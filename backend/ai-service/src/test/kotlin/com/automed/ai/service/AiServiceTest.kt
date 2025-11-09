package com.automed.ai.service

import com.automed.ai.dto.*
import org.junit.jupiter.api.Assertions.*
import org.junit.jupiter.api.BeforeEach
import org.junit.jupiter.api.Test
import org.junit.jupiter.api.extension.ExtendWith
import org.mockito.InjectMocks
import org.mockito.Mock
import org.mockito.Mockito.*
import org.mockito.junit.jupiter.MockitoExtension
import org.springframework.kafka.core.KafkaTemplate
import reactor.core.publisher.Mono
import reactor.test.StepVerifier
import java.time.LocalDateTime

@ExtendWith(MockitoExtension::class)
class AiServiceTest {

    @Mock
    private lateinit var kafkaTemplate: KafkaTemplate<String, Any>

    @InjectMocks
    private lateinit var aiService: AiService

    private lateinit var vitalsRequest: VitalsAnalysisRequest
    private lateinit var diagnosisRequest: DiagnosisPredictionRequest
    private lateinit var triageRequest: TriageRequest

    @BeforeEach
    fun setUp() {
        vitalsRequest = VitalsAnalysisRequest(
            patientId = "patient123",
            vitals = mapOf(
                "heartRate" to 85.0,
                "bloodPressureSystolic" to 135.0,
                "bloodPressureDiastolic" to 85.0,
                "temperature" to 37.2,
                "oxygenSaturation" to 97.0,
                "respiratoryRate" to 16.0
            )
        )

        diagnosisRequest = DiagnosisPredictionRequest(
            patientId = "patient123",
            symptoms = listOf("fever", "cough", "fatigue"),
            patientHistory = PatientHistory(
                age = 35,
                gender = "male",
                previousConditions = listOf("asthma"),
                medications = listOf("albuterol")
            )
        )

        triageRequest = TriageRequest(
            patientId = "patient123",
            symptoms = listOf("chest pain", "shortness of breath"),
            severity = "high",
            vitalSigns = mapOf("heartRate" to 110.0, "bloodPressure" to 160.0)
        )
    }

    @Test
    fun `analyzeVitals should return normal assessment for normal vitals`() {
        // Given
        val normalVitalsRequest = VitalsAnalysisRequest(
            patientId = "patient123",
            vitals = mapOf(
                "heartRate" to 72.0,
                "bloodPressureSystolic" to 120.0,
                "bloodPressureDiastolic" to 80.0,
                "temperature" to 36.8,
                "oxygenSaturation" to 98.0,
                "respiratoryRate" to 14.0
            )
        )

        // When
        val result = aiService.analyzeVitals(normalVitalsRequest)

        // Then
        StepVerifier.create(result)
            .expectNextMatches { response ->
                response.overallAssessment == "Normal" &&
                response.abnormalValues.isEmpty() &&
                response.recommendations.contains("Continue regular health monitoring")
            }
            .verifyComplete()
    }

    @Test
    fun `analyzeVitals should detect abnormal heart rate`() {
        // Given
        val abnormalVitalsRequest = VitalsAnalysisRequest(
            patientId = "patient123",
            vitals = mapOf("heartRate" to 120.0)
        )

        // When
        val result = aiService.analyzeVitals(abnormalVitalsRequest)

        // Then
        StepVerifier.create(result)
            .expectNextMatches { response ->
                response.abnormalValues.any { it.parameter == "heartRate" } &&
                response.overallAssessment == "Abnormal" &&
                response.recommendations.any { it.contains("rest", ignoreCase = true) }
            }
            .verifyComplete()
    }

    @Test
    fun `analyzeVitals should detect critical blood pressure`() {
        // Given
        val criticalVitalsRequest = VitalsAnalysisRequest(
            patientId = "patient123",
            vitals = mapOf(
                "bloodPressureSystolic" to 190.0,
                "bloodPressureDiastolic" to 120.0
            )
        )

        // When
        val result = aiService.analyzeVitals(criticalVitalsRequest)

        // Then
        StepVerifier.create(result)
            .expectNextMatches { response ->
                response.overallAssessment == "Critical" &&
                response.abnormalValues.size == 2 &&
                response.recommendations.any { it.contains("emergency", ignoreCase = true) }
            }
            .verifyComplete()
    }

    @Test
    fun `analyzeVitals should identify risk factors based on abnormal values`() {
        // Given
        val riskVitalsRequest = VitalsAnalysisRequest(
            patientId = "patient123",
            vitals = mapOf(
                "bloodPressureSystolic" to 160.0,
                "oxygenSaturation" to 92.0
            )
        )

        // When
        val result = aiService.analyzeVitals(riskVitalsRequest)

        // Then
        StepVerifier.create(result)
            .expectNextMatches { response ->
                response.riskFactors.contains("Hypertension risk") &&
                response.riskFactors.contains("Respiratory conditions") &&
                response.abnormalValues.size == 2
            }
            .verifyComplete()
    }

