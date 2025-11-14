import 'package:json_annotation/json_annotation.dart';

part 'sync_models.g.dart';

// Additional models used by SyncService
@JsonSerializable()
class SyncActionRecord {
  final String id;
  final String type;
  final String entityId;
  final Map<String, dynamic> data;
  final DateTime timestamp;
  final ActionType actionType;

  SyncActionRecord({
    required this.id,
    required this.type,
    required this.entityId,
    required this.data,
    required this.timestamp,
    required this.actionType,
  });

  factory SyncActionRecord.fromJson(Map<String, dynamic> json) =>
      _$SyncActionRecordFromJson(json);
  Map<String, dynamic> toJson() => _$SyncActionRecordToJson(this);
}

@JsonSerializable()
class OfflineDataUploadRequest {
  final String deviceId;
  final List<SyncActionRecord> actions;
  final int timestamp;

  OfflineDataUploadRequest({
    required this.deviceId,
    required this.actions,
    required this.timestamp,
  });

  factory OfflineDataUploadRequest.fromJson(Map<String, dynamic> json) =>
      _$OfflineDataUploadRequestFromJson(json);
  Map<String, dynamic> toJson() => _$OfflineDataUploadRequestToJson(this);
}

@JsonSerializable()
class SyncResponse {
  final bool success;
  final String? message;
  final List<String>? processedActions;
  final List<DataConflict>? conflicts;

  SyncResponse({
    required this.success,
    this.message,
    this.processedActions,
    this.conflicts,
  });

  factory SyncResponse.fromJson(Map<String, dynamic> json) =>
      _$SyncResponseFromJson(json);
  Map<String, dynamic> toJson() => _$SyncResponseToJson(this);
}

@JsonSerializable()
class DataConflict {
  final String id;
  final String entityId;
  final String entityType;
  final Map<String, dynamic> localData;
  final Map<String, dynamic> serverData;
  final DateTime timestamp;

  DataConflict({
    required this.id,
    required this.entityId,
    required this.entityType,
    required this.localData,
    required this.serverData,
    required this.timestamp,
  });

  factory DataConflict.fromJson(Map<String, dynamic> json) =>
      _$DataConflictFromJson(json);
  Map<String, dynamic> toJson() => _$DataConflictToJson(this);
}

@JsonSerializable()
class ConflictResolution {
  final ConflictResolutionType type;
  final Map<String, dynamic>? mergedData;

  ConflictResolution({
    required this.type,
    this.mergedData,
  });

  factory ConflictResolution.fromJson(Map<String, dynamic> json) =>
      _$ConflictResolutionFromJson(json);
  Map<String, dynamic> toJson() => _$ConflictResolutionToJson(this);
}

@JsonSerializable()
class ConflictResolutionRequest {
  final String conflictId;
  final ConflictResolution resolution;
  final String deviceId;

  ConflictResolutionRequest({
    required this.conflictId,
    required this.resolution,
    required this.deviceId,
  });

  factory ConflictResolutionRequest.fromJson(Map<String, dynamic> json) =>
      _$ConflictResolutionRequestFromJson(json);
  Map<String, dynamic> toJson() => _$ConflictResolutionRequestToJson(this);
}

@JsonSerializable()
class ConflictResolutionResponse {
  final bool success;
  final String? message;

  ConflictResolutionResponse({
    required this.success,
    this.message,
  });

  factory ConflictResolutionResponse.fromJson(Map<String, dynamic> json) =>
      _$ConflictResolutionResponseFromJson(json);
  Map<String, dynamic> toJson() => _$ConflictResolutionResponseToJson(this);
}

@JsonSerializable()
class SyncDownloadResponse {
  final bool success;
  final String? message;
  final List<SyncUpdate>? updates;

  SyncDownloadResponse({
    required this.success,
    this.message,
    this.updates,
  });

  factory SyncDownloadResponse.fromJson(Map<String, dynamic> json) =>
      _$SyncDownloadResponseFromJson(json);
  Map<String, dynamic> toJson() => _$SyncDownloadResponseToJson(this);
}

@JsonSerializable()
class SyncUpdate {
  final String id;
  final String entityType;
  final String entityId;
  final Map<String, dynamic> data;
  final ActionType actionType;
  final DateTime timestamp;

  SyncUpdate({
    required this.id,
    required this.entityType,
    required this.entityId,
    required this.data,
    required this.actionType,
    required this.timestamp,
  });

