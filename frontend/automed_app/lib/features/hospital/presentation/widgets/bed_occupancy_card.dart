import 'package:flutter/material.dart';

// Minimal bed occupancy card stub
class BedOccupancyCard extends StatelessWidget {
  final int occupied;
  final int total;

  const BedOccupancyCard({super.key, this.occupied = 0, this.total = 0});

  @override
  Widget build(BuildContext context) {
    return Card(
      child: ListTile(
        title: const Text('Bed Occupancy'),
        subtitle: Text('$occupied / $total'),
      ),
    );
  }
}
