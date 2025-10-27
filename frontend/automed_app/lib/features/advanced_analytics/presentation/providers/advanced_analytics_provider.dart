import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../core/services/api_service.dart';
import '../../domain/models/analytics_models.dart';

final advancedAnalyticsProvider = StateNotifierProvider<AdvancedAnalyticsNotifier, AsyncValue<AnalyticsDashboardData>>((ref) {
  return AdvancedAnalyticsNotifier(ref.read(apiServiceProvider));
});

class AdvancedAnalyticsNotifier extends StateNotifier<AsyncValue<AnalyticsDashboardData>> {
  final ApiService _apiService;
  String _currentTimeRange = '24h';

  AdvancedAnalyticsNotifier(this._apiService) : super(const AsyncValue.loading()) {
    loadAnalytics();
  }

  Future<void> loadAnalytics() async {
    try {
      state = const AsyncValue.loading();
      
      // Fetch analytics data from multiple endpoints
      final futures = await Future.wait([
        _apiService.get('/analytics/overview?timeRange=$_currentTimeRange'),
        _apiService.get('/analytics/real-time-metrics'),
        _apiService.get('/analytics/predictive-insights'),
        _apiService.get('/analytics/performance-kpis'),
        _apiService.get('/analytics/population-health'),
        _apiService.get('/analytics/system-status'),
      ]);

      final dashboardData = AnalyticsDashboardData(
        activePatients: futures[0]['activePatients'] ?? 0,
        patientGrowth: futures[0]['patientGrowth'] ?? 0.0,
        criticalAlerts: futures[0]['criticalAlerts'] ?? 0,
        alertTrend: futures[0]['alertTrend'] ?? 0.0,
        bedOccupancy: futures[0]['bedOccupancy'] ?? 0.0,
        occupancyTrend: futures[0]['occupancyTrend'] ?? 0.0,
        avgResponseTime: futures[0]['avgResponseTime'] ?? 0.0,
        responseTrend: futures[0]['responseTrend'] ?? 0.0,
        realTimeMetrics: RealTimeMetrics.fromJson(futures[1]),
        predictiveInsights: PredictiveInsights.fromJson(futures[2]),
        performanceKpis: PerformanceKpis.fromJson(futures[3]),
        populationHealth: PopulationHealth.fromJson(futures[4]),
        systemServices: (futures[5]['services'] as List)
            .map((service) => SystemService.fromJson(service))
            .toList(),
        lastUpdated: DateTime.now(),
      );

      state = AsyncValue.data(dashboardData);
    } catch (error, stackTrace) {
      state = AsyncValue.error(error, stackTrace);
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
      final response = await _apiService.get('/analytics/export?format=$format&timeRange=$_currentTimeRange');
      // Handle export response
    } catch (error) {
      // Handle export error
    }
  }
}