  factory SyncUpdate.fromJson(Map<String, dynamic> json) =>
      _$SyncUpdateFromJson(json);
  Map<String, dynamic> toJson() => _$SyncUpdateToJson(this);
}

@JsonSerializable()
class DeviceHeartbeatRequest {
  final String deviceId;
  final int timestamp;
  final int pendingActionsCount;
  final String appVersion;

  DeviceHeartbeatRequest({
    required this.deviceId,
    required this.timestamp,
    required this.pendingActionsCount,
    required this.appVersion,
  });

  factory DeviceHeartbeatRequest.fromJson(Map<String, dynamic> json) =>
      _$DeviceHeartbeatRequestFromJson(json);
  Map<String, dynamic> toJson() => _$DeviceHeartbeatRequestToJson(this);
}

@JsonSerializable()
class SyncStatusData {
  final bool isOnline;
  final int pendingActionsCount;
  final int pendingConflictsCount;
  final int lastSyncTimestamp;
  final String deviceId;

  SyncStatusData({
    required this.isOnline,
    required this.pendingActionsCount,
    required this.pendingConflictsCount,
    required this.lastSyncTimestamp,
    required this.deviceId,
  });

  factory SyncStatusData.fromJson(Map<String, dynamic> json) =>
      _$SyncStatusDataFromJson(json);
  Map<String, dynamic> toJson() => _$SyncStatusDataToJson(this);
}

@JsonSerializable()
class SyncDownloadResult {
  final bool success;
  final String message;
  final List<SyncUpdate> updates;

  SyncDownloadResult({
    required this.success,
    required this.message,
    required this.updates,
  });

  factory SyncDownloadResult.fromJson(Map<String, dynamic> json) =>
      _$SyncDownloadResultFromJson(json);
  Map<String, dynamic> toJson() => _$SyncDownloadResultToJson(this);
}

enum ActionType {
  @JsonValue('CREATE')
  create,
  @JsonValue('UPDATE')
  update,
  @JsonValue('DELETE')
  delete,
}

enum ConflictResolutionType {
  @JsonValue('USE_LOCAL')
  useLocal,
  @JsonValue('USE_SERVER')
  useServer,
  @JsonValue('MERGE')
  merge,
}

@JsonSerializable()
class SyncResult {
  final bool success;
  final String? message;
  final int uploadedItems;
  final int failedItems;
  final List<SyncError>? errors;
  final DateTime timestamp;

  SyncResult({
    required this.success,
    this.message,
    required this.uploadedItems,
    required this.failedItems,
    this.errors,
    required this.timestamp,
  });

  factory SyncResult.fromJson(Map<String, dynamic> json) =>
      _$SyncResultFromJson(json);
  Map<String, dynamic> toJson() => _$SyncResultToJson(this);
}

@JsonSerializable()
class SyncData {
  final List<SyncItem> items;
  final DateTime lastSyncTime;
  final String deviceId;
  final int totalItems;
  final bool hasMore;

  SyncData({
    required this.items,
    required this.lastSyncTime,
    required this.deviceId,
    required this.totalItems,
    required this.hasMore,
  });

  factory SyncData.fromJson(Map<String, dynamic> json) =>
      _$SyncDataFromJson(json);
  Map<String, dynamic> toJson() => _$SyncDataToJson(this);
}

@JsonSerializable()
class SyncItem {
  final String id;
  final String type;
  final Map<String, dynamic> data;
  final DateTime timestamp;
  final SyncAction action;
  final SyncStatus status;

  SyncItem({
    required this.id,
    required this.type,
    required this.data,
    required this.timestamp,
    required this.action,
    required this.status,
  });

  factory SyncItem.fromJson(Map<String, dynamic> json) =>
      _$SyncItemFromJson(json);
  Map<String, dynamic> toJson() => _$SyncItemToJson(this);
}

@JsonSerializable()
class SyncError {
  final String itemId;
  final String error;
  final String? details;
  final DateTime timestamp;

  SyncError({
    required this.itemId,
    required this.error,
    this.details,
    required this.timestamp,
  });

  factory SyncError.fromJson(Map<String, dynamic> json) =>
      _$SyncErrorFromJson(json);
  Map<String, dynamic> toJson() => _$SyncErrorToJson(this);
}

@JsonSerializable()
class OfflineDataUpload {
  final String deviceId;
  final List<OfflineItem> items;
  final DateTime timestamp;
  final Map<String, dynamic>? metadata;

