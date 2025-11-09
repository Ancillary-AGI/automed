package com.automed.ai.controller

import com.automed.ai.dto.HealthDataPoint
import com.automed.ai.dto.PredictiveHealthRequest
import com.automed.ai.service.AiService
import org.slf4j.LoggerFactory
import org.springframework.http.HttpStatus
import org.springframework.http.ResponseEntity
import org.springframework.security.access.prepost.PreAuthorize
import org.springframework.web.bind.annotation.*
import org.springframework.web.client.RestTemplate

@RestController
@RequestMapping("/api/v1/analytics")
@CrossOrigin(origins = ["*"])
class AnalyticsController(
    private val aiService: AiService
) {
    private val logger = LoggerFactory.getLogger(AnalyticsController::class.java)

    /**
     * GET /api/v1/analytics/predictive?patientId={id}&predictionDays={days}
     * - Fetches patient medical history from patient-service
     * - If there is insufficient historical data, returns 422 with a clear error
     * - Otherwise builds PredictiveHealthRequest and forwards to AiService.predictHealth
     */
    @GetMapping("/predictive")
    @PreAuthorize("hasRole('HEALTHCARE_PROVIDER') or hasRole('PATIENT')")
    fun getPredictive(
        @RequestParam patientId: String?,
        @RequestParam(required = false, defaultValue = "30") predictionDays: Int?
    ): ResponseEntity<Any> {
        if (patientId.isNullOrBlank()) {
            return ResponseEntity.status(HttpStatus.BAD_REQUEST).body(mapOf("error" to "patientId is required"))
        }

        val rest = RestTemplate()
        val url = "http://patient-service:8081/api/v1/patients/$patientId/medical-history"

        return try {
            val resp = rest.getForEntity(url, Map::class.java)
            val body = resp.body as? Map<*, *>

            val vitalSignsAny = body?.get("vitalSigns")
            val vitalSigns = when (vitalSignsAny) {
                is List<*> -> vitalSignsAny.filterIsInstance<Map<*, *>>()
                else -> emptyList()
            }

            if (vitalSigns.isEmpty()) {
                // Per frontend policy: do NOT fabricate data. Surface a clear error so UI can show empty-state.
                return ResponseEntity.status(HttpStatus.UNPROCESSABLE_ENTITY)
                    .body(mapOf("error" to "Insufficient historical vital signs for patient"))
            }

            val historicalData = vitalSigns.mapNotNull { vs ->
                try {
                    val tsAny = vs["timestamp"] ?: vs["time"] ?: vs["date"]
                    val timestamp = when (tsAny) {
                        is Number -> tsAny.toLong()
                        is String -> tsAny.toLongOrNull() ?: System.currentTimeMillis()
                        else -> System.currentTimeMillis()
                    }

                    val heartRate = (vs["heartRate"] as? Number)?.toDouble()
                    val systolic = (vs["bloodPressureSystolic"] as? Number)?.toDouble()
                        ?: (vs["systolic"] as? Number)?.toDouble()
                    val diastolic = (vs["bloodPressureDiastolic"] as? Number)?.toDouble()
                        ?: (vs["diastolic"] as? Number)?.toDouble()
                    val temperature = (vs["temperature"] as? Number)?.toDouble()
                    val oxygen = (vs["oxygenSaturation"] as? Number)?.toDouble()
                    val symptoms = (vs["symptoms"] as? List<*>)?.filterIsInstance<String>()
                    val mood = vs["mood"] as? String

                    HealthDataPoint(
                        timestamp = timestamp,
                        heartRate = heartRate,
                        bloodPressureSystolic = systolic,
                        bloodPressureDiastolic = diastolic,
                        temperature = temperature,
                        oxygenSaturation = oxygen,
                        symptoms = symptoms,
                        mood = mood
                    )
                } catch (e: Exception) {
                    logger.warn("Skipping invalid vital sign entry for patient $patientId", e)
                    null
                }
            }

            if (historicalData.isEmpty()) {
                return ResponseEntity.status(HttpStatus.UNPROCESSABLE_ENTITY)
                    .body(mapOf("error" to "No valid historical data points available for predictive analysis"))
            }

            val request = PredictiveHealthRequest(
                patientId = patientId,
                historicalData = historicalData,
                predictionDays = predictionDays ?: 30
            )

            val result = aiService.predictHealth(request).block()

            if (result == null) {
                ResponseEntity.status(HttpStatus.INTERNAL_SERVER_ERROR)
                    .body(mapOf("error" to "Predictive analysis failed"))
            } else {
                ResponseEntity.ok(result)
            }
        } catch (e: Exception) {
            logger.error("Error while computing predictive analytics for patient $patientId", e)
            ResponseEntity.status(HttpStatus.INTERNAL_SERVER_ERROR)
                .body(mapOf("error" to "Failed to compute predictive analytics: ${e.message}"))
        }
    }
}
