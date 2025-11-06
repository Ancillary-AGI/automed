package com.automed.ai.service

import com.automed.ai.dto.*
import org.springframework.stereotype.Service
import kotlin.math.exp
import kotlin.math.ln
import kotlin.math.pow
import kotlin.math.sqrt
import kotlin.random.Random

@Service
class AdvancedMLService {

    /**
     * Advanced Machine Learning Algorithms for Healthcare
     */

    // Neural Network for Disease Prediction
    class NeuralNetwork(
        private val inputSize: Int,
        private val hiddenSize: Int,
        private val outputSize: Int,
        private val learningRate: Double = 0.01
    ) {
        private val weightsInputHidden = Array(inputSize) { DoubleArray(hiddenSize) { Random.nextDouble(-1.0, 1.0) } }
        private val weightsHiddenOutput = Array(hiddenSize) { DoubleArray(outputSize) { Random.nextDouble(-1.0, 1.0) } }
        private val biasHidden = DoubleArray(hiddenSize) { Random.nextDouble(-1.0, 1.0) }
        private val biasOutput = DoubleArray(outputSize) { Random.nextDouble(-1.0, 1.0) }

        fun forward(input: DoubleArray): DoubleArray {
            // Hidden layer
            val hidden = DoubleArray(hiddenSize) { i ->
                val sum = input.indices.sumOf { j -> input[j] * weightsInputHidden[j][i] } + biasHidden[i]
                sigmoid(sum)
            }

            // Output layer
            val output = DoubleArray(outputSize) { i ->
                val sum = hidden.indices.sumOf { j -> hidden[j] * weightsHiddenOutput[j][i] } + biasOutput[i]
                sigmoid(sum)
            }

            return output
        }

        fun train(input: DoubleArray, target: DoubleArray, epochs: Int = 1000) {
            repeat(epochs) {
                // Forward pass
                val hidden = DoubleArray(hiddenSize) { i ->
                    val sum = input.indices.sumOf { j -> input[j] * weightsInputHidden[j][i] } + biasHidden[i]
                    sigmoid(sum)
                }

                val output = DoubleArray(outputSize) { i ->
                    val sum = hidden.indices.sumOf { j -> hidden[j] * weightsHiddenOutput[j][i] } + biasOutput[i]
                    sigmoid(sum)
                }

                // Backward pass
                val outputErrors = DoubleArray(outputSize) { i -> target[i] - output[i] }
                val outputDeltas = DoubleArray(outputSize) { i ->
                    outputErrors[i] * sigmoidDerivative(output[i])
                }

                val hiddenErrors = DoubleArray(hiddenSize) { i ->
                    outputDeltas.indices.sumOf { j -> outputDeltas[j] * weightsHiddenOutput[i][j] }
                }
                val hiddenDeltas = DoubleArray(hiddenSize) { i ->
                    hiddenErrors[i] * sigmoidDerivative(hidden[i])
                }

                // Update weights and biases
                for (i in input.indices) {
                    for (j in hiddenSize.indices) {
                        weightsInputHidden[i][j] += learningRate * hiddenDeltas[j] * input[i]
                    }
                }

                for (i in hiddenSize.indices) {
                    for (j in outputSize.indices) {
                        weightsHiddenOutput[i][j] += learningRate * outputDeltas[j] * hidden[i]
                    }
                }

                for (i in hiddenSize.indices) {
                    biasHidden[i] += learningRate * hiddenDeltas[i]
                }

                for (i in outputSize.indices) {
                    biasOutput[i] += learningRate * outputDeltas[i]
                }
            }
        }

        private fun sigmoid(x: Double): Double = 1.0 / (1.0 + exp(-x))
        private fun sigmoidDerivative(x: Double): Double = x * (1.0 - x)
    }

