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
        @RequestParam(required = false) search: String?,
        @RequestParam(required = false) type: String?
    ): ResponseEntity<Page<HospitalResponse>> {
        val hospitals = hospitalService.getAllHospitals(pageable, search, type)
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
    fun getHospitalStaff(
        @PathVariable id: UUID,
        pageable: Pageable
    ): ResponseEntity<Page<StaffResponse>> {
        val staff = hospitalService.getHospitalStaff(id, pageable)
        return ResponseEntity.ok(staff)
    }

    @PostMapping("/{id}/staff")
    @PreAuthorize("hasRole('ADMIN')")
    fun addStaff(
        @PathVariable id: UUID,
        @Valid @RequestBody request: CreateStaffRequest
    ): ResponseEntity<StaffResponse> {
        val staff = hospitalService.addStaff(id, request)
        return ResponseEntity.status(HttpStatus.CREATED).body(staff)
    }

    @GetMapping("/{id}/equipment")
    @PreAuthorize("hasRole('HEALTHCARE_PROVIDER') or hasRole('ADMIN')")
    fun getHospitalEquipment(
        @PathVariable id: UUID,
        pageable: Pageable
    ): ResponseEntity<Page<EquipmentResponse>> {
        val equipment = hospitalService.getHospitalEquipment(id, pageable)
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

    @GetMapping("/{id}/dashboard")
    @PreAuthorize("hasRole('HEALTHCARE_PROVIDER') or hasRole('ADMIN')")
    fun getHospitalDashboard(@PathVariable id: UUID): ResponseEntity<HospitalDashboardResponse> {
        val dashboard = hospitalService.getHospitalDashboard(id)
        return ResponseEntity.ok(dashboard)
    }
}