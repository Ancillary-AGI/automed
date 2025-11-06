package com.automed.emergency.controller

import com.automed.emergency.dto.*
import com.automed.emergency.service.EmergencyResponseService
import org.springframework.http.ResponseEntity
import org.springframework.web.bind.annotation.*
import reactor.core.publisher.Mono
import java.time.LocalDateTime

@RestController
@RequestMapping("/api/v1/emergency")
class EmergencyController(
    private val emergencyResponseService: EmergencyResponseService
) {

    @PostMapping("/alert")
    fun createEmergencyAlert(@RequestBody request: CreateEmergencyAlertRequest): Mono<ResponseEntity<EmergencyAlertResponse>> {
        return emergencyResponseService.createEmergencyAlert(request)
            .map { ResponseEntity.ok(it) }
    }

    @GetMapping("/alerts")
    fun getEmergencyAlerts(
        @RequestParam(required = false) status: EmergencyStatus?,
        @RequestParam(required = false) priority: EmergencyPriority?,
        @RequestParam(defaultValue = "0") page: Int,
        @RequestParam(defaultValue = "20") size: Int
    ): Mono<ResponseEntity<List<EmergencyAlertResponse>>> {
        return emergencyResponseService.getEmergencyAlerts(status, priority, page, size)
            .map { ResponseEntity.ok(it) }
    }

    @GetMapping("/alerts/{id}")
    fun getEmergencyAlert(@PathVariable id: String): Mono<ResponseEntity<EmergencyAlertResponse>> {
        return emergencyResponseService.getEmergencyAlert(id)
            .map { ResponseEntity.ok(it) }
            .defaultIfEmpty(ResponseEntity.notFound().build())
    }

    @PutMapping("/alerts/{id}/respond")
    fun respondToEmergencyAlert(
        @PathVariable id: String,
        @RequestBody response: EmergencyResponseRequest
    ): Mono<ResponseEntity<EmergencyAlertResponse>> {
        return emergencyResponseService.respondToEmergencyAlert(id, response)
            .map { ResponseEntity.ok(it) }
    }

    @PostMapping("/protocols")
    fun createEmergencyProtocol(@RequestBody request: CreateEmergencyProtocolRequest): Mono<ResponseEntity<EmergencyProtocolResponse>> {
        return emergencyResponseService.createEmergencyProtocol(request)
            .map { ResponseEntity.ok(it) }
    }

    @GetMapping("/protocols")
    fun getEmergencyProtocols(
        @RequestParam(required = false) type: EmergencyType?,
        @RequestParam(defaultValue = "0") page: Int,
        @RequestParam(defaultValue = "20") size: Int
    ): Mono<ResponseEntity<List<EmergencyProtocolResponse>>> {
        return emergencyResponseService.getEmergencyProtocols(type, page, size)
            .map { ResponseEntity.ok(it) }
    }

    @PostMapping("/drills")
    fun scheduleEmergencyDrill(@RequestBody request: ScheduleEmergencyDrillRequest): Mono<ResponseEntity<EmergencyDrillResponse>> {
        return emergencyResponseService.scheduleEmergencyDrill(request)
            .map { ResponseEntity.ok(it) }
    }

    @GetMapping("/drills")
    fun getEmergencyDrills(
        @RequestParam(required = false) status: DrillStatus?,
        @RequestParam(defaultValue = "0") page: Int,
        @RequestParam(defaultValue = "20") size: Int
    ): Mono<ResponseEntity<List<EmergencyDrillResponse>>> {
        return emergencyResponseService.getEmergencyDrills(status, page, size)
            .map { ResponseEntity.ok(it) }
    }

    @PostMapping("/resources/allocate")
    fun allocateEmergencyResources(@RequestBody request: EmergencyResourceAllocationRequest): Mono<ResponseEntity<EmergencyResourceAllocationResponse>> {
        return emergencyResponseService.allocateEmergencyResources(request)
            .map { ResponseEntity.ok(it) }
    }

    @GetMapping("/analytics")
    fun getEmergencyAnalytics(
        @RequestParam(required = false) startDate: LocalDateTime?,
        @RequestParam(required = false) endDate: LocalDateTime?
    ): Mono<ResponseEntity<EmergencyAnalyticsResponse>> {
        return emergencyResponseService.getEmergencyAnalytics(startDate, endDate)
            .map { ResponseEntity.ok(it) }
    }
}