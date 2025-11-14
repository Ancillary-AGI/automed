import 'package:flutter/material.dart';

// Minimal add medication dialog stub
class AddMedicationDialog extends StatelessWidget {
  const AddMedicationDialog({super.key});

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Text('Add Medication'),
      content: const Text('Form placeholder'),
      actions: [
        TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('Close')),
      ],
    );
  }
}
