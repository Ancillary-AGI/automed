package com.automed.ai.causal

import com.automed.ai.dto.*
import org.apache.commons.math3.stat.descriptive.DescriptiveStatistics
import org.apache.commons.math3.distribution.NormalDistribution
import kotlin.math.abs
import kotlin.math.max
import kotlin.math.min

/**
 * Counterfactual Reasoning Engine for "what if" treatment scenarios
 * Implements potential outcomes framework and nearest neighbor matching
 */
class CounterfactualReasoningEngine(
    private val causalModel: CausalGraphicalModel,
    private val historicalData: List<CausalDataPoint>
) {

    private val normalDistribution = NormalDistribution()

    /**
     * Generate counterfactual scenarios for a patient
     */
    fun generateCounterfactuals(request: CounterfactualRequest): CounterfactualResponse {
        val factualOutcome = simulateFactualOutcome(request.factualScenario)

        val counterfactualOutcomes = request.counterfactualScenarios.map { scenario ->
            simulateCounterfactualOutcome(scenario, request.factualScenario)
        }

        val causalContrasts = calculateCausalContrasts(
            factualOutcome,
            counterfactualOutcomes,
            request.outcomeVariables ?: listOf("outcome")
        )

        val whatIfAnalysis = performWhatIfAnalysis(
            factualOutcome,
            counterfactualOutcomes,
            causalContrasts
        )

        val recommendations = generateCounterfactualRecommendations(
            causalContrasts,
            whatIfAnalysis
        )

        return CounterfactualResponse(
            patientId = request.patientId,
            factualOutcome = factualOutcome,
            counterfactualOutcomes = counterfactualOutcomes,
            causalContrast = causalContrasts,
            whatIfAnalysis = whatIfAnalysis,
            recommendations = recommendations
        )
    }

    /**
     * Simulate the factual (observed) outcome
     */
    private fun simulateFactualOutcome(scenario: Scenario): ScenarioOutcome {
        val outcome = mutableMapOf<String, Any>()
        var totalProbability = 1.0
        var totalConfidence = 0.0
        val explanations = mutableListOf<String>()

        // Simulate outcomes based on current scenario
        scenario.variables.forEach { (variable, value) ->
            when (variable) {
                "treatment_dosage" -> {
                    val dosage = (value as? Number)?.toDouble() ?: 0.0
                    val efficacy = calculateTreatmentEfficacy(dosage, scenario.variables)
                    val sideEffects = calculateSideEffectRisk(dosage, scenario.variables)

                    outcome["efficacy"] = efficacy
                    outcome["side_effects"] = sideEffects
                    outcome["quality_of_life"] = max(0.0, 1.0 - sideEffects * 0.3)

                    totalProbability *= (0.8 + efficacy * 0.2)
                    totalConfidence += 0.9
                    explanations.add("Treatment dosage of ${dosage}mg predicted efficacy: ${"%.1f".format(efficacy * 100)}%")
                }
                "lifestyle_changes" -> {
                    val adherence = (value as? Number)?.toDouble() ?: 0.0
                    val lifestyleBenefit = adherence * 0.2

                    outcome["lifestyle_benefit"] = lifestyleBenefit
                    totalProbability *= (0.9 + adherence * 0.1)
                    totalConfidence += 0.8
                    explanations.add("Lifestyle adherence predicted additional benefit: ${"%.1f".format(lifestyleBenefit * 100)}%")
                }
                else -> {
                    // Generic outcome prediction
                    outcome[variable] = value
                }
            }
        }

        return ScenarioOutcome(
            scenarioId = "factual",
            outcome = outcome,
            probability = min(1.0, totalProbability),
            confidence = min(1.0, totalConfidence / max(1, scenario.variables.size)),
            explanation = explanations.joinToString("; ")
        )
    }

    /**
     * Simulate counterfactual outcome for alternative scenario
     */
    private fun simulateCounterfactualOutcome(
        counterfactualScenario: Scenario,
        factualScenario: Scenario
    ): ScenarioOutcome {
        val outcome = mutableMapOf<String, Any>()
        var totalProbability = 1.0
        var totalConfidence = 0.0
        val explanations = mutableListOf<String>()

        // Find similar patients using nearest neighbor matching
        val similarPatients = findSimilarPatients(counterfactualScenario, factualScenario)

        counterfactualScenario.variables.forEach { (variable, value) ->
            when (variable) {
                "treatment_dosage" -> {
                    val dosage = (value as? Number)?.toDouble() ?: 0.0
                    val factualDosage = (factualScenario.variables[variable] as? Number)?.toDouble() ?: 0.0

                    // Calculate counterfactual effect using causal model
                    val counterfactualEffect = causalModel.applyDoOperator(
                        "outcome",
                        "treatment_dosage",
                        dosage,
                        similarPatients
                    )

                    val factualEffect = causalModel.applyDoOperator(
                        "outcome",
                        "treatment_dosage",
                        factualDosage,
                        similarPatients
                    )

                    val relativeEffect = counterfactualEffect - factualEffect

                    outcome["counterfactual_efficacy"] = max(0.0, min(1.0, 0.5 + relativeEffect))
                    outcome["treatment_difference"] = relativeEffect

                    totalProbability *= (0.7 + abs(relativeEffect) * 0.3)
                    totalConfidence += 0.7
                    explanations.add("Counterfactual dosage change predicted effect difference: ${"%.3f".format(relativeEffect)}")
                }
                "alternative_treatment" -> {
                    val alternativeTreatment = value.toString()
                    val switchEffect = calculateTreatmentSwitchEffect(
                        alternativeTreatment,
                        factualScenario.variables["current_treatment"]?.toString() ?: "none",
                        similarPatients
                    )

                    outcome["switch_benefit"] = switchEffect
                    totalProbability *= (0.8 + abs(switchEffect) * 0.2)
                    totalConfidence += 0.75
                    explanations.add("Switching to $alternativeTreatment predicted benefit: ${"%.1f".format(switchEffect * 100)}%")
                }
                else -> {
                    // Use propensity score matching for other variables
                    val propensityScore = calculatePropensityScore(counterfactualScenario, similarPatients)
                    outcome["propensity_score"] = propensityScore
                    totalProbability *= propensityScore
                    totalConfidence += 0.6
                }
            }
        }

        return ScenarioOutcome(
            scenarioId = "counterfactual_${counterfactualScenario.hashCode()}",
            outcome = outcome,
            probability = min(1.0, totalProbability),
            confidence = min(1.0, totalConfidence / max(1, counterfactualScenario.variables.size)),
            explanation = explanations.joinToString("; ")
        )
    }

    /**
     * Find similar patients using nearest neighbor matching
     */
    private fun findSimilarPatients(
        counterfactualScenario: Scenario,
        factualScenario: Scenario
    ): List<CausalDataPoint> {
        val similarities = historicalData.map { dataPoint ->
            val similarity = calculateScenarioSimilarity(counterfactualScenario, dataPoint)
            dataPoint to similarity
        }.sortedByDescending { it.second }

        // Return top 10 most similar patients
        return similarities.take(10).map { it.first }
    }

    /**
     * Calculate similarity between scenario and historical data point
     */
    private fun calculateScenarioSimilarity(
        scenario: Scenario,
        dataPoint: CausalDataPoint
    ): Double {
        var totalSimilarity = 0.0
        var matchedVariables = 0

        scenario.variables.forEach { (variable, scenarioValue) ->
            val dataValue = dataPoint.variables[variable]
            if (dataValue != null) {
                val similarity = calculateVariableSimilarity(scenarioValue, dataValue, variable)
                totalSimilarity += similarity
                matchedVariables++
            }
        }

        return if (matchedVariables > 0) totalSimilarity / matchedVariables else 0.0
    }

    /**
     * Calculate similarity between two values for a specific variable
     */
    private fun calculateVariableSimilarity(value1: Any, value2: Any, variable: String): Double {
        return when {
            value1 is Number && value2 is Number -> {
                val v1 = value1.toDouble()
                val v2 = value2.toDouble()
                val diff = abs(v1 - v2)

                when (variable) {
                    "age" -> max(0.0, 1.0 - diff / 20.0) // Age similarity within 20 years
                    "treatment_dosage" -> max(0.0, 1.0 - diff / 100.0) // Dosage similarity
                    "blood_pressure" -> max(0.0, 1.0 - diff / 50.0) // BP similarity
                    else -> max(0.0, 1.0 - diff / 10.0) // Generic numeric similarity
                }
            }
            value1.toString() == value2.toString() -> 1.0
            else -> 0.5 // Partial match for categorical variables
        }
    }

    /**
     * Calculate treatment efficacy based on dosage and patient factors
     */
    private fun calculateTreatmentEfficacy(dosage: Double, patientFactors: Map<String, Any>): Double {
        var efficacy = min(1.0, dosage / 100.0) // Base efficacy

        // Adjust for patient factors
        val age = (patientFactors["age"] as? Number)?.toDouble() ?: 50.0
        val comorbidities = (patientFactors["comorbidities"] as? Number)?.toDouble() ?: 0.0

        // Age adjustment (younger patients may respond better)
        efficacy *= (1.0 - (age - 30.0) / 100.0).coerceIn(0.5, 1.5)

        // Comorbidity adjustment
        efficacy *= (1.0 - comorbidities * 0.1).coerceIn(0.3, 1.0)

        return efficacy.coerceIn(0.0, 1.0)
    }

    /**
     * Calculate side effect risk
     */
    private fun calculateSideEffectRisk(dosage: Double, patientFactors: Map<String, Any>): Double {
        var risk = dosage / 200.0 // Base risk

        val age = (patientFactors["age"] as? Number)?.toDouble() ?: 50.0
        val kidneyFunction = (patientFactors["kidney_function"] as? Number)?.toDouble() ?: 1.0

        // Age adjustment (older patients higher risk)
        risk *= (0.5 + (age - 20.0) / 100.0).coerceIn(0.5, 2.0)

        // Kidney function adjustment
        risk *= (2.0 - kidneyFunction).coerceIn(1.0, 3.0)

        return risk.coerceIn(0.0, 1.0)
    }

    /**
     * Calculate effect of switching treatments
     */
    private fun calculateTreatmentSwitchEffect(
        newTreatment: String,
        oldTreatment: String,
        similarPatients: List<CausalDataPoint>
    ): Double {
        if (newTreatment == oldTreatment) return 0.0

        // Find patients who switched from old to new treatment
        val switchers = similarPatients.filter { point ->
            point.interventions["treatment_switch"] == true &&
            point.variables["old_treatment"] == oldTreatment &&
            point.variables["new_treatment"] == newTreatment
        }

        if (switchers.isEmpty()) return 0.0

        // Calculate average outcome improvement
        val improvements = switchers.mapNotNull { patient ->
            val preSwitch = patient.variables["pre_switch_outcome"] as? Number
            val postSwitch = patient.variables["post_switch_outcome"] as? Number

            if (preSwitch != null && postSwitch != null) {
                postSwitch.toDouble() - preSwitch.toDouble()
            } else null
        }

        return if (improvements.isNotEmpty()) improvements.average() else 0.0
    }

    /**
     * Calculate propensity score for confounding adjustment
     */
    private fun calculatePropensityScore(
        scenario: Scenario,
        similarPatients: List<CausalDataPoint>
    ): Double {
        // Simplified propensity score calculation
        // In practice, would use logistic regression
        val matchingVariables = listOf("age", "gender", "comorbidities")
        var score = 1.0

        matchingVariables.forEach { variable ->
            val scenarioValue = scenario.variables[variable]
            if (scenarioValue != null) {
                val matches = similarPatients.count { patient ->
                    patient.variables[variable] == scenarioValue
                }
                val matchRate = matches.toDouble() / similarPatients.size
                score *= matchRate.coerceIn(0.1, 1.0)
            }
        }

        return score
    }

    /**
     * Calculate causal contrasts between factual and counterfactual outcomes
     */
    private fun calculateCausalContrasts(
        factual: ScenarioOutcome,
        counterfactuals: List<ScenarioOutcome>,
        outcomeVariables: List<String>
    ): List<CausalContrast> {
        val contrasts = mutableListOf<CausalContrast>()

        counterfactuals.forEach { counterfactual ->
            outcomeVariables.forEach { variable ->
                val factualValue = factual.outcome[variable] as? Number
                val counterfactualValue = counterfactual.outcome[variable] as? Number

                if (factualValue != null && counterfactualValue != null) {
                    val difference = counterfactualValue.toDouble() - factualValue.toDouble()
                    val significance = calculateStatisticalSignificance(
                        factualValue.toDouble(),
                        counterfactualValue.toDouble(),
                        historicalData.size
                    )

                    contrasts.add(CausalContrast(
                        factualValue = factualValue,
                        counterfactualValue = counterfactualValue,
                        difference = difference,
                        significance = significance,
                        variable = variable
                    ))
                }
            }
        }

        return contrasts
    }

    /**
     * Calculate statistical significance of difference
     */
    private fun calculateStatisticalSignificance(value1: Double, value2: Double, sampleSize: Int): Double {
        val diff = abs(value1 - value2)
        val stdDev = diff / 2.0 // Simplified standard deviation estimate

        if (stdDev == 0.0) return 1.0

        val zScore = diff / (stdDev / sqrt(sampleSize.toDouble()))
        return 1.0 - normalDistribution.cumulativeProbability(-abs(zScore)) * 2 // Two-tailed p-value
    }

    /**
     * Perform comprehensive "what if" analysis
     */
    private fun performWhatIfAnalysis(
        factual: ScenarioOutcome,
        counterfactuals: List<ScenarioOutcome>,
        contrasts: List<CausalContrast>
    ): WhatIfAnalysis {
        val keyInsights = mutableListOf<String>()
        val potentialBenefits = mutableListOf<String>()
        val potentialRisks = mutableListOf<String>()
        val actionableRecommendations = mutableListOf<String>()

        // Analyze contrasts for insights
        contrasts.groupBy { it.variable }.forEach { (variable, variableContrasts) ->
            val avgDifference = variableContrasts.map { it.difference }.average()
            val significantContrasts = variableContrasts.filter { it.significance < 0.05 }

            when (variable) {
                "efficacy" -> {
                    if (avgDifference > 0.1) {
                        keyInsights.add("Alternative scenarios show ${"%.1f".format(avgDifference * 100)}% higher efficacy")
                        potentialBenefits.add("Improved treatment outcomes possible")
                    } else if (avgDifference < -0.1) {
                        potentialRisks.add("Alternative scenarios may reduce efficacy by ${"%.1f".format(abs(avgDifference) * 100)}%")
                    }
                }
                "side_effects" -> {
                    if (avgDifference < -0.1) {
                        potentialBenefits.add("Reduced side effect risk in alternative scenarios")
                        actionableRecommendations.add("Consider alternative treatments to minimize side effects")
                    }
                }
                "quality_of_life" -> {
                    if (avgDifference > 0.05) {
                        keyInsights.add("Counterfactual scenarios suggest better quality of life outcomes")
                        potentialBenefits.add("Enhanced patient well-being possible")
                    }
                }
            }
        }

        // Add general insights
        if (counterfactuals.any { it.probability > factual.probability }) {
            keyInsights.add("Some counterfactual scenarios have higher success probabilities")
        }

        if (contrasts.any { it.significance < 0.01 }) {
            keyInsights.add("Statistically significant differences found in counterfactual analysis")
        }

        return WhatIfAnalysis(
            keyInsights = keyInsights.ifEmpty { listOf("No significant counterfactual differences identified") },
            potentialBenefits = potentialBenefits.ifEmpty { listOf("Current treatment appears optimal") },
            potentialRisks = potentialRisks.ifEmpty { listOf("Minimal additional risks identified") },
            actionableRecommendations = actionableRecommendations.ifEmpty {
                listOf("Continue monitoring current treatment effectiveness")
            }
        )
    }

    /**
     * Generate recommendations based on counterfactual analysis
     */
    private fun generateCounterfactualRecommendations(
        contrasts: List<CausalContrast>,
        analysis: WhatIfAnalysis
    ): List<String> {
        val recommendations = mutableListOf<String>()

        // Add insights-based recommendations
        analysis.actionableRecommendations.forEach { rec ->
            recommendations.add(rec)
        }

        // Add contrast-based recommendations
        val significantImprovements = contrasts.filter { it.difference > 0 && it.significance < 0.05 }
        val significantRisks = contrasts.filter { it.difference < 0 && it.significance < 0.05 }

        if (significantImprovements.isNotEmpty()) {
            recommendations.add("Consider implementing scenarios with significant improvements: ${
                significantImprovements.joinToString(", ") { it.variable }
            }")
        }

        if (significantRisks.isNotEmpty()) {
            recommendations.add("Avoid scenarios that may worsen outcomes: ${
                significantRisks.joinToString(", ") { it.variable }
            }")
        }

        // Add general recommendations
        recommendations.add("Use counterfactual analysis results to inform shared decision-making with patients")
        recommendations.add("Monitor patient response closely and re-evaluate if conditions change")

        return recommendations.distinct()
    }
}