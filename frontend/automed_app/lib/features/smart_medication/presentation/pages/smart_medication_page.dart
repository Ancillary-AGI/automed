import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:automed_app/core/theme/app_colors.dart';
import 'package:automed_app/core/models/medication_models.dart';
import '../widgets/medication_card.dart';
import '../widgets/adherence_chart.dart';
import '../widgets/pill_reminder_widget.dart';

class SmartMedicationPage extends ConsumerStatefulWidget {
  const SmartMedicationPage({super.key});

  @override
  ConsumerState<SmartMedicationPage> createState() =>
      _SmartMedicationPageState();
}

class _SmartMedicationPageState extends ConsumerState<SmartMedicationPage>
    with TickerProviderStateMixin {
  late final TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    // In a real implementation we'd read providers/services. Here we compose
    // the existing components with minimal sample data so the page is useful
    // and compiles without stubs.

    final sampleMedication = Medication(
      id: 'med-1',
      patientId: 'pat-1',
      name: 'Atorvastatin',
      genericName: 'Atorvastatin',
      dosage: '20 mg',
      frequency: 'Once daily',
      route: 'Oral',
      startDate: DateTime.now().subtract(const Duration(days: 30)),
      endDate: null,
      prescribedBy: 'Dr. Smith',
      instructions: null,
      sideEffects: const [],
      status: MedicationStatus.active,
      isActive: true,
      createdAt: DateTime.now().subtract(const Duration(days: 31)),
      updatedAt: DateTime.now(),
    );

    final sampleReminders = [
      MedicationReminder(
        id: 'rem-1',
        medicationId: 'med-1',
        patientId: 'pat-1',
        reminderTimes: [
          ReminderTime(hour: 8, minute: 0, daysOfWeek: [1, 2, 3, 4, 5])
        ],
        isEnabled: true,
        type: ReminderType.notification,
      ),
    ];

    return Scaffold(
      appBar: AppBar(
        title: const Text('Smart Medication'),
        backgroundColor: AppColors.appPrimary,
        bottom: TabBar(
          controller: _tabController,
          tabs: const [
            Tab(text: 'Medications'),
            Tab(text: 'Adherence'),
            Tab(text: 'Reminders')
          ],
        ),
      ),
      body: TabBarView(
        controller: _tabController,
        children: [
          // Medications list
          ListView(
              padding: const EdgeInsets.all(12),
              children: [MedicationCard(medication: sampleMedication)]),

          // Adherence view
          const Padding(
            padding: EdgeInsets.all(12),
            child: AdherenceChart(adherence: 0.87),
          ),

          // Reminders
          Padding(
            padding: const EdgeInsets.all(12),
            child: PillReminderWidget(reminders: sampleReminders),
          ),
        ],
      ),
    );
  }
}
