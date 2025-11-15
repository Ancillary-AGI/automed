package com.automed.consultation.domain

import jakarta.persistence.*
import jakarta.validation.constraints.NotNull
import jakarta.validation.constraints.Size
import org.springframework.data.annotation.CreatedDate
import org.springframework.data.jpa.domain.support.AuditingEntityListener
import java.time.LocalDateTime
import java.util.*

@Entity
@Table(
    name = "consultation_files",
    indexes = [
        Index(name = "idx_file_consultation_id", columnList = "consultationId"),
        Index(name = "idx_file_uploader_id", columnList = "uploaderId"),
        Index(name = "idx_file_uploaded_at", columnList = "uploadedAt")
    ]
)
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
    @Size(min = 1, max = 255)
    val fileName: String,

    @Column(nullable = false)
    @NotNull
    @Size(max = 500)
    val fileUrl: String,

    @Column(nullable = false)
    @NotNull
    val fileSize: Long,

    @Column(nullable = false)
    @NotNull
    @Size(max = 100)
    val mimeType: String,

    @Column
    @Size(max = 1000)
    val description: String? = null,

    @Column(nullable = false)
    val isScanned: Boolean = false,

    @Column
    val scanResult: String? = null,

    @Column(nullable = false)
    val isEncrypted: Boolean = false,

    @CreatedDate
    @Column(nullable = false, updatable = false)
    val uploadedAt: LocalDateTime? = null
) {
    // Business logic methods
    fun isValidFileSize(): Boolean {
        return fileSize > 0 && fileSize <= MAX_FILE_SIZE_BYTES
    }

    fun isAllowedFileType(): Boolean {
        return ALLOWED_MIME_TYPES.contains(mimeType.lowercase())
    }

    fun isSafeFileName(): Boolean {
        // Prevent path traversal attacks
        return !fileName.contains("..") &&
               !fileName.contains("/") &&
               !fileName.contains("\\") &&
               fileName.length <= MAX_FILENAME_LENGTH
    }

    companion object {
        val ALLOWED_MIME_TYPES = setOf(
            // Images
            "image/jpeg", "image/jpg", "image/png", "image/gif", "image/webp", "image/svg+xml",
            // Documents
            "application/pdf", "application/msword",
            "application/vnd.openxmlformats-officedocument.wordprocessingml.document",
            "application/vnd.ms-excel",
            "application/vnd.openxmlformats-officedocument.spreadsheetml.sheet",
            "application/vnd.ms-powerpoint",
            "application/vnd.openxmlformats-officedocument.presentationml.presentation",
            // Text files
            "text/plain", "text/csv", "text/html", "text/markdown",
            // Archives (with caution)
            "application/zip", "application/x-rar-compressed"
        )

        const val MAX_FILE_SIZE_BYTES = 50L * 1024L * 1024L // 50MB
        const val MAX_FILENAME_LENGTH = 255
    }
}