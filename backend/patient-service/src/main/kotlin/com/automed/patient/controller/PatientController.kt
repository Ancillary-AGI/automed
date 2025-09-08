package com.automed.patient.controller

import com.automed.patient.domain.Patient
import com.automed.patient.dto.CreatePatientRequest
import com.automed.patient.dto.PatientResponse
import com.automed.patient.dto.UpdatePatientRequest
import com.automed.patient.service.PatientService
import jakarta.validation.Valid
import org.springframework.data.domain.Page
import org.springframework.data.domain.Pageable
import org.springframework.http.HttpStatus
import org.springframework.http.ResponseEntity
import org.springframework.security.access.prepost.PreAuthorize
import org.springframework.web.bind.annotation.*
import java.util.*

@RestController
@RequestMapping("/api/v1/patients")
@CrossOrigin(origins = ["*"])
class PatientController(
    private val patientService: PatientService
) {

    @PostMapping
    @PreAuthorize("hasRole('HEALTHCARE_PROVIDER') or hasRole('ADMIN')")
    fun createPatient(@Valid @RequestBody request: CreatePatientRequest): ResponseEntity<PatientResponse> {
        val patient = patientService.createPatient(request)
        return ResponseEntity.status(HttpStatus.CREATED).body(patient)
    }

    @GetMapping("/{id}")
    @PreAuthorize("hasRole('HEALTHCARE_PROVIDER') or hasRole('ADMIN') or @patientService.isPatientOwner(#id, authentication.name)")
    fun getPatient(@PathVariable id: UUID): ResponseEntity<PatientResponse> {
        val patient = patientService.getPatient(id)
        return ResponseEntity.ok(patient)
    }

    @GetMapping("/patient-id/{patientId}")
    @PreAuthorize("hasRole('HEALTHCARE_PROVIDER') or hasRole('ADMIN')")
    fun getPatientByPatientId(@PathVariable patientId: String): ResponseEntity<PatientResponse> {
        val patient = patientService.getPatientByPatientId(patientId)
        return ResponseEntity.ok(patient)
    }

    @GetMapping
    @PreAuthorize("hasRole('HEALTHCARE_PROVIDER') or hasRole('ADMIN')")
    fun getAllPatients(
        pageable: Pageable,
        @RequestParam(required = false) search: String?
    ): ResponseEntity<Page<PatientResponse>> {
        val patients = patientService.getAllPatients(pageable, search)
        return ResponseEntity.ok(patients)
    }

    @PutMapping("/{id}")
    @PreAuthorize("hasRole('HEALTHCARE_PROVIDER') or hasRole('ADMIN')")
    fun updatePatient(
        @PathVariable id: UUID,
        @Valid @RequestBody request: UpdatePatientRequest
    ): ResponseEntity<PatientResponse> {
        val patient = patientService.updatePatient(id, request)
        return ResponseEntity.ok(patient)
    }

    @DeleteMapping("/{id}")
    @PreAuthorize("hasRole('ADMIN')")
    fun deletePatient(@PathVariable id: UUID): ResponseEntity<Void> {
        patientService.deletePatient(id)
        return ResponseEntity.noContent().build()
    }

    @GetMapping("/{id}/medical-history")
    @PreAuthorize("hasRole('HEALTHCARE_PROVIDER') or hasRole('ADMIN') or @patientService.isPatientOwner(#id, authentication.name)")
    fun getMedicalHistory(@PathVariable id: UUID): ResponseEntity<Any> {
        // This would integrate with medical history service
        return ResponseEntity.ok(mapOf("message" to "Medical history endpoint"))
    }

    @PostMapping("/{id}/emergency-contact")
    @PreAuthorize("hasRole('HEALTHCARE_PROVIDER') or hasRole('ADMIN')")
    fun addEmergencyContact(@PathVariable id: UUID, @RequestBody contact: Any): ResponseEntity<Any> {
        // Emergency contact management
        return ResponseEntity.ok(mapOf("message" to "Emergency contact added"))
    }
}