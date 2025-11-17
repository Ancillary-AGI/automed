import 'package:flutter/material.dart';

class ConsultationsListPage extends StatelessWidget {
  const ConsultationsListPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Consultations'),
      ),
      body: const Center(
        child: Text('Consultations List Page'),
      ),
    );
  }
}
