package com.automed.patient.service

import com.automed.patient.domain.Patient
import com.automed.patient.dto.CreatePatientRequest
import com.automed.patient.dto.PatientResponse
import com.automed.patient.dto.UpdatePatientRequest
import com.automed.patient.event.PatientCreatedEvent
import com.automed.patient.event.PatientUpdatedEvent
import com.automed.patient.exception.PatientNotFoundException
import com.automed.patient.mapper.PatientMapper
import com.automed.patient.repository.PatientRepository
import org.springframework.data.domain.Page
import org.springframework.data.domain.Pageable
import org.springframework.kafka.core.KafkaTemplate
import org.springframework.stereotype.Service
import org.springframework.transaction.annotation.Transactional
import java.util.*

@Service
@Transactional
class PatientService(
    private val patientRepository: PatientRepository,
    private val patientMapper: PatientMapper,
    private val kafkaTemplate: KafkaTemplate<String, Any>
) {

    fun createPatient(request: CreatePatientRequest): PatientResponse {
        val patient = patientMapper.toEntity(request)
        val savedPatient = patientRepository.save(patient)
        
        // Publish event
        val event = PatientCreatedEvent(
            patientId = savedPatient.id!!,
            patientNumber = savedPatient.patientId,
            firstName = savedPatient.firstName,
            lastName = savedPatient.lastName,
            email = savedPatient.email
        )
        kafkaTemplate.send("patient-created", event)
        
        return patientMapper.toResponse(savedPatient)
    }

    @Transactional(readOnly = true)
    fun getPatient(id: UUID): PatientResponse {
        val patient = patientRepository.findById(id)
            .orElseThrow { PatientNotFoundException("Patient not found with id: $id") }
        return patientMapper.toResponse(patient)
    }

    @Transactional(readOnly = true)
    fun getPatientByPatientId(patientId: String): PatientResponse {
        val patient = patientRepository.findByPatientId(patientId)
            .orElseThrow { PatientNotFoundException("Patient not found with patient ID: $patientId") }
        return patientMapper.toResponse(patient)
    }

    @Transactional(readOnly = true)
    fun getAllPatients(pageable: Pageable, search: String?): Page<PatientResponse> {
        val patients = if (search.isNullOrBlank()) {
            patientRepository.findAll(pageable)
        } else {
            patientRepository.findByFirstNameContainingIgnoreCaseOrLastNameContainingIgnoreCase(
                search, search, pageable
            )
        }
        return patients.map { patientMapper.toResponse(it) }
    }

    fun updatePatient(id: UUID, request: UpdatePatientRequest): PatientResponse {
        val existingPatient = patientRepository.findById(id)
            .orElseThrow { PatientNotFoundException("Patient not found with id: $id") }
        
        val updatedPatient = patientMapper.updateEntity(existingPatient, request)
        val savedPatient = patientRepository.save(updatedPatient)
        
        // Publish event
        val event = PatientUpdatedEvent(
            patientId = savedPatient.id!!,
            patientNumber = savedPatient.patientId,
            updatedFields = request.getUpdatedFields()
        )
        kafkaTemplate.send("patient-updated", event)
        
        return patientMapper.toResponse(savedPatient)
    }

    fun deletePatient(id: UUID) {
        if (!patientRepository.existsById(id)) {
            throw PatientNotFoundException("Patient not found with id: $id")
        }
        patientRepository.deleteById(id)
        
        // Publish event
        kafkaTemplate.send("patient-deleted", mapOf("patientId" to id))
    }

    @Transactional(readOnly = true)
    fun getPatientById(id: UUID): Patient? {
        return patientRepository.findById(id).orElse(null)
    }

    @Transactional(readOnly = true)
    fun isPatientOwner(patientId: UUID, userEmail: String): Boolean {
        return patientRepository.findById(patientId)
            .map { it.email == userEmail }
            .orElse(false)
    }
}