package com.automed.hospital.repository

import com.automed.hospital.domain.Hospital
import com.automed.hospital.domain.HospitalStatus
import com.automed.hospital.domain.HospitalType
import org.springframework.data.domain.Page
import org.springframework.data.domain.Pageable
import org.springframework.data.jpa.repository.JpaRepository
import org.springframework.data.jpa.repository.Query
import org.springframework.data.repository.query.Param
import org.springframework.stereotype.Repository
import java.util.*

@Repository
interface HospitalRepository : JpaRepository<Hospital, UUID> {

    fun findByHospitalCode(hospitalCode: String): Optional<Hospital>

    fun findByEmail(email: String): Optional<Hospital>

    fun findByType(type: HospitalType, pageable: Pageable): Page<Hospital>

    fun findByStatus(status: HospitalStatus, pageable: Pageable): Page<Hospital>

    fun findByNameContainingIgnoreCase(name: String, pageable: Pageable): Page<Hospital>

    @Query("SELECT h FROM Hospital h WHERE h.type = :type AND h.status = :status")
    fun findByTypeAndStatus(
        @Param("type") type: HospitalType,
        @Param("status") status: HospitalStatus,
        pageable: Pageable
    ): Page<Hospital>

    @Query("SELECT h FROM Hospital h WHERE h.city = :city")
    fun findByCity(@Param("city") city: String, pageable: Pageable): Page<Hospital>

    @Query("SELECT h FROM Hospital h WHERE h.state = :state")
    fun findByState(@Param("state") state: String, pageable: Pageable): Page<Hospital>

    @Query("SELECT COUNT(h) FROM Hospital h WHERE h.status = 'ACTIVE'")
    fun countActiveHospitals(): Long

    @Query("SELECT h FROM Hospital h WHERE h.capacity > h.currentOccupancy")
    fun findHospitalsWithAvailableBeds(pageable: Pageable): Page<Hospital>
}
