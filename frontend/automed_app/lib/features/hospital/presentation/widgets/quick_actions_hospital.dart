import 'package:flutter/material.dart';

// Minimal quick actions for hospital dashboard
class QuickActionsHospital extends StatelessWidget {
  const QuickActionsHospital({super.key});

  @override
  Widget build(BuildContext context) {
    return Wrap(
      spacing: 8,
      children: [
        ElevatedButton(onPressed: () {}, child: const Text('Action 1')),
        ElevatedButton(onPressed: () {}, child: const Text('Action 2')),
      ],
    );
  }
}
