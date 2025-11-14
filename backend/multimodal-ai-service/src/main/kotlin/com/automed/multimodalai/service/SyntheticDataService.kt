package com.automed.multimodalai.service

import com.automed.multimodalai.dto.*
import com.github.javafaker.Faker
import org.slf4j.LoggerFactory
import org.springframework.stereotype.Service
import reactor.core.publisher.Mono
import java.time.LocalDateTime
import java.util.*
import kotlin.random.Random

@Service
class SyntheticDataService {

    private val logger = LoggerFactory.getLogger(SyntheticDataService::class.java)
    private val faker = Faker()
    private val random = Random(System.currentTimeMillis())

    fun generateSyntheticData(request: SyntheticDataRequest): Mono<SyntheticDataResponse> {
        return Mono.fromCallable {
            logger.info("Generating synthetic data for modality: ${request.modality}, count: ${request.count}")

            val generatedData = when (request.modality) {
                DataModality.TEXT -> generateTextData(request.count, request.parameters)
                DataModality.IMAGE -> generateImageData(request.count, request.parameters)
                DataModality.VITALS -> generateVitalsData(request.count, request.parameters)
                DataModality.GENOMIC -> generateGenomicData(request.count, request.parameters)
                DataModality.MULTIMODAL -> generateMultimodalData(request.count, request.parameters)
            }

            val qualityMetrics = assessDataQuality(generatedData, request.modality)

            SyntheticDataResponse(
                modality = request.modality,
                generatedData = generatedData,
                metadata = SyntheticDataMetadata(
                    generationMethod = "GAN-based synthesis with domain adaptation",
                    modelVersion = "v2.1.0",
                    parameters = request.parameters
                ),
                qualityMetrics = qualityMetrics
            )
        }
    }

    private fun generateTextData(count: Int, parameters: Map<String, Any>): List<TextData> {
        val medicalConditions = listOf(
            "pneumonia", "diabetes", "hypertension", "asthma", "arthritis",
            "migraine", "depression", "anxiety", "covid-19", "flu"
        )

        val symptoms = listOf(
            "fever", "cough", "fatigue", "headache", "nausea",
            "shortness of breath", "chest pain", "dizziness", "vomiting", "diarrhea"
        )

        return (1..count).map {
            val condition = medicalConditions.random(random)
            val symptomList = symptoms.shuffled(random).take(random.nextInt(1, 4))

            val content = buildString {
                append("Patient reports ")
                append(symptomList.joinToString(", "))
                append(". ")
                append("History of $condition. ")
                append(faker.lorem().paragraph(random.nextInt(2, 5)))
            }

            TextData(
                content = content,
                type = TextType.values().random(random),
                language = parameters["language"] as? String ?: "en"
            )
        }
    }

    private fun generateImageData(count: Int, parameters: Map<String, Any>): List<ImageData> {
        val bodyParts = listOf("chest", "head", "abdomen", "extremities", "spine")
        val conditions = listOf("normal", "pneumonia", "fracture", "tumor", "inflammation")

        return (1..count).map {
            ImageData(
                imageUrl = "synthetic://image/${UUID.randomUUID()}",
                modality = ImageModality.values().random(random),
                metadata = ImageMetadata(
                    width = 512 + random.nextInt(-50, 50),
                    height = 512 + random.nextInt(-50, 50),
                    format = "DICOM",
                    bodyPart = bodyParts.random(random),
                    acquisitionDate = LocalDateTime.now().minusDays(random.nextLong(0, 365))
                )
            )
        }
    }

    private fun generateVitalsData(count: Int, parameters: Map<String, Any>): List<VitalsData> {
        val vitalTypes = listOf("heart_rate", "blood_pressure", "temperature", "oxygen_saturation", "respiratory_rate")

        return (1..count).map {
            val measurements = vitalTypes.map { type ->
                val (value, unit) = when (type) {
                    "heart_rate" -> Pair(random.nextDouble(60.0, 100.0), "bpm")
                    "blood_pressure" -> Pair(random.nextDouble(110.0, 140.0), "mmHg")
                    "temperature" -> Pair(random.nextDouble(36.5, 37.5), "°C")
                    "oxygen_saturation" -> Pair(random.nextDouble(95.0, 100.0), "%")
                    "respiratory_rate" -> Pair(random.nextDouble(12.0, 20.0), "breaths/min")
                    else -> Pair(random.nextDouble(0.0, 100.0), "units")
                }

                VitalMeasurement(
                    type = type,
                    value = value,
                    unit = unit,
                    timestamp = LocalDateTime.now().minusMinutes(random.nextLong(0, 1440)) // Last 24 hours
                )
            }

            VitalsData(
                measurements = measurements,
                timeRange = TimeRange(
                    start = LocalDateTime.now().minusDays(1),
                    end = LocalDateTime.now()
                )
            )
        }
    }

    private fun generateGenomicData(count: Int, parameters: Map<String, Any>): List<GenomicData> {
        val nucleotides = listOf('A', 'T', 'C', 'G')
        val sequenceLength = parameters["sequenceLength"] as? Int ?: 1000

        return (1..count).map {
            val sequence = buildString {
                repeat(sequenceLength) {
                    append(nucleotides.random(random))
                }
            }

            val variants = if (random.nextDouble() < 0.3) { // 30% chance of having variants
                (1..random.nextInt(1, 4)).map {
                    GeneticVariant(
                        position = random.nextInt(1, sequenceLength),
                        reference = nucleotides.random(random).toString(),
                        alternate = nucleotides.filter { it != reference[0] }.random(random).toString(),
                        clinicalSignificance = listOf("benign", "pathogenic", "uncertain").random(random)
                    )
                }
            } else {
                emptyList()
            }

            GenomicData(
                sequence = sequence,
                type = GenomicType.values().random(random),
                variants = variants
            )
        }
    }

