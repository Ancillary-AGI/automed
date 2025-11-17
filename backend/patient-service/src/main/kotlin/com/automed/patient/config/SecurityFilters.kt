package com.automed.patient.config

import jakarta.servlet.FilterChain
import jakarta.servlet.http.HttpServletRequest
import jakarta.servlet.http.HttpServletResponse
import org.springframework.security.core.context.SecurityContextHolder
import org.springframework.security.core.Authentication
import org.springframework.stereotype.Component
import org.springframework.web.filter.OncePerRequestFilter
import org.springframework.data.redis.core.RedisTemplate
import org.springframework.beans.factory.annotation.Autowired
import org.springframework.security.access.AccessDeniedException
import java.time.LocalDateTime
import java.time.format.DateTimeFormatter
import java.util.concurrent.TimeUnit

// Audit Logging Filter
@Component
class AuditLoggingFilter : OncePerRequestFilter() {

    @Autowired
    private lateinit var auditService: AuditService

    override fun doFilterInternal(
        request: HttpServletRequest,
        response: HttpServletResponse,
        filterChain: FilterChain
    ) {
        val startTime = System.currentTimeMillis()
        val authentication = SecurityContextHolder.getContext().authentication

        try {
            filterChain.doFilter(request, response)
        } finally {
            val duration = System.currentTimeMillis() - startTime

            // Log all healthcare data access for HIPAA compliance
            if (request.requestURI.contains("/api/v1/patients") ||
                request.requestURI.contains("/api/v1/medical-records")) {

                auditService.logAccess(
                    userId = authentication?.name ?: "anonymous",
                    action = request.method,
                    resource = request.requestURI,
                    ipAddress = getClientIpAddress(request),
                    userAgent = request.getHeader("User-Agent"),
                    success = response.status in 200..299,
                    responseTime = duration
                )
            }
        }
    }

    private fun getClientIpAddress(request: HttpServletRequest): String {
        val xForwardedFor = request.getHeader("X-Forwarded-For")
        if (!xForwardedFor.isNullOrEmpty()) {
            return xForwardedFor.split(",")[0].trim()
        }

        val xRealIp = request.getHeader("X-Real-IP")
        if (!xRealIp.isNullOrEmpty()) {
            return xRealIp
        }

        return request.remoteAddr ?: "unknown"
    }
}

// Rate Limiting Filter
@Component
class RateLimitingFilter : OncePerRequestFilter() {

    @Autowired
    private lateinit var redisTemplate: RedisTemplate<String, String>

    private val maxRequestsPerMinute = 100
    private val maxRequestsPerHour = 1000

    override fun doFilterInternal(
        request: HttpServletRequest,
        response: HttpServletResponse,
        filterChain: FilterChain
    ) {
        val clientId = getClientIdentifier(request)
        val minuteKey = "rate_limit:minute:$clientId"
        val hourKey = "rate_limit:hour:$clientId"

        val minuteCount = redisTemplate.opsForValue().increment(minuteKey) ?: 0
        val hourCount = redisTemplate.opsForValue().increment(hourKey) ?: 0

        // Set expiration for new keys
        if (minuteCount == 1L) {
            redisTemplate.expire(minuteKey, 60, TimeUnit.SECONDS)
        }
        if (hourCount == 1L) {
            redisTemplate.expire(hourKey, 3600, TimeUnit.SECONDS)
        }

        // Check rate limits
        if (minuteCount > maxRequestsPerMinute || hourCount > maxRequestsPerHour) {
            response.status = 429
            response.contentType = "application/json"
            response.writer.write("""
                {
                    "error": "Too Many Requests",
                    "message": "Rate limit exceeded. Please try again later.",
                    "retryAfter": 60
                }
            """.trimIndent())
            response.setHeader("Retry-After", "60")
            response.setHeader("X-Rate-Limit-Remaining", "0")
            return
        }

        // Add rate limit headers
        response.setHeader("X-Rate-Limit-Remaining",
            (maxRequestsPerMinute - minuteCount).toString())
        response.setHeader("X-Rate-Limit-Reset",
            (System.currentTimeMillis() / 1000 + 60).toString())

        filterChain.doFilter(request, response)
    }

    private fun getClientIdentifier(request: HttpServletRequest): String {
        // Use API key, JWT subject, or IP address for identification
        val authHeader = request.getHeader("Authorization")
        if (authHeader?.startsWith("Bearer ") == true) {
            // Extract subject from JWT (simplified)
            return "jwt:${authHeader.substringAfter("Bearer ")}"
        }

        val apiKey = request.getHeader("X-API-Key")
        if (!apiKey.isNullOrEmpty()) {
            return "api_key:$apiKey"
        }

        return "ip:${request.remoteAddr}"
    }
}

