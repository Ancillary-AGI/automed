package com.automed.imaging.config

import org.dcm4che3.net.ApplicationEntity
import org.dcm4che3.net.Connection
import org.dcm4che3.net.Device
import org.dcm4che3.net.TransferCapability
import org.dcm4che3.net.service.BasicCEchoSCP
import org.dcm4che3.net.service.BasicCStoreSCP
import org.dcm4che3.net.service.DicomServiceRegistry
import org.springframework.beans.factory.annotation.Value
import org.springframework.context.annotation.Bean
import org.springframework.context.annotation.Configuration
import java.io.File
import java.util.concurrent.Executors

@Configuration
class DicomConfig {

    @Value("\${imaging.dicom.aet:IMAGING_AI_SERVICE}")
    private lateinit var aeTitle: String

    @Value("\${imaging.dicom.port:104}")
    private val port: Int = 104

    @Value("\${imaging.dicom.timeout:30000}")
    private val timeout: Int = 30000

    @Value("\${imaging.dicom.max-pdu-length:16384}")
    private val maxPduLength: Int = 16384

    @Value("\${imaging.dicom.storage.directory:/tmp/imaging-ai-storage}")
    private lateinit var storageDirectory: String

    @Bean
    fun dicomDevice(): Device {
        val device = Device("imaging-ai-device")

        // Create application entity
        val ae = ApplicationEntity(aeTitle)
        device.addApplicationEntity(ae)

        // Configure connection
        val conn = Connection()
        conn.port = port
        conn.receivePDULength = maxPduLength
        conn.sendPDULength = maxPduLength
        conn.responseTimeout = timeout
        conn.requestTimeout = timeout
        conn.idleTimeout = timeout
        conn.releaseTimeout = timeout

        device.addConnection(conn)
        ae.addConnection(conn)

        // Add transfer capabilities for C-STORE (receiving images)
        val transferCapabilities = arrayOf(
            TransferCapability(
                "*",
                "*",
                TransferCapability.Role.SCP,
                arrayOf(
                    "1.2.840.10008.1.2",      // Implicit VR Little Endian
                    "1.2.840.10008.1.2.1",    // Explicit VR Little Endian
                    "1.2.840.10008.1.2.2",    // Explicit VR Big Endian
                    "1.2.840.10008.1.2.4.50", // JPEG Baseline
                    "1.2.840.10008.1.2.4.51", // JPEG Extended
                    "1.2.840.10008.1.2.4.57", // JPEG Lossless
                    "1.2.840.10008.1.2.4.70", // JPEG Lossless SV1
                    "1.2.840.10008.1.2.4.80", // JPEG-LS Lossless
                    "1.2.840.10008.1.2.4.81", // JPEG-LS Lossy
                    "1.2.840.10008.1.2.4.90", // JPEG 2000 Lossless
                    "1.2.840.10008.1.2.4.91"  // JPEG 2000 Lossy
                )
            )
        )

        ae.transferCapabilities = transferCapabilities

        // Register DICOM services
        val serviceRegistry = DicomServiceRegistry()
        serviceRegistry.addDicomService(BasicCEchoSCP())
        serviceRegistry.addDicomService(BasicCStoreSCP("*"))

        ae.dicomServiceRegistry = serviceRegistry

        return device
    }

    @Bean
    fun storageDirectory(): File {
        val dir = File(storageDirectory)
        if (!dir.exists()) {
            dir.mkdirs()
        }
        return dir
    }

    @Bean
    fun dicomExecutor() = Executors.newCachedThreadPool { r ->
        Thread(r, "dicom-executor").apply {
            isDaemon = true
        }
    }
}