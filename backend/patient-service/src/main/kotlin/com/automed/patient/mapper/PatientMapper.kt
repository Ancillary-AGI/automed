package com.automed.patient.mapper

import com.automed.patient.domain.Patient
import com.automed.patient.dto.CreatePatientRequest
import com.automed.patient.dto.PatientResponse
import com.automed.patient.dto.UpdatePatientRequest
import org.mapstruct.*
import java.util.*

@Mapper(componentModel = "spring")
interface PatientMapper {
    
    @Mapping(target = "id", ignore = true)
    @Mapping(target = "patientId", expression = "java(generatePatientId())")
    @Mapping(target = "status", constant = "ACTIVE")
    @Mapping(target = "createdAt", ignore = true)
    @Mapping(target = "updatedAt", ignore = true)
    fun toEntity(request: CreatePatientRequest): Patient
    
    fun toResponse(patient: Patient): PatientResponse
    
    @BeanMapping(nullValuePropertyMappingStrategy = NullValuePropertyMappingStrategy.IGNORE)
    @Mapping(target = "id", ignore = true)
    @Mapping(target = "patientId", ignore = true)
    @Mapping(target = "createdAt", ignore = true)
    @Mapping(target = "updatedAt", ignore = true)
    fun updateEntity(@MappingTarget patient: Patient, request: UpdatePatientRequest): Patient
    
    fun generatePatientId(): String {
        return "P${System.currentTimeMillis()}"
    }
}