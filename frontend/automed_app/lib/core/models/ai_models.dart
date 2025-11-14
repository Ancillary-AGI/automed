import 'package:json_annotation/json_annotation.dart';

part 'ai_models.g.dart';

@JsonSerializable()
class DiagnosisPrediction {
  final String condition;
  final double probability;
  final String severity;
  final String? description;
  final List<String>? suggestedTests;

  DiagnosisPrediction({
    required this.condition,
    required this.probability,
    required this.severity,
    this.description,
    this.suggestedTests,
  });

  factory DiagnosisPrediction.fromJson(Map<String, dynamic> json) =>
      _$DiagnosisPredictionFromJson(json);
  Map<String, dynamic> toJson() => _$DiagnosisPredictionToJson(this);
}

@JsonSerializable()
class SymptomAnalysis {
  final List<String> relatedSymptoms;
  final List<String> possibleCauses;
  final String urgencyLevel;
  final List<String> recommendations;
  final String? nextSteps;

  SymptomAnalysis({
    required this.relatedSymptoms,
    required this.possibleCauses,
    required this.urgencyLevel,
    required this.recommendations,
    this.nextSteps,
  });

  factory SymptomAnalysis.fromJson(Map<String, dynamic> json) =>
      _$SymptomAnalysisFromJson(json);
  Map<String, dynamic> toJson() => _$SymptomAnalysisToJson(this);
}

@JsonSerializable()
class TriageResult {
  final String priority;
  final int estimatedWaitTime;
  final String recommendedDepartment;
  final double urgencyScore;
  final String reasoning;

  TriageResult({
    required this.priority,
    required this.estimatedWaitTime,
    required this.recommendedDepartment,
    required this.urgencyScore,
    required this.reasoning,
  });

  factory TriageResult.fromJson(Map<String, dynamic> json) =>
      _$TriageResultFromJson(json);
  Map<String, dynamic> toJson() => _$TriageResultToJson(this);
}

@JsonSerializable()
class ImageAnalysisResult {
  final String patientId;
  final String imageType;
  final List<ImageFinding> findings;
  final double confidence;
  final List<String> recommendations;
  final String urgencyLevel;

  ImageAnalysisResult({
    required this.patientId,
    required this.imageType,
    required this.findings,
    required this.confidence,
    required this.recommendations,
    required this.urgencyLevel,
  });

  factory ImageAnalysisResult.fromJson(Map<String, dynamic> json) =>
      _$ImageAnalysisResultFromJson(json);
  Map<String, dynamic> toJson() => _$ImageAnalysisResultToJson(this);
}

@JsonSerializable()
class ImageFinding {
  final ImageLocation location;
  final String condition;
  final double probability;
  final String severity;
  final String description;

  ImageFinding({
    required this.location,
    required this.condition,
    required this.probability,
    required this.severity,
    required this.description,
  });

  factory ImageFinding.fromJson(Map<String, dynamic> json) =>
      _$ImageFindingFromJson(json);
  Map<String, dynamic> toJson() => _$ImageFindingToJson(this);
}

@JsonSerializable()
class ImageLocation {
  final double x;
  final double y;
  final double width;
  final double height;
  final String? anatomicalRegion;

  ImageLocation({
    required this.x,
    required this.y,
    required this.width,
    required this.height,
    this.anatomicalRegion,
  });

  factory ImageLocation.fromJson(Map<String, dynamic> json) =>
      _$ImageLocationFromJson(json);
  Map<String, dynamic> toJson() => _$ImageLocationToJson(this);
}

@JsonSerializable()
class WearableAnalysisResult {
  final String patientId;
  final String deviceType;
  final WearableAnalysis analysis;
  final List<HealthInsight> insights;
  final List<String> recommendations;

  WearableAnalysisResult({
    required this.patientId,
    required this.deviceType,
    required this.analysis,
    required this.insights,
    required this.recommendations,
  });

  factory WearableAnalysisResult.fromJson(Map<String, dynamic> json) =>
      _$WearableAnalysisResultFromJson(json);
  Map<String, dynamic> toJson() => _$WearableAnalysisResultToJson(this);
}

@JsonSerializable()
class WearableAnalysis {
  final double averageHeartRate;
  final double heartRateVariability;
  final double sleepQualityScore;
  final double activityScore;
  final String stressTrend;

  WearableAnalysis({
    required this.averageHeartRate,
    required this.heartRateVariability,
    required this.sleepQualityScore,
    required this.activityScore,
    required this.stressTrend,
  });

  factory WearableAnalysis.fromJson(Map<String, dynamic> json) =>
      _$WearableAnalysisFromJson(json);
  Map<String, dynamic> toJson() => _$WearableAnalysisToJson(this);
}

@JsonSerializable()
class HealthInsight {
  final String type;
  final String message;
  final double confidence;
  final bool actionable;
  final String priority;

