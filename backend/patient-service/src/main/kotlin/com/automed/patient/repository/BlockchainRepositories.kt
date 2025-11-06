package com.automed.patient.repository

import com.automed.patient.model.Block
import com.automed.patient.model.BlockchainTransaction
import com.automed.patient.model.BlockchainNode
import com.automed.patient.model.SmartContract
import org.springframework.data.jpa.repository.JpaRepository
import org.springframework.data.jpa.repository.Query
import org.springframework.data.repository.query.Param
import org.springframework.stereotype.Repository
import java.time.LocalDateTime

@Repository
interface BlockRepository : JpaRepository<Block, String> {
    fun findTopByOrderByTimestampDesc(): Block?
    fun findTop10ByOrderByTimestampDesc(): List<Block>
    fun findByMinerId(minerId: String): List<Block>
    fun findByTimestampBetween(startDate: LocalDateTime, endDate: LocalDateTime): List<Block>
}

@Repository
interface BlockchainTransactionRepository : JpaRepository<BlockchainTransaction, String> {
    fun findByPatientIdOrderByTimestampDesc(patientId: String): List<BlockchainTransaction>
    fun findByUserIdOrderByTimestampDesc(userId: String): List<BlockchainTransaction>
    fun findByBlockIdIsNull(): List<BlockchainTransaction>
    fun findByBlockId(blockId: String): List<BlockchainTransaction>
    fun findByAction(action: String): List<BlockchainTransaction>
    fun findByResource(resource: String): List<BlockchainTransaction>

    @Query("SELECT t FROM BlockchainTransaction t WHERE t.resource = :resource AND t.metadata LIKE %:recordId%")
    fun findByResourceAndMetadata(@Param("resource") resource: String, @Param("recordId") recordId: String): List<BlockchainTransaction>

    fun findByTimestampBetween(startDate: LocalDateTime, endDate: LocalDateTime): List<BlockchainTransaction>

    @Query("SELECT COUNT(t) FROM BlockchainTransaction t WHERE t.patientId = :patientId AND t.action = :action")
    fun countByPatientIdAndAction(@Param("patientId") patientId: String, @Param("action") action: String): Long
}

@Repository
interface BlockchainNodeRepository : JpaRepository<BlockchainNode, String> {
    fun findByIsActive(isActive: Boolean): List<BlockchainNode>
    fun findByNodeId(nodeId: String): BlockchainNode?
    fun findByReputationGreaterThan(reputation: Double): List<BlockchainNode>
}

@Repository
interface SmartContractRepository : JpaRepository<SmartContract, String> {
    fun findByType(type: String): List<SmartContract>
    fun findByCreator(creator: String): List<SmartContract>
    fun findByStatus(status: String): List<SmartContract>
    fun findByParticipantsContaining(participantId: String): List<SmartContract>
    fun findByCreatedAtBetween(startDate: LocalDateTime, endDate: LocalDateTime): List<SmartContract>
}