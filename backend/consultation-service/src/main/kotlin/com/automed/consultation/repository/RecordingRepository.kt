package com.automed.consultation.repository

import com.automed.consultation.domain.Recording
import org.springframework.data.jpa.repository.JpaRepository
import org.springframework.stereotype.Repository
import java.util.*

@Repository
interface RecordingRepository : JpaRepository<Recording, UUID> {

    fun findByConsultationId(consultationId: UUID): List<Recording>

    fun findByConsultationIdOrderByCreatedAtDesc(consultationId: UUID): List<Recording>
}