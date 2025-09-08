package com.automed.sync.dto

import jakarta.validation.constraints.*
import java.util.*

data class OfflineDataUploadRequest(
    @field:NotBlank
    val deviceId: String,

    @field:NotEmpty
    val actions: List<SyncActionDto>,

    @field:NotNull
    val timestamp: Long,

    val userId: String? = null
)

data class SyncActionDto(
    @field:NotBlank
    val id: String,

    @field:NotBlank
    val type: String,

    @field:NotBlank
    val entityType: String,

    @field:NotBlank
    val entityId: String,

    @field:NotEmpty
    val data: Map<String, Any>,

    @field:NotNull
    val timestamp: Long,

    val userId: String? = null,
    val deviceId: String? = null
)

data class SyncResponse(
    val success: Boolean,
    val message: String? = null,
    val processedActions: List<String>? = null,
    val conflicts: List<DataConflictDto>? = null,
    val timestamp: Long? = null
)

data class DataConflictDto(
    val id: String,
    val entityType: String,
    val entityId: String,
    val localData: Map<String, Any>,
    val serverData: Map<String, Any>,
    val localTimestamp: Long,
    val serverTimestamp: Long,
    val type: ConflictType,
    val description: String? = null
)

enum class ConflictType {
    UPDATE_CONFLICT, DELETE_CONFLICT, CREATE_CONFLICT
}

data class ConflictResolutionRequest(
    @field:NotBlank
    val conflictId: String,

    @field:NotNull
    val resolution: ConflictResolutionDto,

    @field:NotBlank
    val deviceId: String,

    val userId: String? = null
)

data class ConflictResolutionDto(
    @field:NotNull
    val type: ConflictResolutionType,

    val mergedData: Map<String, Any>? = null,
    val notes: String? = null
)

enum class ConflictResolutionType {
    USE_LOCAL, USE_SERVER, MERGE, SKIP
}

data class ConflictResolutionResponse(
    val success: Boolean,
    val message: String? = null,
    val resolvedData: Map<String, Any>? = null
)

data class SyncDownloadResponse(
    val success: Boolean,
    val message: String? = null,
    val updates: List<SyncUpdateDto>? = null,
    val timestamp: Long? = null
)

data class SyncUpdateDto(
    val id: String,
    val entityType: String,
    val entityId: String,
    val operation: String,
    val data: Map<String, Any>,
    val timestamp: Long
)

data class DeviceHeartbeatRequest(
    @field:NotBlank
    val deviceId: String,

    @field:NotNull
    val timestamp: Long,

    @field:Min(0)
    val pendingActionsCount: Int,

    @field:NotBlank
    val appVersion: String,

    val userId: String? = null
)

data class DeviceHeartbeatResponse(
    val success: Boolean,
    val message: String? = null,
    val forceSync: Boolean? = null,
    val serverVersion: String? = null
)

data class SyncStatusResponse(
    val deviceId: String,
    val isOnline: Boolean,
    val lastSyncTimestamp: Long,
    val pendingActionsCount: Int,
    val pendingConflictsCount: Int,
    val serverTimestamp: Long
)