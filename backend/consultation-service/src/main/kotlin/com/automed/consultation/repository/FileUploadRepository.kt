package com.automed.consultation.repository

import com.automed.consultation.domain.FileUpload
import org.springframework.data.jpa.repository.JpaRepository
import org.springframework.stereotype.Repository
import java.util.*

@Repository
interface FileUploadRepository : JpaRepository<FileUpload, UUID> {

    fun findByConsultationId(consultationId: UUID): List<FileUpload>

    fun findByConsultationIdOrderByUploadedAtDesc(consultationId: UUID): List<FileUpload>
}