import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:fl_chart/fl_chart.dart';
import '../providers/advanced_analytics_provider.dart';

class PredictiveChartsWidget extends ConsumerWidget {
  const PredictiveChartsWidget({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final analyticsState = ref.watch(advancedAnalyticsProvider);

    return analyticsState.when(
      data: (data) => Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Predictive Analytics',
            style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 16),

          // Health Outcomes Prediction
          Card(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      const Text(
                        'Health Outcomes Prediction',
                        style: TextStyle(
                            fontSize: 16, fontWeight: FontWeight.w600),
                      ),
                      const Spacer(),
                      Chip(
                        label: Text(
                            '${(data.predictiveInsights.accuracyScore * 100).toInt()}% Accuracy'),
                        backgroundColor: Colors.green.withValues(alpha: 0.2),
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),
                  SizedBox(
                    height: 250,
                    child: LineChart(
                      _buildHealthOutcomesChart(
                          data.predictiveInsights.healthOutcomes),
                    ),
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 16),

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
                    child: _buildRiskMatrix(
                        data.predictiveInsights.riskAssessments),
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 16),

          // Trend Analysis
          Card(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Trend Analysis',
                    style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
                  ),
                  const SizedBox(height: 16),
                  SizedBox(
                    height: 200,
                    child: BarChart(
                      _buildTrendChart(data.predictiveInsights.trends),
                    ),
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 16),

          // AI Recommendations
          Card(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'AI Recommendations',
                    style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
                  ),
                  const SizedBox(height: 16),
                  ...data.predictiveInsights.recommendations.take(5).map(
                        (recommendation) =>
                            _buildRecommendationTile(recommendation),
                      ),
                ],
              ),
            ),
          ),
        ],
      ),
      loading: () => const Center(child: CircularProgressIndicator()),
      error: (error, stack) => Center(
        child: Text('Error loading predictive analytics: $error'),
      ),
    );
  }

  LineChartData _buildHealthOutcomesChart(List<dynamic> healthOutcomes) {
    // Group predictions by type
    final predictionGroups = <String, List<dynamic>>{};
    for (final outcome in healthOutcomes) {
      predictionGroups.putIfAbsent(outcome.modelType, () => []).add(outcome);
    }

    final colors = [
      Colors.blue,
      Colors.red,
      Colors.green,
      Colors.orange,
      Colors.purple
    ];
    int colorIndex = 0;

    return LineChartData(
      gridData: const FlGridData(show: true),
      titlesData: FlTitlesData(
        leftTitles: AxisTitles(
          sideTitles: SideTitles(
            showTitles: true,
            reservedSize: 50,
            getTitlesWidget: (value, meta) {
              return Text('${(value * 100).toInt()}%');
            },
          ),
        ),
        bottomTitles: AxisTitles(
          sideTitles: SideTitles(
            showTitles: true,
            reservedSize: 30,
            getTitlesWidget: (value, meta) {
              return Text('Day ${value.toInt()}');
            },
          ),
        ),
        rightTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
        topTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
      ),
      borderData: FlBorderData(show: true),
      lineBarsData: predictionGroups.entries.map((entry) {
        final color = colors[colorIndex % colors.length];
        colorIndex++;

        return LineChartBarData(
          spots: entry.value.asMap().entries.map((spotEntry) {
            return FlSpot(
              spotEntry.key.toDouble(),
              spotEntry.value.confidence.toDouble(),
            );
          }).toList(),
          isCurved: true,
          color: color,
          barWidth: 3,
          dotData: const FlDotData(show: true),
        );
      }).toList(),
    );
  }

  Widget _buildRiskMatrix(List<dynamic> riskAssessments) {
    // Create a grid showing risk levels
    final riskLevels = ['Low', 'Medium', 'High', 'Critical'];
    final riskTypes = [
      'Infection',
      'Fall',
      'Medication',
      'Cardiac',
      'Respiratory'
    ];

    return GridView.builder(
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 5,
        childAspectRatio: 1,
        crossAxisSpacing: 4,
        mainAxisSpacing: 4,
      ),
      itemCount: riskLevels.length * riskTypes.length,
      itemBuilder: (context, index) {
        final row = index ~/ riskTypes.length;
        final col = index % riskTypes.length;

        if (row == 0) {
          // Header row
          return Container(
            decoration: BoxDecoration(
              color: Colors.grey[200],
              borderRadius: BorderRadius.circular(4),
            ),
            child: Center(
              child: Text(
                riskTypes[col],
                style:
                    const TextStyle(fontSize: 10, fontWeight: FontWeight.bold),
                textAlign: TextAlign.center,
              ),
            ),
          );
        }

        final riskLevel = riskLevels[row - 1];
        final riskType = riskTypes[col];

        // Count assessments for this combination
        final count = riskAssessments
            .where((assessment) =>
                assessment.riskLevel == riskLevel &&
                assessment.riskType
                    .toLowerCase()
                    .contains(riskType.toLowerCase()))
            .length;

        Color cellColor;
        switch (riskLevel) {
          case 'Critical':
            cellColor = Colors.red;
            break;
          case 'High':
            cellColor = Colors.orange;
            break;
          case 'Medium':
            cellColor = Colors.yellow;
            break;
          default:
            cellColor = Colors.green;
        }

        return Container(
          decoration: BoxDecoration(
            color: cellColor.withValues(alpha: count > 0 ? 0.7 : 0.1),
            borderRadius: BorderRadius.circular(4),
            border: Border.all(color: cellColor),
          ),
          child: Center(
            child: Text(
              count.toString(),
              style: TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.bold,
                color: count > 0 ? Colors.white : cellColor,
              ),
            ),
          ),
        );
      },
    );
  }

  BarChartData _buildTrendChart(List<dynamic> trends) {
    return BarChartData(
      alignment: BarChartAlignment.spaceAround,
      maxY: trends.isNotEmpty
          ? trends
                  .map((e) => e.changePercentage.abs())
                  .reduce((a, b) => a > b ? a : b)
                  .toDouble() *
              1.2
          : 100,
      barTouchData: BarTouchData(
        enabled: true,
        touchTooltipData: BarTouchTooltipData(
          tooltipBgColor: Colors.blueGrey,
          getTooltipItem: (group, groupIndex, rod, rodIndex) {
            final trend = trends[groupIndex];
            return BarTooltipItem(
              '${trend.metric}\n${trend.changePercentage.toStringAsFixed(1)}%',
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
            reservedSize: 60,
            getTitlesWidget: (value, meta) {
              if (value.toInt() < trends.length) {
                return RotatedBox(
                  quarterTurns: 1,
                  child: Text(
                    trends[value.toInt()].metric,
                    style: const TextStyle(fontSize: 10),
                  ),
                );
              }
              return const Text('');
            },
          ),
        ),
        rightTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
        topTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
      ),
      borderData: FlBorderData(show: true),
      barGroups: trends.asMap().entries.map((entry) {
        final isPositive = entry.value.changePercentage >= 0;
        return BarChartGroupData(
          x: entry.key,
          barRods: [
            BarChartRodData(
              toY: entry.value.changePercentage.abs().toDouble(),
              color: isPositive ? Colors.green : Colors.red,
              width: 20,
            ),
          ],
        );
      }).toList(),
    );
  }

  Widget _buildRecommendationTile(dynamic recommendation) {
    Color priorityColor;
    IconData priorityIcon;

    switch (recommendation.priority.toLowerCase()) {
      case 'high':
        priorityColor = Colors.red;
        priorityIcon = Icons.priority_high;
        break;
      case 'medium':
        priorityColor = Colors.orange;
        priorityIcon = Icons.warning;
        break;
      default:
        priorityColor = Colors.blue;
        priorityIcon = Icons.info;
    }

    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        border: Border.all(color: Colors.grey[300]!),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(priorityIcon, color: priorityColor, size: 20),
              const SizedBox(width: 8),
              Expanded(
                child: Text(
                  recommendation.title,
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
              Chip(
                label: Text(recommendation.priority),
                backgroundColor: priorityColor.withValues(alpha: 0.2),
                labelStyle: TextStyle(color: priorityColor),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Text(
            recommendation.description,
            style: TextStyle(color: Colors.grey[700]),
          ),
          const SizedBox(height: 8),
          Row(
            children: [
              Text(
                'Category: ${recommendation.category ?? 'General'}',
                style: TextStyle(
                  fontSize: 12,
                  color: Colors.grey[600],
                ),
              ),
              const Spacer(),
              if (!recommendation.implemented)
                TextButton(
                  onPressed: () {
                    // Implement recommendation
                  },
                  child: const Text('Implement'),
                ),
            ],
          ),
        ],
      ),
    );
  }
}
