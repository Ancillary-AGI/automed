import 'package:flutter/material.dart';

// Medication card widget
class MedicationCard extends StatelessWidget {
  final dynamic medication;
  final Function(dynamic) onEdit;
  final Function(String) onDelete;
  final Function(String, bool) onToggleActive;

  const MedicationCard({
    super.key,
    required this.medication,
    required this.onEdit,
    required this.onDelete,
    required this.onToggleActive,
  });

  @override
  Widget build(BuildContext context) {
    // Extract medication data - using dynamic for now since medication structure is not defined
    final medicationName = medication['name'] ?? 'Unknown Medication';
    final dosage = medication['dosage'] ?? 'Unknown Dosage';
    final frequency = medication['frequency'] ?? 'Unknown Frequency';
    final isActive = medication['isActive'] ?? true;

    return Card(
      child: ListTile(
        title: Text(medicationName),
        subtitle: Text('$dosage • $frequency'),
        trailing: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Switch(
              value: isActive,
              onChanged: (value) =>
                  onToggleActive(medication['id'] ?? '', value),
            ),
            IconButton(
              icon: const Icon(Icons.edit),
              onPressed: () => onEdit(medication),
            ),
            IconButton(
              icon: const Icon(Icons.delete),
              onPressed: () => onDelete(medication['id'] ?? ''),
            ),
          ],
        ),
      ),
    );
  }
}
