// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'ai_models.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

DiagnosisPrediction _$DiagnosisPredictionFromJson(Map<String, dynamic> json) =>
    DiagnosisPrediction(
      condition: json['condition'] as String,
      probability: (json['probability'] as num).toDouble(),
      severity: json['severity'] as String,
      description: json['description'] as String?,
      suggestedTests: (json['suggestedTests'] as List<dynamic>?)
          ?.map((e) => e as String)
          .toList(),
    );

Map<String, dynamic> _$DiagnosisPredictionToJson(
        DiagnosisPrediction instance) =>
    <String, dynamic>{
      'condition': instance.condition,
      'probability': instance.probability,
      'severity': instance.severity,
      'description': instance.description,
      'suggestedTests': instance.suggestedTests,
    };

SymptomAnalysis _$SymptomAnalysisFromJson(Map<String, dynamic> json) =>
    SymptomAnalysis(
      relatedSymptoms: (json['relatedSymptoms'] as List<dynamic>)
          .map((e) => e as String)
          .toList(),
      possibleCauses: (json['possibleCauses'] as List<dynamic>)
          .map((e) => e as String)
          .toList(),
      urgencyLevel: json['urgencyLevel'] as String,
      recommendations: (json['recommendations'] as List<dynamic>)
          .map((e) => e as String)
          .toList(),
      nextSteps: json['nextSteps'] as String?,
    );

Map<String, dynamic> _$SymptomAnalysisToJson(SymptomAnalysis instance) =>
    <String, dynamic>{
      'relatedSymptoms': instance.relatedSymptoms,
      'possibleCauses': instance.possibleCauses,
      'urgencyLevel': instance.urgencyLevel,
      'recommendations': instance.recommendations,
      'nextSteps': instance.nextSteps,
    };

TriageResult _$TriageResultFromJson(Map<String, dynamic> json) => TriageResult(
      priority: json['priority'] as String,
      estimatedWaitTime: (json['estimatedWaitTime'] as num).toInt(),
      recommendedDepartment: json['recommendedDepartment'] as String,
      urgencyScore: (json['urgencyScore'] as num).toDouble(),
      reasoning: json['reasoning'] as String,
    );

Map<String, dynamic> _$TriageResultToJson(TriageResult instance) =>
    <String, dynamic>{
      'priority': instance.priority,
      'estimatedWaitTime': instance.estimatedWaitTime,
      'recommendedDepartment': instance.recommendedDepartment,
      'urgencyScore': instance.urgencyScore,
      'reasoning': instance.reasoning,
    };

ImageAnalysisResult _$ImageAnalysisResultFromJson(Map<String, dynamic> json) =>
    ImageAnalysisResult(
      patientId: json['patientId'] as String,
      imageType: json['imageType'] as String,
      findings: (json['findings'] as List<dynamic>)
          .map((e) => ImageFinding.fromJson(e as Map<String, dynamic>))
          .toList(),
      confidence: (json['confidence'] as num).toDouble(),
      recommendations: (json['recommendations'] as List<dynamic>)
          .map((e) => e as String)
          .toList(),
      urgencyLevel: json['urgencyLevel'] as String,
    );

Map<String, dynamic> _$ImageAnalysisResultToJson(
        ImageAnalysisResult instance) =>
    <String, dynamic>{
      'patientId': instance.patientId,
      'imageType': instance.imageType,
      'findings': instance.findings,
      'confidence': instance.confidence,
      'recommendations': instance.recommendations,
      'urgencyLevel': instance.urgencyLevel,
    };

ImageFinding _$ImageFindingFromJson(Map<String, dynamic> json) => ImageFinding(
      location:
          ImageLocation.fromJson(json['location'] as Map<String, dynamic>),
      condition: json['condition'] as String,
      probability: (json['probability'] as num).toDouble(),
      severity: json['severity'] as String,
      description: json['description'] as String,
    );

