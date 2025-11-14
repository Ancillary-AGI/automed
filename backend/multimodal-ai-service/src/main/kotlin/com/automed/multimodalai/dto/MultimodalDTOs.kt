package com.automed.multimodalai.dto

import jakarta.validation.constraints.NotBlank
import jakarta.validation.constraints.NotNull
import java.time.LocalDateTime

// Multimodal Fusion Request/Response
data class MultimodalFusionRequest(
    @field:NotBlank
    val patientId: String,

    val textData: TextData? = null,
    val imageData: ImageData? = null,
    val vitalsData: VitalsData? = null,
    val genomicData: GenomicData? = null,

    val fusionStrategy: FusionStrategy = FusionStrategy.LATE_FUSION,
    val includeUncertainty: Boolean = true
)

data class MultimodalFusionResponse(
    val patientId: String,
    val diagnosis: DiagnosisResult,
    val treatmentPlan: TreatmentPlan,
    val confidence: ConfidenceScore,
    val processingTimeMs: Long,
    val timestamp: LocalDateTime = LocalDateTime.now()
)

// Data Modalities
data class TextData(
    @field:NotBlank
    val content: String,
    val type: TextType = TextType.CLINICAL_NOTES,
    val language: String = "en"
)

data class ImageData(
    @field:NotBlank
    val imageUrl: String,
    val modality: ImageModality,
    val metadata: ImageMetadata? = null
)

data class VitalsData(
    val measurements: List<VitalMeasurement>,
    val timeRange: TimeRange? = null
)

data class GenomicData(
    @field:NotBlank
    val sequence: String,
    val type: GenomicType,
    val variants: List<GeneticVariant> = emptyList()
)

// Enums
enum class FusionStrategy {
    EARLY_FUSION,
    LATE_FUSION,
    HYBRID_FUSION
}

enum class TextType {
    CLINICAL_NOTES,
    SYMPTOM_DESCRIPTION,
    MEDICAL_HISTORY,
    LAB_REPORTS
}

enum class ImageModality {
    XRAY,
    MRI,
    CT,
    ULTRASOUND,
    DERMATOLOGY,
    OPHTHALMOLOGY
}

enum class GenomicType {
    DNA_SEQUENCE,
    RNA_SEQUENCE,
    PROTEIN_SEQUENCE
}

// Supporting Data Classes
data class ImageMetadata(
    val width: Int,
    val height: Int,
    val format: String,
    val bodyPart: String? = null,
    val acquisitionDate: LocalDateTime? = null
)

data class VitalMeasurement(
    @field:NotBlank
    val type: String,
    @field:NotNull
    val value: Double,
    val unit: String,
    val timestamp: LocalDateTime
)

data class TimeRange(
    val start: LocalDateTime,
    val end: LocalDateTime
)

data class GeneticVariant(
    val position: Int,
    val reference: String,
    val alternate: String,
    val clinicalSignificance: String? = null
)

data class DiagnosisResult(
    val primaryDiagnosis: String,
    val differentialDiagnoses: List<String>,
    val icdCodes: List<String>,
    val reasoning: String
)

data class TreatmentPlan(
    val recommendations: List<TreatmentRecommendation>,
    val medications: List<MedicationRecommendation>,
    val followUp: FollowUpPlan
)

data class TreatmentRecommendation(
    val type: String,
    val description: String,
    val priority: Priority,
    val rationale: String
)

data class MedicationRecommendation(
    val drugName: String,
    val dosage: String,
    val frequency: String,
    val duration: String,
    val reason: String
)

data class FollowUpPlan(
    val timeline: String,
    val actions: List<String>,
    val monitoring: List<String>
)

data class ConfidenceScore(
    val overall: Double,
    val modalityConfidences: Map<String, Double>,
    val uncertaintyMetrics: UncertaintyMetrics
)

data class UncertaintyMetrics(
    val epistemicUncertainty: Double,
    val aleatoricUncertainty: Double,
    val confidenceInterval: ConfidenceInterval
)

data class ConfidenceInterval(
    val lower: Double,
    val upper: Double,
    val confidenceLevel: Double = 0.95
)

enum class Priority {
    HIGH,
    MEDIUM,
    LOW
}

// Synthetic Data Generation
data class SyntheticDataRequest(
    val modality: DataModality,
    val count: Int = 100,
    val parameters: Map<String, Any> = emptyMap(),
    val includeLabels: Boolean = true
)

data class SyntheticDataResponse(
    val modality: DataModality,
    val generatedData: List<Any>,
    val metadata: SyntheticDataMetadata,
    val qualityMetrics: QualityMetrics
)

enum class DataModality {
    TEXT,
    IMAGE,
    VITALS,
    GENOMIC,
    MULTIMODAL
}

data class SyntheticDataMetadata(
    val generationMethod: String,
    val modelVersion: String,
    val parameters: Map<String, Any>,
    val timestamp: LocalDateTime = LocalDateTime.now()
)

data class QualityMetrics(
    val fidelity: Double,
    val diversity: Double,
    val realism: Double
)

// Real-time Processing
data class RealTimeProcessingRequest(
    val sessionId: String,
    val modality: DataModality,
    val data: Any,
    val priority: Priority = Priority.MEDIUM
)

data class RealTimeProcessingResponse(
    val sessionId: String,
    val result: Any,
    val processingTimeMs: Long,
    val confidence: Double
)

// Cross-modal Reasoning
data class CrossModalReasoningRequest(
    val query: String,
    val modalities: List<DataModality>,
    val contextData: Map<String, Any>,
    val reasoningType: ReasoningType
)

data class CrossModalReasoningResponse(
    val reasoning: String,
    val evidence: List<Evidence>,
    val confidence: Double,
    val alternativeHypotheses: List<String>
)

enum class ReasoningType {
    DIAGNOSTIC,
    PROGNOSTIC,
    TREATMENT,
    RISK_ASSESSMENT
}

data class Evidence(
    val modality: DataModality,
    val source: String,
    val relevance: Double,
    val contribution: String
)

// Patient Data Integration
data class PatientDataIntegrationRequest(
    val patientId: String,
    val includeHistorical: Boolean = true,
    val modalities: List<DataModality> = DataModality.values().toList()
)

data class PatientDataIntegrationResponse(
    val patientId: String,
    val integratedData: Map<String, Any>,
    val dataQuality: DataQualityMetrics,
    val lastUpdated: LocalDateTime
)

data class DataQualityMetrics(
    val completeness: Double,
    val consistency: Double,
    val timeliness: Double,
    val accuracy: Double
)