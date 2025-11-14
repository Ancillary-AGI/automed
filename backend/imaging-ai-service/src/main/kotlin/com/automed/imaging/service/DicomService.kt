package com.automed.imaging.service

import org.dcm4che3.data.Attributes
import org.dcm4che3.data.Tag
import org.dcm4che3.data.VR
import org.dcm4che3.io.DicomInputStream
import org.dcm4che3.io.DicomOutputStream
import org.dcm4che3.net.*
import org.dcm4che3.net.pdu.PresentationContext
import org.dcm4che3.net.service.BasicCStoreSCP
import org.dcm4che3.net.service.DicomServiceException
import org.dcm4che3.util.SafeClose
import org.slf4j.LoggerFactory
import org.springframework.beans.factory.annotation.Value
import org.springframework.stereotype.Service
import java.io.File
import java.io.IOException
import java.nio.file.Files
import java.nio.file.Path
import java.nio.file.Paths
import java.time.LocalDateTime
import java.time.format.DateTimeFormatter
import java.util.*
import java.util.concurrent.CompletableFuture
import kotlin.io.path.exists

@Service
class DicomService(
    @Value("\${imaging.dicom.storage.directory:/tmp/imaging-ai-storage}")
    private val storageDirectory: String,
    @Value("\${imaging.dicom.max-file-size:100MB}")
    private val maxFileSize: String
) {

    private val logger = LoggerFactory.getLogger(DicomService::class.java)
    private val dateFormatter = DateTimeFormatter.ofPattern("yyyyMMddHHmmss")

    /**
     * Store DICOM file and return the stored file path
     */
    fun storeDicomFile(dataset: Attributes, data: ByteArray): String {
        try {
            val studyInstanceUID = dataset.getString(Tag.StudyInstanceUID)
                ?: throw IllegalArgumentException("StudyInstanceUID is required")
            val seriesInstanceUID = dataset.getString(Tag.SeriesInstanceUID)
                ?: throw IllegalArgumentException("SeriesInstanceUID is required")
            val sopInstanceUID = dataset.getString(Tag.SOPInstanceUID)
                ?: throw IllegalArgumentException("SOPInstanceUID is required")

            // Create directory structure: storage/study/series/
            val studyDir = Paths.get(storageDirectory, studyInstanceUID)
            val seriesDir = studyDir.resolve(seriesInstanceUID)
            Files.createDirectories(seriesDir)

            // Generate filename with timestamp
            val timestamp = LocalDateTime.now().format(dateFormatter)
            val filename = "${sopInstanceUID}_${timestamp}.dcm"
            val filePath = seriesDir.resolve(filename)

            // Check file size limit
            if (data.size > parseFileSize(maxFileSize)) {
                throw IllegalArgumentException("File size exceeds maximum allowed size: $maxFileSize")
            }

            // Write DICOM file
            Files.write(filePath, data)

            logger.info("Stored DICOM file: $filePath")
            return filePath.toString()

        } catch (e: Exception) {
            logger.error("Failed to store DICOM file", e)
            throw e
        }
    }

    /**
     * Retrieve DICOM file by SOP Instance UID
     */
    fun retrieveDicomFile(sopInstanceUID: String): Pair<Attributes, ByteArray>? {
        try {
            val file = findDicomFile(sopInstanceUID) ?: return null

            DicomInputStream(file).use { dis ->
                val dataset = dis.readDataset()
                val data = Files.readAllBytes(file.toPath())
                return Pair(dataset, data)
            }
        } catch (e: Exception) {
            logger.error("Failed to retrieve DICOM file: $sopInstanceUID", e)
            return null
        }
    }

    /**
     * Find DICOM file by SOP Instance UID
     */
    private fun findDicomFile(sopInstanceUID: String): File? {
        val storagePath = Paths.get(storageDirectory)
        if (!storagePath.exists()) return null

        // Search recursively for the file
        Files.walk(storagePath)
            .filter { it.toFile().isFile }
            .filter { it.toString().contains(sopInstanceUID) }
            .filter { it.toString().endsWith(".dcm") }
            .findFirst()
            .orElse(null)
            ?.let { return it.toFile() }

        return null
    }

    /**
     * Send DICOM file to PACS
     */
    fun sendToPacs(
        dicomFile: File,
        pacsHost: String,
        pacsPort: Int,
        pacsAET: String,
        callingAET: String = "IMAGING_AI_SERVICE"
    ): CompletableFuture<Void> {
        return CompletableFuture.runAsync {
            try {
                val device = Device(callingAET)
                val conn = Connection()
                conn.hostname = pacsHost
                conn.port = pacsPort

                val remoteAE = ApplicationEntity(pacsAET)
                remoteAE.addConnection(conn)

                val ae = ApplicationEntity(callingAET)
                device.addApplicationEntity(ae)
                device.addConnection(conn)

                val association = ae.connect(remoteAE, null)

                // Send C-STORE request
                DicomInputStream(dicomFile).use { dis ->
                    val fmi = dis.readFileMetaInformation()
                    val dataset = dis.readDataset()

                    association.cstore(
                        fmi.mediaStorageSOPClassUID,
                        fmi.mediaStorageSOPInstanceUID,
                        0, // priority
                        null, // moveOriginatorApplicationEntityTitle
                        0, // moveOriginatorMessageID
                        dataset
                    )
                }

                association.release()
                logger.info("Successfully sent DICOM file to PACS: $pacsHost:$pacsPort")

            } catch (e: Exception) {
                logger.error("Failed to send DICOM file to PACS", e)
                throw e
            }
        }
    }

    /**
     * Query PACS for studies
     */
    fun queryStudies(
        pacsHost: String,
        pacsPort: Int,
        pacsAET: String,
        callingAET: String = "IMAGING_AI_SERVICE",
        patientID: String? = null,
        studyDate: String? = null
    ): List<Attributes> {
        try {
            val device = Device(callingAET)
            val conn = Connection()
            conn.hostname = pacsHost
            conn.port = pacsPort

            val remoteAE = ApplicationEntity(pacsAET)
            remoteAE.addConnection(conn)

            val ae = ApplicationEntity(callingAET)
            device.addApplicationEntity(ae)
            device.addConnection(conn)

            val association = ae.connect(remoteAE, null)

            // Create C-FIND request for studies
            val keys = Attributes()
            keys.setString(Tag.QueryRetrieveLevel, VR.CS, "STUDY")
            keys.setString(Tag.StudyInstanceUID, VR.UI, "")
            keys.setString(Tag.StudyID, VR.SH, "")
            keys.setString(Tag.StudyDescription, VR.LO, "")
            keys.setString(Tag.StudyDate, VR.DA, studyDate ?: "")
            keys.setString(Tag.StudyTime, VR.TM, "")
            keys.setString(Tag.AccessionNumber, VR.SH, "")
            keys.setString(Tag.ModalitiesInStudy, VR.CS, "")
            keys.setString(Tag.ReferringPhysicianName, VR.PN, "")
            keys.setString(Tag.PatientName, VR.PN, "")
            keys.setString(Tag.PatientID, VR.LO, patientID ?: "")
            keys.setString(Tag.PatientBirthDate, VR.DA, "")
            keys.setString(Tag.PatientSex, VR.CS, "")

            val results = mutableListOf<Attributes>()
            association.cfind(
                "1.2.840.10008.5.1.4.1.2.2.1", // Study Root Query/Retrieve Information Model - FIND
                0, // priority
                keys
            ) { response ->
                if (response.command.getInt(Tag.Status, -1) == 0) {
                    results.add(response.dataset)
                }
            }

            association.release()
            return results

        } catch (e: Exception) {
            logger.error("Failed to query studies from PACS", e)
            throw e
        }
    }

    /**
     * Parse file size string (e.g., "100MB") to bytes
     */
    private fun parseFileSize(sizeStr: String): Long {
        val regex = Regex("(\\d+)([KMGT]?)B?", RegexOption.IGNORE_CASE)
        val match = regex.find(sizeStr) ?: return 0L

        val size = match.groupValues[1].toLong()
        val unit = match.groupValues[2].uppercase()

        return when (unit) {
            "K" -> size * 1024
            "M" -> size * 1024 * 1024
            "G" -> size * 1024 * 1024 * 1024
            "T" -> size * 1024 * 1024 * 1024 * 1024
            else -> size
        }
    }

    /**
     * Get storage statistics
     */
    fun getStorageStats(): Map<String, Any> {
        val storagePath = Paths.get(storageDirectory)
        if (!storagePath.exists()) {
            return mapOf(
                "totalFiles" to 0,
                "totalSize" to 0L,
                "studies" to 0,
                "series" to 0
            )
        }

        var totalFiles = 0L
        var totalSize = 0L
        val studies = mutableSetOf<String>()
        val series = mutableSetOf<String>()

        Files.walk(storagePath)
            .filter { it.toFile().isFile }
            .forEach { path ->
                totalFiles++
                totalSize += Files.size(path)

                // Extract study and series UIDs from path
                val pathStr = path.toString()
                val studyMatch = Regex("([0-9a-fA-F]{8}-[0-9a-fA-F]{4}-[0-9a-fA-F]{4}-[0-9a-fA-F]{4}-[0-9a-fA-F]{12})").find(pathStr)
                studyMatch?.let { studies.add(it.value) }

                val seriesMatch = Regex("([0-9a-fA-F]{8}-[0-9a-fA-F]{4}-[0-9a-fA-F]{4}-[0-9a-fA-F]{4}-[0-9a-fA-F]{12})").find(pathStr)
                seriesMatch?.let { series.add(it.value) }
            }

        return mapOf(
            "totalFiles" to totalFiles,
            "totalSize" to totalSize,
            "studies" to studies.size,
            "series" to series.size
        )
    }
}