  HealthInsight({
    required this.type,
    required this.message,
    required this.confidence,
    required this.actionable,
    required this.priority,
  });

  factory HealthInsight.fromJson(Map<String, dynamic> json) =>
      _$HealthInsightFromJson(json);
  Map<String, dynamic> toJson() => _$HealthInsightToJson(this);
}

@JsonSerializable()
class VoiceAnalysisResult {
  final String patientId;
  final String transcription;
  final SentimentAnalysis sentiment;
  final List<MedicalTerm> medicalTerms;
  final String urgencyLevel;
  final List<String> recommendations;

  VoiceAnalysisResult({
    required this.patientId,
    required this.transcription,
    required this.sentiment,
    required this.medicalTerms,
    required this.urgencyLevel,
    required this.recommendations,
  });

  factory VoiceAnalysisResult.fromJson(Map<String, dynamic> json) =>
      _$VoiceAnalysisResultFromJson(json);
  Map<String, dynamic> toJson() => _$VoiceAnalysisResultToJson(this);
}

@JsonSerializable()
class SentimentAnalysis {
  final String overall;
  final double confidence;
  final Map<String, double> emotions;

  SentimentAnalysis({
    required this.overall,
    required this.confidence,
    required this.emotions,
  });

  factory SentimentAnalysis.fromJson(Map<String, dynamic> json) =>
      _$SentimentAnalysisFromJson(json);
  Map<String, dynamic> toJson() => _$SentimentAnalysisToJson(this);
}

@JsonSerializable()
class MedicalTerm {
  final String term;
  final String category;
  final double confidence;
  final String context;

  MedicalTerm({
    required this.term,
    required this.category,
    required this.confidence,
    required this.context,
  });

  factory MedicalTerm.fromJson(Map<String, dynamic> json) =>
      _$MedicalTermFromJson(json);
  Map<String, dynamic> toJson() => _$MedicalTermToJson(this);
}

@JsonSerializable()
class PopulationHealthAnalysis {
  final String region;
  final String condition;
  final int currentCases;
  final TrendAnalysis trend;
  final List<String> recommendations;

  PopulationHealthAnalysis({
    required this.region,
    required this.condition,
    required this.currentCases,
    required this.trend,
    required this.recommendations,
  });

  factory PopulationHealthAnalysis.fromJson(Map<String, dynamic> json) =>
      _$PopulationHealthAnalysisFromJson(json);
  Map<String, dynamic> toJson() => _$PopulationHealthAnalysisToJson(this);
}

@JsonSerializable()
class TrendAnalysis {
  final String direction;
  final double rate;
  final double confidence;

  TrendAnalysis({
    required this.direction,
    required this.rate,
    required this.confidence,
  });

  factory TrendAnalysis.fromJson(Map<String, dynamic> json) =>
      _$TrendAnalysisFromJson(json);
  Map<String, dynamic> toJson() => _$TrendAnalysisToJson(this);
}

@JsonSerializable()
class OutbreakDetection {
  final String region;
  final double outbreakProbability;
  final List<String> recommendedActions;
  final String alertLevel;

  OutbreakDetection({
    required this.region,
    required this.outbreakProbability,
    required this.recommendedActions,
    required this.alertLevel,
  });

  factory OutbreakDetection.fromJson(Map<String, dynamic> json) =>
      _$OutbreakDetectionFromJson(json);
  Map<String, dynamic> toJson() => _$OutbreakDetectionToJson(this);
}

@JsonSerializable()
class AIModel {
  final String id;
  final String name;
  final String version;
  final String type;
  final String? description;
  final List<String>? supportedFeatures;

  AIModel({
    required this.id,
    required this.name,
    required this.version,
    required this.type,
    this.description,
    this.supportedFeatures,
  });

  factory AIModel.fromJson(Map<String, dynamic> json) =>
      _$AIModelFromJson(json);
  Map<String, dynamic> toJson() => _$AIModelToJson(this);
}

// Request DTOs
@JsonSerializable()
class DiagnosisRequest {
  final String patientId;
  final List<String> symptoms;
  final Map<String, double> vitals;
  final String? medicalHistory;

  DiagnosisRequest({
    required this.patientId,
    required this.symptoms,
    required this.vitals,
    this.medicalHistory,
  });

  factory DiagnosisRequest.fromJson(Map<String, dynamic> json) =>
      _$DiagnosisRequestFromJson(json);
  Map<String, dynamic> toJson() => _$DiagnosisRequestToJson(this);
}

@JsonSerializable()
class SymptomAnalysisRequest {
  final List<String> symptoms;
  final int duration;
  final String severity;
  final String? patientId;

  SymptomAnalysisRequest({
    required this.symptoms,
    required this.duration,
    required this.severity,
    this.patientId,
  });

