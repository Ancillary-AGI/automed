package com.automed.clinical.dto

import com.automed.clinical.model.*
import jakarta.validation.constraints.*
import java.time.LocalDateTime

// Clinical Analysis DTOs
data class ClinicalAnalysisRequest(
    @field:NotBlank
    val patientId: String,
    
    @field:Min(0)
    val patientAge: Int,
    
    val vitalSigns: Map<String, Any>? = null,
    val labResults: Map<String, Any>? = null,
    val medications: List<String> = emptyList(),
    val comorbidities: List<String> = emptyList(),
    val symptoms: List<String> = emptyList(),
    val allergies: List<String> = emptyList()
)

data class ClinicalDecisionResponse(
    val patientId: String,
    val analysisId: String,
    val riskScore: Double,
    val riskLevel: RiskLevel,
    val alerts: List<ClinicalAlert>,
    val recommendations: List<String>,
    val drugInteractions: List<DrugInteraction>,
    val labAlerts: List<LabAlert>,
    val vitalTrends: List<VitalTrend>,
    val confidence: Double,
    val timestamp: LocalDateTime,
    val nextReviewTime: LocalDateTime
)

// Sepsis Analysis DTOs
data class SepsisAnalysisRequest(
    @field:NotBlank
    val patientId: String,
    
    @field:NotEmpty
    val vitals: Map<String, Any>,
    
    val labResults: Map<String, Any> = emptyMap(),
    val symptoms: List<String> = emptyList()
)

data class SepsisRiskResponse(
    val patientId: String,
    val qSofaScore: Int,
    val sirsScore: Int,
    val sepsisRisk: SepsisRisk,
    val lactateLevel: Double,
    val recommendations: List<String>,
    val urgency: String,
    val timestamp: LocalDateTime
)

// Medication Dosing DTOs
data class MedicationDosingRequest(
    @field:NotBlank
    val patientId: String,
    
    @field:Min(0)
    val patientAge: Int,
    
    @field:Min(0)
    val patientWeight: Double,
    
    @field:Min(0)
    val serumCreatinine: Double,
    
    @field:NotBlank
    val patientGender: String,
    
    val liverFunction: String = "normal",
    
    @field:NotEmpty
    val medications: List<MedicationInfo>
)

data class MedicationInfo(
    val name: String,
    val dose: String,
    val frequency: String,
    val route: String
)

data class MedicationDosingResponse(
    val patientId: String,
    val creatinineClearance: Double,
    val adjustments: List<MedicationAdjustment>,
    val timestamp: LocalDateTime
)

data class MedicationAdjustment(
    val medicationName: String,
    val originalDose: String,
    val adjustedDose: String,
    val renalAdjustment: Double,
    val hepaticAdjustment: Double,
    val frequency: String,
    val warnings: List<String>
)

// Fall Risk Assessment DTOs
data class FallRiskAssessmentRequest(
    @field:NotBlank
    val patientId: String,
    
    val historyOfFalls: Boolean,
    val secondaryDiagnosis: Boolean,
    val ambulatoryAid: String, // none, crutches_cane_walker, furniture
    val ivTherapy: Boolean,
    val gait: String, // normal, weak, impaired
    val mentalStatus: String // oriented, forgets_limitations
)

data class FallRiskResponse(
    val patientId: String,
    val morseScore: Int,
    val riskLevel: FallRiskLevel,
    val interventions: List<String>,
    val reassessmentInterval: String,
    val timestamp: LocalDateTime
)

// Pressure Ulcer Risk DTOs
data class PressureUlcerRiskRequest(
    @field:NotBlank
    val patientId: String,
    
    @field:Min(1) @field:Max(4)
    val sensoryPerception: Int, // 1-4 scale
    
    @field:Min(1) @field:Max(4)
    val moisture: Int,
    
    @field:Min(1) @field:Max(4)
    val activity: Int,
    
    @field:Min(1) @field:Max(4)
    val mobility: Int,
    
    @field:Min(1) @field:Max(4)
    val nutrition: Int,
    
    @field:Min(1) @field:Max(3)
    val frictionShear: Int // 1-3 scale
)

data class PressureUlcerRiskResponse(
    val patientId: String,
    val bradenScore: Int,
    val riskLevel: PressureUlcerRisk,
    val interventions: List<String>,
    val reassessmentInterval: String,
    val timestamp: LocalDateTime
)

