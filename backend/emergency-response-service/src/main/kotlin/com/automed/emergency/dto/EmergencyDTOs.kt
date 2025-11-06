package com.automed.emergency.dto

import com.automed.emergency.model.*
import java.time.LocalDateTime
import java.time.Duration

// Request DTOs
data class CreateEmergencyAlertRequest(
    val type: EmergencyType,
    val location: String,
    val description: String,
    val reportedBy: String,
    val patientId: String? = null,
    val severity: Int? = null
)

data class EmergencyResponseRequest(
    val responderId: String,
    val status: EmergencyStatus? = null,
    val resourcesAllocated: List<String> = emptyList(),
    val notes: String? = null
)

data class CreateEmergencyProtocolRequest(
    val type: EmergencyType,
    val name: String,
    val description: String,
    val steps: List<ProtocolStepRequest>,
    val triggers: List<String>,
    val resources: List<String>
)

data class ProtocolStepRequest(
    val order: Int,
    val title: String,
    val description: String,
    val duration: Duration,
    val responsibleRole: String,
    val requiredResources: List<String>,
    val checklist: List<String>
)

data class ScheduleEmergencyDrillRequest(
    val type: EmergencyType,
    val title: String,
    val description: String,
    val scheduledDate: LocalDateTime,
    val duration: Duration,
    val participants: List<String>,
    val objectives: List<String>
)

data class EmergencyResourceAllocationRequest(
    val emergencyId: String,
    val resources: List<ResourceRequest>,
    val allocatedBy: String,
    val notes: String? = null
)

data class ResourceRequest(
    val resourceId: String,
    val type: String,
    val quantity: Int,
    val expectedDuration: Duration? = null
)

// Response DTOs
data class EmergencyAlertResponse(
    val id: String,
    val type: EmergencyType,
    val priority: EmergencyPriority,
    val status: EmergencyStatus,
    val location: String,
    val description: String,
    val reportedBy: String,
    val patientId: String?,
    val responderIds: List<String>,
    val resourcesAllocated: List<String>,
    val timeline: List<EmergencyTimelineEntry>,
    val createdAt: LocalDateTime,
    val updatedAt: LocalDateTime
) {
    companion object {
        fun fromEntity(entity: EmergencyAlert): EmergencyAlertResponse {
            return EmergencyAlertResponse(
                id = entity.id,
                type = entity.type,
                priority = entity.priority,
                status = entity.status,
                location = entity.location,
                description = entity.description,
                reportedBy = entity.reportedBy,
                patientId = entity.patientId,
                responderIds = entity.responderIds,
                resourcesAllocated = entity.resourcesAllocated,
                timeline = entity.timeline,
                createdAt = entity.createdAt,
                updatedAt = entity.updatedAt
            )
        }
    }
}

data class EmergencyProtocolResponse(
    val id: String,
    val type: EmergencyType,
    val name: String,
    val description: String,
    val steps: List<EmergencyProtocolStep>,
    val triggers: List<String>,
    val resources: List<String>,
    val isActive: Boolean,
    val createdAt: LocalDateTime,
    val updatedAt: LocalDateTime
) {
    companion object {
        fun fromEntity(entity: EmergencyProtocol): EmergencyProtocolResponse {
            return EmergencyProtocolResponse(
                id = entity.id,
                type = entity.type,
                name = entity.name,
                description = entity.description,
                steps = entity.steps,
                triggers = entity.triggers,
                resources = entity.resources,
                isActive = entity.isActive,
                createdAt = entity.createdAt,
                updatedAt = entity.updatedAt
            )
        }
    }
}

data class EmergencyDrillResponse(
    val id: String,
    val type: EmergencyType,
    val title: String,
    val description: String,
    val scheduledDate: LocalDateTime,
    val duration: Duration,
    val participants: List<String>,
    val objectives: List<String>,
    val status: DrillStatus,
    val createdAt: LocalDateTime,
    val updatedAt: LocalDateTime
) {
    companion object {
        fun fromEntity(entity: EmergencyDrill): EmergencyDrillResponse {
            return EmergencyDrillResponse(
                id = entity.id,
                type = entity.type,
                title = entity.title,
                description = entity.description,
                scheduledDate = entity.scheduledDate,
                duration = entity.duration,
                participants = entity.participants,
                objectives = entity.objectives,
                status = entity.status,
                createdAt = entity.createdAt,
                updatedAt = entity.updatedAt
            )
        }
    }
}

data class EmergencyResourceAllocationResponse(
    val allocationId: String,
    val emergencyId: String,
    val resources: List<AllocatedResource>,
    val allocatedBy: String,
    val allocatedAt: LocalDateTime,
    val availableResources: List<AvailableResource>
)

data class AvailableResource(
    val resourceId: String,
    val type: String,
    val available: Boolean,
    val availableQuantity: Int
)

data class EmergencyAnalyticsResponse(
    val totalAlerts: Int,
    val resolvedAlerts: Int,
    val resolutionRate: Double,
    val averageResponseTime: Double,
    val alertsByType: Map<EmergencyType, Int>,
    val alertsByPriority: Map<EmergencyPriority, Int>,
    val period: AnalyticsPeriod
)

data class AnalyticsPeriod(
    val startDate: LocalDateTime,
    val endDate: LocalDateTime
)