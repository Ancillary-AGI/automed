package com.automed.hospital.controller

import com.automed.hospital.dto.HospitalDTOs.*
import com.automed.hospital.service.HospitalService
import io.swagger.v3.oas.annotations.Operation
import io.swagger.v3.oas.annotations.tags.Tag
import jakarta.validation.Valid
import org.springframework.data.domain.Page
import org.springframework.data.domain.PageRequest
import org.springframework.data.domain.Pageable
import org.springframework.http.HttpStatus
import org.springframework.http.ResponseEntity
import org.springframework.web.bind.annotation.*

@RestController
@RequestMapping("/api/v1/hospitals")
@Tag(name = "Hospital Management", description = "APIs for managing hospital information and operations")
class HospitalController(
    private val hospitalService: HospitalService
) {

    @PostMapping
    @Operation(summary = "Create a new hospital")
    fun createHospital(@Valid @RequestBody request: CreateHospitalRequest): ResponseEntity<HospitalResponse> {
        val hospital = hospitalService.createHospital(request)
        return ResponseEntity.status(HttpStatus.CREATED).body(hospital)
    }

    @GetMapping("/{id}")
    @Operation(summary = "Get hospital by ID")
    fun getHospital(@PathVariable id: String): ResponseEntity<HospitalResponse> {
        val hospital = hospitalService.getHospital(id)
        return ResponseEntity.ok(hospital)
    }

    @GetMapping
    @Operation(summary = "Get all hospitals with pagination and search")
    fun getAllHospitals(
        @RequestParam(defaultValue = "0") page: Int,
        @RequestParam(defaultValue = "20") size: Int,
        @RequestParam(required = false) search: String?
    ): ResponseEntity<Page<HospitalResponse>> {
        val pageable: Pageable = PageRequest.of(page, size)
        val hospitals = hospitalService.getAllHospitals(pageable, search)
        return ResponseEntity.ok(hospitals)
    }

    @GetMapping("/search/location")
    @Operation(summary = "Find hospitals by location and specialty")
    fun findHospitalsByLocation(
        @RequestParam city: String,
        @RequestParam(required = false) specialty: String?,
        @RequestParam(defaultValue = "0") page: Int,
        @RequestParam(defaultValue = "20") size: Int
    ): ResponseEntity<Page<HospitalResponse>> {
        val pageable: Pageable = PageRequest.of(page, size)
        val hospitals = hospitalService.findHospitalsByLocation(city, specialty, pageable)
        return ResponseEntity.ok(hospitals)
    }

    @GetMapping("/search/specialty")
    @Operation(summary = "Find hospitals by specialty")
    fun findHospitalsBySpecialty(
        @RequestParam specialty: String,
        @RequestParam(defaultValue = "0") page: Int,
        @RequestParam(defaultValue = "20") size: Int
    ): ResponseEntity<Page<HospitalResponse>> {
        val pageable: Pageable = PageRequest.of(page, size)
        val hospitals = hospitalService.findHospitalsBySpecialty(specialty, pageable)
        return ResponseEntity.ok(hospitals)
    }

    @GetMapping("/emergency-services")
    @Operation(summary = "Find hospitals with emergency services")
    fun findHospitalsWithEmergencyServices(
        @RequestParam(defaultValue = "0") page: Int,
        @RequestParam(defaultValue = "20") size: Int
    ): ResponseEntity<Page<HospitalResponse>> {
        val pageable: Pageable = PageRequest.of(page, size)
        val hospitals = hospitalService.findHospitalsWithEmergencyServices(pageable)
        return ResponseEntity.ok(hospitals)
    }

    @PutMapping("/{id}")
    @Operation(summary = "Update hospital information")
    fun updateHospital(
        @PathVariable id: String,
        @Valid @RequestBody request: UpdateHospitalRequest
    ): ResponseEntity<HospitalResponse> {
        val hospital = hospitalService.updateHospital(id, request)
        return ResponseEntity.ok(hospital)
    }

    @DeleteMapping("/{id}")
    @Operation(summary = "Delete hospital")
    fun deleteHospital(@PathVariable id: String): ResponseEntity<Void> {
        hospitalService.deleteHospital(id)
        return ResponseEntity.noContent().build()
    }

    @GetMapping("/{id}/capacity")
    @Operation(summary = "Get hospital capacity information")
    fun getHospitalCapacity(@PathVariable id: String): ResponseEntity<HospitalCapacityResponse> {
        val capacity = hospitalService.getHospitalCapacity(id)
        return ResponseEntity.ok(capacity)
    }

    @GetMapping("/{id}/staff")
    @Operation(summary = "Get hospital staff information")
    fun getHospitalStaff(@PathVariable id: String): ResponseEntity<List<StaffResponse>> {
        val staff = hospitalService.getHospitalStaff(id)
        return ResponseEntity.ok(staff)
    }

    @GetMapping("/{id}/equipment")
    @Operation(summary = "Get hospital equipment information")
    fun getHospitalEquipment(@PathVariable id: String): ResponseEntity<List<EquipmentResponse>> {
        val equipment = hospitalService.getHospitalEquipment(id)
        return ResponseEntity.ok(equipment)
    }
}