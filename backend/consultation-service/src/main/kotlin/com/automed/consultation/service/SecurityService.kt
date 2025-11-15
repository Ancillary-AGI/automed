package com.automed.consultation.service

import com.automed.consultation.domain.FileUpload
import com.automed.consultation.domain.Message
import org.slf4j.Logger
import org.slf4j.LoggerFactory
import org.springframework.stereotype.Service
import java.util.*

@Service
class SecurityService {

    private val logger: Logger = LoggerFactory.getLogger(SecurityService::class.java)

    companion object {
        private val SQL_INJECTION_PATTERNS = listOf(
            "(?i)(union|select|insert|update|delete|drop|create|alter)",
            "(?i)(script|javascript|vbscript|onload|onerror)",
            "(?i)(<script|<iframe|<object|<embed)",
            "(?i)(\\\\x[0-9a-f]{2}|%[0-9a-f]{2})", // Hex/URL encoding
        )

        private val XSS_PATTERNS = listOf(
            "(?i)<script[^>]*>.*?</script>",
            "(?i)<iframe[^>]*>.*?</iframe>",
            "(?i)<object[^>]*>.*?</object>",
            "(?i)<embed[^>]*>.*?</embed>",
            "(?i)javascript:",
            "(?i)vbscript:",
            "(?i)onload=",
            "(?i)onerror=",
        )
    }

    fun validateMessageContent(content: String): Boolean {
        if (content.isBlank()) return false
        if (content.length > Message.MAX_MESSAGE_LENGTH) return false

        // Check for malicious content
        return !containsMaliciousPatterns(content)
    }

    fun validateFileUpload(fileUpload: FileUpload): Boolean {
        return fileUpload.isValidFileSize() &&
               fileUpload.isAllowedFileType() &&
               fileUpload.isSafeFileName()
    }

    fun sanitizeFileName(fileName: String): String {
        // Remove path traversal attempts and dangerous characters
        return fileName
            .replace(Regex("[/\\\\:*?\"<>|]"), "_")
            .replace(Regex("\\.\\."), "_")
            .trim()
            .take(FileUpload.MAX_FILENAME_LENGTH)
    }

    fun validateUserAccess(userId: UUID, consultationId: UUID, requiredRole: String? = null): Boolean {
        // In a real implementation, this would check:
        // 1. If user is authenticated
        // 2. If user has access to the consultation
        // 3. If user has the required role (patient, doctor, admin)

        // For now, return true (this should be implemented with proper auth service)
        logger.warn("User access validation not fully implemented for user: $userId, consultation: $consultationId")
        return true
    }

    fun logSecurityEvent(event: String, userId: UUID?, details: Map<String, Any>) {
        logger.warn("Security Event: $event - User: $userId - Details: $details")
        // In production, this should be sent to a security monitoring system
    }

    fun validateFileAccess(fileId: UUID, userId: UUID): Boolean {
        // Check if user has access to download/view the file
        // This should verify consultation membership and file ownership
        logger.warn("File access validation not fully implemented for file: $fileId, user: $userId")
        return true
    }

    private fun containsMaliciousPatterns(content: String): Boolean {
        val allPatterns = SQL_INJECTION_PATTERNS + XSS_PATTERNS

        return allPatterns.any { pattern ->
            Regex(pattern).containsMatchIn(content)
        }
    }

    fun generateSecureFileUrl(fileId: UUID, consultationId: UUID): String {
        // Generate a secure, time-limited URL for file access
        // In production, this should use signed URLs with expiration
        return "/api/v1/consultations/$consultationId/files/$fileId/download"
    }

    fun validateRateLimit(userId: UUID, action: String): Boolean {
        // Implement rate limiting logic
        // This should track user actions and prevent abuse
        logger.debug("Rate limiting not implemented for user: $userId, action: $action")
        return true
    }
}