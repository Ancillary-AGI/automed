package com.automed.patient.dto

import com.automed.patient.domain.Address
import com.automed.patient.domain.BloodType
import com.automed.patient.domain.Gender
import com.automed.patient.domain.PatientStatus
import java.time.LocalDate
import java.time.LocalDateTime
import java.util.*

data class PatientResponse(
    val id: UUID,
    val patientId: String,
    val firstName: String,
    val lastName: String,
    val dateOfBirth: LocalDate,
    val gender: Gender,
    val email: String,
    val phoneNumber: String,
    val address: Address,
    val bloodType: BloodType,
    val allergies: Set<String>,
    val medicalConditions: Set<String>,
    val status: PatientStatus,
    val createdAt: LocalDateTime,
    val updatedAt: LocalDateTime
)