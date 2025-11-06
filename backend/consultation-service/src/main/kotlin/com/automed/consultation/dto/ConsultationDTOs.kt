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

data class CreateConsultationRequest(
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

data class UpdateConsultationRequest(
    val status: ConsultationStatus? = null,

    @field:Size(max = 1000)
    val notes: String? = null,

    @field:Size(max = 1000)
    val diagnosis: String? = null,

    @field:Size(max = 2000)
    val prescription: String? = null,

    val symptoms: Set<String>? = null,

    val vitals: Map<String, String>? = null,

    val priority: Priority? = null
) {
    fun getUpdatedFields(): Map<String, Any?> {
        val fields = mutableMapOf<String, Any?>()
        status?.let { fields["status"] = it }
        notes?.let { fields["notes"] = it }
        diagnosis?.let { fields["diagnosis"] = it }
        prescription?.let { fields["prescription"] = it }
        symptoms?.let { fields["symptoms"] = it }
        vitals?.let { fields["vitals"] = it }
        priority?.let { fields["priority"] = it }
        return fields
    }
}

data class ConsultationSessionResponse(
    val sessionId: String,
    val webrtcConfig: WebRTCConfig,
    val chatRoomId: String,
    val participants: List<ParticipantInfo>,
    val startedAt: LocalDateTime
)

data class SendMessageRequest(
    @field:NotBlank
    @field:Size(max = 1000)
    val content: String,

    val messageType: String = "text"
)

data class MessageResponse(
    val id: UUID,
    val consultationId: UUID,
    val senderId: UUID,
    val senderName: String,
    val content: String,
    val messageType: String,
    val timestamp: LocalDateTime
)

data class FileUploadRequest(
    @field:NotBlank
    val fileName: String,

    @field:NotBlank
    val fileType: String,

    @field:NotNull
    val fileSize: Long,

    val description: String? = null
)

data class FileUploadResponse(
    val fileId: UUID,
    val fileName: String,
    val fileUrl: String,
    val uploadedAt: LocalDateTime
)

data class RecordingResponse(
    val recordingId: UUID,
    val consultationId: UUID,
    val recordingUrl: String,
    val duration: Long,
    val fileSize: Long,
    val createdAt: LocalDateTime
)

data class CreatePrescriptionRequest(
    @field:NotBlank
    val medicationName: String,

    @field:NotBlank
    val dosage: String,

    @field:NotBlank
    val frequency: String,

    @field:NotNull
    val duration: Int,

    @field:Size(max = 1000)
    val instructions: String? = null,

    val quantity: Int? = null
)

data class PrescriptionResponse(
    val id: UUID,
    val consultationId: UUID,
    val medicationName: String,
    val dosage: String,
    val frequency: String,
    val duration: Int,
    val instructions: String?,
    val quantity: Int?,
    val prescribedAt: LocalDateTime
)

data class RescheduleConsultationRequest(
    @field:Future
    val newScheduledAt: LocalDateTime,

    @field:Size(max = 500)
    val reason: String? = null
)