import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:uuid/uuid.dart';

import '../../../../core/services/api_service.dart';
import '../../../../core/models/ai_models.dart';
import '../pages/ai_assistant_page.dart';

// AI Assistant State Notifier
class AIAssistantNotifier extends StateNotifier<AIAssistantState> {
  final ApiService _apiService;
  final Uuid _uuid = const Uuid();

  AIAssistantNotifier(this._apiService) : super(AIAssistantState(
    status: AIStatus.ready,
    messages: [],
    suggestions: [],
    isProcessing: false,
  ));

  // Send message to AI
  Future<void> sendMessage(String content) async {
    if (content.trim().isEmpty) return;

    // Add user message
    final userMessage = AIMessage(
      id: _uuid.v4(),
      content: content,
      isUser: true,
      timestamp: DateTime.now(),
      actions: [],
    );

    state = state.copyWith(
      messages: [...state.messages, userMessage],
      isProcessing: true,
      status: AIStatus.processing,
    );

    try {
      // Determine the type of AI request based on content
      final aiResponse = await _processAIRequest(content);
      
      // Add AI response message
      final aiMessage = AIMessage(
        id: _uuid.v4(),
        content: aiResponse.content,
        isUser: false,
        timestamp: DateTime.now(),
        actions: aiResponse.actions,
      );

      state = state.copyWith(
        messages: [...state.messages, aiMessage],
        suggestions: aiResponse.suggestions,
        isProcessing: false,
        status: AIStatus.ready,
      );
    } catch (e) {
      // Add error message
      final errorMessage = AIMessage(
        id: _uuid.v4(),
        content: 'I apologize, but I encountered an error processing your request. Please try again.',
        isUser: false,
        timestamp: DateTime.now(),
        actions: [],
      );

      state = state.copyWith(
        messages: [...state.messages, errorMessage],
        isProcessing: false,
        status: AIStatus.error,
        error: e.toString(),
      );
    }
  }

  // Process AI request based on content
  Future<AIResponse> _processAIRequest(String content) async {
    final lowerContent = content.toLowerCase();

    // Symptom analysis
    if (lowerContent.contains('symptom') || lowerContent.contains('pain') || lowerContent.contains('feel')) {
      return await _analyzeSymptoms(content);
    }
    
    // Medication queries
    if (lowerContent.contains('medication') || lowerContent.contains('drug') || lowerContent.contains('pill')) {
      return await _handleMedicationQuery(content);
    }
    
    // Appointment scheduling
    if (lowerContent.contains('appointment') || lowerContent.contains('schedule') || lowerContent.contains('book')) {
      return await _handleAppointmentRequest(content);
    }
    
    // Emergency situations
    if (lowerContent.contains('emergency') || lowerContent.contains('urgent') || lowerContent.contains('help')) {
      return await _handleEmergencyRequest(content);
    }
    
    // General medical query
    return await _handleGeneralQuery(content);
  }

  // Analyze symptoms using AI service
  Future<AIResponse> _analyzeSymptoms(String content) async {
    try {
      // Extract symptoms from the content (simplified)
      final symptoms = _extractSymptoms(content);
      
      final request = SymptomAnalysisRequest(
        symptoms: symptoms,
        duration: 1, // Default duration
        severity: 'moderate', // Default severity
      );

      final response = await _apiService.analyzeSymptoms(request);
      
      if (response.success && response.data != null) {
        final analysis = response.data!;
        
        return AIResponse(
          content: _formatSymptomAnalysis(analysis),
          actions: [
            MessageAction(
              type: MessageActionType.scheduleAppointment,
              data: {'reason': 'symptom_analysis'},
            ),
          ],
          suggestions: [
            AISuggestion(
              id: _uuid.v4(),
              title: 'Schedule Consultation',
              description: 'Book an appointment with a healthcare provider',
              icon: Icons.calendar_today,
              data: {'type': 'consultation'},
            ),
            AISuggestion(
              id: _uuid.v4(),
              title: 'Track Symptoms',
              description: 'Monitor your symptoms over time',
              icon: Icons.track_changes,
              data: {'type': 'symptom_tracking'},
            ),
          ],
        );
      }
    } catch (e) {
      // Fallback response
    }

    return AIResponse(
      content: 'Based on the symptoms you described, I recommend monitoring them closely. If they persist or worsen, please consult with a healthcare provider.',
      actions: [],
      suggestions: [],
    );
  }

  // Handle medication queries
  Future<AIResponse> _handleMedicationQuery(String content) async {
    return AIResponse(
      content: 'I can help you with medication information. What specific medication would you like to know about?',
      actions: [
        MessageAction(
          type: MessageActionType.orderMedication,
          data: {'query': content},
        ),
      ],
      suggestions: [
        AISuggestion(
          id: _uuid.v4(),
          title: 'View Medications',
          description: 'See your current medications',
          icon: Icons.medication,
          data: {'type': 'medication_list'},
        ),
        AISuggestion(
          id: _uuid.v4(),
          title: 'Set Reminder',
          description: 'Set medication reminders',
          icon: Icons.alarm,
          data: {'type': 'medication_reminder'},
        ),
      ],
    );
  }

