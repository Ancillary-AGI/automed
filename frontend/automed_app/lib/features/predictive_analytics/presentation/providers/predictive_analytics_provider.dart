import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:automed_app/core/di/injection.dart';
import 'package:automed_app/core/services/api_service.dart';

// Predictive Analytics State
class PredictiveAnalyticsState {
  final PredictiveAnalyticsData? data;
  final bool isLoading;
  final String? error;

  const PredictiveAnalyticsState({
    this.data,
    this.isLoading = false,
    this.error,
  });

  PredictiveAnalyticsState copyWith({
    PredictiveAnalyticsData? data,
    bool? isLoading,
    String? error,
  }) {
    return PredictiveAnalyticsState(
      data: data ?? this.data,
      isLoading: isLoading ?? this.isLoading,
      error: error ?? this.error,
    );
  }
}

// Predictive Analytics Notifier
class PredictiveAnalyticsNotifier
    extends StateNotifier<AsyncValue<PredictiveAnalyticsData>> {
  final ApiService _apiService;
  String _currentTimeRange = '7d';
  String _currentPatientFilter = 'all';

  PredictiveAnalyticsNotifier(this._apiService)
      : super(const AsyncValue.loading());

  // Load predictive data
  Future<void> loadPredictiveData() async {
    state = const AsyncValue.loading();

    try {
      final data = await _fetchPredictiveData();
      state = AsyncValue.data(data);
    } catch (e, stackTrace) {
      state = AsyncValue.error(e, stackTrace);
    }
  }

  // Update time range
  Future<void> updateTimeRange(String timeRange) async {
    _currentTimeRange = timeRange;
    await loadPredictiveData();
  }

  // Update patient filter
  Future<void> updatePatientFilter(String filter) async {
    _currentPatientFilter = filter;
    await loadPredictiveData();
  }

  // Refresh data
  Future<void> refreshData() async {
    await loadPredictiveData();
  }

  // Dismiss alert
  Future<void> dismissAlert(String alertId) async {
    try {
      // Call API to dismiss alert
      // await _apiService.dismissAlert(alertId);

      // Update local state
      state.whenData((data) {
        final updatedAlerts =
            data.activeAlerts.where((alert) => alert.id != alertId).toList();
        final updatedData = data.copyWith(activeAlerts: updatedAlerts);
        state = AsyncValue.data(updatedData);
      });
    } catch (e) {
      // Handle error
    }
  }

  // Fetch predictive data from API
  Future<PredictiveAnalyticsData> _fetchPredictiveData() async {
    // Attempt to fetch predictive analytics from backend API.
    // Assumption: backend exposes an endpoint at `/analytics/predictive` that
    // accepts `range` and `filter` query params and returns a JSON object
    // matching the fields used by PredictiveAnalyticsData. If the call fails
    // or the response is missing fields, fall back to local generators.
    try {
      final endpoint =
          '/analytics/predictive?range=${Uri.encodeComponent(_currentTimeRange)}&filter=${Uri.encodeComponent(_currentPatientFilter)}';
      final apiResp = await _apiService.getTyped<Map<String, dynamic>>(
        endpoint,
        (json) => json as Map<String, dynamic>,
      );

      if (!apiResp.success || apiResp.data == null || apiResp.data!.isEmpty) {
        throw Exception('Empty or error response');
      }

      // Parse response into model
      return _parsePredictiveAnalytics(apiResp.data!);
    } catch (e) {
      // Surface errors to the caller so the UI/state can present an error state.
      // Do not return mock data.
      // ignore: avoid_print
      print('Failed to fetch predictive analytics from API: $e');
      throw Exception('Failed to fetch predictive analytics: $e');
    }
  }

  // Parse backend response into PredictiveAnalyticsData
  PredictiveAnalyticsData _parsePredictiveAnalytics(Map<String, dynamic> json) {
    try {
      // Validate required top-level sections
      final keyMetricsJson = json['keyMetrics'] as Map<String, dynamic>?;
      final populationJson = json['populationHealth'] as Map<String, dynamic>?;
      final riskDistJson = json['riskDistribution'] as Map<String, dynamic>?;
      final alertSummaryJson = json['alertSummary'] as Map<String, dynamic>?;

      if (keyMetricsJson == null) {
        throw Exception('Missing keyMetrics in predictive analytics payload');
      }
      if (populationJson == null) {
        throw Exception(
            'Missing populationHealth in predictive analytics payload');
      }
      if (riskDistJson == null) {
        throw Exception(
            'Missing riskDistribution in predictive analytics payload');
      }
      if (alertSummaryJson == null) {
        throw Exception('Missing alertSummary in predictive analytics payload');
      }

      // Parse required key metrics
      final keyMetrics = KeyMetrics(
        highRiskPatients: (keyMetricsJson['highRiskPatients'] ?? 0) as int,
        predictedAdmissions:
            (keyMetricsJson['predictedAdmissions'] ?? 0) as int,
        earlyWarnings: (keyMetricsJson['earlyWarnings'] ?? 0) as int,
        accuracyScore: (keyMetricsJson['accuracyScore'] ?? 0.0) as double,
        highRiskChange: (keyMetricsJson['highRiskChange'] ?? 0.0) as double,
        admissionChange: (keyMetricsJson['admissionChange'] ?? 0.0) as double,
        warningChange: (keyMetricsJson['warningChange'] ?? 0.0) as double,
        accuracyChange: (keyMetricsJson['accuracyChange'] ?? 0.0) as double,
      );

      // Parse population health
      final populationHealth = PopulationHealthData(
        totalPopulation: (populationJson['totalPopulation'] ?? 0) as int,
        atRiskCount: (populationJson['atRiskCount'] ?? 0) as int,
        trends: (populationJson['trends'] as List<dynamic>?)
                ?.map((t) => PopulationTrend(
                      date: DateTime.tryParse(t['date']?.toString() ?? '') ??
                          DateTime.now(),
                      totalPatients: (t['totalPatients'] ?? 0) as int,
                      atRiskPatients: (t['atRiskPatients'] ?? 0) as int,
                      criticalPatients: (t['criticalPatients'] ?? 0) as int,
                    ))
                .toList() ??
            [],
      );

      // Parse lists (optional; if missing, default to empty lists)
      final recentPredictions = (json['recentPredictions'] as List<dynamic>?)
              ?.map((p) => PredictionResult(
                    id: p['id'].toString(),
                    patientId: p['patientId'].toString(),
                    patientName: p['patientName'].toString(),
                    predictionType: p['predictionType'].toString(),
                    probability: (p['probability'] ?? 0.0) as double,
                    confidence: (p['confidence'] ?? 0.0) as double,
                    timestamp:
                        DateTime.tryParse(p['timestamp']?.toString() ?? '') ??
                            DateTime.now(),
                    factors: (p['factors'] as List<dynamic>?)
                            ?.map((f) => f.toString())
                            .toList() ??
                        [],
                  ))
              .toList() ??
          [];

      final highRiskPatients = (json['highRiskPatients'] as List<dynamic>?)
              ?.map((h) => HighRiskPatient(
                    id: h['id'].toString(),
                    name: h['name'].toString(),
                    age: (h['age'] ?? 0) as int,
                    riskScore: (h['riskScore'] ?? 0.0) as double,
                    primaryRisk: h['primaryRisk']?.toString() ?? '',
                    lastAssessment: DateTime.tryParse(
                            h['lastAssessment']?.toString() ?? '') ??
                        DateTime.now(),
                    interventions: (h['interventions'] as List<dynamic>?)
                            ?.map((i) => i.toString())
                            .toList() ??
                        [],
                  ))
              .toList() ??
          [];

      final riskFactors = (json['riskFactors'] as List<dynamic>?)
              ?.map((r) => RiskFactor(
                  name: r['name'].toString(),
                  prevalence: (r['prevalence'] ?? 0.0) as double))
              .toList() ??
          [];

      final accuracyTrends = (json['accuracyTrends'] as List<dynamic>?)
              ?.map((t) => AccuracyTrend(
                  date: DateTime.tryParse(t['date']?.toString() ?? '') ??
                      DateTime.now(),
                  accuracy: (t['accuracy'] ?? 0.0) as double))
              .toList() ??
          [];

      final healthOutcomeTrends =
          (json['healthOutcomeTrends'] as List<dynamic>?)
                  ?.map((t) => HealthOutcomeTrend(
                      period: t['period'].toString(),
                      value: (t['value'] ?? 0.0) as double))
                  .toList() ??
              [];

      final seasonalPatterns = (json['seasonalPatterns'] as List<dynamic>?)
              ?.map((s) => SeasonalPattern(
                  condition: s['condition'].toString(),
                  season: s['season'].toString(),
                  increase: (s['increase'] ?? 0.0) as double,
                  description: s['description']?.toString() ?? ''))
              .toList() ??
          [];

      final riskDistribution = RiskDistribution(
        lowRisk: (riskDistJson['lowRisk'] ?? 0) as int,
        moderateRisk: (riskDistJson['moderateRisk'] ?? 0) as int,
        highRisk: (riskDistJson['highRisk'] ?? 0) as int,
      );

      final alertSummary = AlertSummary(
        critical: (alertSummaryJson['critical'] ?? 0) as int,
        high: (alertSummaryJson['high'] ?? 0) as int,
        medium: (alertSummaryJson['medium'] ?? 0) as int,
        low: (alertSummaryJson['low'] ?? 0) as int,
      );

      final activeAlerts = (json['activeAlerts'] as List<dynamic>?)
              ?.map((a) => PredictiveAlert(
                    id: a['id'].toString(),
                    patientId: a['patientId'].toString(),
                    patientName: a['patientName'].toString(),
                    alertType: a['alertType'].toString(),
                    severity: _parseAlertSeverity(a['severity']),
                    message: a['message']?.toString() ?? '',
                    timestamp:
                        DateTime.tryParse(a['timestamp']?.toString() ?? '') ??
                            DateTime.now(),
                    actions: (a['actions'] as List<dynamic>?)
                            ?.map((ac) => ac.toString())
                            .toList() ??
                        [],
                  ))
              .toList() ??
          [];

      final alertHistory = (json['alertHistory'] as List<dynamic>?)
              ?.map((a) => PredictiveAlert(
                    id: a['id'].toString(),
                    patientId: a['patientId'].toString(),
                    patientName: a['patientName'].toString(),
                    alertType: a['alertType'].toString(),
                    severity: _parseAlertSeverity(a['severity']),
                    message: a['message']?.toString() ?? '',
                    timestamp:
                        DateTime.tryParse(a['timestamp']?.toString() ?? '') ??
                            DateTime.now(),
                    actions: (a['actions'] as List<dynamic>?)
                            ?.map((ac) => ac.toString())
                            .toList() ??
                        [],
                  ))
              .toList() ??
          [];

      return PredictiveAnalyticsData(
        keyMetrics: keyMetrics,
        earlyWarnings: (json['earlyWarnings'] as List<dynamic>?)
                ?.map((e) => EarlyWarning(
                      id: e['id'].toString(),
                      patientId: e['patientId'].toString(),
                      patientName: e['patientName'].toString(),
                      warningType: e['warningType'].toString(),
                      severity: _parseWarningSeverity(e['severity']),
                      score: (e['score'] ?? 0.0) as double,
                      timestamp:
                          DateTime.tryParse(e['timestamp']?.toString() ?? '') ??
                              DateTime.now(),
                      recommendations: (e['recommendations'] as List<dynamic>?)
                              ?.map((r) => r.toString())
                              .toList() ??
                          [],
                    ))
                .toList() ??
            [],
        populationHealth: populationHealth,
        recentPredictions: recentPredictions,
        riskDistribution: riskDistribution,
        highRiskPatients: highRiskPatients,
        riskFactors: riskFactors,
        accuracyTrends: accuracyTrends,
        healthOutcomeTrends: healthOutcomeTrends,
        seasonalPatterns: seasonalPatterns,
        alertSummary: alertSummary,
        activeAlerts: activeAlerts,
        alertHistory: alertHistory,
      );
    } catch (e) {
      // Parsing errors should be surfaced to the caller so the UI can show an error.
      // Do not synthesize or generate mock data.
      // ignore: avoid_print
      print('Failed to parse predictive analytics payload: $e');
      throw Exception('Failed to parse predictive analytics payload: $e');
    }
  }

  WarningSeverity _parseWarningSeverity(dynamic input) {
    final s = (input?.toString() ?? '').toLowerCase();
    switch (s) {
      case 'low':
        return WarningSeverity.low;
      case 'medium':
        return WarningSeverity.medium;
      case 'high':
        return WarningSeverity.high;
      case 'critical':
        return WarningSeverity.critical;
      default:
        return WarningSeverity.low;
    }
  }

  AlertSeverity _parseAlertSeverity(dynamic input) {
    final s = (input?.toString() ?? '').toLowerCase();
    switch (s) {
      case 'low':
        return AlertSeverity.low;
      case 'medium':
        return AlertSeverity.medium;
      case 'high':
        return AlertSeverity.high;
      case 'critical':
        return AlertSeverity.critical;
      default:
        return AlertSeverity.low;
    }
  }
}

