import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:fl_chart/fl_chart.dart';

class MobileVitalsMonitor extends ConsumerWidget {
  const MobileVitalsMonitor({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                const Text(
                  'Vital Signs Monitor',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const Spacer(),
                TextButton(
                  onPressed: () => Navigator.pushNamed(context, '/vitals-monitor'),
                  child: const Text('Full View'),
                ),
              ],
            ),
            const SizedBox(height: 16),
            
            // Vital signs summary
            Row(
              children: [
                Expanded(
                  child: _buildVitalCard('Heart Rate', '72', 'bpm', Colors.red, Icons.favorite),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: _buildVitalCard('Blood Pressure', '120/80', 'mmHg', Colors.blue, Icons.bloodtype),
                ),
              ],
            ),
            const SizedBox(height: 12),
            Row(
              children: [
                Expanded(
                  child: _buildVitalCard('Temperature', '98.6', '°F', Colors.orange, Icons.thermostat),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: _buildVitalCard('Oxygen', '98', '%', Colors.green, Icons.air),
                ),
              ],
            ),
            const SizedBox(height: 16),
            
            // Mini chart
            SizedBox(
              height: 100,
              child: LineChart(
                LineChartData(
                  gridData: FlGridData(show: false),
                  titlesData: FlTitlesData(show: false),
                  borderData: FlBorderData(show: false),
                  lineBarsData: [
                    LineChartBarData(
                      spots: _generateSampleData(),
                      isCurved: true,
                      color: Colors.red,
                      barWidth: 2,
                      dotData: FlDotData(show: false),
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

  Widget _buildVitalCard(String title, String value, String unit, Color color, IconData icon) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: color.withOpacity(0.3)),
      ),
      child: Column(
        children: [
          Icon(icon, color: color, size: 20),
          const SizedBox(height: 4),
          Text(
            value,
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.bold,
              color: color,
            ),
          ),
          Text(
            unit,
            style: TextStyle(
              fontSize: 10,
              color: color,
            ),
          ),
          Text(
            title,
            style: const TextStyle(
              fontSize: 10,
              color: Colors.grey,
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

  List<FlSpot> _generateSampleData() {
    return List.generate(20, (index) {
      return FlSpot(
        index.toDouble(),
        60 + (index % 5) * 5 + (index % 3) * 2,
      );
    });
  }
}