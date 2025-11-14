// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'medication_models.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

Medication _$MedicationFromJson(Map<String, dynamic> json) => Medication(
      id: json['id'] as String,
      patientId: json['patientId'] as String,
      name: json['name'] as String,
      genericName: json['genericName'] as String,
      dosage: json['dosage'] as String,
      frequency: json['frequency'] as String,
      route: json['route'] as String,
      startDate: DateTime.parse(json['startDate'] as String),
      endDate: json['endDate'] == null
          ? null
          : DateTime.parse(json['endDate'] as String),
      prescribedBy: json['prescribedBy'] as String,
      instructions: json['instructions'] as String?,
      sideEffects: (json['sideEffects'] as List<dynamic>)
          .map((e) => e as String)
          .toList(),
      status: $enumDecode(_$MedicationStatusEnumMap, json['status']),
      isActive: json['isActive'] as bool,
      createdAt: DateTime.parse(json['createdAt'] as String),
      updatedAt: DateTime.parse(json['updatedAt'] as String),
    );

Map<String, dynamic> _$MedicationToJson(Medication instance) =>
    <String, dynamic>{
      'id': instance.id,
      'patientId': instance.patientId,
      'name': instance.name,
      'genericName': instance.genericName,
      'dosage': instance.dosage,
      'frequency': instance.frequency,
      'route': instance.route,
      'startDate': instance.startDate.toIso8601String(),
      'endDate': instance.endDate?.toIso8601String(),
      'prescribedBy': instance.prescribedBy,
      'instructions': instance.instructions,
      'sideEffects': instance.sideEffects,
      'status': _$MedicationStatusEnumMap[instance.status]!,
      'isActive': instance.isActive,
      'createdAt': instance.createdAt.toIso8601String(),
      'updatedAt': instance.updatedAt.toIso8601String(),
    };

const _$MedicationStatusEnumMap = {
  MedicationStatus.active: 'ACTIVE',
  MedicationStatus.paused: 'PAUSED',
  MedicationStatus.completed: 'COMPLETED',
  MedicationStatus.discontinued: 'DISCONTINUED',
};

MedicationLog _$MedicationLogFromJson(Map<String, dynamic> json) =>
    MedicationLog(
      id: json['id'] as String,
      medicationId: json['medicationId'] as String,
      patientId: json['patientId'] as String,
      scheduledTime: DateTime.parse(json['scheduledTime'] as String),
      takenTime: json['takenTime'] == null
          ? null
          : DateTime.parse(json['takenTime'] as String),
      status: $enumDecode(_$MedicationLogStatusEnumMap, json['status']),
      notes: json['notes'] as String?,
      metadata: json['metadata'] as Map<String, dynamic>?,
    );

Map<String, dynamic> _$MedicationLogToJson(MedicationLog instance) =>
    <String, dynamic>{
      'id': instance.id,
      'medicationId': instance.medicationId,
      'patientId': instance.patientId,
      'scheduledTime': instance.scheduledTime.toIso8601String(),
      'takenTime': instance.takenTime?.toIso8601String(),
      'status': _$MedicationLogStatusEnumMap[instance.status]!,
      'notes': instance.notes,
      'metadata': instance.metadata,
    };

const _$MedicationLogStatusEnumMap = {
  MedicationLogStatus.pending: 'PENDING',
  MedicationLogStatus.taken: 'TAKEN',
  MedicationLogStatus.missed: 'MISSED',
  MedicationLogStatus.skipped: 'SKIPPED',
};

CreateMedicationRequest _$CreateMedicationRequestFromJson(
        Map<String, dynamic> json) =>
    CreateMedicationRequest(
      patientId: json['patientId'] as String,
      name: json['name'] as String,
      genericName: json['genericName'] as String,
      dosage: json['dosage'] as String,
      frequency: json['frequency'] as String,
      route: json['route'] as String,
      startDate: DateTime.parse(json['startDate'] as String),
      endDate: json['endDate'] == null
          ? null
          : DateTime.parse(json['endDate'] as String),
      prescribedBy: json['prescribedBy'] as String,
      instructions: json['instructions'] as String?,
      sideEffects: (json['sideEffects'] as List<dynamic>)
          .map((e) => e as String)
          .toList(),
    );

Map<String, dynamic> _$CreateMedicationRequestToJson(
        CreateMedicationRequest instance) =>
    <String, dynamic>{
      'patientId': instance.patientId,
      'name': instance.name,
      'genericName': instance.genericName,
      'dosage': instance.dosage,
      'frequency': instance.frequency,
      'route': instance.route,
      'startDate': instance.startDate.toIso8601String(),
      'endDate': instance.endDate?.toIso8601String(),
      'prescribedBy': instance.prescribedBy,
      'instructions': instance.instructions,
      'sideEffects': instance.sideEffects,
    };

UpdateMedicationRequest _$UpdateMedicationRequestFromJson(
        Map<String, dynamic> json) =>
    UpdateMedicationRequest(
      name: json['name'] as String?,
      genericName: json['genericName'] as String?,
      dosage: json['dosage'] as String?,
      frequency: json['frequency'] as String?,
      route: json['route'] as String?,
      startDate: json['startDate'] == null
          ? null
          : DateTime.parse(json['startDate'] as String),
      endDate: json['endDate'] == null
          ? null
          : DateTime.parse(json['endDate'] as String),
      prescribedBy: json['prescribedBy'] as String?,
      instructions: json['instructions'] as String?,
      sideEffects: (json['sideEffects'] as List<dynamic>?)
          ?.map((e) => e as String)
          .toList(),
      status: $enumDecodeNullable(_$MedicationStatusEnumMap, json['status']),
      isActive: json['isActive'] as bool?,
    );

