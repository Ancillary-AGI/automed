package com.automed.hospital.service

import com.automed.hospital.domain.*
import com.automed.hospital.dto.HospitalDTOs.*
import com.automed.hospital.exception.HospitalNotFoundException
import com.automed.hospital.repository.HospitalRepository
import com.automed.hospital.repository.StaffRepository
import com.automed.hospital.repository.EquipmentRepository
import org.junit.jupiter.api.Assertions.*
import org.junit.jupiter.api.BeforeEach
import org.junit.jupiter.api.Test
import org.junit.jupiter.api.extension.ExtendWith
import org.mockito.ArgumentMatchers.any
import org.mockito.InjectMocks
import org.mockito.Mock
import org.mockito.Mockito.*
import org.mockito.junit.jupiter.MockitoExtension
import org.springframework.data.domain.Page
import org.springframework.data.domain.PageImpl
import org.springframework.data.domain.PageRequest
import org.springframework.data.domain.Pageable
import java.time.LocalDateTime
import java.util.*

@ExtendWith(MockitoExtension::class)
class HospitalServiceTest {

    @Mock
    private lateinit var hospitalRepository: HospitalRepository

    @Mock
    private lateinit var staffRepository: StaffRepository

    @Mock
    private lateinit var equipmentRepository: EquipmentRepository

    @InjectMocks
    private lateinit var hospitalService: HospitalService

    private lateinit var testHospital: Hospital
    private lateinit var testHospitalId: String
    private lateinit var createRequest: CreateHospitalRequest
    private lateinit var updateRequest: UpdateHospitalRequest

    @BeforeEach
    fun setUp() {
        testHospitalId = "hospital123"
        testHospital = Hospital(
            id = testHospitalId,
            name = "General Hospital",
            address = Address(
                street = "123 Medical Center Dr",
                city = "Medical City",
                state = "MC",
                zipCode = "12345",
                country = "USA"
            ),
            phoneNumber = "+1-555-0123",
            email = "info@generalhospital.com",
            website = "https://generalhospital.com",
            type = HospitalType.GENERAL,
            capacity = 500,
            specialties = setOf("Cardiology", "Neurology", "Orthopedics"),
            emergencyServices = true,
            insuranceAccepted = setOf("Blue Cross", "Aetna", "United Healthcare"),
            operatingHours = mapOf(
                "monday" to "24/7",
                "tuesday" to "24/7",
                "wednesday" to "24/7",
                "thursday" to "24/7",
                "friday" to "24/7",
                "saturday" to "24/7",
                "sunday" to "24/7"
            ),
            status = HospitalStatus.ACTIVE,
            createdAt = LocalDateTime.now(),
            updatedAt = LocalDateTime.now()
        )

        createRequest = CreateHospitalRequest(
            name = "General Hospital",
            address = Address(
                street = "123 Medical Center Dr",
                city = "Medical City",
                state = "MC",
                zipCode = "12345",
                country = "USA"
            ),
            phoneNumber = "+1-555-0123",
            email = "info@generalhospital.com",
            website = "https://generalhospital.com",
            type = HospitalType.GENERAL,
            capacity = 500,
            specialties = setOf("Cardiology", "Neurology", "Orthopedics"),
            emergencyServices = true,
            insuranceAccepted = setOf("Blue Cross", "Aetna", "United Healthcare"),
            operatingHours = mapOf(
                "monday" to "24/7",
                "tuesday" to "24/7",
                "wednesday" to "24/7",
                "thursday" to "24/7",
                "friday" to "24/7",
                "saturday" to "24/7",
                "sunday" to "24/7"
            )
        )

        updateRequest = UpdateHospitalRequest(
            name = "Updated General Hospital",
            capacity = 600,
            phoneNumber = "+1-555-0124"
        )
    }

    @Test
    fun `createHospital should create and return hospital successfully`() {
        // Given
        `when`(hospitalRepository.save(any(Hospital::class.java))).thenReturn(testHospital)

        // When
        val result = hospitalService.createHospital(createRequest)

        // Then
        assertNotNull(result)
        assertEquals(testHospitalId, result.id)
        assertEquals("General Hospital", result.name)
        assertEquals(500, result.capacity)
        assertTrue(result.emergencyServices)
        verify(hospitalRepository).save(any(Hospital::class.java))
    }

