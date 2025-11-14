package com.automed.multimodalai.controller

import com.automed.multimodalai.dto.*
import com.automed.multimodalai.service.*
import jakarta.validation.Valid
import org.slf4j.LoggerFactory
import org.springframework.http.MediaType
import org.springframework.http.ResponseEntity
import org.springframework.messaging.handler.annotation.DestinationVariable
import org.springframework.messaging.handler.annotation.MessageMapping
import org.springframework.messaging.handler.annotation.SendTo
import org.springframework.security.access.prepost.PreAuthorize
import org.springframework.web.bind.annotation.*
import reactor.core.publisher.Flux
import reactor.core.publisher.Mono

@RestController
@RequestMapping("/api/v1/multimodal-ai")
@CrossOrigin(origins = ["*"])
class MultimodalAiController(
    private val multimodalFusionService: MultimodalFusionService,
    private val syntheticDataService: SyntheticDataService,
    private val realTimeProcessingService: RealTimeProcessingService,
    private val patientDataIntegrationService: PatientDataIntegrationService,
    private val uncertaintyQuantificationService: UncertaintyQuantificationService
) {

    private val logger = LoggerFactory.getLogger(MultimodalAiController::class.java)

    // Multimodal Fusion Endpoints
    @PostMapping("/fuse")
    @PreAuthorize("hasRole('HEALTHCARE_PROVIDER') or hasRole('AI_SYSTEM')")
    fun fuseMultimodalData(@Valid @RequestBody request: MultimodalFusionRequest): Mono<ResponseEntity<MultimodalFusionResponse>> {
        logger.info("Received multimodal fusion request for patient: ${request.patientId}")
        return multimodalFusionService.fuseMultimodalData(request)
            .map { ResponseEntity.ok(it) }
            .doOnError { e -> logger.error("Error in multimodal fusion: ${e.message}", e) }
    }

    @PostMapping("/cross-modal-reasoning")
    @PreAuthorize("hasRole('HEALTHCARE_PROVIDER') or hasRole('AI_SYSTEM')")
    fun performCrossModalReasoning(@Valid @RequestBody request: CrossModalReasoningRequest): Mono<ResponseEntity<CrossModalReasoningResponse>> {
        logger.info("Received cross-modal reasoning request: ${request.query}")
        return Mono.fromCallable {
            // Simplified cross-modal reasoning - in production, use advanced NLP and multimodal models
            val reasoning = generateReasoning(request)
            val evidence = collectEvidence(request)
            val confidence = calculateReasoningConfidence(request, evidence)

            CrossModalReasoningResponse(
                reasoning = reasoning,
                evidence = evidence,
                confidence = confidence,
                alternativeHypotheses = generateAlternativeHypotheses(request)
            )
        }.map { ResponseEntity.ok(it) }
    }

    // Synthetic Data Generation Endpoints
    @PostMapping("/synthetic-data")
    @PreAuthorize("hasRole('RESEARCHER') or hasRole('ADMIN') or hasRole('AI_SYSTEM')")
    fun generateSyntheticData(@Valid @RequestBody request: SyntheticDataRequest): Mono<ResponseEntity<SyntheticDataResponse>> {
        logger.info("Received synthetic data generation request for modality: ${request.modality}, count: ${request.count}")
        return syntheticDataService.generateSyntheticData(request)
            .map { ResponseEntity.ok(it) }
            .doOnError { e -> logger.error("Error generating synthetic data: ${e.message}", e) }
    }

    // Real-time Processing Endpoints
    @PostMapping("/realtime/process")
    @PreAuthorize("hasRole('HEALTHCARE_PROVIDER') or hasRole('AI_SYSTEM')")
    fun processRealTimeData(@Valid @RequestBody request: RealTimeProcessingRequest): Mono<ResponseEntity<RealTimeProcessingResponse>> {
        logger.info("Received real-time processing request for session: ${request.sessionId}")
        return realTimeProcessingService.startRealTimeProcessing(request)
            .map { ResponseEntity.ok(it) }
            .doOnError { e -> logger.error("Error in real-time processing: ${e.message}", e) }
    }

    @DeleteMapping("/realtime/session/{sessionId}")
    @PreAuthorize("hasRole('HEALTHCARE_PROVIDER') or hasRole('AI_SYSTEM')")
    fun stopRealTimeSession(@PathVariable sessionId: String): Mono<ResponseEntity<Void>> {
        logger.info("Stopping real-time session: $sessionId")
        return realTimeProcessingService.stopRealTimeProcessing(sessionId)
            .then(Mono.just(ResponseEntity.ok().build()))
    }

    // Patient Data Integration Endpoints
    @PostMapping("/patient/{patientId}/integrate")
    @PreAuthorize("hasRole('HEALTHCARE_PROVIDER') or hasRole('AI_SYSTEM')")
    fun integratePatientData(@PathVariable patientId: String, @Valid @RequestBody request: PatientDataIntegrationRequest): Mono<ResponseEntity<PatientDataIntegrationResponse>> {
        val integrationRequest = request.copy(patientId = patientId)
        logger.info("Received patient data integration request for patient: $patientId")
        return patientDataIntegrationService.integratePatientData(integrationRequest)
            .map { ResponseEntity.ok(it) }
            .doOnError { e -> logger.error("Error integrating patient data: ${e.message}", e) }
    }

    // Uncertainty Quantification Endpoints
    @PostMapping("/uncertainty/quantify")
    @PreAuthorize("hasRole('HEALTHCARE_PROVIDER') or hasRole('RESEARCHER') or hasRole('AI_SYSTEM')")
    fun quantifyUncertainty(@Valid @RequestBody request: MultimodalFusionRequest): Mono<ResponseEntity<ConfidenceScore>> {
        logger.info("Received uncertainty quantification request for patient: ${request.patientId}")
        return multimodalFusionService.fuseMultimodalData(request)
            .map { fusionResult ->
                val confidence = uncertaintyQuantificationService.quantifyUncertainty(
                    ai.djl.ndarray.NDManager.newBaseManager().create(floatArrayOf(1.0f)), // Placeholder
                    fusionResult.diagnosis
                )
                ResponseEntity.ok(confidence)
            }
            .doOnError { e -> logger.error("Error quantifying uncertainty: ${e.message}", e) }
    }

    // Model Management Endpoints
    @GetMapping("/models")
    @PreAuthorize("hasRole('ADMIN') or hasRole('AI_SYSTEM')")
    fun getAvailableModels(): ResponseEntity<List<AiModelInfo>> {
        val models = listOf(
            AiModelInfo("multimodal-fusion-v1", "Transformer-based multimodal fusion", "1.0.0", true),
            AiModelInfo("uncertainty-quantifier-v1", "Bayesian uncertainty quantification", "1.0.0", true),
            AiModelInfo("synthetic-data-generator-v1", "GAN-based synthetic data generation", "1.0.0", true),
            AiModelInfo("realtime-processor-v1", "Real-time multimodal processing", "1.0.0", true)
        )
        return ResponseEntity.ok(models)
    }

    @GetMapping("/health")
    fun healthCheck(): ResponseEntity<Map<String, Any>> {
        return ResponseEntity.ok(mapOf(
            "status" to "healthy",
            "service" to "multimodal-ai-service",
            "timestamp" to java.time.LocalDateTime.now()
        ))
    }

    // WebSocket Endpoints for Real-time Updates
    @MessageMapping("/realtime/{sessionId}")
    @SendTo("/topic/realtime/{sessionId}")
    fun handleRealTimeMessage(@DestinationVariable sessionId: String, message: Map<String, Any>): RealTimeProcessingRequest {
        logger.info("Received WebSocket message for session: $sessionId")
        // Convert message to processing request
        return RealTimeProcessingRequest(
            sessionId = sessionId,
            modality = DataModality.valueOf(message["modality"] as? String ?: "TEXT"),
            data = message["data"] ?: "",
            priority = Priority.valueOf(message["priority"] as? String ?: "MEDIUM")
        )
    }

    // Streaming endpoints
    @GetMapping("/realtime/stream/{sessionId}", produces = [MediaType.TEXT_EVENT_STREAM_VALUE])
    @PreAuthorize("hasRole('HEALTHCARE_PROVIDER') or hasRole('AI_SYSTEM')")
    fun streamRealTimeUpdates(@PathVariable sessionId: String): Flux<RealTimeUpdate> {
        logger.info("Starting real-time stream for session: $sessionId")
        return realTimeProcessingService.getRealTimeStream(sessionId)
    }

    // Helper methods
    private fun generateReasoning(request: CrossModalReasoningRequest): String {
        return buildString {
            append("Based on the analysis of ")
            append(request.modalities.joinToString(", ") { it.name.lowercase() })
            append(" data, ")
            append(request.query)
            append(". The multimodal reasoning suggests considering ")
            append("correlations between different data modalities to provide ")
            append("a comprehensive clinical assessment.")
        }
    }

    private fun collectEvidence(request: CrossModalReasoningRequest): List<Evidence> {
        return request.modalities.map { modality ->
            Evidence(
                modality = modality,
                source = "multimodal-fusion-model",
                relevance = 0.85,
                contribution = "Provides ${modality.name.lowercase()} perspective on ${request.query}"
            )
        }
    }

    private fun calculateReasoningConfidence(request: CrossModalReasoningRequest, evidence: List<Evidence>): Double {
        val modalityCount = request.modalities.size
        val avgRelevance = evidence.map { it.relevance }.average()
        return minOf((modalityCount * 0.1) + (avgRelevance * 0.9), 1.0)
    }

    private fun generateAlternativeHypotheses(request: CrossModalReasoningRequest): List<String> {
        return listOf(
            "Alternative diagnosis based on different modality weighting",
            "Consider additional clinical context",
            "Re-evaluate with updated patient data"
        )
    }

    // Supporting data class
    data class AiModelInfo(
        val modelId: String,
        val description: String,
        val version: String,
        val active: Boolean
    )

    data class RealTimeUpdate(
        val sessionId: String,
        val timestamp: java.time.LocalDateTime,
        val status: String,
        val currentResults: List<Any>,
        val metrics: ProcessingMetrics
    )

    data class ProcessingMetrics(
        val averageProcessingTime: Double,
        val totalProcessed: Int,
        val currentThroughput: Double
    )
}