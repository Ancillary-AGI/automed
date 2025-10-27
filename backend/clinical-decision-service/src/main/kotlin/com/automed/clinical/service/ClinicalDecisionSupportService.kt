package com.automed.clinical.service

import com.automed.clinical.dto.*
import com.automed.clinical.model.*
import org.springframework.kafka.core.KafkaTemplate
import org.springframework.stereotype.Service
import reactor.core.publisher.Flux
import reactor.core.publisher.Mono
import java.time.LocalDateTime
import java.util.*
import kotlin.math.*

@Service
class ClinicalDecisionSupportService(
    private val kafkaTemplate: KafkaTemplate<String, Any>
) {

    /**
     * Real-time Clinical Decision Support System
     * Analyzes patient data and provides evidence-based recommendations
     */
    fun analyzeClinicalData(request: ClinicalAnalysisRequest): Mono<ClinicalDecisionResponse> {
        return Mono.fromCallable {
            val riskScore = calculateRiskScore(request)
            val alerts = generateClinicalAlerts(request, riskScore)
            val recommendations = generateRecommendations(request, riskScore, alerts)
            val drugInteractions = checkDrugInteractions(request.medications)
            val labAlerts = analyzeLabResults(request.labResults)
            val vitalTrends = analyzeVitalTrends(request.vitalSigns)

            // Publish critical alerts to Kafka
            alerts.filter { it.severity == AlertSeverity.CRITICAL }
                .forEach { alert ->
                    kafkaTemplate.send("clinical-alerts", alert)
                }

            ClinicalDecisionResponse(
                patientId = request.patientId,
                analysisId = UUID.randomUUID().toString(),
                riskScore = riskScore,
                riskLevel = determineRiskLevel(riskScore),
                alerts = alerts,
                recommendations = recommendations,
                drugInteractions = drugInteractions,
                labAlerts = labAlerts,
                vitalTrends = vitalTrends,
                confidence = calculateConfidence(request),
                timestamp = LocalDateTime.now(),
                nextReviewTime = calculateNextReviewTime(riskScore)
            )
        }
    }

    /**
     * Sepsis Early Warning System
     * Uses SIRS criteria and qSOFA score for early sepsis detection
     */
    fun analyzeSepsisRisk(request: SepsisAnalysisRequest): Mono<SepsisRiskResponse> {
        return Mono.fromCallable {
            val qSofaScore = calculateQSofaScore(request.vitals)
            val sirsScore = calculateSirsScore(request.vitals, request.labResults)
            val lactateLevel = request.labResults["lactate"] as? Double ?: 0.0
            
            val sepsisRisk = when {
                qSofaScore >= 2 && lactateLevel > 2.0 -> SepsisRisk.HIGH
                qSofaScore >= 2 || sirsScore >= 2 -> SepsisRisk.MODERATE
                sirsScore >= 1 -> SepsisRisk.LOW
                else -> SepsisRisk.MINIMAL
            }

            val recommendations = when (sepsisRisk) {
                SepsisRisk.HIGH -> listOf(
                    "Immediate physician notification",
                    "Blood cultures before antibiotics",
                    "Broad-spectrum antibiotics within 1 hour",
                    "Fluid resuscitation 30ml/kg",
                    "Lactate measurement",
                    "Consider ICU transfer"
                )
                SepsisRisk.MODERATE -> listOf(
                    "Physician notification within 30 minutes",
                    "Blood cultures",
                    "Consider antibiotics",
                    "Monitor closely",
                    "Repeat lactate in 2-4 hours"
                )
                SepsisRisk.LOW -> listOf(
                    "Continue monitoring",
                    "Reassess in 4 hours",
                    "Consider infection workup"
                )
                SepsisRisk.MINIMAL -> listOf(
                    "Routine monitoring",
                    "Reassess if condition changes"
                )
            }

            SepsisRiskResponse(
                patientId = request.patientId,
                qSofaScore = qSofaScore,
                sirsScore = sirsScore,
                sepsisRisk = sepsisRisk,
                lactateLevel = lactateLevel,
                recommendations = recommendations,
                urgency = if (sepsisRisk == SepsisRisk.HIGH) "IMMEDIATE" else "ROUTINE",
                timestamp = LocalDateTime.now()
            )
        }
    }

    /**
     * Medication Dosing Calculator with Renal/Hepatic Adjustment
     */
    fun calculateMedicationDosing(request: MedicationDosingRequest): Mono<MedicationDosingResponse> {
        return Mono.fromCallable {
            val creatinineClearance = calculateCreatinineClearance(
                request.patientAge,
                request.patientWeight,
                request.serumCreatinine,
                request.patientGender
            )

            val adjustments = request.medications.map { medication ->
                val renalAdjustment = calculateRenalAdjustment(medication, creatinineClearance)
                val hepaticAdjustment = calculateHepaticAdjustment(medication, request.liverFunction)
                
                MedicationAdjustment(
                    medicationName = medication.name,
                    originalDose = medication.dose,
                    adjustedDose = applyAdjustments(medication.dose, renalAdjustment, hepaticAdjustment),
                    renalAdjustment = renalAdjustment,
                    hepaticAdjustment = hepaticAdjustment,
                    frequency = adjustFrequency(medication.frequency, renalAdjustment, hepaticAdjustment),
                    warnings = generateDosingWarnings(medication, creatinineClearance, request.liverFunction)
                )
            }

            MedicationDosingResponse(
                patientId = request.patientId,
                creatinineClearance = creatinineClearance,
                adjustments = adjustments,
                timestamp = LocalDateTime.now()
            )
        }
    }

    /**
     * Fall Risk Assessment using Morse Fall Scale
     */
    fun assessFallRisk(request: FallRiskAssessmentRequest): Mono<FallRiskResponse> {
        return Mono.fromCallable {
            var morseScore = 0

            // History of falling
            morseScore += if (request.historyOfFalls) 25 else 0

            // Secondary diagnosis
            morseScore += if (request.secondaryDiagnosis) 15 else 0

            // Ambulatory aid
            morseScore += when (request.ambulatoryAid) {
                "none" -> 0
                "crutches_cane_walker" -> 15
                "furniture" -> 30
                else -> 0
            }

            // IV/Heparin lock
            morseScore += if (request.ivTherapy) 20 else 0

            // Gait
            morseScore += when (request.gait) {
                "normal" -> 0
                "weak" -> 10
                "impaired" -> 20
                else -> 0
            }

            // Mental status
            morseScore += when (request.mentalStatus) {
                "oriented" -> 0
                "forgets_limitations" -> 15
                else -> 0
            }

            val riskLevel = when {
                morseScore >= 45 -> FallRiskLevel.HIGH
                morseScore >= 25 -> FallRiskLevel.MODERATE
                else -> FallRiskLevel.LOW
            }

            val interventions = when (riskLevel) {
                FallRiskLevel.HIGH -> listOf(
                    "Bed alarm activated",
                    "Fall risk bracelet",
                    "Frequent rounding every 1 hour",
                    "Assist with all mobility",
                    "Keep call light within reach",
                    "Non-slip socks",
                    "Consider bed rest"
                )
                FallRiskLevel.MODERATE -> listOf(
                    "Fall risk bracelet",
                    "Frequent rounding every 2 hours",
                    "Assist with ambulation",
                    "Keep call light within reach",
                    "Non-slip socks"
                )
                FallRiskLevel.LOW -> listOf(
                    "Standard fall precautions",
                    "Keep call light within reach",
                    "Clear pathways"
                )
            }

            FallRiskResponse(
                patientId = request.patientId,
                morseScore = morseScore,
                riskLevel = riskLevel,
                interventions = interventions,
                reassessmentInterval = when (riskLevel) {
                    FallRiskLevel.HIGH -> "Every 8 hours"
                    FallRiskLevel.MODERATE -> "Every 12 hours"
                    FallRiskLevel.LOW -> "Every 24 hours"
                },
                timestamp = LocalDateTime.now()
            )
        }
    }

    /**
     * Pressure Ulcer Risk Assessment using Braden Scale
     */
    fun assessPressureUlcerRisk(request: PressureUlcerRiskRequest): Mono<PressureUlcerRiskResponse> {
        return Mono.fromCallable {
            val bradenScore = request.sensoryPerception + request.moisture + request.activity +
                    request.mobility + request.nutrition + request.frictionShear

            val riskLevel = when {
                bradenScore <= 9 -> PressureUlcerRisk.VERY_HIGH
                bradenScore <= 12 -> PressureUlcerRisk.HIGH
                bradenScore <= 14 -> PressureUlcerRisk.MODERATE
                bradenScore <= 18 -> PressureUlcerRisk.MILD
                else -> PressureUlcerRisk.LOW
            }

            val interventions = when (riskLevel) {
                PressureUlcerRisk.VERY_HIGH -> listOf(
                    "Turn every 1-2 hours",
                    "Pressure-relieving mattress",
                    "Heel protectors",
                    "Skin assessment every shift",
                    "Nutritional consultation",
                    "Moisture barrier cream",
                    "Minimize head of bed elevation"
                )
                PressureUlcerRisk.HIGH -> listOf(
                    "Turn every 2 hours",
                    "Pressure-relieving surface",
                    "Heel protectors",
                    "Skin assessment daily",
                    "Nutritional support"
                )
                PressureUlcerRisk.MODERATE -> listOf(
                    "Turn every 2-3 hours",
                    "Foam mattress",
                    "Skin assessment daily",
                    "Adequate nutrition"
                )
                PressureUlcerRisk.MILD -> listOf(
                    "Turn every 4 hours",
                    "Standard mattress",
                    "Skin assessment every 2 days"
                )
                PressureUlcerRisk.LOW -> listOf(
                    "Standard precautions",
                    "Skin assessment weekly"
                )
            }

            PressureUlcerRiskResponse(
                patientId = request.patientId,
                bradenScore = bradenScore,
                riskLevel = riskLevel,
                interventions = interventions,
                reassessmentInterval = when (riskLevel) {
                    PressureUlcerRisk.VERY_HIGH, PressureUlcerRisk.HIGH -> "Every 8 hours"
                    PressureUlcerRisk.MODERATE -> "Every 24 hours"
                    PressureUlcerRisk.MILD -> "Every 48 hours"
                    PressureUlcerRisk.LOW -> "Weekly"
                },
                timestamp = LocalDateTime.now()
            )
        }
    }

    // Private helper methods

    private fun calculateRiskScore(request: ClinicalAnalysisRequest): Double {
        var score = 0.0

        // Age factor
        score += when {
            request.patientAge >= 80 -> 0.3
            request.patientAge >= 65 -> 0.2
            request.patientAge >= 50 -> 0.1
            else -> 0.0
        }

        // Vital signs assessment
        request.vitalSigns?.let { vitals ->
            // Heart rate
            val hr = vitals["heartRate"] as? Double ?: 0.0
            score += when {
                hr > 120 || hr < 50 -> 0.2
                hr > 100 || hr < 60 -> 0.1
                else -> 0.0
            }

            // Blood pressure
            val systolic = vitals["systolicBP"] as? Double ?: 0.0
            score += when {
                systolic > 180 || systolic < 90 -> 0.25
                systolic > 160 || systolic < 100 -> 0.15
                else -> 0.0
            }

            // Temperature
            val temp = vitals["temperature"] as? Double ?: 0.0
            score += when {
                temp > 101.5 || temp < 96.0 -> 0.2
                temp > 100.4 -> 0.1
                else -> 0.0
            }
        }

        // Comorbidities
        score += request.comorbidities.size * 0.05

        // Medications
        score += request.medications.size * 0.02

        return minOf(score, 1.0) // Cap at 1.0
    }

    private fun calculateQSofaScore(vitals: Map<String, Any>): Int {
        var score = 0

        // Respiratory rate >= 22
        val rr = vitals["respiratoryRate"] as? Double ?: 0.0
        if (rr >= 22) score++

        // Altered mental status (GCS < 15)
        val gcs = vitals["glasgowComaScale"] as? Int ?: 15
        if (gcs < 15) score++

        // Systolic BP <= 100
        val systolic = vitals["systolicBP"] as? Double ?: 0.0
        if (systolic <= 100) score++

        return score
    }

    private fun calculateSirsScore(vitals: Map<String, Any>, labs: Map<String, Any>): Int {
        var score = 0

        // Temperature > 38°C or < 36°C
        val temp = vitals["temperature"] as? Double ?: 0.0
        if (temp > 38.0 || temp < 36.0) score++

        // Heart rate > 90
        val hr = vitals["heartRate"] as? Double ?: 0.0
        if (hr > 90) score++

        // Respiratory rate > 20
        val rr = vitals["respiratoryRate"] as? Double ?: 0.0
        if (rr > 20) score++

        // WBC > 12,000 or < 4,000 or > 10% bands
        val wbc = labs["whiteBloodCells"] as? Double ?: 0.0
        val bands = labs["bands"] as? Double ?: 0.0
        if (wbc > 12000 || wbc < 4000 || bands > 10) score++

        return score
    }

    private fun calculateCreatinineClearance(age: Int, weight: Double, creatinine: Double, gender: String): Double {
        // Cockcroft-Gault equation
        val genderFactor = if (gender.lowercase() == "female") 0.85 else 1.0
        return ((140 - age) * weight * genderFactor) / (72 * creatinine)
    }

    private fun generateClinicalAlerts(request: ClinicalAnalysisRequest, riskScore: Double): List<ClinicalAlert> {
        val alerts = mutableListOf<ClinicalAlert>()

        // High risk score alert
        if (riskScore > 0.7) {
            alerts.add(ClinicalAlert(
                id = UUID.randomUUID().toString(),
                type = AlertType.HIGH_RISK_PATIENT,
                severity = AlertSeverity.CRITICAL,
                message = "Patient has high clinical risk score: ${String.format("%.2f", riskScore)}",
                recommendations = listOf("Increase monitoring frequency", "Consider physician consultation"),
                timestamp = LocalDateTime.now()
            ))
        }

        // Vital signs alerts
        request.vitalSigns?.let { vitals ->
            checkVitalSignsAlerts(vitals).forEach { alerts.add(it) }
        }

        // Lab results alerts
        request.labResults?.let { labs ->
            checkLabResultsAlerts(labs).forEach { alerts.add(it) }
        }

        return alerts
    }

    private fun checkVitalSignsAlerts(vitals: Map<String, Any>): List<ClinicalAlert> {
        val alerts = mutableListOf<ClinicalAlert>()

        // Critical vital signs
        val hr = vitals["heartRate"] as? Double ?: 0.0
        if (hr > 150 || hr < 40) {
            alerts.add(ClinicalAlert(
                id = UUID.randomUUID().toString(),
                type = AlertType.CRITICAL_VITALS,
                severity = AlertSeverity.CRITICAL,
                message = "Critical heart rate: $hr bpm",
                recommendations = listOf("Immediate physician notification", "Continuous cardiac monitoring"),
                timestamp = LocalDateTime.now()
            ))
        }

        val systolic = vitals["systolicBP"] as? Double ?: 0.0
        if (systolic > 200 || systolic < 80) {
            alerts.add(ClinicalAlert(
                id = UUID.randomUUID().toString(),
                type = AlertType.CRITICAL_VITALS,
                severity = AlertSeverity.CRITICAL,
                message = "Critical blood pressure: $systolic mmHg",
                recommendations = listOf("Immediate physician notification", "Consider antihypertensive therapy"),
                timestamp = LocalDateTime.now()
            ))
        }

        return alerts
    }

    private fun checkLabResultsAlerts(labs: Map<String, Any>): List<ClinicalAlert> {
        val alerts = mutableListOf<ClinicalAlert>()

        // Critical lab values
        val potassium = labs["potassium"] as? Double ?: 0.0
        if (potassium > 6.0 || potassium < 2.5) {
            alerts.add(ClinicalAlert(
                id = UUID.randomUUID().toString(),
                type = AlertType.CRITICAL_LAB,
                severity = AlertSeverity.CRITICAL,
                message = "Critical potassium level: $potassium mEq/L",
                recommendations = listOf("Immediate physician notification", "ECG monitoring", "Consider treatment"),
                timestamp = LocalDateTime.now()
            ))
        }

        val glucose = labs["glucose"] as? Double ?: 0.0
        if (glucose > 400 || glucose < 50) {
            alerts.add(ClinicalAlert(
                id = UUID.randomUUID().toString(),
                type = AlertType.CRITICAL_LAB,
                severity = AlertSeverity.CRITICAL,
                message = "Critical glucose level: $glucose mg/dL",
                recommendations = listOf("Immediate physician notification", "Blood sugar management"),
                timestamp = LocalDateTime.now()
            ))
        }

        return alerts
    }

    private fun generateRecommendations(
        request: ClinicalAnalysisRequest,
        riskScore: Double,
        alerts: List<ClinicalAlert>
    ): List<String> {
        val recommendations = mutableListOf<String>()

        when {
            riskScore > 0.8 -> {
                recommendations.add("Consider ICU transfer")
                recommendations.add("Increase monitoring to every 15 minutes")
                recommendations.add("Immediate physician consultation")
            }
            riskScore > 0.6 -> {
                recommendations.add("Increase monitoring frequency")
                recommendations.add("Physician notification within 30 minutes")
                recommendations.add("Consider additional diagnostic tests")
            }
            riskScore > 0.4 -> {
                recommendations.add("Continue current monitoring")
                recommendations.add("Reassess in 2 hours")
            }
        }

        // Add specific recommendations based on alerts
        if (alerts.any { it.severity == AlertSeverity.CRITICAL }) {
            recommendations.add("Implement critical care protocols")
        }

        return recommendations
    }

    private fun checkDrugInteractions(medications: List<String>): List<DrugInteraction> {
        // Simplified drug interaction checking
        val interactions = mutableListOf<DrugInteraction>()
        
        // Common dangerous interactions
        if (medications.contains("warfarin") && medications.contains("aspirin")) {
            interactions.add(DrugInteraction(
                drug1 = "Warfarin",
                drug2 = "Aspirin",
                severity = InteractionSeverity.HIGH,
                description = "Increased bleeding risk",
                recommendation = "Monitor INR closely, consider alternative"
            ))
        }

        return interactions
    }

    private fun analyzeLabResults(labs: Map<String, Any>?): List<LabAlert> {
        if (labs == null) return emptyList()
        
        val alerts = mutableListOf<LabAlert>()
        
        // Check for abnormal values
        labs.forEach { (test, value) ->
            when (test) {
                "creatinine" -> {
                    val creat = value as? Double ?: 0.0
                    if (creat > 2.0) {
                        alerts.add(LabAlert(
                            test = test,
                            value = creat,
                            normalRange = "0.6-1.2 mg/dL",
                            severity = if (creat > 4.0) AlertSeverity.CRITICAL else AlertSeverity.HIGH,
                            interpretation = "Elevated creatinine suggests kidney dysfunction"
                        ))
                    }
                }
                // Add more lab checks...
            }
        }
        
        return alerts
    }

    private fun analyzeVitalTrends(vitals: Map<String, Any>?): List<VitalTrend> {
        if (vitals == null) return emptyList()
        
        // This would analyze historical trends
        return listOf(
            VitalTrend(
                parameter = "Heart Rate",
                trend = "Increasing",
                significance = "Monitor for tachycardia",
                recommendation = "Continue monitoring"
            )
        )
    }

    private fun calculateConfidence(request: ClinicalAnalysisRequest): Double {
        var confidence = 0.8 // Base confidence
        
        // Adjust based on data completeness
        if (request.vitalSigns != null) confidence += 0.1
        if (request.labResults != null) confidence += 0.1
        if (request.comorbidities.isNotEmpty()) confidence += 0.05
        
        return minOf(confidence, 1.0)
    }

    private fun calculateNextReviewTime(riskScore: Double): LocalDateTime {
        val hoursToAdd = when {
            riskScore > 0.8 -> 1L
            riskScore > 0.6 -> 2L
            riskScore > 0.4 -> 4L
            else -> 8L
        }
        return LocalDateTime.now().plusHours(hoursToAdd)
    }

    private fun determineRiskLevel(riskScore: Double): RiskLevel {
        return when {
            riskScore > 0.8 -> RiskLevel.CRITICAL
            riskScore > 0.6 -> RiskLevel.HIGH
            riskScore > 0.4 -> RiskLevel.MODERATE
            else -> RiskLevel.LOW
        }
    }

    private fun calculateRenalAdjustment(medication: MedicationInfo, creatinineClearance: Double): Double {
        // Simplified renal adjustment - in reality this would use drug-specific data
        return when {
            creatinineClearance < 30 -> 0.5 // 50% dose reduction
            creatinineClearance < 60 -> 0.75 // 25% dose reduction
            else -> 1.0 // No adjustment
        }
    }

    private fun calculateHepaticAdjustment(medication: MedicationInfo, liverFunction: String): Double {
        return when (liverFunction.lowercase()) {
            "severe" -> 0.5
            "moderate" -> 0.75
            else -> 1.0
        }
    }

    private fun applyAdjustments(originalDose: String, renalAdj: Double, hepaticAdj: Double): String {
        // Extract numeric dose and apply adjustments
        val doseRegex = Regex("""(\d+(?:\.\d+)?)""")
        val match = doseRegex.find(originalDose)
        
        return if (match != null) {
            val dose = match.value.toDouble()
            val adjustedDose = dose * renalAdj * hepaticAdj
            originalDose.replace(match.value, String.format("%.1f", adjustedDose))
        } else {
            originalDose
        }
    }

    private fun adjustFrequency(frequency: String, renalAdj: Double, hepaticAdj: Double): String {
        // Adjust frequency based on clearance
        val totalAdj = renalAdj * hepaticAdj
        return when {
            totalAdj <= 0.5 -> frequency.replace("q8h", "q12h").replace("q6h", "q8h")
            totalAdj <= 0.75 -> frequency.replace("q6h", "q8h")
            else -> frequency
        }
    }

    private fun generateDosingWarnings(
        medication: MedicationInfo,
        creatinineClearance: Double,
        liverFunction: String
    ): List<String> {
        val warnings = mutableListOf<String>()
        
        if (creatinineClearance < 30) {
            warnings.add("Severe renal impairment - monitor closely")
        }
        
        if (liverFunction == "severe") {
            warnings.add("Severe hepatic impairment - consider alternative")
        }
        
        return warnings
    }
}