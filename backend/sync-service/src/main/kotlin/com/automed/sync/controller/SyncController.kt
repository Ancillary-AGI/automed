package com.automed.sync.controller

import com.automed.sync.dto.*
import com.automed.sync.service.SyncService
import jakarta.validation.Valid
import org.springframework.http.ResponseEntity
import org.springframework.security.access.prepost.PreAuthorize
import org.springframework.web.bind.annotation.*
import java.util.*

@RestController
@RequestMapping("/api/v1/sync")
@CrossOrigin(origins = ["*"])
class SyncController(
    private val syncService: SyncService
) {

    @PostMapping("/upload")
    @PreAuthorize("hasRole('HEALTHCARE_PROVIDER') or hasRole('PATIENT')")
    fun uploadOfflineData(@Valid @RequestBody request: OfflineDataUploadRequest): ResponseEntity<SyncResponse> {
        val response = syncService.processOfflineData(request)
        return ResponseEntity.ok(response)
    }

    @GetMapping("/download/{deviceId}")
    @PreAuthorize("hasRole('HEALTHCARE_PROVIDER') or hasRole('PATIENT')")
    fun downloadUpdates(
        @PathVariable deviceId: String,
        @RequestParam lastSyncTimestamp: Long
    ): ResponseEntity<SyncDownloadResponse> {
        val response = syncService.getUpdatesForDevice(deviceId, lastSyncTimestamp)
        return ResponseEntity.ok(response)
    }

    @PostMapping("/resolve-conflicts")
    @PreAuthorize("hasRole('HEALTHCARE_PROVIDER')")
    fun resolveConflicts(@Valid @RequestBody request: ConflictResolutionRequest): ResponseEntity<ConflictResolutionResponse> {
        val response = syncService.resolveConflicts(request)
        return ResponseEntity.ok(response)
    }

    @GetMapping("/conflicts/{deviceId}")
    @PreAuthorize("hasRole('HEALTHCARE_PROVIDER') or hasRole('PATIENT')")
    fun getConflicts(@PathVariable deviceId: String): ResponseEntity<List<DataConflict>> {
        val conflicts = syncService.getConflictsForDevice(deviceId)
        return ResponseEntity.ok(conflicts)
    }

    @PostMapping("/heartbeat")
    @PreAuthorize("hasRole('HEALTHCARE_PROVIDER') or hasRole('PATIENT')")
    fun deviceHeartbeat(@Valid @RequestBody request: DeviceHeartbeatRequest): ResponseEntity<DeviceHeartbeatResponse> {
        val response = syncService.processHeartbeat(request)
        return ResponseEntity.ok(response)
    }

    @GetMapping("/status/{deviceId}")
    @PreAuthorize("hasRole('HEALTHCARE_PROVIDER') or hasRole('PATIENT')")
    fun getSyncStatus(@PathVariable deviceId: String): ResponseEntity<SyncStatusResponse> {
        val status = syncService.getSyncStatus(deviceId)
        return ResponseEntity.ok(status)
    }
}