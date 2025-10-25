package com.automed.consultation.repository

import com.automed.consultation.domain.Consultation
import com.automed.consultation.domain.ConsultationStatus
import org.springframework.data.domain.Page
import org.springframework.data.domain.Pageable
import org.springframework.data.jpa.repository.JpaRepository
import org.springframework.data.jpa.repository.Query
import org.springframework.data.repository.query.Param
import org.springframework.stereotype.Repository
import java.time.LocalDateTime
import java.util.*

@Repository
interface ConsultationRepository : JpaRepository<Consultation, UUID> {

    fun findByPatientId(patientId: UUID, pageable: Pageable): Page<Consultation>

    fun findByDoctorId(doctorId: UUID, pageable: Pageable): Page<Consultation>

    fun findByHospitalId(hospitalId: UUID, pageable: Pageable): Page<Consultation>

    fun findByStatus(status: ConsultationStatus, pageable: Pageable): Page<Consultation>

    @Query("SELECT c FROM Consultation c WHERE c.patientId = :patientId AND c.status IN :statuses")
    fun findByPatientIdAndStatusIn(
        @Param("patientId") patientId: UUID,
        @Param("statuses") statuses: List<ConsultationStatus>,
        pageable: Pageable
    ): Page<Consultation>

    @Query("SELECT c FROM Consultation c WHERE c.doctorId = :doctorId AND c.status IN :statuses")
    fun findByDoctorIdAndStatusIn(
        @Param("doctorId") doctorId: UUID,
        @Param("statuses") statuses: List<ConsultationStatus>,
        pageable: Pageable
    ): Page<Consultation>

    @Query("SELECT c FROM Consultation c WHERE c.scheduledAt BETWEEN :startDate AND :endDate")
    fun findByScheduledAtBetween(
        @Param("startDate") startDate: LocalDateTime,
        @Param("endDate") LocalDateTime,
        pageable: Pageable
    ): Page<Consultation>

    @Query("SELECT c FROM Consultation c WHERE c.patientId = :patientId OR c.doctorId = :doctorId")
    fun findByPatientIdOrDoctorId(
        @Param("patientId") patientId: UUID,
        @Param("doctorId") doctorId: UUID,
        pageable: Pageable
    ): Page<Consultation>

    @Query("SELECT COUNT(c) FROM Consultation c WHERE c.status = 'IN_PROGRESS'")
    fun countActiveConsultations(): Long

    @Query("SELECT c FROM Consultation c WHERE c.status = 'SCHEDULED' AND c.scheduledAt < :currentTime")
    fun findOverdueConsultations(@Param("currentTime") currentTime: LocalDateTime): List<Consultation>
}
