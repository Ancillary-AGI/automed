package com.automed.ai.dto

import jakarta.validation.constraints.*
import java.util.*

// Causal Analysis Request/Response DTOs
data class CausalAnalysisRequest(
    @field:NotBlank
    val patientId: String,

    @field:NotEmpty
    val treatmentVariables: List<String>,

    @field:NotEmpty
    val outcomeVariables: List<String>,

    @field:NotEmpty
    val confoundingVariables: List<String>,

    val historicalData: List<CausalDataPoint>? = null,

    val interventionType: InterventionType = InterventionType.DO_OPERATOR,

    val analysisType: CausalAnalysisType = CausalAnalysisType.TREATMENT_EFFECT
)

data class CausalAnalysisResponse(
    val patientId: String,
    val causalEffects: List<CausalEffect>,
    val confidenceIntervals: Map<String, ConfidenceInterval>,
    val causalGraph: CausalGraph,
    val recommendations: List<String>,
    val riskAssessment: RiskAssessment,
    val analysisMetadata: CausalAnalysisMetadata
)

data class CausalEffect(
    val treatment: String,
    val outcome: String,
    val effectSize: Double,
    val effectType: EffectType,
    val confidence: Double,
    val pValue: Double,
    val description: String
)

data class ConfidenceInterval(
    val lower: Double,
    val upper: Double,
    val confidenceLevel: Double = 0.95
)

data class CausalGraph(
    val nodes: List<CausalNode>,
    val edges: List<CausalEdge>,
    val graphType: String = "DAG"
)

data class CausalNode(
    val id: String,
    val name: String,
    val type: NodeType,
    val properties: Map<String, Any> = emptyMap()
)

data class CausalEdge(
    val source: String,
    val target: String,
    val edgeType: EdgeType,
    val strength: Double = 1.0,
    val properties: Map<String, Any> = emptyMap()
)

data class RiskAssessment(
    val overallRisk: Double,
    val riskFactors: List<RiskFactor>,
    val mitigationStrategies: List<String>
)

data class RiskFactor(
    val factor: String,
    val impact: Double,
    val probability: Double,
    val description: String
)

data class CausalAnalysisMetadata(
    val analysisId: String = UUID.randomUUID().toString(),
    val timestamp: Long = System.currentTimeMillis(),
    val modelVersion: String,
    val dataQualityScore: Double,
    val assumptions: List<String>
)

// Counterfactual Reasoning DTOs
data class CounterfactualRequest(
    @field:NotBlank
    val patientId: String,

    @field:NotEmpty
    val factualScenario: Scenario,

    @field:NotEmpty
    val counterfactualScenarios: List<Scenario>,

    val interventionVariables: List<String>? = null,

    val outcomeVariables: List<String>? = null
)

data class CounterfactualResponse(
    val patientId: String,
    val factualOutcome: ScenarioOutcome,
    val counterfactualOutcomes: List<ScenarioOutcome>,
    val causalContrast: List<CausalContrast>,
    val whatIfAnalysis: WhatIfAnalysis,
    val recommendations: List<String>
)

data class Scenario(
    val variables: Map<String, Any>,
    val timestamp: Long? = null,
    val context: Map<String, Any> = emptyMap()
)

data class ScenarioOutcome(
    val scenarioId: String,
    val outcome: Map<String, Any>,
    val probability: Double,
    val confidence: Double,
    val explanation: String
)

data class CausalContrast(
    val factualValue: Any,
    val counterfactualValue: Any,
    val difference: Double,
    val significance: Double,
    val variable: String
)

data class WhatIfAnalysis(
    val keyInsights: List<String>,
    val potentialBenefits: List<String>,
    val potentialRisks: List<String>,
    val actionableRecommendations: List<String>
)

// Treatment Optimization DTOs
data class TreatmentOptimizationRequest(
    @field:NotBlank
    val patientId: String,

    @field:NotEmpty
    val availableTreatments: List<Treatment>,

    @field:NotEmpty
    val patientProfile: PatientProfile,

    val constraints: TreatmentConstraints? = null,

    val optimizationCriteria: List<OptimizationCriterion> = listOf(
        OptimizationCriterion.EFFICACY,
        OptimizationCriterion.SAFETY,
        OptimizationCriterion.COST
    ),

    val timeHorizon: Int = 30 // days
)

data class TreatmentOptimizationResponse(
    val patientId: String,
    val optimalTreatmentPathway: TreatmentPathway,
    val alternativePathways: List<TreatmentPathway>,
    val expectedOutcomes: ExpectedOutcomes,
    val riskBenefitAnalysis: RiskBenefitAnalysis,
    val optimizationMetadata: OptimizationMetadata
)

data class Treatment(
    val id: String,
    val name: String,
    val type: TreatmentType,
    val dosage: String? = null,
    val duration: Int? = null, // days
    val cost: Double? = null,
    val sideEffects: List<String> = emptyList(),
    val contraindications: List<String> = emptyList()
)