Map<String, dynamic> _$ImageFindingToJson(ImageFinding instance) =>
    <String, dynamic>{
      'location': instance.location,
      'condition': instance.condition,
      'probability': instance.probability,
      'severity': instance.severity,
      'description': instance.description,
    };

ImageLocation _$ImageLocationFromJson(Map<String, dynamic> json) =>
    ImageLocation(
      x: (json['x'] as num).toDouble(),
      y: (json['y'] as num).toDouble(),
      width: (json['width'] as num).toDouble(),
      height: (json['height'] as num).toDouble(),
      anatomicalRegion: json['anatomicalRegion'] as String?,
    );

Map<String, dynamic> _$ImageLocationToJson(ImageLocation instance) =>
    <String, dynamic>{
      'x': instance.x,
      'y': instance.y,
      'width': instance.width,
      'height': instance.height,
      'anatomicalRegion': instance.anatomicalRegion,
    };

WearableAnalysisResult _$WearableAnalysisResultFromJson(
        Map<String, dynamic> json) =>
    WearableAnalysisResult(
      patientId: json['patientId'] as String,
      deviceType: json['deviceType'] as String,
      analysis:
          WearableAnalysis.fromJson(json['analysis'] as Map<String, dynamic>),
      insights: (json['insights'] as List<dynamic>)
          .map((e) => HealthInsight.fromJson(e as Map<String, dynamic>))
          .toList(),
      recommendations: (json['recommendations'] as List<dynamic>)
          .map((e) => e as String)
          .toList(),
    );

Map<String, dynamic> _$WearableAnalysisResultToJson(
        WearableAnalysisResult instance) =>
    <String, dynamic>{
      'patientId': instance.patientId,
      'deviceType': instance.deviceType,
      'analysis': instance.analysis,
      'insights': instance.insights,
      'recommendations': instance.recommendations,
    };

WearableAnalysis _$WearableAnalysisFromJson(Map<String, dynamic> json) =>
    WearableAnalysis(
      averageHeartRate: (json['averageHeartRate'] as num).toDouble(),
      heartRateVariability: (json['heartRateVariability'] as num).toDouble(),
      sleepQualityScore: (json['sleepQualityScore'] as num).toDouble(),
      activityScore: (json['activityScore'] as num).toDouble(),
      stressTrend: json['stressTrend'] as String,
    );

Map<String, dynamic> _$WearableAnalysisToJson(WearableAnalysis instance) =>
    <String, dynamic>{
      'averageHeartRate': instance.averageHeartRate,
      'heartRateVariability': instance.heartRateVariability,
      'sleepQualityScore': instance.sleepQualityScore,
      'activityScore': instance.activityScore,
      'stressTrend': instance.stressTrend,
    };

HealthInsight _$HealthInsightFromJson(Map<String, dynamic> json) =>
    HealthInsight(
      type: json['type'] as String,
      message: json['message'] as String,
      confidence: (json['confidence'] as num).toDouble(),
      actionable: json['actionable'] as bool,
      priority: json['priority'] as String,
    );

Map<String, dynamic> _$HealthInsightToJson(HealthInsight instance) =>
    <String, dynamic>{
      'type': instance.type,
      'message': instance.message,
      'confidence': instance.confidence,
      'actionable': instance.actionable,
      'priority': instance.priority,
    };

VoiceAnalysisResult _$VoiceAnalysisResultFromJson(Map<String, dynamic> json) =>
    VoiceAnalysisResult(
      patientId: json['patientId'] as String,
      transcription: json['transcription'] as String,
      sentiment:
          SentimentAnalysis.fromJson(json['sentiment'] as Map<String, dynamic>),
      medicalTerms: (json['medicalTerms'] as List<dynamic>)
          .map((e) => MedicalTerm.fromJson(e as Map<String, dynamic>))
          .toList(),
      urgencyLevel: json['urgencyLevel'] as String,
      recommendations: (json['recommendations'] as List<dynamic>)
          .map((e) => e as String)
          .toList(),
    );