    @Test
    fun `getHospital should return hospital when found`() {
        // Given
        `when`(hospitalRepository.findById(testHospitalId)).thenReturn(Optional.of(testHospital))

        // When
        val result = hospitalService.getHospital(testHospitalId)

        // Then
        assertNotNull(result)
        assertEquals(testHospitalId, result.id)
        assertEquals("General Hospital", result.name)
        verify(hospitalRepository).findById(testHospitalId)
    }

    @Test
    fun `getHospital should throw exception when hospital not found`() {
        // Given
        `when`(hospitalRepository.findById(testHospitalId)).thenReturn(Optional.empty())

        // When & Then
        assertThrows(HospitalNotFoundException::class.java) {
            hospitalService.getHospital(testHospitalId)
        }
        verify(hospitalRepository).findById(testHospitalId)
    }

    @Test
    fun `getAllHospitals should return paginated results with search`() {
        // Given
        val pageable: Pageable = PageRequest.of(0, 20)
        val hospitals = listOf(testHospital)
        val hospitalPage: Page<Hospital> = PageImpl(hospitals, pageable, 1)

        `when`(hospitalRepository.findByNameContainingIgnoreCaseOrAddressCityContainingIgnoreCase(
            "General", "General", pageable
        )).thenReturn(hospitalPage)

        // When
        val result = hospitalService.getAllHospitals(pageable, "General")

        // Then
        assertNotNull(result)
        assertEquals(1, result.content.size)
        assertEquals("General Hospital", result.content[0].name)
        verify(hospitalRepository).findByNameContainingIgnoreCaseOrAddressCityContainingIgnoreCase(
            "General", "General", pageable
        )
    }

    @Test
    fun `findHospitalsByLocation should return hospitals filtered by city and specialty`() {
        // Given
        val pageable: Pageable = PageRequest.of(0, 20)
        val hospitals = listOf(testHospital)
        val hospitalPage: Page<Hospital> = PageImpl(hospitals, pageable, 1)

        `when`(hospitalRepository.findByAddressCityAndSpecialtiesContaining(
            "Medical City", "Cardiology", pageable
        )).thenReturn(hospitalPage)

        // When
        val result = hospitalService.findHospitalsByLocation("Medical City", "Cardiology", pageable)

        // Then
        assertNotNull(result)
        assertEquals(1, result.content.size)
        assertEquals("Medical City", result.content[0].address.city)
        verify(hospitalRepository).findByAddressCityAndSpecialtiesContaining(
            "Medical City", "Cardiology", pageable
        )
    }

    @Test
    fun `findHospitalsBySpecialty should return hospitals with specific specialty`() {
        // Given
        val pageable: Pageable = PageRequest.of(0, 20)
        val hospitals = listOf(testHospital)
        val hospitalPage: Page<Hospital> = PageImpl(hospitals, pageable, 1)

        `when`(hospitalRepository.findBySpecialtiesContaining("Cardiology", pageable)).thenReturn(hospitalPage)

        // When
        val result = hospitalService.findHospitalsBySpecialty("Cardiology", pageable)

        // Then
        assertNotNull(result)
        assertEquals(1, result.content.size)
        assertTrue(result.content[0].specialties.contains("Cardiology"))
        verify(hospitalRepository).findBySpecialtiesContaining("Cardiology", pageable)
    }

    @Test
    fun `findHospitalsWithEmergencyServices should return hospitals with emergency services`() {
        // Given
        val pageable: Pageable = PageRequest.of(0, 20)
        val hospitals = listOf(testHospital)
        val hospitalPage: Page<Hospital> = PageImpl(hospitals, pageable, 1)

        `when`(hospitalRepository.findByEmergencyServices(true, pageable)).thenReturn(hospitalPage)

        // When
        val result = hospitalService.findHospitalsWithEmergencyServices(pageable)

        // Then
        assertNotNull(result)
        assertEquals(1, result.content.size)
        assertTrue(result.content[0].emergencyServices)
        verify(hospitalRepository).findByEmergencyServices(true, pageable)
    }

