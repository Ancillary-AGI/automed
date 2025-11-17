import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:fl_chart/fl_chart.dart';
import '../providers/advanced_analytics_provider.dart';

class RealTimeMetricsWidget extends ConsumerWidget {
  const RealTimeMetricsWidget({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final analyticsState = ref.watch(advancedAnalyticsProvider);

    return analyticsState.when(
      data: (data) => Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Real-Time Metrics',
            style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 16),

          // Vital Signs Chart
          Card(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Vital Signs Monitoring',
                    style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
                  ),
                  const SizedBox(height: 16),
                  SizedBox(
                    height: 200,
                    child: LineChart(
                      _buildVitalSignsChart(data.realTimeMetrics.vitalSigns),
                    ),
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 16),

          // Patient Flow Chart
          Card(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Patient Flow',
                    style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
                  ),
                  const SizedBox(height: 16),
                  SizedBox(
                    height: 200,
                    child: BarChart(
                      _buildPatientFlowChart(data.realTimeMetrics.patientFlow),
                    ),
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 16),

          // Resource Utilization
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
                    child: PieChart(
                      _buildResourceUtilizationChart(
                          data.realTimeMetrics.resourceUtilization),
                    ),
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 16),

          // Active Alerts
          Card(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Active Alerts',
                    style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
                  ),
                  const SizedBox(height: 16),
                  ...data.realTimeMetrics.activeAlerts.take(5).map(
                        (alert) => _buildAlertTile(alert),
                      ),
                  if (data.realTimeMetrics.activeAlerts.length > 5)
                    TextButton(
                      onPressed: () {
                        // Navigate to full alerts view
                      },
                      child: Text(
                          'View all ${data.realTimeMetrics.activeAlerts.length} alerts'),
                    ),
                ],
              ),
            ),
          ),
        ],
      ),
      loading: () => const Center(child: CircularProgressIndicator()),
      error: (error, stack) => Center(
        child: Text('Error loading metrics: $error'),
      ),
    );
  }

  LineChartData _buildVitalSignsChart(List<dynamic> vitalSigns) {
    return LineChartData(
      gridData: const FlGridData(show: true),
      titlesData: const FlTitlesData(
        leftTitles: AxisTitles(
          sideTitles: SideTitles(showTitles: true, reservedSize: 40),
        ),
        bottomTitles: AxisTitles(
          sideTitles: SideTitles(showTitles: true, reservedSize: 30),
        ),
        rightTitles: AxisTitles(sideTitles: SideTitles(showTitles: false)),
        topTitles: AxisTitles(sideTitles: SideTitles(showTitles: false)),
      ),
      borderData: FlBorderData(show: true),
      lineBarsData: [
        LineChartBarData(
          spots: vitalSigns.asMap().entries.map((entry) {
            return FlSpot(entry.key.toDouble(), entry.value.value.toDouble());
          }).toList(),
          isCurved: true,
          color: Colors.blue,
          barWidth: 3,
          dotData: const FlDotData(show: false),
        ),
      ],
    );
  }

  BarChartData _buildPatientFlowChart(List<dynamic> patientFlow) {
    return BarChartData(
      alignment: BarChartAlignment.spaceAround,
      maxY: patientFlow.isNotEmpty
          ? patientFlow
                  .map((e) => e.value)
                  .reduce((a, b) => a > b ? a : b)
                  .toDouble() *
              1.2
          : 100,
      barTouchData: BarTouchData(enabled: true),
      titlesData: const FlTitlesData(
        leftTitles: AxisTitles(
          sideTitles: SideTitles(showTitles: true, reservedSize: 40),
        ),
        bottomTitles: AxisTitles(
          sideTitles: SideTitles(showTitles: true, reservedSize: 30),
        ),
        rightTitles: AxisTitles(sideTitles: SideTitles(showTitles: false)),
        topTitles: AxisTitles(sideTitles: SideTitles(showTitles: false)),
      ),
      borderData: FlBorderData(show: true),
      barGroups: patientFlow.asMap().entries.map((entry) {
        return BarChartGroupData(
          x: entry.key,
          barRods: [
            BarChartRodData(
              toY: entry.value.value.toDouble(),
              color: Colors.green,
              width: 20,
            ),
          ],
        );
      }).toList(),
    );
  }

  PieChartData _buildResourceUtilizationChart(List<dynamic> resourceData) {
    return PieChartData(
      sections: resourceData.asMap().entries.map((entry) {
        final colors = [
          Colors.blue,
          Colors.green,
          Colors.orange,
          Colors.red,
          Colors.purple
        ];
        return PieChartSectionData(
          value: entry.value.value.toDouble(),
          title: '${entry.value.value.toInt()}%',
          color: colors[entry.key % colors.length],
          radius: 60,
          titleStyle: const TextStyle(
            fontSize: 12,
            fontWeight: FontWeight.bold,
            color: Colors.white,
          ),
        );
      }).toList(),
      sectionsSpace: 2,
      centerSpaceRadius: 40,
    );
  }

  Widget _buildAlertTile(dynamic alert) {
    Color severityColor;
    IconData severityIcon;

    switch (alert.severity.toLowerCase()) {
      case 'critical':
        severityColor = Colors.red;
        severityIcon = Icons.error;
        break;
      case 'high':
        severityColor = Colors.orange;
        severityIcon = Icons.warning;
        break;
      case 'medium':
        severityColor = Colors.yellow;
        severityIcon = Icons.info;
        break;
      default:
        severityColor = Colors.blue;
        severityIcon = Icons.notifications;
    }

    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        border: Border(left: BorderSide(color: severityColor, width: 4)),
        color: severityColor.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Row(
        children: [
          Icon(severityIcon, color: severityColor, size: 20),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  alert.message,
                  style: const TextStyle(fontWeight: FontWeight.w600),
                ),
                Text(
                  'Patient: ${alert.patientId} • ${_formatTime(alert.timestamp)}',
                  style: TextStyle(
                    fontSize: 12,
                    color: Colors.grey[600],
                  ),
                ),
              ],
            ),
          ),
          if (!alert.acknowledged)
            IconButton(
              icon: const Icon(Icons.check_circle_outline),
              onPressed: () {
                // Acknowledge alert
              },
            ),
        ],
      ),
    );
  }

  String _formatTime(DateTime timestamp) {
    final now = DateTime.now();
    final difference = now.difference(timestamp);

    if (difference.inMinutes < 1) {
      return 'Just now';
    } else if (difference.inHours < 1) {
      return '${difference.inMinutes}m ago';
    } else if (difference.inDays < 1) {
      return '${difference.inHours}h ago';
    } else {
      return '${difference.inDays}d ago';
    }
  }
}