// Data models
class PredictiveAnalyticsData {
  final KeyMetrics keyMetrics;
  final List<EarlyWarning> earlyWarnings;
  final PopulationHealthData populationHealth;
  final List<PredictionResult> recentPredictions;
  final RiskDistribution riskDistribution;
  final List<HighRiskPatient> highRiskPatients;
  final List<RiskFactor> riskFactors;
  final List<AccuracyTrend> accuracyTrends;
  final List<HealthOutcomeTrend> healthOutcomeTrends;
  final List<SeasonalPattern> seasonalPatterns;
  final AlertSummary alertSummary;
  final List<PredictiveAlert> activeAlerts;
  final List<PredictiveAlert> alertHistory;

  PredictiveAnalyticsData({
    required this.keyMetrics,
    required this.earlyWarnings,
    required this.populationHealth,
    required this.recentPredictions,
    required this.riskDistribution,
    required this.highRiskPatients,
    required this.riskFactors,
    required this.accuracyTrends,
    required this.healthOutcomeTrends,
    required this.seasonalPatterns,
    required this.alertSummary,
    required this.activeAlerts,
    required this.alertHistory,
  });

  PredictiveAnalyticsData copyWith({
    List<PredictiveAlert>? activeAlerts,
  }) {
    return PredictiveAnalyticsData(
      keyMetrics: keyMetrics,
      earlyWarnings: earlyWarnings,
      populationHealth: populationHealth,
      recentPredictions: recentPredictions,
      riskDistribution: riskDistribution,
      highRiskPatients: highRiskPatients,
      riskFactors: riskFactors,
      accuracyTrends: accuracyTrends,
      healthOutcomeTrends: healthOutcomeTrends,
      seasonalPatterns: seasonalPatterns,
      alertSummary: alertSummary,
      activeAlerts: activeAlerts ?? this.activeAlerts,
      alertHistory: alertHistory,
    );
  }
}

