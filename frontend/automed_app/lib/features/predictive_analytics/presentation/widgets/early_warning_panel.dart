import 'package:flutter/material.dart';

class EarlyWarningCard extends StatelessWidget {
  final dynamic warning;
  final VoidCallback? onTap;

  const EarlyWarningCard({super.key, required this.warning, this.onTap});

  @override
  Widget build(BuildContext context) {
    return Card(
      child: ListTile(
        title: Text(warning?.message ?? 'Warning'),
        subtitle: Text(warning?.patientId ?? ''),
        onTap: onTap,
      ),
    );
  }
}
