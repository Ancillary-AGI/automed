package com.automed.hospital.repository

import com.automed.hospital.domain.Equipment
import com.automed.hospital.domain.EquipmentStatus
import com.automed.hospital.domain.EquipmentType
import org.springframework.data.domain.Page
import org.springframework.data.domain.Pageable
import org.springframework.data.jpa.repository.JpaRepository
import org.springframework.data.jpa.repository.Query
import org.springframework.data.repository.query.Param
import org.springframework.stereotype.Repository
import java.time.LocalDateTime
import java.util.*

@Repository
interface EquipmentRepository : JpaRepository<Equipment, UUID> {

    fun findByHospitalId(hospitalId: UUID, pageable: Pageable): Page<Equipment>

    fun findByEquipmentCode(equipmentCode: String): Optional<Equipment>

    fun findByType(type: EquipmentType, pageable: Pageable): Page<Equipment>

    fun findByStatus(status: EquipmentStatus, pageable: Pageable): Page<Equipment>

    fun findByManufacturer(manufacturer: String, pageable: Pageable): Page<Equipment>

    @Query("SELECT e FROM Equipment e WHERE e.hospitalId = :hospitalId AND e.status = :status")
    fun findByHospitalIdAndStatus(
        @Param("hospitalId") hospitalId: UUID,
        @Param("status") status: EquipmentStatus,
        pageable: Pageable
    ): Page<Equipment>

    @Query("SELECT e FROM Equipment e WHERE e.nextMaintenanceDate < :currentDate")
    fun findEquipmentDueForMaintenance(
        @Param("currentDate") currentDate: LocalDateTime,
        pageable: Pageable
    ): Page<Equipment>

    @Query("SELECT COUNT(e) FROM Equipment e WHERE e.hospitalId = :hospitalId AND e.status = 'OPERATIONAL'")
    fun countOperationalEquipmentByHospitalId(@Param("hospitalId") hospitalId: UUID): Long

    @Query("SELECT COUNT(e) FROM Equipment e WHERE e.hospitalId = :hospitalId AND e.status = 'MAINTENANCE'")
    fun countMaintenanceEquipmentByHospitalId(@Param("hospitalId") hospitalId: UUID): Long
}
