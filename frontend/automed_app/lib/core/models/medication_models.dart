import 'package:json_annotation/json_annotation.dart';

part 'medication_models.g.dart';

@JsonSerializable()
class Medication {
  final String id;
  final String patientId;
  final String name;
  final String genericName;
  final String dosage;
  final String frequency;
  final String route;
  final DateTime startDate;
  final DateTime? endDate;
  final String prescribedBy;
  final String? instructions;
  final List<String> sideEffects;
  final MedicationStatus status;
  final bool isActive;
  final DateTime createdAt;
  final DateTime updatedAt;

  Medication({
    required this.id,
    required this.patientId,
    required this.name,
    required this.genericName,
    required this.dosage,
    required this.frequency,
    required this.route,
    required this.startDate,
    this.endDate,
    required this.prescribedBy,
    this.instructions,
    required this.sideEffects,
    required this.status,
    required this.isActive,
    required this.createdAt,
    required this.updatedAt,
  });

  factory Medication.fromJson(Map<String, dynamic> json) => 
      _$MedicationFromJson(json);
  Map<String, dynamic> toJson() => _$MedicationToJson(this);

  bool get isExpired => endDate != null && DateTime.now().isAfter(endDate!);
}

@JsonSerializable()
class MedicationLog {
  final String id;
  final String medicationId;
  final String patientId;
  final DateTime scheduledTime;
  final DateTime? takenTime;
  final MedicationLogStatus status;
  final String? notes;
  final Map<String, dynamic>? metadata;

  MedicationLog({
    required this.id,
    required this.medicationId,
    required this.patientId,
    required this.scheduledTime,
    this.takenTime,
    required this.status,
    this.notes,
    this.metadata,
  });

  factory MedicationLog.fromJson(Map<String, dynamic> json) => 
      _$MedicationLogFromJson(json);
  Map<String, dynamic> toJson() => _$MedicationLogToJson(this);

  bool get isMissed => status == MedicationLogStatus.missed;
  bool get isTaken => status == MedicationLogStatus.taken;
  bool get isPending => status == MedicationLogStatus.pending;
}

@JsonSerializable()
class CreateMedicationRequest {
  final String patientId;
  final String name;
  final String genericName;
  final String dosage;
  final String frequency;
  final String route;
  final DateTime startDate;
  final DateTime? endDate;
  final String prescribedBy;
  final String? instructions;
  final List<String> sideEffects;

  CreateMedicationRequest({
    required this.patientId,
    required this.name,
    required this.genericName,
    required this.dosage,
    required this.frequency,
    required this.route,
    required this.startDate,
    this.endDate,
    required this.prescribedBy,
    this.instructions,
    required this.sideEffects,
  });

  factory CreateMedicationRequest.fromJson(Map<String, dynamic> json) => 
      _$CreateMedicationRequestFromJson(json);
  Map<String, dynamic> toJson() => _$CreateMedicationRequestToJson(this);
}

@JsonSerializable()
class UpdateMedicationRequest {
  final String? name;
  final String? genericName;
  final String? dosage;
  final String? frequency;
  final String? route;
  final DateTime? startDate;
  final DateTime? endDate;
  final String? prescribedBy;
  final String? instructions;
  final List<String>? sideEffects;
  final MedicationStatus? status;
  final bool? isActive;

  UpdateMedicationRequest({
    this.name,
    this.genericName,
    this.dosage,
    this.frequency,
    this.route,
    this.startDate,
    this.endDate,
    this.prescribedBy,
    this.instructions,
    this.sideEffects,
    this.status,
    this.isActive,
  });

  factory UpdateMedicationRequest.fromJson(Map<String, dynamic> json) => 
      _$UpdateMedicationRequestFromJson(json);
  Map<String, dynamic> toJson() => _$UpdateMedicationRequestToJson(this);
}

@JsonSerializable()
class MedicationReminder {
  final String id;
  final String medicationId;
  final String patientId;
  final List<ReminderTime> reminderTimes;
  final bool isEnabled;
  final ReminderType type;
  final Map<String, dynamic>? settings;

  MedicationReminder({
    required this.id,
    required this.medicationId,
    required this.patientId,
    required this.reminderTimes,
    required this.isEnabled,
    required this.type,
    this.settings,
  });

  factory MedicationReminder.fromJson(Map<String, dynamic> json) => 
      _$MedicationReminderFromJson(json);
  Map<String, dynamic> toJson() => _$MedicationReminderToJson(this);
}

@JsonSerializable()
class ReminderTime {
  final int hour;
  final int minute;
  final List<int> daysOfWeek; // 1-7, Monday-Sunday

