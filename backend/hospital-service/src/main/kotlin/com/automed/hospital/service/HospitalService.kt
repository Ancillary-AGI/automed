package com.automed.hospital.service

import com.automed.hospital.domain.Hospital
import com.automed.hospital.dto.HospitalDTOs.*
import com.automed.hospital.exception.HospitalNotFoundException
import com.automed.hospital.repository.HospitalRepository
import com.automed.hospital.repository.StaffRepository
import com.automed.hospital.repository.EquipmentRepository
import org.springframework.data.domain.Page
import org.springframework.data.domain.Pageable
import org.springframework.stereotype.Service
import org.springframework.transaction.annotation.Transactional
import java.util.*

@Service
@Transactional
class HospitalService(
    private val hospitalRepository: HospitalRepository,
    private val staffRepository: StaffRepository,
    private val equipmentRepository: EquipmentRepository
) {

    fun createHospital(request: CreateHospitalRequest): HospitalResponse {
        val hospital = Hospital(
            id = UUID.randomUUID().toString(),
            name = request.name,
            address = request.address,
            phoneNumber = request.phoneNumber,
            email = request.email,
            website = request.website,
            type = request.type,
            capacity = request.capacity,
            specialties = request.specialties,
            emergencyServices = request.emergencyServices,
            insuranceAccepted = request.insuranceAccepted,
            operatingHours = request.operatingHours,
            status = HospitalStatus.ACTIVE,
            createdAt = java.time.LocalDateTime.now(),
            updatedAt = java.time.LocalDateTime.now()
        )

        val savedHospital = hospitalRepository.save(hospital)
        return mapToResponse(savedHospital)
    }

    @Transactional(readOnly = true)
    fun getHospital(id: String): HospitalResponse {
        val hospital = hospitalRepository.findById(id)
            .orElseThrow { HospitalNotFoundException("Hospital not found with id: $id") }
        return mapToResponse(hospital)
    }

    @Transactional(readOnly = true)
    fun getAllHospitals(pageable: Pageable, search: String?): Page<HospitalResponse> {
        val hospitals = if (search.isNullOrBlank()) {
            hospitalRepository.findAll(pageable)
        } else {
            hospitalRepository.findByNameContainingIgnoreCaseOrAddressCityContainingIgnoreCase(
                search, search, pageable
            )
        }
        return hospitals.map { mapToResponse(it) }
    }

    @Transactional(readOnly = true)
    fun findHospitalsByLocation(city: String, specialty: String?, pageable: Pageable): Page<HospitalResponse> {
        val hospitals = if (specialty.isNullOrBlank()) {
            hospitalRepository.findByAddressCity(city, pageable)
        } else {
            hospitalRepository.findByAddressCityAndSpecialtiesContaining(city, specialty, pageable)
        }
        return hospitals.map { mapToResponse(it) }
    }

    @Transactional(readOnly = true)
    fun findHospitalsBySpecialty(specialty: String, pageable: Pageable): Page<HospitalResponse> {
        val hospitals = hospitalRepository.findBySpecialtiesContaining(specialty, pageable)
        return hospitals.map { mapToResponse(it) }
    }

    @Transactional(readOnly = true)
    fun findHospitalsWithEmergencyServices(pageable: Pageable): Page<HospitalResponse> {
        val hospitals = hospitalRepository.findByEmergencyServices(true, pageable)
        return hospitals.map { mapToResponse(it) }
    }

    fun updateHospital(id: String, request: UpdateHospitalRequest): HospitalResponse {
        val hospital = hospitalRepository.findById(id)
            .orElseThrow { HospitalNotFoundException("Hospital not found with id: $id") }

        // Update fields
        request.name?.let { hospital.name = it }
        request.phoneNumber?.let { hospital.phoneNumber = it }
        request.email?.let { hospital.email = it }
        request.website?.let { hospital.website = it }
        request.capacity?.let { hospital.capacity = it }
        request.specialties?.let { hospital.specialties = it }
        request.emergencyServices?.let { hospital.emergencyServices = it }
        request.insuranceAccepted?.let { hospital.insuranceAccepted = it }
        request.operatingHours?.let { hospital.operatingHours = it }
        request.status?.let { hospital.status = it }

        hospital.updatedAt = java.time.LocalDateTime.now()

        val savedHospital = hospitalRepository.save(hospital)
        return mapToResponse(savedHospital)
    }

    fun deleteHospital(id: String) {
        if (!hospitalRepository.existsById(id)) {
            throw HospitalNotFoundException("Hospital not found with id: $id")
        }
        hospitalRepository.deleteById(id)
    }

    @Transactional(readOnly = true)
    fun getHospitalCapacity(id: String): HospitalCapacityResponse {
        val hospital = hospitalRepository.findById(id)
            .orElseThrow { HospitalNotFoundException("Hospital not found with id: $id") }

        // Get current occupancy (this would typically come from patient records)
        val currentOccupancy = calculateCurrentOccupancy(id)

        return HospitalCapacityResponse(
            hospitalId = hospital.id,
            totalCapacity = hospital.capacity,
            currentOccupancy = currentOccupancy,
            availableBeds = hospital.capacity - currentOccupancy,
            occupancyRate = if (hospital.capacity > 0) (currentOccupancy.toDouble() / hospital.capacity) * 100 else 0.0,
            lastUpdated = hospital.updatedAt
        )
    }

    @Transactional(readOnly = true)
    fun getHospitalStaff(id: String): List<StaffResponse> {
        val staff = staffRepository.findByHospitalId(id)
        return staff.map { staff ->
            StaffResponse(
                id = staff.id,
                hospitalId = staff.hospitalId,
                name = staff.name,
                role = staff.role,
                department = staff.department,
                specialization = staff.specialization,
                contactInfo = staff.contactInfo,
                status = staff.status,
                joinDate = staff.joinDate
            )
        }
    }

    @Transactional(readOnly = true)
    fun getHospitalEquipment(id: String): List<EquipmentResponse> {
        val equipment = equipmentRepository.findByHospitalId(id)
        return equipment.map { eq ->
            EquipmentResponse(
                id = eq.id,
                hospitalId = eq.hospitalId,
                name = eq.name,
                type = eq.type,
                model = eq.model,
                serialNumber = eq.serialNumber,
                location = eq.location,
                status = eq.status,
                lastMaintenance = eq.lastMaintenance,
                nextMaintenance = eq.nextMaintenance
            )
        }
    }

    private fun mapToResponse(hospital: Hospital): HospitalResponse {
        return HospitalResponse(
            id = hospital.id,
            name = hospital.name,
            address = hospital.address,
            phoneNumber = hospital.phoneNumber,
            email = hospital.email,
            website = hospital.website,
            type = hospital.type,
            capacity = hospital.capacity,
            specialties = hospital.specialties,
            emergencyServices = hospital.emergencyServices,
            insuranceAccepted = hospital.insuranceAccepted,
            operatingHours = hospital.operatingHours,
            status = hospital.status,
            createdAt = hospital.createdAt,
            updatedAt = hospital.updatedAt
        )
    }

    @Transactional(readOnly = true)
    fun findNearestHospitals(latitude: Double, longitude: Double, limit: Int): List<HospitalResponse> {
        val pageable = org.springframework.data.domain.PageRequest.of(0, limit)
        val hospitals = hospitalRepository.findNearestHospitals(latitude, longitude, pageable)
        return hospitals.content.map { mapToResponse(it) }
    }

    private fun calculateCurrentOccupancy(hospitalId: String): Int {
        // This would typically query patient records to get current occupancy
        // For now, return a mock value
        return (Math.random() * 100).toInt()
    }
}
