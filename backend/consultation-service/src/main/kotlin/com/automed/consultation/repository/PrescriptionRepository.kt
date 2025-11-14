package com.automed.consultation.repository

import com.automed.consultation.domain.Prescription
import org.springframework.data.jpa.repository.JpaRepository
import org.springframework.stereotype.Repository
import java.util.*

@Repository
interface PrescriptionRepository : JpaRepository<Prescription, UUID> {

    fun findByConsultationId(consultationId: UUID): List<Prescription>

    fun findByConsultationIdOrderByPrescribedAtDesc(consultationId: UUID): List<Prescription>

    fun findByPrescribedBy(prescribedBy: UUID): List<Prescription>
}