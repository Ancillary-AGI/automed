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
