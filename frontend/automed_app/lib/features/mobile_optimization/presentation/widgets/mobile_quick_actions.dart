import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class MobileQuickActions extends ConsumerWidget {
  const MobileQuickActions({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Quick Actions',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 16),
            GridView.count(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              crossAxisCount: 3,
              childAspectRatio: 1,
              crossAxisSpacing: 12,
              mainAxisSpacing: 12,
              children: [
                _buildQuickAction(
                  context,
                  'Emergency',
                  Icons.emergency,
                  Colors.red,
                  () => Navigator.pushNamed(context, '/emergency'),
                ),
                _buildQuickAction(
                  context,
                  'Call Doctor',
                  Icons.phone,
                  Colors.green,
                  () => _callDoctor(context),
                ),
                _buildQuickAction(
                  context,
                  'Medications',
                  Icons.medication,
                  Colors.blue,
                  () => Navigator.pushNamed(context, '/medications'),
                ),
                _buildQuickAction(
                  context,
                  'Vitals',
                  Icons.favorite,
                  Colors.pink,
                  () => Navigator.pushNamed(context, '/vitals'),
                ),
                _buildQuickAction(
                  context,
                  'AI Assistant',
                  Icons.smart_toy,
                  Colors.purple,
                  () => Navigator.pushNamed(context, '/ai-assistant'),
                ),
                _buildQuickAction(
                  context,
                  'Appointments',
                  Icons.calendar_today,
                  Colors.orange,
                  () => Navigator.pushNamed(context, '/appointments'),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildQuickAction(
    BuildContext context,
    String title,
    IconData icon,
    Color color,
    VoidCallback onTap,
  ) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(12),
      child: Container(
        decoration: BoxDecoration(
          color: color.withOpacity(0.1),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: color.withOpacity(0.3)),
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icon, color: color, size: 32),
            const SizedBox(height: 8),
            Text(
              title,
              style: TextStyle(
                color: color,
                fontSize: 12,
                fontWeight: FontWeight.w600,
              ),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }

  void _callDoctor(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Call Doctor'),
        content: const Text('Would you like to call your primary care physician?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(context);
              // Implement actual phone call
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('Calling doctor...')),
              );
            },
            child: const Text('Call'),
          ),
        ],
      ),
    );
  }
}
