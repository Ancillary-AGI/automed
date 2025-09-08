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
import java.util.*

@RestController
@RequestMapping("/api/v1/consultations")
@CrossOrigin(origins = ["*"])
class ConsultationController(
    private val consultationService: ConsultationService
) {

    @PostMapping
    @PreAuthorize("hasRole('HEALTHCARE_PROVIDER') or hasRole('PATIENT')")
    fun scheduleConsultation(@Valid @RequestBody request: ScheduleConsultationRequest): ResponseEntity<ConsultationResponse> {
        val consultation = consultationService.scheduleConsultation(request)
        return ResponseEntity.status(HttpStatus.CREATED).body(consultation)
    }

    @GetMapping("/{id}")
    @PreAuthorize("hasRole('HEALTHCARE_PROVIDER') or @consultationService.isParticipant(#id, authentication.name)")
    fun getConsultation(@PathVariable id: UUID): ResponseEntity<ConsultationResponse> {
        val consultation = consultationService.getConsultation(id)
        return ResponseEntity.ok(consultation)
    }

    @GetMapping
    @PreAuthorize("hasRole('HEALTHCARE_PROVIDER') or hasRole('ADMIN')")
    fun getAllConsultations(
        pageable: Pageable,
        @RequestParam(required = false) patientId: UUID?,
        @RequestParam(required = false) doctorId: UUID?,
        @RequestParam(required = false) status: String?
    ): ResponseEntity<Page<ConsultationResponse>> {
        val consultations = consultationService.getAllConsultations(pageable, patientId, doctorId, status)
        return ResponseEntity.ok(consultations)
    }

    @PostMapping("/{id}/start")
    @PreAuthorize("hasRole('HEALTHCARE_PROVIDER')")
    fun startConsultation(@PathVariable id: UUID): ResponseEntity<ConsultationResponse> {
        val consultation = consultationService.startConsultation(id)
        return ResponseEntity.ok(consultation)
    }

    @PostMapping("/{id}/end")
    @PreAuthorize("hasRole('HEALTHCARE_PROVIDER')")
    fun endConsultation(
        @PathVariable id: UUID,
        @Valid @RequestBody request: EndConsultationRequest
    ): ResponseEntity<ConsultationResponse> {
        val consultation = consultationService.endConsultation(id, request)
        return ResponseEntity.ok(consultation)
    }

    @PostMapping("/{id}/cancel")
    @PreAuthorize("hasRole('HEALTHCARE_PROVIDER') or @consultationService.isParticipant(#id, authentication.name)")
    fun cancelConsultation(@PathVariable id: UUID): ResponseEntity<ConsultationResponse> {
        val consultation = consultationService.cancelConsultation(id)
        return ResponseEntity.ok(consultation)
    }

    @PostMapping("/{id}/join")
    @PreAuthorize("@consultationService.isParticipant(#id, authentication.name)")
    fun joinConsultation(@PathVariable id: UUID): ResponseEntity<JoinConsultationResponse> {
        val joinInfo = consultationService.joinConsultation(id)
        return ResponseEntity.ok(joinInfo)
    }

    @GetMapping("/patient/{patientId}")
    @PreAuthorize("hasRole('HEALTHCARE_PROVIDER') or @consultationService.isPatientOwner(#patientId, authentication.name)")
    fun getPatientConsultations(
        @PathVariable patientId: UUID,
        pageable: Pageable
    ): ResponseEntity<Page<ConsultationResponse>> {
        val consultations = consultationService.getPatientConsultations(patientId, pageable)
        return ResponseEntity.ok(consultations)
    }

    @GetMapping("/doctor/{doctorId}")
    @PreAuthorize("hasRole('HEALTHCARE_PROVIDER') or @consultationService.isDoctorOwner(#doctorId, authentication.name)")
    fun getDoctorConsultations(
        @PathVariable doctorId: UUID,
        pageable: Pageable
    ): ResponseEntity<Page<ConsultationResponse>> {
        val consultations = consultationService.getDoctorConsultations(doctorId, pageable)
        return ResponseEntity.ok(consultations)
    }
}