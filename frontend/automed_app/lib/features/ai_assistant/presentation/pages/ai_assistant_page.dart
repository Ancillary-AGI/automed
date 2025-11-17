import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:speech_to_text/speech_to_text.dart' as stt;
import 'package:flutter_tts/flutter_tts.dart';

import 'package:automed_app/core/theme/app_colors.dart';
import 'package:automed_app/core/models/ai_models.dart';
import '../providers/ai_assistant_provider.dart';
import '../widgets/ai_chat_bubble.dart';
import '../widgets/voice_input_button.dart';

class AIAssistantPage extends ConsumerStatefulWidget {
  const AIAssistantPage({super.key});

  @override
  ConsumerState<AIAssistantPage> createState() => _AIAssistantPageState();
}

class _AIAssistantPageState extends ConsumerState<AIAssistantPage>
    with TickerProviderStateMixin {
  final TextEditingController _messageController = TextEditingController();
  final ScrollController _scrollController = ScrollController();
  final stt.SpeechToText _speech = stt.SpeechToText();
  final FlutterTts _tts = FlutterTts();

  late AnimationController _pulseController;
  late Animation<double> _pulseAnimation;

  bool _isListening = false;

  @override
  void initState() {
    super.initState();
    _initializeSpeech();
    _initializeTTS();
    _setupAnimations();
  }

  @override
  void dispose() {
    _messageController.dispose();
    _scrollController.dispose();
    _pulseController.dispose();
    super.dispose();
  }

  void _initializeSpeech() async {
    await _speech.initialize(
      onStatus: (status) {
        setState(() {
          _isListening = status == 'listening';
        });
      },
      onError: (error) {
        setState(() {
          _isListening = false;
        });
      },
    );
  }

  void _initializeTTS() async {
    await _tts.setLanguage('en-US');
    await _tts.setSpeechRate(0.5);
    await _tts.setVolume(1.0);
    await _tts.setPitch(1.0);
  }

  void _setupAnimations() {
    _pulseController = AnimationController(
      duration: const Duration(seconds: 1),
      vsync: this,
    );
    _pulseAnimation = Tween<double>(
      begin: 1.0,
      end: 1.2,
    ).animate(CurvedAnimation(
      parent: _pulseController,
      curve: Curves.easeInOut,
    ));
  }

  @override
  Widget build(BuildContext context) {
    final aiState = ref.watch(aiAssistantProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('AI Medical Assistant'),
        backgroundColor: AppColors.appPrimary,
        foregroundColor: Colors.white,
        actions: [
          IconButton(
            icon: const Icon(Icons.settings),
            onPressed: () => _showSettingsDialog(),
          ),
          IconButton(
            icon: const Icon(Icons.help_outline),
            onPressed: () => _showHelpDialog(),
          ),
        ],
      ),
      body: Column(
        children: [
          // AI Status Bar
          _buildAIStatusBar(aiState),

          // Suggestions Panel
          if (aiState.suggestions.isNotEmpty)
            _buildSuggestionsPanel(aiState.suggestions),

          // Chat Messages
          Expanded(
            child: _buildChatArea(aiState),
          ),

          // Input Area
          _buildInputArea(aiState),
        ],
      ),
    );
  }

  Widget _buildAIStatusBar(AIAssistantState state) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: _getStatusColor(state.status),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.1),
            blurRadius: 4,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Row(
        children: [
          AnimatedBuilder(
            animation: _pulseAnimation,
            builder: (context, child) {
              return Transform.scale(
                scale: state.isProcessing ? _pulseAnimation.value : 1.0,
                child: Icon(
                  _getStatusIcon(state.status),
                  color: Colors.white,
                  size: 20,
                ),
              );
            },
          ),
          const SizedBox(width: 8),
          Expanded(
            child: Text(
              _getStatusText(state.status),
              style: const TextStyle(
                color: Colors.white,
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
          if (state.isProcessing)
            const SizedBox(
              width: 16,
              height: 16,
              child: CircularProgressIndicator(
                strokeWidth: 2,
                valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildSuggestionsPanel(List<AISuggestion> suggestions) {
    return Container(
      height: 120,
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Suggested Actions',
            style: TextStyle(
              fontWeight: FontWeight.w600,
              fontSize: 14,
            ),
          ),
          const SizedBox(height: 8),
          Expanded(
            child: ListView.builder(
              scrollDirection: Axis.horizontal,
              itemCount: suggestions.length,
              itemBuilder: (context, index) {
                final suggestion = suggestions[index];
                return Padding(
                  padding: const EdgeInsets.only(right: 8),
                  child: AISuggestionCard(
                    suggestion: suggestion,
                    onTap: () => _applySuggestion(suggestion),
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildChatArea(AIAssistantState state) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: ListView.builder(
        controller: _scrollController,
        itemCount: state.messages.length,
        itemBuilder: (context, index) {
          final message = state.messages[index];
          return Padding(
            padding: const EdgeInsets.only(bottom: 16),
            child: AIChatBubble(
              message: message,
              onSpeakMessage: _speakMessage,
              onCopyMessage: _copyMessage,
            ),
          );
        },
      ),
    );
  }

  Widget _buildInputArea(AIAssistantState state) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.1),
            blurRadius: 4,
            offset: const Offset(0, -2),
          ),
        ],
      ),
      child: SafeArea(
        child: Row(
          children: [
            // Voice Input Button
            VoiceInputButton(
              onPressed: _toggleListening,
            ),

            const SizedBox(width: 12),

            // Text Input
            Expanded(
              child: TextField(
                controller: _messageController,
                enabled: !state.isProcessing,
                decoration: InputDecoration(
                  hintText: 'Ask me anything about healthcare...',
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(24),
                    borderSide: BorderSide.none,
                  ),
                  filled: true,
                  fillColor: AppColors.grey100,
                  contentPadding: const EdgeInsets.symmetric(
                    horizontal: 16,
                    vertical: 12,
                  ),
                ),
                maxLines: null,
                textCapitalization: TextCapitalization.sentences,
                onSubmitted: (text) => _sendMessage(text),
              ),
            ),

            const SizedBox(width: 12),

            // Send Button
            AnimatedContainer(
              duration: const Duration(milliseconds: 200),
              child: IconButton(
                onPressed: state.isProcessing
                    ? null
                    : () => _sendMessage(_messageController.text),
                icon: Icon(
                  Icons.send,
                  color: state.isProcessing
                      ? AppColors.grey400
                      : AppColors.appPrimary,
                ),
                style: IconButton.styleFrom(
                  backgroundColor: state.isProcessing
                      ? AppColors.grey200
                      : AppColors.appPrimary.withValues(alpha: 0.1),
                  shape: const CircleBorder(),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  // Helper methods
  Color _getStatusColor(AIStatus status) {
    switch (status) {
      case AIStatus.ready:
        return AppColors.appSuccess;
      case AIStatus.processing:
        return AppColors.appPrimary;
      case AIStatus.error:
        return AppColors.appError;
      case AIStatus.offline:
        return AppColors.grey600;
    }
  }

  IconData _getStatusIcon(AIStatus status) {
    switch (status) {
      case AIStatus.ready:
        return Icons.check_circle;
      case AIStatus.processing:
        return Icons.psychology;
      case AIStatus.error:
        return Icons.error;
      case AIStatus.offline:
        return Icons.cloud_off;
    }
  }

  String _getStatusText(AIStatus status) {
    switch (status) {
      case AIStatus.ready:
        return 'AI Assistant Ready';
      case AIStatus.processing:
        return 'Processing your request...';
      case AIStatus.error:
        return 'AI Assistant Error';
      case AIStatus.offline:
        return 'AI Assistant Offline';
    }
  }

  void _toggleListening() async {
    if (_isListening) {
      await _speech.stop();
    } else {
      await _speech.listen(
        onResult: (result) {
          setState(() {
            _messageController.text = result.recognizedWords;
          });
          if (result.finalResult) {
            _sendMessage(result.recognizedWords);
          }
        },
        listenFor: const Duration(seconds: 30),
        pauseFor: const Duration(seconds: 3),
      );
    }
  }

  void _sendMessage(String text) {
    if (text.trim().isEmpty) return;

    ref.read(aiAssistantProvider.notifier).sendMessage(text);
    _messageController.clear();

    // Auto-scroll to bottom
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (_scrollController.hasClients) {
        _scrollController.animateTo(
          _scrollController.position.maxScrollExtent,
          duration: const Duration(milliseconds: 300),
          curve: Curves.easeOut,
        );
      }
    });
  }

  void _speakMessage(String text) async {
    await _tts.speak(text);
  }

  void _copyMessage(String text) {
    Clipboard.setData(ClipboardData(text: text));
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Message copied to clipboard'),
        duration: Duration(seconds: 2),
      ),
    );
  }

  void _applySuggestion(AISuggestion suggestion) {
    ref.read(aiAssistantProvider.notifier).applySuggestion(suggestion);
  }

  void _showSettingsDialog() {
    showDialog(
      context: context,
      builder: (context) => const AISettingsDialog(),
    );
  }

  void _showHelpDialog() {
    showDialog(
      context: context,
      builder: (context) => const AIHelpDialog(),
    );
  }
}

// Supporting widgets and classes would be defined in separate files
class AISuggestionCard extends StatelessWidget {
  final AISuggestion suggestion;
  final VoidCallback onTap;

  const AISuggestionCard({
    super.key,
    required this.suggestion,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: 200,
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: AppColors.appPrimary.withValues(alpha: 0.1),
          borderRadius: BorderRadius.circular(8),
          border: Border.all(color: AppColors.appPrimary.withValues(alpha: 0.3)),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Icon(
              suggestion.icon,
              color: AppColors.appPrimary,
              size: 20,
            ),
            const SizedBox(height: 4),
            Text(
              suggestion.title,
              style: const TextStyle(
                fontWeight: FontWeight.w600,
                fontSize: 12,
              ),
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
            ),
            const SizedBox(height: 2),
            Text(
              suggestion.description,
              style: const TextStyle(
                fontSize: 10,
                color: AppColors.textSecondary,
              ),
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
            ),
          ],
        ),
      ),
    );
  }
}

class AISettingsDialog extends StatelessWidget {
  const AISettingsDialog({super.key});

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Text('AI Assistant Settings'),
      content: const Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          // Settings content
          Text('AI Assistant settings will be implemented here'),
        ],
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.of(context).pop(),
          child: const Text('Close'),
        ),
      ],
    );
  }
}

