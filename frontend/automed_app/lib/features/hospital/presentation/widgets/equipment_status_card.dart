import 'package:flutter/material.dart';

// Minimal equipment status card stub
class EquipmentStatusCard extends StatelessWidget {
  final int operational;
  final int total;

  const EquipmentStatusCard({super.key, this.operational = 0, this.total = 0});

  @override
  Widget build(BuildContext context) {
    return Card(
      child: ListTile(
        title: const Text('Equipment Status'),
        subtitle: Text('Operational: $operational / $total'),
      ),
    );
  }
}