  OfflineDataUpload({
    required this.deviceId,
    required this.items,
    required this.timestamp,
    this.metadata,
  });

  factory OfflineDataUpload.fromJson(Map<String, dynamic> json) =>
      _$OfflineDataUploadFromJson(json);
  Map<String, dynamic> toJson() => _$OfflineDataUploadToJson(this);
}

@JsonSerializable()
class OfflineItem {
  final String id;
  final String type;
  final Map<String, dynamic> data;
  final DateTime createdAt;
  final SyncAction action;
  final int retryCount;

  OfflineItem({
    required this.id,
    required this.type,
    required this.data,
    required this.createdAt,
    required this.action,
    this.retryCount = 0,
  });

  factory OfflineItem.fromJson(Map<String, dynamic> json) =>
      _$OfflineItemFromJson(json);
  Map<String, dynamic> toJson() => _$OfflineItemToJson(this);
}

@JsonSerializable()
class ConflictResolutionResult {
  final List<ResolvedConflict> resolvedConflicts;
  final int totalConflicts;
  final DateTime timestamp;

  ConflictResolutionResult({
    required this.resolvedConflicts,
    required this.totalConflicts,
    required this.timestamp,
  });

  factory ConflictResolutionResult.fromJson(Map<String, dynamic> json) =>
      _$ConflictResolutionResultFromJson(json);
  Map<String, dynamic> toJson() => _$ConflictResolutionResultToJson(this);
}

@JsonSerializable()
class ResolvedConflict {
  final String itemId;
  final String resolution;
  final Map<String, dynamic> finalData;
  final DateTime resolvedAt;

  ResolvedConflict({
    required this.itemId,
    required this.resolution,
    required this.finalData,
    required this.resolvedAt,
  });

  factory ResolvedConflict.fromJson(Map<String, dynamic> json) =>
      _$ResolvedConflictFromJson(json);
  Map<String, dynamic> toJson() => _$ResolvedConflictToJson(this);
}

@JsonSerializable()
class ConflictResolutionBatchRequest {
  final List<ConflictItem> conflicts;
  final String deviceId;
  final DateTime timestamp;

  ConflictResolutionBatchRequest({
    required this.conflicts,
    required this.deviceId,
    required this.timestamp,
  });

  factory ConflictResolutionBatchRequest.fromJson(Map<String, dynamic> json) =>
      _$ConflictResolutionBatchRequestFromJson(json);
  Map<String, dynamic> toJson() => _$ConflictResolutionBatchRequestToJson(this);
}

@JsonSerializable()
class ConflictItem {
  final String itemId;
  final Map<String, dynamic> localData;
  final Map<String, dynamic> serverData;
  final ConflictResolutionStrategy strategy;

  ConflictItem({
    required this.itemId,
    required this.localData,
    required this.serverData,
    required this.strategy,
  });

  factory ConflictItem.fromJson(Map<String, dynamic> json) =>
      _$ConflictItemFromJson(json);
  Map<String, dynamic> toJson() => _$ConflictItemToJson(this);
}

@JsonSerializable()
class HeartbeatRequest {
  final String deviceId;
  final DateTime timestamp;
  final Map<String, dynamic> deviceInfo;
  final SyncStatus syncStatus;

  HeartbeatRequest({
    required this.deviceId,
    required this.timestamp,
    required this.deviceInfo,
    required this.syncStatus,
  });

  factory HeartbeatRequest.fromJson(Map<String, dynamic> json) =>
      _$HeartbeatRequestFromJson(json);
  Map<String, dynamic> toJson() => _$HeartbeatRequestToJson(this);
}

@JsonSerializable()
class FileUploadResult {
  final String fileId;
  final String fileName;
  final String url;
  final int size;
  final String mimeType;
  final DateTime uploadedAt;

  FileUploadResult({
    required this.fileId,
    required this.fileName,
    required this.url,
    required this.size,
    required this.mimeType,
    required this.uploadedAt,
  });

  factory FileUploadResult.fromJson(Map<String, dynamic> json) =>
      _$FileUploadResultFromJson(json);
  Map<String, dynamic> toJson() => _$FileUploadResultToJson(this);
}

// Enums
enum SyncAction {
  @JsonValue('CREATE')
  create,
  @JsonValue('UPDATE')
  update,
  @JsonValue('DELETE')
  delete,
}

