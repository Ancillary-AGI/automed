package com.automed.patient.service

import com.automed.patient.domain.Patient
import com.automed.patient.dto.CreatePatientRequest
import com.automed.patient.dto.UpdatePatientRequest
import com.automed.patient.exception.PatientNotFoundException
import com.automed.patient.mapper.PatientMapper
import com.automed.patient.repository.PatientRepository
import org.junit.jupiter.api.Assertions.*
import org.junit.jupiter.api.BeforeEach
import org.junit.jupiter.api.Test
import org.junit.jupiter.api.extension.ExtendWith
import org.mockito.ArgumentMatchers.any
import org.mockito.InjectMocks
import org.mockito.Mock
import org.mockito.Mockito.*
import org.mockito.junit.jupiter.MockitoExtension
import org.springframework.kafka.core.KafkaTemplate
import java.time.LocalDate
import java.util.*

@ExtendWith(MockitoExtension::class)
class PatientServiceTest {

    @Mock
    private lateinit var patientRepository: PatientRepository

    @Mock
    private lateinit var patientMapper: PatientMapper

    @Mock
    private lateinit var kafkaTemplate: KafkaTemplate<String, Any>

    @Mock
    private lateinit var securityService: SecurityService

    @InjectMocks
    private lateinit var patientService: PatientService

    private lateinit var testPatient: Patient
    private lateinit var testPatientId: UUID
    private lateinit var createRequest: CreatePatientRequest
    private lateinit var updateRequest: UpdatePatientRequest

    @BeforeEach
    fun setUp() {
        testPatientId = UUID.randomUUID()
        testPatient = Patient(
            id = testPatientId,
            patientId = "P001",
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
                zipCode = "12345",
                country = "USA"
            ),
            bloodType = com.automed.patient.domain.BloodType.O_POSITIVE,
            allergies = setOf("Penicillin"),
            medicalConditions = setOf("Hypertension"),
            status = com.automed.patient.domain.PatientStatus.ACTIVE,
            emergencyContact = com.automed.patient.domain.EmergencyContact(
                name = "Jane Doe",
                relationship = "Spouse",
                phoneNumber = "+1234567891"
            ),
            insuranceInfo = com.automed.patient.domain.InsuranceInfo(
                provider = "Blue Cross",
                policyNumber = "BC123456",
                groupNumber = "GRP001"
            ),
            createdAt = java.time.LocalDateTime.now(),
            updatedAt = java.time.LocalDateTime.now()
        )

