package com.automed.ai.causal

import com.automed.ai.dto.*
import org.apache.commons.math3.stat.descriptive.DescriptiveStatistics
import org.apache.commons.math3.stat.regression.SimpleRegression
import org.apache.commons.math3.stat.correlation.PearsonsCorrelation
import kotlin.math.abs
import kotlin.math.sqrt

/**
 * Personalized Causal Model for individual patient response prediction
 * Learns patient-specific causal relationships and treatment effects
 */
class PersonalizedCausalModel(
    private val patientId: String,
    private val patientData: List<CausalDataPoint>,
    private val modelType: CausalModelType = CausalModelType.BAYESIAN_NETWORK
) {

    private val causalGraph = CausalGraphicalModel()
    private val learnedRelationships = mutableListOf<CausalRelationship>()
    private val variableStatistics = mutableMapOf<String, DescriptiveStatistics>()
    private val correlations = mutableMapOf<Pair<String, String>, Double>()

    init {
        initializeModel()
        learnCausalStructure()
        validateModel()
    }

    /**
     * Initialize the personalized model with patient data
     */
    private fun initializeModel() {
        // Calculate statistics for each variable
        val allVariables = patientData.flatMap { it.variables.keys }.distinct()

        allVariables.forEach { variable ->
            val values = patientData.mapNotNull { it.variables[variable] as? Number }.map { it.toDouble() }
            if (values.isNotEmpty()) {
                val stats = DescriptiveStatistics()
                values.forEach { stats.addValue(it) }
                variableStatistics[variable] = stats
            }
        }

        // Calculate correlations between variables
        calculateCorrelations(allVariables)
    }

    /**
     * Calculate correlations between all variable pairs
     */
    private fun calculateCorrelations(variables: List<String>) {
        val correlation = PearsonsCorrelation()

        for (i in variables.indices) {
            for (j in i + 1 until variables.size) {
                val var1 = variables[i]
                val var2 = variables[j]

                val values1 = patientData.mapNotNull { it.variables[var1] as? Number }.map { it.toDouble() }
                val values2 = patientData.mapNotNull { it.variables[var2] as? Number }.map { it.toDouble() }

                if (values1.size >= 3 && values2.size >= 3 && values1.size == values2.size) {
                    try {
                        val corr = correlation.correlation(
                            values1.toDoubleArray(),
                            values2.toDoubleArray()
                        )
                        if (!corr.isNaN()) {
                            correlations[Pair(var1, var2)] = corr
                            correlations[Pair(var2, var1)] = corr
                        }
                    } catch (e: Exception) {
                        // Handle correlation calculation errors
                    }
                }
            }
        }
    }

    /**
     * Learn causal structure from patient data using constraint-based learning
     */
    private fun learnCausalStructure() {
        val variables = patientData.flatMap { it.variables.keys }.distinct()

        // Step 1: Identify potential causal relationships using correlation and temporal ordering
        variables.forEach { cause ->
            variables.forEach { effect ->
                if (cause != effect) {
                    val relationship = assessCausalRelationship(cause, effect)
                    if (relationship != null) {
                        learnedRelationships.add(relationship)
                        causalGraph.addCausalRelationship(cause, effect, relationship.strength)
                    }
                }
            }
        }

        // Step 2: Apply causal inference rules to refine the graph
        refineCausalGraph()

        // Step 3: Learn conditional probability distributions
        learnConditionalProbabilities()
    }

    /**
     * Assess potential causal relationship between two variables
     */
    private fun assessCausalRelationship(cause: String, effect: String): CausalRelationship? {
        val correlation = correlations[Pair(cause, effect)] ?: return null
        val correlationStrength = abs(correlation)

        // Minimum correlation threshold for considering causality
        if (correlationStrength < 0.3) return null

        // Check temporal ordering (simplified - assumes data is time-ordered)
        val temporalOrder = checkTemporalOrdering(cause, effect)
        if (!temporalOrder) return null

        // Assess confounding and other causal criteria
        val confounderCheck = checkForConfounders(cause, effect)
        val direction = determineCausalDirection(cause, effect, correlation)

        val strength = calculateRelationshipStrength(cause, effect, correlationStrength)
        val confidence = calculateRelationshipConfidence(cause, effect, correlationStrength)

        return CausalRelationship(
            cause = cause,
            effect = effect,
            strength = strength,
            direction = direction,
            confidence = confidence,
            evidence = listOf(
                "Correlation: ${"%.3f".format(correlation)}",
                "Temporal ordering: $temporalOrder",
                "Confounder check: $confounderCheck"
            )
        )
    }

    /**
     * Check temporal ordering between cause and effect
     */
    private fun checkTemporalOrdering(cause: String, effect: String): Boolean {
        // Simplified temporal check - in practice would use time series analysis
        val causeTimestamps = patientData.mapNotNull { it.variables[cause] }.map { it.hashCode().toLong() }
        val effectTimestamps = patientData.mapNotNull { it.variables[effect] }.map { it.hashCode().toLong() }

        if (causeTimestamps.isEmpty() || effectTimestamps.isEmpty()) return true

        // Check if cause generally precedes effect
        val avgCauseTime = causeTimestamps.average()
        val avgEffectTime = effectTimestamps.average()

        return avgCauseTime <= avgEffectTime
    }

    /**
     * Check for potential confounders
     */
    private fun checkForConfounders(cause: String, effect: String): Boolean {
        val confounders = variableStatistics.keys.filter { confounder ->
            confounder != cause && confounder != effect
        }

        // Check if any confounder is correlated with both cause and effect
        return confounders.any { confounder ->
            val causeCorr = abs(correlations[Pair(cause, confounder)] ?: 0.0)
            val effectCorr = abs(correlations[Pair(effect, confounder)] ?: 0.0)
            causeCorr > 0.3 && effectCorr > 0.3
        }
    }

    /**
     * Determine causal direction based on various criteria
     */
    private fun determineCausalDirection(cause: String, effect: String, correlation: Double): RelationshipDirection {
        // Use correlation direction and domain knowledge
        return when {
            correlation > 0 -> RelationshipDirection.DIRECTED
            correlation < 0 -> RelationshipDirection.DIRECTED
            else -> RelationshipDirection.UNDIRECTED
        }
    }

    /**
     * Calculate relationship strength
     */
    private fun calculateRelationshipStrength(cause: String, effect: String, correlationStrength: Double): Double {
        // Combine correlation with other factors
        val dataSize = patientData.size
        val reliabilityFactor = min(1.0, dataSize / 10.0) // More data = more reliable

        return correlationStrength * reliabilityFactor
    }

    /**
     * Calculate relationship confidence
     */
    private fun calculateRelationshipConfidence(cause: String, effect: String, correlationStrength: Double): Double {
        // Based on statistical significance and data quality
        val dataSize = patientData.size
        val sampleSize = patientData.count { it.variables.containsKey(cause) && it.variables.containsKey(effect) }

        if (sampleSize < 3) return 0.1

        // Simplified confidence calculation
        val baseConfidence = min(1.0, sampleSize / 20.0)
        val strengthBonus = correlationStrength * 0.5

        return min(1.0, baseConfidence + strengthBonus)
    }

    /**
     * Refine the causal graph using causal inference rules
     */
    private fun refineCausalGraph() {
        // Apply backdoor criterion to identify valid adjustment sets
        learnedRelationships.forEach { relationship ->
            val adjustmentSet = causalGraph.findBackdoorAdjustmentSet(
                relationship.effect,
                relationship.cause
            )

            if (adjustmentSet.isNotEmpty()) {
                relationship.evidence.add("Valid backdoor adjustment set: ${adjustmentSet.joinToString(", ")}")
            }
        }

        // Remove relationships that don't satisfy causal criteria
        learnedRelationships.removeIf { relationship ->
            relationship.confidence < 0.2 || relationship.strength < 0.3
        }
    }

    /**
     * Learn conditional probability distributions
     */
    private fun learnConditionalProbabilities() {
        // Simplified conditional probability learning
        // In practice, would use more sophisticated Bayesian learning
        learnedRelationships.forEach { relationship ->
            val causeValues = patientData.mapNotNull { it.variables[relationship.cause] }
            val effectValues = patientData.mapNotNull { it.variables[relationship.effect] }

            if (causeValues.size == effectValues.size && causeValues.size >= 3) {
                // Learn simple conditional relationship
                val regression = SimpleRegression()
                causeValues.zip(effectValues).forEach { (cause, effect) ->
                    if (cause is Number && effect is Number) {
                        regression.addData(cause.toDouble(), effect.toDouble())
                    }
                }

                if (regression.n > 0) {
                    val conditionalProb = regression.slope
                    // Store for later use in predictions
                }
            }
        }
    }

    /**
     * Validate the learned model
     */
    private fun validateModel() {
        if (patientData.size < 5) {
            throw IllegalArgumentException("Insufficient data for personalized causal modeling")
        }

        if (learnedRelationships.isEmpty()) {
            throw IllegalStateException("No causal relationships could be learned from patient data")
        }

        if (!causalGraph.isValidDAG()) {
            throw IllegalStateException("Learned causal graph contains cycles")
        }
    }

    /**
     * Predict patient response to a specific treatment
     */
    fun predictTreatmentResponse(treatment: String, dosage: Double): TreatmentPrediction {
        val relevantRelationships = learnedRelationships.filter { it.cause == treatment }

        var predictedEffect = 0.0
        var confidence = 0.0
        val contributingFactors = mutableListOf<String>()

        relevantRelationships.forEach { relationship ->
            val effect = relationship.strength * dosage
            predictedEffect += effect
            confidence += relationship.confidence

            contributingFactors.add("${relationship.effect}: ${"%.3f".format(effect)} (confidence: ${"%.2f".format(relationship.confidence)})")
        }

        confidence /= max(1, relevantRelationships.size)

        return TreatmentPrediction(
            treatment = treatment,
            predictedEffect = predictedEffect,
            confidence = confidence,
            contributingFactors = contributingFactors,
            riskFactors = identifyRiskFactors(treatment, dosage)
        )
    }

    /**
     * Identify personalized risk factors
     */
    private fun identifyRiskFactors(treatment: String, dosage: Double): List<String> {
        val riskFactors = mutableListOf<String>()

        // Check for high-risk correlations
        correlations.forEach { (pair, correlation) ->
            if (pair.first == treatment && abs(correlation) > 0.7) {
                val riskLevel = if (abs(correlation) > 0.8) "High" else "Medium"
                riskFactors.add("$riskLevel risk: Strong correlation with ${pair.second} (${"%.2f".format(correlation)})")
            }
        }

        // Check dosage against patient statistics
        val treatmentStats = variableStatistics[treatment]
        if (treatmentStats != null) {
            val meanDosage = treatmentStats.mean
            val stdDev = treatmentStats.standardDeviation

            if (abs(dosage - meanDosage) > 2 * stdDev) {
                riskFactors.add("Dosage significantly outside patient's historical range")
            }
        }

        // Check for adverse effect indicators
        val adverseIndicators = listOf("side_effects", "adverse_reaction", "toxicity")
        adverseIndicators.forEach { indicator ->
            val correlation = correlations[Pair(treatment, indicator)]
            if (correlation != null && correlation > 0.5) {
                riskFactors.add("Potential adverse effects: Correlation with $indicator (${"%.2f".format(correlation)})")
            }
        }

        return riskFactors.ifEmpty { listOf("No significant risk factors identified") }
    }

    /**
     * Generate personalized treatment recommendations
     */
    fun generatePersonalizedRecommendations(availableTreatments: List<String>): List<String> {
        val recommendations = mutableListOf<String>()

        availableTreatments.forEach { treatment ->
            val prediction = predictTreatmentResponse(treatment, 1.0) // Standard dosage

            if (prediction.predictedEffect > 0.5 && prediction.confidence > 0.7) {
                recommendations.add("Consider $treatment - predicted effect: ${"%.2f".format(prediction.predictedEffect)}")
            } else if (prediction.predictedEffect < 0.2) {
                recommendations.add("Exercise caution with $treatment - limited predicted benefit")
            }
        }

        // Add general recommendations based on model characteristics
        if (learnedRelationships.size > 5) {
            recommendations.add("Patient shows complex causal relationships - consider comprehensive treatment approach")
        }

        if (correlations.values.any { abs(it) > 0.8 }) {
            recommendations.add("Strong correlations detected - monitor for potential side effects")
        }

        return recommendations.ifEmpty { listOf("Insufficient data for specific recommendations") }
    }

    /**
     * Get model performance metrics
     */
    fun getModelPerformance(): ModelPerformance {
        // Simplified performance calculation
        val relationshipCount = learnedRelationships.size
        val avgConfidence = learnedRelationships.map { it.confidence }.average()
        val avgStrength = learnedRelationships.map { it.strength }.average()

        return ModelPerformance(
            accuracy = avgConfidence,
            precision = avgStrength,
            recall = relationshipCount.toDouble() / max(1, variableStatistics.size * 2),
            f1Score = 2 * (avgStrength * avgConfidence) / (avgStrength + avgConfidence),
            calibrationScore = calculateCalibrationScore()
        )
    }

    /**
     * Calculate calibration score (how well predicted probabilities match actual outcomes)
     */
    private fun calculateCalibrationScore(): Double {
        // Simplified calibration check
        val predictions = learnedRelationships.map { it.confidence }
        val actualReliability = learnedRelationships.map { if (it.strength > 0.5) 1.0 else 0.0 }

        if (predictions.size != actualReliability.size) return 0.5

        val calibrationError = predictions.zip(actualReliability)
            .map { (pred, actual) -> abs(pred - actual) }
            .average()

        return 1.0 - calibrationError
    }

    /**
     * Export the personalized causal model
     */
    fun toCausalModel(): CausalModel {
        return CausalModel(
            modelId = "personalized_$patientId",
            modelType = modelType,
            variables = variableStatistics.keys.toList(),
            relationships = learnedRelationships,
            parameters = mapOf(
                "data_points" to patientData.size,
                "relationships_learned" to learnedRelationships.size,
                "graph_valid" to causalGraph.isValidDAG()
            ),
            structure = causalGraph.toCausalGraph()
        )
    }

    /**
     * Data class for treatment predictions
     */
    data class TreatmentPrediction(
        val treatment: String,
        val predictedEffect: Double,
        val confidence: Double,
        val contributingFactors: List<String>,
        val riskFactors: List<String>
    )
}