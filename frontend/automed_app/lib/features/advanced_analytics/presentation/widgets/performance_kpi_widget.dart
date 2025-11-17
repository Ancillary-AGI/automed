import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:automed_app/features/advanced_analytics/presentation/providers/advanced_analytics_provider.dart';
import 'package:automed_app/features/advanced_analytics/domain/models/analytics_models.dart';

class PerformanceKpiWidget extends ConsumerWidget {
  const PerformanceKpiWidget({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final analyticsState = ref.watch(advancedAnalyticsProvider);

    return analyticsState.when(
      data: (data) => Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Performance KPIs',
            style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 16),

          // KPI Overview Cards
          GridView.count(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            crossAxisCount: 2,
            childAspectRatio: 1.5,
            crossAxisSpacing: 16,
            mainAxisSpacing: 16,
            children: [
              _buildKpiCard(
                'Patient Satisfaction',
                '${(data.performanceKpis.patientSatisfaction * 100).toInt()}%',
                Icons.sentiment_very_satisfied,
                Colors.green,
                data.performanceKpis.trends.firstWhere(
                  (t) => t.kpiName == 'Patient Satisfaction',
                  orElse: () => KpiTrend(
                    kpiName: 'Patient Satisfaction',
                    currentValue:
                        data.performanceKpis.patientSatisfaction * 100,
                    previousValue:
                        data.performanceKpis.patientSatisfaction * 100,
                    changePercentage: 0.0,
                    trendDirection: 'stable',
                    timeframe: 'current',
                  ),
                ),
              ),
              _buildKpiCard(
                'Staff Efficiency',
                '${(data.performanceKpis.staffEfficiency * 100).toInt()}%',
                Icons.trending_up,
                Colors.blue,
                data.performanceKpis.trends.firstWhere(
                  (t) => t.kpiName == 'Staff Efficiency',
                  orElse: () => KpiTrend(
                    kpiName: 'Staff Efficiency',
                    currentValue: data.performanceKpis.staffEfficiency * 100,
                    previousValue: data.performanceKpis.staffEfficiency * 100,
                    changePercentage: 0.0,
                    trendDirection: 'stable',
                    timeframe: 'current',
                  ),
                ),
              ),
              _buildKpiCard(
                'Cost per Patient',
                '\$${data.performanceKpis.costPerPatient.toInt()}',
                Icons.attach_money,
                Colors.orange,
                data.performanceKpis.trends.firstWhere(
                  (t) => t.kpiName == 'Cost per Patient',
                  orElse: () => KpiTrend(
                    kpiName: 'Cost per Patient',
                    currentValue: data.performanceKpis.costPerPatient,
                    previousValue: data.performanceKpis.costPerPatient,
                    changePercentage: 0.0,
                    trendDirection: 'stable',
                    timeframe: 'current',
                  ),
                ),
              ),
              _buildKpiCard(
                'Readmission Rate',
                '${(data.performanceKpis.readmissionRate * 100).toStringAsFixed(1)}%',
                Icons.refresh,
                Colors.red,
                data.performanceKpis.trends.firstWhere(
                  (t) => t.kpiName == 'Readmission Rate',
                  orElse: () => KpiTrend(
                    kpiName: 'Readmission Rate',
                    currentValue: data.performanceKpis.readmissionRate * 100,
                    previousValue: data.performanceKpis.readmissionRate * 100,
                    changePercentage: 0.0,
                    trendDirection: 'stable',
                    timeframe: 'current',
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 24),

          // KPI Trends Chart
          Card(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'KPI Trends Over Time',
                    style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
                  ),
                  const SizedBox(height: 16),
                  SizedBox(
                    height: 250,
                    child: LineChart(
                      _buildKpiTrendsChart(data.performanceKpis.trends),
                    ),
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 16),

          // Benchmarking
          Card(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Industry Benchmarking',
                    style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
                  ),
                  const SizedBox(height: 16),
                  ...data.performanceKpis.benchmarks.map(
                    (benchmark) => _buildBenchmarkRow(benchmark),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
      loading: () => const Center(child: CircularProgressIndicator()),
      error: (error, stack) => Center(
        child: Text('Error loading performance KPIs: $error'),
      ),
    );
  }

  Widget _buildKpiCard(
    String title,
    String value,
    IconData icon,
    Color color,
    dynamic trend,
  ) {
    final trendValue = trend?.changePercentage ?? 0.0;
    final isPositive = trendValue >= 0;
    final trendColor = isPositive ? Colors.green : Colors.red;
    final trendIcon = isPositive ? Icons.arrow_upward : Icons.arrow_downward;

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
                if (trend != null)
                  Container(
                    padding:
                        const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                    decoration: BoxDecoration(
                      color: trendColor.withValues(alpha: 0.1),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(trendIcon, color: trendColor, size: 12),
                        const SizedBox(width: 4),
                        Text(
                          '${trendValue.abs().toStringAsFixed(1)}%',
                          style: TextStyle(
                            color: trendColor,
                            fontWeight: FontWeight.bold,
                            fontSize: 12,
                          ),
                        ),
                      ],
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

  LineChartData _buildKpiTrendsChart(List<dynamic> trends) {
    final colors = [
      Colors.blue,
      Colors.green,
      Colors.orange,
      Colors.red,
      Colors.purple
    ];

    return LineChartData(
      gridData: const FlGridData(show: true),
      titlesData: FlTitlesData(
        leftTitles: AxisTitles(
          sideTitles: SideTitles(
            showTitles: true,
            reservedSize: 50,
            getTitlesWidget: (value, meta) {
              return Text('${value.toInt()}%');
            },
          ),
        ),
        bottomTitles: AxisTitles(
          sideTitles: SideTitles(
            showTitles: true,
            reservedSize: 30,
            getTitlesWidget: (value, meta) {
              return Text('W${value.toInt()}');
            },
          ),
        ),
        rightTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
        topTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
      ),
      borderData: FlBorderData(show: true),
      lineBarsData: trends.asMap().entries.map((entry) {
        final color = colors[entry.key % colors.length];

        return LineChartBarData(
          spots: List.generate(12, (index) {
            // Generate sample trend data
            final baseValue = entry.value.currentValue;
            final variation = (index - 6) * 2;
            return FlSpot(
                index.toDouble(), (baseValue + variation).clamp(0, 100));
          }),
          isCurved: true,
          color: color,
          barWidth: 3,
          dotData: const FlDotData(show: false),
        );
      }).toList(),
    );
  }

  Widget _buildBenchmarkRow(dynamic benchmark) {
    final ourValue = benchmark.ourValue;
    final industryAvg = benchmark.industryAverage;
    final bestPractice = benchmark.bestPractice;

    final ourPercentage = (ourValue / bestPractice).clamp(0.0, 1.0);
    final industryPercentage = (industryAvg / bestPractice).clamp(0.0, 1.0);

    Color performanceColor;
    if (ourValue >= bestPractice * 0.9) {
      performanceColor = Colors.green;
    } else if (ourValue >= industryAvg) {
      performanceColor = Colors.orange;
    } else {
      performanceColor = Colors.red;
    }

    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Expanded(
                child: Text(
                  benchmark.metric,
                  style: const TextStyle(fontWeight: FontWeight.w600),
                ),
              ),
              Text(
                '${ourValue.toStringAsFixed(1)}${benchmark.unit ?? ''}',
                style: TextStyle(
                  color: performanceColor,
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
                widthFactor: industryPercentage,
                child: Container(
                  height: 8,
                  decoration: BoxDecoration(
                    color: Colors.grey[400],
                    borderRadius: BorderRadius.circular(4),
                  ),
                ),
              ),
              FractionallySizedBox(
                widthFactor: ourPercentage,
                child: Container(
                  height: 8,
                  decoration: BoxDecoration(
                    color: performanceColor,
                    borderRadius: BorderRadius.circular(4),
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 4),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Industry Avg: ${industryAvg.toStringAsFixed(1)}${benchmark.unit ?? ''}',
                style: TextStyle(fontSize: 12, color: Colors.grey[600]),
              ),
              Text(
                'Best Practice: ${bestPractice.toStringAsFixed(1)}${benchmark.unit ?? ''}',
                style: TextStyle(fontSize: 12, color: Colors.grey[600]),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
