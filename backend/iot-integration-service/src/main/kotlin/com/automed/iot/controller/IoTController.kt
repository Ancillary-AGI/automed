package com.automed.iot.controller

import com.automed.iot.dto.*
import com.automed.iot.service.IoTIntegrationService
import org.springframework.http.ResponseEntity
import org.springframework.web.bind.annotation.*
import reactor.core.publisher.Flux
import reactor.core.publisher.Mono
import java.time.LocalDateTime

@RestController
@RequestMapping("/api/v1/iot")
class IoTController(
    private val iotService: IoTIntegrationService
) {

    @PostMapping("/devices")
    fun registerDevice(@RequestBody request: RegisterDeviceRequest): Mono<ResponseEntity<IoTDeviceResponse>> {
        return iotService.registerDevice(request)
            .map { ResponseEntity.ok(it) }
    }

    @GetMapping("/devices")
    fun getDevices(
        @RequestParam(required = false) type: DeviceType?,
        @RequestParam(required = false) status: DeviceStatus?,
        @RequestParam(defaultValue = "0") page: Int,
        @RequestParam(defaultValue = "20") size: Int
    ): Mono<ResponseEntity<List<IoTDeviceResponse>>> {
        return iotService.getDevices(type, status, page, size)
            .map { ResponseEntity.ok(it) }
    }

    @GetMapping("/devices/{deviceId}")
    fun getDevice(@PathVariable deviceId: String): Mono<ResponseEntity<IoTDeviceResponse>> {
        return iotService.getDevice(deviceId)
            .map { ResponseEntity.ok(it) }
            .defaultIfEmpty(ResponseEntity.notFound().build())
    }

    @PutMapping("/devices/{deviceId}/status")
    fun updateDeviceStatus(
        @PathVariable deviceId: String,
        @RequestBody status: DeviceStatus
    ): Mono<ResponseEntity<IoTDeviceResponse>> {
        return iotService.updateDeviceStatus(deviceId, status)
            .map { ResponseEntity.ok(it) }
    }

    @PostMapping("/devices/{deviceId}/data")
    fun submitDeviceData(
        @PathVariable deviceId: String,
        @RequestBody data: DeviceDataRequest
    ): Mono<ResponseEntity<DeviceDataResponse>> {
        return iotService.submitDeviceData(deviceId, data)
            .map { ResponseEntity.ok(it) }
    }

    @GetMapping("/devices/{deviceId}/data")
    fun getDeviceData(
        @PathVariable deviceId: String,
        @RequestParam(required = false) startDate: LocalDateTime?,
        @RequestParam(required = false) endDate: LocalDateTime?,
        @RequestParam(defaultValue = "0") page: Int,
        @RequestParam(defaultValue = "50") size: Int
    ): Mono<ResponseEntity<List<DeviceDataResponse>>> {
        return iotService.getDeviceData(deviceId, startDate, endDate, page, size)
            .map { ResponseEntity.ok(it) }
    }

    @GetMapping("/data/stream")
    fun streamDeviceData(
        @RequestParam(required = false) deviceIds: List<String>?,
        @RequestParam(required = false) types: List<String>?
    ): Flux<DeviceDataResponse> {
        return iotService.streamDeviceData(deviceIds ?: emptyList(), types ?: emptyList())
    }

    @PostMapping("/alerts")
    fun createAlertRule(@RequestBody request: AlertRuleRequest): Mono<ResponseEntity<AlertRuleResponse>> {
        return iotService.createAlertRule(request)
            .map { ResponseEntity.ok(it) }
    }

    @GetMapping("/alerts")
    fun getAlertRules(
        @RequestParam(required = false) deviceType: DeviceType?,
        @RequestParam(defaultValue = "0") page: Int,
        @RequestParam(defaultValue = "20") size: Int
    ): Mono<ResponseEntity<List<AlertRuleResponse>>> {
        return iotService.getAlertRules(deviceType, page, size)
            .map { ResponseEntity.ok(it) }
    }

    @PostMapping("/maintenance")
    fun scheduleMaintenance(@RequestBody request: MaintenanceRequest): Mono<ResponseEntity<MaintenanceResponse>> {
        return iotService.scheduleMaintenance(request)
            .map { ResponseEntity.ok(it) }
    }

    @GetMapping("/analytics")
    fun getIoTAnalytics(
        @RequestParam(required = false) startDate: LocalDateTime?,
        @RequestParam(required = false) endDate: LocalDateTime?
    ): Mono<ResponseEntity<IoTAnalyticsResponse>> {
        return iotService.getIoTAnalytics(startDate, endDate)
            .map { ResponseEntity.ok(it) }
    }
}