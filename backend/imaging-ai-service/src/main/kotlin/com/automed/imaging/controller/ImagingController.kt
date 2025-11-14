package com.automed.imaging.controller

import com.automed.imaging.dto.*
import com.automed.imaging.service.*
import org.slf4j.LoggerFactory
import org.springframework.http.MediaType
import org.springframework.http.ResponseEntity
import org.springframework.security.access.prepost.PreAuthorize
import org.springframework.web.bind.annotation.*
import org.springframework.web.multipart.MultipartFile
import java.util.concurrent.CompletableFuture

@RestController
@RequestMapping("/api/v1/imaging")
class ImagingController(
    private val imagingService: ImagingService,
    private val dicomService: DicomService,
    private val diffusionModelService: DiffusionModelService,
    private val visionTransformerService: VisionTransformerService,
    private val pacsIntegrationService: PACSIntegrationService,
    private val federatedLearningService: FederatedLearningService
) {

    private val logger = LoggerFactory.getLogger(ImagingController::class.java)

    @GetMapping("/health")
    fun health(): ResponseEntity<Map<String, Any>> {
        val health = mapOf(
            "status" to "UP",
            "service" to "imaging-ai-service",
            "models" to mapOf(
                "diffusion" to diffusionModelService.isModelAvailable(),
                "visionTransformer" to visionTransformerService.isModelAvailable()
            ),
            "storage" to dicomService.getStorageStats()
        )
        return ResponseEntity.ok(health)
    }

    @PostMapping("/upload", consumes = [MediaType.MULTIPART_FORM_DATA_VALUE])
    @PreAuthorize("hasRole('RADIOLOGIST') or hasRole('ADMIN')")
    fun uploadImage(
        @RequestParam("file") file: MultipartFile,
        @RequestParam("patientId") patientId: String,
        @RequestParam("modality") modality: String,
        @RequestParam("studyDescription", required = false) studyDescription: String?,
        @RequestParam("seriesDescription", required = false) seriesDescription: String?,
        @RequestParam("bodyPart", required = false) bodyPart: String?
    ): ResponseEntity<ImageUploadResponse> {
        return try {
            val request = ImageUploadRequest(
                patientId = patientId,
                studyDescription = studyDescription,
                seriesDescription = seriesDescription,
                modality = modality,
                bodyPart = bodyPart
            )

            val response = imagingService.uploadImage(file.bytes, request)
            ResponseEntity.ok(response)
        } catch (e: Exception) {
            logger.error("Failed to upload image", e)
            ResponseEntity.badRequest().body(
                ImageUploadResponse(
                    imageId = "",
                    status = UploadStatus.FAILED,
                    message = e.message ?: "Upload failed"
                )
            )
        }
    }

    @PostMapping("/dicom/store")
    @PreAuthorize("hasRole('RADIOLOGIST') or hasRole('ADMIN') or hasRole('SYSTEM')")
    fun storeDicom(@RequestBody dicomData: ByteArray): ResponseEntity<Map<String, String>> {
        return try {
            // Parse DICOM metadata (simplified)
            val filePath = dicomService.storeDicomFile(org.dcm4che3.data.Attributes(), dicomData)
            ResponseEntity.ok(mapOf("filePath" to filePath, "status" to "stored"))
        } catch (e: Exception) {
            logger.error("Failed to store DICOM", e)
            ResponseEntity.badRequest().body(mapOf("error" to (e.message ?: "Storage failed")))
        }
    }

    @GetMapping("/dicom/retrieve/{sopInstanceUid}")
    @PreAuthorize("hasRole('RADIOLOGIST') or hasRole('PHYSICIAN') or hasRole('ADMIN')")
    fun retrieveDicom(@PathVariable sopInstanceUid: String): ResponseEntity<ByteArray> {
        return try {
            val dicomData = dicomService.retrieveDicomFile(sopInstanceUid)
            if (dicomData != null) {
                ResponseEntity.ok()
                    .contentType(MediaType.parseMediaType("application/dicom"))
                    .body(dicomData.second)
            } else {
                ResponseEntity.notFound().build()
            }
        } catch (e: Exception) {
            logger.error("Failed to retrieve DICOM", e)
            ResponseEntity.badRequest().build()
        }
    }

    @PostMapping("/process")
    @PreAuthorize("hasRole('RADIOLOGIST') or hasRole('ADMIN')")
    fun processImage(@RequestBody request: ImageProcessingRequest): ResponseEntity<ImageProcessingResponse> {
        return try {
            val response = imagingService.processImage(request)
            ResponseEntity.ok(response)
        } catch (e: Exception) {
            logger.error("Failed to process image", e)
            ResponseEntity.badRequest().body(
                ImageProcessingResponse(
                    processingId = request.imageId,
                    status = ProcessingStatus.FAILED,
                    error = e.message
                )
            )
        }
    }

    @PostMapping("/ai/analyze/{imageId}")
    @PreAuthorize("hasRole('RADIOLOGIST') or hasRole('ADMIN')")
    fun analyzeImage(@PathVariable imageId: String): ResponseEntity<AIAnalysisResponse> {
        return try {
            val analysis = imagingService.analyzeImage(imageId)
            ResponseEntity.ok(analysis)
        } catch (e: Exception) {
            logger.error("Failed to analyze image", e)
            ResponseEntity.badRequest().build()
        }
    }

    @PostMapping("/ai/enhance/{imageId}")
    @PreAuthorize("hasRole('RADIOLOGIST') or hasRole('ADMIN')")
    fun enhanceImage(
        @PathVariable imageId: String,
        @RequestParam("enhancementType") enhancementType: String
    ): ResponseEntity<ByteArray> {
        return try {
            val enhancedImage = imagingService.enhanceImage(imageId, enhancementType)
            ResponseEntity.ok()
                .contentType(MediaType.IMAGE_PNG)
                .body(enhancedImage)
        } catch (e: Exception) {
            logger.error("Failed to enhance image", e)
            ResponseEntity.badRequest().build()
        }
    }

    @PostMapping("/ai/translate")
    @PreAuthorize("hasRole('RADIOLOGIST') or hasRole('ADMIN')")
    fun translateModality(@RequestBody request: CrossModalityRequest): ResponseEntity<CrossModalityResponse> {
        return try {
            val response = imagingService.translateModality(request)
            ResponseEntity.ok(response)
        } catch (e: Exception) {
            logger.error("Failed to translate modality", e)
            ResponseEntity.badRequest().build()
        }
    }

    @PostMapping("/ai/synthetic")
    @PreAuthorize("hasRole('RADIOLOGIST') or hasRole('ADMIN')")
    fun generateSynthetic(@RequestBody request: SyntheticDataRequest): ResponseEntity<SyntheticDataResponse> {
        return try {
            val response = imagingService.generateSyntheticData(request)
            ResponseEntity.ok(response)
        } catch (e: Exception) {
            logger.error("Failed to generate synthetic data", e)
            ResponseEntity.badRequest().build()
        }
    }

    @PostMapping("/3d/reconstruct")
    @PreAuthorize("hasRole('RADIOLOGIST') or hasRole('ADMIN')")
    fun reconstruct3D(@RequestBody request: ThreeDReconstructionRequest): ResponseEntity<ThreeDModelResponse> {
        return try {
            val response = imagingService.reconstruct3D(request)
            ResponseEntity.ok(response)
        } catch (e: Exception) {
            logger.error("Failed to reconstruct 3D model", e)
            ResponseEntity.badRequest().build()
        }
    }

    @GetMapping("/images")
    @PreAuthorize("hasRole('RADIOLOGIST') or hasRole('PHYSICIAN') or hasRole('ADMIN')")
    fun queryImages(
        @RequestParam("patientId", required = false) patientId: String?,
        @RequestParam("modality", required = false) modality: String?,
        @RequestParam("page", defaultValue = "0") page: Int,
        @RequestParam("size", defaultValue = "20") size: Int
    ): ResponseEntity<ImageQueryResponse> {
        return try {
            val response = imagingService.queryImages(patientId, modality, page, size)
            ResponseEntity.ok(response)
        } catch (e: Exception) {
            logger.error("Failed to query images", e)
            ResponseEntity.badRequest().build()
        }
    }

    @GetMapping("/images/{imageId}")
    @PreAuthorize("hasRole('RADIOLOGIST') or hasRole('PHYSICIAN') or hasRole('ADMIN')")
    fun getImageDetails(@PathVariable imageId: String): ResponseEntity<ImageDetailsResponse> {
        return try {
            val response = imagingService.getImageDetails(imageId)
            ResponseEntity.ok(response)
        } catch (e: Exception) {
            logger.error("Failed to get image details", e)
            ResponseEntity.notFound().build()
        }
    }

    @GetMapping("/pacs/studies")
    @PreAuthorize("hasRole('RADIOLOGIST') or hasRole('ADMIN')")
    fun queryPACS(@RequestBody request: PACSQueryRequest): ResponseEntity<PACSQueryResponse> {
        return try {
            val response = pacsIntegrationService.queryStudies(request)
            ResponseEntity.ok(response)
        } catch (e: Exception) {
            logger.error("Failed to query PACS", e)
            ResponseEntity.badRequest().build()
        }
    }

    @PostMapping("/pacs/transfer")
    @PreAuthorize("hasRole('RADIOLOGIST') or hasRole('ADMIN')")
    fun transferFromPACS(@RequestBody request: PACSTransferRequest): ResponseEntity<PACSTransferResponse> {
        return try {
            val response = pacsIntegrationService.transferStudy(request)
            ResponseEntity.ok(response)
        } catch (e: Exception) {
            logger.error("Failed to transfer from PACS", e)
            ResponseEntity.badRequest().build()
        }
    }

    @PostMapping("/federated/train")
    @PreAuthorize("hasRole('ADMIN') or hasRole('SYSTEM')")
    fun startFederatedTraining(@RequestBody request: FederatedLearningRequest): ResponseEntity<FederatedLearningResponse> {
        return try {
            val response = federatedLearningService.startTraining(request)
            ResponseEntity.ok(response)
        } catch (e: Exception) {
            logger.error("Failed to start federated training", e)
            ResponseEntity.badRequest().build()
        }
    }

    @PostMapping("/batch/process")
    @PreAuthorize("hasRole('RADIOLOGIST') or hasRole('ADMIN')")
    fun batchProcess(@RequestBody request: BatchProcessingRequest): ResponseEntity<BatchProcessingResponse> {
        return try {
            val response = imagingService.batchProcess(request)
            ResponseEntity.ok(response)
        } catch (e: Exception) {
            logger.error("Failed to start batch processing", e)
            ResponseEntity.badRequest().build()
        }
    }

    @GetMapping("/quality/{imageId}")
    @PreAuthorize("hasRole('RADIOLOGIST') or hasRole('ADMIN')")
    fun assessQuality(@PathVariable imageId: String): ResponseEntity<QualityAssessmentResponse> {
        return try {
            val response = imagingService.assessQuality(imageId)
            ResponseEntity.ok(response)
        } catch (e: Exception) {
            logger.error("Failed to assess quality", e)
            ResponseEntity.badRequest().build()
        }
    }
}