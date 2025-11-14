import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:fl_chart/fl_chart.dart';
import '../providers/advanced_analytics_provider.dart';

class PopulationHealthWidget extends ConsumerWidget {
  const PopulationHealthWidget({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final analyticsState = ref.watch(advancedAnalyticsProvider);

    return analyticsState.when(
      data: (data) => Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Text(
                'Population Health Analytics',
                style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
              ),
              const Spacer(),
              Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                decoration: BoxDecoration(
                  color: _getHealthScoreColor(
                          data.populationHealth.communityHealthScore)
                      .withValues(alpha: 0.2),
                  borderRadius: BorderRadius.circular(16),
                ),
                child: Text(
                  'Health Score: ${(data.populationHealth.communityHealthScore * 100).toInt()}',
                  style: TextStyle(
                    color: _getHealthScoreColor(
                        data.populationHealth.communityHealthScore),
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),

          // Demographics Overview
          Card(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Demographics Overview',
                    style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
                  ),
                  const SizedBox(height: 16),
                  SizedBox(
                    height: 200,
                    child: Row(
                      children: [
                        Expanded(
                          child: PieChart(
                            _buildDemographicsChart(
                                data.populationHealth.demographics),
                          ),
                        ),
                        const SizedBox(width: 16),
                        Expanded(
                          child: _buildDemographicsLegend(
                              data.populationHealth.demographics),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 16),

          // Disease Prevalence
          Card(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Disease Prevalence',
                    style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
                  ),
                  const SizedBox(height: 16),
                  SizedBox(
                    height: 250,
                    child: BarChart(
                      _buildDiseasePrevalenceChart(
                          data.populationHealth.diseasePrevalence),
                    ),
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 16),

          // Outbreak Alerts
          if (data.populationHealth.outbreakAlerts.isNotEmpty)
            Card(
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        const Icon(Icons.warning, color: Colors.red),
                        const SizedBox(width: 8),
                        const Text(
                          'Outbreak Alerts',
                          style: TextStyle(
                              fontSize: 16, fontWeight: FontWeight.w600),
                        ),
                        const Spacer(),
                        Chip(
                          label: Text(
                              '${data.populationHealth.outbreakAlerts.length} Active'),
                          backgroundColor: Colors.red.withValues(alpha: 0.2),
                          labelStyle: const TextStyle(color: Colors.red),
                        ),
                      ],
                    ),
                    const SizedBox(height: 16),
                    ...data.populationHealth.outbreakAlerts.map(
                      (alert) => _buildOutbreakAlertTile(alert),
                    ),
                  ],
                ),
              ),
            ),
          const SizedBox(height: 16),

          // Health Trends
          Card(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Health Trends',
                    style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
                  ),
                  const SizedBox(height: 16),
                  SizedBox(
                    height: 200,
                    child: LineChart(
                      _buildHealthTrendsChart(
                          data.populationHealth.healthTrends),
                    ),
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 16),

          // Preventive Care Metrics
          Card(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Preventive Care Coverage',
                    style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
                  ),
                  const SizedBox(height: 16),
                  ...data.populationHealth.preventiveCare.map(
                    (metric) => _buildPreventiveCareRow(metric),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
      loading: () => const Center(child: CircularProgressIndicator()),
      error: (error, stack) => Center(
        child: Text('Error loading population health data: $error'),
      ),
    );
  }

  Color _getHealthScoreColor(double score) {
    if (score >= 0.8) return Colors.green;
    if (score >= 0.6) return Colors.orange;
    return Colors.red;
  }

  PieChartData _buildDemographicsChart(List<dynamic> demographics) {
    final colors = [
      Colors.blue,
      Colors.green,
      Colors.orange,
      Colors.red,
      Colors.purple,
      Colors.teal,
      Colors.pink,
      Colors.indigo,
    ];

    return PieChartData(
      sections: demographics.take(8).toList().asMap().entries.map((entry) {
        return PieChartSectionData(
          value: entry.value.percentage.toDouble(),
          title: '${entry.value.percentage.toInt()}%',
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

  Widget _buildDemographicsLegend(List<dynamic> demographics) {
    final colors = [
      Colors.blue,
      Colors.green,
      Colors.orange,
      Colors.red,
      Colors.purple,
      Colors.teal,
      Colors.pink,
      Colors.indigo,
    ];

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: demographics.take(8).toList().asMap().entries.map((entry) {
        return Padding(
          padding: const EdgeInsets.symmetric(vertical: 4),
          child: Row(
            children: [
              Container(
                width: 12,
                height: 12,
                decoration: BoxDecoration(
                  color: colors[entry.key % colors.length],
                  shape: BoxShape.circle,
                ),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: Text(
                  '${entry.value.category} - ${entry.value.subcategory}',
                  style: const TextStyle(fontSize: 12),
                ),
              ),
            ],
          ),
        );
      }).toList(),
    );
  }

  BarChartData _buildDiseasePrevalenceChart(List<dynamic> diseasePrevalence) {
    return BarChartData(
      alignment: BarChartAlignment.spaceAround,
      maxY: diseasePrevalence.isNotEmpty
          ? diseasePrevalence
                  .map((e) => e.prevalenceRate)
                  .reduce((a, b) => a > b ? a : b)
                  .toDouble() *
              1.2
          : 100,
      barTouchData: BarTouchData(
        enabled: true,
        touchTooltipData: BarTouchTooltipData(
          tooltipBgColor: Colors.blueGrey,
          getTooltipItem: (group, groupIndex, rod, rodIndex) {
            final disease = diseasePrevalence[groupIndex];
            return BarTooltipItem(
              '${disease.disease}\n${disease.cases} cases\n${disease.prevalenceRate.toStringAsFixed(1)}%',
              const TextStyle(color: Colors.white),
            );
          },
        ),
      ),
      titlesData: FlTitlesData(
        leftTitles: AxisTitles(
          sideTitles: SideTitles(
            showTitles: true,
            reservedSize: 40,
            getTitlesWidget: (value, meta) {
              return Text('${value.toInt()}%');
            },
          ),
        ),
        bottomTitles: AxisTitles(
          sideTitles: SideTitles(
            showTitles: true,
            reservedSize: 80,
            getTitlesWidget: (value, meta) {
              if (value.toInt() < diseasePrevalence.length) {
                return RotatedBox(
                  quarterTurns: 1,
                  child: Text(
                    diseasePrevalence[value.toInt()].disease,
                    style: const TextStyle(fontSize: 10),
                  ),
                );
              }
              return const Text('');
            },
          ),
        ),
        rightTitles: AxisTitles(sideTitles: SideTitles(showTitles: false)),
        topTitles: AxisTitles(sideTitles: SideTitles(showTitles: false)),
      ),
      borderData: FlBorderData(show: true),
      barGroups: diseasePrevalence.asMap().entries.map((entry) {
        Color barColor;
        if (entry.value.prevalenceRate > 10) {
          barColor = Colors.red;
        } else if (entry.value.prevalenceRate > 5) {
          barColor = Colors.orange;
        } else {
          barColor = Colors.green;
        }

        return BarChartGroupData(
          x: entry.key,
          barRods: [
            BarChartRodData(
              toY: entry.value.prevalenceRate.toDouble(),
              color: barColor,
              width: 20,
            ),
          ],
        );
      }).toList(),
    );
  }

  Widget _buildOutbreakAlertTile(dynamic alert) {
    Color severityColor;
    switch (alert.severity.toLowerCase()) {
      case 'critical':
        severityColor = Colors.red;
        break;
      case 'high':
        severityColor = Colors.orange;
        break;
      default:
        severityColor = Colors.yellow;
    }

    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        border: Border(left: BorderSide(color: severityColor, width: 4)),
        color: severityColor.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Expanded(
                child: Text(
                  '${alert.disease} Outbreak - ${alert.location}',
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
              Chip(
                label: Text(alert.severity),
                backgroundColor: severityColor.withValues(alpha: 0.2),
                labelStyle: TextStyle(color: severityColor),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Text(
            'Affected: ${alert.affectedCount} people',
            style: const TextStyle(fontWeight: FontWeight.w500),
          ),
          if (alert.description != null) ...[
            const SizedBox(height: 4),
            Text(
              alert.description,
              style: TextStyle(color: Colors.grey[700]),
            ),
          ],
          const SizedBox(height: 8),
          Row(
            children: [
              Text(
                'Detected: ${_formatDateTime(alert.detectedAt)}',
                style: TextStyle(
                  fontSize: 12,
                  color: Colors.grey[600],
                ),
              ),
              const Spacer(),
              Text(
                'Status: ${alert.status}',
                style: TextStyle(
                  fontSize: 12,
                  color: Colors.grey[600],
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  LineChartData _buildHealthTrendsChart(List<dynamic> healthTrends) {
    final colors = [
      Colors.blue,
      Colors.green,
      Colors.orange,
      Colors.red,
      Colors.purple
    ];

    return LineChartData(
      gridData: FlGridData(show: true),
      titlesData: FlTitlesData(
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
      lineBarsData: healthTrends.asMap().entries.map((entry) {
        final color = colors[entry.key % colors.length];

        return LineChartBarData(
          spots:
              entry.value.dataPoints.asMap().entries.map<FlSpot>((pointEntry) {
            return FlSpot(
              pointEntry.key.toDouble(),
              pointEntry.value.value.toDouble(),
            );
          }).toList(),
          isCurved: true,
          color: color,
          barWidth: 3,
          dotData: FlDotData(show: false),
        );
      }).toList(),
    );
  }

  Widget _buildPreventiveCareRow(dynamic metric) {
    final completionRate = metric.completionRate;
    final targetRate = metric.targetRate;
    final isOnTarget = completionRate >= targetRate;

    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Expanded(
                child: Text(
                  metric.careType,
                  style: const TextStyle(fontWeight: FontWeight.w600),
                ),
              ),
              Text(
                '${(completionRate * 100).toInt()}% / ${(targetRate * 100).toInt()}%',
                style: TextStyle(
                  color: isOnTarget ? Colors.green : Colors.red,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Stack(
            children: [
              Container(
                height: 8,
                decoration: BoxDecoration(
                  color: Colors.grey[200],
                  borderRadius: BorderRadius.circular(4),
                ),
              ),
              FractionallySizedBox(
                widthFactor: targetRate,
                child: Container(
                  height: 8,
                  decoration: BoxDecoration(
                    color: Colors.grey[400],
                    borderRadius: BorderRadius.circular(4),
                  ),
                ),
              ),
              FractionallySizedBox(
                widthFactor: completionRate,
                child: Container(
                  height: 8,
                  decoration: BoxDecoration(
                    color: isOnTarget ? Colors.green : Colors.orange,
                    borderRadius: BorderRadius.circular(4),
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 4),
          Text(
            '${metric.completedScreenings} of ${metric.eligiblePopulation} eligible',
            style: TextStyle(fontSize: 12, color: Colors.grey[600]),
          ),
        ],
      ),
    );
  }

  String _formatDateTime(DateTime dateTime) {
    return '${dateTime.day}/${dateTime.month}/${dateTime.year}';
  }
}
