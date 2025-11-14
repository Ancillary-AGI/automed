package com.automed.multimodalai.service

import com.automed.multimodalai.dto.*
import org.slf4j.LoggerFactory
import org.springframework.beans.factory.annotation.Value
import org.springframework.stereotype.Service
import org.springframework.web.reactive.function.client.WebClient
import reactor.core.publisher.Mono
import java.time.LocalDateTime

@Service
class PatientDataIntegrationService(
    private val webClient: WebClient
) {

    private val logger = LoggerFactory.getLogger(PatientDataIntegrationService::class.java)

    @Value("\${services.patient-service.url:http://patient-service:8081}")
    private lateinit var patientServiceUrl: String

    @Value("\${services.hospital-service.url:http://hospital-service:8082}")
    private lateinit var hospitalServiceUrl: String

    @Value("\${services.ai-service.url:http://ai-service:8084}")
    private lateinit var aiServiceUrl: String

    fun integratePatientData(request: PatientDataIntegrationRequest): Mono<PatientDataIntegrationResponse> {
        return Mono.fromCallable {
            logger.info("Integrating patient data for patient: ${request.patientId}")

            val integratedData = mutableMapOf<String, Any>()
            val dataQualityMetrics = mutableListOf<Double>()

            // Fetch data from different sources concurrently
            val textDataMono = if (request.includeHistorical && request.modalities.contains(DataModality.TEXT)) {
                fetchTextData(request.patientId)
            } else Mono.just(emptyList<TextData>())

            val imageDataMono = if (request.modalities.contains(DataModality.IMAGE)) {
                fetchImageData(request.patientId)
            } else Mono.just(emptyList<ImageData>())

            val vitalsDataMono = if (request.modalities.contains(DataModality.VITALS)) {
                fetchVitalsData(request.patientId)
            } else Mono.just(emptyList<VitalsData>())

            val genomicDataMono = if (request.modalities.contains(DataModality.GENOMIC)) {
                fetchGenomicData(request.patientId)
            } else Mono.just(emptyList<GenomicData>())

            // Wait for all data to be fetched
            val textData = textDataMono.block() ?: emptyList()
            val imageData = imageDataMono.block() ?: emptyList()
            val vitalsData = vitalsDataMono.block() ?: emptyList()
            val genomicData = genomicDataMono.block() ?: emptyList()

            // Integrate and quality-check the data
            if (textData.isNotEmpty()) {
                integratedData["text"] = textData
                dataQualityMetrics.add(assessTextDataQuality(textData))
            }

            if (imageData.isNotEmpty()) {
                integratedData["images"] = imageData
                dataQualityMetrics.add(assessImageDataQuality(imageData))
            }

            if (vitalsData.isNotEmpty()) {
                integratedData["vitals"] = vitalsData
                dataQualityMetrics.add(assessVitalsDataQuality(vitalsData))
            }

            if (genomicData.isNotEmpty()) {
                integratedData["genomic"] = genomicData
                dataQualityMetrics.add(assessGenomicDataQuality(genomicData))
            }

            // Add patient demographics
            val demographics = fetchPatientDemographics(request.patientId).block()
            if (demographics != null) {
                integratedData["demographics"] = demographics
            }

            // Calculate overall data quality
            val overallQuality = if (dataQualityMetrics.isNotEmpty()) {
                DataQualityMetrics(
                    completeness = calculateCompleteness(integratedData),
                    consistency = calculateConsistency(integratedData),
                    timeliness = calculateTimeliness(integratedData),
                    accuracy = dataQualityMetrics.average()
                )
            } else {
                DataQualityMetrics(0.0, 0.0, 0.0, 0.0)
            }

            PatientDataIntegrationResponse(
                patientId = request.patientId,
                integratedData = integratedData,
                dataQuality = overallQuality,
                lastUpdated = LocalDateTime.now()
            )
        }
    }

    private fun fetchTextData(patientId: String): Mono<List<TextData>> {
        return webClient.get()
            .uri("$patientServiceUrl/api/v1/patients/$patientId/medical-history")
            .retrieve()
            .bodyToMono(String::class.java)
            .map { history ->
                listOf(TextData(
                    content = history,
                    type = TextType.MEDICAL_HISTORY,
                    language = "en"
                ))
            }
            .onErrorResume { e ->
                logger.warn("Failed to fetch text data for patient $patientId: ${e.message}")
                Mono.just(emptyList())
            }
    }

    private fun fetchImageData(patientId: String): Mono<List<ImageData>> {
        return webClient.get()
            .uri("$hospitalServiceUrl/api/v1/patients/$patientId/imaging")
            .retrieve()
            .bodyToMono(List::class.java)
            .map { data ->
                // Convert to ImageData objects - simplified
                (data as List<Map<String, Any>>).map { item ->
                    ImageData(
                        imageUrl = item["url"] as? String ?: "",
                        modality = ImageModality.valueOf(item["modality"] as? String ?: "XRAY"),
                        metadata = ImageMetadata(
                            width = item["width"] as? Int ?: 512,
                            height = item["height"] as? Int ?: 512,
                            format = item["format"] as? String ?: "DICOM",
                            bodyPart = item["bodyPart"] as? String
                        )
                    )
                }
            }
            .onErrorResume { e ->
                logger.warn("Failed to fetch image data for patient $patientId: ${e.message}")
                Mono.just(emptyList())
            }
    }

    private fun fetchVitalsData(patientId: String): Mono<List<VitalsData>> {
        return webClient.get()
            .uri("$patientServiceUrl/api/v1/patients/$patientId/vitals")
            .retrieve()
            .bodyToMono(List::class.java)
            .map { data ->
                // Convert to VitalsData objects - simplified
                (data as List<Map<String, Any>>).map { item ->
                    val measurements = (item["measurements"] as? List<Map<String, Any>>)?.map { measurement ->
                        VitalMeasurement(
                            type = measurement["type"] as? String ?: "unknown",
                            value = (measurement["value"] as? Number)?.toDouble() ?: 0.0,
                            unit = measurement["unit"] as? String ?: "",
                            timestamp = LocalDateTime.parse(measurement["timestamp"] as? String ?: LocalDateTime.now().toString())
                        )
                    } ?: emptyList()

                    VitalsData(
                        measurements = measurements,
                        timeRange = TimeRange(
                            start = LocalDateTime.now().minusDays(7),
                            end = LocalDateTime.now()
                        )
                    )
                }
            }
            .onErrorResume { e ->
                logger.warn("Failed to fetch vitals data for patient $patientId: ${e.message}")
                Mono.just(emptyList())
            }
    }

    private fun fetchGenomicData(patientId: String): Mono<List<GenomicData>> {
        return webClient.get()
            .uri("$aiServiceUrl/api/v1/ai/patients/$patientId/genomic")
            .retrieve()
            .bodyToMono(List::class.java)
            .map { data ->
                // Convert to GenomicData objects - simplified
                (data as List<Map<String, Any>>).map { item ->
                    GenomicData(
                        sequence = item["sequence"] as? String ?: "",
                        type = GenomicType.valueOf(item["type"] as? String ?: "DNA_SEQUENCE"),
                        variants = (item["variants"] as? List<Map<String, Any>>)?.map { variant ->
                            GeneticVariant(
                                position = variant["position"] as? Int ?: 0,
                                reference = variant["reference"] as? String ?: "",
                                alternate = variant["alternate"] as? String ?: "",
                                clinicalSignificance = variant["clinicalSignificance"] as? String
                            )
                        } ?: emptyList()
                    )
                }
            }
            .onErrorResume { e ->
                logger.warn("Failed to fetch genomic data for patient $patientId: ${e.message}")
                Mono.just(emptyList())
            }
    }

    private fun fetchPatientDemographics(patientId: String): Mono<PatientDemographics?> {
        return webClient.get()
            .uri("$patientServiceUrl/api/v1/patients/$patientId/demographics")
            .retrieve()
            .bodyToMono(PatientDemographics::class.java)
            .onErrorResume { e ->
                logger.warn("Failed to fetch demographics for patient $patientId: ${e.message}")
                Mono.empty()
            }
    }

    private fun assessTextDataQuality(textData: List<TextData>): Double {
        if (textData.isEmpty()) return 0.0

        val avgLength = textData.map { it.content.length }.average()
        val hasMedicalContent = textData.count { content ->
            val medicalKeywords = listOf("patient", "diagnosis", "treatment", "symptoms", "medication")
            medicalKeywords.any { keyword -> content.content.contains(keyword, ignoreCase = true) }
        }.toDouble() / textData.size

        return minOf((avgLength / 1000.0) * hasMedicalContent, 1.0)
    }

    private fun assessImageDataQuality(imageData: List<ImageData>): Double {
        if (imageData.isEmpty()) return 0.0

        val hasMetadata = imageData.count { it.metadata != null }.toDouble() / imageData.size
        val validUrls = imageData.count { it.imageUrl.isNotBlank() }.toDouble() / imageData.size

        return (hasMetadata + validUrls) / 2.0
    }

    private fun assessVitalsDataQuality(vitalsData: List<VitalsData>): Double {
        if (vitalsData.isEmpty()) return 0.0

        val avgMeasurements = vitalsData.map { it.measurements.size }.average()
        val physiologicalRanges = vitalsData.count { data ->
            data.measurements.all { measurement ->
                when (measurement.type) {
                    "heart_rate" -> measurement.value in 40.0..150.0
                    "blood_pressure" -> measurement.value in 80.0..200.0
                    "temperature" -> measurement.value in 35.0..45.0
                    "oxygen_saturation" -> measurement.value in 80.0..100.0
                    "respiratory_rate" -> measurement.value in 5.0..40.0
                    else -> true
                }
            }
        }.toDouble() / vitalsData.size

        return minOf((avgMeasurements / 5.0) * physiologicalRanges, 1.0)
    }

    private fun assessGenomicDataQuality(genomicData: List<GenomicData>): Double {
        if (genomicData.isEmpty()) return 0.0

        val avgLength = genomicData.map { it.sequence.length }.average()
        val validSequences = genomicData.count { data ->
            data.sequence.all { it.uppercaseChar() in "ATCGN" }
        }.toDouble() / genomicData.size

        return minOf((avgLength / 1000.0) * validSequences, 1.0)
    }

    private fun calculateCompleteness(integratedData: Map<String, Any>): Double {
        val expectedModalities = listOf("text", "images", "vitals", "genomic", "demographics")
        val presentModalities = expectedModalities.count { integratedData.containsKey(it) }
        return presentModalities.toDouble() / expectedModalities.size
    }

    private fun calculateConsistency(integratedData: Map<String, Any>): Double {
        // Simplified consistency check - ensure data types are consistent
        var consistentCount = 0
        var totalChecks = 0

        if (integratedData.containsKey("text")) {
            totalChecks++
            if ((integratedData["text"] as? List<*>)?.all { it is TextData } == true) consistentCount++
        }

        if (integratedData.containsKey("images")) {
            totalChecks++
            if ((integratedData["images"] as? List<*>)?.all { it is ImageData } == true) consistentCount++
        }

        if (integratedData.containsKey("vitals")) {
            totalChecks++
            if ((integratedData["vitals"] as? List<*>)?.all { it is VitalsData } == true) consistentCount++
        }

        return if (totalChecks > 0) consistentCount.toDouble() / totalChecks else 1.0
    }

    private fun calculateTimeliness(integratedData: Map<String, Any>): Double {
        // Check how recent the data is
        val now = LocalDateTime.now()
        var recentDataCount = 0
        var totalDataPoints = 0

        // Check vitals timeliness
        (integratedData["vitals"] as? List<VitalsData>)?.forEach { vitalsData ->
            vitalsData.measurements.forEach { measurement ->
                totalDataPoints++
                if (java.time.Duration.between(measurement.timestamp, now).toDays() <= 7) {
                    recentDataCount++
                }
            }
        }

        // Check images timeliness
        (integratedData["images"] as? List<ImageData>)?.forEach { imageData ->
            totalDataPoints++
            if (imageData.metadata?.acquisitionDate?.let { java.time.Duration.between(it, now).toDays() <= 30 } == true) {
                recentDataCount++
            }
        }

        return if (totalDataPoints > 0) recentDataCount.toDouble() / totalDataPoints else 1.0
    }

    // Supporting data class
    data class PatientDemographics(
        val patientId: String,
        val age: Int,
        val gender: String,
        val ethnicity: String? = null,
        val medicalHistory: List<String> = emptyList()
    )
}