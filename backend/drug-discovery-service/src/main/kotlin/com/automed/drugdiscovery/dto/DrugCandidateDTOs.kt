package com.automed.drugdiscovery.dto

import java.time.LocalDateTime

data class DrugCandidateDTO(
    val id: String? = null,
    val moleculeId: String,
    val name: String,
    val therapeuticArea: String,
    val targetIds: List<String> = emptyList(),
    val stage: DrugDevelopmentStage,
    val predictedActivity: Double? = null,
    val predictedToxicity: Double? = null,
    val admetProperties: ADMETPropertiesDTO? = null,
    val synthesisRoute: String? = null,
    val patentStatus: PatentStatus = PatentStatus.NOT_PATENTED,
    val clinicalTrialIds: List<String> = emptyList(),
    val createdAt: LocalDateTime = LocalDateTime.now(),
    val updatedAt: LocalDateTime = LocalDateTime.now()
)

enum class DrugDevelopmentStage {
    DISCOVERY,
    PRECLINICAL,
    PHASE_1,
    PHASE_2,
    PHASE_3,
    APPROVED,
    WITHDRAWN
}

enum class PatentStatus {
    NOT_PATENTED,
    PENDING,
    PATENTED,
    EXPIRED
}

data class ADMETPropertiesDTO(
    val absorption: Double? = null, // Human intestinal absorption %
    val distribution: Double? = null, // Volume of distribution
    val metabolism: Double? = null, // Hepatic clearance
    val excretion: Double? = null, // Renal clearance
    val toxicity: ToxicityPredictionDTO? = null
)

data class ToxicityPredictionDTO(
    val hepatotoxicity: Double? = null, // Probability of liver toxicity
    val cardiotoxicity: Double? = null, // Probability of heart toxicity
    val nephrotoxicity: Double? = null, // Probability of kidney toxicity
    val mutagenicity: Double? = null, // Probability of causing mutations
    val carcinogenicity: Double? = null, // Probability of causing cancer
    val overallRisk: String? = null // "Low", "Medium", "High"
)

data class DrugRepurposingDTO(
    val existingDrugId: String,
    val newIndication: String,
    val predictedEfficacy: Double,
    val mechanismOfAction: String,
    val supportingEvidence: List<String> = emptyList(),
    val clinicalTrialSuggestion: String? = null
)

data class VirtualScreeningResultDTO(
    val queryId: String,
    val moleculeId: String,
    val score: Double,
    val rank: Int,
    val dockingPose: DockingPoseDTO? = null,
    val bindingAffinity: Double? = null
)

data class DockingPoseDTO(
    val coordinates: List<Triple<Double, Double, Double>>,
    val energy: Double,
    val rmsd: Double? = null,
    val interactions: List<InteractionDTO> = emptyList()
)

data class InteractionDTO(
    val type: String, // "hydrogen_bond", "hydrophobic", "electrostatic"
    val ligandAtom: String,
    val proteinResidue: String,
    val distance: Double
)