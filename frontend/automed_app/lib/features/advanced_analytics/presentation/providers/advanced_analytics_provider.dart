import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../core/di/injection.dart';
import '../../../../core/services/api_service.dart';
import '../../domain/models/analytics_models.dart';

final advancedAnalyticsProvider = StateNotifierProvider<
    AdvancedAnalyticsNotifier, AsyncValue<AnalyticsDashboardData>>((ref) {
  final apiService = ref.read(apiServiceProvider);
  return AdvancedAnalyticsNotifier(apiService);
});

class AdvancedAnalyticsNotifier
    extends StateNotifier<AsyncValue<AnalyticsDashboardData>> {
  final ApiService _apiService;
  String _currentTimeRange = '24h';

  AdvancedAnalyticsNotifier(this._apiService)
      : super(const AsyncValue.loading()) {
    loadAnalytics();
  }

  Future<void> loadAnalytics() async {
    state = const AsyncValue.loading();
    try {
      // Fetch analytics data from multiple endpoints
      final fetched = await Future.wait<Map<String, dynamic>>([
        _apiService
            .getTyped<Map<String, dynamic>>(
                '/analytics/overview?timeRange=$_currentTimeRange',
                (json) => json as Map<String, dynamic>)
            .then((r) => r.data ?? <String, dynamic>{}),
        _apiService
            .getTyped<Map<String, dynamic>>('/analytics/real-time-metrics',
                (json) => json as Map<String, dynamic>)
            .then((r) => r.data ?? <String, dynamic>{}),
        _apiService
            .getTyped<Map<String, dynamic>>('/analytics/predictive-insights',
                (json) => json as Map<String, dynamic>)
            .then((r) => r.data ?? <String, dynamic>{}),
        _apiService
            .getTyped<Map<String, dynamic>>('/analytics/performance-kpis',
                (json) => json as Map<String, dynamic>)
            .then((r) => r.data ?? <String, dynamic>{}),
        _apiService
            .getTyped<Map<String, dynamic>>('/analytics/population-health',
                (json) => json as Map<String, dynamic>)
            .then((r) => r.data ?? <String, dynamic>{}),
        _apiService
            .getTyped<Map<String, dynamic>>('/analytics/system-status',
                (json) => json as Map<String, dynamic>)
            .then((r) => r.data ?? <String, dynamic>{}),
      ]);

      int parseInt(dynamic value) {
        if (value == null) return 0;
        if (value is int) return value;
        if (value is double) return value.toInt();
        if (value is String) {
          final intVal = int.tryParse(value);
          if (intVal != null) return intVal;
          final doubleVal = double.tryParse(value);
          if (doubleVal != null) return doubleVal.toInt();
        }
        return 0;
      }

      double parseDouble(dynamic value) {
        if (value == null) return 0.0;
        if (value is double) return value;
        if (value is int) return value.toDouble();
        if (value is String) {
          final doubleVal = double.tryParse(value);
          if (doubleVal != null) return doubleVal;
          final intVal = int.tryParse(value);
          if (intVal != null) return intVal.toDouble();
        }
        return 0.0;
      }

      print('[DEBUG][AdvancedAnalyticsNotifier] Types of fetched values:');
      try {
        final overview = fetched.isNotEmpty ? fetched[0] : <String, dynamic>{};
        void dbg(String key) {
          final val = overview[key];
          print(
              '[DEBUG][AdvancedAnalyticsNotifier] $key -> type=${val?.runtimeType} value=${val?.toString()}');
        }

        dbg('activePatients');
        dbg('patientGrowth');
        dbg('criticalAlerts');
        dbg('alertTrend');
        dbg('bedOccupancy');
        dbg('occupancyTrend');
        dbg('avgResponseTime');
        dbg('responseTrend');
      } catch (e) {
        print(
            '[DEBUG][AdvancedAnalyticsNotifier] Failed to print debug values: $e');
      }

      // Safely extract overview and system services
      final overviewMap = fetched.isNotEmpty ? fetched[0] : <String, dynamic>{};

      List<SystemService> systemServices = [];
      if (fetched.length > 5) {
        final sys = fetched[5];
        final servicesRaw = sys['services'];
        if (servicesRaw is List) {
          systemServices = servicesRaw
              .whereType<Map<String, dynamic>>()
              .map((s) => SystemService.fromJson(s))
              .toList();
        }
      }

      final dashboardData = AnalyticsDashboardData(
        activePatients: parseInt(overviewMap['activePatients']),
        patientGrowth: parseDouble(overviewMap['patientGrowth']),
        criticalAlerts: parseInt(overviewMap['criticalAlerts']),
        alertTrend: parseDouble(overviewMap['alertTrend']),
        bedOccupancy: parseDouble(overviewMap['bedOccupancy']),
        occupancyTrend: parseDouble(overviewMap['occupancyTrend']),
        avgResponseTime: parseDouble(overviewMap['avgResponseTime']),
        responseTrend: parseDouble(overviewMap['responseTrend']),
        realTimeMetrics: fetched.length > 1
            ? RealTimeMetrics.fromJson(fetched[1])
            : RealTimeMetrics(
                vitalSigns: [],
                patientFlow: [],
                resourceUtilization: [],
                activeAlerts: [],
                systemLoad: 0.0,
                connectedDevices: 0,
              ),
        predictiveInsights: fetched.length > 2
            ? PredictiveInsights.fromJson(fetched[2])
            : PredictiveInsights(
                healthOutcomes: [],
                riskAssessments: [],
                trends: [],
                recommendations: [],
                accuracyScore: 0.0,
                lastModelUpdate: DateTime.now(),
              ),
        performanceKpis: fetched.length > 3
            ? PerformanceKpis.fromJson(fetched[3])
            : PerformanceKpis(
                patientSatisfaction: 0.0,
                staffEfficiency: 0.0,
                costPerPatient: 0.0,
                readmissionRate: 0.0,
                mortalityRate: 0.0,
                infectionRate: 0.0,
                trends: [],
                benchmarks: [],
              ),
        populationHealth: fetched.length > 4
            ? PopulationHealth.fromJson(fetched[4])
            : PopulationHealth(
                demographics: [],
                diseasePrevalence: [],
                outbreakAlerts: [],
                healthTrends: [],
                communityHealthScore: 0.0,
                preventiveCare: [],
              ),
        systemServices: systemServices,
        lastUpdated: DateTime.now(),
      );

      state = AsyncValue.data(dashboardData);
    } catch (error, stackTrace) {
      // Semantic bug logging for diagnostics
      print('[ERROR][AdvancedAnalyticsNotifier] $error\n$stackTrace');
      state = AsyncValue.error(
        'Failed to load analytics: $error',
        stackTrace,
      );
    }
  }

  Future<void> updateTimeRange(String timeRange) async {
    _currentTimeRange = timeRange;
    await loadAnalytics();
  }

  Future<void> refreshMetrics() async {
    await loadAnalytics();
  }

  Future<void> exportAnalytics(String format) async {
    try {
      await _apiService
          .get('/analytics/export?format=$format&timeRange=$_currentTimeRange');
      // TODO: handle export response (e.g., download file, show confirmation)
    } catch (error) {
      // Handle export error
    }
  }
}