    // Random Forest for Classification
    class RandomForest(
        private val numTrees: Int = 10,
        private val maxDepth: Int = 5,
        private val minSamplesSplit: Int = 2
    ) {
        private val trees = mutableListOf<DecisionTree>()

        fun train(features: List<DoubleArray>, labels: List<String>) {
            trees.clear()
            repeat(numTrees) {
                val tree = DecisionTree(maxDepth, minSamplesSplit)
                // Bootstrap sampling
                val indices = (0 until features.size).shuffled().take((features.size * 0.8).toInt())
                val sampleFeatures = indices.map { features[it] }
                val sampleLabels = indices.map { labels[it] }
                tree.train(sampleFeatures, sampleLabels)
                trees.add(tree)
            }
        }

        fun predict(features: DoubleArray): String {
            val predictions = trees.map { it.predict(features) }
            return predictions.groupBy { it }.maxByOrNull { it.value.size }?.key ?: "unknown"
        }

        fun predictProbability(features: DoubleArray): Map<String, Double> {
            val predictions = trees.map { it.predict(features) }
            val total = predictions.size.toDouble()
            return predictions.groupBy { it }.mapValues { it.value.size / total }
        }
    }

    // Decision Tree Node
    class DecisionTreeNode(
        val featureIndex: Int? = null,
        val threshold: Double? = null,
        val left: DecisionTreeNode? = null,
        val right: DecisionTreeNode? = null,
        val label: String? = null
    )

    // Decision Tree Implementation
    class DecisionTree(
        private val maxDepth: Int,
        private val minSamplesSplit: Int
    ) {
        private var root: DecisionTreeNode? = null

        fun train(features: List<DoubleArray>, labels: List<String>) {
            root = buildTree(features, labels, 0)
        }

        fun predict(features: DoubleArray): String {
            return predictRecursive(root, features) ?: "unknown"
        }

        private fun buildTree(
            features: List<DoubleArray>,
            labels: List<String>,
            depth: Int
        ): DecisionTreeNode? {
            if (depth >= maxDepth || features.size < minSamplesSplit ||
                labels.toSet().size == 1) {
                return DecisionTreeNode(label = labels.groupBy { it }.maxByOrNull { it.value.size }?.key)
            }

            val bestSplit = findBestSplit(features, labels)
            if (bestSplit == null) {
                return DecisionTreeNode(label = labels.groupBy { it }.maxByOrNull { it.value.size }?.key)
            }

            val (leftFeatures, leftLabels, rightFeatures, rightLabels) = splitData(
                features, labels, bestSplit.first, bestSplit.second
            )

            return DecisionTreeNode(
                featureIndex = bestSplit.first,
                threshold = bestSplit.second,
                left = buildTree(leftFeatures, leftLabels, depth + 1),
                right = buildTree(rightFeatures, rightLabels, depth + 1)
            )
        }

        private fun findBestSplit(
            features: List<DoubleArray>,
            labels: List<String>
        ): Pair<Int, Double>? {
            var bestGini = Double.MAX_VALUE
            var bestFeature = -1
            var bestThreshold = 0.0

            for (featureIndex in features[0].indices) {
                val values = features.map { it[featureIndex] }.sorted()
                for (i in 0 until values.size - 1) {
                    val threshold = (values[i] + values[i + 1]) / 2
                    val gini = calculateGiniForSplit(features, labels, featureIndex, threshold)
                    if (gini < bestGini) {
                        bestGini = gini
                        bestFeature = featureIndex
                        bestThreshold = threshold
                    }
                }
            }

            return if (bestFeature == -1) null else Pair(bestFeature, bestThreshold)
        }

        private fun calculateGiniForSplit(
            features: List<DoubleArray>,
            labels: List<String>,
            featureIndex: Int,
            threshold: Double
        ): Double {
            val (leftLabels, rightLabels) = splitData(features, labels, featureIndex, threshold)
                .let { Pair(it.second, it.fourth) }

            val totalSize = labels.size.toDouble()
            val leftSize = leftLabels.size.toDouble()
            val rightSize = rightLabels.size.toDouble()

            if (leftSize == 0.0 || rightSize == 0.0) return Double.MAX_VALUE

            val leftGini = calculateGini(leftLabels)
            val rightGini = calculateGini(rightLabels)

            return (leftSize / totalSize) * leftGini + (rightSize / totalSize) * rightGini
        }

        private fun calculateGini(labels: List<String>): Double {
            val total = labels.size.toDouble()
            val labelCounts = labels.groupBy { it }.mapValues { it.value.size.toDouble() }
            return 1.0 - labelCounts.values.sumOf { (it / total).pow(2) }
        }

        private fun splitData(
            features: List<DoubleArray>,
            labels: List<String>,
            featureIndex: Int,
            threshold: Double
        ): Quadruple<List<DoubleArray>, List<String>, List<DoubleArray>, List<String>> {
            val leftFeatures = mutableListOf<DoubleArray>()
            val leftLabels = mutableListOf<String>()
            val rightFeatures = mutableListOf<DoubleArray>()
            val rightLabels = mutableListOf<String>()

            for (i in features.indices) {
                if (features[i][featureIndex] <= threshold) {
                    leftFeatures.add(features[i])
                    leftLabels.add(labels[i])
                } else {
                    rightFeatures.add(features[i])
                    rightLabels.add(labels[i])
                }
            }

            return Quadruple(leftFeatures, leftLabels, rightFeatures, rightLabels)
        }

        private fun predictRecursive(node: DecisionTreeNode?, features: DoubleArray): String? {
            if (node == null) return null
            if (node.label != null) return node.label

            return if (features[node.featureIndex!!] <= node.threshold!!) {
                predictRecursive(node.left, features)
            } else {
                predictRecursive(node.right, features)
            }
        }
    }

