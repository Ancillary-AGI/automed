package com.automed.patient.service

import com.automed.patient.domain.Patient
import com.automed.patient.domain.PatientStatus
import com.automed.patient.dto.CreatePatientRequest
import com.automed.patient.dto.PatientResponse
import com.automed.patient.dto.UpdatePatientRequest
import com.automed.patient.exception.PatientNotFoundException
import com.automed.patient.mapper.PatientMapper
import com.automed.patient.repository.PatientRepository
import org.junit.jupiter.api.BeforeEach
import org.junit.jupiter.api.Test
import org.junit.jupiter.api.assertThrows
import org.junit.jupiter.api.extension.ExtendWith
import org.mockito.InjectMocks
import org.mockito.Mock
import org.mockito.junit.jupiter.MockitoExtension
import org.springframework.data.domain.Page
import org.springframework.data.domain.PageImpl
import org.springframework.data.domain.PageRequest
import org.springframework.kafka.core.KafkaTemplate
import java.time.LocalDate
import java.time.LocalDateTime
import java.util.*
import org.mockito.Mockito.*

@ExtendWith(MockitoExtension::class)
class PatientServiceTest {

    @Mock
    private lateinit var patientRepository: PatientRepository

    @Mock
    private lateinit var patientMapper: PatientMapper

    @Mock
    private lateinit var kafkaTemplate: KafkaTemplate<String, Any>

    @InjectMocks
    private lateinit var patientService: PatientService

    private lateinit var patient: Patient
    private lateinit var patientResponse: PatientResponse
    private lateinit var createRequest: CreatePatientRequest
    private lateinit var updateRequest: UpdatePatientRequest

    @BeforeEach
    fun setUp() {
        patient = Patient(
            id = UUID.randomUUID(),
            patientId = "P123456789",
            firstName = "John",
            lastName = "Doe",
            dateOfBirth = LocalDate.of(1990, 1, 1),
            gender = com.automed.patient.domain.Gender.MALE,
            email = "john.doe@example.com",
            phoneNumber = "+1234567890",
            address = com.automed.patient.domain.Address(
                street = "123 Main St",
                city = "Anytown",
                state = "CA",
                country = "USA",
                zipCode = "12345"
            ),
            bloodType = com.automed.patient.domain.BloodType.O_POSITIVE,
            status = PatientStatus.ACTIVE
        )

        patientResponse = PatientResponse(
            id = patient.id!!,
            patientId = patient.patientId,
            firstName = patient.firstName,
            lastName = patient.lastName,
            dateOfBirth = patient.dateOfBirth,
            gender = patient.gender,
            email = patient.email,
            phoneNumber = patient.phoneNumber,
            address = patient.address,
            bloodType = patient.bloodType,
            allergies = patient.allergies,
            medicalConditions = patient.medicalConditions,
            status = patient.status,
            createdAt = LocalDateTime.now(),
            updatedAt = LocalDateTime.now()
        )

        createRequest = CreatePatientRequest(
            firstName = "John",
            lastName = "Doe",
            dateOfBirth = LocalDate.of(1990, 1, 1),
            gender = com.automed.patient.domain.Gender.MALE,
            email = "john.doe@example.com",
            phoneNumber = "+1234567890",
            address = patient.address,
            bloodType = com.automed.patient.domain.BloodType.O_POSITIVE
        )

        updateRequest = UpdatePatientRequest(
            firstName = "Jane",
            lastName = "Smith",
            dateOfBirth = LocalDate.of(1991, 2, 2),
            gender = com.automed.patient.domain.Gender.FEMALE,
            email = "jane.smith@example.com",
            phoneNumber = "+1987654321",
            address = patient.address,
            bloodType = com.automed.patient.domain.BloodType.A_POSITIVE,
            allergies = setOf("Penicillin"),
            medicalConditions = setOf("Diabetes"),
            status = PatientStatus.ACTIVE
        )
    }

