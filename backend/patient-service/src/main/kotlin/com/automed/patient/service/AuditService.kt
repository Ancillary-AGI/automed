package com.automed.patient.service

import org.springframework.stereotype.Service
import org.springframework.data.mongodb.core.MongoTemplate
import org.springframework.data.redis.core.RedisTemplate
import org.springframework.beans.factory.annotation.Autowired
import java.time.LocalDateTime

@Service
class AuditService {

    @Autowired
    private lateinit var mongoTemplate: MongoTemplate

    @Autowired
    private lateinit var redisTemplate: RedisTemplate<String, String>

    fun logAccess(
        userId: String,
        action: String,
        resource: String,
        ipAddress: String?,
        userAgent: String?,
        success: Boolean,
        responseTime: Long
    ) {
        val auditEntry = AuditEntry(
            id = null,
            timestamp = LocalDateTime.now(),
            userId = userId,
            action = action,
            resource = resource,
            ipAddress = ipAddress,
            userAgent = userAgent,
            success = success,
            responseTime = responseTime,
            sessionId = getCurrentSessionId(),
            additionalData = mapOf(
                "compliance" to "HIPAA",
                "dataClassification" to getDataClassification(resource)
            )
        )

        // Store in MongoDB for long-term retention
        mongoTemplate.save(auditEntry, "audit_log")

        // Store recent entries in Redis for quick access
        val redisKey = "audit:recent:$userId"
        redisTemplate.opsForList().leftPush(redisKey, auditEntry.toJson())
        redisTemplate.opsForList().trim(redisKey, 0, 99) // Keep last 100 entries
        redisTemplate.expire(redisKey, 7, java.util.concurrent.TimeUnit.DAYS)
    }

    fun getAuditTrail(
        userId: String? = null,
        action: String? = null,
        resource: String? = null,
        startDate: LocalDateTime? = null,
        endDate: LocalDateTime? = null,
        limit: Int = 100
    ): List<AuditEntry> {
        val query = org.springframework.data.mongodb.core.query.Query()

        userId?.let { query.addCriteria(org.springframework.data.mongodb.core.query.Criteria.where("userId").`is`(it)) }
        action?.let { query.addCriteria(org.springframework.data.mongodb.core.query.Criteria.where("action").`is`(it)) }
        resource?.let { query.addCriteria(org.springframework.data.mongodb.core.query.Criteria.where("resource").regex(it)) }

        if (startDate != null || endDate != null) {
            val criteria = org.springframework.data.mongodb.core.query.Criteria.where("timestamp")
            if (startDate != null && endDate != null) {
                criteria.gte(startDate).lte(endDate)
            } else if (startDate != null) {
                criteria.gte(startDate)
            } else if (endDate != null) {
                criteria.lte(endDate)
            }
            query.addCriteria(criteria)
        }

        query.limit(limit)
        query.with(org.springframework.data.mongodb.core.query.Sort.by(
            org.springframework.data.mongodb.core.query.Sort.Direction.DESC,
            "timestamp"
        ))

        return mongoTemplate.find(query, AuditEntry::class.java, "audit_log")
    }

    fun generateComplianceReport(
        startDate: LocalDateTime,
        endDate: LocalDateTime
    ): ComplianceReport {
        val entries = getAuditTrail(startDate = startDate, endDate = endDate, limit = 10000)

        return ComplianceReport(
            periodStart = startDate,
            periodEnd = endDate,
            totalEntries = entries.size,
            successfulAccesses = entries.count { it.success },
            failedAccesses = entries.count { !it.success },
            uniqueUsers = entries.map { it.userId }.distinct().size,
            dataAccessEvents = entries.count { it.action in listOf("GET", "POST", "PUT", "DELETE") },
            sensitiveDataAccess = entries.count { isSensitiveResource(it.resource) },
            complianceViolations = entries.count { !it.success && isSensitiveResource(it.resource) }
        )
    }

    private fun getCurrentSessionId(): String {
        // In a real implementation, this would get the current session ID
        return "session_${System.currentTimeMillis()}"
    }

    private fun getDataClassification(resource: String): String {
        return when {
            resource.contains("medical-records") -> "PHI"
            resource.contains("patients") -> "PII"
            resource.contains("diagnostics") -> "PHI"
            else -> "PUBLIC"
        }
    }

    private fun isSensitiveResource(resource: String): Boolean {
        return resource.contains("medical-records") ||
               resource.contains("diagnostics") ||
               resource.contains("personal")
    }
}

data class AuditEntry(
    val id: String?,
    val timestamp: LocalDateTime,
    val userId: String,
    val action: String,
    val resource: String,
    val ipAddress: String?,
    val userAgent: String?,
    val success: Boolean,
    val responseTime: Long,
    val sessionId: String,
    val additionalData: Map<String, Any>
) {
    fun toJson(): String {
        return """
            {
                "id": "$id",
                "timestamp": "$timestamp",
                "userId": "$userId",
                "action": "$action",
                "resource": "$resource",
                "ipAddress": "$ipAddress",
                "userAgent": "$userAgent",
                "success": $success,
                "responseTime": $responseTime,
                "sessionId": "$sessionId",
                "additionalData": ${additionalData}
            }
        """.trimIndent()
    }
}

data class ComplianceReport(
    val periodStart: LocalDateTime,
    val periodEnd: LocalDateTime,
    val totalEntries: Int,
    val successfulAccesses: Int,
    val failedAccesses: Int,
    val uniqueUsers: Int,
    val dataAccessEvents: Int,
    val sensitiveDataAccess: Int,
    val complianceViolations: Int
)