    // K-Means Clustering for Patient Segmentation
    class KMeans(private val k: Int, private val maxIterations: Int = 100) {
        private lateinit var centroids: Array<DoubleArray>

        fun fit(data: List<DoubleArray>): List<Int> {
            initializeCentroids(data)
            var clusters = assignClusters(data)

            repeat(maxIterations) {
                updateCentroids(data, clusters)
                val newClusters = assignClusters(data)
                if (newClusters == clusters) return@repeat
                clusters = newClusters
            }

            return clusters
        }

        private fun initializeCentroids(data: List<DoubleArray>) {
            centroids = Array(k) { data.random().clone() }
        }

        private fun assignClusters(data: List<DoubleArray>): List<Int> {
            return data.map { point ->
                centroids.indices.minByOrNull { centroidIndex ->
                    euclideanDistance(point, centroids[centroidIndex])
                } ?: 0
            }
        }

        private fun updateCentroids(data: List<DoubleArray>, clusters: List<Int>) {
            val clusterSums = Array(k) { DoubleArray(data[0].size) { 0.0 } }
            val clusterCounts = IntArray(k) { 0 }

            for (i in data.indices) {
                val cluster = clusters[i]
                for (j in data[i].indices) {
                    clusterSums[cluster][j] += data[i][j]
                }
                clusterCounts[cluster]++
            }

            for (i in centroids.indices) {
                if (clusterCounts[i] > 0) {
                    for (j in centroids[i].indices) {
                        centroids[i][j] = clusterSums[i][j] / clusterCounts[i]
                    }
                }
            }
        }

        private fun euclideanDistance(a: DoubleArray, b: DoubleArray): Double {
            return sqrt(a.indices.sumOf { (a[it] - b[it]).pow(2) })
        }
    }

    // Gradient Boosting for Risk Prediction
    class GradientBoosting(
        private val numEstimators: Int = 100,
        private val learningRate: Double = 0.1,
        private val maxDepth: Int = 3
    ) {
        private val trees = mutableListOf<DecisionTree>()
        private var initialPrediction = 0.0

        fun fit(features: List<DoubleArray>, targets: List<Double>) {
            trees.clear()

            // Initialize with mean
            initialPrediction = targets.average()

            var predictions = DoubleArray(targets.size) { initialPrediction }
            var residuals = targets.mapIndexed { i, target -> target - predictions[i] }

            repeat(numEstimators) {
                val tree = DecisionTree(maxDepth, 2)
                val residualFeatures = features.map { it.clone() }
                tree.train(residualFeatures, residuals.map { it.toString() })

                // Update predictions
                for (i in predictions.indices) {
                    val treePrediction = tree.predict(features[i]).toDoubleOrNull() ?: 0.0
                    predictions[i] += learningRate * treePrediction
                }

                // Update residuals
                residuals = targets.mapIndexed { i, target -> target - predictions[i] }
                trees.add(tree)
            }
        }

        fun predict(features: DoubleArray): Double {
            var prediction = initialPrediction
            for (tree in trees) {
                val treePrediction = tree.predict(features).toDoubleOrNull() ?: 0.0
                prediction += learningRate * treePrediction
            }
            return prediction
        }
    }

