package com.automed.hospital.service

import com.automed.hospital.domain.*
import com.automed.hospital.dto.*
import com.automed.hospital.exception.HospitalNotFoundException
import com.automed.hospital.repository.EquipmentRepository
import com.automed.hospital.repository.HospitalRepository
import com.automed.hospital.repository.StaffRepository
import org.springframework.data.domain.Page
import org.springframework.data.domain.Pageable
import org.springframework.kafka.core.KafkaTemplate
import org.springframework.stereotype.Service
import org.springframework.transaction.annotation.Transactional
import java.time.LocalDateTime
import java.util.*

@Service
@Transactional
class HospitalService(
    private val hospitalRepository: HospitalRepository,
    private val staffRepository: StaffRepository,
    private val equipmentRepository: EquipmentRepository,
    private val kafkaTemplate: KafkaTemplate<String, Any>
) {

    fun createHospital(request: CreateHospitalRequest): HospitalResponse {
        val hospital = Hospital(
            hospitalCode = generateHospitalCode(),
            name = request.name,
            type = request.type,
            address = request.address,
            phoneNumber = request.phoneNumber,
            email = request.email,
            website = request.website,
            capacity = request.capacity,
            specialties = request.specialties,
            certifications = request.certifications
        )

        val savedHospital = hospitalRepository.save(hospital)

        // Publish event
        kafkaTemplate.send("hospital-created", mapOf(
            "hospitalId" to savedHospital.id,
            "name" to savedHospital.name,
            "type" to savedHospital.type
        ))

        return mapToResponse(savedHospital)
    }

    @Transactional(readOnly = true)
    fun getHospital(id: UUID): HospitalResponse {
        val hospital = hospitalRepository.findById(id)
            .orElseThrow { HospitalNotFoundException("Hospital not found with id: $id") }
        return mapToResponse(hospital)
    }

    @Transactional(readOnly = true)
    fun getAllHospitals(pageable: Pageable, search: String?, type: String?): Page<HospitalResponse> {
        val hospitals = when {
            search != null -> hospitalRepository.findByNameContainingIgnoreCase(search, pageable)
            type != null -> hospitalRepository.findByType(HospitalType.valueOf(type.uppercase()), pageable)
            else -> hospitalRepository.findAll(pageable)
        }
        return hospitals.map { mapToResponse(it) }
    }

    fun updateHospital(id: UUID, request: UpdateHospitalRequest): HospitalResponse {
        val existingHospital = hospitalRepository.findById(id)
            .orElseThrow { HospitalNotFoundException("Hospital not found with id: $id") }

        val updatedHospital = existingHospital.copy(
            name = request.name ?: existingHospital.name,
            type = request.type ?: existingHospital.type,
            address = request.address ?: existingHospital.address,
            phoneNumber = request.phoneNumber ?: existingHospital.phoneNumber,
            email = request.email ?: existingHospital.email,
            website = request.website ?: existingHospital.website,
            capacity = request.capacity ?: existingHospital.capacity,
            specialties = request.specialties ?: existingHospital.specialties,
            certifications = request.certifications ?: existingHospital.certifications,
            status = request.status ?: existingHospital.status
        )

        val savedHospital = hospitalRepository.save(updatedHospital)

        // Publish event
        kafkaTemplate.send("hospital-updated", mapOf(
            "hospitalId" to savedHospital.id,
            "updatedFields" to request.getUpdatedFields()
        ))

        return mapToResponse(savedHospital)
    }

    @Transactional(readOnly = true)
    fun getHospitalStaff(hospitalId: UUID, pageable: Pageable): Page<StaffResponse> {
        val staff = staffRepository.findByHospitalId(hospitalId, pageable)
        return staff.map { mapToStaffResponse(it) }
    }

    fun addStaff(hospitalId: UUID, request: CreateStaffRequest): StaffResponse {
        val hospital = hospitalRepository.findById(hospitalId)
            .orElseThrow { HospitalNotFoundException("Hospital not found with id: $hospitalId") }

        val staff = Staff(
            hospitalId = hospitalId,
            employeeId = request.employeeId,
            firstName = request.firstName,
            lastName = request.lastName,
            role = request.role,
            department = request.department,
            email = request.email,
            phoneNumber = request.phoneNumber,
            licenseNumber = request.licenseNumber,
            specializations = request.specializations
        )

        val savedStaff = staffRepository.save(staff)

        // Publish event
        kafkaTemplate.send("staff-added", mapOf(
            "staffId" to savedStaff.id,
            "hospitalId" to hospitalId,
            "role" to savedStaff.role
        ))

        return mapToStaffResponse(savedStaff)
    }

    @Transactional(readOnly = true)
    fun getHospitalEquipment(hospitalId: UUID, pageable: Pageable): Page<EquipmentResponse> {
        val equipment = equipmentRepository.findByHospitalId(hospitalId, pageable)
        return equipment.map { mapToEquipmentResponse(it) }
    }

    fun addEquipment(hospitalId: UUID, request: CreateEquipmentRequest): EquipmentResponse {
        val hospital = hospitalRepository.findById(hospitalId)
            .orElseThrow { HospitalNotFoundException("Hospital not found with id: $hospitalId") }

        val equipment = Equipment(
            hospitalId = hospitalId,
            equipmentCode = request.equipmentCode,
            name = request.name,
            type = request.type,
            manufacturer = request.manufacturer,
            model = request.model,
            serialNumber = request.serialNumber,
            location = request.location,
            notes = request.notes
        )

        val savedEquipment = equipmentRepository.save(equipment)

        // Publish event
        kafkaTemplate.send("equipment-added", mapOf(
            "equipmentId" to savedEquipment.id,
            "hospitalId" to hospitalId,
            "type" to savedEquipment.type
        ))

        return mapToEquipmentResponse(savedEquipment)
    }

    @Transactional(readOnly = true)
    fun getHospitalDashboard(hospitalId: UUID): HospitalDashboardResponse {
        val hospital = hospitalRepository.findById(hospitalId)
            .orElseThrow { HospitalNotFoundException("Hospital not found with id: $hospitalId") }

        // Simulate dashboard data - in real implementation, would query from other services
        val totalPatients = 150L // Would come from patient service
        val activeConsultations = 25L // Would come from consultation service
        val availableBeds = hospital.capacity - hospital.currentOccupancy
        val staffOnDuty = staffRepository.countActiveStaffByHospitalId(hospitalId)
        val equipmentOperational = equipmentRepository.countOperationalEquipmentByHospitalId(hospitalId)
        val equipmentMaintenance = equipmentRepository.countMaintenanceEquipmentByHospitalId(hospitalId)
        val recentAlerts = listOf("Equipment maintenance due", "Staff shortage in ER")
        val occupancyRate = (hospital.currentOccupancy.toDouble() / hospital.capacity) * 100

        return HospitalDashboardResponse(
            hospitalId = hospitalId,
            totalPatients = totalPatients,
            activeConsultations = activeConsultations,
            availableBeds = availableBeds,
            staffOnDuty = staffOnDuty,
            equipmentOperational = equipmentOperational,
            equipmentMaintenance = equipmentMaintenance,
            recentAlerts = recentAlerts,
            occupancyRate = occupancyRate
        )
    }

    private fun mapToResponse(hospital: Hospital): HospitalResponse {
        return HospitalResponse(
            id = hospital.id!!,
            hospitalCode = hospital.hospitalCode,
            name = hospital.name,
            type = hospital.type,
            address = hospital.address,
            phoneNumber = hospital.phoneNumber,
            email = hospital.email,
            website = hospital.website,
            capacity = hospital.capacity,
            currentOccupancy = hospital.currentOccupancy,
            status = hospital.status,
            specialties = hospital.specialties,
            certifications = hospital.certifications,
            createdAt = hospital.createdAt!!,
            updatedAt = hospital.updatedAt!!
        )
    }

    private fun mapToStaffResponse(staff: Staff): StaffResponse {
        return StaffResponse(
            id = staff.id!!,
            hospitalId = staff.hospitalId,
            employeeId = staff.employeeId,
            firstName = staff.firstName,
            lastName = staff.lastName,
            role = staff.role,
            department = staff.department,
            email = staff.email,
            phoneNumber = staff.phoneNumber,
            licenseNumber = staff.licenseNumber,
            specializations = staff.specializations,
            status = staff.status,
            createdAt = staff.createdAt!!,
            updatedAt = staff.updatedAt!!
        )
    }

    private fun mapToEquipmentResponse(equipment: Equipment): EquipmentResponse {
        return EquipmentResponse(
            id = equipment.id!!,
            hospitalId = equipment.hospitalId,
            equipmentCode = equipment.equipmentCode,
            name = equipment.name,
            type = equipment.type,
            manufacturer = equipment.manufacturer,
            model = equipment.model,
            serialNumber = equipment.serialNumber,
            status = equipment.status,
            location = equipment.location,
            lastMaintenanceDate = equipment.lastMaintenanceDate,
            nextMaintenanceDate = equipment.nextMaintenanceDate,
            notes = equipment.notes,
            createdAt = equipment.createdAt!!,
            updatedAt = equipment.updatedAt!!
        )
    }

    @Transactional(readOnly = true)
    fun getHospitalCapacity(hospitalId: UUID): HospitalCapacityResponse {
        val hospital = hospitalRepository.findById(hospitalId)
            .orElseThrow { HospitalNotFoundException("Hospital not found with id: $hospitalId") }

        // TODO: Implement proper capacity tracking with ICU and emergency beds
        val icuBeds = (hospital.capacity * 0.1).toInt() // Assume 10% are ICU beds
        val emergencyBeds = (hospital.capacity * 0.15).toInt() // Assume 15% are emergency beds
        val icuOccupied = (icuBeds * 0.8).toInt() // Simulate occupancy
        val emergencyOccupied = (emergencyBeds * 0.6).toInt() // Simulate occupancy

        return HospitalCapacityResponse(
            hospitalId = hospitalId,
            totalBeds = hospital.capacity,
            occupiedBeds = hospital.currentOccupancy,
            availableBeds = hospital.capacity - hospital.currentOccupancy,
            occupancyRate = (hospital.currentOccupancy.toDouble() / hospital.capacity) * 100,
            icuBeds = icuBeds,
            icuOccupied = icuOccupied,
            emergencyBeds = emergencyBeds,
            emergencyOccupied = emergencyOccupied,
            lastUpdated = LocalDateTime.now()
        )
    }

    @Transactional(readOnly = true)
    fun getHospitalMetrics(hospitalId: UUID): HospitalMetricsResponse {
        val hospital = hospitalRepository.findById(hospitalId)
            .orElseThrow { HospitalNotFoundException("Hospital not found with id: $hospitalId") }

        // TODO: Implement real metrics calculation from historical data
        return HospitalMetricsResponse(
            hospitalId = hospitalId,
            averageWaitTime = 45L, // minutes
            patientSatisfaction = 4.2, // out of 5
            staffUtilization = 78.5, // percentage
            equipmentUptime = 92.3, // percentage
            emergencyResponseTime = 8L, // minutes
            readmissionRate = 5.2, // percentage
            infectionRate = 0.8, // percentage
            period = "LAST_30_DAYS",
            lastUpdated = LocalDateTime.now()
        )
    }

    fun createEmergencyAlert(hospitalId: UUID, request: CreateEmergencyAlertRequest): EmergencyAlertResponse {
        val hospital = hospitalRepository.findById(hospitalId)
            .orElseThrow { HospitalNotFoundException("Hospital not found with id: $hospitalId") }

        // TODO: Implement emergency alert persistence and notification system
        val alert = EmergencyAlertResponse(
            id = UUID.randomUUID(),
            hospitalId = hospitalId,
            title = request.title,
            description = request.description,
            severity = request.severity,
            alertType = request.alertType,
            status = AlertStatus.ACTIVE,
            affectedDepartments = request.affectedDepartments,
            requiredResources = request.requiredResources,
            createdBy = UUID.randomUUID(), // TODO: Get from security context
            acknowledgedBy = emptySet(),
            resolvedAt = null,
            createdAt = LocalDateTime.now(),
            updatedAt = LocalDateTime.now()
        )

        // Publish event
        kafkaTemplate.send("emergency-alert-created", mapOf(
            "alertId" to alert.id,
            "hospitalId" to hospitalId,
            "severity" to alert.severity,
            "type" to alert.alertType
        ))

        return alert
    }

    @Transactional(readOnly = true)
    fun getEmergencyAlerts(hospitalId: UUID): List<EmergencyAlertResponse> {
        val hospital = hospitalRepository.findById(hospitalId)
            .orElseThrow { HospitalNotFoundException("Hospital not found with id: $hospitalId") }

        // TODO: Implement emergency alerts retrieval from database
        return emptyList() // Return empty list for now
    }

    private fun generateHospitalCode(): String {
        return "H${System.currentTimeMillis()}"
    }
}
