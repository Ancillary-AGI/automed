package com.automed.imaging.domain

import java.time.LocalDateTime

data class MedicalImage(
    val id: String,
    val patientId: String,
    val studyInstanceUid: String,
    val seriesInstanceUid: String,
    val sopInstanceUid: String,
    val modality: Modality,
    val bodyPart: String?,
    val studyDescription: String?,
    val seriesDescription: String?,
    val acquisitionDate: LocalDateTime?,
    val imageType: ImageType,
    val filePath: String,
    val fileSize: Long,
    val width: Int?,
    val height: Int?,
    val bitsAllocated: Int?,
    val bitsStored: Int?,
    val highBit: Int?,
    val pixelRepresentation: Int?,
    val samplesPerPixel: Int?,
    val photometricInterpretation: String?,
    val compression: String?,
    val qualityScore: Double? = null,
    val aiProcessed: Boolean = false,
    val createdAt: LocalDateTime = LocalDateTime.now(),
    val updatedAt: LocalDateTime = LocalDateTime.now()
)

enum class Modality {
    CT, MR, CR, DX, US, NM, PT, XA, RF, MG, IO, OP, SM, OT
}

enum class ImageType {
    ORIGINAL,
    PROCESSED,
    ENHANCED,
    SYNTHETIC,
    SEGMENTED
}

data class ImageMetadata(
    val dicomTags: Map<String, Any>,
    val processingHistory: List<ProcessingStep> = emptyList(),
    val qualityMetrics: QualityMetrics? = null,
    val aiAnalysis: AIAnalysis? = null
)

data class ProcessingStep(
    val stepName: String,
    val timestamp: LocalDateTime,
    val parameters: Map<String, Any>,
    val duration: Long? = null,
    val success: Boolean = true,
    val errorMessage: String? = null
)

data class QualityMetrics(
    val psnr: Double? = null,
    val ssim: Double? = null,
    val sharpness: Double? = null,
    val contrast: Double? = null,
    val noiseLevel: Double? = null,
    val resolution: String? = null
)

data class AIAnalysis(
    val modelVersion: String,
    val confidence: Double,
    val findings: List<Finding>,
    val segmentationMasks: List<SegmentationMask> = emptyList(),
    val classification: String? = null,
    val riskScore: Double? = null
)

data class Finding(
    val type: FindingType,
    val location: ImageLocation,
    val description: String,
    val confidence: Double,
    val severity: Severity,
    val recommendations: List<String> = emptyList()
)

enum class FindingType {
    ANOMALY,
    LESION,
    FRACTURE,
    TUMOR,
    HEMORRHAGE,
    PNEUMONIA,
    EFFUSION,
    CONSOLIDATION,
    NODULE,
    OTHER
}

enum class Severity {
    LOW,
    MODERATE,
    HIGH,
    CRITICAL
}

data class ImageLocation(
    val x: Int,
    val y: Int,
    val width: Int,
    val height: Int,
    val slice: Int? = null,
    val coordinates: List<Point3D> = emptyList()
)

data class Point3D(
    val x: Double,
    val y: Double,
    val z: Double
)

data class SegmentationMask(
    val maskId: String,
    val maskType: String,
    val confidence: Double,
    val pixels: ByteArray,
    val width: Int,
    val height: Int,
    val color: String? = null
) {
    override fun equals(other: Any?): Boolean {
        if (this === other) return true
        if (javaClass != other?.javaClass) return false

        other as SegmentationMask

        if (maskId != other.maskId) return false
        if (maskType != other.maskType) return false
        if (confidence != other.confidence) return false
        if (!pixels.contentEquals(other.pixels)) return false
        if (width != other.width) return false
        if (height != other.height) return false
        if (color != other.color) return false

        return true
    }

    override fun hashCode(): Int {
        var result = maskId.hashCode()
        result = 31 * result + maskType.hashCode()
        result = 31 * result + confidence.hashCode()
        result = 31 * result + pixels.contentHashCode()
        result = 31 * result + width
        result = 31 * result + height
        result = 31 * result + (color?.hashCode() ?: 0)
        return result
    }
}