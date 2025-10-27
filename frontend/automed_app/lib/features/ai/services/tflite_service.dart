import 'dart:io';
import 'dart:typed_data';
import 'package:flutter/services.dart';
import 'package:path_provider/path_provider.dart';
import 'package:tflite_flutter/tflite_flutter.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:http/http.dart' as http;

import '../../../core/utils/logger.dart';
import '../data/models/ai_models.dart';

class TFLiteService {
  Interpreter? _interpreter;
  String? _currentModelPath;
  
  /// Initialize TensorFlow Lite interpreter with a model
  Future<bool> loadModel(String modelPath) async {
    try {
      // Dispose existing interpreter
      await dispose();
      
      // Load the model
      _interpreter = await Interpreter.fromAsset(modelPath);
      _currentModelPath = modelPath;
      
      Logger.info('TFLite model loaded successfully: $modelPath');
      return true;
    } catch (e) {
      Logger.error('Failed to load TFLite model', e);
      return false;
    }
  }
  
  /// Download and load model from server
  Future<bool> downloadAndLoadModel(TFLiteModelInfo modelInfo) async {
    try {
      final directory = await getApplicationDocumentsDirectory();
      final modelFile = File('${directory.path}/${modelInfo.id}.tflite');
      
      // Check if model already exists and is up to date
      if (await modelFile.exists()) {
        final fileSize = await modelFile.length();
        if (fileSize == modelInfo.size) {
          Logger.info('Model already exists and is up to date');
          return await loadModelFromFile(modelFile.path);
        }
      }
      
      // Download model from server
      Logger.info('Downloading model: ${modelInfo.name}');
      
      try {
        final response = await http.get(Uri.parse(modelInfo.downloadUrl));
        if (response.statusCode == 200) {
          final modelBytes = response.bodyBytes;
          final modelFile = File('${(await getApplicationDocumentsDirectory()).path}/${modelInfo.name}.tflite');
          await modelFile.writeAsBytes(modelBytes);
          Logger.info('Model downloaded successfully: ${modelInfo.name}');
        } else {
          throw Exception('Failed to download model: HTTP ${response.statusCode}');
        }
      } catch (e) {
        Logger.error('Error downloading model: $e');
        // Fall back to assets if download fails
        Logger.info('Falling back to bundled model assets');
      }
      
      return await loadModel('assets/models/${modelInfo.id}.tflite');
    } catch (e) {
      Logger.error('Failed to download and load model', e);
      return false;
    }
  }
  
  /// Load model from file path
  Future<bool> loadModelFromFile(String filePath) async {
    try {
      await dispose();
      _interpreter = await Interpreter.fromFile(File(filePath));
      _currentModelPath = filePath;
      
      Logger.info('TFLite model loaded from file: $filePath');
      return true;
    } catch (e) {
      Logger.error('Failed to load TFLite model from file', e);
      return false;
    }
  }
  
  /// Run inference on symptom data
  Future<DiagnosisPredictionResponse?> predictDiagnosis({
    required List<String> symptoms,
    required Map<String, double> vitals,
    int? age,
    String? gender,
  }) async {
    if (_interpreter == null) {
      Logger.error('TFLite interpreter not initialized');
      return null;
    }
    
    try {
      // Prepare input data
      final inputData = _prepareInputData(symptoms, vitals, age, gender);
      
      // Prepare output buffer
      final outputShape = _interpreter!.getOutputTensor(0).shape;
      final outputData = List.filled(outputShape.reduce((a, b) => a * b), 0.0)
          .reshape(outputShape);
      
      // Run inference
      _interpreter!.run(inputData, outputData);
      
      // Process output
      return _processOutput(outputData);
    } catch (e) {
      Logger.error('TFLite inference failed', e);
      return null;
    }
  }
  
  /// Run symptom analysis
  Future<SymptomAnalysisResponse?> analyzeSymptoms({
    required List<String> symptoms,
    required int duration,
    required String severity,
  }) async {
    if (_interpreter == null) {
      Logger.error('TFLite interpreter not initialized');
      return null;
    }
    
    try {
      // Prepare input for symptom analysis
      final inputData = _prepareSymptomInputData(symptoms, duration, severity);
      
      // Run inference
      final outputShape = _interpreter!.getOutputTensor(0).shape;
      final outputData = List.filled(outputShape.reduce((a, b) => a * b), 0.0)
          .reshape(outputShape);
      
      _interpreter!.run(inputData, outputData);
      
      // Process output for symptom analysis
      return _processSymptomOutput(outputData);
    } catch (e) {
      Logger.error('Symptom analysis failed', e);
      return null;
    }
  }
  
  /// Check if model is loaded
  bool get isModelLoaded => _interpreter != null;
  
  /// Get current model path
  String? get currentModelPath => _currentModelPath;
  
  /// Get model input shape
  List<int>? get inputShape => _interpreter?.getInputTensor(0).shape;
  
  /// Get model output shape
  List<int>? get outputShape => _interpreter?.getOutputTensor(0).shape;
  
  /// Dispose resources
  Future<void> dispose() async {
    _interpreter?.close();
    _interpreter = null;
    _currentModelPath = null;
  }
  
  // Private helper methods
  