// Supporting data classes
class KeyMetrics {
  final int highRiskPatients;
  final int predictedAdmissions;
  final int earlyWarnings;
  final double accuracyScore;
  final double highRiskChange;
  final double admissionChange;
  final double warningChange;
  final double accuracyChange;

  KeyMetrics({
    required this.highRiskPatients,
    required this.predictedAdmissions,
    required this.earlyWarnings,
    required this.accuracyScore,
    required this.highRiskChange,
    required this.admissionChange,
    required this.warningChange,
    required this.accuracyChange,
  });
}

class EarlyWarning {
  final String id;
  final String patientId;
  final String patientName;
  final String warningType;
  final WarningSeverity severity;
  final double score;
  final DateTime timestamp;
  final List<String> recommendations;

  EarlyWarning({
    required this.id,
    required this.patientId,
    required this.patientName,
    required this.warningType,
    required this.severity,
    required this.score,
    required this.timestamp,
    required this.recommendations,
  });
}

enum WarningSeverity { low, medium, high, critical }

class PopulationHealthData {
  final int totalPopulation;
  final int atRiskCount;
  final List<PopulationTrend> trends;

  PopulationHealthData({
    required this.totalPopulation,
    required this.atRiskCount,
    required this.trends,
  });
}

class PopulationTrend {
  final DateTime date;
  final int totalPatients;
  final int atRiskPatients;
  final int criticalPatients;