    // Principal Component Analysis for Dimensionality Reduction
    class PCA(private val nComponents: Int) {
        private lateinit var components: Array<DoubleArray>
        private lateinit var mean: DoubleArray
        private lateinit var explainedVariance: DoubleArray

        fun fit(data: List<DoubleArray>) {
            val n = data.size
            val d = data[0].size

            // Center the data
            mean = DoubleArray(d) { j -> data.sumOf { it[j] } / n }
            val centeredData = data.map { row -> DoubleArray(d) { j -> row[j] - mean[j] } }

            // Compute covariance matrix
            val covariance = Array(d) { DoubleArray(d) { 0.0 } }
            for (i in 0 until d) {
                for (j in 0 until d) {
                    covariance[i][j] = centeredData.sumOf { it[i] * it[j] } / (n - 1)
                }
            }

            // Eigenvalue decomposition (simplified)
            val (eigenvalues, eigenvectors) = jacobiEigenvalue(covariance)

            // Sort by eigenvalues
            val sortedIndices = eigenvalues.indices.sortedByDescending { eigenvalues[it] }
            explainedVariance = DoubleArray(nComponents) { eigenvalues[sortedIndices[it]] }

            components = Array(nComponents) { i ->
                DoubleArray(d) { j -> eigenvectors[j][sortedIndices[i]] }
            }
        }

        fun transform(data: List<DoubleArray>): List<DoubleArray> {
            return data.map { row ->
                val centered = DoubleArray(row.size) { j -> row[j] - mean[j] }
                DoubleArray(nComponents) { i ->
                    components[i].indices.sumOf { j -> components[i][j] * centered[j] }
                }
            }
        }

        private fun jacobiEigenvalue(matrix: Array<DoubleArray>): Pair<DoubleArray, Array<DoubleArray>> {
            // Simplified Jacobi eigenvalue algorithm
            val n = matrix.size
            val eigenvalues = DoubleArray(n) { matrix[it][it] }
            val eigenvectors = Array(n) { DoubleArray(n) { if (it == i) 1.0 else 0.0 } }

            // In a real implementation, this would perform Jacobi rotations
            // For now, return identity (simplified)
            return Pair(eigenvalues, eigenvectors)
        }
    }

    // Advanced ML Service Methods
    private val diseasePredictionNN = NeuralNetwork(10, 20, 5)
    private val patientSegmentationKMeans = KMeans(3)
    private val riskPredictionGB = GradientBoosting()
    private val dimensionalityReductionPCA = PCA(5)

    fun advancedDiseasePrediction(symptoms: List<String>, patientHistory: Map<String, Any>): DiseasePredictionResult {
        // Convert symptoms to feature vector
        val features = convertSymptomsToFeatures(symptoms, patientHistory)

        // Use neural network for prediction
        val predictions = diseasePredictionNN.forward(features)

        val diseases = listOf("Influenza", "Pneumonia", "COVID-19", "Bronchitis", "Asthma")
        val probabilities = predictions.mapIndexed { index, prob ->
            diseases.getOrNull(index) to prob
        }.filter { it.first != null }.associate { it.first!! to it.second }

        return DiseasePredictionResult(
            predictions = probabilities,
            confidence = predictions.maxOrNull() ?: 0.0,
            riskLevel = when {
                predictions.maxOrNull() ?: 0.0 > 0.8 -> "High"
                predictions.maxOrNull() ?: 0.0 > 0.6 -> "Medium"
                else -> "Low"
            }
        )
    }

