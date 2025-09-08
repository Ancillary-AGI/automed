package com.automed.consultation.dto

import com.automed.consultation.domain.ConsultationStatus
import com.automed.consultation.domain.ConsultationType
import com.automed.consultation.domain.Priority
import jakarta.validation.constraints.*
import java.time.LocalDateTime
import java.util.*

data class ScheduleConsultationRequest(
    @field:NotNull
    val patientId: UUID,

    @field:NotNull
    val doctorId: UUID,

    @field:NotNull
    val hospitalId: UUID,

    @field:NotNull
    val type: ConsultationType,

    @field:Future
    val scheduledAt: LocalDateTime,

    val priority: Priority = Priority.NORMAL,

    @field:Size(max = 1000)
    val notes: String? = null
)

data class ConsultationResponse(
    val id: UUID,
    val patientId: UUID,
    val doctorId: UUID,
    val hospitalId: UUID,
    val type: ConsultationType,
    val status: ConsultationStatus,
    val scheduledAt: LocalDateTime,
    val startedAt: LocalDateTime?,
    val endedAt: LocalDateTime?,
    val notes: String?,
    val diagnosis: String?,
    val prescription: String?,
    val sessionId: String?,
    val recordingUrl: String?,
    val symptoms: Set<String>,
    val vitals: Map<String, String>,
    val priority: Priority,
    val createdAt: LocalDateTime,
    val updatedAt: LocalDateTime
)

data class EndConsultationRequest(
    @field:Size(max = 2000)
    val notes: String?,

    @field:Size(max = 1000)
    val diagnosis: String?,

    @field:Size(max = 2000)
    val prescription: String?
)

data class JoinConsultationResponse(
    val sessionId: String,
    val webrtcConfig: WebRTCConfig,
    val chatRoomId: String,
    val participants: List<ParticipantInfo>
)

data class WebRTCConfig(
    val iceServers: List<IceServer>,
    val signalingUrl: String
)

data class IceServer(
    val urls: List<String>,
    val username: String? = null,
    val credential: String? = null
)

data class ParticipantInfo(
    val id: UUID,
    val name: String,
    val role: String,
    val isOnline: Boolean
)