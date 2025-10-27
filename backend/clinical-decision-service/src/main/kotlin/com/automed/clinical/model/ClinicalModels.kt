package com.automed.clinical.model

// Risk Level Enums
enum class RiskLevel {
    LOW, MODERATE, HIGH, CRITICAL
}

enum class SepsisRisk {
    MINIMAL, LOW, MODERATE, HIGH
}

enum class FallRiskLevel {
    LOW, MODERATE, HIGH
}

enum class PressureUlcerRisk {
    LOW, MILD, MODERATE, HIGH, VERY_HIGH
}

enum class EarlyWarningRisk {
    LOW, MEDIUM, HIGH, CRITICAL
}

enum class CardiacRisk {
    LOW, MODERATE, HIGH
}

enum class StrokeRisk {
    LOW, MODERATE, HIGH
}

enum class PainLevel {
    NONE, MILD, MODERATE, SEVERE
}

// Alert and Severity Enums
enum class AlertType {
    HIGH_RISK_PATIENT,
    CRITICAL_VITALS,
    CRITICAL_LAB,
    DRUG_INTERACTION,
    FALL_RISK,
    PRESSURE_ULCER_RISK,
    SEPSIS_RISK,
    CARDIAC_RISK,
    STROKE_RISK,
    DELIRIUM_RISK,
    PAIN_MANAGEMENT,
    MEDICATION_ERROR,
    ALLERGY_ALERT,
    INFECTION_CONTROL
}

enum class AlertSeverity {
    INFO, WARNING, HIGH, CRITICAL
}

enum class InteractionSeverity {
    MINOR, MODERATE, MAJOR, CONTRAINDICATED
}

// Clinical Pathway Models
data class ClinicalPathway(
    val id: String,
    val name: String,
    val condition: String,
    val steps: List<PathwayStep>,
    val triggers: List<PathwayTrigger>,
    val outcomes: List<PathwayOutcome>
)

data class PathwayStep(
    val id: String,
    val order: Int,
    val title: String,
    val description: String,
    val actions: List<String>,
    val timeframe: String,
    val responsible: String, // role responsible for this step
    val prerequisites: List<String>,
    val completionCriteria: List<String>
)

data class PathwayTrigger(
    val condition: String,
    val value: Any,
    val operator: String // equals, greater_than, less_than, etc.
)

data class PathwayOutcome(
    val metric: String,
    val target: String,
    val measurement: String
)

// Quality Metrics Models
data class QualityMetric(
    val id: String,
    val name: String,
    val category: QualityCategory,
    val value: Double,
    val target: Double,
    val unit: String,
    val trend: String, // improving, declining, stable
    val benchmark: Double? = null
)

enum class QualityCategory {
    PATIENT_SAFETY,
    CLINICAL_EFFECTIVENESS,
    PATIENT_EXPERIENCE,
    EFFICIENCY,
    EQUITY,
    TIMELINESS
}

// Evidence-Based Guidelines Models
data class ClinicalGuideline(
    val id: String,
    val title: String,
    val organization: String,
    val version: String,
    val lastUpdated: String,
    val recommendations: List<Recommendation>,
    val evidenceLevel: EvidenceLevel
)

data class Recommendation(
    val id: String,
    val text: String,
    val strength: RecommendationStrength,
    val evidenceLevel: EvidenceLevel,
    val applicableConditions: List<String>,
    val contraindications: List<String>
)

enum class EvidenceLevel {
    LEVEL_1A, // Systematic review of RCTs
    LEVEL_1B, // Individual RCT
    LEVEL_2A, // Systematic review of cohort studies
    LEVEL_2B, // Individual cohort study
    LEVEL_3A, // Systematic review of case-control studies
    LEVEL_3B, // Individual case-control study
    LEVEL_4,  // Case series
    LEVEL_5   // Expert opinion
}

enum class RecommendationStrength {
    STRONG_FOR,
    WEAK_FOR,
    WEAK_AGAINST,
    STRONG_AGAINST
}

// Clinical Decision Rules Models
data class ClinicalDecisionRule(
    val id: String,
    val name: String,
    val purpose: String,
    val criteria: List<DecisionCriteria>,
    val scoring: ScoringMethod,
    val interpretation: List<ScoreInterpretation>
)

data class DecisionCriteria(
    val criterion: String,
    val points: Int,
    val description: String
)

data class ScoringMethod(
    val type: String, // additive, weighted, categorical
    val maxScore: Int,
    val minScore: Int
)

data class ScoreInterpretation(
    val scoreRange: String,
    val risk: String,
    val recommendation: String
)

// Medication Safety Models
data class MedicationSafetyCheck(
    val patientId: String,
    val medicationName: String,
    val dose: String,
    val route: String,
    val frequency: String,
    val allergies: List<String>,
    val interactions: List<DrugInteraction>,
    val contraindications: List<String>,
    val warnings: List<String>,
    val safetyScore: Double
)

data class DrugInteraction(
    val drug1: String,
    val drug2: String,
    val severity: InteractionSeverity,
    val mechanism: String,
    val clinicalEffect: String,
    val management: String
)

// Infection Control Models
data class InfectionControlAssessment(
    val patientId: String,
    val isolationPrecautions: List<IsolationPrecaution>,
    val riskFactors: List<String>,
    val surveillanceCultures: List<String>,
    val antibioticStewardship: AntibioticRecommendation?
)

data class IsolationPrecaution(
    val type: IsolationType,
    val indication: String,
    val duration: String,
    val requirements: List<String>
)

enum class IsolationType {
    STANDARD,
    CONTACT,
    DROPLET,
    AIRBORNE,
    PROTECTIVE
}

data class AntibioticRecommendation(
    val indication: String,
    val recommendedAntibiotics: List<String>,
    val duration: String,
    val monitoring: List<String>,
    val deEscalationCriteria: List<String>
)

// Nutritional Assessment Models
data class NutritionalAssessment(
    val patientId: String,
    val bmi: Double,
    val albumin: Double?,
    val prealbumin: Double?,
    val weightLoss: Double?, // percentage in last 6 months
    val appetiteChanges: Boolean,
    val swallowingDifficulty: Boolean,
    val nutritionalRisk: NutritionalRisk,
    val recommendations: List<String>
)

enum class NutritionalRisk {
    LOW, MODERATE, HIGH
}

// Discharge Planning Models
data class DischargePlan(
    val patientId: String,
    val estimatedDischargeDate: String,
    val dischargeDestination: DischargeDestination,
    val requiredServices: List<String>,
    val medications: List<DischargeMedication>,
    val followUpAppointments: List<FollowUpAppointment>,
    val educationProvided: List<String>,
    val barriers: List<String>
)

enum class DischargeDestination {
    HOME,
    HOME_WITH_SERVICES,
    SKILLED_NURSING_FACILITY,
    REHABILITATION_FACILITY,
    LONG_TERM_CARE,
    HOSPICE,
    TRANSFER_TO_ANOTHER_HOSPITAL
}

data class DischargeMedication(
    val name: String,
    val dose: String,
    val frequency: String,
    val duration: String,
    val indication: String,
    val instructions: String
)

data class FollowUpAppointment(
    val provider: String,
    val specialty: String,
    val timeframe: String,
    val reason: String,
    val priority: AppointmentPriority
)

enum class AppointmentPriority {
    URGENT, // within 1 week
    ROUTINE, // within 2-4 weeks
    FOLLOW_UP // within 1-3 months
}