Map<String, dynamic> _$UpdateMedicationRequestToJson(
        UpdateMedicationRequest instance) =>
    <String, dynamic>{
      'name': instance.name,
      'genericName': instance.genericName,
      'dosage': instance.dosage,
      'frequency': instance.frequency,
      'route': instance.route,
      'startDate': instance.startDate?.toIso8601String(),
      'endDate': instance.endDate?.toIso8601String(),
      'prescribedBy': instance.prescribedBy,
      'instructions': instance.instructions,
      'sideEffects': instance.sideEffects,
      'status': _$MedicationStatusEnumMap[instance.status],
      'isActive': instance.isActive,
    };

MedicationReminder _$MedicationReminderFromJson(Map<String, dynamic> json) =>
    MedicationReminder(
      id: json['id'] as String,
      medicationId: json['medicationId'] as String,
      patientId: json['patientId'] as String,
      reminderTimes: (json['reminderTimes'] as List<dynamic>)
          .map((e) => ReminderTime.fromJson(e as Map<String, dynamic>))
          .toList(),
      isEnabled: json['isEnabled'] as bool,
      type: $enumDecode(_$ReminderTypeEnumMap, json['type']),
      settings: json['settings'] as Map<String, dynamic>?,
    );

Map<String, dynamic> _$MedicationReminderToJson(MedicationReminder instance) =>
    <String, dynamic>{
      'id': instance.id,
      'medicationId': instance.medicationId,
      'patientId': instance.patientId,
      'reminderTimes': instance.reminderTimes,
      'isEnabled': instance.isEnabled,
      'type': _$ReminderTypeEnumMap[instance.type]!,
      'settings': instance.settings,
    };

const _$ReminderTypeEnumMap = {
  ReminderType.notification: 'NOTIFICATION',
  ReminderType.alarm: 'ALARM',
  ReminderType.sms: 'SMS',
  ReminderType.email: 'EMAIL',
};

ReminderTime _$ReminderTimeFromJson(Map<String, dynamic> json) => ReminderTime(
      hour: (json['hour'] as num).toInt(),
      minute: (json['minute'] as num).toInt(),
      daysOfWeek: (json['daysOfWeek'] as List<dynamic>)
          .map((e) => (e as num).toInt())
          .toList(),
    );

Map<String, dynamic> _$ReminderTimeToJson(ReminderTime instance) =>
    <String, dynamic>{
      'hour': instance.hour,
      'minute': instance.minute,
      'daysOfWeek': instance.daysOfWeek,
    };

MedicationInteraction _$MedicationInteractionFromJson(
        Map<String, dynamic> json) =>
    MedicationInteraction(
      id: json['id'] as String,
      medication1Id: json['medication1Id'] as String,
      medication2Id: json['medication2Id'] as String,
      medication1Name: json['medication1Name'] as String,
      medication2Name: json['medication2Name'] as String,
      severity: $enumDecode(_$InteractionSeverityEnumMap, json['severity']),
      description: json['description'] as String,
      recommendation: json['recommendation'] as String,
      effects:
          (json['effects'] as List<dynamic>).map((e) => e as String).toList(),
    );

Map<String, dynamic> _$MedicationInteractionToJson(
        MedicationInteraction instance) =>
    <String, dynamic>{
      'id': instance.id,
      'medication1Id': instance.medication1Id,
      'medication2Id': instance.medication2Id,
      'medication1Name': instance.medication1Name,
      'medication2Name': instance.medication2Name,
      'severity': _$InteractionSeverityEnumMap[instance.severity]!,
      'description': instance.description,
      'recommendation': instance.recommendation,
      'effects': instance.effects,
    };

const _$InteractionSeverityEnumMap = {
  InteractionSeverity.minor: 'MINOR',
  InteractionSeverity.moderate: 'MODERATE',
  InteractionSeverity.major: 'MAJOR',
  InteractionSeverity.contraindicated: 'CONTRAINDICATED',
};

MedicationAdherence _$MedicationAdherenceFromJson(Map<String, dynamic> json) =>
    MedicationAdherence(
      patientId: json['patientId'] as String,
      medicationId: json['medicationId'] as String,
      adherenceRate: (json['adherenceRate'] as num).toDouble(),
      totalDoses: (json['totalDoses'] as num).toInt(),
      takenDoses: (json['takenDoses'] as num).toInt(),
      missedDoses: (json['missedDoses'] as num).toInt(),
      periodStart: DateTime.parse(json['periodStart'] as String),
      periodEnd: DateTime.parse(json['periodEnd'] as String),
      patterns: (json['patterns'] as List<dynamic>)
          .map((e) => AdherencePattern.fromJson(e as Map<String, dynamic>))
          .toList(),
    );

Map<String, dynamic> _$MedicationAdherenceToJson(
        MedicationAdherence instance) =>
    <String, dynamic>{
      'patientId': instance.patientId,
      'medicationId': instance.medicationId,
      'adherenceRate': instance.adherenceRate,
      'totalDoses': instance.totalDoses,
      'takenDoses': instance.takenDoses,
      'missedDoses': instance.missedDoses,
      'periodStart': instance.periodStart.toIso8601String(),
      'periodEnd': instance.periodEnd.toIso8601String(),
      'patterns': instance.patterns,
    };

AdherencePattern _$AdherencePatternFromJson(Map<String, dynamic> json) =>
    AdherencePattern(
      pattern: json['pattern'] as String,
      description: json['description'] as String,
      frequency: (json['frequency'] as num).toDouble(),
    );

Map<String, dynamic> _$AdherencePatternToJson(AdherencePattern instance) =>
    <String, dynamic>{
      'pattern': instance.pattern,
      'description': instance.description,
      'frequency': instance.frequency,
    };