  List<List<double>> _prepareInputData(
    List<String> symptoms,
    Map<String, double> vitals,
    int? age,
    String? gender,
  ) {
    // This is a simplified example - in reality, you'd need to:
    // 1. Convert symptoms to numerical features (one-hot encoding, embeddings, etc.)
    // 2. Normalize vital signs
    // 3. Encode categorical variables like gender
    // 4. Create feature vector matching model's expected input
    
    final features = <double>[];
    
    // Add age (normalized)
    features.add((age ?? 30) / 100.0);
    
    // Add gender (encoded)
    features.add(gender == 'male' ? 1.0 : 0.0);
    
    // Add vital signs (normalized)
    features.add((vitals['heartRate'] ?? 70) / 200.0);
    features.add((vitals['bloodPressureSystolic'] ?? 120) / 300.0);
    features.add((vitals['bloodPressureDiastolic'] ?? 80) / 200.0);
    features.add((vitals['temperature'] ?? 98.6) / 110.0);
    features.add((vitals['oxygenSaturation'] ?? 98) / 100.0);
    
    // Add symptom features (simplified - would need proper encoding)
    final commonSymptoms = [
      'fever', 'cough', 'headache', 'fatigue', 'nausea', 'chest_pain',
      'shortness_of_breath', 'dizziness', 'abdominal_pain', 'back_pain'
    ];
    
    for (final symptom in commonSymptoms) {
      features.add(symptoms.contains(symptom) ? 1.0 : 0.0);
    }
    
    return [features];
  }
  
  List<List<double>> _prepareSymptomInputData(
    List<String> symptoms,
    int duration,
    String severity,
  ) {
    final features = <double>[];
    
    // Add duration (normalized)
    features.add(duration / 30.0); // Normalize by 30 days
    
    // Add severity (encoded)
    final severityMap = {'mild': 0.3, 'moderate': 0.6, 'severe': 1.0};
    features.add(severityMap[severity.toLowerCase()] ?? 0.5);
    
    // Add symptom features
    final commonSymptoms = [
      'fever', 'cough', 'headache', 'fatigue', 'nausea', 'chest_pain',
      'shortness_of_breath', 'dizziness', 'abdominal_pain', 'back_pain'
    ];
    
    for (final symptom in commonSymptoms) {
      features.add(symptoms.contains(symptom) ? 1.0 : 0.0);
    }
    
    return [features];
  }
  
  DiagnosisPredictionResponse _processOutput(List<dynamic> outputData) {
    // This is a simplified example - in reality, you'd need to:
    // 1. Interpret the model's output format
    // 2. Map numerical outputs to condition names
    // 3. Calculate confidence scores
    // 4. Generate recommendations based on predictions
    
    final predictions = <DiagnosisPrediction>[];
    final rawOutput = outputData[0] as List<double>;
    
    // Map output probabilities to medical conditions
    final conditions = [
      'Common Cold', 'Flu', 'COVID-19', 'Pneumonia', 'Bronchitis',
      'Allergic Reaction', 'Migraine', 'Hypertension', 'Diabetes', 'Other'
    ];
    
    for (int i = 0; i < conditions.length && i < rawOutput.length; i++) {
      if (rawOutput[i] > 0.1) { // Only include predictions above 10%
        predictions.add(DiagnosisPrediction(
          condition: conditions[i],
          probability: rawOutput[i],
          severity: rawOutput[i] > 0.7 ? 'High' : rawOutput[i] > 0.4 ? 'Medium' : 'Low',
          description: 'AI-generated prediction based on symptoms and vitals',
          suggestedTests: _getSuggestedTests(conditions[i]),
        ));
      }
    }
    
    // Sort by probability
    predictions.sort((a, b) => b.probability.compareTo(a.probability));
    
    final maxConfidence = predictions.isNotEmpty ? predictions.first.probability : 0.0;
    
    return DiagnosisPredictionResponse(
      predictions: predictions.take(5).toList(), // Top 5 predictions
      confidence: maxConfidence,
      recommendations: _generateRecommendations(predictions),
      riskLevel: maxConfidence > 0.8 ? 'High' : maxConfidence > 0.5 ? 'Medium' : 'Low',
    );
  }
  
  SymptomAnalysisResponse _processSymptomOutput(List<dynamic> outputData) {
    // Process output for symptom analysis
    final rawOutput = outputData[0] as List<double>;
    
    return SymptomAnalysisResponse(
      relatedSymptoms: ['Related symptom 1', 'Related symptom 2'],
      possibleCauses: ['Possible cause 1', 'Possible cause 2'],
      urgencyLevel: rawOutput[0] > 0.8 ? 'High' : rawOutput[0] > 0.5 ? 'Medium' : 'Low',
      recommendations: ['Recommendation 1', 'Recommendation 2'],
      nextSteps: 'Consult with healthcare provider',
    );
  }
  
  List<String> _getSuggestedTests(String condition) {
    final testMap = {
      'Common Cold': ['Complete Blood Count'],
      'Flu': ['Rapid Flu Test', 'Complete Blood Count'],
      'COVID-19': ['COVID-19 PCR Test', 'Chest X-ray'],
      'Pneumonia': ['Chest X-ray', 'Complete Blood Count', 'Sputum Culture'],
      'Bronchitis': ['Chest X-ray', 'Pulmonary Function Test'],
    };
    
    return testMap[condition] ?? ['General Health Checkup'];
  }
  
  List<String> _generateRecommendations(List<DiagnosisPrediction> predictions) {
    final recommendations = <String>[];
    
    if (predictions.isEmpty) {
      recommendations.add('Monitor symptoms and consult healthcare provider if they persist');
      return recommendations;
    }
    
    final topPrediction = predictions.first;
    
    if (topPrediction.probability > 0.8) {
      recommendations.add('Seek immediate medical attention');
    } else if (topPrediction.probability > 0.5) {
      recommendations.add('Schedule appointment with healthcare provider');
    } else {
      recommendations.add('Monitor symptoms and rest');
    }
    
    recommendations.add('Stay hydrated and get adequate rest');
    recommendations.add('Follow up if symptoms worsen or persist');
    
    return recommendations;
  }
}

// Provider
final tfliteServiceProvider = Provider<TFLiteService>((ref) {
  return TFLiteService();
});