Map<String, dynamic> _$VoiceAnalysisResultToJson(
        VoiceAnalysisResult instance) =>
    <String, dynamic>{
      'patientId': instance.patientId,
      'transcription': instance.transcription,
      'sentiment': instance.sentiment,
      'medicalTerms': instance.medicalTerms,
      'urgencyLevel': instance.urgencyLevel,
      'recommendations': instance.recommendations,
    };

SentimentAnalysis _$SentimentAnalysisFromJson(Map<String, dynamic> json) =>
    SentimentAnalysis(
      overall: json['overall'] as String,
      confidence: (json['confidence'] as num).toDouble(),
      emotions: (json['emotions'] as Map<String, dynamic>).map(
        (k, e) => MapEntry(k, (e as num).toDouble()),
      ),
    );

Map<String, dynamic> _$SentimentAnalysisToJson(SentimentAnalysis instance) =>
    <String, dynamic>{
      'overall': instance.overall,
      'confidence': instance.confidence,
      'emotions': instance.emotions,
    };

MedicalTerm _$MedicalTermFromJson(Map<String, dynamic> json) => MedicalTerm(
      term: json['term'] as String,
      category: json['category'] as String,
      confidence: (json['confidence'] as num).toDouble(),
      context: json['context'] as String,
    );

Map<String, dynamic> _$MedicalTermToJson(MedicalTerm instance) =>
    <String, dynamic>{
      'term': instance.term,
      'category': instance.category,
      'confidence': instance.confidence,
      'context': instance.context,
    };

PopulationHealthAnalysis _$PopulationHealthAnalysisFromJson(
        Map<String, dynamic> json) =>
    PopulationHealthAnalysis(
      region: json['region'] as String,
      condition: json['condition'] as String,
      currentCases: (json['currentCases'] as num).toInt(),
      trend: TrendAnalysis.fromJson(json['trend'] as Map<String, dynamic>),
      recommendations: (json['recommendations'] as List<dynamic>)
          .map((e) => e as String)
          .toList(),
    );

Map<String, dynamic> _$PopulationHealthAnalysisToJson(
        PopulationHealthAnalysis instance) =>
    <String, dynamic>{
      'region': instance.region,
      'condition': instance.condition,
      'currentCases': instance.currentCases,
      'trend': instance.trend,
      'recommendations': instance.recommendations,
    };

TrendAnalysis _$TrendAnalysisFromJson(Map<String, dynamic> json) =>
    TrendAnalysis(
      direction: json['direction'] as String,
      rate: (json['rate'] as num).toDouble(),
      confidence: (json['confidence'] as num).toDouble(),
    );

Map<String, dynamic> _$TrendAnalysisToJson(TrendAnalysis instance) =>
    <String, dynamic>{
      'direction': instance.direction,
      'rate': instance.rate,
      'confidence': instance.confidence,
    };

OutbreakDetection _$OutbreakDetectionFromJson(Map<String, dynamic> json) =>
    OutbreakDetection(
      region: json['region'] as String,
      outbreakProbability: (json['outbreakProbability'] as num).toDouble(),
      recommendedActions: (json['recommendedActions'] as List<dynamic>)
          .map((e) => e as String)
          .toList(),
      alertLevel: json['alertLevel'] as String,
    );

Map<String, dynamic> _$OutbreakDetectionToJson(OutbreakDetection instance) =>
    <String, dynamic>{
      'region': instance.region,
      'outbreakProbability': instance.outbreakProbability,
      'recommendedActions': instance.recommendedActions,
      'alertLevel': instance.alertLevel,
    };

AIModel _$AIModelFromJson(Map<String, dynamic> json) => AIModel(
      id: json['id'] as String,
      name: json['name'] as String,
      version: json['version'] as String,
      type: json['type'] as String,
      description: json['description'] as String?,
      supportedFeatures: (json['supportedFeatures'] as List<dynamic>?)
          ?.map((e) => e as String)
          .toList(),
    );