  ReminderTime({
    required this.hour,
    required this.minute,
    required this.daysOfWeek,
  });

  factory ReminderTime.fromJson(Map<String, dynamic> json) => 
      _$ReminderTimeFromJson(json);
  Map<String, dynamic> toJson() => _$ReminderTimeToJson(this);

  String get displayTime {
    final period = hour >= 12 ? 'PM' : 'AM';
    final displayHour = hour > 12 ? hour - 12 : (hour == 0 ? 12 : hour);
    final displayMinute = minute.toString().padLeft(2, '0');
    return '$displayHour:$displayMinute $period';
  }
}

@JsonSerializable()
class MedicationInteraction {
  final String id;
  final String medication1Id;
  final String medication2Id;
  final String medication1Name;
  final String medication2Name;
  final InteractionSeverity severity;
  final String description;
  final String recommendation;
  final List<String> effects;

  MedicationInteraction({
    required this.id,
    required this.medication1Id,
    required this.medication2Id,
    required this.medication1Name,
    required this.medication2Name,
    required this.severity,
    required this.description,
    required this.recommendation,
    required this.effects,
  });

  factory MedicationInteraction.fromJson(Map<String, dynamic> json) => 
      _$MedicationInteractionFromJson(json);
  Map<String, dynamic> toJson() => _$MedicationInteractionToJson(this);
}

@JsonSerializable()
class MedicationAdherence {
  final String patientId;
  final String medicationId;
  final double adherenceRate;
  final int totalDoses;
  final int takenDoses;
  final int missedDoses;
  final DateTime periodStart;
  final DateTime periodEnd;
  final List<AdherencePattern> patterns;

  MedicationAdherence({
    required this.patientId,
    required this.medicationId,
    required this.adherenceRate,
    required this.totalDoses,
    required this.takenDoses,
    required this.missedDoses,
    required this.periodStart,
    required this.periodEnd,
    required this.patterns,
  });

  factory MedicationAdherence.fromJson(Map<String, dynamic> json) => 
      _$MedicationAdherenceFromJson(json);
  Map<String, dynamic> toJson() => _$MedicationAdherenceToJson(this);
}

@JsonSerializable()
class AdherencePattern {
  final String pattern;
  final String description;
  final double frequency;

  AdherencePattern({
    required this.pattern,
    required this.description,
    required this.frequency,
  });

  factory AdherencePattern.fromJson(Map<String, dynamic> json) => 
      _$AdherencePatternFromJson(json);
  Map<String, dynamic> toJson() => _$AdherencePatternToJson(this);
}

// Enums
enum MedicationStatus {
  @JsonValue('ACTIVE')
  active,
  @JsonValue('PAUSED')
  paused,
  @JsonValue('COMPLETED')
  completed,
  @JsonValue('DISCONTINUED')
  discontinued,
}

enum MedicationLogStatus {
  @JsonValue('PENDING')
  pending,
  @JsonValue('TAKEN')
  taken,
  @JsonValue('MISSED')
  missed,
  @JsonValue('SKIPPED')
  skipped,
}

enum ReminderType {
  @JsonValue('NOTIFICATION')
  notification,
  @JsonValue('ALARM')
  alarm,
  @JsonValue('SMS')
  sms,
  @JsonValue('EMAIL')
  email,
}

enum InteractionSeverity {
  @JsonValue('MINOR')
  minor,
  @JsonValue('MODERATE')
  moderate,
  @JsonValue('MAJOR')
  major,
  @JsonValue('CONTRAINDICATED')
  contraindicated,
}

// Extension methods
extension MedicationStatusExtension on MedicationStatus {
  String get displayName {
    switch (this) {
      case MedicationStatus.active:
        return 'Active';
      case MedicationStatus.paused:
        return 'Paused';
      case MedicationStatus.completed:
        return 'Completed';
      case MedicationStatus.discontinued:
        return 'Discontinued';
    }
  }
}

extension MedicationLogStatusExtension on MedicationLogStatus {
  String get displayName {
    switch (this) {
      case MedicationLogStatus.pending:
        return 'Pending';
      case MedicationLogStatus.taken:
        return 'Taken';
      case MedicationLogStatus.missed:
        return 'Missed';
      case MedicationLogStatus.skipped:
        return 'Skipped';
    }
  }
}

extension InteractionSeverityExtension on InteractionSeverity {
  String get displayName {
    switch (this) {
      case InteractionSeverity.minor:
        return 'Minor';
      case InteractionSeverity.moderate:
        return 'Moderate';
      case InteractionSeverity.major:
        return 'Major';
      case InteractionSeverity.contraindicated:
        return 'Contraindicated';
    }
  }
}