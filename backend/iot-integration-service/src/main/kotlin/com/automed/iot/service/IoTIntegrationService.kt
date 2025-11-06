package com.automed.iot.service

import com.automed.iot.dto.*
import com.automed.iot.model.*
import com.automed.iot.repository.IoTDeviceRepository
import org.springframework.kafka.core.KafkaTemplate
import org.springframework.stereotype.Service
import reactor.core.publisher.Flux
import reactor.core.publisher.Mono
import java.time.LocalDateTime
import java.util.*

@Service
class IoTIntegrationService(
    private val deviceRepository: IoTDeviceRepository,
    private val kafkaTemplate: KafkaTemplate<String, Any>
) {

    fun registerDevice(request: RegisterDeviceRequest): Mono<IoTDeviceResponse> {
        return Mono.fromCallable {
            val device = IoTDevice(
                id = UUID.randomUUID().toString(),
                deviceId = request.deviceId,
                type = request.type,
                name = request.name,
                location = request.location,
                status = DeviceStatus.OFFLINE,
                capabilities = request.capabilities,
                metadata = request.metadata,
                registeredAt = LocalDateTime.now(),
                lastSeen = null
            )

            val savedDevice = deviceRepository.save(device)
            kafkaTemplate.send("device-registered", savedDevice)

            IoTDeviceResponse.fromEntity(savedDevice)
        }
    }

    fun getDevices(
        type: DeviceType?,
        status: DeviceStatus?,
        page: Int,
        size: Int
    ): Mono<List<IoTDeviceResponse>> {
        return Mono.fromCallable {
            val devices = deviceRepository.findAll()
                .filter { type == null || it.type == type }
                .filter { status == null || it.status == status }
                .sortedByDescending { it.registeredAt }
                .drop(page * size)
                .take(size)

            devices.map { IoTDeviceResponse.fromEntity(it) }
        }
    }

    fun getDevice(deviceId: String): Mono<IoTDeviceResponse> {
        return Mono.fromCallable {
            val device = deviceRepository.findByDeviceId(deviceId)
                ?: throw IoTDeviceNotFoundException("Device not found: $deviceId")
            IoTDeviceResponse.fromEntity(device)
        }
    }

    fun updateDeviceStatus(deviceId: String, status: DeviceStatus): Mono<IoTDeviceResponse> {
        return Mono.fromCallable {
            val device = deviceRepository.findByDeviceId(deviceId)
                ?: throw IoTDeviceNotFoundException("Device not found: $deviceId")

            val updatedDevice = device.copy(
                status = status,
                lastSeen = LocalDateTime.now()
            )

            val savedDevice = deviceRepository.save(updatedDevice)
            kafkaTemplate.send("device-status-changed", savedDevice)

            IoTDeviceResponse.fromEntity(savedDevice)
        }
    }

    fun submitDeviceData(deviceId: String, data: DeviceDataRequest): Mono<DeviceDataResponse> {
        return Mono.fromCallable {
            val device = deviceRepository.findByDeviceId(deviceId)
                ?: throw IoTDeviceNotFoundException("Device not found: $deviceId")

            val deviceData = DeviceData(
                id = UUID.randomUUID().toString(),
                deviceId = deviceId,
                dataType = data.dataType,
                payload = data.payload,
                timestamp = data.timestamp ?: LocalDateTime.now(),
                quality = data.quality ?: 1.0
            )

            // Update device last seen
            deviceRepository.save(device.copy(lastSeen = LocalDateTime.now()))

            // Publish to Kafka
            kafkaTemplate.send("device-data", deviceData)

            DeviceDataResponse(
                dataId = deviceData.id,
                deviceId = deviceData.deviceId,
                dataType = deviceData.dataType,
                timestamp = deviceData.timestamp,
                processed = true
            )
        }
    }

    fun getDeviceData(
        deviceId: String,
        startDate: LocalDateTime?,
        endDate: LocalDateTime?,
        page: Int,
        size: Int
    ): Mono<List<DeviceDataResponse>> {
        return Mono.fromCallable {
            // In a real implementation, this would query a time-series database
            // For now, return mock data
            listOf(
                DeviceDataResponse(
                    dataId = UUID.randomUUID().toString(),
                    deviceId = deviceId,
                    dataType = "vital_signs",
                    timestamp = LocalDateTime.now().minusMinutes(5),
                    processed = true
                )
            )
        }
    }

    fun streamDeviceData(deviceIds: List<String>, types: List<String>): Flux<DeviceDataResponse> {
        // In a real implementation, this would stream from Kafka or WebSocket
        return Flux.empty()
    }

    fun createAlertRule(request: AlertRuleRequest): Mono<AlertRuleResponse> {
        return Mono.fromCallable {
            val rule = AlertRule(
                id = UUID.randomUUID().toString(),
                name = request.name,
                deviceType = request.deviceType,
                condition = request.condition,
                threshold = request.threshold,
                severity = request.severity,
                enabled = true,
                createdAt = LocalDateTime.now()
            )

            // Save rule (would need AlertRuleRepository in real implementation)
            kafkaTemplate.send("alert-rule-created", rule)

            AlertRuleResponse.fromEntity(rule)
        }
    }

    fun getAlertRules(deviceType: DeviceType?, page: Int, size: Int): Mono<List<AlertRuleResponse>> {
        return Mono.fromCallable {
            // Mock implementation
            listOf(
                AlertRuleResponse(
                    id = UUID.randomUUID().toString(),
                    name = "High Temperature Alert",
                    deviceType = DeviceType.THERMOMETER,
                    condition = "temperature > 100.4",
                    threshold = 100.4,
                    severity = AlertSeverity.HIGH,
                    enabled = true,
                    createdAt = LocalDateTime.now()
                )
            )
        }
    }

    fun scheduleMaintenance(request: MaintenanceRequest): Mono<MaintenanceResponse> {
        return Mono.fromCallable {
            val maintenance = MaintenanceSchedule(
                id = UUID.randomUUID().toString(),
                deviceId = request.deviceId,
                maintenanceType = request.maintenanceType,
                scheduledDate = request.scheduledDate,
                priority = request.priority,
                description = request.description,
                status = MaintenanceStatus.SCHEDULED,
                createdAt = LocalDateTime.now()
            )

            kafkaTemplate.send("maintenance-scheduled", maintenance)

            MaintenanceResponse.fromEntity(maintenance)
        }
    }

    fun getIoTAnalytics(startDate: LocalDateTime?, endDate: LocalDateTime?): Mono<IoTAnalyticsResponse> {
        return Mono.fromCallable {
            IoTAnalyticsResponse(
                totalDevices = deviceRepository.count(),
                activeDevices = deviceRepository.findAll().count { it.status == DeviceStatus.ONLINE },
                totalDataPoints = 1000L, // Mock
                alertsTriggered = 25, // Mock
                uptimePercentage = 0.95,
                period = AnalyticsPeriod(startDate ?: LocalDateTime.now().minusDays(7), endDate ?: LocalDateTime.now())
            )
        }
    }
}

class IoTDeviceNotFoundException(message: String) : Exception(message)