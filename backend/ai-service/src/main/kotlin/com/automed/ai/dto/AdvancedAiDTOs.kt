package com.automed.ai.dto

import jakarta.validation.constraints.*
import java.util.*

// Computer Vision & Medical Imaging DTOs
data class MedicalImageAnalysisRequest(
    @field:NotBlank
    val patientId: String,

    @field:NotBlank
    val imageType: ImageType,

    @field:NotBlank
    val imageData: String, // Base64 encoded image

    val regionOfInterest: Map<String, Double>? = null, // x, y, width, height
    val clinicalContext: Map<String, Any>? = null,
    val previousImages: List<String>? = null
)

data class MedicalImageAnalysisResponse(
    val patientId: String,
    val imageType: ImageType,
    val findings: List<ImageFinding>,
    val confidence: Double,
    val recommendations: List<String>,
    val urgencyLevel: String,
    val suggestedActions: List<String>,
    val comparisonWithPrevious: ImageComparison? = null
)

data class ImageFinding(
    val location: ImageLocation,
    val condition: String,
    val probability: Double,
    val severity: String,
    val description: String,
    val measurements: Map<String, Double>? = null,
    val characteristics: List<String>? = null
)

data class ImageLocation(
    val x: Double,
    val y: Double,
    val width: Double,
    val height: Double,
    val anatomicalRegion: String? = null
)

data class ImageComparison(
    val hasSignificantChange: Boolean,
    val changeDescription: String? = null,
    val progressionRate: String? = null,
    val previousImageDate: String? = null
)

enum class ImageType {
    X_RAY, MRI, CT_SCAN, ULTRASOUND, DERMATOLOGY, RETINAL, PATHOLOGY
}

// Wearable Integration DTOs
data class WearableDataRequest(
    @field:NotBlank
    val patientId: String,

    @field:NotBlank
    val deviceType: DeviceType,

    @field:NotEmpty
    val dataPoints: List<WearableDataPoint>,

    @field:NotNull
    val timeRange: TimeRange
)

data class WearableDataPoint(
    val timestamp: Long,
    val heartRate: Double? = null,
    val bloodPressureSystolic: Double? = null,
    val bloodPressureDiastolic: Double? = null,
    val temperature: Double? = null,
    val oxygenSaturation: Double? = null,
    val steps: Int? = null,
    val sleepDuration: Double? = null,
    val sleepQuality: String? = null,
    val activityLevel: String? = null,
    val stressLevel: Double? = null,
    val bloodGlucose: Double? = null,
    val customMetrics: Map<String, Double>? = null
)

data class TimeRange(
    val startTime: Long,
    val endTime: Long
)

data class WearableDataResponse(
    val patientId: String,
    val deviceType: DeviceType,
    val analysis: WearableAnalysis,
    val insights: List<HealthInsight>,
    val alerts: List<WearableAlert>,
    val recommendations: List<String>
)

data class WearableAnalysis(
    val averageHeartRate: Double,
    val heartRateVariability: Double,
    val averageBloodPressure: BloodPressureAverage,
    val sleepQualityScore: Double,
    val activityScore: Double,
    val stressTrend: String,
    val anomalyDetection: List<String>
)

data class BloodPressureAverage(
    val systolic: Double,
    val diastolic: Double
)

data class HealthInsight(
    val type: InsightType,
    val message: String,
    val confidence: Double,
    val actionable: Boolean,
    val priority: String
)

data class WearableAlert(
    val type: AlertType,
    val severity: AlertSeverity,
    val message: String,
    val timestamp: Long,
    val suggestedAction: String
)

enum class DeviceType {
    SMARTWATCH, FITNESS_TRACKER, CGM, BLOOD_PRESSURE_MONITOR, SLEEP_TRACKER, SMART_SCALE
}

enum class InsightType {
    SLEEP_QUALITY, ACTIVITY_LEVEL, HEART_HEALTH, STRESS_MANAGEMENT, GLUCOSE_CONTROL
}

// Voice & NLP DTOs
data class VoiceAnalysisRequest(
    @field:NotBlank
    val patientId: String,

    @field:NotBlank
    val audioData: String, // Base64 encoded audio

    @field:NotBlank
    val analysisType: VoiceAnalysisType,

    val context: Map<String, Any>? = null,
    val language: String? = "en"
)

data class VoiceAnalysisResponse(
    val patientId: String,
    val analysisType: VoiceAnalysisType,
    val transcription: String,
    val sentiment: SentimentAnalysis,
    val medicalTerms: List<MedicalTerm>,
    val urgencyLevel: String,
    val recommendations: List<String>,
    val confidence: Double
)

data class SentimentAnalysis(
    val overall: String,
    val confidence: Double,
    val emotions: Map<String, Double>,
    val stressIndicators: List<String>
)

data class MedicalTerm(
    val term: String,
    val category: String,
    val confidence: Double,
    val context: String
)

enum class VoiceAnalysisType {
    SYMPTOM_DESCRIPTION, CONSULTATION_NOTES, EMERGENCY_CALL, GENERAL_INQUIRY
}

// Population Health DTOs
data class PopulationHealthRequest(
    @field:NotBlank
    val region: String,

    @field:NotBlank
    val condition: String,

    @field:Min(1)
    val timeRangeDays: Int,

    val demographics: Map<String, Any>? = null,
    val includeForecasting: Boolean? = false
)