Map<String, dynamic> _$AIModelToJson(AIModel instance) => <String, dynamic>{
      'id': instance.id,
      'name': instance.name,
      'version': instance.version,
      'type': instance.type,
      'description': instance.description,
      'supportedFeatures': instance.supportedFeatures,
    };

DiagnosisRequest _$DiagnosisRequestFromJson(Map<String, dynamic> json) =>
    DiagnosisRequest(
      patientId: json['patientId'] as String,
      symptoms:
          (json['symptoms'] as List<dynamic>).map((e) => e as String).toList(),
      vitals: (json['vitals'] as Map<String, dynamic>).map(
        (k, e) => MapEntry(k, (e as num).toDouble()),
      ),
      medicalHistory: json['medicalHistory'] as String?,
    );

Map<String, dynamic> _$DiagnosisRequestToJson(DiagnosisRequest instance) =>
    <String, dynamic>{
      'patientId': instance.patientId,
      'symptoms': instance.symptoms,
      'vitals': instance.vitals,
      'medicalHistory': instance.medicalHistory,
    };

SymptomAnalysisRequest _$SymptomAnalysisRequestFromJson(
        Map<String, dynamic> json) =>
    SymptomAnalysisRequest(
      symptoms:
          (json['symptoms'] as List<dynamic>).map((e) => e as String).toList(),
      duration: (json['duration'] as num).toInt(),
      severity: json['severity'] as String,
      patientId: json['patientId'] as String?,
    );

Map<String, dynamic> _$SymptomAnalysisRequestToJson(
        SymptomAnalysisRequest instance) =>
    <String, dynamic>{
      'symptoms': instance.symptoms,
      'duration': instance.duration,
      'severity': instance.severity,
      'patientId': instance.patientId,
    };

TriageRequest _$TriageRequestFromJson(Map<String, dynamic> json) =>
    TriageRequest(
      patientId: json['patientId'] as String,
      symptoms:
          (json['symptoms'] as List<dynamic>).map((e) => e as String).toList(),
      vitals: (json['vitals'] as Map<String, dynamic>).map(
        (k, e) => MapEntry(k, (e as num).toDouble()),
      ),
      chiefComplaint: json['chiefComplaint'] as String?,
    );

Map<String, dynamic> _$TriageRequestToJson(TriageRequest instance) =>
    <String, dynamic>{
      'patientId': instance.patientId,
      'symptoms': instance.symptoms,
      'vitals': instance.vitals,
      'chiefComplaint': instance.chiefComplaint,
    };

ImageAnalysisRequest _$ImageAnalysisRequestFromJson(
        Map<String, dynamic> json) =>
    ImageAnalysisRequest(
      patientId: json['patientId'] as String,
      imageType: json['imageType'] as String,
      imageData: json['imageData'] as String,
      clinicalContext: json['clinicalContext'] as Map<String, dynamic>?,
    );

Map<String, dynamic> _$ImageAnalysisRequestToJson(
        ImageAnalysisRequest instance) =>
    <String, dynamic>{
      'patientId': instance.patientId,
      'imageType': instance.imageType,
      'imageData': instance.imageData,
      'clinicalContext': instance.clinicalContext,
    };

WearableDataRequest _$WearableDataRequestFromJson(Map<String, dynamic> json) =>
    WearableDataRequest(
      patientId: json['patientId'] as String,
      deviceType: json['deviceType'] as String,
      dataPoints: (json['dataPoints'] as List<dynamic>)
          .map((e) => WearableDataPoint.fromJson(e as Map<String, dynamic>))
          .toList(),
    );

Map<String, dynamic> _$WearableDataRequestToJson(
        WearableDataRequest instance) =>
    <String, dynamic>{
      'patientId': instance.patientId,
      'deviceType': instance.deviceType,
      'dataPoints': instance.dataPoints,
    };

