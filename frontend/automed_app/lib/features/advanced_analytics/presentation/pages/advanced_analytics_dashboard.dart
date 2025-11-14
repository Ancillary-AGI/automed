import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../providers/advanced_analytics_provider.dart';
import '../widgets/real_time_metrics_widget.dart';
import '../widgets/predictive_charts_widget.dart';
import '../widgets/performance_kpi_widget.dart';
import '../widgets/population_health_widget.dart';

class AdvancedAnalyticsDashboard extends ConsumerStatefulWidget {
  const AdvancedAnalyticsDashboard({super.key});

  @override
  ConsumerState<AdvancedAnalyticsDashboard> createState() =>
      _AdvancedAnalyticsDashboardState();
}

class _AdvancedAnalyticsDashboardState
    extends ConsumerState<AdvancedAnalyticsDashboard>
    with TickerProviderStateMixin {
  late TabController _tabController;
  String selectedTimeRange = '24h';

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 4, vsync: this);
  }

  @override
  Widget build(BuildContext context) {
    final analyticsState = ref.watch(advancedAnalyticsProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Advanced Analytics Dashboard'),
        backgroundColor: Theme.of(context).colorScheme.primary,
        foregroundColor: Colors.white,
        actions: [
          PopupMenuButton<String>(
            initialValue: selectedTimeRange,
            onSelected: (value) {
              setState(() {
                selectedTimeRange = value;
              });
              ref
                  .read(advancedAnalyticsProvider.notifier)
                  .updateTimeRange(value);
            },
            itemBuilder: (context) => [
              const PopupMenuItem(value: '1h', child: Text('Last Hour')),
              const PopupMenuItem(value: '24h', child: Text('Last 24 Hours')),
              const PopupMenuItem(value: '7d', child: Text('Last 7 Days')),
              const PopupMenuItem(value: '30d', child: Text('Last 30 Days')),
              const PopupMenuItem(value: '90d', child: Text('Last 90 Days')),
            ],
          ),
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: () => ref.refresh(advancedAnalyticsProvider),
          ),
        ],
        bottom: TabBar(
          controller: _tabController,
          indicatorColor: Colors.white,
          labelColor: Colors.white,
          unselectedLabelColor: Colors.white70,
          tabs: const [
            Tab(icon: Icon(Icons.dashboard), text: 'Overview'),
            Tab(icon: Icon(Icons.trending_up), text: 'Predictive'),
            Tab(icon: Icon(Icons.speed), text: 'Performance'),
            Tab(icon: Icon(Icons.people), text: 'Population'),
          ],
        ),
      ),
      body: analyticsState.when(
        data: (data) => TabBarView(
          controller: _tabController,
          children: [
            _buildOverviewTab(data),
            _buildPredictiveTab(data),
            _buildPerformanceTab(data),
            _buildPopulationTab(data),
          ],
        ),
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (error, stack) => Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(Icons.error, size: 64, color: Colors.red[300]),
              const SizedBox(height: 16),
              Text('Error loading analytics: $error'),
              const SizedBox(height: 16),
              ElevatedButton(
                onPressed: () => ref.refresh(advancedAnalyticsProvider),
                child: const Text('Retry'),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildOverviewTab(dynamic data) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Real-time metrics cards
          Row(
            children: [
              Expanded(
                child: _buildMetricCard(
                  'Active Patients',
                  '${data.activePatients}',
                  Icons.people,
                  Colors.blue,
                  '+${data.patientGrowth}%',
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: _buildMetricCard(
                  'Critical Alerts',
                  '${data.criticalAlerts}',
                  Icons.warning,
                  Colors.red,
                  '${data.alertTrend}%',
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          Row(
            children: [
              Expanded(
                child: _buildMetricCard(
                  'Bed Occupancy',
                  '${data.bedOccupancy}%',
                  Icons.bed,
                  Colors.green,
                  '${data.occupancyTrend}%',
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: _buildMetricCard(
                  'Avg Response Time',
                  '${data.avgResponseTime}min',
                  Icons.timer,
                  Colors.orange,
                  '${data.responseTrend}%',
                ),
              ),
            ],
          ),
          const SizedBox(height: 24),

          // Real-time charts
          const RealTimeMetricsWidget(),
          const SizedBox(height: 24),

          // System status
          _buildSystemStatusSection(data),
        ],
      ),
    );
  }

  Widget _buildPredictiveTab(dynamic data) {
    return const SingleChildScrollView(
      padding: EdgeInsets.all(16),
      child: Column(
        children: [
          PredictiveChartsWidget(),
          SizedBox(height: 24),

          // Risk Assessment Matrix
          Card(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Risk Assessment Matrix',
                    style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
                  ),
                  const SizedBox(height: 16),
                  SizedBox(
                    height: 200,
                    child: const Center(
                      child: Text('Risk assessment visualization'),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildPerformanceTab(dynamic data) {
    return const SingleChildScrollView(
      padding: EdgeInsets.all(16),
      child: Column(
        children: [
          PerformanceKpiWidget(),
          SizedBox(height: 24),

          // Resource Utilization Chart
          Card(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Resource Utilization',
                    style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
                  ),
                  const SizedBox(height: 16),
                  SizedBox(
                    height: 200,
                    child: const Center(
                      child: Text('Resource utilization charts'),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildPopulationTab(dynamic data) {
    return const SingleChildScrollView(
      padding: EdgeInsets.all(16),
      child: Column(
        children: [
          PopulationHealthWidget(),
          SizedBox(height: 24),

          // Community Health Metrics
          Card(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Community Health Metrics',
                    style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
                  ),
                  const SizedBox(height: 16),
                  SizedBox(
                    height: 200,
                    child: const Center(
                      child: Text('Community health visualization'),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildMetricCard(
    String title,
    String value,
    IconData icon,
    Color color,
    String trend,
  ) {
    final isPositive = trend.startsWith('+');
    final trendColor = isPositive ? Colors.green : Colors.red;

    return Card(
      elevation: 4,
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
                  padding:
                      const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                  decoration: BoxDecoration(
                    color: trendColor.withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Text(
                    trend,
                    style: TextStyle(
                      color: trendColor,
                      fontWeight: FontWeight.bold,
                      fontSize: 12,
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
            Text(
              title,
              style: TextStyle(
                color: Colors.grey[600],
                fontSize: 14,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSystemStatusSection(dynamic data) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'System Status',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 16),
            ...data.systemServices
                .map<Widget>((service) => _buildServiceStatus(
                    service.name, service.status, service.responseTime))
                .toList(),
          ],
        ),
      ),
    );
  }

  Widget _buildServiceStatus(String name, String status, int responseTime) {
    final isHealthy = status == 'healthy';
    final statusColor = isHealthy ? Colors.green : Colors.red;

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        children: [
          Container(
            width: 8,
            height: 8,
            decoration: BoxDecoration(
              color: statusColor,
              shape: BoxShape.circle,
            ),
          ),
          const SizedBox(width: 12),
          Expanded(child: Text(name)),
          Text('${responseTime}ms', style: TextStyle(color: Colors.grey[600])),
        ],
      ),
    );
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }
}
