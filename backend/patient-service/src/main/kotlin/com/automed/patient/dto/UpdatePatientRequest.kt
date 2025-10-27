package com.automed.patient.dto

import com.automed.patient.domain.Address
import com.automed.patient.domain.BloodType
import com.automed.patient.domain.Gender
import com.automed.patient.domain.PatientStatus
import jakarta.validation.Valid
import jakarta.validation.constraints.*
import java.time.LocalDate

data class UpdatePatientRequest(
    @field:Size(max = 100)
    val firstName: String? = null,

    @field:Size(max = 100)
    val lastName: String? = null,

    @field:Past
    val dateOfBirth: LocalDate? = null,

    val gender: Gender? = null,

    @field:Email
    val email: String? = null,

    @field:Pattern(regexp = "^\\+?[1-9]\\d{1,14}$")
    val phoneNumber: String? = null,

    @field:Valid
    val address: Address? = null,

    val bloodType: BloodType? = null,

    val allergies: Set<String>? = null,

    val medicalConditions: Set<String>? = null,

    val status: PatientStatus? = null
) {
    fun getUpdatedFields(): Map<String, Any?> {
        val fields = mutableMapOf<String, Any?>()
        firstName?.let { fields["firstName"] = it }
        lastName?.let { fields["lastName"] = it }
        dateOfBirth?.let { fields["dateOfBirth"] = it }
        gender?.let { fields["gender"] = it }
        email?.let { fields["email"] = it }
        phoneNumber?.let { fields["phoneNumber"] = it }
        address?.let { fields["address"] = it }
        bloodType?.let { fields["bloodType"] = it }
        allergies?.let { fields["allergies"] = it }
        medicalConditions?.let { fields["medicalConditions"] = it }
        status?.let { fields["status"] = it }
        return fields
    }
}