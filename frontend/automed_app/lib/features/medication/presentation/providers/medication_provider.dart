import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

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

  factory MedicationHistoryEntry.fromJson(Map<String, dynamic> json) {
    return MedicationHistoryEntry(
      id: json['id'],
      medicationName: json['medicationName'],
      dosage: json['dosage'],
      scheduledTime: DateTime.parse(json['scheduledTime']),
      date: DateTime.parse(json['date']),
      status: json['status'],
      notes: json['notes'],
    );
  }
}

// Medication model
class Medication {
  final String id;
  final String name;
  final String dosage;
  final List<String> schedule;
  final bool isActive;
  final DateTime createdAt;

  Medication({
    required this.id,
    required this.name,
    required this.dosage,
    required this.schedule,
    this.isActive = true,
    DateTime? createdAt,
  }) : createdAt = createdAt ?? DateTime.now();

  factory Medication.fromJson(Map<String, dynamic> json) {
    return Medication(
      id: json['id'],
      name: json['name'],
      dosage: json['dosage'],
      schedule: List<String>.from(json['schedule'] ?? []),
      isActive: json['isActive'] ?? true,
      createdAt: json['createdAt'] != null
          ? DateTime.parse(json['createdAt'])
          : DateTime.now(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'dosage': dosage,
      'schedule': schedule,
      'isActive': isActive,
      'createdAt': createdAt.toIso8601String(),
    };
  }
}

// Medication schedule entry
class MedicationSchedule {
  final String id;
  final String medicationId;
  final DateTime scheduledTime;
  final bool isTaken;
  final bool isSkipped;

  MedicationSchedule({
    required this.id,
    required this.medicationId,
    required this.scheduledTime,
    this.isTaken = false,
    this.isSkipped = false,
  });

  factory MedicationSchedule.fromJson(Map<String, dynamic> json) {
    return MedicationSchedule(
      id: json['id'],
      medicationId: json['medicationId'],
      scheduledTime: DateTime.parse(json['scheduledTime']),
      isTaken: json['isTaken'] ?? false,
      isSkipped: json['isSkipped'] ?? false,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'medicationId': medicationId,
      'scheduledTime': scheduledTime.toIso8601String(),
      'isTaken': isTaken,
      'isSkipped': isSkipped,
    };
  }
}

// Providers
final medicationsProvider =
    StateNotifierProvider<MedicationsNotifier, AsyncValue<List<Medication>>>(
        (ref) {
  return MedicationsNotifier();
});

final medicationSchedulesProvider = StateNotifierProvider<
    MedicationSchedulesNotifier, List<MedicationSchedule>>((ref) {
  return MedicationSchedulesNotifier();
});

final medicationProvider =
    StateNotifierProvider<MedicationNotifier, AsyncValue<String>>((ref) {
  return MedicationNotifier();
});

class MedicationsNotifier extends StateNotifier<AsyncValue<List<Medication>>> {
  MedicationsNotifier() : super(const AsyncValue.data([]));

  void addMedication(Medication medication) {
    state = state.whenData((medications) => [...medications, medication]);
  }

  void removeMedication(String medicationId) {
    state = state.whenData((medications) =>
        medications.where((med) => med.id != medicationId).toList());
  }

  void toggleMedication(String medicationId, bool isActive) {
    state = state.whenData((medications) => medications.map((med) {
          if (med.id == medicationId) {
            return Medication(
              id: med.id,
              name: med.name,
              dosage: med.dosage,
              schedule: med.schedule,
              isActive: isActive,
              createdAt: med.createdAt,
            );
          }
          return med;
        }).toList());
  }
}

class MedicationSchedulesNotifier
    extends StateNotifier<List<MedicationSchedule>> {
  MedicationSchedulesNotifier() : super([]);

  void addSchedule(MedicationSchedule schedule) {
    state = [...state, schedule];
  }

  void markAsTaken(String scheduleId) {
    state = state.map((schedule) {
      if (schedule.id == scheduleId) {
        return MedicationSchedule(
          id: schedule.id,
          medicationId: schedule.medicationId,
          scheduledTime: schedule.scheduledTime,
          isTaken: true,
          isSkipped: false,
        );
      }
      return schedule;
    }).toList();
  }

  void markAsSkipped(String scheduleId) {
    state = state.map((schedule) {
      if (schedule.id == scheduleId) {
        return MedicationSchedule(
          id: schedule.id,
          medicationId: schedule.medicationId,
          scheduledTime: schedule.scheduledTime,
          isTaken: false,
          isSkipped: true,
        );
      }
      return schedule;
    }).toList();
  }
}

class MedicationNotifier extends StateNotifier<AsyncValue<String>> {
  MedicationNotifier() : super(const AsyncValue.data(''));