WearableDataPoint _$WearableDataPointFromJson(Map<String, dynamic> json) =>
    WearableDataPoint(
      timestamp: (json['timestamp'] as num).toInt(),
      heartRate: (json['heartRate'] as num?)?.toDouble(),
      bloodPressureSystolic:
          (json['bloodPressureSystolic'] as num?)?.toDouble(),
      bloodPressureDiastolic:
          (json['bloodPressureDiastolic'] as num?)?.toDouble(),
      temperature: (json['temperature'] as num?)?.toDouble(),
      oxygenSaturation: (json['oxygenSaturation'] as num?)?.toDouble(),
    );

Map<String, dynamic> _$WearableDataPointToJson(WearableDataPoint instance) =>
    <String, dynamic>{
      'timestamp': instance.timestamp,
      'heartRate': instance.heartRate,
      'bloodPressureSystolic': instance.bloodPressureSystolic,
      'bloodPressureDiastolic': instance.bloodPressureDiastolic,
      'temperature': instance.temperature,
      'oxygenSaturation': instance.oxygenSaturation,
    };

VoiceAnalysisRequest _$VoiceAnalysisRequestFromJson(
        Map<String, dynamic> json) =>
    VoiceAnalysisRequest(
      patientId: json['patientId'] as String,
      audioData: json['audioData'] as String,
      analysisType: json['analysisType'] as String,
      language: json['language'] as String?,
    );

Map<String, dynamic> _$VoiceAnalysisRequestToJson(
        VoiceAnalysisRequest instance) =>
    <String, dynamic>{
      'patientId': instance.patientId,
      'audioData': instance.audioData,
      'analysisType': instance.analysisType,
      'language': instance.language,
    };

PopulationHealthRequest _$PopulationHealthRequestFromJson(
        Map<String, dynamic> json) =>
    PopulationHealthRequest(
      region: json['region'] as String,
      condition: json['condition'] as String,
      timeRangeDays: (json['timeRangeDays'] as num).toInt(),
      includeForecasting: json['includeForecasting'] as bool?,
    );

Map<String, dynamic> _$PopulationHealthRequestToJson(
        PopulationHealthRequest instance) =>
    <String, dynamic>{
      'region': instance.region,
      'condition': instance.condition,
      'timeRangeDays': instance.timeRangeDays,
      'includeForecasting': instance.includeForecasting,
    };

OutbreakDetectionRequest _$OutbreakDetectionRequestFromJson(
        Map<String, dynamic> json) =>
    OutbreakDetectionRequest(
      region: json['region'] as String,
      symptoms:
          (json['symptoms'] as List<dynamic>).map((e) => e as String).toList(),
      caseCount: (json['caseCount'] as num).toInt(),
      demographics: json['demographics'] as Map<String, dynamic>?,
    );

Map<String, dynamic> _$OutbreakDetectionRequestToJson(
        OutbreakDetectionRequest instance) =>
    <String, dynamic>{
      'region': instance.region,
      'symptoms': instance.symptoms,
      'caseCount': instance.caseCount,
      'demographics': instance.demographics,
    };

AIMessage _$AIMessageFromJson(Map<String, dynamic> json) => AIMessage(
      id: json['id'] as String,
      content: json['content'] as String,
      isUser: json['isUser'] as bool,
      timestamp: DateTime.parse(json['timestamp'] as String),
      type: $enumDecode(_$MessageTypeEnumMap, json['type']),
      metadata: json['metadata'] as Map<String, dynamic>?,
    );

Map<String, dynamic> _$AIMessageToJson(AIMessage instance) => <String, dynamic>{
      'id': instance.id,
      'content': instance.content,
      'isUser': instance.isUser,
      'timestamp': instance.timestamp.toIso8601String(),
      'type': _$MessageTypeEnumMap[instance.type]!,
      'metadata': instance.metadata,
    };

const _$MessageTypeEnumMap = {
  MessageType.text: 'TEXT',
  MessageType.diagnosis: 'DIAGNOSIS',
  MessageType.recommendation: 'RECOMMENDATION',
  MessageType.alert: 'ALERT',
  MessageType.summary: 'SUMMARY',
  MessageType.analysis: 'ANALYSIS',
};
