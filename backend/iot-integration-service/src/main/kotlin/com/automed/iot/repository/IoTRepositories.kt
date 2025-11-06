package com.automed.iot.repository

import com.automed.iot.model.IoTDevice
import org.springframework.data.jpa.repository.JpaRepository
import org.springframework.stereotype.Repository

@Repository
interface IoTDeviceRepository : JpaRepository<IoTDevice, String> {
    fun findByDeviceId(deviceId: String): IoTDevice?
    fun findByType(type: DeviceType): List<IoTDevice>
    fun findByStatus(status: DeviceStatus): List<IoTDevice>
    fun findByLocation(location: String): List<IoTDevice>
}