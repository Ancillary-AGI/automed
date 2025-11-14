package com.automed.consultation.domain

import jakarta.persistence.*
import jakarta.validation.constraints.NotNull
import org.springframework.data.annotation.CreatedDate
import org.springframework.data.jpa.domain.support.AuditingEntityListener
import java.time.LocalDateTime
import java.util.*

@Entity
@Table(name = "consultation_prescriptions")
@EntityListeners(AuditingEntityListener::class)
data class Prescription(
    @Id
    @GeneratedValue(strategy = GenerationType.UUID)
    val id: UUID? = null,

    @Column(nullable = false)
    @NotNull
    val consultationId: UUID,

    @Column(nullable = false)
    @NotNull
    val medicationName: String,

    @Column(nullable = false)
    @NotNull
    val dosage: String,

    @Column(nullable = false)
    @NotNull
    val frequency: String,

    @Column(nullable = false)
    @NotNull
    val duration: String,

    @Column
    val instructions: String? = null,

    @Column(nullable = false)
    @NotNull
    val quantity: Int,

    @Column(nullable = false)
    @NotNull
    val prescribedBy: UUID, // doctor ID

    @Column
    val pharmacyNotes: String? = null,

    @Column
    val filled: Boolean = false,

    @Column
    val filledAt: LocalDateTime? = null,

    @CreatedDate
    @Column(nullable = false, updatable = false)
    val prescribedAt: LocalDateTime? = null
)