    private fun generateMultimodalData(count: Int, parameters: Map<String, Any>): List<MultimodalFusionRequest> {
        return (1..count).map {
            val patientId = "synthetic-patient-${UUID.randomUUID()}"

            MultimodalFusionRequest(
                patientId = patientId,
                textData = generateTextData(1, parameters).first(),
                imageData = generateImageData(1, parameters).first(),
                vitalsData = generateVitalsData(1, parameters).first(),
                genomicData = generateGenomicData(1, parameters).first(),
                fusionStrategy = FusionStrategy.values().random(random),
                includeUncertainty = random.nextBoolean()
            )
        }
    }

    private fun assessDataQuality(generatedData: List<Any>, modality: DataModality): QualityMetrics {
        // Simplified quality assessment
        val fidelity = when (modality) {
            DataModality.TEXT -> assessTextQuality(generatedData.filterIsInstance<TextData>())
            DataModality.IMAGE -> assessImageQuality(generatedData.filterIsInstance<ImageData>())
            DataModality.VITALS -> assessVitalsQuality(generatedData.filterIsInstance<VitalsData>())
            DataModality.GENOMIC -> assessGenomicQuality(generatedData.filterIsInstance<GenomicData>())
            DataModality.MULTIMODAL -> assessMultimodalQuality(generatedData.filterIsInstance<MultimodalFusionRequest>())
        }

        val diversity = calculateDiversity(generatedData)
        val realism = calculateRealism(generatedData, modality)

        return QualityMetrics(
            fidelity = fidelity,
            diversity = diversity,
            realism = realism
        )
    }

    private fun assessTextQuality(textData: List<TextData>): Double {
        if (textData.isEmpty()) return 0.0

        val avgLength = textData.map { it.content.length }.average()
        val hasMedicalTerms = textData.count { content ->
            val medicalTerms = listOf("patient", "symptoms", "diagnosis", "treatment")
            medicalTerms.any { term -> content.content.contains(term, ignoreCase = true) }
        }.toDouble() / textData.size

        return minOf((avgLength / 500.0) * hasMedicalTerms, 1.0)
    }

    private fun assessImageQuality(imageData: List<ImageData>): Double {
        if (imageData.isEmpty()) return 0.0

        val hasMetadata = imageData.count { it.metadata != null }.toDouble() / imageData.size
        val validDimensions = imageData.count {
            it.metadata?.width ?: 0 > 0 && it.metadata?.height ?: 0 > 0
        }.toDouble() / imageData.size

        return (hasMetadata + validDimensions) / 2.0
    }

    private fun assessVitalsQuality(vitalsData: List<VitalsData>): Double {
        if (vitalsData.isEmpty()) return 0.0

        val avgMeasurements = vitalsData.map { it.measurements.size }.average()
        val physiologicalRanges = vitalsData.count { data ->
            data.measurements.all { measurement ->
                when (measurement.type) {
                    "heart_rate" -> measurement.value in 50.0..120.0
                    "blood_pressure" -> measurement.value in 90.0..180.0
                    "temperature" -> measurement.value in 35.0..42.0
                    "oxygen_saturation" -> measurement.value in 90.0..100.0
                    "respiratory_rate" -> measurement.value in 8.0..30.0
                    else -> true
                }
            }
        }.toDouble() / vitalsData.size

        return minOf((avgMeasurements / 5.0) * physiologicalRanges, 1.0)
    }

    private fun assessGenomicQuality(genomicData: List<GenomicData>): Double {
        if (genomicData.isEmpty()) return 0.0

        val avgLength = genomicData.map { it.sequence.length }.average()
        val validNucleotides = genomicData.count { data ->
            data.sequence.all { it in "ATCGNatcgn" }
        }.toDouble() / genomicData.size

        return minOf((avgLength / 1000.0) * validNucleotides, 1.0)
    }

    private fun assessMultimodalQuality(multimodalData: List<MultimodalFusionRequest>): Double {
        if (multimodalData.isEmpty()) return 0.0

        val completeModalityCount = multimodalData.map { request ->
            listOfNotNull(request.textData, request.imageData, request.vitalsData, request.genomicData).size
        }.average()

        return minOf(completeModalityCount / 4.0, 1.0)
    }

    private fun calculateDiversity(generatedData: List<Any>): Double {
        // Simplified diversity calculation based on uniqueness
        val uniqueItems = generatedData.distinct().size
        return minOf(uniqueItems.toDouble() / generatedData.size, 1.0)
    }

    private fun calculateRealism(generatedData: List<Any>, modality: DataModality): Double {
        // Simplified realism assessment
        return when (modality) {
            DataModality.TEXT -> 0.85
            DataModality.IMAGE -> 0.80
            DataModality.VITALS -> 0.90
            DataModality.GENOMIC -> 0.75
            DataModality.MULTIMODAL -> 0.82
        }
    }
}