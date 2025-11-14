package com.automed.imaging.dto

import com.automed.imaging.domain.*
import java.time.LocalDateTime

// Request DTOs
data class ImageUploadRequest(
    val patientId: String,
    val studyDescription: String? = null,
    val seriesDescription: String? = null,
    val modality: String,
    val bodyPart: String? = null,
    val priority: ProcessingPriority = ProcessingPriority.NORMAL
)

enum class ProcessingPriority {
    LOW, NORMAL, HIGH, URGENT
}

data class ImageProcessingRequest(
    val imageId: String,
    val operations: List<ImageOperation>,
    val priority: ProcessingPriority = ProcessingPriority.NORMAL,
    val callbackUrl: String? = null
)

data class ImageOperation(
    val type: OperationType,
    val parameters: Map<String, Any> = emptyMap()
)

enum class OperationType {
    ENHANCE,
    DENOISE,
    SEGMENT,
    CLASSIFY,
    DETECT_ANOMALIES,
    CROSS_MODALITY_TRANSLATION,
    THREE_D_RECONSTRUCTION,
    QUALITY_ASSESSMENT
}

data class CrossModalityRequest(
    val sourceImageId: String,
    val targetModality: String,
    val preserveAnatomy: Boolean = true,
    val quality: TranslationQuality = TranslationQuality.HIGH
)

enum class TranslationQuality {
    FAST, BALANCED, HIGH, ULTRA
}

data class ThreeDReconstructionRequest(
    val imageIds: List<String>,
    val reconstructionType: ReconstructionType,
    val interpolationMethod: InterpolationMethod = InterpolationMethod.LINEAR,
    val outputResolution: Resolution? = null
)

enum class ReconstructionType {
    SURFACE_MESH,
    VOLUME_RENDERING,
    ISOSURFACE
}

enum class InterpolationMethod {
    NEAREST_NEIGHBOR,
    LINEAR,
    CUBIC,
    SPLINE
}

data class Resolution(
    val width: Int,
    val height: Int,
    val depth: Int? = null
)

data class SyntheticDataRequest(
    val templateImageId: String? = null,
    val targetModality: String,
    val pathology: String? = null,
    val count: Int = 1,
    val variationLevel: VariationLevel = VariationLevel.MODERATE,
    val includeAnnotations: Boolean = false
)

enum class VariationLevel {
    LOW, MODERATE, HIGH
}

data class FederatedLearningRequest(
    val modelType: String,
    val datasetIds: List<String>,
    val rounds: Int = 5,
    val privacyLevel: PrivacyLevel = PrivacyLevel.MODERATE
)

enum class PrivacyLevel {
    LOW, MODERATE, HIGH
}

// Response DTOs
data class ImageUploadResponse(
    val imageId: String,
    val status: UploadStatus,
    val message: String,
    val processingId: String? = null
)

enum class UploadStatus {
    SUCCESS, PENDING_PROCESSING, FAILED
}

data class ImageProcessingResponse(
    val processingId: String,
    val status: ProcessingStatus,
    val progress: Double = 0.0,
    val estimatedTimeRemaining: Long? = null,
    val results: List<ProcessingResult> = emptyList(),
    val error: String? = null
)

enum class ProcessingStatus {
    QUEUED, PROCESSING, COMPLETED, FAILED, CANCELLED
}

data class ProcessingResult(
    val operationType: OperationType,
    val success: Boolean,
    val outputImageId: String? = null,
    val metrics: Map<String, Any> = emptyMap(),
    val findings: List<Finding> = emptyList(),
    val error: String? = null
)

data class ImageQueryResponse(
    val images: List<ImageSummary>,
    val totalCount: Long,
    val page: Int,
    val size: Int,
    val hasNext: Boolean
)

data class ImageSummary(
    val id: String,
    val patientId: String,
    val modality: String,
    val bodyPart: String?,
    val studyDescription: String?,
    val acquisitionDate: LocalDateTime?,
    val imageType: String,
    val fileSize: Long,
    val qualityScore: Double?,
    val aiProcessed: Boolean,
    val thumbnailUrl: String? = null
)

data class ImageDetailsResponse(
    val image: MedicalImage,
    val metadata: ImageMetadata,
    val downloadUrl: String,
    val relatedImages: List<ImageSummary> = emptyList()
)

data class AIAnalysisResponse(
    val imageId: String,
    val analysis: AIAnalysis,
    val processingTime: Long,
    val modelVersion: String,
    val confidence: Double
)

data class QualityAssessmentResponse(
    val imageId: String,
    val metrics: QualityMetrics,
    val overallScore: Double,
    val recommendations: List<String>
)

data class CrossModalityResponse(
    val sourceImageId: String,
    val targetImageId: String,
    val targetModality: String,
    val quality: TranslationQuality,
    val fidelityScore: Double,
    val processingTime: Long
)

data class ThreeDModelResponse(
    val modelId: String,
    val sourceImageIds: List<String>,
    val reconstructionType: ReconstructionType,
    val meshUrl: String? = null,
    val volumeUrl: String? = null,
    val statistics: Map<String, Any>
)

data class SyntheticDataResponse(
    val generatedImages: List<String>,
    val templateImageId: String?,
    val generationParameters: Map<String, Any>,
    val qualityMetrics: List<QualityMetrics>
)

data class FederatedLearningResponse(
    val sessionId: String,
    val status: FLStatus,
    val currentRound: Int,
    val totalRounds: Int,
    val participants: Int,
    val modelAccuracy: Double? = null,
    val privacyMetrics: Map<String, Any> = emptyMap()
)

enum class FLStatus {
    INITIALIZING, TRAINING, AGGREGATING, COMPLETED, FAILED
}

// PACS Integration DTOs
data class PACSQueryRequest(
    val patientId: String? = null,
    val studyDate: String? = null,
    val modality: String? = null,
    val limit: Int = 50
)

data class PACSQueryResponse(
    val studies: List<PACSStudy>,
    val totalCount: Int
)

data class PACSStudy(
    val studyInstanceUid: String,
    val patientId: String,
    val patientName: String,
    val studyDate: String,
    val studyTime: String,
    val studyDescription: String?,
    val modalities: List<String>,
    val seriesCount: Int,
    val imageCount: Int,
    val accessionNumber: String?
)

data class PACSTransferRequest(
    val studyInstanceUid: String,
    val seriesInstanceUids: List<String>? = null,
    val priority: ProcessingPriority = ProcessingPriority.NORMAL
)

data class PACSTransferResponse(
    val transferId: String,
    val status: TransferStatus,
    val transferredImages: Int = 0,
    val totalImages: Int = 0
)

enum class TransferStatus {
    QUEUED, TRANSFERRING, COMPLETED, FAILED, PARTIAL_SUCCESS
}

// Batch Processing DTOs
data class BatchProcessingRequest(
    val imageIds: List<String>,
    val operations: List<ImageOperation>,
    val parallel: Boolean = true,
    val maxConcurrency: Int = 5
)

data class BatchProcessingResponse(
    val batchId: String,
    val totalImages: Int,
    val completed: Int = 0,
    val failed: Int = 0,
    val inProgress: Int = 0,
    val results: List<ProcessingResult> = emptyList()
)

// Error Response
data class ImagingErrorResponse(
    val error: String,
    val code: String,
    val details: Map<String, Any> = emptyMap(),
    val timestamp: LocalDateTime = LocalDateTime.now()
)