  Future<void> markScheduleAsTaken(String scheduleId) async {
    state = const AsyncValue.loading();
    try {
      final response = await http.put(
        Uri.parse('$_baseUrl/medications/schedules/$scheduleId/taken'),
        headers: {'Content-Type': 'application/json'},
      );

      if (response.statusCode == 200) {
        state = const AsyncValue.data('Schedule marked as taken');
      } else {
        throw Exception('Failed to mark schedule as taken');
      }
    } catch (e) {
      state = AsyncValue.error(e, StackTrace.current);
    }
  }

  Future<void> markScheduleAsSkipped(String scheduleId) async {
    state = const AsyncValue.loading();
    try {
      final response = await http.put(
        Uri.parse('$_baseUrl/medications/schedules/$scheduleId/skipped'),
        headers: {'Content-Type': 'application/json'},
      );

      if (response.statusCode == 200) {
        state = const AsyncValue.data('Schedule marked as skipped');
      } else {
        throw Exception('Failed to mark schedule as skipped');
      }
    } catch (e) {
      state = AsyncValue.error(e, StackTrace.current);
    }
  }

  Future<void> deleteMedication(String medicationId) async {
    state = const AsyncValue.loading();
    try {
      final response = await http.delete(
        Uri.parse('$_baseUrl/medications/$medicationId'),
        headers: {'Content-Type': 'application/json'},
      );

      if (response.statusCode == 204) {
        state = const AsyncValue.data('Medication deleted');
      } else {
        throw Exception('Failed to delete medication');
      }
    } catch (e) {
      state = AsyncValue.error(e, StackTrace.current);
    }
  }

  Future<void> toggleMedicationActive(
      String medicationId, bool isActive) async {
    state = const AsyncValue.loading();
    try {
      final response = await http.put(
        Uri.parse('$_baseUrl/medications/$medicationId/active'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({'isActive': isActive}),
      );

      if (response.statusCode == 200) {
        state = const AsyncValue.data('Medication status updated');
      } else {
        throw Exception('Failed to update medication status');
      }
    } catch (e) {
      state = AsyncValue.error(e, StackTrace.current);
    }
  }
}

final medicationSyncProvider =
    StateNotifierProvider<MedicationSyncNotifier, AsyncValue<bool>>((ref) {
  return MedicationSyncNotifier();
});

class MedicationSyncNotifier extends StateNotifier<AsyncValue<bool>> {
  MedicationSyncNotifier() : super(const AsyncValue.data(false));

  Future<void> syncMedications() async {
    state = const AsyncValue.loading();
    try {
      final response = await http.post(
        Uri.parse('$_baseUrl/medications/sync'),
        headers: {'Content-Type': 'application/json'},
      );

      if (response.statusCode == 200) {
        state = const AsyncValue.data(true);
      } else {
        throw Exception('Failed to sync medications');
      }
    } catch (e) {
      state = AsyncValue.error(e, StackTrace.current);
    }
  }
}

const String _baseUrl = 'http://localhost:8080/api/v1';

final todayMedicationScheduleProvider =
    FutureProvider<List<MedicationSchedule>>((ref) async {
  try {
    final response = await http.get(
      Uri.parse('$_baseUrl/medications/schedules/today'),
      headers: {'Content-Type': 'application/json'},
    );

    if (response.statusCode == 200) {
      final List<dynamic> data = jsonDecode(response.body);
      return data.map((json) => MedicationSchedule.fromJson(json)).toList();
    } else {
      throw Exception('Failed to load medication schedule');
    }
  } catch (e) {
    // Return empty list on error to prevent crashes
    return [];
  }
});

final medicationHistoryProvider =
    FutureProvider<List<MedicationHistoryEntry>>((ref) async {
  try {
    final response = await http.get(
      Uri.parse('$_baseUrl/medications/history'),
      headers: {'Content-Type': 'application/json'},
    );

    if (response.statusCode == 200) {
      final List<dynamic> data = jsonDecode(response.body);
      return data.map((json) => MedicationHistoryEntry.fromJson(json)).toList();
    } else {
      throw Exception('Failed to load medication history');
    }
  } catch (e) {
    // Return empty list on error to prevent crashes
    return [];
  }
});
