package com.automed.consultation.controller

import com.automed.consultation.dto.*
import com.automed.consultation.service.ConsultationService
import jakarta.validation.Valid
import org.springframework.data.domain.Page
import org.springframework.data.domain.Pageable
import org.springframework.http.HttpStatus
import org.springframework.http.ResponseEntity
import org.springframework.security.access.prepost.PreAuthorize
import org.springframework.web.bind.annotation.*
import reactor.core.publisher.Mono
import java.util.*

@RestController
@RequestMapping("/api/v1/consultations")
@CrossOrigin(origins = ["*"])
class ConsultationController(
    private val consultationService: ConsultationService
) {

    @PostMapping
    @PreAuthorize("hasRole('HEALTHCARE_PROVIDER') or hasRole('PATIENT')")
    fun createConsultation(@Valid @RequestBody request: CreateConsultationRequest): Mono<ResponseEntity<ConsultationResponse>> {
        return consultationService.createConsultation(request)
            .map { ResponseEntity.status(HttpStatus.CREATED).body(it) }
    }

    @GetMapping("/{id}")
    @PreAuthorize("hasRole('HEALTHCARE_PROVIDER') or hasRole('PATIENT')")
    fun getConsultation(@PathVariable id: UUID): Mono<ResponseEntity<ConsultationResponse>> {
        return consultationService.getConsultation(id)
            .map { ResponseEntity.ok(it) }
    }

    @GetMapping
    @PreAuthorize("hasRole('HEALTHCARE_PROVIDER') or hasRole('PATIENT')")
    fun getAllConsultations(
        pageable: Pageable,
        @RequestParam(required = false) status: String?,
        @RequestParam(required = false) patientId: String?,
        @RequestParam(required = false) providerId: String?
    ): Mono<ResponseEntity<Page<ConsultationResponse>>> {
        return consultationService.getAllConsultations(pageable, status, patientId, providerId)
            .map { ResponseEntity.ok(it) }
    }

    @PutMapping("/{id}")
    @PreAuthorize("hasRole('HEALTHCARE_PROVIDER')")
    fun updateConsultation(
        @PathVariable id: UUID,
        @Valid @RequestBody request: UpdateConsultationRequest
    ): Mono<ResponseEntity<ConsultationResponse>> {
        return consultationService.updateConsultation(id, request)
            .map { ResponseEntity.ok(it) }
    }

    @PostMapping("/{id}/start")
    @PreAuthorize("hasRole('HEALTHCARE_PROVIDER') or hasRole('PATIENT')")
    fun startConsultation(@PathVariable id: UUID): Mono<ResponseEntity<ConsultationSessionResponse>> {
        return consultationService.startConsultation(id)
            .map { ResponseEntity.ok(it) }
    }

    @PostMapping("/{id}/join")
    @PreAuthorize("hasRole('HEALTHCARE_PROVIDER') or hasRole('PATIENT')")
    fun joinConsultation(@PathVariable id: UUID): Mono<ResponseEntity<ConsultationSessionResponse>> {
        return consultationService.joinConsultation(id)
            .map { ResponseEntity.ok(it) }
    }

    @PostMapping("/{id}/end")
    @PreAuthorize("hasRole('HEALTHCARE_PROVIDER')")
    fun endConsultation(
        @PathVariable id: UUID,
        @RequestBody(required = false) notes: String?
    ): Mono<ResponseEntity<Void>> {
        return consultationService.endConsultation(id, notes)
            .map { ResponseEntity.ok().build<Void>() }
    }

    @PostMapping("/{id}/messages")
    @PreAuthorize("hasRole('HEALTHCARE_PROVIDER') or hasRole('PATIENT')")
    fun sendMessage(
        @PathVariable id: UUID,
        @Valid @RequestBody request: SendMessageRequest
    ): Mono<ResponseEntity<MessageResponse>> {
        return consultationService.sendMessage(id, request)
            .map { ResponseEntity.status(HttpStatus.CREATED).body(it) }
    }

    @GetMapping("/{id}/messages")
    @PreAuthorize("hasRole('HEALTHCARE_PROVIDER') or hasRole('PATIENT')")
    fun getMessages(@PathVariable id: UUID): Mono<ResponseEntity<List<MessageResponse>>> {
        return consultationService.getMessages(id)
            .map { ResponseEntity.ok(it) }
    }

    @PostMapping("/{id}/files")
    @PreAuthorize("hasRole('HEALTHCARE_PROVIDER') or hasRole('PATIENT')")
    fun uploadFile(
        @PathVariable id: UUID,
        @Valid @RequestBody request: FileUploadRequest
    ): Mono<ResponseEntity<FileUploadResponse>> {
        return consultationService.uploadFile(id, request)
            .map { ResponseEntity.status(HttpStatus.CREATED).body(it) }
    }

    @GetMapping("/{id}/recording")
    @PreAuthorize("hasRole('HEALTHCARE_PROVIDER')")
    fun getConsultationRecording(@PathVariable id: UUID): Mono<ResponseEntity<RecordingResponse>> {
        return consultationService.getConsultationRecording(id)
            .map { ResponseEntity.ok(it) }
    }

    @PostMapping("/{id}/prescription")
    @PreAuthorize("hasRole('HEALTHCARE_PROVIDER')")
    fun createPrescription(
        @PathVariable id: UUID,
        @Valid @RequestBody request: CreatePrescriptionRequest
    ): Mono<ResponseEntity<PrescriptionResponse>> {
        return consultationService.createPrescription(id, request)
            .map { ResponseEntity.status(HttpStatus.CREATED).body(it) }
    }

    @GetMapping("/upcoming")
    @PreAuthorize("hasRole('HEALTHCARE_PROVIDER') or hasRole('PATIENT')")
    fun getUpcomingConsultations(): Mono<ResponseEntity<List<ConsultationResponse>>> {
        return consultationService.getUpcomingConsultations()
            .map { ResponseEntity.ok(it) }
    }

    @PostMapping("/{id}/reschedule")
    @PreAuthorize("hasRole('HEALTHCARE_PROVIDER') or hasRole('PATIENT')")
    fun rescheduleConsultation(
        @PathVariable id: UUID,
        @Valid @RequestBody request: RescheduleConsultationRequest
    ): Mono<ResponseEntity<ConsultationResponse>> {
        return consultationService.rescheduleConsultation(id, request)
            .map { ResponseEntity.ok(it) }
    }

    @PostMapping("/{id}/cancel")
    @PreAuthorize("hasRole('HEALTHCARE_PROVIDER') or hasRole('PATIENT')")
    fun cancelConsultation(
        @PathVariable id: UUID,
        @RequestBody(required = false) reason: String?
    ): Mono<ResponseEntity<Void>> {
        return consultationService.cancelConsultation(id, reason)
            .map { ResponseEntity.ok().build<Void>() }
    }
}