// Supporting DTOs
data class ClinicalAlert(
    val id: String,
    val type: AlertType,
    val severity: AlertSeverity,
    val message: String,
    val recommendations: List<String>,
    val timestamp: LocalDateTime
)

data class DrugInteraction(
    val drug1: String,
    val drug2: String,
    val severity: InteractionSeverity,
    val description: String,
    val recommendation: String
)

data class LabAlert(
    val test: String,
    val value: Any,
    val normalRange: String,
    val severity: AlertSeverity,
    val interpretation: String
)

data class VitalTrend(
    val parameter: String,
    val trend: String, // increasing, decreasing, stable
    val significance: String,
    val recommendation: String
)

// Early Warning System DTOs
data class EarlyWarningScoreRequest(
    @field:NotBlank
    val patientId: String,
    
    @field:NotEmpty
    val vitals: Map<String, Double>,
    
    val consciousness: String = "alert", // alert, voice, pain, unresponsive
    val supplementalOxygen: Boolean = false
)

data class EarlyWarningScoreResponse(
    val patientId: String,
    val newsScore: Int, // National Early Warning Score
    val riskLevel: EarlyWarningRisk,
    val recommendations: List<String>,
    val escalationRequired: Boolean,
    val timestamp: LocalDateTime
)

// Cardiac Risk Assessment DTOs
data class CardiacRiskAssessmentRequest(
    @field:NotBlank
    val patientId: String,
    
    @field:Min(0)
    val age: Int,
    
    val gender: String,
    val chestPain: Boolean,
    val shortnessOfBreath: Boolean,
    val diaphoresis: Boolean,
    val nausea: Boolean,
    val radiatingPain: Boolean,
    val riskFactors: List<String>, // diabetes, hypertension, smoking, etc.
    val ecgFindings: List<String> = emptyList(),
    val troponinLevel: Double? = null
)

data class CardiacRiskResponse(
    val patientId: String,
    val heartScore: Int, // HEART score for chest pain
    val riskLevel: CardiacRisk,
    val recommendations: List<String>,
    val disposition: String, // discharge, observation, admission
    val followUpRequired: Boolean,
    val timestamp: LocalDateTime
)

// Stroke Risk Assessment DTOs
data class StrokeRiskAssessmentRequest(
    @field:NotBlank
    val patientId: String,
    
    val faceDropping: Boolean,
    val armWeakness: Boolean,
    val speechDifficulty: Boolean,
    val timeOfOnset: LocalDateTime?,
    val bloodGlucose: Double? = null,
    val bloodPressure: Map<String, Double>? = null,
    val nihssScore: Int? = null // NIH Stroke Scale
)

data class StrokeRiskResponse(
    val patientId: String,
    val fastScore: Int, // Face, Arms, Speech, Time
    val strokeLikelihood: StrokeRisk,
    val timeWindow: String, // for thrombolytic therapy
    val recommendations: List<String>,
    val urgentActions: List<String>,
    val timestamp: LocalDateTime
)

// Delirium Assessment DTOs
data class DeliriumAssessmentRequest(
    @field:NotBlank
    val patientId: String,
    
    val acuteOnset: Boolean,
    val inattention: Boolean,
    val disorganizedThinking: Boolean,
    val alteredConsciousness: Boolean,
    val riskFactors: List<String> // age, dementia, infection, etc.
)

data class DeliriumAssessmentResponse(
    val patientId: String,
    val camScore: Int, // Confusion Assessment Method
    val deliriumPresent: Boolean,
    val riskFactors: List<String>,
    val interventions: List<String>,
    val timestamp: LocalDateTime
)

// Pain Assessment DTOs
data class PainAssessmentRequest(
    @field:NotBlank
    val patientId: String,
    
    @field:Min(0) @field:Max(10)
    val painScore: Int,
    
    val painLocation: String,
    val painType: String, // sharp, dull, burning, etc.
    val painDuration: String,
    val alleviatingFactors: List<String>,
    val aggravatingFactors: List<String>,
    val currentMedications: List<String>
)

data class PainAssessmentResponse(
    val patientId: String,
    val painLevel: PainLevel,
    val recommendations: List<String>,
    val nonPharmacologicInterventions: List<String>,
    val pharmacologicOptions: List<String>,
    val reassessmentInterval: String,
    val timestamp: LocalDateTime
)