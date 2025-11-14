package com.automed.consultation.domain

import jakarta.persistence.*
import jakarta.validation.constraints.NotNull
import org.springframework.data.annotation.CreatedDate
import org.springframework.data.jpa.domain.support.AuditingEntityListener
import java.time.LocalDateTime
import java.util.*

@Entity
@Table(name = "consultation_files")
@EntityListeners(AuditingEntityListener::class)
data class FileUpload(
    @Id
    @GeneratedValue(strategy = GenerationType.UUID)
    val id: UUID? = null,

    @Column(nullable = false)
    @NotNull
    val consultationId: UUID,

    @Column(nullable = false)
    @NotNull
    val uploaderId: UUID,

    @Column(nullable = false)
    @NotNull
    val fileName: String,

    @Column(nullable = false)
    @NotNull
    val fileUrl: String,

    @Column(nullable = false)
    @NotNull
    val fileSize: Long,

    @Column(nullable = false)
    @NotNull
    val mimeType: String,

    @Column
    val description: String? = null,

    @CreatedDate
    @Column(nullable = false, updatable = false)
    val uploadedAt: LocalDateTime? = null
)