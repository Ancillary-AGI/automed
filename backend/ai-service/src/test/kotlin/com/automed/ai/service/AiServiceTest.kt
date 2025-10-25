package com.automed.ai.service

import com.automed.ai.dto.*
import org.junit.jupiter.api.BeforeEach
import org.junit.jupiter.api.Test
import org.junit.jupiter.api.extension.ExtendWith
import org.mockito.InjectMocks
import org.mockito.junit.jupiter.MockitoExtension
import reactor.test.StepVerifier
import java.time.LocalDateTime

@ExtendWith(MockitoExtension::class)
class AiServiceTest {

    @InjectMocks
    private lateinit var aiService: AiService

    private lateinit var predictiveHealthRequest: PredictiveHealthRequest
    private lateinit var historicalData: List<HealthDataPoint>

    @BeforeEach
    fun setUp() {
        historicalData = listOf(
            HealthDataPoint(
                timestamp = System.currentTimeMillis() - 86400000, // 1 day ago
                heartRate = 75.0,
                bloodPressureSystolic = 120.0,
                bloodPressureDiastolic = 80.0,
                temperature = 98.6,
                oxygenSaturation = 98.0,
                symptoms = listOf("fatigue"),
                mood = "good"
            ),
            HealthDataPoint(
                timestamp = System.currentTimeMillis() - 172800000, // 2 days ago
                heartRate = 78.0,
                bloodPressureSystolic = 125.0,
                bloodPressureDiastolic = 82.0,
                temperature = 99.1,
                oxygenSaturation = 97.0,
                symptoms = listOf("headache", "fatigue"),
                mood = "fair"
            ),
            HealthDataPoint(
                timestamp = System.currentTimeMillis() - 259200000, // 3 days ago
                heartRate = 80.0,
                bloodPressureSystolic = 130.0,
                bloodPressureDiastolic = 85.0,
                temperature = 100.2,
                oxygenSaturation = 96.0,
                symptoms = listOf("fever", "headache"),
                mood = "poor"
            )
        )

        predictiveHealthRequest = PredictiveHealthRequest(
            patientId = "patient-123",
            historicalData = historicalData,
            predictionDays = 7,
            riskFactors = listOf("diabetes", "hypertension"),
            currentMedications = listOf("metformin", "lisinopril")
        )
    }

    @Test
    fun `predictHealth should return valid prediction response`() {
        // When
        val result = aiService.predictHealth(predictiveHealthRequest)

        // Then
        StepVerifier.create(result)
            .expectNextMatches { response ->
                response.patientId == "patient-123" &&
                response.riskScore >= 0.0 && response.riskScore <= 100.0 &&
                response.confidence >= 0.0 && response.confidence <= 1.0 &&
                response.predictions.isNotEmpty() &&
                response.recommendations.isNotEmpty() &&
                response.alerts.isNotEmpty()
            }
            .verifyComplete()
    }

    @Test
    fun `predictHealth should handle empty historical data gracefully`() {
        // Given
        val emptyRequest = predictiveHealthRequest.copy(historicalData = emptyList())

        // When
        val result = aiService.predictHealth(emptyRequest)

        // Then
        StepVerifier.create(result)
            .expectNextMatches { response ->
                response.patientId == "patient-123" &&
                response.riskScore == 0.0 &&
                response.riskLevel == RiskLevel.LOW &&
                response.predictions.isEmpty() &&
                response.recommendations.isNotEmpty()
            }
            .verifyComplete()
    }

    @Test
    fun `predictHealth should detect high risk scenarios`() {
        // Given - Create high-risk data
        val highRiskData = listOf(
            HealthDataPoint(
                timestamp = System.currentTimeMillis(),
                heartRate = 150.0, // Very high
                bloodPressureSystolic = 200.0, // Very high
                bloodPressureDiastolic = 130.0, // Very high
                temperature = 104.0, // Very high
                oxygenSaturation = 85.0, // Very low
                symptoms = listOf("chest pain", "shortness of breath"),
                mood = "critical"
            )
        )
        val highRiskRequest = predictiveHealthRequest.copy(historicalData = highRiskData)

        // When
        val result = aiService.predictHealth(highRiskRequest)

        // Then
        StepVerifier.create(result)
            .expectNextMatches { response ->
                response.riskLevel == RiskLevel.CRITICAL &&
                response.alerts.any { it.type == AlertType.DETERIORATION_RISK } &&
                response.recommendations.any { it.contains("immediate") }
            }
            .verifyComplete()
    }

    @Test
    fun `predictDiagnosis should return valid diagnosis response`() {
        // Given
        val diagnosisRequest = DiagnosisPredictionRequest(
            patientId = "patient-123",
            symptoms = listOf("fever", "cough", "fatigue"),
            vitals = mapOf(
                "heartRate" to 85.0,
                "bloodPressureSystolic" to 120.0,
                "bloodPressureDiastolic" to 80.0,
                "temperature" to 101.5,
                "oxygenSaturation" to 97.0
            ),
            medicalHistory = "No significant history",
            age = 35,
            gender = "male"
        )

        // When
        val result = aiService.predictDiagnosis(diagnosisRequest)

        // Then
        StepVerifier.create(result)
            .expectNextMatches { response ->
                response.predictions.isNotEmpty() &&
                response.confidence >= 0.0 && response.confidence <= 1.0 &&
                response.recommendations.isNotEmpty()
            }
            .verifyComplete()
    }

    @Test
    fun `analyzeVitals should detect abnormal values`() {
        // Given
        val vitalsRequest = VitalsAnalysisRequest(
            vitals = mapOf(
                "heartRate" to 150.0, // Abnormal
                "bloodPressureSystolic" to 200.0, // Abnormal
                "bloodPressureDiastolic" to 130.0, // Abnormal
                "temperature" to 104.0, // Abnormal
                "oxygenSaturation" to 85.0 // Abnormal
            ),
            patientId = "patient-123",
            age = 45,
            gender = "female",
            medicalHistory = listOf("hypertension", "diabetes")
        )

        // When
        val result = aiService.analyzeVitals(vitalsRequest)

        // Then
        StepVerifier.create(result)
            .expectNextMatches { response ->
                response.abnormalValues.size >= 3 && // Should detect multiple abnormalities
                response.overallAssessment == "Abnormal" &&
                response.recommendations.isNotEmpty()
            }
            .verifyComplete()
    }

    @Test
    fun `getAvailableModels should return list of models`() {
        // When
        val models = aiService.getAvailableModels()

        // Then
        assert(models.isNotEmpty())
        assert(models.any { it.type == "Classification" })
        assert(models.all { it.id.isNotBlank() && it.name.isNotBlank() })
    }
}
