package com.automed.multimodalai.service

import ai.djl.ndarray.NDManager
import com.automed.multimodalai.dto.*
import org.junit.jupiter.api.BeforeEach
import org.junit.jupiter.api.Test
import org.junit.jupiter.api.extension.ExtendWith
import org.mockito.Mock
import org.mockito.junit.jupiter.MockitoExtension
import org.mockito.kotlin.whenever
import reactor.test.StepVerifier
import java.time.LocalDateTime

@ExtendWith(MockitoExtension::class)
class MultimodalFusionServiceTest {

    @Mock
    private lateinit var ndManager: NDManager

    @Mock
    private lateinit var uncertaintyQuantificationService: UncertaintyQuantificationService

    @Mock
    private lateinit var patientDataIntegrationService: PatientDataIntegrationService

    private lateinit var multimodalFusionService: MultimodalFusionService

    @BeforeEach
    fun setUp() {
        multimodalFusionService = MultimodalFusionService(
            ndManager,
            uncertaintyQuantificationService,
            patientDataIntegrationService
        )
    }

    @Test
    fun `should fuse multimodal data successfully`() {
        // Given
        val patientId = "patient-123"
        val request = MultimodalFusionRequest(
            patientId = patientId,
            textData = TextData(
                content = "Patient reports chest pain and shortness of breath",
                type = TextType.SYMPTOM_DESCRIPTION
            ),
            imageData = ImageData(
                imageUrl = "http://example.com/xray.jpg",
                modality = ImageModality.XRAY
            ),
            vitalsData = VitalsData(
                measurements = listOf(
                    VitalMeasurement(
                        type = "heart_rate",
                        value = 95.0,
                        unit = "bpm",
                        timestamp = LocalDateTime.now()
                    )
                )
            ),
            fusionStrategy = FusionStrategy.LATE_FUSION,
            includeUncertainty = true
        )

        val mockIntegrationResponse = PatientDataIntegrationResponse(
            patientId = patientId,
            integratedData = mapOf("text" to listOf(request.textData)),
            dataQuality = DataQualityMetrics(0.9, 0.85, 0.95, 0.88),
            lastUpdated = LocalDateTime.now()
        )

        whenever(patientDataIntegrationService.integratePatientData(any()))
            .thenReturn(Mono.just(mockIntegrationResponse))

        // When
        val result = multimodalFusionService.fuseMultimodalData(request)

        // Then
        StepVerifier.create(result)
            .expectNextMatches { response ->
                response.patientId == patientId &&
                response.diagnosis.primaryDiagnosis.isNotBlank() &&
                response.treatmentPlan.recommendations.isNotEmpty() &&
                response.confidence.overall > 0.0
            }
            .verifyComplete()
    }

    @Test
    fun `should handle empty multimodal data gracefully`() {
        // Given
        val patientId = "patient-456"
        val request = MultimodalFusionRequest(
            patientId = patientId,
            fusionStrategy = FusionStrategy.EARLY_FUSION,
            includeUncertainty = false
        )

        val mockIntegrationResponse = PatientDataIntegrationResponse(
            patientId = patientId,
            integratedData = emptyMap(),
            dataQuality = DataQualityMetrics(0.0, 0.0, 0.0, 0.0),
            lastUpdated = LocalDateTime.now()
        )

        whenever(patientDataIntegrationService.integratePatientData(any()))
            .thenReturn(Mono.just(mockIntegrationResponse))

        // When
        val result = multimodalFusionService.fuseMultimodalData(request)

        // Then
        StepVerifier.create(result)
            .expectNextMatches { response ->
                response.patientId == patientId &&
                response.diagnosis.primaryDiagnosis.isNotBlank()
            }
            .verifyComplete()
    }

    private fun <T> any(): T = org.mockito.kotlin.any()
}