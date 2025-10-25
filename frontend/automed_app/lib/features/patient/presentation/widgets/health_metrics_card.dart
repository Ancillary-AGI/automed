import 'package:flutter/material.dart';

import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_text_styles.dart';
import '../models/patient_dashboard_model.dart';

class HealthMetricsCard extends StatelessWidget {
  final HealthMetrics metrics;

  const HealthMetricsCard({super.key, required this.metrics});

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 4,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(Icons.favorite, color: AppColors.primary),
                const SizedBox(width: 8),
                Text('Health Metrics', style: AppTextStyles.titleMedium),
              ],
            ),
            const SizedBox(height: 16),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                _MetricItem(
                  label: 'Heart Rate',
                  value: '${metrics.heartRate.toStringAsFixed(0)} bpm',
                  icon: Icons.favorite_border,
                  color: Colors.red,
                ),
                _MetricItem(
                  label: 'Blood Pressure',
                  value: '${metrics.bloodPressure.toStringAsFixed(0)} mmHg',
                  icon: Icons.speed,
                  color: Colors.blue,
                ),
                _MetricItem(
                  label: 'Temperature',
                  value: '${metrics.temperature.toStringAsFixed(1)}°C',
                  icon: Icons.thermostat,
                  color: Colors.orange,
                ),
                _MetricItem(
                  label: 'Oxygen',
                  value: '${metrics.oxygenSaturation.toStringAsFixed(0)}%',
                  icon: Icons.air,
                  color: Colors.green,
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

class _MetricItem extends StatelessWidget {
  final String label;
  final String value;
  final IconData icon;
  final Color color;

  const _MetricItem({
    required this.label,
    required this.value,
    required this.icon,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Icon(icon, color: color, size: 32),
        const SizedBox(height: 8),
        Text(
          value,
          style: AppTextStyles.bodyLarge.copyWith(fontWeight: FontWeight.bold),
        ),
        Text(
          label,
          style: AppTextStyles.bodySmall.copyWith(color: Colors.grey[600]),
        ),
      ],
    );
  }
}
