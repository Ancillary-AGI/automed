package com.automed.consultation.domain

import jakarta.persistence.*
import jakarta.validation.constraints.NotNull
import org.springframework.data.annotation.CreatedDate
import org.springframework.data.jpa.domain.support.AuditingEntityListener
import java.time.LocalDateTime
import java.util.*

@Entity
@Table(name = "consultation_messages")
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
    val senderName: String,

    @Column(nullable = false, length = 2000)
    @NotNull
    val content: String,

    @Column(nullable = false)
    @Enumerated(EnumType.STRING)
    val messageType: MessageType = MessageType.TEXT,

    @Column
    val fileUrl: String? = null,

    @Column
    val fileName: String? = null,

    @Column
    val fileSize: Long? = null,

    @CreatedDate
    @Column(nullable = false, updatable = false)
    val timestamp: LocalDateTime? = null
)

enum class MessageType {
    TEXT, IMAGE, FILE, SYSTEM
}