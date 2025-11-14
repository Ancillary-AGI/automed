package com.automed.ai.causal

import com.automed.ai.dto.*
import org.jgrapht.Graph
import org.jgrapht.graph.DefaultDirectedGraph
import org.jgrapht.graph.DefaultEdge
import org.jgrapht.alg.cycle.CycleDetector
import org.apache.commons.math3.stat.descriptive.DescriptiveStatistics
import org.apache.commons.math3.stat.regression.SimpleRegression
import kotlin.math.abs
import kotlin.math.sqrt

/**
 * Causal Graphical Model implementing do-calculus for causal inference
 * Based on Pearl's causal framework and do-operator semantics
 */
class CausalGraphicalModel(
    private val graph: Graph<String, DefaultEdge> = DefaultDirectedGraph(DefaultEdge::class.java)
) {

    private val variables = mutableSetOf<String>()
    private val interventions = mutableMapOf<String, Any>()
    private val conditionalProbabilities = mutableMapOf<String, MutableMap<String, Double>>()

    /**
     * Add a causal relationship to the graph
     */
    fun addCausalRelationship(cause: String, effect: String, strength: Double = 1.0) {
        variables.add(cause)
        variables.add(effect)
        graph.addVertex(cause)
        graph.addVertex(effect)
        graph.addEdge(cause, effect)

        // Store relationship strength for weighting
        val edge = graph.getEdge(cause, effect)
        if (edge != null) {
            // Note: DefaultEdge doesn't support attributes, we'd need custom edge class for strength
        }
    }

    /**
     * Check if the graph is a valid DAG (Directed Acyclic Graph)
     */
    fun isValidDAG(): Boolean {
        val cycleDetector = CycleDetector(graph)
        return !cycleDetector.detectCycles()
    }

    /**
     * Get all ancestors of a variable
     */
    fun getAncestors(variable: String): Set<String> {
        val ancestors = mutableSetOf<String>()
        val visited = mutableSetOf<String>()

        fun dfs(current: String) {
            if (current in visited) return
            visited.add(current)

            graph.incomingEdgesOf(current).forEach { edge ->
                val source = graph.getEdgeSource(edge)
                ancestors.add(source)
                dfs(source)
            }
        }

        dfs(variable)
        return ancestors
    }

    /**
     * Get all descendants of a variable
     */
    fun getDescendants(variable: String): Set<String> {
        val descendants = mutableSetOf<String>()
        val visited = mutableSetOf<String>()

        fun dfs(current: String) {
            if (current in visited) return
            visited.add(current)

            graph.outgoingEdgesOf(current).forEach { edge ->
                val target = graph.getEdgeTarget(edge)
                descendants.add(target)
                dfs(target)
            }
        }

        dfs(variable)
        return descendants
    }

    /**
     * Check if variables are d-connected (d-separated when conditioned on Z)
     */
    fun areDConnected(x: String, y: String, conditioned: Set<String> = emptySet()): Boolean {
        // Simplified d-connection check
        // In a full implementation, this would use proper d-separation algorithms
        val paths = findPaths(x, y)
        return paths.any { path -> isDConnectedPath(path, conditioned) }
    }

    /**
     * Find all paths between two variables
     */
    private fun findPaths(start: String, end: String): List<List<String>> {
        val paths = mutableListOf<List<String>>()
        val visited = mutableSetOf<String>()

        fun dfs(current: String, path: MutableList<String>) {
            if (current in visited) return
            visited.add(current)

            path.add(current)

            if (current == end) {
                paths.add(path.toList())
            } else {
                graph.outgoingEdgesOf(current).forEach { edge ->
                    val next = graph.getEdgeTarget(edge)
                    dfs(next, path)
                }
            }

            path.removeAt(path.size - 1)
            visited.remove(current)
        }

        dfs(start, mutableListOf())
        return paths
    }

    /**
     * Check if a path is d-connected given conditioning set
     */
    private fun isDConnectedPath(path: List<String>, conditioned: Set<String>): Boolean {
        if (path.size < 2) return false

        for (i in 0 until path.size - 1) {
            val current = path[i]
            val next = path[i + 1]

            // Check for colliders (variables with two incoming edges)
            if (i > 0 && i < path.size - 1) {
                val prev = path[i - 1]
                val incomingCount = graph.incomingEdgesOf(current).size
                if (incomingCount >= 2 && current !in conditioned) {
                    // Collider not conditioned - path is blocked
                    return false
                }
            }

            // Check for chains and forks
            if (current in conditioned) {
                // Conditioned variable blocks the path
                return false
            }
        }

        return true
    }

    /**
     * Apply do-operator: P(Y | do(X = x))
     * This is the fundamental operation in causal inference
     */
    fun applyDoOperator(
        outcome: String,
        intervention: String,
        interventionValue: Any,
        data: List<CausalDataPoint>
    ): Double {
        interventions[intervention] = interventionValue

        // Find adjustment set using backdoor criterion
        val adjustmentSet = findBackdoorAdjustmentSet(outcome, intervention)

        // Estimate causal effect using adjusted regression
        return estimateCausalEffect(outcome, intervention, adjustmentSet, data)
    }

    /**
     * Find backdoor adjustment set for deconfounding
     */
    fun findBackdoorAdjustmentSet(outcome: String, treatment: String): Set<String> {
        val ancestors = getAncestors(treatment)
        val confounders = mutableSetOf<String>()

        // Variables that affect both treatment and outcome
        ancestors.forEach { ancestor ->
            if (areDConnected(ancestor, outcome, setOf(treatment))) {
                confounders.add(ancestor)
            }
        }

        return confounders
    }

    /**
     * Estimate causal effect using statistical adjustment
     */
    private fun estimateCausalEffect(
        outcome: String,
        treatment: String,
        adjustmentSet: Set<String>,
        data: List<CausalDataPoint>
    ): Double {
        if (adjustmentSet.isEmpty()) {
            // Simple difference in means
            return calculateSimpleEffect(outcome, treatment, data)
        }

        // Use regression adjustment
        return calculateAdjustedEffect(outcome, treatment, adjustmentSet, data)
    }

    /**
     * Calculate simple treatment effect (no confounding adjustment)
     */
    private fun calculateSimpleEffect(
        outcome: String,
        treatment: String,
        data: List<CausalDataPoint>
    ): Double {
        val treatedOutcomes = mutableListOf<Double>()
        val controlOutcomes = mutableListOf<Double>()

        data.forEach { point ->
            val treatmentValue = point.variables[treatment] as? Number
            val outcomeValue = point.variables[outcome] as? Number

            if (treatmentValue != null && outcomeValue != null) {
                if (treatmentValue.toDouble() > 0) {
                    treatedOutcomes.add(outcomeValue.toDouble())
                } else {
                    controlOutcomes.add(outcomeValue.toDouble())
                }
            }
        }

        if (treatedOutcomes.isEmpty() || controlOutcomes.isEmpty()) {
            return 0.0
        }

        val treatedMean = treatedOutcomes.average()
        val controlMean = controlOutcomes.average()

        return treatedMean - controlMean
    }

    /**
     * Calculate adjusted treatment effect using regression
     */
    private fun calculateAdjustedEffect(
        outcome: String,
        treatment: String,
        adjustmentSet: Set<String>,
        data: List<CausalDataPoint>
    ): Double {
        // Simple implementation - in practice, would use more sophisticated methods
        val regression = SimpleRegression()

        data.forEach { point ->
            val treatmentValue = point.variables[treatment] as? Number ?: return@forEach
            val outcomeValue = point.variables[outcome] as? Number ?: return@forEach

            // Create regression input with treatment and confounders
            val predictors = mutableListOf(treatmentValue.toDouble())

            adjustmentSet.forEach { confounder ->
                val confounderValue = point.variables[confounder] as? Number
                if (confounderValue != null) {
                    predictors.add(confounderValue.toDouble())
                }
            }

            // For simplicity, use single predictor (treatment) with adjustment
            // In full implementation, would use multivariate regression
            regression.addData(treatmentValue.toDouble(), outcomeValue.toDouble())
        }

        return regression.slope
    }

    /**
     * Calculate total effect using front-door criterion if applicable
     */
    fun calculateTotalEffect(
        outcome: String,
        treatment: String,
        mediators: Set<String>,
        data: List<CausalDataPoint>
    ): Double {
        // Check if front-door criterion applies
        if (!satisfiesFrontDoorCriterion(outcome, treatment, mediators)) {
            return applyDoOperator(outcome, treatment, 1.0, data)
        }

        // Use front-door formula: P(Y|do(X)) = ∑_M P(M|X) * ∑_{X'} P(Y|M,X') * P(X')
        return calculateFrontDoorEffect(outcome, treatment, mediators, data)
    }

    /**
     * Check if front-door criterion is satisfied
     */
    private fun satisfiesFrontDoorCriterion(
        outcome: String,
        treatment: String,
        mediators: Set<String>
    ): Boolean {
        // Front-door criterion requires:
        // 1. Mediators block all paths from treatment to outcome
        // 2. No confounding of mediator-outcome relationship
        // 3. Treatment and outcome are independent given mediators

        val paths = findPaths(treatment, outcome)
        val allPathsBlocked = paths.all { path ->
            mediators.any { mediator -> mediator in path }
        }

        return allPathsBlocked && mediators.all { mediator ->
            // Check no confounding (simplified)
            !areDConnected(treatment, mediator, emptySet())
        }
    }

    /**
     * Calculate effect using front-door formula
     */
    private fun calculateFrontDoorEffect(
        outcome: String,
        treatment: String,
        mediators: Set<String>,
        data: List<CausalDataPoint>
    ): Double {
        // Simplified front-door calculation
        // In practice, this would involve complex probabilistic calculations

        var totalEffect = 0.0
        val treatmentValues = data.mapNotNull { it.variables[treatment] as? Number }.distinct()

        treatmentValues.forEach { treatmentVal ->
            mediators.forEach { mediator ->
                val mediatorProb = calculateConditionalProbability(mediator, treatment, treatmentVal.toDouble(), data)
                val outcomeProb = calculateConditionalProbability(outcome, mediator, 1.0, data) // Simplified
                totalEffect += mediatorProb * outcomeProb
            }
        }

        return totalEffect
    }

    /**
     * Calculate conditional probability P(Y|X)
     */
    private fun calculateConditionalProbability(
        outcome: String,
        condition: String,
        conditionValue: Double,
        data: List<CausalDataPoint>
    ): Double {
        val matchingData = data.filter { point ->
            val condValue = point.variables[condition] as? Number
            condValue != null && abs(condValue.toDouble() - conditionValue) < 0.01
        }

        if (matchingData.isEmpty()) return 0.0

        val outcomeValues = matchingData.mapNotNull { it.variables[outcome] as? Number }
        if (outcomeValues.isEmpty()) return 0.0

        return outcomeValues.map { it.toDouble() }.average()
    }

    /**
     * Calculate mediation effects (direct vs indirect)
     */
    fun calculateMediationEffects(
        outcome: String,
        treatment: String,
        mediator: String,
        data: List<CausalDataPoint>
    ): MediationEffects {
        val totalEffect = applyDoOperator(outcome, treatment, 1.0, data)
        val directEffect = calculateDirectEffect(outcome, treatment, mediator, data)
        val indirectEffect = totalEffect - directEffect

        return MediationEffects(
            totalEffect = totalEffect,
            directEffect = directEffect,
            indirectEffect = indirectEffect,
            proportionMediated = if (totalEffect != 0.0) indirectEffect / totalEffect else 0.0
        )
    }

    /**
     * Calculate direct effect (controlling for mediator)
     */
    private fun calculateDirectEffect(
        outcome: String,
        treatment: String,
        mediator: String,
        data: List<CausalDataPoint>
    ): Double {
        // Simplified direct effect calculation
        // In practice, would use more sophisticated methods
        return calculateAdjustedEffect(outcome, treatment, setOf(mediator), data)
    }

    /**
     * Get causal graph representation
     */
    fun toCausalGraph(): CausalGraph {
        val nodes = variables.map { variable ->
            CausalNode(
                id = variable,
                name = variable,
                type = determineNodeType(variable),
                properties = mapOf("intervened" to (variable in interventions))
            )
        }

        val edges = graph.edgeSet().map { edge ->
            CausalEdge(
                source = graph.getEdgeSource(edge),
                target = graph.getEdgeTarget(edge),
                edgeType = EdgeType.CAUSAL,
                strength = 1.0
            )
        }

        return CausalGraph(nodes = nodes, edges = edges)
    }

    /**
     * Determine node type based on causal role
     */
    private fun determineNodeType(variable: String): NodeType {
        return when {
            interventions.containsKey(variable) -> NodeType.TREATMENT
            // Simplified - in practice would analyze graph structure
            getDescendants(variable).isNotEmpty() -> NodeType.MEDIATOR
            else -> NodeType.OUTCOME
        }
    }

    /**
     * Reset interventions
     */
    fun resetInterventions() {
        interventions.clear()
    }

    /**
     * Data class for mediation analysis results
     */
    data class MediationEffects(
        val totalEffect: Double,
        val directEffect: Double,
        val indirectEffect: Double,
        val proportionMediated: Double
    )
}