  PopulationTrend({
    required this.date,
    required this.totalPatients,
    required this.atRiskPatients,
    required this.criticalPatients,
  });
}

class PredictionResult {
  final String id;
  final String patientId;
  final String patientName;
  final String predictionType;
  final double probability;
  final double confidence;
  final DateTime timestamp;
  final List<String> factors;

  PredictionResult({
    required this.id,
    required this.patientId,
    required this.patientName,
    required this.predictionType,
    required this.probability,
    required this.confidence,
    required this.timestamp,
    required this.factors,
  });
}

class RiskDistribution {
  final int lowRisk;
  final int moderateRisk;
  final int highRisk;

  RiskDistribution({
    required this.lowRisk,
    required this.moderateRisk,
    required this.highRisk,
  });
}

class HighRiskPatient {
  final String id;
  final String name;
  final int age;
  final double riskScore;
  final String primaryRisk;
  final DateTime lastAssessment;
  final List<String> interventions;

  HighRiskPatient({
    required this.id,
    required this.name,
    required this.age,
    required this.riskScore,
    required this.primaryRisk,
    required this.lastAssessment,
    required this.interventions,
  });
}

class RiskFactor {
  final String name;
  final double prevalence;

  RiskFactor({
    required this.name,
    required this.prevalence,
  });
}

