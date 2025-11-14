import 'package:flutter/material.dart';

// Minimal emergency button stub
class EmergencyButton extends StatelessWidget {
  final VoidCallback? onPressed;

  const EmergencyButton({super.key, this.onPressed});

  @override
  Widget build(BuildContext context) {
    return ElevatedButton.icon(
      onPressed: onPressed ?? () {},
      icon: const Icon(Icons.emergency),
      label: const Text('Emergency'),
      style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
    );
  }
}
