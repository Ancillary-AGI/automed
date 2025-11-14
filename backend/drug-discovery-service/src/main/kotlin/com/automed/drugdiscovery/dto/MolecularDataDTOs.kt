package com.automed.drugdiscovery.dto

import java.time.LocalDateTime

data class MoleculeDTO(
    val id: String? = null,
    val smiles: String,
    val name: String? = null,
    val molecularWeight: Double? = null,
    val logP: Double? = null,
    val hBondDonors: Int? = null,
    val hBondAcceptors: Int? = null,
    val rotatableBonds: Int? = null,
    val polarSurfaceArea: Double? = null,
    val properties: Map<String, Any> = emptyMap(),
    val createdAt: LocalDateTime = LocalDateTime.now(),
    val updatedAt: LocalDateTime = LocalDateTime.now()
)

data class MolecularFingerprintDTO(
    val moleculeId: String,
    val fingerprintType: String, // "morgan", "maccs", "daylight"
    val fingerprint: List<Int>,
    val radius: Int? = null,
    val bits: Int? = null
)

data class MolecularPropertyDTO(
    val moleculeId: String,
    val propertyName: String,
    val propertyValue: Any,
    val propertyType: String, // "numeric", "categorical", "boolean"
    val source: String, // "calculated", "experimental", "predicted"
    val confidence: Double? = null,
    val units: String? = null
)

data class MolecularSimilarityDTO(
    val moleculeId1: String,
    val moleculeId2: String,
    val similarityScore: Double,
    val similarityMetric: String, // "tanimoto", "cosine", "euclidean"
    val fingerprintType: String
)

data class ProteinTargetDTO(
    val id: String? = null,
    val uniprotId: String,
    val name: String,
    val sequence: String,
    val organism: String,
    val function: String? = null,
    val structureAvailable: Boolean = false,
    val pdbIds: List<String> = emptyList(),
    val createdAt: LocalDateTime = LocalDateTime.now()
)

data class BindingSiteDTO(
    val proteinId: String,
    val siteId: String,
    val residues: List<String>,
    val coordinates: List<Triple<Double, Double, Double>>, // x, y, z coordinates
    val bindingAffinity: Double? = null,
    val ligands: List<String> = emptyList()
)