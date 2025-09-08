import 'package:freezed_annotation/freezed_annotation.dart';

part 'ai_models.freezed.dart';
part 'ai_models.g.dart';

@freezed
class DiagnosisPredictionRequest with _$DiagnosisPredictionRequest {
  const factory DiagnosisPredictionRequest({
    required String patientId,
    required List<String> symptoms,
    required Map<String, double> vitals,
    String? medicalHistory,
    int? age,
    String? gender,
  }) = _DiagnosisPredictionRequest;

  factory DiagnosisPredictionRequest.fromJson(Map<String, dynamic> json) =>
      _$DiagnosisPredictionRequestFromJson(json);
}

@freezed
class DiagnosisPredictionResponse with _$DiagnosisPredictionResponse {
  const factory DiagnosisPredictionResponse({
    required List<DiagnosisPrediction> predictions,
    required double confidence,
    required List<String> recommendations,
    String? riskLevel,
    Map<String, dynamic>? additionalInfo,
  }) = _DiagnosisPredictionResponse;

  factory DiagnosisPredictionResponse.fromJson(Map<String, dynamic> json) =>
      _$DiagnosisPredictionResponseFromJson(json);
}

@freezed
class DiagnosisPrediction with _$DiagnosisPrediction {
  const factory DiagnosisPrediction({
    required String condition,
    required double probability,
    required String severity,
    String? description,
    List<String>? suggestedTests,
  }) = _DiagnosisPrediction;

  factory DiagnosisPrediction.fromJson(Map<String, dynamic> json) =>
      _$DiagnosisPredictionFromJson(json);
}

@freezed
class SymptomAnalysisRequest with _$SymptomAnalysisRequest {
  const factory SymptomAnalysisRequest({
    required List<String> symptoms,
    required int duration,
    required String severity,
    String? patientId,
    Map<String, dynamic>? context,
  }) = _SymptomAnalysisRequest;

  factory SymptomAnalysisRequest.fromJson(Map<String, dynamic> json) =>
      _$SymptomAnalysisRequestFromJson(json);
}

@freezed
class SymptomAnalysisResponse with _$SymptomAnalysisResponse {
  const factory SymptomAnalysisResponse({
    required List<String> relatedSymptoms,
    required List<String> possibleCauses,
    required String urgencyLevel,
    required List<String> recommendations,
    String? nextSteps,
  }) = _SymptomAnalysisResponse;

  factory SymptomAnalysisResponse.fromJson(Map<String, dynamic> json) =>
      _$SymptomAnalysisResponseFromJson(json);
}

@freezed
class TFLiteModelInfo with _$TFLiteModelInfo {
  const factory TFLiteModelInfo({
    required String id,
    required String name,
    required String version,
    required String downloadUrl,
    required int size,
    required String checksum,
    String? description,
    List<String>? supportedFeatures,
  }) = _TFLiteModelInfo;

  factory TFLiteModelInfo.fromJson(Map<String, dynamic> json) =>
      _$TFLiteModelInfoFromJson(json);
}