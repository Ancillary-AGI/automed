package com.automed.consultation.domain

import jakarta.persistence.*
import jakarta.validation.constraints.NotNull
import org.springframework.data.annotation.CreatedDate
import org.springframework.data.jpa.domain.support.AuditingEntityListener
import java.time.LocalDateTime
import java.util.*

@Entity
@Table(name = "consultation_recordings")
@EntityListeners(AuditingEntityListener::class)
data class Recording(
    @Id
    @GeneratedValue(strategy = GenerationType.UUID)
    val id: UUID? = null,

    @Column(nullable = false)
    @NotNull
    val consultationId: UUID,

    @Column(nullable = false)
    @NotNull
    val recordingUrl: String,

    @Column(nullable = false)
    @NotNull
    val duration: Long, // in seconds

    @Column(nullable = false)
    @NotNull
    val fileSize: Long, // in bytes

    @Column(nullable = false)
    @Enumerated(EnumType.STRING)
    val recordingType: RecordingType = RecordingType.VIDEO,

    @Column
    val thumbnailUrl: String? = null,

    @Column
    val transcription: String? = null,

    @CreatedDate
    @Column(nullable = false, updatable = false)
    val createdAt: LocalDateTime? = null
)

enum class RecordingType {
    VIDEO, AUDIO, SCREEN_SHARE
}