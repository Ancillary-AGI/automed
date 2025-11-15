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
    name = "consultation_messages",
    indexes = [
        Index(name = "idx_message_consultation_id", columnList = "consultationId"),
        Index(name = "idx_message_sender_id", columnList = "senderId"),
        Index(name = "idx_message_timestamp", columnList = "timestamp")
    ]
)
@EntityListeners(AuditingEntityListener::class)
data class Message(
    @Id
    @GeneratedValue(strategy = GenerationType.UUID)
    val id: UUID? = null,

    @Column(nullable = false)
    @NotNull
    val consultationId: UUID,

    @Column(nullable = false)
    @NotNull
    val senderId: UUID,

    @Column(nullable = false)
    @NotNull
    @Size(min = 1, max = 100)
    val senderName: String,

    @Column(nullable = false, columnDefinition = "TEXT")
    @NotNull
    @Size(min = 1, max = 10000) // Increased limit for longer messages
    val content: String,

    @Column(nullable = false)
    @Enumerated(EnumType.STRING)
    val messageType: MessageType = MessageType.TEXT,

    @Column
    val fileUrl: String? = null,

    @Column
    @Size(max = 255)
    val fileName: String? = null,

    @Column
    val fileSize: Long? = null,

    @Column(nullable = false)
    val isEncrypted: Boolean = false,

    @CreatedDate
    @Column(nullable = false, updatable = false)
    val timestamp: LocalDateTime? = null,

    @Column(nullable = false)
    val isDeleted: Boolean = false
) {
    // Business logic methods
    fun isValidFileMessage(): Boolean {
        return when (messageType) {
            MessageType.IMAGE, MessageType.FILE -> fileUrl != null && fileName != null && fileSize != null
            else -> fileUrl == null // Text messages shouldn't have file data
        }
    }

    fun isValidFileSize(): Boolean {
        return fileSize == null || (fileSize > 0 && fileSize <= 100 * 1024 * 1024) // Max 100MB
    }

    companion object {
        val ALLOWED_FILE_TYPES = setOf(
            // Images
            "image/jpeg", "image/png", "image/gif", "image/webp",
            // Documents
            "application/pdf", "application/msword", "application/vnd.openxmlformats-officedocument.wordprocessingml.document",
            "application/vnd.ms-excel", "application/vnd.openxmlformats-officedocument.spreadsheetml.sheet",
            // Text files
            "text/plain", "text/csv"
        )

        const val MAX_FILE_SIZE_BYTES = 100L * 1024L * 1024L // 100MB
        const val MAX_MESSAGE_LENGTH = 10000
        const val MAX_SENDER_NAME_LENGTH = 100
    }
}

enum class MessageType {
    TEXT, IMAGE, FILE, SYSTEM
}