class AIHelpDialog extends StatelessWidget {
  const AIHelpDialog({super.key});

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Text('AI Assistant Help'),
      content: const SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              'How to use the AI Assistant:',
              style: TextStyle(fontWeight: FontWeight.w600),
            ),
            SizedBox(height: 8),
            Text('• Ask questions about symptoms, medications, or treatments'),
            Text('• Use voice input by tapping the microphone button'),
            Text('• Tap on suggested actions for quick access'),
            Text('• The AI can help with scheduling, reminders, and more'),
            SizedBox(height: 16),
            Text(
              'Example questions:',
              style: TextStyle(fontWeight: FontWeight.w600),
            ),
            SizedBox(height: 8),
            Text('• "What are the side effects of aspirin?"'),
            Text('• "Schedule an appointment with my cardiologist"'),
            Text('• "Remind me to take my medication"'),
            Text('• "What should I do about chest pain?"'),
          ],
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.of(context).pop(),
          child: const Text('Got it'),
        ),
      ],
    );
  }
}

// Enums and data classes
enum AIStatus { ready, processing, error, offline }

enum MessageActionType {
  scheduleAppointment,
  orderMedication,
  requestConsultation,
  viewResults
}

class AISuggestion {
  final String id;
  final String title;
  final String description;
  final IconData icon;
  final Map<String, dynamic> data;

  AISuggestion({
    required this.id,
    required this.title,
    required this.description,
    required this.icon,
    required this.data,
  });
}

class MessageAction {
  final MessageActionType type;
  final Map<String, dynamic> data;

  MessageAction({
    required this.type,
    required this.data,
  });
}

class AIAssistantState {
  final AIStatus status;
  final List<AIMessage> messages;
  final List<AISuggestion> suggestions;
  final bool isProcessing;
  final String? error;

  AIAssistantState({
    required this.status,
    required this.messages,
    required this.suggestions,
    required this.isProcessing,
    this.error,
  });
}
