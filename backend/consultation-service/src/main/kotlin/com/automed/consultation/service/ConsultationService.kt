package com.automed.consultation.service

import com.automed.consultation.domain.*
import com.automed.consultation.dto.*
import com.automed.consultation.exception.ConsultationNotFoundException
import com.automed.consultation.repository.*
import org.springframework.data.domain.Page
import org.springframework.data.domain.Pageable
import org.springframework.kafka.core.KafkaTemplate
import org.springframework.stereotype.Service
import org.springframework.transaction.annotation.Transactional
import reactor.core.publisher.Mono
import java.time.LocalDateTime
import java.util.*

@Service
class ConsultationService(
    private val consultationRepository: ConsultationRepository,
    private val messageRepository: MessageRepository,
    private val fileUploadRepository: FileUploadRepository,
    private val recordingRepository: RecordingRepository,
    private val prescriptionRepository: PrescriptionRepository,
    private val kafkaTemplate: KafkaTemplate<String, Any>
) {

    fun createConsultation(request: CreateConsultationRequest): Mono<ConsultationResponse> {
        return Mono.fromCallable {
            val consultation = Consultation(
                patientId = request.patientId,
                doctorId = request.doctorId,
                hospitalId = request.hospitalId,
                type = request.type,
                status = ConsultationStatus.SCHEDULED,
                scheduledAt = request.scheduledAt,
                priority = request.priority,
                notes = request.notes
            )

            val savedConsultation = consultationRepository.save(consultation)

            // Publish event
            kafkaTemplate.send("consultation-created", mapOf(
                "consultationId" to savedConsultation.id,
                "patientId" to savedConsultation.patientId,
                "doctorId" to savedConsultation.doctorId,
                "scheduledAt" to savedConsultation.scheduledAt
            ))

            mapToResponse(savedConsultation)
        }
    }

    fun getConsultation(id: UUID): Mono<ConsultationResponse> {
        return Mono.fromCallable {
            val consultation = consultationRepository.findById(id)
                .orElseThrow { ConsultationNotFoundException("Consultation not found with id: $id") }
            mapToResponse(consultation)
        }
    }

    fun getAllConsultations(
        pageable: Pageable,
        status: String?,
        patientId: String?,
        providerId: String?
    ): Mono<Page<ConsultationResponse>> {
        return Mono.fromCallable {
            val consultations = when {
                patientId != null -> consultationRepository.findByPatientId(UUID.fromString(patientId), pageable)
                providerId != null -> consultationRepository.findByDoctorId(UUID.fromString(providerId), pageable)
                status != null -> consultationRepository.findByStatus(
                    ConsultationStatus.valueOf(status.uppercase()), pageable
                )
                else -> consultationRepository.findAll(pageable)
            }
            consultations.map { mapToResponse(it) }
        }
    }

    fun updateConsultation(id: UUID, request: UpdateConsultationRequest): Mono<ConsultationResponse> {
        return Mono.fromCallable {
            val consultation = consultationRepository.findById(id)
                .orElseThrow { ConsultationNotFoundException("Consultation not found with id: $id") }

            val updatedConsultation = consultation.copy(
                status = request.status ?: consultation.status,
                notes = request.notes ?: consultation.notes,
                diagnosis = request.diagnosis ?: consultation.diagnosis,
                prescription = request.prescription ?: consultation.prescription,
                symptoms = request.symptoms ?: consultation.symptoms,
                vitals = request.vitals ?: consultation.vitals,
                priority = request.priority ?: consultation.priority
            )

            val savedConsultation = consultationRepository.save(updatedConsultation)

            // Publish event
            kafkaTemplate.send("consultation-updated", mapOf(
                "consultationId" to savedConsultation.id,
                "updatedFields" to request.getUpdatedFields()
            ))

            mapToResponse(savedConsultation)
        }
    }

    fun startConsultation(id: UUID): Mono<ConsultationSessionResponse> {
        return Mono.fromCallable {
            val consultation = consultationRepository.findById(id)
                .orElseThrow { ConsultationNotFoundException("Consultation not found with id: $id") }

            if (consultation.status != ConsultationStatus.SCHEDULED) {
                throw IllegalStateException("Consultation must be scheduled to start")
            }

            val updatedConsultation = consultation.copy(
                status = ConsultationStatus.IN_PROGRESS,
                startedAt = LocalDateTime.now(),
                sessionId = generateSessionId()
            )

            val savedConsultation = consultationRepository.save(updatedConsultation)

            // Publish event
            kafkaTemplate.send("consultation-started", mapOf(
                "consultationId" to savedConsultation.id,
                "sessionId" to savedConsultation.sessionId
            ))

            ConsultationSessionResponse(
                sessionId = savedConsultation.sessionId!!,
                webrtcConfig = WebRTCConfig(
                    iceServers = listOf(
                        IceServer(
                            urls = listOf("stun:stun.l.google.com:19302"),
                            username = null,
                            credential = null
                        )
                    ),
                    signalingUrl = "ws://localhost:8082/signaling"
                ),
                chatRoomId = "room-${savedConsultation.id}",
                participants = listOf(
                    ParticipantInfo(
                        id = savedConsultation.patientId,
                        name = "Patient",
                        role = "PATIENT",
                        isOnline = true
                    ),
                    ParticipantInfo(
                        id = savedConsultation.doctorId,
                        name = "Doctor",
                        role = "DOCTOR",
                        isOnline = true
                    )
                ),
                startedAt = savedConsultation.startedAt!!
            )
        }
    }

    fun joinConsultation(id: UUID): Mono<ConsultationSessionResponse> {
        return Mono.fromCallable {
            val consultation = consultationRepository.findById(id)
                .orElseThrow { ConsultationNotFoundException("Consultation not found with id: $id") }

            if (consultation.status != ConsultationStatus.IN_PROGRESS) {
                throw IllegalStateException("Consultation must be in progress to join")
            }

            ConsultationSessionResponse(
                sessionId = consultation.sessionId!!,
                webrtcConfig = WebRTCConfig(
                    iceServers = listOf(
                        IceServer(
                            urls = listOf("stun:stun.l.google.com:19302"),
                            username = null,
                            credential = null
                        )
                    ),
                    signalingUrl = "ws://localhost:8082/signaling"
                ),
                chatRoomId = "room-${consultation.id}",
                participants = listOf(
                    ParticipantInfo(
                        id = consultation.patientId,
                        name = "Patient",
                        role = "PATIENT",
                        isOnline = true
                    ),
                    ParticipantInfo(
                        id = consultation.doctorId,
                        name = "Doctor",
                        role = "DOCTOR",
                        isOnline = true
                    )
                ),
                startedAt = consultation.startedAt!!
            )
        }
    }

    fun endConsultation(id: UUID, notes: String?): Mono<Void> {
        return Mono.fromCallable {
            val consultation = consultationRepository.findById(id)
                .orElseThrow { ConsultationNotFoundException("Consultation not found with id: $id") }

            if (consultation.status != ConsultationStatus.IN_PROGRESS) {
                throw IllegalStateException("Consultation must be in progress to end")
            }

            val updatedConsultation = consultation.copy(
                status = ConsultationStatus.COMPLETED,
                endedAt = LocalDateTime.now(),
                notes = notes ?: consultation.notes
            )

            val savedConsultation = consultationRepository.save(updatedConsultation)

            // Publish event
            kafkaTemplate.send("consultation-ended", mapOf(
                "consultationId" to savedConsultation.id,
                "endedAt" to savedConsultation.endedAt
            ))

            null
        }.then()
    }

    fun sendMessage(id: UUID, request: SendMessageRequest, senderId: UUID, senderName: String): Mono<MessageResponse> {
        return Mono.fromCallable {
            val message = Message(
                consultationId = id,
                senderId = senderId,
                senderName = senderName,
                content = request.content,
                messageType = request.messageType,
                fileUrl = request.fileUrl,
                fileName = request.fileName,
                fileSize = request.fileSize
            )

            val savedMessage = messageRepository.save(message)

            // Publish event for real-time messaging
            kafkaTemplate.send("consultation-message", mapOf(
                "consultationId" to id,
                "messageId" to savedMessage.id,
                "senderId" to senderId,
                "content" to request.content
            ))

            MessageResponse(
                id = savedMessage.id!!,
                consultationId = savedMessage.consultationId,
                senderId = savedMessage.senderId,
                senderName = savedMessage.senderName,
                content = savedMessage.content,
                messageType = savedMessage.messageType,
                fileUrl = savedMessage.fileUrl,
                fileName = savedMessage.fileName,
                fileSize = savedMessage.fileSize,
                timestamp = savedMessage.timestamp!!
            )
        }
    }

    fun getMessages(id: UUID): Mono<List<MessageResponse>> {
        return Mono.fromCallable {
            val messages = messageRepository.findByConsultationIdOrderByTimestamp(id)
            messages.map { message ->
                MessageResponse(
                    id = message.id!!,
                    consultationId = message.consultationId,
                    senderId = message.senderId,
                    senderName = message.senderName,
                    content = message.content,
                    messageType = message.messageType,
                    fileUrl = message.fileUrl,
                    fileName = message.fileName,
                    fileSize = message.fileSize,
                    timestamp = message.timestamp!!
                )
            }
        }
    }

    fun uploadFile(id: UUID, request: FileUploadRequest, uploaderId: UUID): Mono<FileUploadResponse> {
        return Mono.fromCallable {
            // In a real implementation, you would upload the file to cloud storage
            // For now, we'll simulate the upload
            val fileUrl = "https://storage.automed.com/files/${UUID.randomUUID()}/${request.fileName}"

            val fileUpload = FileUpload(
                consultationId = id,
                uploaderId = uploaderId,
                fileName = request.fileName,
                fileUrl = fileUrl,
                fileSize = request.fileSize,
                mimeType = request.mimeType,
                description = request.description
            )

            val savedFile = fileUploadRepository.save(fileUpload)

            FileUploadResponse(
                fileId = savedFile.id!!,
                fileName = savedFile.fileName,
                fileUrl = savedFile.fileUrl,
                uploadedAt = savedFile.uploadedAt!!
            )
        }
    }

    fun getConsultationRecording(id: UUID): Mono<RecordingResponse> {
        return Mono.fromCallable {
            val recordings = recordingRepository.findByConsultationIdOrderByCreatedAtDesc(id)
            val latestRecording = recordings.firstOrNull()

            if (latestRecording != null) {
                RecordingResponse(
                    recordingId = latestRecording.id!!,
                    consultationId = latestRecording.consultationId,
                    recordingUrl = latestRecording.recordingUrl,
                    duration = latestRecording.duration,
                    fileSize = latestRecording.fileSize,
                    recordingType = latestRecording.recordingType,
                    thumbnailUrl = latestRecording.thumbnailUrl,
                    transcription = latestRecording.transcription,
                    createdAt = latestRecording.createdAt!!
                )
            } else {
                throw IllegalStateException("No recording found for consultation $id")
            }
        }
    }

    fun createPrescription(id: UUID, request: CreatePrescriptionRequest, prescribedBy: UUID): Mono<PrescriptionResponse> {
        return Mono.fromCallable {
            val prescription = Prescription(
                consultationId = id,
                medicationName = request.medicationName,
                dosage = request.dosage,
                frequency = request.frequency,
                duration = request.duration,
                instructions = request.instructions,
                quantity = request.quantity,
                prescribedBy = prescribedBy,
                pharmacyNotes = request.pharmacyNotes
            )

            val savedPrescription = prescriptionRepository.save(prescription)

            PrescriptionResponse(
                id = savedPrescription.id!!,
                consultationId = savedPrescription.consultationId,
                medicationName = savedPrescription.medicationName,
                dosage = savedPrescription.dosage,
                frequency = savedPrescription.frequency,
                duration = savedPrescription.duration,
                instructions = savedPrescription.instructions,
                quantity = savedPrescription.quantity,
                pharmacyNotes = savedPrescription.pharmacyNotes,
                filled = savedPrescription.filled,
                filledAt = savedPrescription.filledAt,
                prescribedAt = savedPrescription.prescribedAt!!
            )
        }
    }

    fun getUpcomingConsultations(): Mono<List<ConsultationResponse>> {
        return Mono.fromCallable {
            val upcoming = consultationRepository.findByScheduledAtBetween(
                LocalDateTime.now(),
                LocalDateTime.now().plusDays(7),
                Pageable.unpaged()
            )
            upcoming.content.map { mapToResponse(it) }
        }
    }

    fun rescheduleConsultation(id: UUID, request: RescheduleConsultationRequest): Mono<ConsultationResponse> {
        return Mono.fromCallable {
            val consultation = consultationRepository.findById(id)
                .orElseThrow { ConsultationNotFoundException("Consultation not found with id: $id") }

            if (consultation.status != ConsultationStatus.SCHEDULED) {
                throw IllegalStateException("Only scheduled consultations can be rescheduled")
            }

            val updatedConsultation = consultation.copy(
                scheduledAt = request.newScheduledAt,
                notes = "${consultation.notes}\nRescheduled: ${request.reason ?: "No reason provided"}"
            )

            val savedConsultation = consultationRepository.save(updatedConsultation)

            // Publish event
            kafkaTemplate.send("consultation-rescheduled", mapOf(
                "consultationId" to savedConsultation.id,
                "newScheduledAt" to savedConsultation.scheduledAt
            ))

            mapToResponse(savedConsultation)
        }
    }

    fun cancelConsultation(id: UUID, reason: String?): Mono<Void> {
        return Mono.fromCallable {
            val consultation = consultationRepository.findById(id)
                .orElseThrow { ConsultationNotFoundException("Consultation not found with id: $id") }

            if (consultation.status == ConsultationStatus.COMPLETED) {
                throw IllegalStateException("Cannot cancel completed consultation")
            }

            val updatedConsultation = consultation.copy(
                status = ConsultationStatus.CANCELLED,
                notes = "${consultation.notes}\nCancelled: ${reason ?: "No reason provided"}"
            )

            val savedConsultation = consultationRepository.save(updatedConsultation)

            // Publish event
            kafkaTemplate.send("consultation-cancelled", mapOf(
                "consultationId" to savedConsultation.id,
                "reason" to reason
            ))

            null
        }.then()
    }

    private fun mapToResponse(consultation: Consultation): ConsultationResponse {
        return ConsultationResponse(
            id = consultation.id!!,
            patientId = consultation.patientId,
            doctorId = consultation.doctorId,
            hospitalId = consultation.hospitalId,
            type = consultation.type,
            status = consultation.status,
            scheduledAt = consultation.scheduledAt,
            startedAt = consultation.startedAt,
            endedAt = consultation.endedAt,
            notes = consultation.notes,
            diagnosis = consultation.diagnosis,
            prescription = consultation.prescription,
            sessionId = consultation.sessionId,
            recordingUrl = consultation.recordingUrl,
            symptoms = consultation.symptoms,
            vitals = consultation.vitals,
            priority = consultation.priority,
            createdAt = consultation.createdAt!!,
            updatedAt = consultation.updatedAt!!
        )
    }

    private fun generateSessionId(): String {
        return "session-${UUID.randomUUID()}"
    }
}
