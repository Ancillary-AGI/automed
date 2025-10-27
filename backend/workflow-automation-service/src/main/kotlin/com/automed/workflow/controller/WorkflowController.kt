package com.automed.workflow.controller

import com.automed.workflow.dto.*
import com.automed.workflow.service.WorkflowOrchestrationService
import jakarta.validation.Valid
import org.springframework.http.ResponseEntity
import org.springframework.security.access.prepost.PreAuthorize
import org.springframework.web.bind.annotation.*
import reactor.core.publisher.Mono

@RestController
@RequestMapping("/api/v1/workflow")
@CrossOrigin(origins = ["*"])
class WorkflowController(
    private val workflowService: WorkflowOrchestrationService
) {

    @PostMapping("/optimize-patient-flow")
    @PreAuthorize("hasRole('HEALTHCARE_PROVIDER') or hasRole('ADMIN')")
    fun optimizePatientFlow(@Valid @RequestBody request: PatientFlowOptimizationRequest): Mono<ResponseEntity<PatientFlowResponse>> {
        return workflowService.optimizePatientFlow(request)
            .map { ResponseEntity.ok(it) }
    }

    @PostMapping("/manage-clinical-pathways")
    @PreAuthorize("hasRole('HEALTHCARE_PROVIDER')")
    fun manageClinicalPathways(@Valid @RequestBody request: ClinicalPathwayRequest): Mono<ResponseEntity<ClinicalPathwayResponse>> {
        return workflowService.manageClinicalPathways(request)
            .map { ResponseEntity.ok(it) }
    }

    @PostMapping("/optimize-scheduling")
    @PreAuthorize("hasRole('HEALTHCARE_PROVIDER') or hasRole('ADMIN')")
    fun optimizeScheduling(@Valid @RequestBody request: SchedulingOptimizationRequest): Mono<ResponseEntity<SchedulingOptimizationResponse>> {
        return workflowService.optimizeScheduling(request)
            .map { ResponseEntity.ok(it) }
    }

    @PostMapping("/monitor-quality-compliance")
    @PreAuthorize("hasRole('HEALTHCARE_PROVIDER') or hasRole('ADMIN')")
    fun monitorQualityCompliance(@Valid @RequestBody request: QualityComplianceRequest): Mono<ResponseEntity<QualityComplianceResponse>> {
        return workflowService.monitorQualityCompliance(request)
            .map { ResponseEntity.ok(it) }
    }

    @PostMapping("/predict-equipment-maintenance")
    @PreAuthorize("hasRole('HEALTHCARE_PROVIDER') or hasRole('ADMIN')")
    fun predictEquipmentMaintenance(@Valid @RequestBody request: EquipmentMaintenanceRequest): Mono<ResponseEntity<EquipmentMaintenanceResponse>> {
        return workflowService.predictEquipmentMaintenance(request)
            .map { ResponseEntity.ok(it) }
    }

    @PostMapping("/optimize-inventory")
    @PreAuthorize("hasRole('HEALTHCARE_PROVIDER') or hasRole('ADMIN')")
    fun optimizeInventoryManagement(@Valid @RequestBody request: InventoryOptimizationRequest): Mono<ResponseEntity<InventoryOptimizationResponse>> {
        return workflowService.optimizeInventoryManagement(request)
            .map { ResponseEntity.ok(it) }
    }

    @PostMapping("/coordinate-emergency-response")
    @PreAuthorize("hasRole('HEALTHCARE_PROVIDER') or hasRole('ADMIN')")
    fun coordinateEmergencyResponse(@Valid @RequestBody request: EmergencyResponseRequest): Mono<ResponseEntity<EmergencyResponseCoordination>> {
        return workflowService.coordinateEmergencyResponse(request)
            .map { ResponseEntity.ok(it) }
    }

    @GetMapping("/hospital-capacity/{hospitalId}")
    @PreAuthorize("hasRole('HEALTHCARE_PROVIDER') or hasRole('ADMIN')")
    fun getHospitalCapacity(@PathVariable hospitalId: String): ResponseEntity<HospitalCapacity> {
        val capacity = workflowService.getCurrentHospitalCapacity(hospitalId)
        return ResponseEntity.ok(capacity)
    }

    @GetMapping("/workflow-metrics/{hospitalId}")
    @PreAuthorize("hasRole('HEALTHCARE_PROVIDER') or hasRole('ADMIN')")
    fun getWorkflowMetrics(@PathVariable hospitalId: String): ResponseEntity<WorkflowMetrics> {
        val metrics = workflowService.getWorkflowMetrics(hospitalId)
        return ResponseEntity.ok(metrics)
    }

    @PostMapping("/trigger-workflow")
    @PreAuthorize("hasRole('HEALTHCARE_PROVIDER') or hasRole('ADMIN')")
    fun triggerWorkflow(@Valid @RequestBody request: WorkflowTriggerRequest): ResponseEntity<WorkflowExecutionResponse> {
        val response = workflowService.triggerWorkflow(request)
        return ResponseEntity.ok(response)
    }
}