data class PopulationHealthResponse(
    val region: String,
    val condition: String,
    val currentCases: Int,
    val trend: TrendAnalysis,
    val demographics: Map<String, Any>,
    val riskFactors: List<String>,
    val forecast: HealthForecast? = null,
    val recommendations: List<String>
)

data class TrendAnalysis(
    val direction: String,
    val rate: Double,
    val confidence: Double,
    val seasonalPattern: String? = null
)

data class HealthForecast(
    val predictedCases: Int,
    val confidence: Double,
    val timeHorizon: String,
    val factors: List<String>
)

// Blockchain & Security DTOs
data class MedicalRecordRequest(
    @field:NotBlank
    val patientId: String,

    @field:NotBlank
    val recordType: RecordType,

    @field:NotEmpty
    val data: Map<String, Any>,

    val metadata: Map<String, Any>? = null,
    val accessLevel: AccessLevel? = AccessLevel.PATIENT_ONLY
)

data class MedicalRecordResponse(
    val recordId: String,
    val patientId: String,
    val recordType: RecordType,
    val blockchainHash: String,
    val timestamp: Long,
    val accessLevel: AccessLevel,
    val auditTrail: List<AuditEntry>
)

data class AuditEntry(
    val timestamp: Long,
    val action: String,
    val userId: String,
    val ipAddress: String,
    val userAgent: String
)

enum class RecordType {
    DIAGNOSIS, TREATMENT, MEDICATION, LAB_RESULT, IMAGING, CONSULTATION
}

enum class AccessLevel {
    PUBLIC, PATIENT_ONLY, HEALTHCARE_PROVIDER, EMERGENCY_ONLY
}

// VR/AR Medical Training DTOs
data class VRTrainingRequest(
    @field:NotBlank
    val traineeId: String,

    @field:NotBlank
    val scenarioType: ScenarioType,

    @field:NotBlank
    val difficultyLevel: DifficultyLevel,

    val patientProfile: Map<String, Any>? = null,
    val timeLimit: Int? = null
)

data class VRTrainingResponse(
    val sessionId: String,
    val traineeId: String,
    val scenarioType: ScenarioType,
    val score: Double,
    val feedback: List<TrainingFeedback>,
    val areasForImprovement: List<String>,
    val completedProcedures: List<String>,
    val timeSpent: Int
)

data class TrainingFeedback(
    val category: String,
    val score: Double,
    val comments: String,
    val timestamp: Long
)

enum class ScenarioType {
    EMERGENCY_RESPONSE, SURGICAL_PROCEDURE, PATIENT_ASSESSMENT, DIAGNOSTIC_PROCEDURE
}

enum class DifficultyLevel {
    BEGINNER, INTERMEDIATE, ADVANCED, EXPERT
}

// Global Health Coordination DTOs
data class OutbreakDetectionRequest(
    @field:NotBlank
    val region: String,

    @field:NotEmpty
    val symptoms: List<String>,

    @field:Min(1)
    val caseCount: Int,

    val demographics: Map<String, Any>? = null,
    val timeRange: TimeRange? = null
)

data class OutbreakDetectionResponse(
    val region: String,
    val outbreakProbability: Double,
    val predictedSpread: SpreadPrediction,
    val recommendedActions: List<String>,
    val resourceNeeds: ResourceRequirements,
    val alertLevel: AlertLevel
)

data class SpreadPrediction(
    val rate: Double,
    val direction: String,
    val affectedAreas: List<String>,
    val peakTime: String
)

data class ResourceRequirements(
    val medicalStaff: Int,
    val hospitalBeds: Int,
    val ventilators: Int,
    val medications: Map<String, Int>,
    val urgencyLevel: String
)

enum class AlertLevel {
    LOW, MODERATE, HIGH, CRITICAL, EMERGENCY
}

// Robotics Integration DTOs
data class RoboticProcedureRequest(
    @field:NotBlank
    val patientId: String,

    @field:NotBlank
    val procedureType: ProcedureType,

    @field:NotBlank
    val robotType: RobotType,

    val parameters: Map<String, Any>? = null,
    val safetyConstraints: Map<String, Any>? = null
)

data class RoboticProcedureResponse(
    val procedureId: String,
    val patientId: String,
    val status: ProcedureStatus,
    val progress: Double,
    val estimatedTimeRemaining: Int,
    val safetyAlerts: List<SafetyAlert>,
    val outcome: String? = null
)

data class SafetyAlert(
    val type: SafetyAlertType,
    val severity: AlertSeverity,
    val message: String,
    val timestamp: Long,
    val actionRequired: Boolean
)

enum class ProcedureType {
    SURGICAL_ASSISTANCE, REHABILITATION, MEDICATION_DELIVERY, SAMPLE_COLLECTION
}

enum class RobotType {
    SURGICAL_ROBOT, REHABILITATION_ROBOT, PHARMACY_ROBOT, DIAGNOSTIC_ROBOT
}

enum class ProcedureStatus {
    PREPARING, IN_PROGRESS, COMPLETED, PAUSED, CANCELLED
}

enum class SafetyAlertType {
    EMERGENCY_STOP, PARAMETER_DEVIATION, SYSTEM_ERROR, PATIENT_SAFETY
}
