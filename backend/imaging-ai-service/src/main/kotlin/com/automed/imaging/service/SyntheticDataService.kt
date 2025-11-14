package com.automed.imaging.service

import org.slf4j.LoggerFactory
import org.springframework.stereotype.Service

@Service
class SyntheticDataService(
    private val diffusionModelService: DiffusionModelService
) {

    private val logger = LoggerFactory.getLogger(SyntheticDataService::class.java)

    fun generateSyntheticImage(
        templateImageId: String?,
        modality: String,
        pathology: String?,
        variationLevel: com.automed.imaging.dto.VariationLevel
    ): ByteArray? {
        return try {
            // Use diffusion model to generate synthetic images
            val parameters = mapOf(
                "variationLevel" to variationLevel.toString(),
                "pathology" to (pathology ?: "normal"),
                "templateBased" to (templateImageId != null).toString()
            )

            diffusionModelService.generateSyntheticImage(modality, pathology, parameters)
        } catch (e: Exception) {
            logger.error("Failed to generate synthetic image", e)
            null
        }
    }
}