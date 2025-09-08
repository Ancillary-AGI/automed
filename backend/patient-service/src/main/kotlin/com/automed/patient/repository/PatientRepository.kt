package com.automed.patient.repository

import com.automed.patient.domain.Patient
import org.springframework.data.domain.Page
import org.springframework.data.domain.Pageable
import org.springframework.data.jpa.repository.JpaRepository
import org.springframework.data.jpa.repository.Query
import org.springframework.stereotype.Repository
import java.util.*

@Repository
interface PatientRepository : JpaRepository<Patient, UUID> {
    
    fun findByPatientId(patientId: String): Optional<Patient>
    
    fun findByEmail(email: String): Optional<Patient>
    
    fun findByFirstNameContainingIgnoreCaseOrLastNameContainingIgnoreCase(
        firstName: String,
        lastName: String,
        pageable: Pageable
    ): Page<Patient>
    
    @Query("SELECT p FROM Patient p WHERE p.status = 'ACTIVE'")
    fun findActivePatients(pageable: Pageable): Page<Patient>
    
    @Query("SELECT COUNT(p) FROM Patient p WHERE p.status = 'ACTIVE'")
    fun countActivePatients(): Long
    
    @Query("SELECT p FROM Patient p WHERE p.createdAt >= CURRENT_DATE")
    fun findPatientsRegisteredToday(): List<Patient>
}