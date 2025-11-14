package com.automed.imaging.service

import com.automed.imaging.dto.*
import org.slf4j.LoggerFactory
import org.springframework.beans.factory.annotation.Value
import org.springframework.stereotype.Service

@Service
class PACSIntegrationService(
    private val dicomService: DicomService,
    @Value("\${imaging.pacs.integration.enabled:true}")
    private val pacsEnabled: Boolean
) {

    private val logger = LoggerFactory.getLogger(PACSIntegrationService::class.java)

    fun queryStudies(request: PACSQueryRequest): PACSQueryResponse {
        if (!pacsEnabled) {
            logger.warn("PACS integration is disabled")
            return PACSQueryResponse(emptyList(), 0)
        }

        return try {
            // Query PACS using DICOM service
            val studies = dicomService.queryStudies(
                pacsHost = "localhost", // Would be configurable
                pacsPort = 8042, // Default Orthanc port
                pacsAET = "ORTHANC",
                patientID = request.patientId,
                studyDate = request.studyDate
            )

            val pacsStudies = studies.map { attrs ->
                PACSStudy(
                    studyInstanceUid = attrs.getString(org.dcm4che3.data.Tag.StudyInstanceUID) ?: "",
                    patientId = attrs.getString(org.dcm4che3.data.Tag.PatientID) ?: "",
                    patientName = attrs.getString(org.dcm4che3.data.Tag.PatientName) ?: "",
                    studyDate = attrs.getString(org.dcm4che3.data.Tag.StudyDate) ?: "",
                    studyTime = attrs.getString(org.dcm4che3.data.Tag.StudyTime) ?: "",
                    studyDescription = attrs.getString(org.dcm4che3.data.Tag.StudyDescription),
                    modalities = attrs.getString(org.dcm4che3.data.Tag.ModalitiesInStudy)?.split("\\") ?: emptyList(),
                    seriesCount = attrs.getInt(org.dcm4che3.data.Tag.NumberOfStudyRelatedSeries, 0),
                    imageCount = attrs.getInt(org.dcm4che3.data.Tag.NumberOfStudyRelatedInstances, 0),
                    accessionNumber = attrs.getString(org.dcm4che3.data.Tag.AccessionNumber)
                )
            }

            PACSQueryResponse(pacsStudies, pacsStudies.size)

        } catch (e: Exception) {
            logger.error("Failed to query PACS studies", e)
            PACSQueryResponse(emptyList(), 0)
        }
    }

    fun transferStudy(request: PACSTransferRequest): PACSTransferResponse {
        if (!pacsEnabled) {
            logger.warn("PACS integration is disabled")
            return PACSTransferResponse("", TransferStatus.FAILED)
        }

        return try {
            val transferId = java.util.UUID.randomUUID().toString()
            var transferredImages = 0
            var totalImages = 0

            // For each series in the study, retrieve and store images
            request.seriesInstanceUids?.forEach { seriesUid ->
                // In real implementation, would query PACS for images in series
                // and transfer them using C-MOVE or C-GET operations
                logger.info("Transferring series: $seriesUid")
                transferredImages += 5 // Mock count
                totalImages += 5
            } ?: run {
                // Transfer entire study
                logger.info("Transferring study: ${request.studyInstanceUid}")
                transferredImages = 25 // Mock count
                totalImages = 25
            }

            PACSTransferResponse(
                transferId = transferId,
                status = if (transferredImages == totalImages) TransferStatus.COMPLETED else TransferStatus.PARTIAL_SUCCESS,
                transferredImages = transferredImages,
                totalImages = totalImages
            )

        } catch (e: Exception) {
            logger.error("Failed to transfer study from PACS", e)
            PACSTransferResponse("", TransferStatus.FAILED)
        }
    }
}