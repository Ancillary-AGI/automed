package com.automed.emergency.model

import jakarta.persistence.*
import java.time.LocalDateTime
import java.time.Duration

// Enums
enum class EmergencyType {
    CARDIAC_ARREST,
    STROKE,
    SEPSIS,
    TRAUMA,
    RESPIRATORY_DISTRESS,
    ALLERGIC_REACTION,
    POISONING,
    BURNS,
    ELECTRICAL_INJURY,
    DROWNING,
    FIRE,
    ACTIVE_SHOOTER,
    CHEMICAL_SPILL,
    RADIATION_EXPOSURE,
    MASS_CASUALTY,
    OTHER
}

enum class EmergencyPriority {
    CRITICAL,
    HIGH,
    MEDIUM,
    LOW
}

enum class EmergencyStatus {
    ACTIVE,
    RESPONDING,
    CONTAINED,
    RESOLVED,
    CANCELLED
}

enum class DrillStatus {
    SCHEDULED,
    IN_PROGRESS,
    COMPLETED,
    CANCELLED
}

enum class ResourceStatus {
    AVAILABLE,
    ALLOCATED,
    IN_USE,
    MAINTENANCE,
    OUT_OF_SERVICE
}

// Entities
@Entity
@Table(name = "emergency_alerts")
data class EmergencyAlert(
    @Id
    val id: String,
    val type: EmergencyType,
    val priority: EmergencyPriority,
    val status: EmergencyStatus,
    val location: String,
    val description: String,
    val reportedBy: String,
    val patientId: String? = null,
    @ElementCollection
    val responderIds: MutableList<String> = mutableListOf(),
    @ElementCollection
    val resourcesAllocated: MutableList<String> = mutableListOf(),
    @ElementCollection
    val timeline: MutableList<EmergencyTimelineEntry> = mutableListOf(),
    val createdAt: LocalDateTime,
    val updatedAt: LocalDateTime
)

@Embeddable
data class EmergencyTimelineEntry(
    val timestamp: LocalDateTime,
    val action: String,
    val actor: String,
    val details: String
)

@Entity
@Table(name = "emergency_protocols")
data class EmergencyProtocol(
    @Id
    val id: String,
    val type: EmergencyType,
    val name: String,
    val description: String,
    @ElementCollection
    val steps: List<EmergencyProtocolStep>,
    @ElementCollection
    val triggers: List<String>,
    @ElementCollection
    val resources: List<String>,
    val isActive: Boolean = true,
    val createdAt: LocalDateTime,
    val updatedAt: LocalDateTime
)

@Embeddable
data class EmergencyProtocolStep(
    val id: String,
    val order: Int,
    val title: String,
    val description: String,
    val duration: Duration,
    val responsibleRole: String,
    @ElementCollection
    val requiredResources: List<String>,
    @ElementCollection
    val checklist: List<String>
)

@Entity
@Table(name = "emergency_drills")
data class EmergencyDrill(
    @Id
    val id: String,
    val type: EmergencyType,
    val title: String,
    val description: String,
    val scheduledDate: LocalDateTime,
    val duration: Duration,
    @ElementCollection
    val participants: List<String>,
    @ElementCollection
    val objectives: List<String>,
    val status: DrillStatus,
    val createdAt: LocalDateTime,
    val updatedAt: LocalDateTime
)

@Entity
@Table(name = "resource_allocations")
data class EmergencyResourceAllocation(
    @Id
    val id: String,
    val emergencyId: String,
    @ElementCollection
    val resources: List<AllocatedResource>,
    val allocatedBy: String,
    val notes: String? = null,
    val createdAt: LocalDateTime
)

@Embeddable
data class AllocatedResource(
    val resourceId: String,
    val type: String,
    val quantity: Int,
    val allocatedAt: LocalDateTime,
    val expectedReturn: LocalDateTime? = null
)

// Analytics Models
data class EmergencyMetrics(
    val totalAlerts: Int,
    val responseTime: Double,
    val resolutionRate: Double,
    val resourceUtilization: Double,
    val drillPerformance: Double
)

data class EmergencyTrend(
    val date: LocalDateTime,
    val alertCount: Int,
    val averageResponseTime: Double,
    val resolutionRate: Double
)