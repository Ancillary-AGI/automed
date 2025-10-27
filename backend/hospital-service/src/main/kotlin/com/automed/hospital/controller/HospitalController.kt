package com.automed.hospital.controller

import com.automed.hospital.dto.*
import com.automed.hospital.service.HospitalService
import jakarta.validation.Valid
import org.springframework.data.domain.Page
import org.springframework.data.domain.Pageable
import org.springframework.http.HttpStatus
import org.springframework.http.ResponseEntity
import org.springframework.security.access.prepost.PreAuthorize
import org.springframework.web.bind.annotation.*
import java.util.*

@RestController
@RequestMapping("/api/v1/hospitals")
@CrossOrigin(origins = ["*"])
class HospitalController(
    private val hospitalService: HospitalService
) {

    @PostMapping
    @PreAuthorize("hasRole('ADMIN')")
    fun createHospital(@Valid @RequestBody request: CreateHospitalRequest): ResponseEntity<HospitalResponse> {
        val hospital = hospitalService.createHospital(request)
        return ResponseEntity.status(HttpStatus.CREATED).body(hospital)
    }

    @GetMapping("/{id}")
    @PreAuthorize("hasRole('HEALTHCARE_PROVIDER') or hasRole('ADMIN')")
    fun getHospital(@PathVariable id: UUID): ResponseEntity<HospitalResponse> {
        val hospital = hospitalService.getHospital(id)
        return ResponseEntity.ok(hospital)
    }

    @GetMapping
    @PreAuthorize("hasRole('HEALTHCARE_PROVIDER') or hasRole('ADMIN')")
    fun getAllHospitals(
        pageable: Pageable,
        @RequestParam(required = false) search: String?
    ): ResponseEntity<Page<HospitalResponse>> {
        val hospitals = hospitalService.getAllHospitals(pageable, search)
        return ResponseEntity.ok(hospitals)
    }

    @PutMapping("/{id}")
    @PreAuthorize("hasRole('ADMIN')")
    fun updateHospital(
        @PathVariable id: UUID,
        @Valid @RequestBody request: UpdateHospitalRequest
    ): ResponseEntity<HospitalResponse> {
        val hospital = hospitalService.updateHospital(id, request)
        return ResponseEntity.ok(hospital)
    }

    @GetMapping("/{id}/staff")
    @PreAuthorize("hasRole('HEALTHCARE_PROVIDER') or hasRole('ADMIN')")
    fun getHospitalStaff(@PathVariable id: UUID): ResponseEntity<List<StaffResponse>> {
        val staff = hospitalService.getHospitalStaff(id)
        return ResponseEntity.ok(staff)
    }

    @PostMapping("/{id}/staff")
    @PreAuthorize("hasRole('ADMIN')")
    fun addStaffMember(
        @PathVariable id: UUID,
        @Valid @RequestBody request: CreateStaffRequest
    ): ResponseEntity<StaffResponse> {
        val staff = hospitalService.addStaffMember(id, request)
        return ResponseEntity.status(HttpStatus.CREATED).body(staff)
    }

    @GetMapping("/{id}/equipment")
    @PreAuthorize("hasRole('HEALTHCARE_PROVIDER') or hasRole('ADMIN')")
    fun getHospitalEquipment(@PathVariable id: UUID): ResponseEntity<List<EquipmentResponse>> {
        val equipment = hospitalService.getHospitalEquipment(id)
        return ResponseEntity.ok(equipment)
    }

    @PostMapping("/{id}/equipment")
    @PreAuthorize("hasRole('ADMIN')")
    fun addEquipment(
        @PathVariable id: UUID,
        @Valid @RequestBody request: CreateEquipmentRequest
    ): ResponseEntity<EquipmentResponse> {
        val equipment = hospitalService.addEquipment(id, request)
        return ResponseEntity.status(HttpStatus.CREATED).body(equipment)
    }

    @GetMapping("/{id}/capacity")
    @PreAuthorize("hasRole('HEALTHCARE_PROVIDER') or hasRole('ADMIN')")
    fun getHospitalCapacity(@PathVariable id: UUID): ResponseEntity<HospitalCapacityResponse> {
        val capacity = hospitalService.getHospitalCapacity(id)
        return ResponseEntity.ok(capacity)
    }

    @GetMapping("/{id}/metrics")
    @PreAuthorize("hasRole('HEALTHCARE_PROVIDER') or hasRole('ADMIN')")
    fun getHospitalMetrics(@PathVariable id: UUID): ResponseEntity<HospitalMetricsResponse> {
        val metrics = hospitalService.getHospitalMetrics(id)
        return ResponseEntity.ok(metrics)
    }

    @PostMapping("/{id}/emergency-alert")
    @PreAuthorize("hasRole('HEALTHCARE_PROVIDER') or hasRole('ADMIN')")
    fun createEmergencyAlert(
        @PathVariable id: UUID,
        @Valid @RequestBody request: CreateEmergencyAlertRequest
    ): ResponseEntity<EmergencyAlertResponse> {
        val alert = hospitalService.createEmergencyAlert(id, request)
        return ResponseEntity.status(HttpStatus.CREATED).body(alert)
    }

    @GetMapping("/{id}/emergency-alerts")
    @PreAuthorize("hasRole('HEALTHCARE_PROVIDER') or hasRole('ADMIN')")
    fun getEmergencyAlerts(@PathVariable id: UUID): ResponseEntity<List<EmergencyAlertResponse>> {
        val alerts = hospitalService.getEmergencyAlerts(id)
        return ResponseEntity.ok(alerts)
    }
}