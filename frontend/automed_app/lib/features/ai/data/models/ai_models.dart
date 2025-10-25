class DiagnosisPredictionRequest {
  final String patientId;
  final List<String> symptoms;
  final Map<String, double> vitals;
  final String? medicalHistory;
  final int? age;
  final String? gender;

  const DiagnosisPredictionRequest({
    required this.patientId,
    required this.symptoms,
    required this.vitals,
    this.medicalHistory,
    this.age,
    this.gender,
  });

  factory DiagnosisPredictionRequest.fromJson(Map<String, dynamic> json) {
    return DiagnosisPredictionRequest(
      patientId: json['patientId'],
      symptoms: List<String>.from(json['symptoms']),
      vitals: Map<String, double>.from(json['vitals']),
      medicalHistory: json['medicalHistory'],
      age: json['age'],
      gender: json['gender'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'patientId': patientId,
      'symptoms': symptoms,
      'vitals': vitals,
      'medicalHistory': medicalHistory,
      'age': age,
      'gender': gender,
    };
  }
}

class DiagnosisPredictionResponse {
  final List<DiagnosisPrediction> predictions;
  final double confidence;
  final List<String> recommendations;
  final String? riskLevel;
  final Map<String, dynamic>? additionalInfo;

  const DiagnosisPredictionResponse({
    required this.predictions,
    required this.confidence,
    required this.recommendations,
    this.riskLevel,
    this.additionalInfo,
  });

  factory DiagnosisPredictionResponse.fromJson(Map<String, dynamic> json) {
    return DiagnosisPredictionResponse(
      predictions: (json['predictions'] as List)
          .map((e) => DiagnosisPrediction.fromJson(e))
          .toList(),
      confidence: json['confidence'].toDouble(),
      recommendations: List<String>.from(json['recommendations']),
      riskLevel: json['riskLevel'],
      additionalInfo: json['additionalInfo'],
    );
  }
}

class DiagnosisPrediction {
  final String condition;
  final double probability;
  final String severity;
  final String? description;
  final List<String>? suggestedTests;

  const DiagnosisPrediction({
    required this.condition,
    required this.probability,
    required this.severity,
    this.description,
    this.suggestedTests,
  });

  factory DiagnosisPrediction.fromJson(Map<String, dynamic> json) {
    return DiagnosisPrediction(
      condition: json['condition'],
      probability: json['probability'].toDouble(),
      severity: json['severity'],
      description: json['description'],
      suggestedTests: json['suggestedTests'] != null
          ? List<String>.from(json['suggestedTests'])
          : null,
    );
  }
}

class SymptomAnalysisRequest {
  final List<String> symptoms;
  final int duration;
  final String severity;
  final String? patientId;
  final Map<String, dynamic>? context;

  const SymptomAnalysisRequest({
    required this.symptoms,
    required this.duration,
    required this.severity,
    this.patientId,
    this.context,
  });

  factory SymptomAnalysisRequest.fromJson(Map<String, dynamic> json) {
    return SymptomAnalysisRequest(
      symptoms: List<String>.from(json['symptoms']),
      duration: json['duration'],
      severity: json['severity'],
      patientId: json['patientId'],
      context: json['context'],
    );
  }
}

class SymptomAnalysisResponse {
  final List<String> relatedSymptoms;
  final List<String> possibleCauses;
  final String urgencyLevel;
  final List<String> recommendations;
  final String? nextSteps;

  const SymptomAnalysisResponse({
    required this.relatedSymptoms,
    required this.possibleCauses,
    required this.urgencyLevel,
    required this.recommendations,
    this.nextSteps,
  });

  factory SymptomAnalysisResponse.fromJson(Map<String, dynamic> json) {
    return SymptomAnalysisResponse(
      relatedSymptoms: List<String>.from(json['relatedSymptoms']),
      possibleCauses: List<String>.from(json['possibleCauses']),
      urgencyLevel: json['urgencyLevel'],
      recommendations: List<String>.from(json['recommendations']),
      nextSteps: json['nextSteps'],
    );
  }
}

class TFLiteModelInfo {
  final String id;
  final String name;
  final String version;
  final String downloadUrl;
  final int size;
  final String checksum;
  final String? description;
  final List<String>? supportedFeatures;

  const TFLiteModelInfo({
    required this.id,
    required this.name,
    required this.version,
    required this.downloadUrl,
    required this.size,
    required this.checksum,
    this.description,
    this.supportedFeatures,
  });

  factory TFLiteModelInfo.fromJson(Map<String, dynamic> json) {
    return TFLiteModelInfo(
      id: json['id'],
      name: json['name'],
      version: json['version'],
      downloadUrl: json['downloadUrl'],
      size: json['size'],
      checksum: json['checksum'],
      description: json['description'],
      supportedFeatures: json['supportedFeatures'] != null
          ? List<String>.from(json['supportedFeatures'])
          : null,
    );
  }
}
