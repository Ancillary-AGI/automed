package com.automed.clinical.controller

import com.automed.clinical.dto.*
import com.automed.clinical.service.ClinicalDecisionSupportService
import jakarta.validation.Valid
import org.springframework.http.ResponseEntity
import org.springframework.security.access.prepost.PreAuthorize
import org.springframework.web.bind.annotation.*
import reactor.core.publisher.Mono

@RestController
@RequestMapping("/api/v1/clinical")
@CrossOrigin(origins = ["*"])
class ClinicalDecisionController(
    private val clinicalDecisionService: ClinicalDecisionSupportService
) {

    @PostMapping("/analyze")
    @PreAuthorize("hasRole('HEALTHCARE_PROVIDER')")
    fun analyzeClinicalData(@Valid @RequestBody request: ClinicalAnalysisRequest): Mono<ResponseEntity<ClinicalDecisionResponse>> {
        return clinicalDecisionService.analyzeClinicalData(request)
            .map { ResponseEntity.ok(it) }
    }

    @PostMapping("/sepsis-analysis")
    @PreAuthorize("hasRole('HEALTHCARE_PROVIDER')")
    fun analyzeSepsisRisk(@Valid @RequestBody request: SepsisAnalysisRequest): Mono<ResponseEntity<SepsisRiskResponse>> {
        return clinicalDecisionService.analyzeSepsisRisk(request)
            .map { ResponseEntity.ok(it) }
    }

    @PostMapping("/medication-dosing")
    @PreAuthorize("hasRole('HEALTHCARE_PROVIDER')")
    fun calculateMedicationDosing(@Valid @RequestBody request: MedicationDosingRequest): Mono<ResponseEntity<MedicationDosingResponse>> {
        return clinicalDecisionService.calculateMedicationDosing(request)
            .map { ResponseEntity.ok(it) }
    }

    @PostMapping("/fall-risk")
    @PreAuthorize("hasRole('HEALTHCARE_PROVIDER')")
    fun assessFallRisk(@Valid @RequestBody request: FallRiskAssessmentRequest): Mono<ResponseEntity<FallRiskResponse>> {
        return clinicalDecisionService.assessFallRisk(request)
            .map { ResponseEntity.ok(it) }
    }

    @PostMapping("/pressure-ulcer-risk")
    @PreAuthorize("hasRole('HEALTHCARE_PROVIDER')")
    fun assessPressureUlcerRisk(@Valid @RequestBody request: PressureUlcerRiskRequest): Mono<ResponseEntity<PressureUlcerRiskResponse>> {
        return clinicalDecisionService.assessPressureUlcerRisk(request)
            .map { ResponseEntity.ok(it) }
    }

    @PostMapping("/early-warning")
    @PreAuthorize("hasRole('HEALTHCARE_PROVIDER')")
    fun calculateEarlyWarningScore(@Valid @RequestBody request: EarlyWarningScoreRequest): Mono<ResponseEntity<EarlyWarningScoreResponse>> {
        return clinicalDecisionService.calculateEarlyWarningScore(request)
            .map { ResponseEntity.ok(it) }
    }

    @PostMapping("/cardiac-risk")
    @PreAuthorize("hasRole('HEALTHCARE_PROVIDER')")
    fun assessCardiacRisk(@Valid @RequestBody request: CardiacRiskAssessmentRequest): Mono<ResponseEntity<CardiacRiskResponse>> {
        return clinicalDecisionService.assessCardiacRisk(request)
            .map { ResponseEntity.ok(it) }
    }

    @PostMapping("/stroke-risk")
    @PreAuthorize("hasRole('HEALTHCARE_PROVIDER')")
    fun assessStrokeRisk(@Valid @RequestBody request: StrokeRiskAssessmentRequest): Mono<ResponseEntity<StrokeRiskResponse>> {
        return clinicalDecisionService.assessStrokeRisk(request)
            .map { ResponseEntity.ok(it) }
    }

    @PostMapping("/delirium-assessment")
    @PreAuthorize("hasRole('HEALTHCARE_PROVIDER')")
    fun assessDelirium(@Valid @RequestBody request: DeliriumAssessmentRequest): Mono<ResponseEntity<DeliriumAssessmentResponse>> {
        return clinicalDecisionService.assessDelirium(request)
            .map { ResponseEntity.ok(it) }
    }

    @PostMapping("/pain-assessment")
    @PreAuthorize("hasRole('HEALTHCARE_PROVIDER')")
    fun assessPain(@Valid @RequestBody request: PainAssessmentRequest): Mono<ResponseEntity<PainAssessmentResponse>> {
        return clinicalDecisionService.assessPain(request)
            .map { ResponseEntity.ok(it) }
    }

    @GetMapping("/guidelines/{condition}")
    @PreAuthorize("hasRole('HEALTHCARE_PROVIDER')")
    fun getClinicalGuidelines(@PathVariable condition: String): ResponseEntity<List<ClinicalGuideline>> {
        val guidelines = clinicalDecisionService.getClinicalGuidelines(condition)
        return ResponseEntity.ok(guidelines)
    }

    @GetMapping("/pathways/{condition}")
    @PreAuthorize("hasRole('HEALTHCARE_PROVIDER')")
    fun getClinicalPathways(@PathVariable condition: String): ResponseEntity<List<ClinicalPathway>> {
        val pathways = clinicalDecisionService.getClinicalPathways(condition)
        return ResponseEntity.ok(pathways)
    }

    @GetMapping("/quality-metrics/{hospitalId}")
    @PreAuthorize("hasRole('HEALTHCARE_PROVIDER') or hasRole('ADMIN')")
    fun getQualityMetrics(@PathVariable hospitalId: String): ResponseEntity<List<QualityMetric>> {
        val metrics = clinicalDecisionService.getQualityMetrics(hospitalId)
        return ResponseEntity.ok(metrics)
    }
}