// Data Encryption Filter
@Component
class DataEncryptionFilter : OncePerRequestFilter() {

    @Autowired
    private lateinit var encryptionService: EncryptionService

    override fun doFilterInternal(
        request: HttpServletRequest,
        response: HttpServletResponse,
        filterChain: FilterChain
    ) {
        // Encrypt sensitive data in requests
        if (request.method in listOf("POST", "PUT", "PATCH") &&
            request.requestURI.contains("/api/v1/patients")) {

            // Wrap request to encrypt sensitive fields
            val encryptedRequest = EncryptedRequestWrapper(request, encryptionService)
            filterChain.doFilter(encryptedRequest, response)
        } else {
            filterChain.doFilter(request, response)
        }

        // Decrypt sensitive data in responses
        if (request.requestURI.contains("/api/v1/patients") ||
            request.requestURI.contains("/api/v1/medical-records")) {

            // Wrap response to decrypt sensitive fields
            val encryptedResponse = EncryptedResponseWrapper(response, encryptionService)
            // Note: In practice, this would need to be handled differently
        }
    }
}

// Custom JWT Authentication Converter
@Component
class CustomJwtAuthenticationConverter {

    fun convert(jwt: org.springframework.security.oauth2.jwt.Jwt):
            org.springframework.security.core.Authentication {

        val claims = jwt.claims
        val roles = (claims["roles"] as? List<String>)?.map { "ROLE_$it" } ?: emptyList()
        val permissions = claims["permissions"] as? List<String> ?: emptyList()

        val authorities = mutableListOf<org.springframework.security.core.GrantedAuthority>()

        // Add roles
        roles.forEach { role ->
            authorities.add(org.springframework.security.core.authority.SimpleGrantedAuthority(role))
        }

        // Add permissions
        permissions.forEach { permission ->
            authorities.add(org.springframework.security.core.authority.SimpleGrantedAuthority(permission))
        }

        return org.springframework.security.authentication.UsernamePasswordAuthenticationToken(
            jwt.subject,
            jwt.tokenValue,
            authorities
        )
    }
}

// Security Service for method-level security
@Component
class SecurityService {

    @Autowired
    private lateinit var patientRepository: PatientRepository

    fun canAccessPatientData(authentication: Authentication, patientId: String): Boolean {
        val userId = authentication.name
        val roles = authentication.authorities.map { it.authority }

        // Admin can access all data
        if (roles.contains("ROLE_ADMIN")) {
            return true
        }

        // Doctors and nurses can access patient data
        if (roles.contains("ROLE_DOCTOR") || roles.contains("ROLE_NURSE")) {
            return true
        }

        // Patients can only access their own data
        if (roles.contains("ROLE_PATIENT")) {
            return userId == patientId
        }

        return false
    }

    fun canAccessMedicalRecords(authentication: Authentication, patientId: String): Boolean {
        val roles = authentication.authorities.map { it.authority }

        // Only healthcare professionals can access medical records
        return roles.contains("ROLE_DOCTOR") ||
               roles.contains("ROLE_NURSE") ||
               roles.contains("ROLE_ADMIN")
    }
}

// Supporting services (interfaces for dependency injection)
interface AuditService {
    fun logAccess(
        userId: String,
        action: String,
        resource: String,
        ipAddress: String?,
        userAgent: String?,
        success: Boolean,
        responseTime: Long
    )
}

interface EncryptionService {
    fun encrypt(data: String): String
    fun decrypt(encryptedData: String): String
}

interface PatientRepository {
    fun findById(id: String): Any?
}

// Wrapper classes for request/response encryption
class EncryptedRequestWrapper(
    private val request: HttpServletRequest,
    private val encryptionService: EncryptionService
) : HttpServletRequest by request {

    override fun getParameter(name: String): String? {
        val value = request.getParameter(name)
        return if (isSensitiveField(name) && value != null) {
            encryptionService.decrypt(value)
        } else {
            value
        }
    }

    private fun isSensitiveField(fieldName: String): Boolean {
        return fieldName in listOf(
            "medicalHistory",
            "diagnosis",
            "treatment",
            "medications",
            "allergies",
            "socialSecurityNumber",
            "insuranceId"
        )
    }
}

class EncryptedResponseWrapper(
    private val response: HttpServletResponse,
    private val encryptionService: EncryptionService
) : HttpServletResponse by response {
    // Implementation would encrypt sensitive data in JSON responses
}