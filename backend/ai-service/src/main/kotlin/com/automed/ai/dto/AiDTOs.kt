package com.automed.ai.dto

import jakarta.validation.constraints.*
import java.util.*

data class DiagnosisPredictionRequest(
    @field:NotBlank
    val patientId: String,

    @field:NotEmpty
    val symptoms: List<String>,

    @field:NotEmpty
    val vitals: Map<String, Double>,

    val medicalHistory: String? = null,
    val age: Int? = null,
    val gender: String? = null
)

data class DiagnosisPredictionResponse(
    val predictions: List<DiagnosisPrediction>,
    val confidence: Double,
    val recommendations: List<String>,
    val riskLevel: String? = null,
    val additionalInfo: Map<String, Any>? = null
)

data class DiagnosisPrediction(
    val condition: String,
    val probability: Double,
    val severity: String,
    val description: String? = null,
    val suggestedTests: List<String>? = null
)

data class SymptomAnalysisRequest(
    @field:NotEmpty
    val symptoms: List<String>,

    @field:Min(1)
    val duration: Int,

    @field:NotBlank
    val severity: String,

    val patientId: String? = null,
    val context: Map<String, Any>? = null
)

data class SymptomAnalysisResponse(
    val relatedSymptoms: List<String>,
    val possibleCauses: List<String>,
    val urgencyLevel: String,
    val recommendations: List<String>,
    val nextSteps: String? = null
)

data class TriageRequest(
    @field:NotBlank
    val patientId: String,

    @field:NotEmpty
    val symptoms: List<String>,

    @field:NotEmpty
    val vitals: Map<String, Double>,

    val chiefComplaint: String? = null,
    val painLevel: Int? = null,
    val age: Int? = null
)

data class TriageResponse(
    val priority: String,
    val estimatedWaitTime: Int,
    val recommendedDepartment: String,
    val urgencyScore: Double,
    val reasoning: String
)

data class VitalsAnalysisRequest(
    @field:NotEmpty
    val vitals: Map<String, Double>,

    val patientId: String? = null,
    val age: Int? = null,
    val gender: String? = null,
    val medicalHistory: List<String>? = null
)

data class VitalsAnalysisResponse(
    val abnormalValues: List<AbnormalVital>,
    val overallAssessment: String,
    val recommendations: List<String>,
    val riskFactors: List<String>
)

data class AbnormalVital(
    val parameter: String,
    val value: Double,
    val normalRange: String,
    val severity: String,
    val description: String
)

data class DrugInteractionRequest(
    @field:NotEmpty
    val medications: List<String>,

    val patientId: String? = null,
    val allergies: List<String>? = null,
    val medicalConditions: List<String>? = null
)

data class DrugInteractionResponse(
    val interactions: List<DrugInteraction>,
    val contraindications: List<String>,
    val warnings: List<String>,
    val overallRisk: String
)

data class DrugInteraction(
    val drug1: String,
    val drug2: String,
    val severity: String,
    val description: String,
    val recommendation: String
)

data class AiModelInfo(
    val id: String,
    val name: String,
    val version: String,
    val type: String,
    val description: String? = null,
    val supportedFeatures: List<String>? = null,
    val size: Long? = null,
    val lastUpdated: String? = null
)

data class ModelDownloadResponse(
    val downloadUrl: String,
    val checksum: String,
    val size: Long,
    val expiresAt: String
)

data class AiFeedbackRequest(
    @field:NotBlank
    val predictionId: String,

    @field:NotBlank
    val actualOutcome: String,

    @field:Min(1)
    @field:Max(5)
    val accuracy: Int,

    val comments: String? = null,
    val userId: String? = null
)

data class AiFeedbackResponse(
    val success: Boolean,
    val message: String,
    val feedbackId: String
)



data class PredictiveHealthRequest(
    @field:NotBlank
    val patientId: String,

    @field:NotEmpty
    val historicalData: List<HealthDataPoint>,

    @field:Min(1)
    val predictionDays: Int,

    val riskFactors: List<String>? = null,
    val currentMedications: List<String>? = null
)

data class HealthDataPoint(
    val timestamp: Long,
    val heartRate: Double?,
    val bloodPressureSystolic: Double?,
    val bloodPressureDiastolic: Double?,
    val temperature: Double?,
    val oxygenSaturation: Double?,
    val symptoms: List<String>? = null,
    val mood: String? = null
)

data class PredictiveHealthResponse(
    val patientId: String,
    val riskScore: Double,
    val riskLevel: RiskLevel,
    val predictions: List<HealthPrediction>,
    val recommendations: List<String>,
    val alerts: List<HealthAlert>,
    val confidence: Double,
    val nextCheckupDate: String?
)

data class HealthPrediction(
    val metric: String,
    val predictedValue: Double,
    val confidence: Double,
    val trend: TrendDirection,
    val description: String
)

data class HealthAlert(
    val type: AlertType,
    val severity: AlertSeverity,
    val message: String,
    val suggestedAction: String,
    val timestamp: Long
)

enum class RiskLevel {
    LOW, MODERATE, HIGH, CRITICAL
}

enum class TrendDirection {
    IMPROVING, STABLE, DECLINING, VOLATILE
}

enum class AlertType {
    DETERIORATION_RISK, MEDICATION_REMINDER, APPOINTMENT_NEEDED, EMERGENCY
}

enum class AlertSeverity {
    INFO, WARNING, CRITICAL
