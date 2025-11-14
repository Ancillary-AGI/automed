package com.automed.imaging.config

import org.springframework.beans.factory.annotation.Value
import org.springframework.context.annotation.Bean
import org.springframework.context.annotation.Configuration
import org.springframework.security.crypto.encrypt.Encryptors
import org.springframework.security.crypto.encrypt.TextEncryptor
import javax.crypto.Cipher
import javax.crypto.KeyGenerator
import javax.crypto.SecretKey
import javax.crypto.spec.SecretKeySpec
import java.security.SecureRandom
import java.util.Base64

@Configuration
class HIPAAConfig {

    @Value("\${imaging.hipaa.compliance.encryption.algorithm:AES256}")
    private lateinit var encryptionAlgorithm: String

    @Value("\${jasypt.encryptor.password}")
    private lateinit var encryptionPassword: String

    @Bean
    fun textEncryptor(): TextEncryptor {
        return Encryptors.text(encryptionPassword, generateSalt())
    }

    @Bean
    fun dataEncryptor(): DataEncryptor {
        return DataEncryptor(encryptionAlgorithm, encryptionPassword)
    }

    @Bean
    fun auditLogger(): HIPAAuditLogger {
        return HIPAAuditLogger()
    }

    private fun generateSalt(): String {
        val random = SecureRandom()
        val salt = ByteArray(16)
        random.nextBytes(salt)
        return Base64.getEncoder().encodeToString(salt)
    }
}

class DataEncryptor(
    private val algorithm: String,
    private val password: String
) {

    private val key: SecretKey by lazy {
        val keyBytes = password.toByteArray(Charsets.UTF_8).copyOf(32)
        SecretKeySpec(keyBytes, "AES")
    }

    fun encrypt(data: ByteArray): ByteArray {
        val cipher = Cipher.getInstance("AES/CBC/PKCS5Padding")
        cipher.init(Cipher.ENCRYPT_MODE, key)
        val encrypted = cipher.doFinal(data)
        val iv = cipher.iv

        // Prepend IV to encrypted data
        return iv + encrypted
    }

    fun decrypt(encryptedData: ByteArray): ByteArray {
        val cipher = Cipher.getInstance("AES/CBC/PKCS5Padding")
        val iv = encryptedData.copyOfRange(0, 16)
        val encrypted = encryptedData.copyOfRange(16, encryptedData.size)

        cipher.init(Cipher.DECRYPT_MODE, key, javax.crypto.spec.IvParameterSpec(iv))
        return cipher.doFinal(encrypted)
    }

    fun encryptString(data: String): String {
        val encrypted = encrypt(data.toByteArray(Charsets.UTF_8))
        return Base64.getEncoder().encodeToString(encrypted)
    }

    fun decryptString(encryptedData: String): String {
        val encrypted = Base64.getDecoder().decode(encryptedData)
        val decrypted = decrypt(encrypted)
        return String(decrypted, Charsets.UTF_8)
    }
}

class HIPAAuditLogger {

    private val logger = org.slf4j.LoggerFactory.getLogger(HIPAAuditLogger::class.java)

    fun logAccess(
        userId: String,
        patientId: String,
        resource: String,
        action: AuditAction,
        success: Boolean,
        ipAddress: String? = null,
        userAgent: String? = null,
        additionalInfo: Map<String, Any> = emptyMap()
    ) {
        val auditEntry = AuditEntry(
            timestamp = java.time.LocalDateTime.now(),
            userId = userId,
            patientId = patientId,
            resource = resource,
            action = action,
            success = success,
            ipAddress = ipAddress,
            userAgent = userAgent,
            additionalInfo = additionalInfo
        )

        logger.info("HIPAA_AUDIT: ${auditEntry.toJson()}")
    }

    fun logDataModification(
        userId: String,
        patientId: String,
        resource: String,
        action: AuditAction,
        oldValue: String? = null,
        newValue: String? = null,
        reason: String? = null
    ) {
        val additionalInfo = mutableMapOf<String, Any>()
        oldValue?.let { additionalInfo["oldValue"] = maskSensitiveData(it) }
        newValue?.let { additionalInfo["newValue"] = maskSensitiveData(it) }
        reason?.let { additionalInfo["reason"] = it }

        logAccess(userId, patientId, resource, action, true, additionalInfo = additionalInfo)
    }

    fun logSecurityEvent(
        eventType: SecurityEventType,
        userId: String? = null,
        patientId: String? = null,
        description: String,
        severity: SecuritySeverity = SecuritySeverity.MEDIUM,
        ipAddress: String? = null
    ) {
        val auditEntry = SecurityEvent(
            timestamp = java.time.LocalDateTime.now(),
            eventType = eventType,
            userId = userId,
            patientId = patientId,
            description = description,
            severity = severity,
            ipAddress = ipAddress
        )

        logger.warn("HIPAA_SECURITY: ${auditEntry.toJson()}")
    }

    private fun maskSensitiveData(data: String): String {
        // Mask sensitive information like PHI
        return if (data.length > 4) {
            "*".repeat(data.length - 4) + data.takeLast(4)
        } else {
            "*".repeat(data.length)
        }
    }

    private fun Any.toJson(): String {
        // Simple JSON serialization for audit logging
        return when (this) {
            is AuditEntry -> """
                {
                    "timestamp": "${timestamp}",
                    "userId": "$userId",
                    "patientId": "$patientId",
                    "resource": "$resource",
                    "action": "$action",
                    "success": $success,
                    "ipAddress": "$ipAddress",
                    "userAgent": "$userAgent",
                    "additionalInfo": ${additionalInfo.toJson()}
                }
            """.trimIndent()

            is SecurityEvent -> """
                {
                    "timestamp": "${timestamp}",
                    "eventType": "$eventType",
                    "userId": "$userId",
                    "patientId": "$patientId",
                    "description": "$description",
                    "severity": "$severity",
                    "ipAddress": "$ipAddress"
                }
            """.trimIndent()

            is Map<*, *> -> this.entries.joinToString(", ", "{", "}") { (k, v) ->
                "\"$k\": ${v.toJson()}"
            }

            is String -> "\"$this\""
            is Number -> this.toString()
            is Boolean -> this.toString()
            else -> "\"$this\""
        }
    }
}

enum class AuditAction {
    CREATE, READ, UPDATE, DELETE, EXPORT, IMPORT, PROCESS, ANALYZE
}

enum class SecurityEventType {
    UNAUTHORIZED_ACCESS,
    FAILED_LOGIN,
    SUSPICIOUS_ACTIVITY,
    DATA_BREACH_ATTEMPT,
    ENCRYPTION_FAILURE,
    AUDIT_LOG_TAMPERING
}

enum class SecuritySeverity {
    LOW, MEDIUM, HIGH, CRITICAL
}

data class AuditEntry(
    val timestamp: java.time.LocalDateTime,
    val userId: String,
    val patientId: String,
    val resource: String,
    val action: AuditAction,
    val success: Boolean,
    val ipAddress: String?,
    val userAgent: String?,
    val additionalInfo: Map<String, Any>
)

data class SecurityEvent(
    val timestamp: java.time.LocalDateTime,
    val eventType: SecurityEventType,
    val userId: String?,
    val patientId: String?,
    val description: String,
    val severity: SecuritySeverity,
    val ipAddress: String?
)