package com.automed.emergency.service

import com.automed.emergency.dto.*
import com.automed.emergency.model.*
import com.automed.emergency.repository.EmergencyAlertRepository
import com.automed.emergency.repository.EmergencyProtocolRepository
import com.automed.emergency.repository.EmergencyDrillRepository
import org.springframework.kafka.core.KafkaTemplate
import org.springframework.stereotype.Service
import reactor.core.publisher.Mono
import java.time.LocalDateTime
import java.util.*

@Service
class EmergencyResponseService(
    private val emergencyAlertRepository: EmergencyAlertRepository,
    private val emergencyProtocolRepository: EmergencyProtocolRepository,
    private val emergencyDrillRepository: EmergencyDrillRepository,
    private val kafkaTemplate: KafkaTemplate<String, Any>
) {

    fun createEmergencyAlert(request: CreateEmergencyAlertRequest): Mono<EmergencyAlertResponse> {
        return Mono.fromCallable {
            val alert = EmergencyAlert(
                id = UUID.randomUUID().toString(),
                type = request.type,
                priority = determinePriority(request),
                status = EmergencyStatus.ACTIVE,
                location = request.location,
                description = request.description,
                reportedBy = request.reportedBy,
                patientId = request.patientId,
                responderIds = mutableListOf(),
                resourcesAllocated = mutableListOf(),
                timeline = mutableListOf(
                    EmergencyTimelineEntry(
                        timestamp = LocalDateTime.now(),
                        action = "Alert created",
                        actor = request.reportedBy,
                        details = "Emergency alert initiated"
                    )
                ),
                createdAt = LocalDateTime.now(),
                updatedAt = LocalDateTime.now()
            )

            val savedAlert = emergencyAlertRepository.save(alert)

            // Publish to Kafka for real-time notifications
            kafkaTemplate.send("emergency-alerts", savedAlert)

            // Trigger automated response
            triggerAutomatedResponse(savedAlert)

            EmergencyAlertResponse.fromEntity(savedAlert)
        }
    }

    fun getEmergencyAlerts(
        status: EmergencyStatus?,
        priority: EmergencyPriority?,
        page: Int,
        size: Int
    ): Mono<List<EmergencyAlertResponse>> {
        return Mono.fromCallable {
            val alerts = emergencyAlertRepository.findAll()
                .filter { status == null || it.status == status }
                .filter { priority == null || it.priority == priority }
                .sortedByDescending { it.createdAt }
                .drop(page * size)
                .take(size)

            alerts.map { EmergencyAlertResponse.fromEntity(it) }
        }
    }

    fun getEmergencyAlert(id: String): Mono<EmergencyAlertResponse> {
        return Mono.fromCallable {
            val alert = emergencyAlertRepository.findById(id)
                .orElseThrow { EmergencyAlertNotFoundException("Emergency alert not found: $id") }
            EmergencyAlertResponse.fromEntity(alert)
        }
    }

    fun respondToEmergencyAlert(id: String, response: EmergencyResponseRequest): Mono<EmergencyAlertResponse> {
        return Mono.fromCallable {
            val alert = emergencyAlertRepository.findById(id)
                .orElseThrow { EmergencyAlertNotFoundException("Emergency alert not found: $id") }

            // Update alert with response
            alert.responderIds.add(response.responderId)
            alert.resourcesAllocated.addAll(response.resourcesAllocated)
            alert.status = response.status ?: alert.status

            // Add timeline entry
            alert.timeline.add(
                EmergencyTimelineEntry(
                    timestamp = LocalDateTime.now(),
                    action = "Response received",
                    actor = response.responderId,
                    details = response.notes ?: "Responder assigned to emergency"
                )
            )

            alert.updatedAt = LocalDateTime.now()

            val savedAlert = emergencyAlertRepository.save(alert)

            // Publish update
            kafkaTemplate.send("emergency-updates", savedAlert)

            EmergencyAlertResponse.fromEntity(savedAlert)
        }
    }

    fun createEmergencyProtocol(request: CreateEmergencyProtocolRequest): Mono<EmergencyProtocolResponse> {
        return Mono.fromCallable {
            val protocol = EmergencyProtocol(
                id = UUID.randomUUID().toString(),
                type = request.type,
                name = request.name,
                description = request.description,
                steps = request.steps.map { step ->
                    EmergencyProtocolStep(
                        id = UUID.randomUUID().toString(),
                        order = step.order,
                        title = step.title,
                        description = step.description,
                        duration = step.duration,
                        responsibleRole = step.responsibleRole,
                        requiredResources = step.requiredResources,
                        checklist = step.checklist
                    )
                },
                triggers = request.triggers,
                resources = request.resources,
                isActive = true,
                createdAt = LocalDateTime.now(),
                updatedAt = LocalDateTime.now()
            )

            val savedProtocol = emergencyProtocolRepository.save(protocol)
            EmergencyProtocolResponse.fromEntity(savedProtocol)
        }
    }

    fun getEmergencyProtocols(
        type: EmergencyType?,
        page: Int,
        size: Int
    ): Mono<List<EmergencyProtocolResponse>> {
        return Mono.fromCallable {
            val protocols = emergencyProtocolRepository.findAll()
                .filter { type == null || it.type == type }
                .filter { it.isActive }
                .sortedByDescending { it.createdAt }
                .drop(page * size)
                .take(size)

            protocols.map { EmergencyProtocolResponse.fromEntity(it) }
        }
    }

    fun scheduleEmergencyDrill(request: ScheduleEmergencyDrillRequest): Mono<EmergencyDrillResponse> {
        return Mono.fromCallable {
            val drill = EmergencyDrill(
                id = UUID.randomUUID().toString(),
                type = request.type,
                title = request.title,
                description = request.description,
                scheduledDate = request.scheduledDate,
                duration = request.duration,
                participants = request.participants,
                objectives = request.objectives,
                status = DrillStatus.SCHEDULED,
                createdAt = LocalDateTime.now(),
                updatedAt = LocalDateTime.now()
            )

            val savedDrill = emergencyDrillRepository.save(drill)
            EmergencyDrillResponse.fromEntity(savedDrill)
        }
    }

    fun getEmergencyDrills(
        status: DrillStatus?,
        page: Int,
        size: Int
    ): Mono<List<EmergencyDrillResponse>> {
        return Mono.fromCallable {
            val drills = emergencyDrillRepository.findAll()
                .filter { status == null || it.status == status }
                .sortedByDescending { it.createdAt }
                .drop(page * size)
                .take(size)

            drills.map { EmergencyDrillResponse.fromEntity(it) }
        }
    }

    fun allocateEmergencyResources(request: EmergencyResourceAllocationRequest): Mono<EmergencyResourceAllocationResponse> {
        return Mono.fromCallable {
            // Validate resource availability
            val availableResources = checkResourceAvailability(request.resources)

            val allocation = EmergencyResourceAllocation(
                id = UUID.randomUUID().toString(),
                emergencyId = request.emergencyId,
                resources = request.resources.map { resource ->
                    AllocatedResource(
                        resourceId = resource.resourceId,
                        type = resource.type,
                        quantity = resource.quantity,
                        allocatedAt = LocalDateTime.now(),
                        expectedReturn = resource.expectedDuration?.let { LocalDateTime.now().plus(it) }
                    )
                },
                allocatedBy = request.allocatedBy,
                notes = request.notes,
                createdAt = LocalDateTime.now()
            )

            // Update resource status
            updateResourceStatus(allocation.resources, ResourceStatus.ALLOCATED)

            EmergencyResourceAllocationResponse(
                allocationId = allocation.id,
                emergencyId = allocation.emergencyId,
                resources = allocation.resources,
                allocatedBy = allocation.allocatedBy,
                allocatedAt = allocation.createdAt,
                availableResources = availableResources
            )
        }
    }

    fun updateEmergencyLocation(request: EmergencyLocationUpdateRequest): Mono<EmergencyLocationUpdateResponse> {
        return Mono.fromCallable {
            // Log location update for emergency tracking
            println("Emergency location update received: lat=${request.latitude}, lng=${request.longitude}, user=${request.userId}")

            // In a real implementation, you might:
            // 1. Store location in a database
            // 2. Update active emergency alerts with location
            // 3. Send location to emergency responders
            // 4. Trigger proximity-based alerts

            // For now, just acknowledge the update
            EmergencyLocationUpdateResponse(
                success = true,
                message = "Location updated successfully",
                locationId = UUID.randomUUID().toString(),
                timestamp = LocalDateTime.now()
            )
        }
    }

    fun getEmergencyAnalytics(
        startDate: LocalDateTime?,
        endDate: LocalDateTime?
    ): Mono<EmergencyAnalyticsResponse> {
        return Mono.fromCallable {
            val start = startDate ?: LocalDateTime.now().minusDays(30)
            val end = endDate ?: LocalDateTime.now()

            val alerts = emergencyAlertRepository.findAll()
                .filter { it.createdAt.isAfter(start) && it.createdAt.isBefore(end) }

            val totalAlerts = alerts.size
            val resolvedAlerts = alerts.count { it.status == EmergencyStatus.RESOLVED }
            val averageResponseTime = calculateAverageResponseTime(alerts)
            val alertsByType = alerts.groupBy { it.type }.mapValues { it.value.size }
            val alertsByPriority = alerts.groupBy { it.priority }.mapValues { it.value.size }

            EmergencyAnalyticsResponse(
                totalAlerts = totalAlerts,
                resolvedAlerts = resolvedAlerts,
                resolutionRate = if (totalAlerts > 0) resolvedAlerts.toDouble() / totalAlerts else 0.0,
                averageResponseTime = averageResponseTime,
                alertsByType = alertsByType,
                alertsByPriority = alertsByPriority,
                period = AnalyticsPeriod(start, end)
            )
        }
    }

    private fun determinePriority(request: CreateEmergencyAlertRequest): EmergencyPriority {
        return when (request.type) {
            EmergencyType.CARDIAC_ARREST -> EmergencyPriority.CRITICAL
            EmergencyType.STROKE -> EmergencyPriority.CRITICAL
            EmergencyType.SEPSIS -> EmergencyPriority.HIGH
            EmergencyType.TRAUMA -> EmergencyPriority.HIGH
            EmergencyType.RESPIRATORY_DISTRESS -> EmergencyPriority.HIGH
            else -> EmergencyPriority.MEDIUM
        }
    }

    private fun triggerAutomatedResponse(alert: EmergencyAlert) {
        // Trigger automated notifications
        kafkaTemplate.send("emergency-notifications", alert)

        // Activate relevant protocols
        val protocol = emergencyProtocolRepository.findByTypeAndIsActive(alert.type, true)
        if (protocol != null) {
            kafkaTemplate.send("protocol-activation", protocol)
        }
    }

    private fun checkResourceAvailability(resources: List<ResourceRequest>): List<AvailableResource> {
        // Implementation for checking resource availability
        return resources.map { resource ->
            AvailableResource(
                resourceId = resource.resourceId,
                type = resource.type,
                available = true, // Simplified - should check actual availability
                availableQuantity = resource.quantity
            )
        }
    }

    private fun updateResourceStatus(resources: List<AllocatedResource>, status: ResourceStatus) {
        // Implementation for updating resource status
        resources.forEach { resource ->
            kafkaTemplate.send("resource-updates", mapOf(
                "resourceId" to resource.resourceId,
                "status" to status,
                "allocatedAt" to resource.allocatedAt
            ))
        }
    }

    private fun calculateAverageResponseTime(alerts: List<EmergencyAlert>): Double {
        val resolvedAlerts = alerts.filter { it.status == EmergencyStatus.RESOLVED }
        if (resolvedAlerts.isEmpty()) return 0.0

        val responseTimes = resolvedAlerts.mapNotNull { alert ->
            val created = alert.createdAt
            val firstResponse = alert.timeline
                .filter { it.action == "Response received" }
                .minByOrNull { it.timestamp }
                ?.timestamp

            firstResponse?.let { java.time.Duration.between(created, it).toMinutes().toDouble() }
        }

        return responseTimes.average()
    }
}

class EmergencyAlertNotFoundException(message: String) : Exception(message)