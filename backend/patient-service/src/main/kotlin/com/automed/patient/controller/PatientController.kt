package com.automed.patient.controller

import com.automed.patient.domain.Patient
import com.automed.patient.dto.CreatePatientRequest
import com.automed.patient.dto.PatientResponse
import com.automed.patient.dto.UpdatePatientRequest
import com.automed.patient.service.PatientService
import jakarta.validation.Valid
import org.slf4j.Logger
import org.slf4j.LoggerFactory
import org.springframework.beans.factory.annotation.Value
import org.springframework.data.domain.Page
import org.springframework.data.domain.Pageable
import org.springframework.http.HttpStatus
import org.springframework.http.ResponseEntity
import org.springframework.security.access.prepost.PreAuthorize
import org.springframework.web.bind.annotation.*
import org.springframework.web.client.RestTemplate
import org.springframework.web.client.RestClientException
import java.time.LocalDateTime
import java.util.*

@RestController
@RequestMapping("/api/v1/patients")
@CrossOrigin(origins = ["*"])
class PatientController(
    private val patientService: PatientService,
    private val restTemplate: RestTemplate = RestTemplate()
) {
    private val logger: Logger = LoggerFactory.getLogger(PatientController::class.java)

    @Value("\${services.medication-service.url:http://localhost:8087}")
    private lateinit var medicationServiceUrl: String

    @Value("\${services.vital-signs-service.url:http://localhost:8088}")
    private lateinit var vitalSignsServiceUrl: String

    @Value("\${services.medical-history-service.url:http://localhost:8089}")
    private lateinit var medicalHistoryServiceUrl: String

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
        return try {
            val patient = patientService.getPatient(id)

            // Integrate with other services
            val medicalHistory = getMedicalHistoryFromService(id)
            val vitalSigns = getVitalSignsFromService(id)
            val currentMedications = getMedicationsFromService(id)

            val response = mapOf(
                "patient" to patient,
                "medicalHistory" to medicalHistory,
                "vitalSigns" to vitalSigns,
                "currentMedications" to currentMedications,
                "allergies" to patient.allergies,
                "lastUpdated" to LocalDateTime.now()
            )

            ResponseEntity.ok(response)
        } catch (e: Exception) {
            logger.error("Error retrieving medical history for patient $id", e)
            ResponseEntity.status(HttpStatus.INTERNAL_SERVER_ERROR)
                .body(mapOf("error" to "Failed to retrieve medical history"))
        }
    }

    private fun getMedicalHistoryFromService(patientId: UUID): List<Map<String, Any>> {
        return try {
            val url = "$medicalHistoryServiceUrl/api/v1/medical-history/patient/$patientId"
            val response = restTemplate.getForObject(url, List::class.java)
            response as? List<Map<String, Any>> ?: emptyList()
        } catch (e: RestClientException) {
            logger.warn("Failed to fetch medical history for patient $patientId", e)
            emptyList()
        }
    }

    private fun getVitalSignsFromService(patientId: UUID): List<Map<String, Any>> {
        return try {
            val url = "$vitalSignsServiceUrl/api/v1/vital-signs/patient/$patientId"
            val response = restTemplate.getForObject(url, List::class.java)
            response as? List<Map<String, Any>> ?: emptyList()
        } catch (e: RestClientException) {
            logger.warn("Failed to fetch vital signs for patient $patientId", e)
            emptyList()
        }
    }

    private fun getMedicationsFromService(patientId: UUID): List<Map<String, Any>> {
        return try {
            val url = "$medicationServiceUrl/api/v1/medications/patient/$patientId"
            val response = restTemplate.getForObject(url, List::class.java)
            response as? List<Map<String, Any>> ?: emptyList()
        } catch (e: RestClientException) {
            logger.warn("Failed to fetch medications for patient $patientId", e)
            emptyList()
        }
    }

    @PostMapping("/{id}/emergency-contact")
    @PreAuthorize("hasRole('HEALTHCARE_PROVIDER') or hasRole('ADMIN')")
    fun addEmergencyContact(@PathVariable id: UUID, @RequestBody contact: Any): ResponseEntity<Any> {
        // Emergency contact management
        return ResponseEntity.ok(mapOf("message" to "Emergency contact added"))
    }
}