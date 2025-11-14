package com.automed.multimodalai.service

import ai.djl.ndarray.NDArray
import com.automed.multimodalai.dto.*
import org.apache.commons.math3.distribution.NormalDistribution
import org.apache.commons.math3.stat.descriptive.SummaryStatistics
import org.slf4j.LoggerFactory
import org.springframework.stereotype.Service
import kotlin.math.abs
import kotlin.math.exp
import kotlin.math.sqrt

@Service
class UncertaintyQuantificationService {

    private val logger = LoggerFactory.getLogger(UncertaintyQuantificationService::class.java)

    fun quantifyUncertainty(fusedFeatures: NDArray, diagnosis: DiagnosisResult): ConfidenceScore {
        logger.info("Quantifying uncertainty for diagnosis: ${diagnosis.primaryDiagnosis}")

        val features = fusedFeatures.toFloatArray()

        // Calculate epistemic uncertainty (model uncertainty)
        val epistemicUncertainty = calculateEpistemicUncertainty(features)

        // Calculate aleatoric uncertainty (data uncertainty)
        val aleatoricUncertainty = calculateAleatoricUncertainty(features)

        // Calculate modality-specific confidences
        val modalityConfidences = calculateModalityConfidences(features)

        // Calculate overall confidence
        val overallConfidence = calculateOverallConfidence(epistemicUncertainty, aleatoricUncertainty, modalityConfidences)

        // Calculate confidence interval
        val confidenceInterval = calculateConfidenceInterval(overallConfidence, epistemicUncertainty, aleatoricUncertainty)

        return ConfidenceScore(
            overall = overallConfidence,
            modalityConfidences = modalityConfidences,
            uncertaintyMetrics = UncertaintyMetrics(
                epistemicUncertainty = epistemicUncertainty,
                aleatoricUncertainty = aleatoricUncertainty,
                confidenceInterval = confidenceInterval
            )
        )
    }

    private fun calculateEpistemicUncertainty(features: FloatArray): Double {
        // Epistemic uncertainty relates to uncertainty in model parameters
        // Simplified calculation based on feature variance and model confidence

        val stats = SummaryStatistics()
        features.forEach { stats.addValue(it.toDouble()) }

        val variance = stats.variance
        val mean = stats.mean

        // Use entropy-based measure for epistemic uncertainty
        val normalizedVariance = variance / (mean * mean + 1.0)
        return minOf(normalizedVariance, 1.0) // Cap at 1.0
    }

    private fun calculateAleatoricUncertainty(features: FloatArray): Double {
        // Aleatoric uncertainty relates to noise in the data
        // Calculate based on feature distribution characteristics

        val nonZeroFeatures = features.filter { abs(it) > 0.01f }
        if (nonZeroFeatures.isEmpty()) return 0.5

        // Calculate coefficient of variation
        val mean = nonZeroFeatures.average()
        val stdDev = sqrt(nonZeroFeatures.map { (it - mean) * (it - mean) }.average())

        return if (mean != 0.0) minOf(stdDev / abs(mean), 1.0) else 0.5
    }

    private fun calculateModalityConfidences(features: FloatArray): Map<String, Double> {
        // Estimate confidence for each modality based on feature quality and consistency

        val confidences = mutableMapOf<String, Double>()

        // Text modality confidence (first 768 features - BERT)
        val textFeatures = features.take(768)
        confidences["text"] = calculateModalityConfidence(textFeatures, "text")

        // Image modality confidence (next 2048 features - Vision)
        val imageFeatures = features.drop(768).take(2048)
        confidences["image"] = calculateModalityConfidence(imageFeatures, "image")

        // Vitals modality confidence (next 128 features)
        val vitalsFeatures = features.drop(768 + 2048).take(128)
        confidences["vitals"] = calculateModalityConfidence(vitalsFeatures, "vitals")

        // Genomic modality confidence (remaining features)
        val genomicFeatures = features.drop(768 + 2048 + 128)
        confidences["genomic"] = calculateModalityConfidence(genomicFeatures, "genomic")

        return confidences
    }

