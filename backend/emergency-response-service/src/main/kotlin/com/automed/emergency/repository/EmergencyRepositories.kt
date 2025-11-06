package com.automed.emergency.repository

import com.automed.emergency.model.*
import org.springframework.data.jpa.repository.JpaRepository
import org.springframework.stereotype.Repository
import java.time.LocalDateTime

@Repository
interface EmergencyAlertRepository : JpaRepository<EmergencyAlert, String> {
    fun findByStatus(status: EmergencyStatus): List<EmergencyAlert>
    fun findByType(type: EmergencyType): List<EmergencyAlert>
    fun findByPriority(priority: EmergencyPriority): List<EmergencyAlert>
    fun findByReportedBy(reportedBy: String): List<EmergencyAlert>
    fun findByPatientId(patientId: String): List<EmergencyAlert>
    fun findByCreatedAtBetween(startDate: LocalDateTime, endDate: LocalDateTime): List<EmergencyAlert>
    fun findByStatusAndPriority(status: EmergencyStatus, priority: EmergencyPriority): List<EmergencyAlert>
}

@Repository
interface EmergencyProtocolRepository : JpaRepository<EmergencyProtocol, String> {
    fun findByType(type: EmergencyType): List<EmergencyProtocol>
    fun findByTypeAndIsActive(type: EmergencyType, isActive: Boolean): EmergencyProtocol?
    fun findByIsActive(isActive: Boolean): List<EmergencyProtocol>
    fun findByNameContainingIgnoreCase(name: String): List<EmergencyProtocol>
}

@Repository
interface EmergencyDrillRepository : JpaRepository<EmergencyDrill, String> {
    fun findByStatus(status: DrillStatus): List<EmergencyDrill>
    fun findByType(type: EmergencyType): List<EmergencyDrill>
    fun findByScheduledDateBetween(startDate: LocalDateTime, endDate: LocalDateTime): List<EmergencyDrill>
    fun findByParticipantsContaining(participantId: String): List<EmergencyDrill>
}

@Repository
interface EmergencyResourceAllocationRepository : JpaRepository<EmergencyResourceAllocation, String> {
    fun findByEmergencyId(emergencyId: String): List<EmergencyResourceAllocation>
    fun findByAllocatedBy(allocatedBy: String): List<EmergencyResourceAllocation>
    fun findByCreatedAtBetween(startDate: LocalDateTime, endDate: LocalDateTime): List<EmergencyResourceAllocation>
}