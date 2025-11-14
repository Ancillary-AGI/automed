import 'package:flutter/material.dart';

// Minimal emergency alerts card stub
class EmergencyAlertsCard extends StatelessWidget {
  final int activeAlerts;

  const EmergencyAlertsCard({super.key, this.activeAlerts = 0});

  @override
  Widget build(BuildContext context) {
    return Card(
      child: ListTile(
        title: const Text('Emergency Alerts'),
        subtitle: Text('Active: $activeAlerts'),
      ),
    );
  }
}
