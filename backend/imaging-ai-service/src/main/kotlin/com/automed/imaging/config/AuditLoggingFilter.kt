package com.automed.imaging.config

import org.springframework.security.core.context.SecurityContextHolder
import org.springframework.stereotype.Component
import org.springframework.web.filter.OncePerRequestFilter
import javax.servlet.FilterChain
import javax.servlet.http.HttpServletRequest
import javax.servlet.http.HttpServletResponse

@Component
class AuditLoggingFilter(
    private val auditLogger: HIPAAuditLogger
) : OncePerRequestFilter() {

    override fun doFilterInternal(
        request: HttpServletRequest,
        response: HttpServletResponse,
        filterChain: FilterChain
    ) {
        val startTime = System.currentTimeMillis()
        val userId = extractUserId()
        val ipAddress = extractIpAddress(request)
        val userAgent = request.getHeader("User-Agent")
        val method = request.method
        val uri = request.requestURI

        try {
            filterChain.doFilter(request, response)
        } finally {
            val duration = System.currentTimeMillis() - startTime
            val status = response.status

            // Log access for medical imaging resources
            if (uri.contains("/api/v1/imaging")) {
                val patientId = extractPatientIdFromRequest(request)
                val action = determineAction(method, uri)

                auditLogger.logAccess(
                    userId = userId ?: "anonymous",
                    patientId = patientId ?: "unknown",
                    resource = uri,
                    action = action,
                    success = status in 200..299,
                    ipAddress = ipAddress,
                    userAgent = userAgent,
                    additionalInfo = mapOf(
                        "method" to method,
                        "status" to status,
                        "duration" to duration,
                        "userAgent" to (userAgent ?: "")
                    )
                )

                // Log security events for suspicious activities
                if (status == 403) {
                    auditLogger.logSecurityEvent(
                        eventType = SecurityEventType.UNAUTHORIZED_ACCESS,
                        userId = userId,
                        patientId = patientId,
                        description = "Unauthorized access attempt to $uri",
                        severity = SecuritySeverity.HIGH,
                        ipAddress = ipAddress
                    )
                } else if (status == 401) {
                    auditLogger.logSecurityEvent(
                        eventType = SecurityEventType.FAILED_LOGIN,
                        userId = userId,
                        description = "Authentication failed for $uri",
                        severity = SecuritySeverity.MEDIUM,
                        ipAddress = ipAddress
                    )
                }
            }
        }
    }

    private fun extractUserId(): String? {
        val authentication = SecurityContextHolder.getContext().authentication
        return authentication?.name
    }

    private fun extractIpAddress(request: HttpServletRequest): String? {
        val xForwardedFor = request.getHeader("X-Forwarded-For")
        return if (!xForwardedFor.isNullOrBlank()) {
            xForwardedFor.split(",").first().trim()
        } else {
            request.remoteAddr
        }
    }

    private fun extractPatientIdFromRequest(request: HttpServletRequest): String? {
        // Extract patient ID from various sources
        return request.getParameter("patientId") ?:
               request.getParameter("patient_id") ?:
               extractFromPath(request.requestURI, "patients/([^/]+)") ?:
               extractFromPath(request.requestURI, "patient/([^/]+)")
    }

    private fun extractFromPath(uri: String, pattern: String): String? {
        val regex = Regex(pattern)
        return regex.find(uri)?.groupValues?.get(1)
    }

    private fun determineAction(method: String, uri: String): AuditAction {
        return when (method.uppercase()) {
            "GET" -> if (uri.contains("/download") || uri.contains("/retrieve")) AuditAction.READ else AuditAction.READ
            "POST" -> when {
                uri.contains("/upload") || uri.contains("/store") -> AuditAction.CREATE
                uri.contains("/process") || uri.contains("/ai") -> AuditAction.PROCESS
                uri.contains("/analyze") -> AuditAction.ANALYZE
                else -> AuditAction.CREATE
            }
            "PUT" -> AuditAction.UPDATE
            "DELETE" -> AuditAction.DELETE
            else -> AuditAction.READ
        }
    }
}