        createRequest = CreatePatientRequest(
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
                zipCode = "12345",
                country = "USA"
            ),
            bloodType = com.automed.patient.domain.BloodType.O_POSITIVE,
            allergies = setOf("Penicillin"),
            medicalConditions = setOf("Hypertension"),
            emergencyContact = com.automed.patient.domain.EmergencyContact(
                name = "Jane Doe",
                relationship = "Spouse",
                phoneNumber = "+1234567891"
            ),
            insuranceInfo = com.automed.patient.domain.InsuranceInfo(
                provider = "Blue Cross",
                policyNumber = "BC123456",
                groupNumber = "GRP001"
            )
        )

        updateRequest = UpdatePatientRequest(
            firstName = "John Updated",
            phoneNumber = "+1234567899"
        )
    }

    @Test
    fun `createPatient should create and return patient successfully`() {
        // Given
        `when`(patientMapper.toEntity(createRequest)).thenReturn(testPatient)
        `when`(patientRepository.save(any(Patient::class.java))).thenReturn(testPatient)
        `when`(patientMapper.toResponse(testPatient)).thenReturn(
            com.automed.patient.dto.PatientResponse(
                id = testPatientId,
                patientId = testPatient.patientId,
                firstName = testPatient.firstName,
                lastName = testPatient.lastName,
                dateOfBirth = testPatient.dateOfBirth,
                gender = testPatient.gender,
                email = testPatient.email,
                phoneNumber = testPatient.phoneNumber,
                address = testPatient.address,
                bloodType = testPatient.bloodType,
                allergies = testPatient.allergies,
                medicalConditions = testPatient.medicalConditions,
                status = testPatient.status,
                emergencyContact = testPatient.emergencyContact,
                insuranceInfo = testPatient.insuranceInfo,
                createdAt = testPatient.createdAt,
                updatedAt = testPatient.updatedAt
            )
        )

        // When
        val result = patientService.createPatient(createRequest)

        // Then
        assertNotNull(result)
        assertEquals(testPatientId, result.id)
        assertEquals("John", result.firstName)
        assertEquals("Doe", result.lastName)
        verify(patientRepository).save(any(Patient::class.java))
        verify(kafkaTemplate).send(eq("patient-created"), any())
    }

    @Test
    fun `getPatient should return patient when found`() {
        // Given
        `when`(patientRepository.findById(testPatientId)).thenReturn(Optional.of(testPatient))
        `when`(patientMapper.toResponse(testPatient)).thenReturn(
            com.automed.patient.dto.PatientResponse(
                id = testPatientId,
                patientId = testPatient.patientId,
                firstName = testPatient.firstName,
                lastName = testPatient.lastName,
                dateOfBirth = testPatient.dateOfBirth,
                gender = testPatient.gender,
                email = testPatient.email,
                phoneNumber = testPatient.phoneNumber,
                address = testPatient.address,
                bloodType = testPatient.bloodType,
                allergies = testPatient.allergies,
                medicalConditions = testPatient.medicalConditions,
                status = testPatient.status,
                emergencyContact = testPatient.emergencyContact,
                insuranceInfo = testPatient.insuranceInfo,
                createdAt = testPatient.createdAt,
                updatedAt = testPatient.updatedAt
            )
        )

        // When
        val result = patientService.getPatient(testPatientId)

        // Then
        assertNotNull(result)
        assertEquals(testPatientId, result.id)
        verify(patientRepository).findById(testPatientId)
    }

    @Test
    fun `getPatient should throw exception when patient not found`() {
        // Given
        `when`(patientRepository.findById(testPatientId)).thenReturn(Optional.empty())

        // When & Then
        assertThrows(PatientNotFoundException::class.java) {
            patientService.getPatient(testPatientId)
        }
        verify(patientRepository).findById(testPatientId)
    }

    @Test
    fun `updatePatient should update and return patient successfully`() {
        // Given
        val updatedPatient = testPatient.copy(firstName = "John Updated", phoneNumber = "+1234567899")
        `when`(patientRepository.findById(testPatientId)).thenReturn(Optional.of(testPatient))
        `when`(patientMapper.updateEntity(testPatient, updateRequest)).thenReturn(updatedPatient)
        `when`(patientRepository.save(updatedPatient)).thenReturn(updatedPatient)
        `when`(patientMapper.toResponse(updatedPatient)).thenReturn(
            com.automed.patient.dto.PatientResponse(
                id = testPatientId,
                patientId = updatedPatient.patientId,
                firstName = "John Updated",
                lastName = updatedPatient.lastName,
                dateOfBirth = updatedPatient.dateOfBirth,
                gender = updatedPatient.gender,
                email = updatedPatient.email,
                phoneNumber = "+1234567899",
                address = updatedPatient.address,
                bloodType = updatedPatient.bloodType,
                allergies = updatedPatient.allergies,
                medicalConditions = updatedPatient.medicalConditions,
                status = updatedPatient.status,
                emergencyContact = updatedPatient.emergencyContact,
                insuranceInfo = updatedPatient.insuranceInfo,
                createdAt = updatedPatient.createdAt,
                updatedAt = updatedPatient.updatedAt
            )
        )

        // When
        val result = patientService.updatePatient(testPatientId, updateRequest)

        // Then
        assertNotNull(result)
        assertEquals("John Updated", result.firstName)
        assertEquals("+1234567899", result.phoneNumber)
        verify(patientRepository).findById(testPatientId)
        verify(patientRepository).save(updatedPatient)
        verify(kafkaTemplate).send(eq("patient-updated"), any())
    }

    @Test
    fun `deletePatient should delete patient successfully`() {
        // Given
        `when`(patientRepository.existsById(testPatientId)).thenReturn(true)
        doNothing().`when`(patientRepository).deleteById(testPatientId)

        // When
        patientService.deletePatient(testPatientId)

        // Then
        verify(patientRepository).existsById(testPatientId)
        verify(patientRepository).deleteById(testPatientId)
        verify(kafkaTemplate).send(eq("patient-deleted"), any())
    }

    @Test
    fun `deletePatient should throw exception when patient not found`() {
        // Given
        `when`(patientRepository.existsById(testPatientId)).thenReturn(false)

        // When & Then
        assertThrows(PatientNotFoundException::class.java) {
            patientService.deletePatient(testPatientId)
        }
        verify(patientRepository).existsById(testPatientId)
        verify(patientRepository, never()).deleteById(testPatientId)
    }

    @Test
    fun `getPatientByPatientId should return patient when found`() {
        // Given
        `when`(patientRepository.findByPatientId("P001")).thenReturn(Optional.of(testPatient))
        `when`(patientMapper.toResponse(testPatient)).thenReturn(
            com.automed.patient.dto.PatientResponse(
                id = testPatientId,
                patientId = testPatient.patientId,
                firstName = testPatient.firstName,
                lastName = testPatient.lastName,
                dateOfBirth = testPatient.dateOfBirth,
                gender = testPatient.gender,
                email = testPatient.email,
                phoneNumber = testPatient.phoneNumber,
                address = testPatient.address,
                bloodType = testPatient.bloodType,
                allergies = testPatient.allergies,
                medicalConditions = testPatient.medicalConditions,
                status = testPatient.status,
                emergencyContact = testPatient.emergencyContact,
                insuranceInfo = testPatient.insuranceInfo,
                createdAt = testPatient.createdAt,
                updatedAt = testPatient.updatedAt
            )
        )

        // When
        val result = patientService.getPatientByPatientId("P001")

        // Then
        assertNotNull(result)
        assertEquals("P001", result.patientId)
        verify(patientRepository).findByPatientId("P001")
    }

    @Test
    fun `isPatientOwner should return true when user owns patient`() {
        // Given
        `when`(patientRepository.findById(testPatientId)).thenReturn(Optional.of(testPatient))

        // When
        val result = patientService.isPatientOwner(testPatientId, "john.doe@example.com")

        // Then
        assertTrue(result)
        verify(patientRepository).findById(testPatientId)
    }

    @Test
    fun `isPatientOwner should return false when user does not own patient`() {
        // Given
        `when`(patientRepository.findById(testPatientId)).thenReturn(Optional.of(testPatient))

        // When
        val result = patientService.isPatientOwner(testPatientId, "other@example.com")

        // Then
        assertFalse(result)
        verify(patientRepository).findById(testPatientId)
    }

    @Test
    fun `isPatientOwner should return false when patient not found`() {
        // Given
        `when`(patientRepository.findById(testPatientId)).thenReturn(Optional.empty())

        // When
        val result = patientService.isPatientOwner(testPatientId, "john.doe@example.com")

        // Then
        assertFalse(result)
        verify(patientRepository).findById(testPatientId)
    }
}
