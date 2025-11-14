package com.automed.ai.causal

import com.automed.ai.dto.CausalDataPoint
import org.apache.commons.math3.distribution.BetaDistribution
import org.apache.commons.math3.distribution.NormalDistribution
import kotlin.math.ln
import kotlin.math.exp
import kotlin.math.max
import kotlin.math.min

/**
 * Bayesian Network for uncertainty handling in causal relationships
 * Provides probabilistic inference and uncertainty quantification
 */
class BayesianNetwork(
    private val variables: List<String>,
    private val structure: Map<String, List<String>>, // parent -> children mapping
    private val conditionalProbabilities: Map<String, ConditionalProbabilityTable>
) {

    private val priorDistributions = mutableMapOf<String, ProbabilityDistribution>()
    private val posteriorDistributions = mutableMapOf<String, ProbabilityDistribution>()

    init {
        initializeDistributions()
        validateNetwork()
    }

    /**
     * Initialize prior distributions for all variables
     */
    private fun initializeDistributions() {
        variables.forEach { variable ->
            when {
                variable.contains("probability") || variable.contains("risk") -> {
                    // Beta distribution for probabilities (0-1 range)
                    priorDistributions[variable] = ProbabilityDistribution.Beta(1.0, 1.0) // Uniform prior
                }
                variable.contains("effect") || variable.contains("impact") -> {
                    // Normal distribution for effects
                    priorDistributions[variable] = ProbabilityDistribution.Normal(0.0, 1.0)
                }
                else -> {
                    // Default normal distribution
                    priorDistributions[variable] = ProbabilityDistribution.Normal(0.0, 1.0)
                }
            }
        }
    }

    /**
     * Validate network structure and probabilities
     */
    private fun validateNetwork() {
        // Check that all variables in structure are defined
        structure.keys.forEach { parent ->
            require(variables.contains(parent)) { "Unknown variable in structure: $parent" }
        }

        structure.values.flatten().forEach { child ->
            require(variables.contains(child)) { "Unknown variable in structure: $child" }
        }

        // Check conditional probability tables
        conditionalProbabilities.keys.forEach { variable ->
            require(variables.contains(variable)) { "CPT defined for unknown variable: $variable" }
        }

        // Check for cycles (simplified check)
        val visited = mutableSetOf<String>()
        val recursionStack = mutableSetOf<String>()

        fun hasCycle(node: String): Boolean {
            if (recursionStack.contains(node)) return true
            if (visited.contains(node)) return false

            visited.add(node)
            recursionStack.add(node)

            val children = structure[node] ?: emptyList()
            for (child in children) {
                if (hasCycle(child)) return true
            }

            recursionStack.remove(node)
            return false
        }

        variables.forEach { variable ->
            if (hasCycle(variable)) {
                throw IllegalArgumentException("Bayesian network contains cycles")
            }
        }
    }

    /**
     * Perform probabilistic inference
     */
    fun performInference(
        evidence: Map<String, Any>,
        queryVariables: List<String>,
        data: List<CausalDataPoint>
    ): InferenceResult {
        // Update beliefs with evidence
        updateBeliefs(evidence, data)

        // Compute posterior distributions for query variables
        val posteriors = mutableMapOf<String, ProbabilityDistribution>()
        val marginals = mutableMapOf<String, Double>()

        queryVariables.forEach { variable ->
            posteriors[variable] = posteriorDistributions[variable]
                ?: priorDistributions[variable]
                ?: ProbabilityDistribution.Normal(0.0, 1.0)

            marginals[variable] = calculateMarginalProbability(variable, evidence)
        }

        // Calculate joint probabilities
        val jointProbabilities = calculateJointProbabilities(queryVariables, evidence)

        // Compute uncertainty measures
        val uncertainties = calculateUncertaintyMeasures(posteriors)

        return InferenceResult(
            posteriorDistributions = posteriors,
            marginalProbabilities = marginals,
            jointProbabilities = jointProbabilities,
            uncertainties = uncertainties,
            evidenceStrength = calculateEvidenceStrength(evidence, data)
        )
    }

    /**
     * Update beliefs using evidence and data
     */
    private fun updateBeliefs(evidence: Map<String, Any>, data: List<CausalDataPoint>) {
        variables.forEach { variable ->
            val prior = priorDistributions[variable] ?: return@forEach

            // Incorporate evidence
            val likelihood = calculateLikelihood(variable, evidence, data)
            val posterior = updateDistribution(prior, likelihood, data.size)

            posteriorDistributions[variable] = posterior
        }
    }

    /**
     * Calculate likelihood of evidence given variable
     */
    private fun calculateLikelihood(
        variable: String,
        evidence: Map<String, Any>,
        data: List<CausalDataPoint>
    ): Double {
        val relevantData = data.filter { point ->
            evidence.all { (key, value) ->
                point.variables[key] == value
            }
        }

        if (relevantData.isEmpty()) return 0.5 // Neutral likelihood

        // Calculate empirical likelihood
        val variableValues = relevantData.mapNotNull { it.variables[variable] }
        if (variableValues.isEmpty()) return 0.5

        // For binary outcomes, calculate proportion
        val positiveOutcomes = variableValues.count { value ->
            when (value) {
                is Number -> value.toDouble() > 0.5
                is Boolean -> value
                else -> value.toString().toLowerCase() in listOf("true", "yes", "positive")
            }
        }

        return positiveOutcomes.toDouble() / variableValues.size
    }

    /**
     * Update distribution using Bayesian updating
     */
    private fun updateDistribution(
        prior: ProbabilityDistribution,
        likelihood: Double,
        sampleSize: Int
    ): ProbabilityDistribution {
        return when (prior) {
            is ProbabilityDistribution.Beta -> {
                // Beta-Binomial updating
                val alpha = prior.alpha + likelihood * sampleSize
                val beta = prior.beta + (1.0 - likelihood) * sampleSize
                ProbabilityDistribution.Beta(alpha, beta)
            }
            is ProbabilityDistribution.Normal -> {
                // Normal-Normal updating (simplified)
                val precision = 1.0 / (prior.variance * prior.variance)
                val newPrecision = precision + sampleSize.toDouble()
                val newMean = (prior.mean * precision + likelihood * sampleSize) / newPrecision
                val newVariance = 1.0 / sqrt(newPrecision)
                ProbabilityDistribution.Normal(newMean, newVariance)
            }
        }
    }

    /**
     * Calculate marginal probability for a variable
     */
    private fun calculateMarginalProbability(variable: String, evidence: Map<String, Any>): Double {
        val cpt = conditionalProbabilities[variable]
        if (cpt != null) {
            return cpt.getProbability(evidence)
        }

        // Fallback to posterior mean
        val posterior = posteriorDistributions[variable]
        return when (posterior) {
            is ProbabilityDistribution.Beta -> posterior.alpha / (posterior.alpha + posterior.beta)
            is ProbabilityDistribution.Normal -> posterior.mean
            else -> 0.5
        }
    }

    /**
     * Calculate joint probabilities for multiple variables
     */
    private fun calculateJointProbabilities(
        variables: List<String>,
        evidence: Map<String, Any>
    ): Map<String, Double> {
        val joints = mutableMapOf<String, Double>()

        // Calculate pairwise joint probabilities
        for (i in variables.indices) {
            for (j in i + 1 until variables.size) {
                val var1 = variables[i]
                val var2 = variables[j]
                val key = "${var1}_${var2}"

                val prob1 = calculateMarginalProbability(var1, evidence)
                val prob2 = calculateMarginalProbability(var2, evidence)

                // Simplified joint probability (assumes independence given evidence)
                val joint = prob1 * prob2

                // Adjust for dependencies if CPTs are available
                val adjustedJoint = adjustForDependencies(var1, var2, joint, evidence)
                joints[key] = adjustedJoint
            }
        }

        return joints
    }

    /**
     * Adjust joint probability for dependencies
     */
    private fun adjustForDependencies(
        var1: String,
        var2: String,
        independentJoint: Double,
        evidence: Map<String, Any>
    ): Double {
        // Check if there's a direct causal relationship
        val parents1 = structure.filter { it.value.contains(var1) }.keys
        val parents2 = structure.filter { it.value.contains(var2) }.keys

        // If one is parent of the other, they're dependent
        val dependent = parents1.contains(var2) || parents2.contains(var1)

        return if (dependent) {
            // Use conditional probability
            val cpt1 = conditionalProbabilities[var1]
            val cpt2 = conditionalProbabilities[var2]

            when {
                cpt1 != null && parents1.contains(var2) -> {
                    val conditionalProb = cpt1.getProbability(evidence + (var2 to true))
                    conditionalProb * calculateMarginalProbability(var2, evidence)
                }
                cpt2 != null && parents2.contains(var1) -> {
                    val conditionalProb = cpt2.getProbability(evidence + (var1 to true))
                    conditionalProb * calculateMarginalProbability(var1, evidence)
                }
                else -> independentJoint * 0.8 // Slight dependency adjustment
            }
        } else {
            independentJoint
        }
    }

    /**
     * Calculate uncertainty measures for distributions
     */
    private fun calculateUncertaintyMeasures(
        distributions: Map<String, ProbabilityDistribution>
    ): Map<String, UncertaintyMeasure> {
        val measures = mutableMapOf<String, UncertaintyMeasure>()

        distributions.forEach { (variable, distribution) ->
            val measure = when (distribution) {
                is ProbabilityDistribution.Beta -> {
                    val mean = distribution.alpha / (distribution.alpha + distribution.beta)
                    val variance = (distribution.alpha * distribution.beta) /
                        ((distribution.alpha + distribution.beta).pow(2) * (distribution.alpha + distribution.beta + 1))
                    val entropy = calculateBetaEntropy(distribution.alpha, distribution.beta)

                    UncertaintyMeasure(
                        variance = variance,
                        entropy = entropy,
                        confidenceInterval = calculateBetaConfidenceInterval(distribution),
                        uncertaintyLevel = classifyUncertainty(variance)
                    )
                }
                is ProbabilityDistribution.Normal -> {
                    val entropy = 0.5 * ln(2 * Math.PI * Math.E * distribution.variance)
                    val confidenceInterval = calculateNormalConfidenceInterval(distribution)

                    UncertaintyMeasure(
                        variance = distribution.variance,
                        entropy = entropy,
                        confidenceInterval = confidenceInterval,
                        uncertaintyLevel = classifyUncertainty(distribution.variance)
                    )
                }
            }

            measures[variable] = measure
        }

        return measures
    }

    /**
     * Calculate entropy for Beta distribution
     */
    private fun calculateBetaEntropy(alpha: Double, beta: Double): Double {
        val total = alpha + beta
        val digammaAlpha = digamma(alpha)
        val digammaBeta = digamma(beta)
        val digammaTotal = digamma(total)

        return (alpha - 1) * digammaAlpha +
               (beta - 1) * digammaBeta -
               (total - 1) * digammaTotal +
               lnBeta(alpha, beta)
    }

    /**
     * Digamma function approximation
     */
    private fun digamma(x: Double): Double {
        // Simplified digamma approximation
        return ln(x) - 1.0 / (2.0 * x) - 1.0 / (12.0 * x * x)
    }

    /**
     * Log Beta function
     */
    private fun lnBeta(alpha: Double, beta: Double): Double {
        // Using approximation
        return lnGamma(alpha) + lnGamma(beta) - lnGamma(alpha + beta)
    }

    /**
     * Log Gamma function approximation
     */
    private fun lnGamma(x: Double): Double {
        // Stirling's approximation
        return (x - 0.5) * ln(x) - x + 0.5 * ln(2 * Math.PI)
    }

    /**
     * Calculate confidence interval for Beta distribution
     */
    private fun calculateBetaConfidenceInterval(distribution: ProbabilityDistribution.Beta): Pair<Double, Double> {
        val betaDist = BetaDistribution(distribution.alpha, distribution.beta)
        val lower = betaDist.inverseCumulativeProbability(0.025)
        val upper = betaDist.inverseCumulativeProbability(0.975)
        return Pair(lower, upper)
    }

    /**
     * Calculate confidence interval for Normal distribution
     */
    private fun calculateNormalConfidenceInterval(distribution: ProbabilityDistribution.Normal): Pair<Double, Double> {
        val normalDist = NormalDistribution(distribution.mean, distribution.variance)
        val lower = normalDist.inverseCumulativeProbability(0.025)
        val upper = normalDist.inverseCumulativeProbability(0.975)
        return Pair(lower, upper)
    }

    /**
     * Classify uncertainty level
     */
    private fun classifyUncertainty(variance: Double): UncertaintyLevel {
        return when {
            variance < 0.1 -> UncertaintyLevel.LOW
            variance < 0.5 -> UncertaintyLevel.MEDIUM
            else -> UncertaintyLevel.HIGH
        }
    }

    /**
     * Calculate evidence strength
     */
    private fun calculateEvidenceStrength(evidence: Map<String, Any>, data: List<CausalDataPoint>): Double {
        val relevantDataPoints = data.count { point ->
            evidence.all { (key, value) ->
                point.variables[key] == value
            }
        }

        return min(1.0, relevantDataPoints.toDouble() / data.size)
    }

    /**
     * Predict outcomes with uncertainty quantification
     */
    fun predictWithUncertainty(
        input: Map<String, Any>,
        targetVariable: String,
        data: List<CausalDataPoint>
    ): PredictionWithUncertainty {
        val inference = performInference(input, listOf(targetVariable), data)

        val posterior = inference.posteriorDistributions[targetVariable]
        val uncertainty = inference.uncertainties[targetVariable]

        val prediction = when (posterior) {
            is ProbabilityDistribution.Beta -> {
                posterior.alpha / (posterior.alpha + posterior.beta)
            }
            is ProbabilityDistribution.Normal -> posterior.mean
            else -> 0.5
        }

        return PredictionWithUncertainty(
            predictedValue = prediction,
            uncertainty = uncertainty ?: UncertaintyMeasure(
                variance = 1.0,
                entropy = 1.0,
                confidenceInterval = Pair(0.0, 1.0),
                uncertaintyLevel = UncertaintyLevel.HIGH
            ),
            confidence = inference.evidenceStrength,
            predictionInterval = uncertainty?.confidenceInterval ?: Pair(0.0, 1.0)
        )
    }

    /**
     * Data classes and enums
     */
    sealed class ProbabilityDistribution {
        data class Beta(val alpha: Double, val beta: Double) : ProbabilityDistribution()
        data class Normal(val mean: Double, val variance: Double) : ProbabilityDistribution()
    }

    data class ConditionalProbabilityTable(
        val variable: String,
        val parents: List<String>,
        val probabilities: Map<String, Double> // key format: "parent1=value1,parent2=value2" -> probability
    ) {
        fun getProbability(evidence: Map<String, Any>): Double {
            val key = parents.joinToString(",") { parent ->
                val value = evidence[parent]?.toString() ?: "unknown"
                "$parent=$value"
            }

            return probabilities[key] ?: probabilities["default"] ?: 0.5
        }
    }

    data class InferenceResult(
        val posteriorDistributions: Map<String, ProbabilityDistribution>,
        val marginalProbabilities: Map<String, Double>,
        val jointProbabilities: Map<String, Double>,
        val uncertainties: Map<String, UncertaintyMeasure>,
        val evidenceStrength: Double
    )

    data class UncertaintyMeasure(
        val variance: Double,
        val entropy: Double,
        val confidenceInterval: Pair<Double, Double>,
        val uncertaintyLevel: UncertaintyLevel
    )

    data class PredictionWithUncertainty(
        val predictedValue: Double,
        val uncertainty: UncertaintyMeasure,
        val confidence: Double,
        val predictionInterval: Pair<Double, Double>
    )

    enum class UncertaintyLevel {
        LOW, MEDIUM, HIGH
    }
}