import 'package:flutter/material.dart';

// Minimal emergency contacts list stub
class EmergencyContactsList extends StatelessWidget {
  final List<String> contacts;

  const EmergencyContactsList({super.key, this.contacts = const []});

  @override
  Widget build(BuildContext context) {
    if (contacts.isEmpty) return const SizedBox.shrink();
    return Column(
      children: contacts.map((c) => ListTile(title: Text(c))).toList(),
    );
  }
}
