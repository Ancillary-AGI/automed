package com.automed.consultation.service

import com.automed.consultation.domain.Consultation
import com.automed.consultation.domain.ConsultationStatus
import com.automed.consultation.dto.*
import com.automed.consultation.exception.ConsultationNotFoundException
import com.automed.consultation.repository.ConsultationRepository
import org.springframework.data.domain.Page
import org.springframework.data.domain.Pageable
import org.springframework.kafka.core.KafkaTemplate
import org.springframework.stereotype.Service
import org.springframework.transaction.annotation.Transactional
import reactor.core.publisher.Mono
import java.time.LocalDateTime
import java.util.*

@Service
@Transactional
class ConsultationService(
    private val consultationRepository: ConsultationRepository,
    private val kafkaTemplate: KafkaTemplate<String, Any>
) {

    fun scheduleConsultation(request: ScheduleConsultationRequest): ConsultationResponse {
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
        kafkaTemplate.send("consultation-scheduled", mapOf(
            "consultationId" to savedConsultation.id,
            "patientId" to savedConsultation.patientId,
            "doctorId" to savedConsultation.doctorId,
            "scheduledAt" to savedConsultation.scheduledAt
        ))

        return mapToResponse(savedConsultation)
    }

    @Transactional(readOnly = true)
    fun getConsultation(id: UUID): ConsultationResponse {
        val consultation = consultationRepository.findById(id)
            .orElseThrow { ConsultationNotFoundException("Consultation not found with id: $id") }
        return mapToResponse(consultation)
    }

    @Transactional(readOnly = true)
    fun getAllConsultations(
        pageable: Pageable,
        patientId: UUID?,
        doctorId: UUID?,
        status: String?
    ): Page<ConsultationResponse> {
        val consultations = when {
            patientId != null -> consultationRepository.findByPatientId(patientId, pageable)
            doctorId != null -> consultationRepository.findByDoctorId(doctorId, pageable)
            status != null -> consultationRepository.findByStatus(
                ConsultationStatus.valueOf(status.uppercase()), pageable
            )
            else -> consultationRepository.findAll(pageable)
        }
        return consultations.map { mapToResponse(it) }
    }

    fun startConsultation(id: UUID): ConsultationResponse {
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

        return mapToResponse(savedConsultation)
    }

    fun endConsultation(id: UUID, request: EndConsultationRequest): ConsultationResponse {
        val consultation = consultationRepository.findById(id)
            .orElseThrow { ConsultationNotFoundException("Consultation not found with id: $id") }

        if (consultation.status != ConsultationStatus.IN_PROGRESS) {
            throw IllegalStateException("Consultation must be in progress to end")
        }

        val updatedConsultation = consultation.copy(
            status = ConsultationStatus.COMPLETED,
            endedAt = LocalDateTime.now(),
            notes = request.notes,
            diagnosis = request.diagnosis,
            prescription = request.prescription
        )

        val savedConsultation = consultationRepository.save(updatedConsultation)

        // Publish event
        kafkaTemplate.send("consultation-ended", mapOf(
            "consultationId" to savedConsultation.id,
            "diagnosis" to savedConsultation.diagnosis,
            "prescription" to savedConsultation.prescription
        ))

        return mapToResponse(savedConsultation)
    }

    fun cancelConsultation(id: UUID): ConsultationResponse {
        val consultation = consultationRepository.findById(id)
            .orElseThrow { ConsultationNotFoundException("Consultation not found with id: $id") }

        if (consultation.status == ConsultationStatus.COMPLETED) {
            throw IllegalStateException("Cannot cancel completed consultation")
        }

        val updatedConsultation = consultation.copy(status = ConsultationStatus.CANCELLED)
        val savedConsultation = consultationRepository.save(updatedConsultation)

        // Publish event
        kafkaTemplate.send("consultation-cancelled", mapOf(
            "consultationId" to savedConsultation.id,
            "reason" to "Cancelled by user"
        ))

        return mapToResponse(savedConsultation)
    }

    fun joinConsultation(id: UUID): JoinConsultationResponse {
        val consultation = consultationRepository.findById(id)
            .orElseThrow { ConsultationNotFoundException("Consultation not found with id: $id") }

        if (consultation.status != ConsultationStatus.IN_PROGRESS) {
            throw IllegalStateException("Consultation must be in progress to join")
        }

        // Generate WebRTC config (simplified)
        val webrtcConfig = WebRTCConfig(
            iceServers = listOf(
                IceServer(
                    urls = listOf("stun:stun.l.google.com:19302"),
                    username = null,
                    credential = null
                )
            ),
            signalingUrl = "ws://localhost:8082/signaling"
        )

        return JoinConsultationResponse(
            sessionId = consultation.sessionId!!,
            webrtcConfig = webrtcConfig,
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
            )
        )
    }

    @Transactional(readOnly = true)
    fun getPatientConsultations(patientId: UUID, pageable: Pageable): Page<ConsultationResponse> {
        val consultations = consultationRepository.findByPatientId(patientId, pageable)
        return consultations.map { mapToResponse(it) }
    }

    @Transactional(readOnly = true)
    fun getDoctorConsultations(doctorId: UUID, pageable: Pageable): Page<ConsultationResponse> {
        val consultations = consultationRepository.findByDoctorId(doctorId, pageable)
        return consultations.map { mapToResponse(it) }
    }

    @Transactional(readOnly = true)
    fun isParticipant(consultationId: UUID, userEmail: String): Boolean {
        // Simplified - in real implementation, would check user roles and permissions
        return true
    }

    @Transactional(readOnly = true)
    fun isPatientOwner(patientId: UUID, userEmail: String): Boolean {
        // Simplified - in real implementation, would check ownership
        return true
    }

    @Transactional(readOnly = true)
    fun isDoctorOwner(doctorId: UUID, userEmail: String): Boolean {
        // Simplified - in real implementation, would check ownership
        return true
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