  // Handle appointment requests
  Future<AIResponse> _handleAppointmentRequest(String content) async {
    return AIResponse(
      content: 'I can help you schedule an appointment. What type of appointment would you like to book?',
      actions: [
        MessageAction(
          type: MessageActionType.scheduleAppointment,
          data: {'request': content},
        ),
      ],
      suggestions: [
        AISuggestion(
          id: _uuid.v4(),
          title: 'General Consultation',
          description: 'Book a general medical consultation',
          icon: Icons.medical_services,
          data: {'type': 'general_consultation'},
        ),
        AISuggestion(
          id: _uuid.v4(),
          title: 'Specialist Appointment',
          description: 'Book with a medical specialist',
          icon: Icons.person_search,
          data: {'type': 'specialist_consultation'},
        ),
      ],
    );
  }

  // Handle emergency requests
  Future<AIResponse> _handleEmergencyRequest(String content) async {
    return AIResponse(
      content: 'If this is a medical emergency, please call emergency services immediately (911). For urgent but non-emergency situations, I can help you find immediate care options.',
      actions: [
        MessageAction(
          type: MessageActionType.requestConsultation,
          data: {'urgency': 'high', 'type': 'emergency'},
        ),
      ],
      suggestions: [
        AISuggestion(
          id: _uuid.v4(),
          title: 'Emergency Services',
          description: 'Call emergency services',
          icon: Icons.emergency,
          data: {'type': 'emergency_call'},
        ),
        AISuggestion(
          id: _uuid.v4(),
          title: 'Urgent Care',
          description: 'Find nearby urgent care',
          icon: Icons.local_hospital,
          data: {'type': 'urgent_care'},
        ),
      ],
    );
  }

  // Handle general queries
  Future<AIResponse> _handleGeneralQuery(String content) async {
    return AIResponse(
      content: 'I\'m here to help with your healthcare needs. You can ask me about symptoms, medications, appointments, or general health questions.',
      actions: [],
      suggestions: [
        AISuggestion(
          id: _uuid.v4(),
          title: 'Health Check',
          description: 'Get a general health assessment',
          icon: Icons.health_and_safety,
          data: {'type': 'health_check'},
        ),
        AISuggestion(
          id: _uuid.v4(),
          title: 'Find Provider',
          description: 'Find healthcare providers near you',
          icon: Icons.search,
          data: {'type': 'find_provider'},
        ),
      ],
    );
  }

  // Apply suggestion
  void applySuggestion(AISuggestion suggestion) {
    // Handle suggestion application based on type
    final message = 'I\'d like to ${suggestion.title.toLowerCase()}.';
    sendMessage(message);
  }

  // Clear conversation
  void clearConversation() {
    state = AIAssistantState(
      status: AIStatus.ready,
      messages: [],
      suggestions: [],
      isProcessing: false,
    );
  }

  // Helper methods
  List<String> _extractSymptoms(String content) {
    // Simplified symptom extraction
    final symptoms = <String>[];
    final commonSymptoms = [
      'headache', 'fever', 'cough', 'pain', 'nausea', 'fatigue',
      'dizziness', 'shortness of breath', 'chest pain', 'abdominal pain'
    ];
    
    for (final symptom in commonSymptoms) {
      if (content.toLowerCase().contains(symptom)) {
        symptoms.add(symptom);
      }
    }
    
    return symptoms.isEmpty ? ['general discomfort'] : symptoms;
  }

  String _formatSymptomAnalysis(SymptomAnalysis analysis) {
    final buffer = StringBuffer();
    buffer.writeln('Based on your symptoms, here\'s what I found:');
    buffer.writeln();
    
    if (analysis.possibleCauses.isNotEmpty) {
      buffer.writeln('Possible causes:');
      for (final cause in analysis.possibleCauses) {
        buffer.writeln('• $cause');
      }
      buffer.writeln();
    }
    
    if (analysis.recommendations.isNotEmpty) {
      buffer.writeln('Recommendations:');
      for (final recommendation in analysis.recommendations) {
        buffer.writeln('• $recommendation');
      }
      buffer.writeln();
    }
    
    buffer.writeln('Urgency level: ${analysis.urgencyLevel}');
    
    if (analysis.nextSteps != null) {
      buffer.writeln();
      buffer.writeln('Next steps: ${analysis.nextSteps}');
    }
    
    return buffer.toString();
  }
}

// AI Response model
class AIResponse {
  final String content;
  final List<MessageAction> actions;
  final List<AISuggestion> suggestions;

  AIResponse({
    required this.content,
    required this.actions,
    required this.suggestions,
  });
}

// State extension
extension AIAssistantStateExtension on AIAssistantState {
  AIAssistantState copyWith({
    AIStatus? status,
    List<AIMessage>? messages,
    List<AISuggestion>? suggestions,
    bool? isProcessing,
    String? error,
  }) {
    return AIAssistantState(
      status: status ?? this.status,
      messages: messages ?? this.messages,
      suggestions: suggestions ?? this.suggestions,
      isProcessing: isProcessing ?? this.isProcessing,
      error: error ?? this.error,
    );
  }
}

// Provider
final aiAssistantProvider = StateNotifierProvider<AIAssistantNotifier, AIAssistantState>((ref) {
  final apiService = ref.watch(apiServiceProvider);
  return AIAssistantNotifier(apiService);
});