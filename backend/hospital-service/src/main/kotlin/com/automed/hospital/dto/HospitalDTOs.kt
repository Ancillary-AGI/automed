package com.automed.hospital.dto

import com.automed.hospital.domain.*
import jakarta.validation.Valid
import jakarta.validation.constraints.*
import java.time.LocalDateTime
import java.util.*

data class CreateHospitalRequest(
    @field:NotBlank
    @field:Size(max = 200)
    val name: String,

    @field:NotNull
    val type: HospitalType,

    @field:Valid
    val address: Address,

    @field:Pattern(regexp = "^\\+?[1-9]\\d{1,14}$")
    val phoneNumber: String,

    @field:Email
    val email: String,

    val website: String?,

    @field:Min(1)
    val capacity: Int,

    val specialties: Set<String> = emptySet(),

    val certifications: Set<String> = emptySet()
)

data class UpdateHospitalRequest(
    @field:Size(max = 200)
    val name: String?,

    val type: HospitalType?,

    @field:Valid
    val address: Address?,

    @field:Pattern(regexp = "^\\+?[1-9]\\d{1,14}$")
    val phoneNumber: String?,

    @field:Email
    val email: String?,

    val website: String?,

    @field:Min(1)
    val capacity: Int?,

    val specialties: Set<String>?,

    val certifications: Set<String>?,

    val status: HospitalStatus?
) {
    fun getUpdatedFields(): Map<String, Any?> {
        val fields = mutableMapOf<String, Any?>()
        name?.let { fields["name"] = it }
        type?.let { fields["type"] = it }
        address?.let { fields["address"] = it }
        phoneNumber?.let { fields["phoneNumber"] = it }
        email?.let { fields["email"] = it }
        website?.let { fields["website"] = it }
        capacity?.let { fields["capacity"] = it }
        specialties?.let { fields["specialties"] = it }
        certifications?.let { fields["certifications"] = it }
        status?.let { fields["status"] = it }
        return fields
    }
}

data class HospitalResponse(
    val id: UUID,
    val hospitalCode: String,
    val name: String,
    val type: HospitalType,
    val address: Address,
    val phoneNumber: String,
    val email: String,
    val website: String?,
    val capacity: Int,
    val currentOccupancy: Int,
    val status: HospitalStatus,
    val specialties: Set<String>,
    val certifications: Set<String>,
    val createdAt: LocalDateTime,
    val updatedAt: LocalDateTime
)

data class CreateStaffRequest(
    @field:NotBlank
    val employeeId: String,

    @field:NotBlank
    @field:Size(max = 100)
    val firstName: String,

    @field:NotBlank
    @field:Size(max = 100)
    val lastName: String,

    @field:NotNull
    val role: StaffRole,

    @field:NotNull
    val department: Department,

    @field:Email
    val email: String,

    @field:Pattern(regexp = "^\\+?[1-9]\\d{1,14}$")
    val phoneNumber: String,

    val licenseNumber: String?,

    val specializations: Set<String> = emptySet()
)

data class UpdateStaffRequest(
    @field:Size(max = 100)
    val firstName: String?,

    @field:Size(max = 100)
    val lastName: String?,

    val role: StaffRole?,

    val department: Department?,

    @field:Email
    val email: String?,

    @field:Pattern(regexp = "^\\+?[1-9]\\d{1,14}$")
    val phoneNumber: String?,

    val licenseNumber: String?,

    val specializations: Set<String>?,

    val status: StaffStatus?
)

data class StaffResponse(
    val id: UUID,
    val hospitalId: UUID,
    val employeeId: String,
    val firstName: String,
    val lastName: String,
    val role: StaffRole,
    val department: Department,
    val email: String,
    val phoneNumber: String,
    val licenseNumber: String?,
    val specializations: Set<String>,
    val status: StaffStatus,
    val createdAt: LocalDateTime,
    val updatedAt: LocalDateTime
)