    @Test
    fun `updateHospital should update and return hospital successfully`() {
        // Given
        val updatedHospital = testHospital.copy(
            name = "Updated General Hospital",
            capacity = 600,
            phoneNumber = "+1-555-0124"
        )
        `when`(hospitalRepository.findById(testHospitalId)).thenReturn(Optional.of(testHospital))
        `when`(hospitalRepository.save(any(Hospital::class.java))).thenReturn(updatedHospital)

        // When
        val result = hospitalService.updateHospital(testHospitalId, updateRequest)

        // Then
        assertNotNull(result)
        assertEquals("Updated General Hospital", result.name)
        assertEquals(600, result.capacity)
        assertEquals("+1-555-0124", result.phoneNumber)
        verify(hospitalRepository).findById(testHospitalId)
        verify(hospitalRepository).save(any(Hospital::class.java))
    }

    @Test
    fun `deleteHospital should delete hospital successfully`() {
        // Given
        `when`(hospitalRepository.existsById(testHospitalId)).thenReturn(true)
        doNothing().`when`(hospitalRepository).deleteById(testHospitalId)

        // When
        hospitalService.deleteHospital(testHospitalId)

        // Then
        verify(hospitalRepository).existsById(testHospitalId)
        verify(hospitalRepository).deleteById(testHospitalId)
    }

    @Test
    fun `deleteHospital should throw exception when hospital not found`() {
        // Given
        `when`(hospitalRepository.existsById(testHospitalId)).thenReturn(false)

        // When & Then
        assertThrows(HospitalNotFoundException::class.java) {
            hospitalService.deleteHospital(testHospitalId)
        }
        verify(hospitalRepository).existsById(testHospitalId)
        verify(hospitalRepository, never()).deleteById(testHospitalId)
    }

    @Test
    fun `getHospitalCapacity should return capacity information`() {
        // Given
        `when`(hospitalRepository.findById(testHospitalId)).thenReturn(Optional.of(testHospital))

        // When
        val result = hospitalService.getHospitalCapacity(testHospitalId)

        // Then
        assertNotNull(result)
        assertEquals(testHospitalId, result.hospitalId)
        assertEquals(500, result.totalCapacity)
        assertTrue(result.availableBeds >= 0)
        assertTrue(result.occupancyRate >= 0.0)
        verify(hospitalRepository).findById(testHospitalId)
    }

    @Test
    fun `getHospitalStaff should return staff information`() {
        // Given
        val staffList = listOf(
            Staff(
                id = "staff1",
                hospitalId = testHospitalId,
                name = "Dr. Smith",
                role = StaffRole.DOCTOR,
                department = "Cardiology",
                specialization = "Interventional Cardiology",
                contactInfo = ContactInfo(
                    email = "smith@hospital.com",
                    phone = "+1-555-0001"
                ),
                status = StaffStatus.ACTIVE,
                joinDate = LocalDateTime.now().minusYears(5)
            )
        )
        `when`(staffRepository.findByHospitalId(testHospitalId)).thenReturn(staffList)

        // When
        val result = hospitalService.getHospitalStaff(testHospitalId)

        // Then
        assertNotNull(result)
        assertEquals(1, result.size)
        assertEquals("Dr. Smith", result[0].name)
        assertEquals("Cardiology", result[0].department)
        verify(staffRepository).findByHospitalId(testHospitalId)
    }

    @Test
    fun `getHospitalEquipment should return equipment information`() {
        // Given
        val equipmentList = listOf(
            Equipment(
                id = "equip1",
                hospitalId = testHospitalId,
                name = "MRI Scanner",
                type = EquipmentType.MEDICAL_IMAGING,
                model = "Siemens Magnetom",
                serialNumber = "MRI001",
                location = "Radiology Department",
                status = EquipmentStatus.OPERATIONAL,
                lastMaintenance = LocalDateTime.now().minusMonths(1),
                nextMaintenance = LocalDateTime.now().plusMonths(5)
            )
        )
        `when`(equipmentRepository.findByHospitalId(testHospitalId)).thenReturn(equipmentList)

        // When
        val result = hospitalService.getHospitalEquipment(testHospitalId)

        // Then
        assertNotNull(result)
        assertEquals(1, result.size)
        assertEquals("MRI Scanner", result[0].name)
        assertEquals("Siemens Magnetom", result[0].model)
        assertEquals(EquipmentStatus.OPERATIONAL, result[0].status)
        verify(equipmentRepository).findByHospitalId(testHospitalId)
    }
}