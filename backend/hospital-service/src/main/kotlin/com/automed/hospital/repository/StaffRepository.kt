package com.automed.hospital.repository

import com.automed.hospital.domain.Staff
import com.automed.hospital.domain.StaffStatus
import org.springframework.data.domain.Page
import org.springframework.data.domain.Pageable
import org.springframework.data.jpa.repository.JpaRepository
import org.springframework.data.jpa.repository.Query
import org.springframework.data.repository.query.Param
import org.springframework.stereotype.Repository
import java.util.*

@Repository
interface StaffRepository : JpaRepository<Staff, UUID> {

    fun findByHospitalId(hospitalId: UUID, pageable: Pageable): Page<Staff>

    fun findByEmployeeId(employeeId: String): Optional<Staff>

    fun findByEmail(email: String): Optional<Staff>

    fun findByRole(role: com.automed.hospital.domain.StaffRole, pageable: Pageable): Page<Staff>

    fun findByDepartment(department: com.automed.hospital.domain.Department, pageable: Pageable): Page<Staff>

    fun findByStatus(status: StaffStatus, pageable: Pageable): Page<Staff>

    @Query("SELECT s FROM Staff s WHERE s.hospitalId = :hospitalId AND s.status = :status")
    fun findByHospitalIdAndStatus(
        @Param("hospitalId") hospitalId: UUID,
        @Param("status") status: StaffStatus,
        pageable: Pageable
    ): Page<Staff>

    @Query("SELECT COUNT(s) FROM Staff s WHERE s.hospitalId = :hospitalId AND s.status = 'ACTIVE'")
    fun countActiveStaffByHospitalId(@Param("hospitalId") hospitalId: UUID): Long
}
