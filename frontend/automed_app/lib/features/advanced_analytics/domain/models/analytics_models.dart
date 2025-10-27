import 'package:freezed_annotation/freezed_annotation.dart';

part 'analytics_models.freezed.dart';
part 'analytics_models.g.dart';

@freezed
class AnalyticsDashboardData with _$AnalyticsDashboardData {
  const factory AnalyticsDashboardData({
    required int activePatients,
    required double patientGrowth,
    required int criticalAlerts,
    required double alertTrend,
    required double bedOccupancy,
    required double occupancyTrend,
    required double avgResponseTime,
    required double responseTrend,
    required RealTimeMetrics realTimeMetrics,
    required PredictiveInsights predictiveInsights,
    required PerformanceKpis performanceKpis,
    required PopulationHealth populationHealth,
    required List<SystemService> systemServices,
    required DateTime lastUpdated,
  }) = _AnalyticsDashboardData;

  factory AnalyticsDashboardData.fromJson(Map<String, dynamic> json) =>
      _$AnalyticsDashboardDataFromJson(json);
}

@freezed
class RealTimeMetrics with _$RealTimeMetrics {
  const factory RealTimeMetrics({
    required List<MetricDataPoint> vitalSigns,
    required List<MetricDataPoint> patientFlow,
    required List<MetricDataPoint> resourceUtilization,
    required List<AlertMetric> activeAlerts,
    required double systemLoad,
    required int connectedDevices,
  }) = _RealTimeMetrics;

  factory RealTimeMetrics.fromJson(Map<String, dynamic> json) =>
      _$RealTimeMetricsFromJson(json);
}

@freezed
class PredictiveInsights with _$PredictiveInsights {
  const factory PredictiveInsights({
    required List<PredictionModel> healthOutcomes,
    required List<RiskAssessment> riskAssessments,
    required List<TrendAnalysis> trends,
    required List<Recommendation> recommendations,
    required double accuracyScore,
    required DateTime lastModelUpdate,
  }) = _PredictiveInsights;

  factory PredictiveInsights.fromJson(Map<String, dynamic> json) =>
      _$PredictiveInsightsFromJson(json);
}

@freezed
class PerformanceKpis with _$PerformanceKpis {
  const factory PerformanceKpis({
    required double patientSatisfaction,
    required double staffEfficiency,
    required double costPerPatient,
    required double readmissionRate,
    required double mortalityRate,
    required double infectionRate,
    required List<KpiTrend> trends,
    required List<Benchmark> benchmarks,
  }) = _PerformanceKpis;

  factory PerformanceKpis.fromJson(Map<String, dynamic> json) =>
      _$PerformanceKpisFromJson(json);
}

@freezed
class PopulationHealth with _$PopulationHealth {
  const factory PopulationHealth({
    required List<DemographicData> demographics,
    required List<DiseasePrevalence> diseasePrevalence,
    required List<OutbreakAlert> outbreakAlerts,
    required List<HealthTrend> healthTrends,
    required double communityHealthScore,
    required List<PreventiveCareMetric> preventiveCare,
  }) = _PopulationHealth;

  factory PopulationHealth.fromJson(Map<String, dynamic> json) =>
      _$PopulationHealthFromJson(json);
}

@freezed
class MetricDataPoint with _$MetricDataPoint {
  const factory MetricDataPoint({
    required DateTime timestamp,
    required double value,
    required String metric,
    String? unit,
    String? category,
  }) = _MetricDataPoint;

  factory MetricDataPoint.fromJson(Map<String, dynamic> json) =>
      _$MetricDataPointFromJson(json);
}

@freezed
class AlertMetric with _$AlertMetric {
  const factory AlertMetric({
    required String id,
    required String type,
    required String severity,
    required String message,
    required DateTime timestamp,
    required String patientId,
    String? department,
    bool? acknowledged,
  }) = _AlertMetric;

  factory AlertMetric.fromJson(Map<String, dynamic> json) =>
      _$AlertMetricFromJson(json);
}

@freezed
class PredictionModel with _$PredictionModel {
  const factory PredictionModel({
    required String modelType,
    required String prediction,
    required double confidence,
    required DateTime predictionDate,
    required String patientId,
    required List<String> riskFactors,
    String? recommendedAction,
  }) = _PredictionModel;

  factory PredictionModel.fromJson(Map<String, dynamic> json) =>
      _$PredictionModelFromJson(json);
}

