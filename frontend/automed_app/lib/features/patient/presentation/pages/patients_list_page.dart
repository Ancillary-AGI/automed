import 'package:flutter/material.dart';

class PatientsListPage extends StatelessWidget {
  const PatientsListPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Patients'),
      ),
      body: const Center(
        child: Text('Patients List Page'),
      ),
    );
  }
}
