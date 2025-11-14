package com.automed.ai.service

import com.automed.ai.causal.CausalGraphicalModel
import com.automed.ai.dto.*
import org.junit.jupiter.api.BeforeEach
import org.junit.jupiter.api.Test
import org.junit.jupiter.api.extension.ExtendWith
import org.mockito.Mock
import org.mockito.junit.jupiter.MockitoExtension
import org.springframework.test.util.ReflectionTestUtils
import reactor.test.StepVerifier
import kotlin.test.assertEquals
import kotlin.test.assertNotNull
import kotlin.test.assertTrue

@ExtendWith(MockitoExtension::class)
class CausalAnalysisServiceTest {

    @Mock
    private lateinit var causalModel: CausalGraphicalModel

    private lateinit var causalAnalysisService: CausalAnalysisService

    @BeforeEach
    fun setUp() {
        causalAnalysisService = CausalAnalysisService()
    }

    @Test
    fun `should perform causal analysis successfully`() {
        // Given
        val request = CausalAnalysisRequest(
            patientId = "patient123",
            treatmentVariables = listOf("treatment_dosage"),
            outcomeVariables = listOf("outcome"),
            confoundingVariables = listOf("age", "comorbidities"),
            historicalData = listOf(
                CausalDataPoint(
                    timestamp = System.currentTimeMillis(),
                    variables = mapOf(
                        "treatment_dosage" to 50.0,
                        "outcome" to 0.8,
                        "age" to 45.0,
                        "comorbidities" to 1.0
                    )
                )
            )
        )

        // When
        val result = causalAnalysisService.performCausalAnalysis(request)

        // Then
        StepVerifier.create(result)
            .assertNext { response ->
                assertEquals("patient123", response.patientId)
                assertNotNull(response.causalEffects)
                assertNotNull(response.causalGraph)
                assertNotNull(response.recommendations)
                assertNotNull(response.riskAssessment)
                assertNotNull(response.analysisMetadata)
                assertTrue(response.causalEffects.isNotEmpty())
            }
            .verifyComplete()
    }

    @Test
    fun `should generate counterfactual scenarios successfully`() {
        // Given
        val request = CounterfactualRequest(
            patientId = "patient123",
            factualScenario = Scenario(
                variables = mapOf(
                    "treatment_dosage" to 50.0,
                    "lifestyle_changes" to 0.5
                )
            ),
            counterfactualScenarios = listOf(
                Scenario(
                    variables = mapOf(
                        "treatment_dosage" to 75.0,
                        "lifestyle_changes" to 0.8
                    )
                )
            )
        )

        // When
        val result = causalAnalysisService.generateCounterfactuals(request)

        // Then
        StepVerifier.create(result)
            .assertNext { response ->
                assertEquals("patient123", response.patientId)
                assertNotNull(response.factualOutcome)
                assertNotNull(response.counterfactualOutcomes)
                assertNotNull(response.causalContrast)
                assertNotNull(response.whatIfAnalysis)
                assertNotNull(response.recommendations)
                assertTrue(response.counterfactualOutcomes.isNotEmpty())
            }
            .verifyComplete()
    }

    @Test
    fun `should optimize treatment pathway successfully`() {
        // Given
        val request = TreatmentOptimizationRequest(
            patientId = "patient123",
            availableTreatments = listOf(
                Treatment(
                    id = "treatment_a",
                    name = "Treatment A",
                    type = TreatmentType.MEDICATION,
                    dosage = "50mg",
                    duration = 30,
                    cost = 100.0,
                    sideEffects = listOf("nausea"),
                    contraindications = listOf("allergy_a")
                )
            ),
            patientProfile = PatientProfile(
                demographics = Demographics(
                    age = 45,
                    gender = "female",
                    weight = 70.0,
                    height = 165.0
                ),
                medicalHistory = listOf("hypertension"),
                currentConditions = listOf("diabetes"),
                allergies = listOf("penicillin"),
                biomarkers = mapOf("glucose" to 150.0),
                geneticFactors = mapOf("diabetes_risk" to "high")
            ),
            constraints = TreatmentConstraints(
                maxCost = 500.0,
                maxDuration = 90
            ),
            optimizationCriteria = listOf(
                OptimizationCriterion.EFFICACY,
                OptimizationCriterion.SAFETY
            ),
            timeHorizon = 30
        )

        // When
        val result = causalAnalysisService.optimizeTreatmentPathway(request)

        // Then
        StepVerifier.create(result)
            .assertNext { response ->
                assertEquals("patient123", response.patientId)
                assertNotNull(response.optimalTreatmentPathway)
                assertNotNull(response.expectedOutcomes)
                assertNotNull(response.riskBenefitAnalysis)
                assertNotNull(response.optimizationMetadata)
                assertTrue(response.optimalTreatmentPathway.treatments.isNotEmpty())
            }
            .verifyComplete()
    }

    @Test
    fun `should create personalized causal model successfully`() {
        // Given
        val request = PersonalizedCausalModelRequest(
            patientId = "patient123",
            patientData = listOf(
                CausalDataPoint(
                    timestamp = System.currentTimeMillis(),
                    variables = mapOf(
                        "treatment_dosage" to 50.0,
                        "outcome" to 0.8,
                        "age" to 45.0,
                        "comorbidities" to 1.0
                    )
                ),
                CausalDataPoint(
                    timestamp = System.currentTimeMillis() + 1000,
                    variables = mapOf(
                        "treatment_dosage" to 60.0,
                        "outcome" to 0.85,
                        "age" to 45.0,
                        "comorbidities" to 1.0
                    )
                )
            ),
            modelType = CausalModelType.BAYESIAN_NETWORK,
            includeConfounders = true
        )

        // When
        val result = causalAnalysisService.createPersonalizedModel(request)

        // Then
        StepVerifier.create(result)
            .assertNext { response ->
                assertEquals("patient123", response.patientId)
                assertNotNull(response.causalModel)
                assertNotNull(response.modelPerformance)
                assertNotNull(response.personalizedInsights)
                assertNotNull(response.recommendations)
                assertNotNull(response.modelMetadata)
                assertTrue(response.personalizedInsights.isNotEmpty())
            }
            .verifyComplete()
    }

    @Test
    fun `should handle empty historical data gracefully`() {
        // Given
        val request = CausalAnalysisRequest(
            patientId = "patient123",
            treatmentVariables = listOf("treatment_dosage"),
            outcomeVariables = listOf("outcome"),
            confoundingVariables = listOf("age"),
            historicalData = emptyList()
        )

        // When
        val result = causalAnalysisService.performCausalAnalysis(request)

        // Then
        StepVerifier.create(result)
            .assertNext { response ->
                assertEquals("patient123", response.patientId)
                assertNotNull(response.analysisMetadata)
                // Should still work with default causal structure
            }
            .verifyComplete()
    }

    @Test
    fun `should validate causal analysis request parameters`() {
        // Given - invalid request with empty treatment variables
        val invalidRequest = CausalAnalysisRequest(
            patientId = "patient123",
            treatmentVariables = emptyList(), // Invalid
            outcomeVariables = listOf("outcome"),
            confoundingVariables = listOf("age")
        )

        // When & Then - should handle gracefully or throw appropriate exception
        // This test ensures the service handles invalid inputs appropriately
        val result = causalAnalysisService.performCausalAnalysis(invalidRequest)

        StepVerifier.create(result)
            .expectError() // Should fail validation
            .verify()
    }
}