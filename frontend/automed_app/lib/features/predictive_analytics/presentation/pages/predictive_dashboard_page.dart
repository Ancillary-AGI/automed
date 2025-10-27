import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:syncfusion_flutter_charts/charts.dart';

import '../../../../core/theme/app_colors.dart';
import '../providers/predictive_analytics_provider.dart';
import '../widgets/health_risk_card.dart';
import '../widgets/prediction_chart.dart';
import '../widgets/early_warning_panel.dart';

class PredictiveDashboardPage extends ConsumerStatefulWidget {
  const PredictiveDashboardPage({super.key});

  @override
  ConsumerState<PredictiveDashboardPage> createState() => _PredictiveDashboardPageState();
}

class _PredictiveDashboardPageState extends ConsumerState<PredictiveDashboardPage>
    with TickerProviderStateMixin {
  late TabController _tabController;
  String _selectedTimeRange = '7d';
  String _selectedPatientId = 'all';

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 4, vsync: this);
    WidgetsBinding.instance.addPostFrameCallback((_) {
      ref.read(predictiveAnalyticsProvider.notifier).loadPredictiveData();
    });
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final analyticsState = ref.watch(predictiveAnalyticsProvider);
    
    return Scaffold(
      appBar: AppBar(
        title: const Text('Predictive Analytics'),
        backgroundColor: AppColors.primary,
        foregroundColor: Colors.white,
        bottom: TabBar(
          controller: _tabController,
          indicatorColor: Colors.white,
          labelColor: Colors.white,
          unselectedLabelColor: Colors.white70,
          tabs: const [
            Tab(text: 'Overview', icon: Icon(Icons.dashboard, size: 20)),
            Tab(text: 'Risk Analysis', icon: Icon(Icons.warning, size: 20)),
            Tab(text: 'Trends', icon: Icon(Icons.trending_up, size: 20)),
            Tab(text: 'Alerts', icon: Icon(Icons.notifications, size: 20)),
          ],
        ),
        actions: [
          _buildTimeRangeSelector(),
          _buildPatientSelector(),
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: () => ref.read(predictiveAnalyticsProvider.notifier).refreshData(),
          ),
        ],
      ),
      body: analyticsState.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (error, _) => Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(Icons.error, size: 64, color: AppColors.error),
              const SizedBox(height: 16),
              Text('Error: $error'),
              const SizedBox(height: 16),
              ElevatedButton(
                onPressed: () => ref.read(predictiveAnalyticsProvider.notifier).loadPredictiveData(),
                child: const Text('Retry'),
              ),
            ],
          ),
        ),
        data: (data) => TabBarView(
          controller: _tabController,
          children: [
            _buildOverviewTab(data),
            _buildRiskAnalysisTab(data),
            _buildTrendsTab(data),
            _buildAlertsTab(data),
          ],
        ),
      ),
    );
  }

  Widget _buildTimeRangeSelector() {
    return PopupMenuButton<String>(
      initialValue: _selectedTimeRange,
      onSelected: (value) {
        setState(() {
          _selectedTimeRange = value;
        });
        ref.read(predictiveAnalyticsProvider.notifier).updateTimeRange(value);
      },
      itemBuilder: (context) => [
        const PopupMenuItem(value: '24h', child: Text('Last 24 Hours')),
        const PopupMenuItem(value: '7d', child: Text('Last 7 Days')),
        const PopupMenuItem(value: '30d', child: Text('Last 30 Days')),
        const PopupMenuItem(value: '90d', child: Text('Last 90 Days')),
      ],
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 8),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(_getTimeRangeLabel(_selectedTimeRange)),
            const Icon(Icons.arrow_drop_down),
          ],
        ),
      ),
    );
  }

  Widget _buildPatientSelector() {
    return PopupMenuButton<String>(
      initialValue: _selectedPatientId,
      onSelected: (value) {
        setState(() {
          _selectedPatientId = value;
        });
        ref.read(predictiveAnalyticsProvider.notifier).updatePatientFilter(value);
      },
      itemBuilder: (context) => [
        const PopupMenuItem(value: 'all', child: Text('All Patients')),
        const PopupMenuItem(value: 'high_risk', child: Text('High Risk Only')),
        const PopupMenuItem(value: 'critical', child: Text('Critical Only')),
      ],
      child: const Padding(
        padding: EdgeInsets.symmetric(horizontal: 8),
        child: Icon(Icons.filter_list),
      ),
    );
  }

  Widget _buildOverviewTab(PredictiveAnalyticsData data) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Key Metrics Cards
          _buildKeyMetricsSection(data.keyMetrics),
          
          const SizedBox(height: 24),
          
          // Early Warning System
          _buildEarlyWarningSection(data.earlyWarnings),
          
          const SizedBox(height: 24),
          
          // Population Health Overview
          _buildPopulationHealthSection(data.populationHealth),
          
          const SizedBox(height: 24),
          
          // Recent Predictions
          _buildRecentPredictionsSection(data.recentPredictions),
        ],
      ),
    );
  }

  Widget _buildKeyMetricsSection(KeyMetrics metrics) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Key Metrics',
          style: TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 16),
        GridView.count(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          crossAxisCount: 2,
          crossAxisSpacing: 16,
          mainAxisSpacing: 16,
          childAspectRatio: 1.5,
          children: [
            _buildMetricCard(
              'High Risk Patients',
              metrics.highRiskPatients.toString(),
              Icons.warning,
              AppColors.warning,
              '${metrics.highRiskChange > 0 ? '+' : ''}${metrics.highRiskChange}%',
            ),
            _buildMetricCard(
              'Predicted Admissions',
              metrics.predictedAdmissions.toString(),
              Icons.local_hospital,
              AppColors.info,
              '${metrics.admissionChange > 0 ? '+' : ''}${metrics.admissionChange}%',
            ),
            _buildMetricCard(
              'Early Warnings',
              metrics.earlyWarnings.toString(),
              Icons.notifications_active,
              AppColors.error,
              '${metrics.warningChange > 0 ? '+' : ''}${metrics.warningChange}%',
            ),
            _buildMetricCard(
              'Accuracy Score',
              '${(metrics.accuracyScore * 100).toStringAsFixed(1)}%',
              Icons.analytics,
              AppColors.success,
              '${metrics.accuracyChange > 0 ? '+' : ''}${metrics.accuracyChange.toStringAsFixed(1)}%',
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildMetricCard(String title, String value, IconData icon, Color color, String change) {
    final isPositive = change.startsWith('+');
    final changeColor = title == 'Accuracy Score' 
        ? (isPositive ? AppColors.success : AppColors.error)
        : (isPositive ? AppColors.error : AppColors.success);
    
    return Card(
      elevation: 2,
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(icon, color: color, size: 24),
                const Spacer(),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                  decoration: BoxDecoration(
                    color: changeColor.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Text(
                    change,
                    style: TextStyle(
                      color: changeColor,
                      fontSize: 10,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 8),
            Text(
              value,
              style: const TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              title,
              style: TextStyle(
                fontSize: 12,
                color: AppColors.textSecondary,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildEarlyWarningSection(List<EarlyWarning> warnings) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            const Text(
              'Early Warning System',
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
              ),
            ),
            const Spacer(),
            TextButton(
              onPressed: () => _showAllWarnings(warnings),
              child: const Text('View All'),
            ),
          ],
        ),
        const SizedBox(height: 16),
        if (warnings.isEmpty)
          Container(
            padding: const EdgeInsets.all(24),
            decoration: BoxDecoration(
              color: AppColors.success.withOpacity(0.1),
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: AppColors.success.withOpacity(0.3)),
            ),
            child: Row(
              children: [
                Icon(Icons.check_circle, color: AppColors.success),
                const SizedBox(width: 12),
                const Expanded(
                  child: Text(
                    'No critical warnings at this time. All patients are stable.',
                    style: TextStyle(fontWeight: FontWeight.w500),
                  ),
                ),
              ],
            ),
          )
        else
          ListView.builder(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            itemCount: warnings.take(3).length,
            itemBuilder: (context, index) {
              final warning = warnings[index];
              return EarlyWarningCard(
                warning: warning,
                onTap: () => _handleWarningTap(warning),
              );
            },
          ),
      ],
    );
  }

  Widget _buildPopulationHealthSection(PopulationHealthData populationHealth) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Population Health Trends',
          style: TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 16),
        Card(
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              children: [
                Row(
                  children: [
                    Expanded(
                      child: _buildPopulationMetric(
                        'Total Population',
                        populationHealth.totalPopulation.toString(),
                        Icons.people,
                        AppColors.primary,
                      ),
                    ),
                    Expanded(
                      child: _buildPopulationMetric(
                        'At Risk',
                        populationHealth.atRiskCount.toString(),
                        Icons.warning,
                        AppColors.warning,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 16),
                SizedBox(
                  height: 200,
                  child: PopulationHealthChart(data: populationHealth.trends),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildPopulationMetric(String title, String value, IconData icon, Color color) {
    return Column(
      children: [
        Icon(icon, color: color, size: 32),
        const SizedBox(height: 8),
        Text(
          value,
          style: const TextStyle(
            fontSize: 24,
            fontWeight: FontWeight.bold,
          ),
        ),
        Text(
          title,
          style: TextStyle(
            fontSize: 12,
            color: AppColors.textSecondary,
          ),
        ),
      ],
    );
  }

  Widget _buildRecentPredictionsSection(List<PredictionResult> predictions) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            const Text(
              'Recent Predictions',
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
              ),
            ),
            const Spacer(),
            TextButton(
              onPressed: () => _showAllPredictions(predictions),
              child: const Text('View All'),
            ),
          ],
        ),
        const SizedBox(height: 16),
        ListView.builder(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          itemCount: predictions.take(5).length,
          itemBuilder: (context, index) {
            final prediction = predictions[index];
            return PredictionCard(
              prediction: prediction,
              onTap: () => _handlePredictionTap(prediction),
            );
          },
        ),
      ],
    );
  }

  Widget _buildRiskAnalysisTab(PredictiveAnalyticsData data) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Risk Distribution Chart
          _buildRiskDistributionChart(data.riskDistribution),
          
          const SizedBox(height: 24),
          
          // High Risk Patients
          _buildHighRiskPatientsSection(data.highRiskPatients),
          
          const SizedBox(height: 24),
          
          // Risk Factors Analysis
          _buildRiskFactorsSection(data.riskFactors),
        ],
      ),
    );
  }

  Widget _buildRiskDistributionChart(RiskDistribution distribution) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Risk Distribution',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 16),
            SizedBox(
              height: 300,
              child: PieChart(
                PieChartData(
                  sections: [
                    PieChartSectionData(
                      value: distribution.lowRisk.toDouble(),
                      title: 'Low\n${distribution.lowRisk}',
                      color: AppColors.success,
                      radius: 100,
                      titleStyle: const TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                      ),
                    ),
                    PieChartSectionData(
                      value: distribution.moderateRisk.toDouble(),
                      title: 'Moderate\n${distribution.moderateRisk}',
                      color: AppColors.warning,
                      radius: 100,
                      titleStyle: const TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                      ),
                    ),
                    PieChartSectionData(
                      value: distribution.highRisk.toDouble(),
                      title: 'High\n${distribution.highRisk}',
                      color: AppColors.error,
                      radius: 100,
                      titleStyle: const TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                      ),
                    ),
                  ],
                  sectionsSpace: 2,
                  centerSpaceRadius: 40,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildHighRiskPatientsSection(List<HighRiskPatient> patients) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'High Risk Patients',
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 16),
        ListView.builder(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          itemCount: patients.length,
          itemBuilder: (context, index) {
            final patient = patients[index];
            return HighRiskPatientCard(
              patient: patient,
              onTap: () => _handleHighRiskPatientTap(patient),
            );
          },
        ),
      ],
    );
  }

  Widget _buildRiskFactorsSection(List<RiskFactor> riskFactors) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Top Risk Factors',
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 16),
        Card(
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              children: riskFactors.map((factor) {
                return Padding(
                  padding: const EdgeInsets.only(bottom: 12),
                  child: Row(
                    children: [
                      Expanded(
                        flex: 2,
                        child: Text(
                          factor.name,
                          style: const TextStyle(fontWeight: FontWeight.w500),
                        ),
                      ),
                      Expanded(
                        flex: 3,
                        child: LinearProgressIndicator(
                          value: factor.prevalence,
                          backgroundColor: AppColors.grey200,
                          valueColor: AlwaysStoppedAnimation<Color>(
                            _getRiskFactorColor(factor.prevalence),
                          ),
                        ),
                      ),
                      const SizedBox(width: 8),
                      Text(
                        '${(factor.prevalence * 100).toStringAsFixed(1)}%',
                        style: const TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ],
                  ),
                );
              }).toList(),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildTrendsTab(PredictiveAnalyticsData data) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Prediction Accuracy Trends
          _buildAccuracyTrendsChart(data.accuracyTrends),
          
          const SizedBox(height: 24),
          
          // Health Outcome Trends
          _buildHealthOutcomeTrends(data.healthOutcomeTrends),
          
          const SizedBox(height: 24),
          
          // Seasonal Patterns
          _buildSeasonalPatterns(data.seasonalPatterns),
        ],
      ),
    );
  }

  Widget _buildAccuracyTrendsChart(List<AccuracyTrend> trends) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Prediction Accuracy Trends',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 16),
            SizedBox(
              height: 300,
              child: LineChart(
                LineChartData(
                  gridData: FlGridData(show: true),
                  titlesData: FlTitlesData(show: true),
                  borderData: FlBorderData(show: true),
                  lineBarsData: [
                    LineChartBarData(
                      spots: trends.asMap().entries.map((entry) {
                        return FlSpot(entry.key.toDouble(), entry.value.accuracy);
                      }).toList(),
                      isCurved: true,
                      color: AppColors.primary,
                      barWidth: 3,
                      dotData: FlDotData(show: true),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildHealthOutcomeTrends(List<HealthOutcomeTrend> trends) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Health Outcome Trends',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 16),
            SizedBox(
              height: 300,
              child: SfCartesianChart(
                primaryXAxis: CategoryAxis(),
                series: <ChartSeries>[
                  LineSeries<HealthOutcomeTrend, String>(
                    dataSource: trends,
                    xValueMapper: (trend, _) => trend.period,
                    yValueMapper: (trend, _) => trend.value,
                    color: AppColors.success,
                    width: 3,
                    markerSettings: const MarkerSettings(isVisible: true),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSeasonalPatterns(List<SeasonalPattern> patterns) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Seasonal Health Patterns',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 16),
            ListView.builder(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              itemCount: patterns.length,
              itemBuilder: (context, index) {
                final pattern = patterns[index];
                return SeasonalPatternCard(pattern: pattern);
              },
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildAlertsTab(PredictiveAnalyticsData data) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Alert Summary
          _buildAlertSummary(data.alertSummary),
          
          const SizedBox(height: 24),
          
          // Active Alerts
          _buildActiveAlerts(data.activeAlerts),
          
          const SizedBox(height: 24),
          
          // Alert History
          _buildAlertHistory(data.alertHistory),
        ],
      ),
    );
  }

  Widget _buildAlertSummary(AlertSummary summary) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Alert Summary',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 16),
            Row(
              children: [
                Expanded(
                  child: _buildAlertSummaryItem(
                    'Critical',
                    summary.critical,
                    AppColors.error,
                  ),
                ),
                Expanded(
                  child: _buildAlertSummaryItem(
                    'High',
                    summary.high,
                    AppColors.warning,
                  ),
                ),
                Expanded(
                  child: _buildAlertSummaryItem(
                    'Medium',
                    summary.medium,
                    AppColors.info,
                  ),
                ),
                Expanded(
                  child: _buildAlertSummaryItem(
                    'Low',
                    summary.low,
                    AppColors.success,
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildAlertSummaryItem(String label, int count, Color color) {
    return Column(
      children: [
        Text(
          count.toString(),
          style: TextStyle(
            fontSize: 24,
            fontWeight: FontWeight.bold,
            color: color,
          ),
        ),
        Text(
          label,
          style: TextStyle(
            fontSize: 12,
            color: AppColors.textSecondary,
          ),
        ),
      ],
    );
  }

  Widget _buildActiveAlerts(List<PredictiveAlert> alerts) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Active Alerts',
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 16),
        ListView.builder(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          itemCount: alerts.length,
          itemBuilder: (context, index) {
            final alert = alerts[index];
            return PredictiveAlertCard(
              alert: alert,
              onTap: () => _handleAlertTap(alert),
              onDismiss: () => _dismissAlert(alert),
            );
          },
        ),
      ],
    );
  }

  Widget _buildAlertHistory(List<PredictiveAlert> history) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Recent Alert History',
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 16),
        ListView.builder(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          itemCount: history.take(10).length,
          itemBuilder: (context, index) {
            final alert = history[index];
            return AlertHistoryCard(alert: alert);
          },
        ),
      ],
    );
  }

  // Helper methods
  String _getTimeRangeLabel(String range) {
    switch (range) {
      case '24h':
        return '24h';
      case '7d':
        return '7d';
      case '30d':
        return '30d';
      case '90d':
        return '90d';
      default:
        return '7d';
    }
  }

  Color _getRiskFactorColor(double prevalence) {
    if (prevalence > 0.7) return AppColors.error;
    if (prevalence > 0.4) return AppColors.warning;
    return AppColors.success;
  }

  void _showAllWarnings(List<EarlyWarning> warnings) {
    // Navigate to detailed warnings page
  }

  void _showAllPredictions(List<PredictionResult> predictions) {
    // Navigate to detailed predictions page
  }

  void _handleWarningTap(EarlyWarning warning) {
    // Handle warning tap - navigate to patient details or take action
  }

  void _handlePredictionTap(PredictionResult prediction) {
    // Handle prediction tap - show detailed analysis
  }

  void _handleHighRiskPatientTap(HighRiskPatient patient) {
    // Navigate to patient details
  }

  void _handleAlertTap(PredictiveAlert alert) {
    // Handle alert tap - show details or take action
  }

  void _dismissAlert(PredictiveAlert alert) {
    ref.read(predictiveAnalyticsProvider.notifier).dismissAlert(alert.id);
  }
}

// Supporting data classes and widgets would be defined in separate files
// This includes all the chart widgets, card widgets, and data models