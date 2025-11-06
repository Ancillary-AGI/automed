package com.automed.patient.model

import jakarta.persistence.*
import java.time.LocalDateTime

@Entity
@Table(name = "blockchain_blocks")
data class Block(
    @Id
    val id: String,
    val previousHash: String,
    val timestamp: LocalDateTime,
    val nonce: Long,
    val hash: String,
    @OneToMany(cascade = [CascadeType.ALL], fetch = FetchType.LAZY)
    val transactions: List<BlockchainTransaction>,
    val difficulty: Int,
    val minerId: String
)

@Entity
@Table(name = "blockchain_transactions")
data class BlockchainTransaction(
    @Id
    val id: String,
    val patientId: String,
    val userId: String,
    val action: String, // CREATE, READ, UPDATE, DELETE, ACCESS, etc.
    val resource: String, // PATIENT_DATA, MEDICAL_RECORD, etc.
    val dataHash: String,
    val timestamp: LocalDateTime,
    @ElementCollection
    val metadata: Map<String, Any> = emptyMap(),
    var blockId: String? = null
)

@Entity
@Table(name = "blockchain_nodes")
data class BlockchainNode(
    @Id
    val id: String,
    val nodeId: String,
    val address: String,
    val port: Int,
    val isActive: Boolean = true,
    val lastSeen: LocalDateTime,
    val reputation: Double = 1.0
)

@Entity
@Table(name = "smart_contracts")
data class SmartContract(
    @Id
    val id: String,
    val contractId: String,
    val type: String, // CONSENT, TREATMENT_PLAN, BILLING, etc.
    val code: String, // Contract logic
    val creator: String,
    val participants: List<String>,
    val status: String, // ACTIVE, COMPLETED, TERMINATED
    val createdAt: LocalDateTime,
    val executedAt: LocalDateTime? = null,
    @ElementCollection
    val parameters: Map<String, Any> = emptyMap(),
    @ElementCollection
    val executionResults: Map<String, Any> = emptyMap()
)