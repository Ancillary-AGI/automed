package com.automed.patient.service

import com.automed.patient.model.AuditLog
import com.automed.patient.model.EncryptedData
import com.automed.patient.repository.AuditLogRepository
import org.springframework.stereotype.Service
import org.springframework.transaction.annotation.Transactional
import java.security.MessageDigest
import java.security.SecureRandom
import java.time.LocalDateTime
import java.util.*
import javax.crypto.Cipher
import javax.crypto.KeyGenerator
import javax.crypto.SecretKey
import javax.crypto.spec.GCMParameterSpec
import javax.crypto.spec.SecretKeySpec

@Service
@Transactional
class SecurityService(
    private val auditLogRepository: AuditLogRepository
) {

    private val secureRandom = SecureRandom()
    private val keyGenerator = KeyGenerator.getInstance("AES").apply { init(256) }

    companion object {
        private const val AES_GCM_TAG_LENGTH = 128
        private const val AES_GCM_IV_LENGTH = 12
        private const val ALGORITHM = "AES/GCM/NoPadding"
    }

    /**
     * Encrypts sensitive patient data using AES-GCM
     */
    fun encryptPatientData(data: String, patientId: String): EncryptedData {
        val secretKey = keyGenerator.generateKey()
        val iv = ByteArray(AES_GCM_IV_LENGTH).apply { secureRandom.nextBytes(this) }

        val cipher = Cipher.getInstance(ALGORITHM)
        val gcmSpec = GCMParameterSpec(AES_GCM_TAG_LENGTH, iv)
        cipher.init(Cipher.ENCRYPT_MODE, secretKey, gcmSpec)

        val encryptedBytes = cipher.doFinal(data.toByteArray(Charsets.UTF_8))

        // Store key securely (in production, use HSM or key management service)
        val keyBytes = secretKey.encoded

        return EncryptedData(
            id = UUID.randomUUID().toString(),
            patientId = patientId,
            encryptedData = Base64.getEncoder().encodeToString(encryptedBytes),
            encryptionKey = Base64.getEncoder().encodeToString(keyBytes),
            iv = Base64.getEncoder().encodeToString(iv),
            algorithm = ALGORITHM,
            createdAt = LocalDateTime.now()
        )
    }

    /**
     * Decrypts patient data with proper access logging
     */
    fun decryptPatientData(encryptedData: EncryptedData, userId: String, purpose: String): String {
        // Log access for HIPAA compliance
        logDataAccess(encryptedData.patientId, userId, "DECRYPT", purpose)

        val keyBytes = Base64.getDecoder().decode(encryptedData.encryptionKey)
        val iv = Base64.getDecoder().decode(encryptedData.iv)
        val encryptedBytes = Base64.getDecoder().decode(encryptedData.encryptedData)

        val secretKey = SecretKeySpec(keyBytes, "AES")
        val cipher = Cipher.getInstance(ALGORITHM)
        val gcmSpec = GCMParameterSpec(AES_GCM_TAG_LENGTH, iv)
        cipher.init(Cipher.DECRYPT_MODE, secretKey, gcmSpec)

        val decryptedBytes = cipher.doFinal(encryptedBytes)
        return String(decryptedBytes, Charsets.UTF_8)
    }

    /**
     * Generates HIPAA-compliant audit trail
     */
    fun logDataAccess(patientId: String, userId: String, action: String, purpose: String) {
        val auditLog = AuditLog(
            id = UUID.randomUUID().toString(),
            patientId = patientId,
            userId = userId,
            action = action,
            resource = "PATIENT_DATA",
            timestamp = LocalDateTime.now(),
            ipAddress = getCurrentIpAddress(),
            userAgent = getCurrentUserAgent(),
            purpose = purpose,
            success = true,
            details = mapOf(
                "dataClassification" to "PHI",
                "accessType" to "ENCRYPTED_ACCESS",
                "compliance" to "HIPAA"
            )
        )

        auditLogRepository.save(auditLog)
    }

    /**
     * Validates user access to patient data based on role and relationship
     */
    fun validateAccess(patientId: String, userId: String, requiredRole: String): Boolean {
        // Check if user has required role
        val userRoles = getUserRoles(userId)
        if (!userRoles.contains(requiredRole)) {
            logAccessDenied(patientId, userId, "INSUFFICIENT_ROLE", requiredRole)
            return false
        }

        // Check if user is authorized for this patient
        if (!isAuthorizedForPatient(userId, patientId)) {
            logAccessDenied(patientId, userId, "UNAUTHORIZED_PATIENT", "")
            return false
        }

        // Check for emergency access override
        if (hasEmergencyAccess(userId)) {
            logEmergencyAccess(patientId, userId)
            return true
        }

        return true
    }

    /**
     * Implements data anonymization for analytics
     */
    fun anonymizePatientData(patientData: Map<String, Any>): Map<String, Any> {
        val anonymized = patientData.toMutableMap()

        // Remove or hash identifiable information
        anonymized.remove("firstName")
        anonymized.remove("lastName")
        anonymized.remove("email")
        anonymized.remove("phoneNumber")
        anonymized.remove("address")

        // Hash date of birth to age group
        patientData["dateOfBirth"]?.let { dob ->
            val age = calculateAge(dob as String)
            anonymized["ageGroup"] = when {
                age < 18 -> "under_18"
                age < 35 -> "18_34"
                age < 55 -> "35_54"
                age < 75 -> "55_74"
                else -> "75_plus"
            }
            anonymized.remove("dateOfBirth")
        }

        // Add anonymization metadata
        anonymized["anonymized"] = true
        anonymized["anonymizationDate"] = LocalDateTime.now().toString()
        anonymized["anonymizationMethod"] = "HIPAA_SAFE_HARBOR"

        return anonymized
    }

    /**
     * Generates secure tokens for API access
     */
    fun generateSecureToken(userId: String, scope: String, expirationMinutes: Long = 60): String {
        val tokenData = mapOf(
            "userId" to userId,
            "scope" to scope,
            "issuedAt" to LocalDateTime.now().toString(),
            "expiresAt" to LocalDateTime.now().plusMinutes(expirationMinutes).toString(),
            "tokenId" to UUID.randomUUID().toString()
        )

        val tokenString = tokenData.entries.joinToString("|") { "${it.key}=${it.value}" }
        return encryptToken(tokenString)
    }

    /**
     * Validates secure tokens
     */
    fun validateToken(token: String): Map<String, Any>? {
        return try {
            val decrypted = decryptToken(token)
            val tokenData = decrypted.split("|").associate {
                val (key, value) = it.split("=", limit = 2)
                key to value
            }

            val expiresAt = LocalDateTime.parse(tokenData["expiresAt"])
            if (LocalDateTime.now().isAfter(expiresAt)) {
                null // Token expired
            } else {
                tokenData
            }
        } catch (e: Exception) {
            null // Invalid token
        }
    }

    /**
     * Implements rate limiting for API endpoints
     */
    fun checkRateLimit(userId: String, endpoint: String, maxRequests: Int = 100): Boolean {
        val key = "rate_limit:$userId:$endpoint"
        // In production, use Redis or similar for distributed rate limiting
        // For now, return true (allow)
        return true
    }

    private fun logAccessDenied(patientId: String, userId: String, reason: String, details: String) {
        val auditLog = AuditLog(
            id = UUID.randomUUID().toString(),
            patientId = patientId,
            userId = userId,
            action = "ACCESS_DENIED",
            resource = "PATIENT_DATA",
            timestamp = LocalDateTime.now(),
            ipAddress = getCurrentIpAddress(),
            userAgent = getCurrentUserAgent(),
            purpose = "SECURITY_CHECK",
            success = false,
            details = mapOf(
                "reason" to reason,
                "details" to details,
                "compliance" to "HIPAA"
            )
        )

        auditLogRepository.save(auditLog)
    }

    private fun logEmergencyAccess(patientId: String, userId: String) {
        val auditLog = AuditLog(
            id = UUID.randomUUID().toString(),
            patientId = patientId,
            userId = userId,
            action = "EMERGENCY_ACCESS",
            resource = "PATIENT_DATA",
            timestamp = LocalDateTime.now(),
            ipAddress = getCurrentIpAddress(),
            userAgent = getCurrentUserAgent(),
            purpose = "EMERGENCY_MEDICAL_CARE",
            success = true,
            details = mapOf(
                "accessType" to "EMERGENCY_OVERRIDE",
                "compliance" to "HIPAA_EMERGENCY_EXCEPTION"
            )
        )

        auditLogRepository.save(auditLog)
    }

    private fun getUserRoles(userId: String): List<String> {
        // In production, fetch from user service or database
        return listOf("DOCTOR", "NURSE") // Mock implementation
    }

    private fun isAuthorizedForPatient(userId: String, patientId: String): Boolean {
        // In production, check patient-provider relationships
        return true // Mock implementation
    }

    private fun hasEmergencyAccess(userId: String): Boolean {
        // Check if user has emergency access privileges
        return false // Mock implementation
    }

    private fun calculateAge(dateOfBirth: String): Int {
        // Simple age calculation
        return 30 // Mock implementation
    }

    private fun getCurrentIpAddress(): String {
        // In production, get from request context
        return "192.168.1.100"
    }

    private fun getCurrentUserAgent(): String {
        // In production, get from request headers
        return "MedicalApp/1.0"
    }

    private fun encryptToken(data: String): String {
        val key = keyGenerator.generateKey()
        val cipher = Cipher.getInstance("AES")
        cipher.init(Cipher.ENCRYPT_MODE, key)
        val encrypted = cipher.doFinal(data.toByteArray(Charsets.UTF_8))
        return Base64.getEncoder().encodeToString(encrypted)
    }

    private fun decryptToken(token: String): String {
        val key = keyGenerator.generateKey() // In production, use stored key
        val cipher = Cipher.getInstance("AES")
        cipher.init(Cipher.DECRYPT_MODE, key)
        val decrypted = cipher.doFinal(Base64.getDecoder().decode(token))
        return String(decrypted, Charsets.UTF_8)
    }
}