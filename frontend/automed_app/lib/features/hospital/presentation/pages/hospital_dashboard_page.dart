import 'package:flutter/material.dart';

class HospitalDashboardPage extends StatelessWidget {
  const HospitalDashboardPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Hospital Dashboard'),
      ),
      body: const Center(
        child: Text('Hospital Dashboard Page'),
      ),
    );
  }
}