@freezed
class RiskAssessment with _$RiskAssessment {
  const factory RiskAssessment({
    required String patientId,
    required String riskType,
    required String riskLevel,
    required double riskScore,
    required List<String> riskFactors,
    required DateTime assessmentDate,
    String? mitigation,
  }) = _RiskAssessment;

  factory RiskAssessment.fromJson(Map<String, dynamic> json) =>
      _$RiskAssessmentFromJson(json);
}

@freezed
class TrendAnalysis with _$TrendAnalysis {
  const factory TrendAnalysis({
    required String metric,
    required String trendDirection,
    required double changePercentage,
    required List<MetricDataPoint> dataPoints,
    required String timeframe,
    String? significance,
  }) = _TrendAnalysis;

  factory TrendAnalysis.fromJson(Map<String, dynamic> json) =>
      _$TrendAnalysisFromJson(json);
}

@freezed
class Recommendation with _$Recommendation {
  const factory Recommendation({
    required String id,
    required String type,
    required String title,
    required String description,
    required String priority,
    required DateTime createdAt,
    String? category,
    String? targetAudience,
    bool? implemented,
  }) = _Recommendation;

  factory Recommendation.fromJson(Map<String, dynamic> json) =>
      _$RecommendationFromJson(json);
}

@freezed
class KpiTrend with _$KpiTrend {
  const factory KpiTrend({
    required String kpiName,
    required double currentValue,
    required double previousValue,
    required double changePercentage,
    required String trendDirection,
    required String timeframe,
  }) = _KpiTrend;

  factory KpiTrend.fromJson(Map<String, dynamic> json) =>
      _$KpiTrendFromJson(json);
}

@freezed
class Benchmark with _$Benchmark {
  const factory Benchmark({
    required String metric,
    required double ourValue,
    required double industryAverage,
    required double bestPractice,
    required String comparison,
    String? unit,
  }) = _Benchmark;

  factory Benchmark.fromJson(Map<String, dynamic> json) =>
      _$BenchmarkFromJson(json);
}

@freezed
class DemographicData with _$DemographicData {
  const factory DemographicData({
    required String category,
    required String subcategory,
    required int count,
    required double percentage,
    String? ageGroup,
    String? gender,
  }) = _DemographicData;

  factory DemographicData.fromJson(Map<String, dynamic> json) =>
      _$DemographicDataFromJson(json);
}

@freezed
class DiseasePrevalence with _$DiseasePrevalence {
  const factory DiseasePrevalence({
    required String disease,
    required int cases,
    required double prevalenceRate,
    required String timeframe,
    required double changeFromPrevious,
    String? severity,
  }) = _DiseasePrevalence;

  factory DiseasePrevalence.fromJson(Map<String, dynamic> json) =>
      _$DiseasePrevalenceFromJson(json);
}

@freezed
class OutbreakAlert with _$OutbreakAlert {
  const factory OutbreakAlert({
    required String id,
    required String disease,
    required String location,
    required int affectedCount,
    required String severity,
    required DateTime detectedAt,
    required String status,
    String? description,
  }) = _OutbreakAlert;

  factory OutbreakAlert.fromJson(Map<String, dynamic> json) =>
      _$OutbreakAlertFromJson(json);
}

@freezed
class HealthTrend with _$HealthTrend {
  const factory HealthTrend({
    required String indicator,
    required String trendDirection,
    required double changeRate,
    required String timeframe,
    required List<MetricDataPoint> dataPoints,
    String? significance,
  }) = _HealthTrend;

  factory HealthTrend.fromJson(Map<String, dynamic> json) =>
      _$HealthTrendFromJson(json);
}

@freezed
class PreventiveCareMetric with _$PreventiveCareMetric {
  const factory PreventiveCareMetric({
    required String careType,
    required int eligiblePopulation,
    required int completedScreenings,
    required double completionRate,
    required double targetRate,
    String? timeframe,
  }) = _PreventiveCareMetric;

  factory PreventiveCareMetric.fromJson(Map<String, dynamic> json) =>
      _$PreventiveCareMetricFromJson(json);
}

@freezed
class SystemService with _$SystemService {
  const factory SystemService({
    required String name,
    required String status,
    required int responseTime,
    required double uptime,
    required DateTime lastCheck,
    String? version,
    String? endpoint,
  }) = _SystemService;

  factory SystemService.fromJson(Map<String, dynamic> json) =>
      _$SystemServiceFromJson(json);
}