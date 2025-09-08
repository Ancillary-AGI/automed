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
    val firstName: String?,

    @field:Size(max = 100)
    val lastName: String?,

    @field:Past
    val dateOfBirth: LocalDate?,

    val gender: Gender?,

    @field:Email
    val email: String?,

    @field:Pattern(regexp = "^\\+?[1-9]\\d{1,14}$")
    val phoneNumber: String?,

    @field:Valid
    val address: Address?,

    val bloodType: BloodType?,

    val allergies: Set<String>?,

    val medicalConditions: Set<String>?,

    val status: PatientStatus?
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