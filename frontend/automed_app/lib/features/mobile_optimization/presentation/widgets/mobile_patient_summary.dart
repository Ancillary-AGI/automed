import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class MobilePatientSummary extends ConsumerWidget {
  const MobilePatientSummary({super.key});

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
                  'Patient Summary',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const Spacer(),
                TextButton(
                  onPressed: () => Navigator.pushNamed(context, '/patients'),
                  child: const Text('View All'),
                ),
              ],
            ),
            const SizedBox(height: 16),

            // Recent patients
            ...List.generate(
                3,
                (index) => _buildPatientTile(
                      context,
                      'Patient ${index + 1}',
                      'Last visit: ${DateTime.now().subtract(Duration(days: index + 1)).toString().substring(0, 10)}',
                      _getStatusColor(index),
                      () => Navigator.pushNamed(context, '/patient-details',
                          arguments: 'patient_${index + 1}'),
                    )),
          ],
        ),
      ),
    );
  }

  Widget _buildPatientTile(
    BuildContext context,
    String name,
    String subtitle,
    Color statusColor,
    VoidCallback onTap,
  ) {
    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      child: ListTile(
        leading: CircleAvatar(
          backgroundColor: statusColor.withValues(alpha: 0.2),
          child: Icon(Icons.person, color: statusColor),
        ),
        title: Text(name),
        subtitle: Text(subtitle),
        trailing: Icon(Icons.chevron_right, color: Colors.grey[400]),
        onTap: onTap,
      ),
    );
  }

  Color _getStatusColor(int index) {
    switch (index % 3) {
      case 0:
        return Colors.green;
      case 1:
        return Colors.orange;
      default:
        return Colors.blue;
    }
  }
}
