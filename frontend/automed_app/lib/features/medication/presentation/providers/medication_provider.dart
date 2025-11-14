import 'package:flutter_riverpod/flutter_riverpod.dart';

// Medication history entry model
class MedicationHistoryEntry {
  final String id;
  final String medicationName;
  final String dosage;
  final DateTime scheduledTime;
  final DateTime date;
  final String status;
  final String? notes;

  MedicationHistoryEntry({
    required this.id,
    required this.medicationName,
    required this.dosage,
    required this.scheduledTime,
    required this.date,
    required this.status,
    this.notes,
  });
}

// Minimal medication provider stubs
final medicationsProvider = FutureProvider<List<String>>((ref) async {
  return [];
});

final medicationProvider =
    StateNotifierProvider<MedicationNotifier, AsyncValue<String>>((ref) {
  return MedicationNotifier();
});

class MedicationNotifier extends StateNotifier<AsyncValue<String>> {
  MedicationNotifier() : super(const AsyncValue.data(''));

  void markScheduleAsTaken(String scheduleId) {
    // TODO: Implement
  }

  void markScheduleAsSkipped(String scheduleId) {
    // TODO: Implement
  }

  void deleteMedication(String medicationId) {
    // TODO: Implement
  }

  void toggleMedicationActive(String medicationId, bool isActive) {
    // TODO: Implement
  }
}

final medicationSyncProvider =
    StateNotifierProvider<MedicationSyncNotifier, AsyncValue<bool>>((ref) {
  return MedicationSyncNotifier();
});

class MedicationSyncNotifier extends StateNotifier<AsyncValue<bool>> {
  MedicationSyncNotifier() : super(const AsyncValue.data(false));

  void syncMedications() {
    // TODO: Implement
  }
}

final todayMedicationScheduleProvider =
    FutureProvider<List<String>>((ref) async {
  return [];
});

final medicationHistoryProvider =
    FutureProvider<List<MedicationHistoryEntry>>((ref) async {
  return [];
});
