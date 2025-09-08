package com.automed.patient.event

import java.time.LocalDateTime
import java.util.*

data class PatientCreatedEvent(
    val patientId: UUID,
    val patientNumber: String,
    val firstName: String,
    val lastName: String,
    val email: String,
    val timestamp: LocalDateTime = LocalDateTime.now()
)

data class PatientUpdatedEvent(
    val patientId: UUID,
    val patientNumber: String,
    val updatedFields: Map<String, Any?>,
    val timestamp: LocalDateTime = LocalDateTime.now()
)

data class PatientDeletedEvent(
    val patientId: UUID,
    val patientNumber: String,
    val timestamp: LocalDateTime = LocalDateTime.now()
)