    fun patientRiskStratification(patientData: List<Map<String, Any>>): PatientSegmentationResult {
        // Convert patient data to features
        val features = patientData.map { convertPatientToFeatures(it) }

        // Apply PCA for dimensionality reduction
        dimensionalityReductionPCA.fit(features)
        val reducedFeatures = dimensionalityReductionPCA.transform(features)

        // Apply K-means clustering
        val clusters = patientSegmentationKMeans.fit(reducedFeatures)

        // Analyze clusters
        val clusterAnalysis = clusters.groupBy { it }.mapValues { entry ->
            val clusterPatients = entry.value.map { patientData[it] }
            mapOf(
                "size" to entry.value.size,
                "avgAge" to clusterPatients.mapNotNull { it["age"] as? Number }.average(),
                "avgRiskScore" to clusterPatients.mapNotNull { it["riskScore"] as? Number }.average(),
                "commonConditions" to clusterPatients.flatMap { (it["conditions"] as? List<String>) ?: emptyList() }
                    .groupBy { it }.mapValues { it.value.size }.entries.sortedByDescending { it.value }.take(3)
            )
        }

        return PatientSegmentationResult(
            clusters = clusters,
            clusterAnalysis = clusterAnalysis,
            explainedVariance = dimensionalityReductionPCA.explainedVariance.toList()
        )
    }

    fun predictiveHealthAnalytics(historicalData: List<HealthDataPoint>): PredictiveAnalyticsResult {
        // Prepare features and targets
        val features = historicalData.map { convertHealthDataToFeatures(it) }
        val targets = historicalData.map { calculateHealthRiskScore(it) }

        // Train gradient boosting model
        riskPredictionGB.fit(features, targets)

        // Generate predictions
        val predictions = features.map { riskPredictionGB.predict(it) }

        // Calculate trends
        val trend = calculateTrend(predictions)

        // Identify anomalies
        val anomalies = detectAnomalies(predictions, targets)

        return PredictiveAnalyticsResult(
            predictions = predictions,
            trend = trend,
            anomalies = anomalies,
            confidence = calculatePredictionConfidence(predictions, targets),
            recommendations = generateHealthRecommendations(trend, anomalies)
        )
    }

    private fun convertSymptomsToFeatures(symptoms: List<String>, patientHistory: Map<String, Any>): DoubleArray {
        // Convert symptoms and history to numerical features
        return doubleArrayOf(
            symptoms.size.toDouble() / 10.0, // Symptom count normalized
            (patientHistory["age"] as? Number)?.toDouble()?.div(100.0) ?: 0.5,
            if (symptoms.any { it.contains("fever", ignoreCase = true) }) 1.0 else 0.0,
            if (symptoms.any { it.contains("cough", ignoreCase = true) }) 1.0 else 0.0,
            if (symptoms.any { it.contains("pain", ignoreCase = true) }) 1.0 else 0.0,
            (patientHistory["chronicConditions"] as? List<String>)?.size?.toDouble()?.div(5.0) ?: 0.0,
            if ((patientHistory["smoker"] as? Boolean) == true) 1.0 else 0.0,
            (patientHistory["bmi"] as? Number)?.toDouble()?.div(50.0) ?: 0.5,
            if (symptoms.any { it.contains("shortness", ignoreCase = true) }) 1.0 else 0.0,
            (patientHistory["recentHospitalizations"] as? Number)?.toDouble()?.div(5.0) ?: 0.0
        )
    }

    private fun convertPatientToFeatures(patient: Map<String, Any>): DoubleArray {
        return doubleArrayOf(
            (patient["age"] as? Number)?.toDouble()?.div(100.0) ?: 0.5,
            (patient["bmi"] as? Number)?.toDouble()?.div(50.0) ?: 0.5,
            (patient["chronicConditions"] as? List<String>)?.size?.toDouble()?.div(10.0) ?: 0.0,
            if ((patient["smoker"] as? Boolean) == true) 1.0 else 0.0,
            (patient["exerciseFrequency"] as? Number)?.toDouble()?.div(7.0) ?: 0.0,
            (patient["stressLevel"] as? Number)?.toDouble()?.div(10.0) ?: 0.5,
            (patient["sleepHours"] as? Number)?.toDouble()?.div(12.0) ?: 0.5,
            (patient["recentCheckups"] as? Number)?.toDouble()?.div(12.0) ?: 0.0
        )
    }

    private fun convertHealthDataToFeatures(data: HealthDataPoint): DoubleArray {
        return doubleArrayOf(
            data.heartRate?.div(200.0) ?: 0.5,
            data.bloodPressureSystolic?.div(200.0) ?: 0.5,
            data.bloodPressureDiastolic?.div(150.0) ?: 0.5,
            data.temperature?.div(110.0) ?: 0.5,
            data.oxygenSaturation?.div(100.0) ?: 0.95,
            data.respiratoryRate?.div(50.0) ?: 0.2,
            data.glucoseLevel?.div(500.0) ?: 0.1
        )
    }

