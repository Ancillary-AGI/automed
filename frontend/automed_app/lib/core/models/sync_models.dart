class SyncAction {
  final String id;
  final String type;
  final String entityType;
  final String entityId;
  final Map<String, dynamic> data;
  final int timestamp;
  final String? userId;
  final String? deviceId;

  const SyncAction({
    required this.id,
    required this.type,
    required this.entityType,
    required this.entityId,
    required this.data,
    required this.timestamp,
    this.userId,
    this.deviceId,
  });

  factory SyncAction.fromJson(Map<String, dynamic> json) {
    return SyncAction(
      id: json['id'],
      type: json['type'],
      entityType: json['entityType'],
      entityId: json['entityId'],
      data: Map<String, dynamic>.from(json['data']),
      timestamp: json['timestamp'],
      userId: json['userId'],
      deviceId: json['deviceId'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'type': type,
      'entityType': entityType,
      'entityId': entityId,
      'data': data,
      'timestamp': timestamp,
      'userId': userId,
      'deviceId': deviceId,
    };
  }
}

class OfflineDataUploadRequest {
  final String deviceId;
  final List<SyncAction> actions;
  final int timestamp;
  final String? userId;

  const OfflineDataUploadRequest({
    required this.deviceId,
    required this.actions,
    required this.timestamp,
    this.userId,
  });

  factory OfflineDataUploadRequest.fromJson(Map<String, dynamic> json) {
    return OfflineDataUploadRequest(
      deviceId: json['deviceId'],
      actions: (json['actions'] as List)
          .map((e) => SyncAction.fromJson(e))
          .toList(),
      timestamp: json['timestamp'],
      userId: json['userId'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'deviceId': deviceId,
      'actions': actions.map((e) => e.toJson()).toList(),
      'timestamp': timestamp,
      'userId': userId,
    };
  }
}

class SyncResponse {
  final bool success;
  final String? message;
  final List<String>? processedActions;
  final List<DataConflict>? conflicts;
  final int? timestamp;

  const SyncResponse({
    required this.success,
    this.message,
    this.processedActions,
    this.conflicts,
    this.timestamp,
  });

  factory SyncResponse.fromJson(Map<String, dynamic> json) {
    return SyncResponse(
      success: json['success'],
      message: json['message'],
      processedActions: json['processedActions'] != null
          ? List<String>.from(json['processedActions'])
          : null,
      conflicts: json['conflicts'] != null
          ? (json['conflicts'] as List)
                .map((e) => DataConflict.fromJson(e))
                .toList()
          : null,
      timestamp: json['timestamp'],
    );
  }
}

class DataConflict {
  final String id;
  final String entityType;
  final String entityId;
  final Map<String, dynamic> localData;
  final Map<String, dynamic> serverData;
  final int localTimestamp;
  final int serverTimestamp;
  final ConflictType type;
  final String? description;

  const DataConflict({
    required this.id,
    required this.entityType,
    required this.entityId,
    required this.localData,
    required this.serverData,
    required this.localTimestamp,
    required this.serverTimestamp,
    required this.type,
    this.description,
  });

  factory DataConflict.fromJson(Map<String, dynamic> json) {
    return DataConflict(
      id: json['id'],
      entityType: json['entityType'],
      entityId: json['entityId'],
      localData: Map<String, dynamic>.from(json['localData']),
      serverData: Map<String, dynamic>.from(json['serverData']),
      localTimestamp: json['localTimestamp'],
      serverTimestamp: json['serverTimestamp'],
      type: ConflictType.values[json['type'] as int],
      description: json['description'],
    );
  }
}

enum ConflictType { updateConflict, deleteConflict, createConflict }

class ConflictResolution {
  final ConflictResolutionType type;
  final Map<String, dynamic>? mergedData;
  final String? notes;

  const ConflictResolution({required this.type, this.mergedData, this.notes});

  factory ConflictResolution.fromJson(Map<String, dynamic> json) {
    return ConflictResolution(
      type: ConflictResolutionType.values[json['type'] as int],
      mergedData: json['mergedData'] != null
          ? Map<String, dynamic>.from(json['mergedData'])
          : null,
      notes: json['notes'],
    );
  }

  Map<String, dynamic> toJson() {
    return {'type': type.index, 'mergedData': mergedData, 'notes': notes};
  }
}

enum ConflictResolutionType { useLocal, useServer, merge, skip }

class ConflictResolutionRequest {
  final String conflictId;
  final ConflictResolution resolution;
  final String deviceId;
  final String? userId;

  const ConflictResolutionRequest({
    required this.conflictId,
    required this.resolution,
    required this.deviceId,
    this.userId,
  });

  factory ConflictResolutionRequest.fromJson(Map<String, dynamic> json) {
    return ConflictResolutionRequest(
      conflictId: json['conflictId'],
      resolution: ConflictResolution.fromJson(json['resolution']),
      deviceId: json['deviceId'],
      userId: json['userId'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'conflictId': conflictId,
      'resolution': resolution.toJson(),
      'deviceId': deviceId,
      'userId': userId,
    };
  }
}

class ConflictResolutionResponse {
  final bool success;
  final String? message;
  final Map<String, dynamic>? resolvedData;

  const ConflictResolutionResponse({
    required this.success,
    this.message,
    this.resolvedData,
  });

  factory ConflictResolutionResponse.fromJson(Map<String, dynamic> json) {
    return ConflictResolutionResponse(
      success: json['success'],
      message: json['message'],
      resolvedData: json['resolvedData'] != null
          ? Map<String, dynamic>.from(json['resolvedData'])
          : null,
    );
  }
}

class SyncDownloadResponse {
  final bool success;
  final String? message;
  final List<SyncUpdate>? updates;
  final int? timestamp;

  const SyncDownloadResponse({
    required this.success,
    this.message,
    this.updates,
    this.timestamp,
  });

  factory SyncDownloadResponse.fromJson(Map<String, dynamic> json) {
    return SyncDownloadResponse(
      success: json['success'],
      message: json['message'],
      updates: json['updates'] != null
          ? (json['updates'] as List)
                .map((e) => SyncUpdate.fromJson(e))
                .toList()
          : null,
      timestamp: json['timestamp'],
    );
  }
}

class SyncUpdate {
  final String id;
  final String entityType;
  final String entityId;
  final String operation;
  final Map<String, dynamic> data;
  final int timestamp;

  const SyncUpdate({
    required this.id,
    required this.entityType,
    required this.entityId,
    required this.operation,
    required this.data,
    required this.timestamp,
  });

  factory SyncUpdate.fromJson(Map<String, dynamic> json) {
    return SyncUpdate(
      id: json['id'],
      entityType: json['entityType'],
      entityId: json['entityId'],
      operation: json['operation'],
      data: Map<String, dynamic>.from(json['data']),
      timestamp: json['timestamp'],
    );
  }
}

class DeviceHeartbeatRequest {
  final String deviceId;
  final int timestamp;
  final int pendingActionsCount;
  final String appVersion;
  final String? userId;

  const DeviceHeartbeatRequest({
    required this.deviceId,
    required this.timestamp,
    required this.pendingActionsCount,
    required this.appVersion,
    this.userId,
  });

  factory DeviceHeartbeatRequest.fromJson(Map<String, dynamic> json) {
    return DeviceHeartbeatRequest(
      deviceId: json['deviceId'],
      timestamp: json['timestamp'],
      pendingActionsCount: json['pendingActionsCount'],
      appVersion: json['appVersion'],
      userId: json['userId'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'deviceId': deviceId,
      'timestamp': timestamp,
      'pendingActionsCount': pendingActionsCount,
      'appVersion': appVersion,
      'userId': userId,
    };
  }
}

class DeviceHeartbeatResponse {
  final bool success;
  final String? message;
  final bool? forceSync;
  final String? serverVersion;

  const DeviceHeartbeatResponse({
    required this.success,
    this.message,
    this.forceSync,
    this.serverVersion,
  });

  factory DeviceHeartbeatResponse.fromJson(Map<String, dynamic> json) {
    return DeviceHeartbeatResponse(
      success: json['success'],
      message: json['message'],
      forceSync: json['forceSync'],
      serverVersion: json['serverVersion'],
    );
  }
}

// Result classes for service methods
class SyncResult {
  final bool success;
  final String message;
  final int syncedCount;
  final int conflictCount;
  final List<DataConflict>? conflicts;

  const SyncResult({
    required this.success,
    required this.message,
    required this.syncedCount,
    required this.conflictCount,
    this.conflicts,
  });

  factory SyncResult.fromJson(Map<String, dynamic> json) {
    return SyncResult(
      success: json['success'],
      message: json['message'],
      syncedCount: json['syncedCount'],
      conflictCount: json['conflictCount'],
      conflicts: json['conflicts'] != null
          ? (json['conflicts'] as List)
                .map((e) => DataConflict.fromJson(e))
                .toList()
          : null,
    );
  }
}

class SyncDownloadResult {
  final bool success;
  final String message;
  final List<SyncUpdate> updates;

  const SyncDownloadResult({
    required this.success,
    required this.message,
    required this.updates,
  });

  factory SyncDownloadResult.fromJson(Map<String, dynamic> json) {
    return SyncDownloadResult(
      success: json['success'],
      message: json['message'],
      updates: (json['updates'] as List)
          .map((e) => SyncUpdate.fromJson(e))
          .toList(),
    );
  }
}

class SyncStatus {
  final bool isOnline;
  final int pendingActionsCount;
  final int pendingConflictsCount;
  final int lastSyncTimestamp;
  final String deviceId;

  const SyncStatus({
    required this.isOnline,
    required this.pendingActionsCount,
    required this.pendingConflictsCount,
    required this.lastSyncTimestamp,
    required this.deviceId,
  });

  factory SyncStatus.fromJson(Map<String, dynamic> json) {
    return SyncStatus(
      isOnline: json['isOnline'],
      pendingActionsCount: json['pendingActionsCount'],
      pendingConflictsCount: json['pendingConflictsCount'],
      lastSyncTimestamp: json['lastSyncTimestamp'],
      deviceId: json['deviceId'],
    );
  }
}
