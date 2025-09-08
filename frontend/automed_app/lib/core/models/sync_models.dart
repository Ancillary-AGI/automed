import 'package:freezed_annotation/freezed_annotation.dart';

part 'sync_models.freezed.dart';
part 'sync_models.g.dart';

@freezed
class SyncAction with _$SyncAction {
  const factory SyncAction({
    required String id,
    required String type,
    required String entityType,
    required String entityId,
    required Map<String, dynamic> data,
    required int timestamp,
    String? userId,
    String? deviceId,
  }) = _SyncAction;

  factory SyncAction.fromJson(Map<String, dynamic> json) =>
      _$SyncActionFromJson(json);
}

@freezed
class OfflineDataUploadRequest with _$OfflineDataUploadRequest {
  const factory OfflineDataUploadRequest({
    required String deviceId,
    required List<SyncAction> actions,
    required int timestamp,
    String? userId,
  }) = _OfflineDataUploadRequest;

  factory OfflineDataUploadRequest.fromJson(Map<String, dynamic> json) =>
      _$OfflineDataUploadRequestFromJson(json);
}

@freezed
class SyncResponse with _$SyncResponse {
  const factory SyncResponse({
    required bool success,
    String? message,
    List<String>? processedActions,
    List<DataConflict>? conflicts,
    int? timestamp,
  }) = _SyncResponse;

  factory SyncResponse.fromJson(Map<String, dynamic> json) =>
      _$SyncResponseFromJson(json);
}

@freezed
class DataConflict with _$DataConflict {
  const factory DataConflict({
    required String id,
    required String entityType,
    required String entityId,
    required Map<String, dynamic> localData,
    required Map<String, dynamic> serverData,
    required int localTimestamp,
    required int serverTimestamp,
    required ConflictType type,
    String? description,
  }) = _DataConflict;

  factory DataConflict.fromJson(Map<String, dynamic> json) =>
      _$DataConflictFromJson(json);
}

enum ConflictType {
  @JsonValue('UPDATE_CONFLICT')
  updateConflict,
  @JsonValue('DELETE_CONFLICT')
  deleteConflict,
  @JsonValue('CREATE_CONFLICT')
  createConflict,
}

@freezed
class ConflictResolution with _$ConflictResolution {
  const factory ConflictResolution({
    required ConflictResolutionType type,
    Map<String, dynamic>? mergedData,
    String? notes,
  }) = _ConflictResolution;

  factory ConflictResolution.fromJson(Map<String, dynamic> json) =>
      _$ConflictResolutionFromJson(json);
}

enum ConflictResolutionType {
  @JsonValue('USE_LOCAL')
  useLocal,
  @JsonValue('USE_SERVER')
  useServer,
  @JsonValue('MERGE')
  merge,
  @JsonValue('SKIP')
  skip,
}

@freezed
class ConflictResolutionRequest with _$ConflictResolutionRequest {
  const factory ConflictResolutionRequest({
    required String conflictId,
    required ConflictResolution resolution,
    required String deviceId,
    String? userId,
  }) = _ConflictResolutionRequest;

  factory ConflictResolutionRequest.fromJson(Map<String, dynamic> json) =>
      _$ConflictResolutionRequestFromJson(json);
}

@freezed
class ConflictResolutionResponse with _$ConflictResolutionResponse {
  const factory ConflictResolutionResponse({
    required bool success,
    String? message,
    Map<String, dynamic>? resolvedData,
  }) = _ConflictResolutionResponse;

  factory ConflictResolutionResponse.fromJson(Map<String, dynamic> json) =>
      _$ConflictResolutionResponseFromJson(json);
}

@freezed
class SyncDownloadResponse with _$SyncDownloadResponse {
  const factory SyncDownloadResponse({
    required bool success,
    String? message,
    List<SyncUpdate>? updates,
    int? timestamp,
  }) = _SyncDownloadResponse;

  factory SyncDownloadResponse.fromJson(Map<String, dynamic> json) =>
      _$SyncDownloadResponseFromJson(json);
}

@freezed
class SyncUpdate with _$SyncUpdate {
  const factory SyncUpdate({
    required String id,
    required String entityType,
    required String entityId,
    required String operation,
    required Map<String, dynamic> data,
    required int timestamp,
  }) = _SyncUpdate;

  factory SyncUpdate.fromJson(Map<String, dynamic> json) =>
      _$SyncUpdateFromJson(json);
}

@freezed
class DeviceHeartbeatRequest with _$DeviceHeartbeatRequest {
  const factory DeviceHeartbeatRequest({
    required String deviceId,
    required int timestamp,
    required int pendingActionsCount,
    required String appVersion,
    String? userId,
  }) = _DeviceHeartbeatRequest;

  factory DeviceHeartbeatRequest.fromJson(Map<String, dynamic> json) =>
      _$DeviceHeartbeatRequestFromJson(json);
}

@freezed
class DeviceHeartbeatResponse with _$DeviceHeartbeatResponse {
  const factory DeviceHeartbeatResponse({
    required bool success,
    String? message,
    bool? forceSync,
    String? serverVersion,
  }) = _DeviceHeartbeatResponse;

  factory DeviceHeartbeatResponse.fromJson(Map<String, dynamic> json) =>
      _$DeviceHeartbeatResponseFromJson(json);
}

// Result classes for service methods
@freezed
class SyncResult with _$SyncResult {
  const factory SyncResult({
    required bool success,
    required String message,
    required int syncedCount,
    required int conflictCount,
    List<DataConflict>? conflicts,
  }) = _SyncResult;
}

@freezed
class SyncDownloadResult with _$SyncDownloadResult {
  const factory SyncDownloadResult({
    required bool success,
    required String message,
    required List<SyncUpdate> updates,
  }) = _SyncDownloadResult;
}

@freezed
class SyncStatus with _$SyncStatus {
  const factory SyncStatus({
    required bool isOnline,
    required int pendingActionsCount,
    required int pendingConflictsCount,
    required int lastSyncTimestamp,
    required String deviceId,
  }) = _SyncStatus;
}