class AccuracyTrend {
  final DateTime date;
  final double accuracy;

  AccuracyTrend({
    required this.date,
    required this.accuracy,
  });
}

class HealthOutcomeTrend {
  final String period;
  final double value;

  HealthOutcomeTrend({
    required this.period,
    required this.value,
  });
}

class SeasonalPattern {
  final String condition;
  final String season;
  final double increase;
  final String description;

  SeasonalPattern({
    required this.condition,
    required this.season,
    required this.increase,
    required this.description,
  });
}

class AlertSummary {
  final int critical;
  final int high;
  final int medium;
  final int low;

  AlertSummary({
    required this.critical,
    required this.high,
    required this.medium,
    required this.low,
  });
}

class PredictiveAlert {
  final String id;
  final String patientId;
  final String patientName;
  final String alertType;
  final AlertSeverity severity;
  final String message;
  final DateTime timestamp;
  final List<String> actions;

  PredictiveAlert({
    required this.id,
    required this.patientId,
    required this.patientName,
    required this.alertType,
    required this.severity,
    required this.message,
    required this.timestamp,
    required this.actions,
  });
}

enum AlertSeverity { low, medium, high, critical }

// Provider
final predictiveAnalyticsProvider = StateNotifierProvider<
    PredictiveAnalyticsNotifier, AsyncValue<PredictiveAnalyticsData>>((ref) {
  final apiService = ref.watch(apiServiceProvider);
  return PredictiveAnalyticsNotifier(apiService);
});
