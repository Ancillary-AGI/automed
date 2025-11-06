package com.automed.patient.service

import com.automed.patient.model.Block
import com.automed.patient.model.BlockchainTransaction
import com.automed.patient.repository.BlockRepository
import com.automed.patient.repository.BlockchainTransactionRepository
import org.springframework.stereotype.Service
import org.springframework.transaction.annotation.Transactional
import java.security.MessageDigest
import java.time.LocalDateTime
import java.util.*
import kotlin.random.Random

@Service
@Transactional
class BlockchainAuditService(
    private val blockRepository: BlockRepository,
    private val transactionRepository: BlockchainTransactionRepository
) {

    private val difficulty = 4 // Number of leading zeros required for proof-of-work
    private val miningReward = 10.0 // Reward for mining a block

    companion object {
        private const val GENESIS_BLOCK_PREVIOUS_HASH = "0"
        private const val GENESIS_BLOCK_DATA = "Genesis Block - Healthcare Blockchain Initialized"
    }

    init {
        initializeGenesisBlock()
    }

    /**
     * Creates an immutable audit trail entry for medical record access/modification
     */
    fun createAuditTrailEntry(
        patientId: String,
        userId: String,
        action: String,
        resource: String,
        dataHash: String,
        metadata: Map<String, Any> = emptyMap()
    ): BlockchainTransaction {
        val transaction = BlockchainTransaction(
            id = UUID.randomUUID().toString(),
            patientId = patientId,
            userId = userId,
            action = action,
            resource = resource,
            dataHash = dataHash,
            timestamp = LocalDateTime.now(),
            metadata = metadata,
            blockId = null // Will be set when mined
        )

        val savedTransaction = transactionRepository.save(transaction)

        // Add to pending transactions for mining
        addToPendingTransactions(savedTransaction)

        return savedTransaction
    }

    /**
     * Mines a new block with pending transactions
     */
    fun mineBlock(minerId: String): Block? {
        val pendingTransactions = getPendingTransactions()
        if (pendingTransactions.isEmpty()) return null

        val previousBlock = getLatestBlock()
        val previousHash = previousBlock?.hash ?: GENESIS_BLOCK_PREVIOUS_HASH

        // Create coinbase transaction for miner reward
        val coinbaseTransaction = createCoinbaseTransaction(minerId)

        val transactions = listOf(coinbaseTransaction) + pendingTransactions

        // Mine the block
        val (nonce, hash) = proofOfWork(previousHash, transactions)

        val block = Block(
            id = UUID.randomUUID().toString(),
            previousHash = previousHash,
            timestamp = LocalDateTime.now(),
            nonce = nonce,
            hash = hash,
            transactions = transactions,
            difficulty = difficulty,
            minerId = minerId
        )

        val savedBlock = blockRepository.save(block)

        // Update transaction block references
        transactions.forEach { transaction ->
            transaction.blockId = savedBlock.id
            transactionRepository.save(transaction)
        }

        // Clear pending transactions
        clearPendingTransactions()

        return savedBlock
    }

    /**
     * Validates the entire blockchain integrity
     */
    fun validateBlockchain(): BlockchainValidationResult {
        val blocks = blockRepository.findAll().sortedBy { it.timestamp }
        val errors = mutableListOf<String>()

        for (i in 1 until blocks.size) {
            val currentBlock = blocks[i]
            val previousBlock = blocks[i - 1]

            // Validate hash chain
            if (currentBlock.previousHash != previousBlock.hash) {
                errors.add("Block ${currentBlock.id}: Invalid previous hash")
            }

            // Validate block hash
            val calculatedHash = calculateBlockHash(currentBlock)
            if (calculatedHash != currentBlock.hash) {
                errors.add("Block ${currentBlock.id}: Invalid block hash")
            }

            // Validate proof-of-work
            if (!isValidProofOfWork(currentBlock.hash, difficulty)) {
                errors.add("Block ${currentBlock.id}: Invalid proof-of-work")
            }

            // Validate transactions
            currentBlock.transactions.forEach { transaction ->
                if (!validateTransaction(transaction)) {
                    errors.add("Block ${currentBlock.id}: Invalid transaction ${transaction.id}")
                }
            }
        }

        return BlockchainValidationResult(
            isValid = errors.isEmpty(),
            totalBlocks = blocks.size,
            errors = errors
        )
    }

    /**
     * Retrieves complete audit trail for a patient
     */
    fun getPatientAuditTrail(patientId: String): List<BlockchainTransaction> {
        return transactionRepository.findByPatientIdOrderByTimestampDesc(patientId)
    }

    /**
     * Retrieves audit trail for a specific medical record
     */
    fun getRecordAuditTrail(recordId: String): List<BlockchainTransaction> {
        return transactionRepository.findByResourceAndMetadata(recordId)
    }

    /**
     * Creates a verifiable consent record on the blockchain
     */
    fun createConsentRecord(
        patientId: String,
        consentType: String,
        consented: Boolean,
        purpose: String,
        scope: String
    ): BlockchainTransaction {
        val consentData = mapOf(
            "consentType" to consentType,
            "consented" to consented,
            "purpose" to purpose,
            "scope" to scope,
            "timestamp" to LocalDateTime.now().toString()
        )

        val dataHash = calculateHash(consentData.toString())

        return createAuditTrailEntry(
            patientId = patientId,
            userId = "SYSTEM",
            action = "CONSENT_RECORD",
            resource = "PATIENT_CONSENT",
            dataHash = dataHash,
            metadata = consentData
        )
    }

    /**
     * Verifies data integrity by comparing current hash with blockchain record
     */
    fun verifyDataIntegrity(recordId: String, currentData: String): DataIntegrityResult {
        val auditTrail = getRecordAuditTrail(recordId)
        if (auditTrail.isEmpty()) {
            return DataIntegrityResult(
                isVerified = false,
                reason = "No audit trail found for record",
                lastVerified = null
            )
        }

        val currentHash = calculateHash(currentData)
        val blockchainHash = auditTrail.first().dataHash

        val isVerified = currentHash == blockchainHash

        return DataIntegrityResult(
            isVerified = isVerified,
            reason = if (isVerified) "Data integrity verified" else "Data has been modified",
            lastVerified = LocalDateTime.now(),
            blockchainHash = blockchainHash,
            currentHash = currentHash
        )
    }

    /**
     * Gets blockchain statistics
     */
    fun getBlockchainStats(): BlockchainStats {
        val totalBlocks = blockRepository.count()
        val totalTransactions = transactionRepository.count()
        val pendingTransactions = getPendingTransactions().size
        val latestBlock = getLatestBlock()

        return BlockchainStats(
            totalBlocks = totalBlocks,
            totalTransactions = totalTransactions,
            pendingTransactions = pendingTransactions,
            latestBlockTimestamp = latestBlock?.timestamp,
            averageBlockTime = calculateAverageBlockTime(),
            networkDifficulty = difficulty
        )
    }

    private fun initializeGenesisBlock() {
        if (blockRepository.count() == 0L) {
            val genesisTransaction = BlockchainTransaction(
                id = "genesis-transaction",
                patientId = "SYSTEM",
                userId = "SYSTEM",
                action = "GENESIS",
                resource = "BLOCKCHAIN",
                dataHash = calculateHash(GENESIS_BLOCK_DATA),
                timestamp = LocalDateTime.now().minusDays(1),
                metadata = mapOf("type" to "genesis"),
                blockId = null
            )

            val (nonce, hash) = proofOfWork(GENESIS_BLOCK_PREVIOUS_HASH, listOf(genesisTransaction))

            val genesisBlock = Block(
                id = "genesis-block",
                previousHash = GENESIS_BLOCK_PREVIOUS_HASH,
                timestamp = LocalDateTime.now().minusDays(1),
                nonce = nonce,
                hash = hash,
                transactions = listOf(genesisTransaction),
                difficulty = difficulty,
                minerId = "SYSTEM"
            )

            blockRepository.save(genesisBlock)
            genesisTransaction.blockId = genesisBlock.id
            transactionRepository.save(genesisTransaction)
        }
    }

    private fun proofOfWork(previousHash: String, transactions: List<BlockchainTransaction>): Pair<Long, String> {
        val blockData = createBlockData(previousHash, transactions)
        var nonce = 0L

        while (true) {
            val hash = calculateHash("$blockData$nonce")
            if (isValidProofOfWork(hash, difficulty)) {
                return Pair(nonce, hash)
            }
            nonce++
        }
    }

    private fun createBlockData(previousHash: String, transactions: List<BlockchainTransaction>): String {
        val transactionData = transactions.joinToString("|") { "${it.id}:${it.dataHash}" }
        return "$previousHash$transactionData${LocalDateTime.now()}"
    }

    private fun calculateBlockHash(block: Block): String {
        val blockData = "${block.previousHash}${block.transactions.joinToString("|") { it.id }}:${block.timestamp}${block.nonce}"
        return calculateHash(blockData)
    }

    private fun isValidProofOfWork(hash: String, difficulty: Int): Boolean {
        return hash.startsWith("0".repeat(difficulty))
    }

    private fun validateTransaction(transaction: BlockchainTransaction): Boolean {
        // Validate transaction data integrity
        val expectedHash = calculateHash(
            "${transaction.patientId}${transaction.userId}${transaction.action}${transaction.resource}${transaction.timestamp}"
        )
        return transaction.dataHash == expectedHash
    }

    private fun createCoinbaseTransaction(minerId: String): BlockchainTransaction {
        return BlockchainTransaction(
            id = "coinbase-${UUID.randomUUID()}",
            patientId = "SYSTEM",
            userId = minerId,
            action = "MINING_REWARD",
            resource = "BLOCKCHAIN",
            dataHash = calculateHash("Mining reward: $miningReward"),
            timestamp = LocalDateTime.now(),
            metadata = mapOf("reward" to miningReward, "type" to "coinbase"),
            blockId = null
        )
    }

    private fun calculateHash(data: String): String {
        val digest = MessageDigest.getInstance("SHA-256")
        val hashBytes = digest.digest(data.toByteArray())
        return hashBytes.joinToString("") { "%02x".format(it) }
    }

    private fun getLatestBlock(): Block? {
        return blockRepository.findTopByOrderByTimestampDesc()
    }

    private fun addToPendingTransactions(transaction: BlockchainTransaction) {
        // In a real implementation, this would use a queue or database
        // For now, we'll mine immediately for demonstration
        mineBlock("SYSTEM")
    }

    private fun getPendingTransactions(): List<BlockchainTransaction> {
        // In a real implementation, this would return pending transactions
        return transactionRepository.findByBlockIdIsNull()
    }

    private fun clearPendingTransactions() {
        // In a real implementation, this would clear the pending queue
    }

    private fun calculateAverageBlockTime(): Double {
        val blocks = blockRepository.findTop10ByOrderByTimestampDesc()
        if (blocks.size < 2) return 0.0

        val timeDifferences = mutableListOf<Long>()
        for (i in 1 until blocks.size) {
            val diff = java.time.Duration.between(blocks[i - 1].timestamp, blocks[i].timestamp).toMillis()
            timeDifferences.add(diff)
        }

        return timeDifferences.average() / 1000.0 // Convert to seconds
    }
}

// Data classes for blockchain results
data class BlockchainValidationResult(
    val isValid: Boolean,
    val totalBlocks: Long,
    val errors: List<String>
)

data class DataIntegrityResult(
    val isVerified: Boolean,
    val reason: String,
    val lastVerified: LocalDateTime?,
    val blockchainHash: String? = null,
    val currentHash: String? = null
)

data class BlockchainStats(
    val totalBlocks: Long,
    val totalTransactions: Long,
    val pendingTransactions: Int,
    val latestBlockTimestamp: LocalDateTime?,
    val averageBlockTime: Double,
    val networkDifficulty: Int
)