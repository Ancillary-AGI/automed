package com.automed.iot.model

import jakarta.persistence.*
import java.time.LocalDateTime

@Entity
@Table(name = "iot_devices")
data class IoTDevice(
    @Id
    val id: String,
    val deviceId: String,
    val type: DeviceType,
    val name: String,
    val location: String,
    val status: DeviceStatus,
    @ElementCollection
    val capabilities: List<String>,
    @ElementCollection
    val metadata: Map<String, Any>,
    val registeredAt: LocalDateTime,
    val lastSeen: LocalDateTime?
)

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

data class DeviceData(
    val id: String,
    val deviceId: String,
    val dataType: String,
    val payload: Map<String, Any>,
    val timestamp: LocalDateTime,
    val quality: Double
)

data class AlertRule(
    val id: String,
    val name: String,
    val deviceType: DeviceType,
    val condition: String,
    val threshold: Double,
    val severity: AlertSeverity,
    val enabled: Boolean,
    val createdAt: LocalDateTime
)

data class MaintenanceSchedule(
    val id: String,
    val deviceId: String,
    val maintenanceType: String,
    val scheduledDate: LocalDateTime,
    val priority: String,
    val description: String,
    val status: MaintenanceStatus,
    val createdAt: LocalDateTime
)