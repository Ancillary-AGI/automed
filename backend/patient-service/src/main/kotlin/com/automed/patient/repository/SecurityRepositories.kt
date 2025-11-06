package com.automed.patient.repository

import com.automed.patient.model.*
import org.springframework.data.jpa.repository.JpaRepository
import org.springframework.data.jpa.repository.Query
import org.springframework.data.repository.query.Param
import org.springframework.stereotype.Repository
import java.time.LocalDateTime

@Repository
interface AuditLogRepository : JpaRepository<AuditLog, String> {
    fun findByPatientId(patientId: String): List<AuditLog>
    fun findByUserId(userId: String): List<AuditLog>
    fun findByAction(action: String): List<AuditLog>
    fun findByResource(resource: String): List<AuditLog>
    fun findByTimestampBetween(startDate: LocalDateTime, endDate: LocalDateTime): List<AuditLog>
    fun findByPatientIdAndTimestampBetween(
        patientId: String,
        startDate: LocalDateTime,
        endDate: LocalDateTime
    ): List<AuditLog>

    @Query("SELECT a FROM AuditLog a WHERE a.patientId = :patientId AND a.success = false")
    fun findFailedAccessAttempts(@Param("patientId") patientId: String): List<AuditLog>

    @Query("SELECT COUNT(a) FROM AuditLog a WHERE a.userId = :userId AND a.action = 'ACCESS_DENIED' AND a.timestamp > :since")
    fun countRecentAccessDenials(
        @Param("userId") userId: String,
        @Param("since") since: LocalDateTime
    ): Long
}

@Repository
interface EncryptedDataRepository : JpaRepository<EncryptedData, String> {
    fun findByPatientId(patientId: String): List<EncryptedData>
    fun findByPatientIdAndCreatedAtBetween(
        patientId: String,
        startDate: LocalDateTime,
        endDate: LocalDateTime
    ): List<EncryptedData>
}

@Repository
interface SecurityEventRepository : JpaRepository<SecurityEvent, String> {
    fun findByEventType(eventType: String): List<SecurityEvent>
    fun findBySeverity(severity: String): List<SecurityEvent>
    fun findByResolved(resolved: Boolean): List<SecurityEvent>
    fun findByTimestampBetween(startDate: LocalDateTime, endDate: LocalDateTime): List<SecurityEvent>
}

@Repository
interface AccessPolicyRepository : JpaRepository<AccessPolicy, String> {
    fun findByResourceAndAction(resource: String, action: String): List<AccessPolicy>
    fun findByRolesContaining(role: String): List<AccessPolicy>
    fun findByIsActive(isActive: Boolean): List<AccessPolicy>
}

@Repository
interface ConsentRecordRepository : JpaRepository<ConsentRecord, String> {
    fun findByPatientId(patientId: String): List<ConsentRecord>
    fun findByPatientIdAndConsentType(patientId: String, consentType: String): List<ConsentRecord>
    fun findByConsentedAndRevoked(consented: Boolean, revoked: Boolean): List<ConsentRecord>
    fun findByConsentExpiresAtBefore(expiryDate: LocalDateTime): List<ConsentRecord>
}