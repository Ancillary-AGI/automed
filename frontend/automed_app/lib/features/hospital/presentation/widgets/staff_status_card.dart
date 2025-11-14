import 'package:flutter/material.dart';

// Minimal staff status card stub
class StaffStatusCard extends StatelessWidget {
  final int onDuty;
  final int total;

  const StaffStatusCard({super.key, this.onDuty = 0, this.total = 0});

  @override
  Widget build(BuildContext context) {
    return Card(
      child: ListTile(
        title: const Text('Staff Status'),
        subtitle: Text('On duty: $onDuty / $total'),
      ),
    );
  }
}
