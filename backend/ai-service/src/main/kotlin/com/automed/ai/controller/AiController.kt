package com.automed.ai.controller

import com.automed.ai.dto.*
import com.automed.ai.service.AiService
import com.automed.ai.service.CausalAnalysisService
import jakarta.validation.Valid
import org.springframework.http.ResponseEntity
import org.springframework.security.access.prepost.PreAuthorize
import org.springframework.web.bind.annotation.*
import reactor.core.publisher.Mono

@RestController
@RequestMapping("/api/v1/ai")
@CrossOrigin(origins = ["*"])
class AiController(
    private val aiService: AiService,
    private val causalAnalysisService: CausalAnalysisService
) {

    @PostMapping("/predict-diagnosis")
    @PreAuthorize("hasRole('HEALTHCARE_PROVIDER')")
    fun predictDiagnosis(@Valid @RequestBody request: DiagnosisPredictionRequest): Mono<ResponseEntity<DiagnosisPredictionResponse>> {
        return aiService.predictDiagnosis(request)
            .map { ResponseEntity.ok(it) }
    }

    @PostMapping("/analyze-symptoms")
    @PreAuthorize("hasRole('HEALTHCARE_PROVIDER') or hasRole('PATIENT')")
    fun analyzeSymptoms(@Valid @RequestBody request: SymptomAnalysisRequest): Mono<ResponseEntity<SymptomAnalysisResponse>> {
        return aiService.analyzeSymptoms(request)
            .map { ResponseEntity.ok(it) }
    }

    @PostMapping("/triage")
    @PreAuthorize("hasRole('HEALTHCARE_PROVIDER')")
    fun performTriage(@Valid @RequestBody request: TriageRequest): Mono<ResponseEntity<TriageResponse>> {
        return aiService.performTriage(request)
            .map { ResponseEntity.ok(it) }
    }

    @PostMapping("/analyze-vitals")
    @PreAuthorize("hasRole('HEALTHCARE_PROVIDER') or hasRole('PATIENT')")
    fun analyzeVitals(@Valid @RequestBody request: VitalsAnalysisRequest): Mono<ResponseEntity<VitalsAnalysisResponse>> {
        return aiService.analyzeVitals(request)
            .map { ResponseEntity.ok(it) }
    }

    @PostMapping("/drug-interaction")
    @PreAuthorize("hasRole('HEALTHCARE_PROVIDER')")
    fun checkDrugInteractions(@Valid @RequestBody request: DrugInteractionRequest): Mono<ResponseEntity<DrugInteractionResponse>> {
        return aiService.checkDrugInteractions(request)
            .map { ResponseEntity.ok(it) }
    }

    @GetMapping("/models")
    @PreAuthorize("hasRole('HEALTHCARE_PROVIDER') or hasRole('ADMIN')")
    fun getAvailableModels(): ResponseEntity<List<AiModelInfo>> {
        val models = aiService.getAvailableModels()
        return ResponseEntity.ok(models)
    }

    @GetMapping("/models/{modelId}/download")
    @PreAuthorize("hasRole('HEALTHCARE_PROVIDER') or hasRole('PATIENT')")
    fun downloadModel(@PathVariable modelId: String): Mono<ResponseEntity<ModelDownloadResponse>> {
        return aiService.getModelDownloadInfo(modelId)
            .map { ResponseEntity.ok(it) }
    }

    @PostMapping("/feedback")
    @PreAuthorize("hasRole('HEALTHCARE_PROVIDER')")
    fun submitFeedback(@Valid @RequestBody request: AiFeedbackRequest): ResponseEntity<AiFeedbackResponse> {
        val response = aiService.submitFeedback(request)
        return ResponseEntity.ok(response)
    }

    @PostMapping("/predictive-health")
    @PreAuthorize("hasRole('HEALTHCARE_PROVIDER') or hasRole('PATIENT')")
    fun predictHealth(@Valid @RequestBody request: PredictiveHealthRequest): Mono<ResponseEntity<PredictiveHealthResponse>> {
        return aiService.predictHealth(request)
            .map { ResponseEntity.ok(it) }
    }

    @PostMapping("/analyze-medical-image")
    @PreAuthorize("hasRole('HEALTHCARE_PROVIDER')")
    fun analyzeMedicalImage(@Valid @RequestBody request: MedicalImageAnalysisRequest): Mono<ResponseEntity<MedicalImageAnalysisResponse>> {
        return aiService.analyzeMedicalImage(request)
            .map { ResponseEntity.ok(it) }
    }

    @PostMapping("/analyze-wearable-data")
    @PreAuthorize("hasRole('HEALTHCARE_PROVIDER') or hasRole('PATIENT')")
    fun analyzeWearableData(@Valid @RequestBody request: WearableDataRequest): Mono<ResponseEntity<WearableDataResponse>> {
        return aiService.analyzeWearableData(request)
            .map { ResponseEntity.ok(it) }
    }

    @PostMapping("/analyze-voice")
    @PreAuthorize("hasRole('HEALTHCARE_PROVIDER') or hasRole('PATIENT')")
    fun analyzeVoice(@Valid @RequestBody request: VoiceAnalysisRequest): Mono<ResponseEntity<VoiceAnalysisResponse>> {
        return aiService.analyzeVoice(request)
            .map { ResponseEntity.ok(it) }
    }

    @PostMapping("/population-health")
    @PreAuthorize("hasRole('HEALTHCARE_PROVIDER') or hasRole('ADMIN')")
    fun analyzePopulationHealth(@Valid @RequestBody request: PopulationHealthRequest): Mono<ResponseEntity<PopulationHealthResponse>> {
        return aiService.analyzePopulationHealth(request)
            .map { ResponseEntity.ok(it) }
    }

    @PostMapping("/detect-outbreak")
    @PreAuthorize("hasRole('HEALTHCARE_PROVIDER') or hasRole('ADMIN')")
    fun detectOutbreak(@Valid @RequestBody request: OutbreakDetectionRequest): Mono<ResponseEntity<OutbreakDetectionResponse>> {
        return aiService.detectOutbreak(request)
            .map { ResponseEntity.ok(it) }
    }

    @PostMapping("/robotic-procedure")
    @PreAuthorize("hasRole('HEALTHCARE_PROVIDER')")
    fun initiateRoboticProcedure(@Valid @RequestBody request: RoboticProcedureRequest): Mono<ResponseEntity<RoboticProcedureResponse>> {
        return aiService.initiateRoboticProcedure(request)
            .map { ResponseEntity.ok(it) }
    }

    @PostMapping("/vr-training")
    @PreAuthorize("hasRole('HEALTHCARE_PROVIDER') or hasRole('ADMIN')")
    fun startVRTraining(@Valid @RequestBody request: VRTrainingRequest): Mono<ResponseEntity<VRTrainingResponse>> {
        return aiService.startVRTraining(request)
            .map { ResponseEntity.ok(it) }
    }

    // ===== CAUSAL AI ENDPOINTS =====

    @PostMapping("/causal-analysis")
    @PreAuthorize("hasRole('HEALTHCARE_PROVIDER')")
    fun performCausalAnalysis(@Valid @RequestBody request: CausalAnalysisRequest): Mono<ResponseEntity<CausalAnalysisResponse>> {
        return causalAnalysisService.performCausalAnalysis(request)
            .map { ResponseEntity.ok(it) }
    }

    @PostMapping("/counterfactual-reasoning")
    @PreAuthorize("hasRole('HEALTHCARE_PROVIDER')")
    fun generateCounterfactuals(@Valid @RequestBody request: CounterfactualRequest): Mono<ResponseEntity<CounterfactualResponse>> {
        return causalAnalysisService.generateCounterfactuals(request)
            .map { ResponseEntity.ok(it) }
    }

    @PostMapping("/treatment-optimization")
    @PreAuthorize("hasRole('HEALTHCARE_PROVIDER')")
    fun optimizeTreatmentPathway(@Valid @RequestBody request: TreatmentOptimizationRequest): Mono<ResponseEntity<TreatmentOptimizationResponse>> {
        return causalAnalysisService.optimizeTreatmentPathway(request)
            .map { ResponseEntity.ok(it) }
    }

    @PostMapping("/personalized-causal-model")
    @PreAuthorize("hasRole('HEALTHCARE_PROVIDER')")
    fun createPersonalizedModel(@Valid @RequestBody request: PersonalizedCausalModelRequest): Mono<ResponseEntity<PersonalizedCausalModelResponse>> {
        return causalAnalysisService.createPersonalizedModel(request)
            .map { ResponseEntity.ok(it) }
    }

    @GetMapping("/causal-models/{patientId}")
    @PreAuthorize("hasRole('HEALTHCARE_PROVIDER')")
    fun getPersonalizedModel(@PathVariable patientId: String): ResponseEntity<PersonalizedCausalModelResponse?> {
        // This would retrieve stored models - simplified for now
        return ResponseEntity.ok(null)
    }
}
