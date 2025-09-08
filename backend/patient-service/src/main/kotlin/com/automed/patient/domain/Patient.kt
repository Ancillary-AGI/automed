package com.automed.patient.domain

import jakarta.persistence.*
import jakarta.validation.constraints.*
import org.springframework.data.annotation.CreatedDate
import org.springframework.data.annotation.LastModifiedDate
import org.springframework.data.jpa.domain.support.AuditingEntityListener
import java.time.LocalDate
import java.time.LocalDateTime
import java.util.*

@Entity
@Table(name = "patients")
@EntityListeners(AuditingEntityListener::class)
data class Patient(
    @Id
    @GeneratedValue(strategy = GenerationType.UUID)
    val id: UUID? = null,

    @Column(nullable = false, unique = true)
    @NotBlank
    val patientId: String,

    @Column(nullable = false)
    @NotBlank
    @Size(max = 100)
    val firstName: String,

    @Column(nullable = false)
    @NotBlank
    @Size(max = 100)
    val lastName: String,

    @Column(nullable = false)
    @Past
    val dateOfBirth: LocalDate,

    @Column(nullable = false)
    @Enumerated(EnumType.STRING)
    val gender: Gender,

    @Column(nullable = false, unique = true)
    @Email
    val email: String,

    @Column(nullable = false)
    @Pattern(regexp = "^\\+?[1-9]\\d{1,14}$")
    val phoneNumber: String,

    @Embedded
    val address: Address,

    @Column(nullable = false)
    @Enumerated(EnumType.STRING)
    val bloodType: BloodType,

    @ElementCollection
    @CollectionTable(name = "patient_allergies")
    val allergies: Set<String> = emptySet(),

    @ElementCollection
    @CollectionTable(name = "patient_medical_conditions")
    val medicalConditions: Set<String> = emptySet(),

    @Column(nullable = false)
    @Enumerated(EnumType.STRING)
    val status: PatientStatus = PatientStatus.ACTIVE,

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
    val zipCode: String
)

enum class Gender {
    MALE, FEMALE, OTHER, PREFER_NOT_TO_SAY
}

enum class BloodType {
    A_POSITIVE, A_NEGATIVE,
    B_POSITIVE, B_NEGATIVE,
    AB_POSITIVE, AB_NEGATIVE,
    O_POSITIVE, O_NEGATIVE,
    UNKNOWN
}

enum class PatientStatus {
    ACTIVE, INACTIVE, DECEASED, UNKNOWN
}