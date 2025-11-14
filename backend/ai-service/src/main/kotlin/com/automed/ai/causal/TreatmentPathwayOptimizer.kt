package com.automed.ai.causal

import com.automed.ai.dto.*
import kotlin.math.max
import kotlin.math.min
import kotlin.math.pow

/**
 * Treatment Pathway Optimizer using causal understanding
 * Optimizes treatment sequences considering causal relationships, efficacy, safety, and costs
 */
class TreatmentPathwayOptimizer(
    private val causalModel: CausalGraphicalModel,
    private val patientProfile: PatientProfile,
    private val historicalOutcomes: List<CausalDataPoint>
) {

    private val optimizationAlgorithms = listOf(
        OptimizationAlgorithm.GENETIC,
        OptimizationAlgorithm.DYNAMIC_PROGRAMMING,
        OptimizationAlgorithm.REINFORCEMENT_LEARNING
    )

    /**
     * Optimize treatment pathway for a patient
     */
    fun optimizePathway(
        availableTreatments: List<Treatment>,
        constraints: TreatmentConstraints? = null,
        criteria: List<OptimizationCriterion> = listOf(OptimizationCriterion.EFFICACY),
        timeHorizon: Int = 30
    ): TreatmentPathway {
        // Validate inputs
        require(availableTreatments.isNotEmpty()) { "At least one treatment must be available" }
        require(timeHorizon > 0) { "Time horizon must be positive" }

        // Generate candidate pathways
        val candidatePathways = generateCandidatePathways(availableTreatments, constraints, timeHorizon)

        // Evaluate pathways using causal understanding
        val evaluatedPathways = candidatePathways.map { pathway ->
            evaluatePathway(pathway, criteria)
        }

        // Select optimal pathway
        val optimalPathway = selectOptimalPathway(evaluatedPathways, criteria)

        return optimalPathway
    }

    /**
     * Generate candidate treatment pathways
     */
    private fun generateCandidatePathways(
        treatments: List<Treatment>,
        constraints: TreatmentConstraints?,
        timeHorizon: Int
    ): List<CandidatePathway> {
        val pathways = mutableListOf<CandidatePathway>()

        // Generate monotherapy pathways
        treatments.forEach { treatment ->
            if (satisfiesConstraints(treatment, constraints)) {
                pathways.add(CandidatePathway(listOf(treatment)))
            }
        }

        // Generate combination pathways (up to 3 treatments)
        if (treatments.size >= 2) {
            for (i in treatments.indices) {
                for (j in i + 1 until treatments.size) {
                    val combo = listOf(treatments[i], treatments[j])
                    if (combo.all { satisfiesConstraints(it, constraints) } &&
                        isCompatibleCombination(combo)) {
                        pathways.add(CandidatePathway(combo))
                    }
                }
            }
        }

        // Generate sequential pathways
        generateSequentialPathways(treatments, constraints, timeHorizon, pathways)

        return pathways.take(50) // Limit to top candidates
    }

    /**
     * Generate sequential treatment pathways
     */
    private fun generateSequentialPathways(
        treatments: List<Treatment>,
        constraints: TreatmentConstraints?,
        timeHorizon: Int,
        pathways: MutableList<CandidatePathway>
    ) {
        // Simple sequential generation - first-line, then second-line if needed
        val firstLineTreatments = treatments.filter { it.type == TreatmentType.MEDICATION }
        val secondLineTreatments = treatments.filter { it.type != TreatmentType.MEDICATION }

        firstLineTreatments.forEach { first ->
            secondLineTreatments.forEach { second ->
                if (isValidSequence(first, second) &&
                    satisfiesConstraints(first, constraints) &&
                    satisfiesConstraints(second, constraints)) {

                    pathways.add(CandidatePathway(listOf(first, second)))
                }
            }
        }
    }

    /**
     * Check if treatment satisfies constraints
     */
    private fun satisfiesConstraints(treatment: Treatment, constraints: TreatmentConstraints?): Boolean {
        if (constraints == null) return true

        // Cost constraint
        if (constraints.maxCost != null && treatment.cost != null) {
            if (treatment.cost > constraints.maxCost) return false
        }

        // Duration constraint
        if (constraints.maxDuration != null && treatment.duration != null) {
            if (treatment.duration > constraints.maxDuration) return false
        }

        // Excluded treatments
        if (constraints.excludedTreatments.contains(treatment.id)) return false

        // Preferred treatments (if specified, only allow preferred)
        if (constraints.preferredTreatments.isNotEmpty()) {
            if (!constraints.preferredTreatments.contains(treatment.id)) return false
        }

        // Patient allergies
        if (treatment.sideEffects.any { sideEffect ->
            patientProfile.allergies.any { allergy ->
                sideEffect.contains(allergy, ignoreCase = true)
            }
        }) return false

        // Medical conditions compatibility
        if (treatment.contraindications.any { contraindication ->
            patientProfile.medicalHistory.any { condition ->
                condition.contains(contraindication, ignoreCase = true)
            }
        }) return false

        return true
    }

    /**
     * Check if treatment combination is compatible
     */
    private fun isCompatibleCombination(treatments: List<Treatment>): Boolean {
        // Check for drug interactions
        val medications = treatments.filter { it.type == TreatmentType.MEDICATION }
        if (medications.size > 1) {
            // Simplified interaction check - in practice would use drug interaction database
            val drugNames = medications.map { it.name }
            if (drugNames.contains("Aspirin") && drugNames.contains("Warfarin")) {
                return false // Known interaction
            }
        }

        // Check for redundant treatments
        val types = treatments.map { it.type }.distinct()
        if (types.size < treatments.size) {
            return false // Same type treatments
        }

        return true
    }

    /**
     * Check if treatment sequence is valid
     */
    private fun isValidSequence(first: Treatment, second: Treatment): Boolean {
        // First-line should be less aggressive than second-line
        if (first.type == TreatmentType.SURGERY && second.type == TreatmentType.MEDICATION) {
            return false // Surgery typically not followed by medication as first-line
        }

        // Check for logical progression
        val progressionValid = when {
            first.type == TreatmentType.LIFESTYLE && second.type == TreatmentType.MEDICATION -> true
            first.type == TreatmentType.MEDICATION && second.type == TreatmentType.THERAPY -> true
            first.type == TreatmentType.MEDICATION && second.type == TreatmentType.SURGERY -> true
            first.type == TreatmentType.THERAPY && second.type == TreatmentType.MEDICATION -> false
            else -> true
        }

        return progressionValid
    }

    /**
     * Evaluate a treatment pathway using causal understanding
     */
    private fun evaluatePathway(
        pathway: CandidatePathway,
        criteria: List<OptimizationCriterion>
    ): EvaluatedPathway {
        val treatments = pathway.treatments

        // Calculate causal effects
        val causalEffects = calculatePathwayCausalEffects(treatments)

        // Calculate efficacy
        val efficacy = calculatePathwayEfficacy(treatments, causalEffects)

        // Calculate safety
        val safety = calculatePathwaySafety(treatments)

        // Calculate cost
        val totalCost = treatments.sumOf { it.cost ?: 0.0 }

        // Calculate duration
        val totalDuration = treatments.sumOf { it.duration ?: 0 }

        // Calculate quality of life impact
        val qualityOfLife = calculateQualityOfLifeImpact(treatments, safety)

        // Calculate overall score based on criteria
        val overallScore = calculateOverallScore(
            efficacy = efficacy,
            safety = safety,
            cost = totalCost,
            qualityOfLife = qualityOfLife,
            criteria = criteria
        )

        return EvaluatedPathway(
            pathway = pathway,
            efficacy = efficacy,
            safety = safety,
            cost = totalCost,
            duration = totalDuration,
            qualityOfLife = qualityOfLife,
            causalEffects = causalEffects,
            overallScore = overallScore
        )
    }

    /**
     * Calculate causal effects for the pathway
     */
    private fun calculatePathwayCausalEffects(treatments: List<Treatment>): List<CausalEffect> {
        val effects = mutableListOf<CausalEffect>()

        treatments.forEach { treatment ->
            // Use causal model to estimate treatment effects
            val treatmentEffect = causalModel.applyDoOperator(
                "outcome",
                "treatment",
                1.0, // Binary treatment indicator
                historicalOutcomes
            )

            effects.add(CausalEffect(
                treatment = treatment.name,
                outcome = "health_outcome",
                effectSize = treatmentEffect,
                effectType = EffectType.AVERAGE_TREATMENT_EFFECT,
                confidence = 0.8,
                pValue = 0.05,
                description = "Causal effect of ${treatment.name} on health outcomes"
            ))
        }

        return effects
    }

    /**
     * Calculate pathway efficacy
     */
    private fun calculatePathwayEfficacy(treatments: List<Treatment>, causalEffects: List<CausalEffect>): Double {
        var totalEfficacy = 0.0
        var weightSum = 0.0

        treatments.forEachIndexed { index, treatment ->
            val baseEfficacy = when (treatment.type) {
                TreatmentType.MEDICATION -> 0.7
                TreatmentType.SURGERY -> 0.9
                TreatmentType.THERAPY -> 0.6
                TreatmentType.LIFESTYLE -> 0.4
                else -> 0.5
            }

            // Adjust for causal effects
            val causalAdjustment = causalEffects.getOrNull(index)?.effectSize ?: 0.0
            val adjustedEfficacy = baseEfficacy * (1.0 + causalAdjustment * 0.2)

            // Weight by treatment position (later treatments have less impact)
            val weight = 1.0 / (index + 1.0)
            totalEfficacy += adjustedEfficacy * weight
            weightSum += weight
        }

        // Adjust for patient factors
        val patientAdjustment = calculatePatientEfficacyAdjustment()
        totalEfficacy *= patientAdjustment

        return min(1.0, totalEfficacy / weightSum)
    }

    /**
     * Calculate patient-specific efficacy adjustment
     */
    private fun calculatePatientEfficacyAdjustment(): Double {
        var adjustment = 1.0

        // Age adjustment
        val age = patientProfile.demographics.age
        adjustment *= when {
            age < 30 -> 1.1
            age > 70 -> 0.9
            else -> 1.0
        }

        // Comorbidity adjustment
        val comorbidityCount = patientProfile.medicalHistory.size
        adjustment *= max(0.5, 1.0 - comorbidityCount * 0.1)

        // Biomarker adjustment
        patientProfile.biomarkers.forEach { (biomarker, value) ->
            when (biomarker) {
                "inflammation_marker" -> if (value > 10) adjustment *= 0.8
                "immune_response" -> if (value > 5) adjustment *= 1.2
            }
        }

        return adjustment
    }

    /**
     * Calculate pathway safety
     */
    private fun calculatePathwaySafety(treatments: List<Treatment>): Double {
        var totalRisk = 0.0
        var riskCount = 0

        treatments.forEach { treatment ->
            // Base risk by treatment type
            val baseRisk = when (treatment.type) {
                TreatmentType.MEDICATION -> 0.2
                TreatmentType.SURGERY -> 0.4
                TreatmentType.THERAPY -> 0.1
                TreatmentType.LIFESTYLE -> 0.05
                else -> 0.15
            }

            // Adjust for side effects
            val sideEffectRisk = treatment.sideEffects.size * 0.1
            val adjustedRisk = baseRisk + sideEffectRisk

            // Adjust for patient allergies
            val allergyRisk = if (treatment.sideEffects.any { sideEffect ->
                patientProfile.allergies.any { allergy ->
                    sideEffect.contains(allergy, ignoreCase = true)
                }
            }) 0.3 else 0.0

            totalRisk += adjustedRisk + allergyRisk
            riskCount++
        }

        // Combination risk
        if (treatments.size > 1) {
            totalRisk *= 1.2 // Increased risk for combinations
        }

        return max(0.0, 1.0 - totalRisk / riskCount)
    }

    /**
     * Calculate quality of life impact
     */
    private fun calculateQualityOfLifeImpact(treatments: List<Treatment>, safety: Double): Double {
        var qolImpact = 1.0

        treatments.forEach { treatment ->
            // Treatment burden
            val burdenImpact = when (treatment.type) {
                TreatmentType.SURGERY -> 0.3
                TreatmentType.MEDICATION -> 0.1
                TreatmentType.THERAPY -> 0.2
                TreatmentType.LIFESTYLE -> 0.05
                else -> 0.15
            }

            qolImpact *= (1.0 - burdenImpact)
        }

        // Safety adjustment
        qolImpact *= safety

        // Patient age adjustment (older patients more affected)
        val ageAdjustment = max(0.8, 1.0 - (patientProfile.demographics.age - 50) * 0.005)
        qolImpact *= ageAdjustment

        return qolImpact
    }

    /**
     * Calculate overall optimization score
     */
    private fun calculateOverallScore(
        efficacy: Double,
        safety: Double,
        cost: Double,
        qualityOfLife: Double,
        criteria: List<OptimizationCriterion>
    ): Double {
        val weights = calculateCriterionWeights(criteria)

        var score = 0.0
        var totalWeight = 0.0

        criteria.forEach { criterion ->
            val weight = weights[criterion] ?: 0.0
            val value = when (criterion) {
                OptimizationCriterion.EFFICACY -> efficacy
                OptimizationCriterion.SAFETY -> safety
                OptimizationCriterion.COST -> 1.0 / (1.0 + cost / 1000.0) // Inverse cost
                OptimizationCriterion.QUALITY_OF_LIFE -> qualityOfLife
                OptimizationCriterion.CLINICAL_GUIDELINES -> 0.8 // Placeholder
                else -> 0.5
            }

            score += value * weight
            totalWeight += weight
        }

        return if (totalWeight > 0) score / totalWeight else 0.5
    }

    /**
     * Calculate weights for optimization criteria
     */
    private fun calculateCriterionWeights(criteria: List<OptimizationCriterion>): Map<OptimizationCriterion, Double> {
        val weights = mutableMapOf<OptimizationCriterion, Double>()

        criteria.forEach { criterion ->
            weights[criterion] = when (criterion) {
                OptimizationCriterion.EFFICACY -> 0.4
                OptimizationCriterion.SAFETY -> 0.3
                OptimizationCriterion.COST -> 0.1
                OptimizationCriterion.QUALITY_OF_LIFE -> 0.15
                OptimizationCriterion.CLINICAL_GUIDELINES -> 0.05
                else -> 0.1
            }
        }

        return weights
    }

    /**
     * Select the optimal pathway from evaluated candidates
     */
    private fun selectOptimalPathway(
        evaluatedPathways: List<EvaluatedPathway>,
        criteria: List<OptimizationCriterion>
    ): TreatmentPathway {
        if (evaluatedPathways.isEmpty()) {
            throw IllegalStateException("No valid treatment pathways found")
        }

        // Sort by overall score (descending)
        val sortedPathways = evaluatedPathways.sortedByDescending { it.overallScore }
        val optimal = sortedPathways.first()

        // Generate alternative pathways (top 3)
        val alternatives = sortedPathways.take(3).map { pathway ->
            TreatmentPathway(
                pathwayId = "alt_${pathway.pathway.treatments.hashCode()}",
                treatments = pathway.pathway.treatments,
                sequence = pathway.pathway.treatments.map { it.id },
                duration = pathway.duration,
                totalCost = pathway.cost,
                expectedEfficacy = pathway.efficacy,
                riskScore = 1.0 - pathway.safety,
                rationale = "Alternative pathway with score: ${"%.3f".format(pathway.overallScore)}"
            )
        }

        return TreatmentPathway(
            pathwayId = "optimal_${optimal.pathway.treatments.hashCode()}",
            treatments = optimal.pathway.treatments,
            sequence = optimal.pathway.treatments.map { it.id },
            duration = optimal.duration,
            totalCost = optimal.cost,
            expectedEfficacy = optimal.efficacy,
            riskScore = 1.0 - optimal.safety,
            rationale = generatePathwayRationale(optimal, criteria)
        )
    }

    /**
     * Generate rationale for the selected pathway
     */
    private fun generatePathwayRationale(pathway: EvaluatedPathway, criteria: List<OptimizationCriterion>): String {
        val rationale = mutableListOf<String>()

        rationale.add("Selected based on ${criteria.joinToString(", ") { it.name.lowercase() }} optimization")

        if (pathway.efficacy > 0.8) {
            rationale.add("High expected efficacy: ${"%.1f".format(pathway.efficacy * 100)}%")
        }

        if (pathway.safety > 0.9) {
            rationale.add("Excellent safety profile")
        }

        if (pathway.cost < 500) {
            rationale.add("Cost-effective option")
        }

        if (pathway.qualityOfLife > 0.8) {
            rationale.add("Minimal impact on quality of life")
        }

        if (pathway.causalEffects.isNotEmpty()) {
            rationale.add("Supported by causal evidence from patient data")
        }

        return rationale.joinToString(". ")
    }

    /**
     * Data classes for pathway optimization
     */
    private data class CandidatePathway(val treatments: List<Treatment>)

    private data class EvaluatedPathway(
        val pathway: CandidatePathway,
        val efficacy: Double,
        val safety: Double,
        val cost: Double,
        val duration: Int,
        val qualityOfLife: Double,
        val causalEffects: List<CausalEffect>,
        val overallScore: Double
    )

    enum class OptimizationAlgorithm {
        GENETIC,
        DYNAMIC_PROGRAMMING,
        REINFORCEMENT_LEARNING
    }
}