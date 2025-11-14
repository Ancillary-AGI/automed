package com.automed.patient.dto

import com.automed.patient.domain.Address
import com.automed.patient.domain.BloodType
import com.automed.patient.domain.Gender
import jakarta.validation.Valid
import jakarta.validation.constraints.*
import java.time.LocalDate

data class CreatePatientRequest(
    @field:NotBlank
    @field:Size(max = 100)
    val firstName: String,

    @field:NotBlank
    @field:Size(max = 100)
    val lastName: String,

    @field:Past
    val dateOfBirth: LocalDate,

    @field:NotNull
    val gender: Gender,

    @field:Email
    val email: String,

    @field:Pattern(regexp = "^\\+?[1-9]\\d{1,14}$")
    val phoneNumber: String,

    @field:Valid
    val address: Address,

    @field:NotNull
    val bloodType: BloodType,

    val allergies: Set<String> = emptySet(),
    val medicalConditions: Set<String> = emptySet(),

    val medicalHistory: String? = null
)