data class CreateEquipmentRequest(
    @field:NotBlank
    val equipmentCode: String,

    @field:NotBlank
    val name: String,

    @field:NotNull
    val type: EquipmentType,

    @field:NotBlank
    val manufacturer: String,

    @field:NotBlank
    val model: String,

    val serialNumber: String?,

    val location: String?,

    val notes: String?
)

data class UpdateEquipmentRequest(
    val name: String?,

    val type: EquipmentType?,

    val manufacturer: String?,

    val model: String?,

    val serialNumber: String?,

    val location: String?,

    val status: EquipmentStatus?,

    val notes: String?
)

data class EquipmentResponse(
    val id: UUID,
    val hospitalId: UUID,
    val equipmentCode: String,
    val name: String,
    val type: EquipmentType,
    val manufacturer: String,
    val model: String,
    val serialNumber: String?,
    val status: EquipmentStatus,
    val location: String?,
    val lastMaintenanceDate: LocalDateTime?,
    val nextMaintenanceDate: LocalDateTime?,
    val notes: String?,
    val createdAt: LocalDateTime,
    val updatedAt: LocalDateTime
)

data class HospitalDashboardResponse(
    val hospitalId: UUID,
    val totalPatients: Long,
    val activeConsultations: Long,
    val availableBeds: Int,
    val staffOnDuty: Long,
    val equipmentOperational: Long,
    val equipmentMaintenance: Long,
    val recentAlerts: List<String>,
    val occupancyRate: Double
)

data class HospitalCapacityResponse(
    val hospitalId: UUID,
    val totalBeds: Int,
    val occupiedBeds: Int,
    val availableBeds: Int,
    val occupancyRate: Double,
    val icuBeds: Int,
    val icuOccupied: Int,
    val emergencyBeds: Int,
    val emergencyOccupied: Int,
    val lastUpdated: LocalDateTime
)

data class HospitalMetricsResponse(
    val hospitalId: UUID,
    val averageWaitTime: Long, // in minutes
    val patientSatisfaction: Double, // 0-5 scale
    val staffUtilization: Double, // percentage
    val equipmentUptime: Double, // percentage
    val emergencyResponseTime: Long, // in minutes
    val readmissionRate: Double, // percentage
    val infectionRate: Double, // percentage
    val period: String, // e.g., "LAST_30_DAYS"
    val lastUpdated: LocalDateTime
)

data class CreateEmergencyAlertRequest(
    @field:NotBlank
    @field:Size(max = 200)
    val title: String,

    @field:NotBlank
    @field:Size(max = 1000)
    val description: String,

    @field:NotNull
    val severity: AlertSeverity,

    @field:NotNull
    val alertType: AlertType,

    val affectedDepartments: Set<Department> = emptySet(),

    val requiredResources: Set<String> = emptySet()
)

data class EmergencyAlertResponse(
    val id: UUID,
    val hospitalId: UUID,
    val title: String,
    val description: String,
    val severity: AlertSeverity,
    val alertType: AlertType,
    val status: AlertStatus,
    val affectedDepartments: Set<Department>,
    val requiredResources: Set<String>,
    val createdBy: UUID,
    val acknowledgedBy: Set<UUID>,
    val resolvedAt: LocalDateTime?,
    val createdAt: LocalDateTime,
    val updatedAt: LocalDateTime
)

enum class AlertSeverity {
    LOW, MEDIUM, HIGH, CRITICAL
}

enum class AlertType {
    MEDICAL_EMERGENCY, EQUIPMENT_FAILURE, STAFF_SHORTAGE,
    RESOURCE_SHORTAGE, SECURITY_INCIDENT, NATURAL_DISASTER,
    INFRASTRUCTURE_FAILURE, OTHER
}

enum class AlertStatus {
    ACTIVE, ACKNOWLEDGED, RESOLVED, CANCELLED
}
