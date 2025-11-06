package com.automed.patient.model

import jakarta.persistence.*
import java.time.LocalDateTime

@Entity
@Table(name = "audit_logs")
data class AuditLog(
    @Id
    val id: String,
    val patientId: String,
    val userId: String,
    val action: String, // CREATE, READ, UPDATE, DELETE, ACCESS_DENIED, etc.
    val resource: String, // PATIENT_DATA, MEDICAL_RECORD, etc.
    val timestamp: LocalDateTime,
    val ipAddress: String,
    val userAgent: String,
    val purpose: String,
    val success: Boolean,
    @ElementCollection
    val details: Map<String, Any> = emptyMap()
)

@Entity
@Table(name = "encrypted_data")
data class EncryptedData(
    @Id
    val id: String,
    val patientId: String,
    @Column(columnDefinition = "TEXT")
    val encryptedData: String,
    @Column(columnDefinition = "TEXT")
    val encryptionKey: String,
    val iv: String,
    val algorithm: String,
    val createdAt: LocalDateTime
)

@Entity
@Table(name = "security_events")
data class SecurityEvent(
    @Id
    val id: String,
    val eventType: String, // BREACH_ATTEMPT, UNAUTHORIZED_ACCESS, etc.
    val severity: String, // LOW, MEDIUM, HIGH, CRITICAL
    val description: String,
    val source: String,
    val timestamp: LocalDateTime,
    @ElementCollection
    val metadata: Map<String, Any> = emptyMap(),
    val resolved: Boolean = false,
    val resolvedAt: LocalDateTime? = null,
    val resolution: String? = null
)

@Entity
@Table(name = "access_policies")
data class AccessPolicy(
    @Id
    val id: String,
    val name: String,
    val resource: String,
    val action: String,
    @ElementCollection
    val roles: List<String>,
    @ElementCollection
    val conditions: Map<String, Any> = emptyMap(),
    val isActive: Boolean = true,
    val createdAt: LocalDateTime,
    val updatedAt: LocalDateTime
)

@Entity
@Table(name = "consent_records")
data class ConsentRecord(
    @Id
    val id: String,
    val patientId: String,
    val consentType: String, // DATA_SHARING, TREATMENT, RESEARCH, etc.
    val consented: Boolean,
    val consentGivenAt: LocalDateTime,
    val consentExpiresAt: LocalDateTime? = null,
    val purpose: String,
    val scope: String,
    @ElementCollection
    val grantedPermissions: List<String>,
    val revoked: Boolean = false,
    val revokedAt: LocalDateTime? = null,
    val revocationReason: String? = null
)