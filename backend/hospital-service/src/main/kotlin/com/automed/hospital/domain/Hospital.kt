package com.automed.hospital.domain

import jakarta.persistence.*
import jakarta.validation.constraints.*
import org.springframework.data.annotation.CreatedDate
import org.springframework.data.annotation.LastModifiedDate
import org.springframework.data.jpa.domain.support.AuditingEntityListener
import java.time.LocalDateTime
import java.util.*

@Entity
@Table(name = "hospitals")
@EntityListeners(AuditingEntityListener::class)
data class Hospital(
    @Id
    @GeneratedValue(strategy = GenerationType.UUID)
    val id: UUID? = null,

    @Column(nullable = false, unique = true)
    @NotBlank
    val hospitalCode: String,

    @Column(nullable = false)
    @NotBlank
    @Size(max = 200)
    val name: String,

    @Column(nullable = false)
    @Enumerated(EnumType.STRING)
    val type: HospitalType,

    @Embedded
    val address: Address,

    @Column(nullable = false)
    @Pattern(regexp = "^\\+?[1-9]\\d{1,14}$")
    val phoneNumber: String,

    @Column(nullable = false)
    @Email
    val email: String,

    @Column
    val website: String?,

    @Column(nullable = false)
    val capacity: Int,

    @Column(nullable = false)
    val currentOccupancy: Int = 0,

    @Column(nullable = false)
    @Enumerated(EnumType.STRING)
    val status: HospitalStatus = HospitalStatus.ACTIVE,

    @ElementCollection
    @CollectionTable(name = "hospital_specialties")
    val specialties: Set<String> = emptySet(),

    @ElementCollection
    @CollectionTable(name = "hospital_certifications")
    val certifications: Set<String> = emptySet(),

    @CreatedDate
    @Column(nullable = false, updatable = false)
    val createdAt: LocalDateTime? = null,

    @LastModifiedDate
    @Column(nullable = false)
    val updatedAt: LocalDateTime? = null
)

@Entity
@Table(name = "staff")
@EntityListeners(AuditingEntityListener::class)
data class Staff(
    @Id
    @GeneratedValue(strategy = GenerationType.UUID)
    val id: UUID? = null,

    @Column(nullable = false)
    @NotNull
    val hospitalId: UUID,

    @Column(nullable = false)
    @NotBlank
    val employeeId: String,

    @Column(nullable = false)
    @NotBlank
    @Size(max = 100)
    val firstName: String,

    @Column(nullable = false)
    @NotBlank
    @Size(max = 100)
    val lastName: String,

    @Column(nullable = false)
    @Enumerated(EnumType.STRING)
    val role: StaffRole,

    @Column(nullable = false)
    @Enumerated(EnumType.STRING)
    val department: Department,

    @Column(nullable = false)
    @Email
    val email: String,

    @Column(nullable = false)
    @Pattern(regexp = "^\\+?[1-9]\\d{1,14}$")
    val phoneNumber: String,

    @Column
    val licenseNumber: String?,

    @ElementCollection
    @CollectionTable(name = "staff_specializations")
    val specializations: Set<String> = emptySet(),

    @Column(nullable = false)
    @Enumerated(EnumType.STRING)
    val status: StaffStatus = StaffStatus.ACTIVE,

    @CreatedDate
    @Column(nullable = false, updatable = false)
    val createdAt: LocalDateTime? = null,

    @LastModifiedDate
    @Column(nullable = false)
    val updatedAt: LocalDateTime? = null
)

@Entity
@Table(name = "equipment")
@EntityListeners(AuditingEntityListener::class)
data class Equipment(
    @Id
    @GeneratedValue(strategy = GenerationType.UUID)
    val id: UUID? = null,

    @Column(nullable = false)
    @NotNull
    val hospitalId: UUID,

    @Column(nullable = false)
    @NotBlank
    val equipmentCode: String,

    @Column(nullable = false)
    @NotBlank
    val name: String,

    @Column(nullable = false)
    @Enumerated(EnumType.STRING)
    val type: EquipmentType,

    @Column(nullable = false)
    val manufacturer: String,

    @Column(nullable = false)
    val model: String,

    @Column
    val serialNumber: String?,

    @Column(nullable = false)
    @Enumerated(EnumType.STRING)
    val status: EquipmentStatus,

    @Column
    val location: String?,

    @Column
    val lastMaintenanceDate: LocalDateTime?,

    @Column
    val nextMaintenanceDate: LocalDateTime?,

    @Column(length = 1000)
    val notes: String?,

    @CreatedDate
    @Column(nullable = false, updatable = false)
    val createdAt: LocalDateTime? = null,

    @LastModifiedDate
    @Column(nullable = false)
    val updatedAt: LocalDateTime? = null
)

@Embeddable
data class Address(
    @Column(nullable = false)
    @NotBlank
    val street: String,

    @Column(nullable = false)
    @NotBlank
    val city: String,

    @Column(nullable = false)
    @NotBlank
    val state: String,

    @Column(nullable = false)
    @NotBlank
    val country: String,

    @Column(nullable = false)
    @Pattern(regexp = "^[0-9]{5}(?:-[0-9]{4})?$")
    val zipCode: String,

    @Column
    val latitude: Double?,

    @Column
    val longitude: Double?
)

enum class HospitalType {
    GENERAL, SPECIALTY, EMERGENCY, CLINIC, RESEARCH, TEACHING
}

enum class HospitalStatus {
    ACTIVE, INACTIVE, MAINTENANCE, EMERGENCY_ONLY
}

enum class StaffRole {
    DOCTOR, NURSE, TECHNICIAN, ADMINISTRATOR, PHARMACIST, THERAPIST, SUPPORT
}

enum class Department {
    EMERGENCY, CARDIOLOGY, NEUROLOGY, ONCOLOGY, PEDIATRICS, SURGERY, 
    RADIOLOGY, LABORATORY, PHARMACY, ADMINISTRATION, ICU, MATERNITY
}

enum class StaffStatus {
    ACTIVE, INACTIVE, ON_LEAVE, SUSPENDED
}

enum class EquipmentType {
    DIAGNOSTIC, THERAPEUTIC, MONITORING, SURGICAL, LABORATORY, IMAGING, LIFE_SUPPORT
}

enum class EquipmentStatus {
    OPERATIONAL, MAINTENANCE, OUT_OF_ORDER, RETIRED
}