package com.automed.consultation.repository

import com.automed.consultation.domain.Message
import org.springframework.data.jpa.repository.JpaRepository
import org.springframework.data.jpa.repository.Query
import org.springframework.data.repository.query.Param
import org.springframework.stereotype.Repository
import java.util.*

@Repository
interface MessageRepository : JpaRepository<Message, UUID> {

    @Query("SELECT m FROM Message m WHERE m.consultationId = :consultationId ORDER BY m.timestamp ASC")
    fun findByConsultationIdOrderByTimestamp(@Param("consultationId") consultationId: UUID): List<Message>

    fun findByConsultationId(consultationId: UUID): List<Message>

    @Query("SELECT COUNT(m) FROM Message m WHERE m.consultationId = :consultationId")
    fun countByConsultationId(@Param("consultationId") consultationId: UUID): Long
}