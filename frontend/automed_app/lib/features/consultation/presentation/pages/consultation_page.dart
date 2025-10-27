import 'package:flutter/material.dart';

class ConsultationPage extends StatelessWidget {
  final String consultationId;
  
  const ConsultationPage({super.key, required this.consultationId});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Consultation'),
      ),
      body: Center(
        child: Text('Consultation Page - ID: $consultationId'),
      ),
    );
  }
}