data class PatientProfile(
    val demographics: Demographics,
    val medicalHistory: List<String>,
    val currentConditions: List<String>,
    val allergies: List<String> = emptyList(),
    val biomarkers: Map<String, Double> = emptyMap(),
    val geneticFactors: Map<String, String> = emptyMap()
)

data class Demographics(
    val age: Int,
    val gender: String,
    val weight: Double? = null,
    val height: Double? = null,
    val ethnicity: String? = null
)

data class TreatmentConstraints(
    val maxCost: Double? = null,
    val maxDuration: Int? = null,
    val excludedTreatments: List<String> = emptyList(),
    val preferredTreatments: List<String> = emptyList(),
    val comorbidities: List<String> = emptyList()
)

data class TreatmentPathway(
    val pathwayId: String,
    val treatments: List<Treatment>,
    val sequence: List<String>, // treatment IDs in order
    val duration: Int,
    val totalCost: Double,
    val expectedEfficacy: Double,
    val riskScore: Double,
    val rationale: String
)

data class ExpectedOutcomes(
    val efficacyProbability: Double,
    val adverseEventProbability: Double,
    val qualityOfLifeScore: Double,
    val survivalProbability: Double? = null,
    val timeToImprovement: Int? = null
)

data class RiskBenefitAnalysis(
    val benefitRiskRatio: Double,
    val keyBenefits: List<String>,
    val keyRisks: List<String>,
    val mitigationStrategies: List<String>
)

data class OptimizationMetadata(
    val optimizationId: String = UUID.randomUUID().toString(),
    val timestamp: Long = System.currentTimeMillis(),
    val algorithm: String,
    val confidence: Double,
    val assumptions: List<String>
)

// Personalized Causal Model DTOs
data class PersonalizedCausalModelRequest(
    @field:NotBlank
    val patientId: String,

    @field:NotEmpty
    val patientData: List<CausalDataPoint>,

    val modelType: CausalModelType = CausalModelType.BAYESIAN_NETWORK,

    val includeConfounders: Boolean = true,

    val validationData: List<CausalDataPoint>? = null
)

data class PersonalizedCausalModelResponse(
    val patientId: String,
    val causalModel: CausalModel,
    val modelPerformance: ModelPerformance,
    val personalizedInsights: List<String>,
    val recommendations: List<String>,
    val modelMetadata: CausalModelMetadata
)

data class CausalDataPoint(
    val timestamp: Long,
    val variables: Map<String, Any>,
    val interventions: Map<String, Any> = emptyMap(),
    val outcomes: Map<String, Any> = emptyMap()
)

data class CausalModel(
    val modelId: String,
    val modelType: CausalModelType,
    val variables: List<String>,
    val relationships: List<CausalRelationship>,
    val parameters: Map<String, Any>,
    val structure: CausalGraph
)

data class CausalRelationship(
    val cause: String,
    val effect: String,
    val strength: Double,
    val direction: RelationshipDirection,
    val confidence: Double,
    val evidence: List<String>
)

data class ModelPerformance(
    val accuracy: Double,
    val precision: Double,
    val recall: Double,
    val f1Score: Double,
    val auc: Double? = null,
    val calibrationScore: Double? = null
)

data class CausalModelMetadata(
    val modelId: String,
    val createdAt: Long = System.currentTimeMillis(),
    val lastUpdated: Long = System.currentTimeMillis(),
    val trainingDataSize: Int,
    val validationScore: Double,
    val modelVersion: String
)

// Enums
enum class InterventionType {
    DO_OPERATOR,
    BACKDOOR_CRITERION,
    FRONTDOOR_CRITERION,
    IV_ESTIMATION
}

enum class CausalAnalysisType {
    TREATMENT_EFFECT,
    MEDIATION_ANALYSIS,
    CONFOUNDING_ADJUSTMENT,
    HETEROGENEOUS_EFFECT
}

enum class EffectType {
    AVERAGE_TREATMENT_EFFECT,
    CONDITIONAL_AVERAGE_TREATMENT_EFFECT,
    MARGINAL_EFFECT,
    TOTAL_EFFECT,
    DIRECT_EFFECT,
    INDIRECT_EFFECT
}

enum class NodeType {
    TREATMENT,
    OUTCOME,
    CONFOUNDER,
    MEDIATOR,
    COLLIDER
}

enum class EdgeType {
    CAUSAL,
    CONFOUNDING,
    MEDIATION,
    SELECTION_BIAS
}

enum class TreatmentType {
    MEDICATION,
    SURGERY,
    THERAPY,
    LIFESTYLE,
    MONITORING,
    COMBINATION
}

enum class OptimizationCriterion {
    EFFICACY,
    SAFETY,
    COST,
    QUALITY_OF_LIFE,
    PATIENT_PREFERENCE,
    CLINICAL_GUIDELINES
}

enum class CausalModelType {
    BAYESIAN_NETWORK,
    STRUCTURAL_EQUATION_MODEL,
    DECISION_TREE,
    GRAPHICAL_MODEL
}

enum class RelationshipDirection {
    DIRECTED,
    UNDIRECTED,
    BIDIRECTED
}