    private fun calculateModalityConfidence(modalityFeatures: List<Float>, modality: String): Double {
        if (modalityFeatures.isEmpty()) return 0.5

        val nonZeroCount = modalityFeatures.count { abs(it) > 0.01f }
        val coverage = nonZeroCount.toDouble() / modalityFeatures.size

        val stats = SummaryStatistics()
        modalityFeatures.forEach { stats.addValue(it.toDouble()) }

        val signalToNoiseRatio = if (stats.standardDeviation != 0.0) {
            abs(stats.mean) / stats.standardDeviation
        } else {
            1.0
        }

        // Combine coverage and signal-to-noise ratio
        val confidence = (coverage * 0.6) + (minOf(signalToNoiseRatio / 10.0, 1.0) * 0.4)

        return minOf(maxOf(confidence, 0.0), 1.0)
    }

    private fun calculateOverallConfidence(
        epistemicUncertainty: Double,
        aleatoricUncertainty: Double,
        modalityConfidences: Map<String, Double>
    ): Double {
        // Calculate weighted average of modality confidences
        val avgModalityConfidence = modalityConfidences.values.average()

        // Adjust for uncertainties
        val totalUncertainty = (epistemicUncertainty + aleatoricUncertainty) / 2.0

        // Final confidence is modality confidence reduced by uncertainty
        return maxOf(avgModalityConfidence * (1.0 - totalUncertainty), 0.0)
    }

    private fun calculateConfidenceInterval(
        overallConfidence: Double,
        epistemicUncertainty: Double,
        aleatoricUncertainty: Double
    ): ConfidenceInterval {
        val totalUncertainty = epistemicUncertainty + aleatoricUncertainty
        val marginOfError = totalUncertainty * 1.96 // 95% confidence interval

        return ConfidenceInterval(
            lower = maxOf(overallConfidence - marginOfError, 0.0),
            upper = minOf(overallConfidence + marginOfError, 1.0),
            confidenceLevel = 0.95
        )
    }

    fun quantifyPredictionUncertainty(predictions: List<Double>): UncertaintyMetrics {
        // Quantify uncertainty for a set of predictions
        val stats = SummaryStatistics()
        predictions.forEach { stats.addValue(it) }

        val mean = stats.mean
        val stdDev = stats.standardDeviation

        // Epistemic uncertainty based on prediction variance
        val epistemicUncertainty = stdDev / (abs(mean) + 1.0)

        // Aleatoric uncertainty based on prediction spread
        val aleatoricUncertainty = calculateAleatoricFromPredictions(predictions)

        return UncertaintyMetrics(
            epistemicUncertainty = epistemicUncertainty,
            aleatoricUncertainty = aleatoricUncertainty,
            confidenceInterval = ConfidenceInterval(
                lower = mean - 1.96 * stdDev,
                upper = mean + 1.96 * stdDev
            )
        )
    }

    private fun calculateAleatoricFromPredictions(predictions: List<Double>): Double {
        if (predictions.size < 2) return 0.5

        // Calculate the spread of predictions
        val min = predictions.minOrNull() ?: 0.0
        val max = predictions.maxOrNull() ?: 1.0
        val range = max - min

        // Normalize to [0, 1] scale
        return minOf(range, 1.0)
    }

    fun calculateDecisionConfidence(
        diagnosis: DiagnosisResult,
        treatmentPlan: TreatmentPlan,
        uncertaintyMetrics: UncertaintyMetrics
    ): Double {
        // Calculate confidence in the overall clinical decision
        val diagnosisConfidence = 0.8 // Simplified - would be based on diagnosis logic
        val treatmentConfidence = 0.75 // Simplified - would be based on treatment logic

        val clinicalConfidence = (diagnosisConfidence + treatmentConfidence) / 2.0
        val uncertaintyPenalty = uncertaintyMetrics.epistemicUncertainty * 0.3 +
                                uncertaintyMetrics.aleatoricUncertainty * 0.2

        return maxOf(clinicalConfidence - uncertaintyPenalty, 0.0)
    }
}