enum SyncStatus {
  @JsonValue('PENDING')
  pending,
  @JsonValue('IN_PROGRESS')
  inProgress,
  @JsonValue('COMPLETED')
  completed,
  @JsonValue('FAILED')
  failed,
  @JsonValue('CONFLICT')
  conflict,
}

enum ConflictResolutionStrategy {
  @JsonValue('USE_LOCAL')
  useLocal,
  @JsonValue('USE_SERVER')
  useServer,
  @JsonValue('MERGE')
  merge,
  @JsonValue('MANUAL')
  manual,
}

// Extension methods
extension SyncActionExtension on SyncAction {
  String get displayName {
    switch (this) {
      case SyncAction.create:
        return 'Create';
      case SyncAction.update:
        return 'Update';
      case SyncAction.delete:
        return 'Delete';
    }
  }
}

extension SyncStatusExtension on SyncStatus {
  String get displayName {
    switch (this) {
      case SyncStatus.pending:
        return 'Pending';
      case SyncStatus.inProgress:
        return 'In Progress';
      case SyncStatus.completed:
        return 'Completed';
      case SyncStatus.failed:
        return 'Failed';
      case SyncStatus.conflict:
        return 'Conflict';
    }
  }
}

class CriticalPatientData {
  final String patientId;
  final String name;
  final String bloodType;
  final List<String> allergies;
  final List<String> medications;
  final Map<String, dynamic> vitalSigns;
  final String emergencyContact;
  final String medicalHistory;

  CriticalPatientData({
    required this.patientId,
    required this.name,
    required this.bloodType,
    required this.allergies,
    required this.medications,
    required this.vitalSigns,
    required this.emergencyContact,
    required this.medicalHistory,
  });

  factory CriticalPatientData.fromJson(Map<String, dynamic> json) {
    return CriticalPatientData(
      patientId: json['patientId'] ?? '',
      name: json['name'] ?? '',
      bloodType: json['bloodType'] ?? '',
      allergies: List<String>.from(json['allergies'] ?? []),
      medications: List<String>.from(json['medications'] ?? []),
      vitalSigns: json['vitalSigns'] ?? {},
      emergencyContact: json['emergencyContact'] ?? '',
      medicalHistory: json['medicalHistory'] ?? '',
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'patientId': patientId,
      'name': name,
      'bloodType': bloodType,
      'allergies': allergies,
      'medications': medications,
      'vitalSigns': vitalSigns,
      'emergencyContact': emergencyContact,
      'medicalHistory': medicalHistory,
    };
  }
}

class EmergencyProtocol {
  final String id;
  final String type;
  final String title;
  final String description;
  final List<String> steps;
  final List<String> requiredEquipment;
  final String priority;

  EmergencyProtocol({
    required this.id,
    required this.type,
    required this.title,
    required this.description,
    required this.steps,
    required this.requiredEquipment,
    required this.priority,
  });

  factory EmergencyProtocol.fromJson(Map<String, dynamic> json) {
    return EmergencyProtocol(
      id: json['id'] ?? '',
      type: json['type'] ?? '',
      title: json['title'] ?? '',
      description: json['description'] ?? '',
      steps: List<String>.from(json['steps'] ?? []),
      requiredEquipment: List<String>.from(json['requiredEquipment'] ?? []),
      priority: json['priority'] ?? 'normal',
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'type': type,
      'title': title,
      'description': description,
      'steps': steps,
      'requiredEquipment': requiredEquipment,
      'priority': priority,
    };
  }
}

class MedicationSafetyData {
  final String medicationId;
  final String name;
  final List<String> interactions;
  final List<String> contraindications;
  final String dosageGuidelines;
  final List<String> sideEffects;

  MedicationSafetyData({
    required this.medicationId,
    required this.name,
    required this.interactions,
    required this.contraindications,
    required this.dosageGuidelines,
    required this.sideEffects,
  });

  factory MedicationSafetyData.fromJson(Map<String, dynamic> json) {
    return MedicationSafetyData(
      medicationId: json['medicationId'] ?? '',
      name: json['name'] ?? '',
      interactions: List<String>.from(json['interactions'] ?? []),
      contraindications: List<String>.from(json['contraindications'] ?? []),
      dosageGuidelines: json['dosageGuidelines'] ?? '',
      sideEffects: List<String>.from(json['sideEffects'] ?? []),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'medicationId': medicationId,
      'name': name,
      'interactions': interactions,
      'contraindications': contraindications,
      'dosageGuidelines': dosageGuidelines,
      'sideEffects': sideEffects,
    };
  }
}

