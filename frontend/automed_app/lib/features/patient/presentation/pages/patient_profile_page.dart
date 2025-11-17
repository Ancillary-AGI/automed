import 'package:flutter/material.dart';

class PatientProfilePage extends StatelessWidget {
  final String? patientId;
  
  const PatientProfilePage({super.key, this.patientId});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Patient Profile'),
      ),
      body: const Center(
        child: Text('Patient Profile Page'),
      ),
    );
  }
}