    private fun calculateHealthRiskScore(data: HealthDataPoint): Double {
        var riskScore = 0.0

        // Heart rate risk
        data.heartRate?.let {
            when {
                it < 50 || it > 120 -> riskScore += 0.3
                it < 60 || it > 100 -> riskScore += 0.1
            }
        }

        // Blood pressure risk
        if (data.bloodPressureSystolic != null && data.bloodPressureDiastolic != null) {
            when {
                data.bloodPressureSystolic > 180 || data.bloodPressureDiastolic > 120 -> riskScore += 0.4
                data.bloodPressureSystolic > 140 || data.bloodPressureDiastolic > 90 -> riskScore += 0.2
            }
        }

        // Temperature risk
        data.temperature?.let {
            when {
                it > 103 || it < 95 -> riskScore += 0.3
                it > 100.4 -> riskScore += 0.1
            }
        }

        // Oxygen saturation risk
        data.oxygenSaturation?.let {
            if (it < 95) riskScore += 0.2
        }

        return riskScore.coerceIn(0.0, 1.0)
    }

    private fun calculateTrend(predictions: List<Double>): String {
        if (predictions.size < 2) return "stable"

        val recent = predictions.takeLast(5).average()
        val earlier = predictions.take(5).average()

        return when {
            recent > earlier + 0.1 -> "increasing"
            recent < earlier - 0.1 -> "decreasing"
            else -> "stable"
        }
    }

    private fun detectAnomalies(predictions: List<Double>, actuals: List<Double>): List<Int> {
        val anomalies = mutableListOf<Int>()
        val threshold = 0.2 // 20% deviation threshold

        for (i in predictions.indices) {
            val deviation = kotlin.math.abs(predictions[i] - actuals[i])
            if (deviation > threshold) {
                anomalies.add(i)
            }
        }

        return anomalies
    }

    private fun calculatePredictionConfidence(predictions: List<Double>, actuals: List<Double>): Double {
        if (predictions.isEmpty()) return 0.0

        val mse = predictions.indices.sumOf { (predictions[it] - actuals[it]).pow(2) } / predictions.size
        val rmse = sqrt(mse)

        // Convert RMSE to confidence score (lower RMSE = higher confidence)
        return (1.0 / (1.0 + rmse)).coerceIn(0.0, 1.0)
    }

    private fun generateHealthRecommendations(trend: String, anomalies: List<Int>): List<String> {
        val recommendations = mutableListOf<String>()

        when (trend) {
            "increasing" -> {
                recommendations.add("Schedule immediate consultation with healthcare provider")
                recommendations.add("Increase monitoring frequency")
                recommendations.add("Review current medications and dosages")
            }
            "decreasing" -> {
                recommendations.add("Continue current treatment plan")
                recommendations.add("Schedule regular follow-up appointments")
                recommendations.add("Maintain healthy lifestyle habits")
            }
            else -> {
                recommendations.add("Continue regular health check-ups")
                recommendations.add("Maintain current monitoring schedule")
                recommendations.add("Report any new symptoms immediately")
            }
        }

        if (anomalies.isNotEmpty()) {
            recommendations.add("Review recent health data anomalies with healthcare provider")
            recommendations.add("Consider additional diagnostic tests")
        }

        return recommendations
    }
}

// Data classes for ML results
data class DiseasePredictionResult(
    val predictions: Map<String, Double>,
    val confidence: Double,
    val riskLevel: String
)

data class PatientSegmentationResult(
    val clusters: List<Int>,
    val clusterAnalysis: Map<Int, Map<String, Any>>,
    val explainedVariance: List<Double>
)

data class PredictiveAnalyticsResult(
    val predictions: List<Double>,
    val trend: String,
    val anomalies: List<Int>,
    val confidence: Double,
    val recommendations: List<String>
)

// Utility class for multiple return values
data class Quadruple<A, B, C, D>(
    val first: A,
    val second: B,
    val third: C,
    val fourth: D
)