class DrugInteraction {
  final String id;
  final String medication1;
  final String medication2;
  final String severity;
  final String description;
  final String recommendation;

  DrugInteraction({
    required this.id,
    required this.medication1,
    required this.medication2,
    required this.severity,
    required this.description,
    required this.recommendation,
  });

  factory DrugInteraction.fromJson(Map<String, dynamic> json) {
    return DrugInteraction(
      id: json['id'] ?? '',
      medication1: json['medication1'] ?? '',
      medication2: json['medication2'] ?? '',
      severity: json['severity'] ?? 'unknown',
      description: json['description'] ?? '',
      recommendation: json['recommendation'] ?? '',
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'medication1': medication1,
      'medication2': medication2,
      'severity': severity,
      'description': description,
      'recommendation': recommendation,
    };
  }
}

class VitalSignAlert {
  final String id;
  final String patientId;
  final String vitalType;
  final String alertType;
  final String message;
  final DateTime timestamp;

  VitalSignAlert({
    required this.id,
    required this.patientId,
    required this.vitalType,
    required this.alertType,
    required this.message,
    required this.timestamp,
  });

  factory VitalSignAlert.fromJson(Map<String, dynamic> json) {
    return VitalSignAlert(
      id: json['id'] ?? '',
      patientId: json['patientId'] ?? '',
      vitalType: json['vitalType'] ?? '',
      alertType: json['alertType'] ?? '',
      message: json['message'] ?? '',
      timestamp:
          DateTime.parse(json['timestamp'] ?? DateTime.now().toIso8601String()),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'patientId': patientId,
      'vitalType': vitalType,
      'alertType': alertType,
      'message': message,
      'timestamp': timestamp.toIso8601String(),
    };
  }
}

class VitalSigns {
  final String patientId;
  final double heartRate;
  final String bloodPressure;
  final double temperature;
  final double oxygenSaturation;
  final double respiratoryRate;
  final DateTime timestamp;

  VitalSigns({
    required this.patientId,
    required this.heartRate,
    required this.bloodPressure,
    required this.temperature,
    required this.oxygenSaturation,
    required this.respiratoryRate,
    required this.timestamp,
  });

  factory VitalSigns.fromJson(Map<String, dynamic> json) {
    return VitalSigns(
      patientId: json['patientId'] ?? '',
      heartRate: (json['heartRate'] ?? 0.0).toDouble(),
      bloodPressure: json['bloodPressure'] ?? '',
      temperature: (json['temperature'] ?? 0.0).toDouble(),
      oxygenSaturation: (json['oxygenSaturation'] ?? 0.0).toDouble(),
      respiratoryRate: (json['respiratoryRate'] ?? 0.0).toDouble(),
      timestamp:
          DateTime.parse(json['timestamp'] ?? DateTime.now().toIso8601String()),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'patientId': patientId,
      'heartRate': heartRate,
      'bloodPressure': bloodPressure,
      'temperature': temperature,
      'oxygenSaturation': oxygenSaturation,
      'respiratoryRate': respiratoryRate,
      'timestamp': timestamp.toIso8601String(),
    };
  }
}

enum OfflineActionType {
  patientUpdate,
  vitalsRecording,
  medicationAdministration,
  appointmentBooking,
  emergencyReport,
}

class OfflineAction {
  final String id;
  final OfflineActionType type;
  final Map<String, dynamic> data;
  final DateTime timestamp;
  final bool synced;

  OfflineAction({
    required this.id,
    required this.type,
    required this.data,
    required this.timestamp,
    this.synced = false,
  });

  factory OfflineAction.fromJson(Map<String, dynamic> json) {
    return OfflineAction(
      id: json['id'] ?? '',
      type: OfflineActionType.values.firstWhere(
        (e) => e.name == json['type'],
        orElse: () => OfflineActionType.patientUpdate,
      ),
      data: json['data'] ?? {},
      timestamp:
          DateTime.parse(json['timestamp'] ?? DateTime.now().toIso8601String()),
      synced: json['synced'] ?? false,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'type': type.name,
      'data': data,
      'timestamp': timestamp.toIso8601String(),
      'synced': synced,
    };
  }
}
