package com.automed.sync.service

import com.automed.sync.dto.*
import org.springframework.kafka.core.KafkaTemplate
import org.springframework.stereotype.Service
import org.springframework.transaction.annotation.Transactional
import java.time.LocalDateTime
import java.util.*

@Service
@Transactional
class SyncService(
    private val kafkaTemplate: KafkaTemplate<String, Any>
) {

    fun processOfflineData(request: OfflineDataUploadRequest): SyncResponse {
        val processedActions = mutableListOf<String>()
        val conflicts = mutableListOf<DataConflictDto>()

        for (action in request.actions) {
            try {
                when (action.type.uppercase()) {
                    "CREATE" -> handleCreateAction(action)
                    "UPDATE" -> handleUpdateAction(action)
                    "DELETE" -> handleDeleteAction(action)
                }
                processedActions.add(action.id)

                // Publish sync event
                kafkaTemplate.send("sync-action-processed", mapOf(
                    "actionId" to action.id,
                    "deviceId" to request.deviceId,
                    "type" to action.type
                ))
            } catch (e: Exception) {
                // Handle conflict or error
                conflicts.add(DataConflictDto(
                    id = UUID.randomUUID().toString(),
                    entityType = action.entityType,
                    entityId = action.entityId,
                    localData = action.data,
                    serverData = mapOf("error" to e.message),
                    localTimestamp = action.timestamp,
                    serverTimestamp = System.currentTimeMillis(),
                    type = ConflictType.UPDATE_CONFLICT,
                    description = "Error processing action: ${e.message}"
                ))
            }
        }

        return SyncResponse(
            success = true,
            message = "Offline data processed successfully",
            processedActions = processedActions,
            conflicts = conflicts,
            timestamp = System.currentTimeMillis()
        )
    }

    fun getUpdatesForDevice(deviceId: String, lastSyncTimestamp: Long): SyncDownloadResponse {
        // Simulate getting updates since last sync
        val updates = listOf(
            SyncUpdateDto(
                id = UUID.randomUUID().toString(),
                entityType = "Patient",
                entityId = "patient-123",
                operation = "UPDATE",
                data = mapOf("name" to "Updated Name"),
                timestamp = System.currentTimeMillis()
            )
        )

        return SyncDownloadResponse(
            success = true,
            message = "Updates retrieved successfully",
            updates = updates,
            timestamp = System.currentTimeMillis()
        )
    }

    fun resolveConflicts(request: ConflictResolutionRequest): ConflictResolutionResponse {
        // Simulate conflict resolution
        val resolvedData = when (request.resolution.type) {
            ConflictResolutionType.USE_LOCAL -> mapOf("source" to "local")
            ConflictResolutionType.USE_SERVER -> mapOf("source" to "server")
            ConflictResolutionType.MERGE -> request.resolution.mergedData ?: emptyMap()
            ConflictResolutionType.SKIP -> emptyMap()
        }

        return ConflictResolutionResponse(
            success = true,
            message = "Conflict resolved successfully",
            resolvedData = resolvedData
        )
    }

    fun getConflictsForDevice(deviceId: String): List<DataConflict> {
        // Simulate getting conflicts
        return listOf(
            DataConflict(
                id = UUID.randomUUID().toString(),
                entityType = "Patient",
                entityId = "patient-123",
                localData = mapOf("name" to "Local Name"),
                serverData = mapOf("name" to "Server Name"),
                localTimestamp = System.currentTimeMillis() - 1000,
                serverTimestamp = System.currentTimeMillis(),
                type = ConflictType.UPDATE_CONFLICT,
                description = "Name conflict detected"
            )
        )
    }

    fun processHeartbeat(request: DeviceHeartbeatRequest): DeviceHeartbeatResponse {
        // Simulate heartbeat processing
        val forceSync = request.pendingActionsCount > 10

        return DeviceHeartbeatResponse(
            success = true,
            message = "Heartbeat processed",
            forceSync = forceSync,
            serverVersion = "1.0.0"
        )
    }

    fun getSyncStatus(deviceId: String): SyncStatusResponse {
        // Simulate sync status
        return SyncStatusResponse(
            deviceId = deviceId,
            isOnline = true,
            lastSyncTimestamp = System.currentTimeMillis() - 3600000,
            pendingActionsCount = 5,
            pendingConflictsCount = 2,
            serverTimestamp = System.currentTimeMillis()
        )
    }

    private fun handleCreateAction(action: SyncActionDto) {
        // Simulate creating entity
        kafkaTemplate.send("entity-created", mapOf(
            "entityType" to action.entityType,
            "entityId" to action.entityId,
            "data" to action.data
        ))
    }

    private fun handleUpdateAction(action: SyncActionDto) {
        // Simulate updating entity
        kafkaTemplate.send("entity-updated", mapOf(
            "entityType" to action.entityType,
            "entityId" to action.entityId,
            "data" to action.data
        ))
    }

    private fun handleDeleteAction(action: SyncActionDto) {
        // Simulate deleting entity
        kafkaTemplate.send("entity-deleted", mapOf(
            "entityType" to action.entityType,
            "entityId" to action.entityId
        ))
    }
}
