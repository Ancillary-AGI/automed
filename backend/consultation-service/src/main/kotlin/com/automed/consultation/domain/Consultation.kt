package com.automed.consultation.domain

import jakarta.persistence.*
import jakarta.validation.constraints.*
import org.springframework.data.annotation.CreatedDate
import org.springframework.data.annotation.LastModifiedDate
import org.springframework.data.jpa.domain.support.AuditingEntityListener
import java.time.LocalDateTime
import java.util.*

@Entity
@Table(name = "consultations")
@EntityListeners(AuditingEntityListener::class)
data class Consultation(
    @Id
    @GeneratedValue(strategy = GenerationType.UUID)
    val id: UUID? = null,

    @Column(nullable = false)
    @NotNull
    val patientId: UUID,

    @Column(nullable = false)
    @NotNull
    val doctorId: UUID,

    @Column(nullable = false)
    @NotNull
    val hospitalId: UUID,

    @Column(nullable = false)
    @Enumerated(EnumType.STRING)
    val type: ConsultationType,

    @Column(nullable = false)
    @Enumerated(EnumType.STRING)
    val status: ConsultationStatus = ConsultationStatus.SCHEDULED,

    @Column(nullable = false)
    val scheduledAt: LocalDateTime,

    @Column
    val startedAt: LocalDateTime? = null,

    @Column
    val endedAt: LocalDateTime? = null,

    @Column(length = 2000)
    val notes: String? = null,

    @Column(length = 1000)
    val diagnosis: String? = null,

    @Column(length = 2000)
    val prescription: String? = null,

    @Column
    val sessionId: String? = null,

    @Column
    val recordingUrl: String? = null,

    @ElementCollection
    @CollectionTable(name = "consultation_symptoms")
    val symptoms: Set<String> = emptySet(),

    @ElementCollection
    @CollectionTable(name = "consultation_vitals")
    val vitals: Map<String, String> = emptyMap(),

    @Column(nullable = false)
    @Enumerated(EnumType.STRING)
    val priority: Priority = Priority.NORMAL,

    @CreatedDate
    @Column(nullable = false, updatable = false)
    val createdAt: LocalDateTime? = null,

    @LastModifiedDate
    @Column(nullable = false)
    val updatedAt: LocalDateTime? = null
)

enum class ConsultationType {
    VIDEO_CALL, AUDIO_CALL, CHAT, IN_PERSON, EMERGENCY
}

enum class ConsultationStatus {
    SCHEDULED, IN_PROGRESS, COMPLETED, CANCELLED, NO_SHOW
}

enum class Priority {
    LOW, NORMAL, HIGH, CRITICAL, EMERGENCY
}