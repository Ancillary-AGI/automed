package com.automed.iot.dto

import com.automed.iot.model.*
import java.time.LocalDateTime

// Enums
enum class DeviceType {
    VITAL_SIGNS_MONITOR,
    INFUSION_PUMP,
    VENTILATOR,
    ECG_MONITOR,
    THERMOMETER,
    BLOOD_PRESSURE_MONITOR,
    PULSE_OXIMETER,
    SCALE,
    GLUCOMETER,
    DEFIBRILLATOR,
    PATIENT_MONITOR,
    OTHER
}

enum class DeviceStatus {
    ONLINE,
    OFFLINE,
    MAINTENANCE,
    ERROR,
    DISCONNECTED
}

enum class AlertSeverity {
    LOW,
    MEDIUM,
    HIGH,
    CRITICAL
}

enum class MaintenanceStatus {
    SCHEDULED,
    IN_PROGRESS,
    COMPLETED,
    CANCELLED
}

// Request DTOs
data class RegisterDeviceRequest(
    val deviceId: String,
    val type: DeviceType,
    val name: String,
    val location: String,
    val capabilities: List<String>,
    val metadata: Map<String, Any> = emptyMap()
)

data class DeviceDataRequest(
    val dataType: String,
    val payload: Map<String, Any>,
    val timestamp: LocalDateTime? = null,
    val quality: Double? = null
)

data class AlertRuleRequest(
    val name: String,
    val deviceType: DeviceType,
    val condition: String,
    val threshold: Double,
    val severity: AlertSeverity
)

data class MaintenanceRequest(
    val deviceId: String,
    val maintenanceType: String,
    val scheduledDate: LocalDateTime,
    val priority: String,
    val description: String
)

// Response DTOs
data class IoTDeviceResponse(
    val id: String,
    val deviceId: String,
    val type: DeviceType,
    val name: String,
    val location: String,
    val status: DeviceStatus,
    val capabilities: List<String>,
    val metadata: Map<String, Any>,
    val registeredAt: LocalDateTime,
    val lastSeen: LocalDateTime?
) {
    companion object {
        fun fromEntity(entity: IoTDevice): IoTDeviceResponse {
            return IoTDeviceResponse(
                id = entity.id,
                deviceId = entity.deviceId,
                type = entity.type,
                name = entity.name,
                location = entity.location,
                status = entity.status,
                capabilities = entity.capabilities,
                metadata = entity.metadata,
                registeredAt = entity.registeredAt,
                lastSeen = entity.lastSeen
            )
        }
    }
}

data class DeviceDataResponse(
    val dataId: String,
    val deviceId: String,
    val dataType: String,
    val timestamp: LocalDateTime,
    val processed: Boolean
)

data class AlertRuleResponse(
    val id: String,
    val name: String,
    val deviceType: DeviceType,
    val condition: String,
    val threshold: Double,
    val severity: AlertSeverity,
    val enabled: Boolean,
    val createdAt: LocalDateTime
) {
    companion object {
        fun fromEntity(entity: AlertRule): AlertRuleResponse {
            return AlertRuleResponse(
                id = entity.id,
                name = entity.name,
                deviceType = entity.deviceType,
                condition = entity.condition,
                threshold = entity.threshold,
                severity = entity.severity,
                enabled = entity.enabled,
                createdAt = entity.createdAt
            )
        }
    }
}

data class MaintenanceResponse(
    val id: String,
    val deviceId: String,
    val maintenanceType: String,
    val scheduledDate: LocalDateTime,
    val priority: String,
    val description: String,
    val status: MaintenanceStatus,
    val createdAt: LocalDateTime
) {
    companion object {
        fun fromEntity(entity: MaintenanceSchedule): MaintenanceResponse {
            return MaintenanceResponse(
                id = entity.id,
                deviceId = entity.deviceId,
                maintenanceType = entity.maintenanceType,
                scheduledDate = entity.scheduledDate,
                priority = entity.priority,
                description = entity.description,
                status = entity.status,
                createdAt = entity.createdAt
            )
        }
    }
}

data class IoTAnalyticsResponse(
    val totalDevices: Long,
    val activeDevices: Long,
    val totalDataPoints: Long,
    val alertsTriggered: Int,
    val uptimePercentage: Double,
    val period: AnalyticsPeriod
)

data class AnalyticsPeriod(
    val startDate: LocalDateTime,
    val endDate: LocalDateTime
)