  factory SymptomAnalysisRequest.fromJson(Map<String, dynamic> json) =>
      _$SymptomAnalysisRequestFromJson(json);
  Map<String, dynamic> toJson() => _$SymptomAnalysisRequestToJson(this);
}

@JsonSerializable()
class TriageRequest {
  final String patientId;
  final List<String> symptoms;
  final Map<String, double> vitals;
  final String? chiefComplaint;

  TriageRequest({
    required this.patientId,
    required this.symptoms,
    required this.vitals,
    this.chiefComplaint,
  });

  factory TriageRequest.fromJson(Map<String, dynamic> json) =>
      _$TriageRequestFromJson(json);
  Map<String, dynamic> toJson() => _$TriageRequestToJson(this);
}

@JsonSerializable()
class ImageAnalysisRequest {
  final String patientId;
  final String imageType;
  final String imageData;
  final Map<String, dynamic>? clinicalContext;

  ImageAnalysisRequest({
    required this.patientId,
    required this.imageType,
    required this.imageData,
    this.clinicalContext,
  });

  factory ImageAnalysisRequest.fromJson(Map<String, dynamic> json) =>
      _$ImageAnalysisRequestFromJson(json);
  Map<String, dynamic> toJson() => _$ImageAnalysisRequestToJson(this);
}

@JsonSerializable()
class WearableDataRequest {
  final String patientId;
  final String deviceType;
  final List<WearableDataPoint> dataPoints;

  WearableDataRequest({
    required this.patientId,
    required this.deviceType,
    required this.dataPoints,
  });

  factory WearableDataRequest.fromJson(Map<String, dynamic> json) =>
      _$WearableDataRequestFromJson(json);
  Map<String, dynamic> toJson() => _$WearableDataRequestToJson(this);
}

@JsonSerializable()
class WearableDataPoint {
  final int timestamp;
  final double? heartRate;
  final double? bloodPressureSystolic;
  final double? bloodPressureDiastolic;
  final double? temperature;
  final double? oxygenSaturation;

  WearableDataPoint({
    required this.timestamp,
    this.heartRate,
    this.bloodPressureSystolic,
    this.bloodPressureDiastolic,
    this.temperature,
    this.oxygenSaturation,
  });

  factory WearableDataPoint.fromJson(Map<String, dynamic> json) =>
      _$WearableDataPointFromJson(json);
  Map<String, dynamic> toJson() => _$WearableDataPointToJson(this);
}

@JsonSerializable()
class VoiceAnalysisRequest {
  final String patientId;
  final String audioData;
  final String analysisType;
  final String? language;

  VoiceAnalysisRequest({
    required this.patientId,
    required this.audioData,
    required this.analysisType,
    this.language,
  });

  factory VoiceAnalysisRequest.fromJson(Map<String, dynamic> json) =>
      _$VoiceAnalysisRequestFromJson(json);
  Map<String, dynamic> toJson() => _$VoiceAnalysisRequestToJson(this);
}

@JsonSerializable()
class PopulationHealthRequest {
  final String region;
  final String condition;
  final int timeRangeDays;
  final bool? includeForecasting;

  PopulationHealthRequest({
    required this.region,
    required this.condition,
    required this.timeRangeDays,
    this.includeForecasting,
  });

  factory PopulationHealthRequest.fromJson(Map<String, dynamic> json) =>
      _$PopulationHealthRequestFromJson(json);
  Map<String, dynamic> toJson() => _$PopulationHealthRequestToJson(this);
}

@JsonSerializable()
class OutbreakDetectionRequest {
  final String region;
  final List<String> symptoms;
  final int caseCount;
  final Map<String, dynamic>? demographics;

  OutbreakDetectionRequest({
    required this.region,
    required this.symptoms,
    required this.caseCount,
    this.demographics,
  });

  factory OutbreakDetectionRequest.fromJson(Map<String, dynamic> json) =>
      _$OutbreakDetectionRequestFromJson(json);
  Map<String, dynamic> toJson() => _$OutbreakDetectionRequestToJson(this);
}

@JsonSerializable()
class AIMessage {
  final String id;
  final String content;
  final bool isUser;
  final DateTime timestamp;
  final MessageType type;
  final Map<String, dynamic>? metadata;

  AIMessage({
    required this.id,
    required this.content,
    required this.isUser,
    required this.timestamp,
    required this.type,
    this.metadata,
  });

  factory AIMessage.fromJson(Map<String, dynamic> json) =>
      _$AIMessageFromJson(json);
  Map<String, dynamic> toJson() => _$AIMessageToJson(this);
}

enum MessageType {
  @JsonValue('TEXT')
  text,
  @JsonValue('DIAGNOSIS')
  diagnosis,
  @JsonValue('RECOMMENDATION')
  recommendation,
  @JsonValue('ALERT')
  alert,
  @JsonValue('SUMMARY')
  summary,
  @JsonValue('ANALYSIS')
  analysis,
}