    @Test
    fun `createPatient should save patient and publish event`() {
        // Given
        `when`(patientMapper.toEntity(createRequest)).thenReturn(patient)
        `when`(patientRepository.save(patient)).thenReturn(patient)
        `when`(patientMapper.toResponse(patient)).thenReturn(patientResponse)

        // When
        val result = patientService.createPatient(createRequest)

        // Then
        assert(result == patientResponse)
        verify(patientRepository).save(patient)
        verify(kafkaTemplate).send(eq("patient-created"), any())
        verify(patientMapper).toEntity(createRequest)
        verify(patientMapper).toResponse(patient)
    }

    @Test
    fun `getPatient should return patient when found`() {
        // Given
        val patientId = UUID.randomUUID()
        `when`(patientRepository.findById(patientId)).thenReturn(Optional.of(patient))
        `when`(patientMapper.toResponse(patient)).thenReturn(patientResponse)

        // When
        val result = patientService.getPatient(patientId)

        // Then
        assert(result == patientResponse)
        verify(patientRepository).findById(patientId)
        verify(patientMapper).toResponse(patient)
    }

    @Test
    fun `getPatient should throw exception when not found`() {
        // Given
        val patientId = UUID.randomUUID()
        `when`(patientRepository.findById(patientId)).thenReturn(Optional.empty())

        // When & Then
        assertThrows(PatientNotFoundException::class.java) {
            patientService.getPatient(patientId)
        }
        verify(patientRepository).findById(patientId)
    }

    @Test
    fun `getAllPatients should return paginated results`() {
        // Given
        val pageable = PageRequest.of(0, 10)
        val patientPage: Page<Patient> = PageImpl(listOf(patient), pageable, 1)
        val responsePage: Page<PatientResponse> = PageImpl(listOf(patientResponse), pageable, 1)

        `when`(patientRepository.findAll(pageable)).thenReturn(patientPage)
        `when`(patientMapper.toResponse(patient)).thenReturn(patientResponse)

        // When
        val result = patientService.getAllPatients(pageable, null)

        // Then
        assert(result == responsePage)
        verify(patientRepository).findAll(pageable)
        verify(patientMapper).toResponse(patient)
    }

    @Test
    fun `updatePatient should update and save patient`() {
        // Given
        val patientId = UUID.randomUUID()
        val existingPatient = patient.copy(id = patientId)
        val updatedPatient = existingPatient.copy(
            firstName = updateRequest.firstName!!,
            lastName = updateRequest.lastName!!,
            email = updateRequest.email!!
        )

        `when`(patientRepository.findById(patientId)).thenReturn(Optional.of(existingPatient))
        `when`(patientMapper.updateEntity(existingPatient, updateRequest)).thenReturn(updatedPatient)
        `when`(patientRepository.save(updatedPatient)).thenReturn(updatedPatient)
        `when`(patientMapper.toResponse(updatedPatient)).thenReturn(patientResponse)

        // When
        val result = patientService.updatePatient(patientId, updateRequest)

        // Then
        assert(result == patientResponse)
        verify(patientRepository).findById(patientId)
        verify(patientMapper).updateEntity(existingPatient, updateRequest)
        verify(patientRepository).save(updatedPatient)
        verify(kafkaTemplate).send(eq("patient-updated"), any())
    }

    @Test
    fun `deletePatient should delete patient when exists`() {
        // Given
        val patientId = UUID.randomUUID()
        `when`(patientRepository.existsById(patientId)).thenReturn(true)

        // When
        patientService.deletePatient(patientId)

        // Then
        verify(patientRepository).existsById(patientId)
        verify(patientRepository).deleteById(patientId)
        verify(kafkaTemplate).send(eq("patient-deleted"), any())
    }

    @Test
    fun `deletePatient should throw exception when not exists`() {
        // Given
        val patientId = UUID.randomUUID()
        `when`(patientRepository.existsById(patientId)).thenReturn(false)

        // When & Then
        assertThrows(PatientNotFoundException::class.java) {
            patientService.deletePatient(patientId)
        }
        verify(patientRepository).existsById(patientId)
        verify(patientRepository, never()).deleteById(patientId)
    }
}