    @Test
    fun `predictDiagnosis should return diagnosis predictions with confidence scores`() {
        // When
        val result = aiService.predictDiagnosis(diagnosisRequest)

        // Then
        StepVerifier.create(result)
            .expectNextMatches { response ->
                response.predictions.isNotEmpty() &&
                response.confidence > 0.0 &&
                response.predictions.all { it.probability > 0.0 } &&
                response.recommendations.isNotEmpty()
            }
            .verifyComplete()
    }

    @Test
    fun `performTriage should return triage assessment with priority and wait time`() {
        // When
        val result = aiService.performTriage(triageRequest)

        // Then
        StepVerifier.create(result)
            .expectNextMatches { response ->
                response.priority.isNotEmpty() &&
                response.estimatedWaitTime >= 0 &&
                response.urgencyScore >= 0.0 &&
                response.urgencyScore <= 1.0
            }
            .verifyComplete()
    }

    @Test
    fun `analyzeSymptoms should return symptom analysis with possible causes`() {
        // Given
        val symptomRequest = SymptomAnalysisRequest(
            patientId = "patient123",
            symptoms = listOf("headache", "nausea", "dizziness"),
            patientHistory = PatientHistory(
                age = 45,
                gender = "female",
                previousConditions = listOf("migraine"),
                medications = listOf("sumatriptan")
            )
        )

        // When
        val result = aiService.analyzeSymptoms(symptomRequest)

        // Then
        StepVerifier.create(result)
            .expectNextMatches { response ->
                response.relatedSymptoms.isNotEmpty() &&
                response.possibleCauses.isNotEmpty() &&
                response.urgencyLevel.isNotEmpty() &&
                response.recommendations.isNotEmpty()
            }
            .verifyComplete()
    }

    @Test
    fun `checkDrugInteractions should return interaction analysis`() {
        // Given
        val interactionRequest = DrugInteractionRequest(
            patientId = "patient123",
            medications = listOf(
                MedicationInfo(name = "warfarin", dosage = "5mg", frequency = "daily"),
                MedicationInfo(name = "aspirin", dosage = "81mg", frequency = "daily")
            )
        )

        // When
        val result = aiService.checkDrugInteractions(interactionRequest)

        // Then
        StepVerifier.create(result)
            .expectNextMatches { response ->
                response.interactions.isNotEmpty() &&
                response.overallRisk.isNotEmpty() &&
                response.warnings.isNotEmpty()
            }
            .verifyComplete()
    }

    @Test
    fun `getAvailableModels should return list of AI models with metadata`() {
        // When
        val models = aiService.getAvailableModels()

        // Then
        assertTrue(models.isNotEmpty())
        models.forEach { model ->
            assertNotNull(model.id)
            assertNotNull(model.name)
            assertNotNull(model.version)
            assertNotNull(model.type)
            assertTrue(model.size > 0)
            assertNotNull(model.lastUpdated)
        }
    }

    @Test
    fun `getModelDownloadInfo should return download information for valid model`() {
        // When
        val result = aiService.getModelDownloadInfo("diagnosis-v1")

        // Then
        StepVerifier.create(result)
            .expectNextMatches { response ->
                response.downloadUrl.isNotEmpty() &&
                response.checksum.isNotEmpty() &&
                response.size > 0 &&
                response.expiresAt.isNotEmpty()
            }
            .verifyComplete()
    }

    @Test
    fun `submitFeedback should return success response`() {
        // Given
        val feedbackRequest = AiFeedbackRequest(
            modelId = "diagnosis-v1",
            predictionId = "pred123",
            rating = 4,
            comments = "Good prediction but could be more specific",
            userId = "user123"
        )

        // When
        val result = aiService.submitFeedback(feedbackRequest)

        // Then
        assertTrue(result.success)
        assertNotNull(result.feedbackId)
        assertEquals("Feedback submitted successfully", result.message)
    }

    @Test
    fun `predictHealth should return comprehensive health prediction with alerts`() {
        // Given
        val healthRequest = PredictiveHealthRequest(
            patientId = "patient123",
            historicalData = listOf(
                HealthDataPoint(
                    timestamp = LocalDateTime.now().minusDays(1),
                    heartRate = 75.0,
                    bloodPressureSystolic = 125.0,
                    bloodPressureDiastolic = 82.0,
                    temperature = 36.9,
                    oxygenSaturation = 97.0
                ),
                HealthDataPoint(
                    timestamp = LocalDateTime.now().minusDays(2),
                    heartRate = 78.0,
                    bloodPressureSystolic = 128.0,
                    bloodPressureDiastolic = 85.0,
                    temperature = 37.1,
                    oxygenSaturation = 96.0
                )
            )
        )

        // When
        val result = aiService.predictHealth(healthRequest)

        // Then
        StepVerifier.create(result)
            .expectNextMatches { response ->
                response.patientId == "patient123" &&
                response.riskScore >= 0.0 &&
                response.riskLevel.isNotEmpty() &&
                response.predictions.isNotEmpty() &&
                response.recommendations.isNotEmpty() &&
                response.confidence >= 0.0 &&
                response.confidence <= 1.0
            }
            .verifyComplete()
    }
}
