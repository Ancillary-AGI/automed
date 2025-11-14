import 'package:flutter/material.dart';

// Minimal suggestions panel stub
class AISuggestionsPanel extends StatelessWidget {
  final List<String> suggestions;

  const AISuggestionsPanel({super.key, this.suggestions = const []});

  @override
  Widget build(BuildContext context) {
    if (suggestions.isEmpty) return const SizedBox.shrink();
    return Wrap(
      spacing: 8,
      children: suggestions.map((s) => Chip(label: Text(s))).toList(),
    );
  }
}
