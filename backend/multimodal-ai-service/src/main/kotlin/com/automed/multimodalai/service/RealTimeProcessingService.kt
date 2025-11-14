package com.automed.multimodalai.service

import com.automed.multimodalai.dto.*
import org.slf4j.LoggerFactory
import org.springframework.messaging.simp.SimpMessagingTemplate
import org.springframework.stereotype.Service
import reactor.core.publisher.Flux
import reactor.core.publisher.Mono
import java.time.LocalDateTime
import java.util.concurrent.ConcurrentHashMap
import kotlin.random.Random

@Service
class RealTimeProcessingService(
    private val messagingTemplate: SimpMessagingTemplate,
    private val multimodalFusionService: MultimodalFusionService
) {

    private val logger = LoggerFactory.getLogger(RealTimeProcessingService::class.java)
    private val activeSessions = ConcurrentHashMap<String, ProcessingSession>()
    private val random = Random(System.currentTimeMillis())

    fun startRealTimeProcessing(request: RealTimeProcessingRequest): Mono<RealTimeProcessingResponse> {
        return Mono.fromCallable {
            logger.info("Starting real-time processing for session: ${request.sessionId}")

            val startTime = System.currentTimeMillis()

            // Create or update session
            val session = activeSessions.computeIfAbsent(request.sessionId) {
                ProcessingSession(
                    sessionId = request.sessionId,
                    startTime = LocalDateTime.now(),
                    modality = request.modality,
                    priority = request.priority
                )
            }

            // Process the data based on modality
            val result = when (request.modality) {
                DataModality.TEXT -> processTextRealTime(request.data as String)
                DataModality.IMAGE -> processImageRealTime(request.data as String) // URL or base64
                DataModality.VITALS -> processVitalsRealTime(request.data as List<VitalMeasurement>)
                DataModality.GENOMIC -> processGenomicRealTime(request.data as String)
                DataModality.MULTIMODAL -> processMultimodalRealTime(request.data as MultimodalFusionRequest)
            }

            val processingTime = System.currentTimeMillis() - startTime
            val confidence = calculateRealTimeConfidence(result, request.modality)

            // Send real-time update via WebSocket
            sendRealTimeUpdate(request.sessionId, result, confidence)

            // Update session statistics
            session.update(result, processingTime)

            RealTimeProcessingResponse(
                sessionId = request.sessionId,
                result = result,
                processingTimeMs = processingTime,
                confidence = confidence
            )
        }
    }

    fun getRealTimeStream(sessionId: String): Flux<RealTimeUpdate> {
        return Flux.create { sink ->
            val session = activeSessions[sessionId]
            if (session != null) {
                // Send periodic updates
                val disposable = Flux.interval(java.time.Duration.ofSeconds(1))
                    .map {
                        RealTimeUpdate(
                            sessionId = sessionId,
                            timestamp = LocalDateTime.now(),
                            status = "processing",
                            currentResults = session.recentResults.takeLast(5),
                            metrics = ProcessingMetrics(
                                averageProcessingTime = session.averageProcessingTime(),
                                totalProcessed = session.totalProcessed,
                                currentThroughput = session.currentThroughput()
                            )
                        )
                    }
                    .subscribe(sink::next)

                sink.onDispose(disposable::dispose)
            } else {
                sink.error(IllegalArgumentException("Session not found: $sessionId"))
            }
        }
    }

    fun stopRealTimeProcessing(sessionId: String): Mono<Void> {
        return Mono.fromRunnable {
            logger.info("Stopping real-time processing for session: $sessionId")
            activeSessions.remove(sessionId)
        }
    }

    private fun processTextRealTime(text: String): Any {
        // Real-time text analysis - simplified
        val keywords = listOf("pain", "fever", "cough", "headache", "nausea")
        val detectedSymptoms = keywords.filter { text.contains(it, ignoreCase = true) }

        return TextAnalysisResult(
            content = text,
            detectedSymptoms = detectedSymptoms,
            sentiment = analyzeSentiment(text),
            urgency = calculateUrgency(text, detectedSymptoms),
            extractedEntities = extractEntities(text)
        )
    }

    private fun processImageRealTime(imageData: String): Any {
        // Real-time image analysis - simplified
        return ImageAnalysisResult(
            imageUrl = imageData,
            findings = listOf("Normal chest X-ray", "No acute abnormalities detected"),
            confidence = random.nextDouble(0.8, 0.95),
            processingTime = random.nextLong(100, 500)
        )
    }

    private fun processVitalsRealTime(measurements: List<VitalMeasurement>): Any {
        // Real-time vitals analysis
        val alerts = measurements.mapNotNull { measurement ->
            when (measurement.type) {
                "heart_rate" -> {
                    if (measurement.value < 50 || measurement.value > 120) {
                        VitalAlert("Abnormal heart rate", measurement.type, measurement.value, "bpm")
                    } else null
                }
                "blood_pressure" -> {
                    if (measurement.value < 90 || measurement.value > 180) {
                        VitalAlert("Abnormal blood pressure", measurement.type, measurement.value, "mmHg")
                    } else null
                }
                "oxygen_saturation" -> {
                    if (measurement.value < 95) {
                        VitalAlert("Low oxygen saturation", measurement.type, measurement.value, "%")
                    } else null
                }
                else -> null
            }
        }

        return VitalsAnalysisResult(
            measurements = measurements,
            alerts = alerts,
            overallStatus = if (alerts.isEmpty()) "Normal" else "Abnormal",
            trends = calculateTrends(measurements)
        )
    }

    private fun processGenomicRealTime(sequence: String): Any {
        // Real-time genomic analysis - simplified
        val gcContent = calculateGCContent(sequence)
        val variants = detectSimpleVariants(sequence)

        return GenomicAnalysisResult(
            sequence = sequence,
            gcContent = gcContent,
            detectedVariants = variants,
            qualityScore = calculateSequenceQuality(sequence),
            analysis = "Real-time genomic sequence analysis completed"
        )
    }

    private fun processMultimodalRealTime(request: MultimodalFusionRequest): Any {
        // Full multimodal fusion for real-time processing
        return multimodalFusionService.fuseMultimodalData(request).block()
    }

    private fun calculateRealTimeConfidence(result: Any, modality: DataModality): Double {
        return when (modality) {
            DataModality.TEXT -> 0.85
            DataModality.IMAGE -> 0.80
            DataModality.VITALS -> 0.90
            DataModality.GENOMIC -> 0.75
            DataModality.MULTIMODAL -> 0.82
        }
    }

    private fun sendRealTimeUpdate(sessionId: String, result: Any, confidence: Double) {
        val update = RealTimeUpdate(
            sessionId = sessionId,
            timestamp = LocalDateTime.now(),
            status = "processed",
            currentResults = listOf(result),
            metrics = ProcessingMetrics(
                averageProcessingTime = 150.0,
                totalProcessed = 1,
                currentThroughput = 6.67
            )
        )

        messagingTemplate.convertAndSend("/topic/realtime/$sessionId", update)
    }

    private fun analyzeSentiment(text: String): String {
        val positiveWords = listOf("good", "better", "improving", "stable")
        val negativeWords = listOf("pain", "worse", "severe", "critical")

        val positiveCount = positiveWords.count { text.contains(it, ignoreCase = true) }
        val negativeCount = negativeWords.count { text.contains(it, ignoreCase = true) }

        return when {
            positiveCount > negativeCount -> "positive"
            negativeCount > positiveCount -> "negative"
            else -> "neutral"
        }
    }

    private fun calculateUrgency(text: String, symptoms: List<String>): String {
        val urgentSymptoms = listOf("chest pain", "shortness of breath", "severe pain")
        val urgentDetected = urgentSymptoms.any { symptom ->
            text.contains(symptom, ignoreCase = true)
        }

        return if (urgentDetected || symptoms.size > 3) "high" else if (symptoms.isNotEmpty()) "medium" else "low"
    }

    private fun extractEntities(text: String): List<String> {
        // Simple entity extraction - in production, use NLP models
        val entities = mutableListOf<String>()
        val medicalTerms = listOf("diabetes", "hypertension", "pneumonia", "asthma", "cancer")

        medicalTerms.forEach { term ->
            if (text.contains(term, ignoreCase = true)) {
                entities.add(term)
            }
        }

        return entities
    }

    private fun calculateTrends(measurements: List<VitalMeasurement>): Map<String, String> {
        // Simple trend calculation
        return measurements.groupBy { it.type }.mapValues { (_, measurements) ->
            if (measurements.size < 2) "stable"
            else {
                val sorted = measurements.sortedBy { it.timestamp }
                val first = sorted.first().value
                val last = sorted.last().value
                when {
                    last > first * 1.1 -> "increasing"
                    last < first * 0.9 -> "decreasing"
                    else -> "stable"
                }
            }
        }
    }

    private fun calculateGCContent(sequence: String): Double {
        val gcCount = sequence.count { it.uppercaseChar() in listOf('G', 'C') }
        return gcCount.toDouble() / sequence.length
    }

    private fun detectSimpleVariants(sequence: String): List<GeneticVariant> {
        // Simplified variant detection
        val variants = mutableListOf<GeneticVariant>()
        sequence.forEachIndexed { index, char ->
            if (char.uppercaseChar() !in listOf('A', 'T', 'C', 'G')) {
                variants.add(GeneticVariant(
                    position = index,
                    reference = "N",
                    alternate = char.toString(),
                    clinicalSignificance = "unknown"
                ))
            }
        }
        return variants
    }

    private fun calculateSequenceQuality(sequence: String): Double {
        val validBases = sequence.count { it.uppercaseChar() in listOf('A', 'T', 'C', 'G') }
        return validBases.toDouble() / sequence.length
    }

    // Supporting data classes
    data class ProcessingSession(
        val sessionId: String,
        val startTime: LocalDateTime,
        val modality: DataModality,
        val priority: Priority,
        var totalProcessed: Int = 0,
        val processingTimes: MutableList<Long> = mutableListOf(),
        val recentResults: MutableList<Any> = mutableListOf()
    ) {
        fun update(result: Any, processingTime: Long) {
            totalProcessed++
            processingTimes.add(processingTime)
            recentResults.add(result)

            // Keep only recent results
            if (recentResults.size > 10) {
                recentResults.removeAt(0)
            }
            if (processingTimes.size > 100) {
                processingTimes.removeAt(0)
            }
        }

        fun averageProcessingTime(): Double = processingTimes.average()
        fun currentThroughput(): Double = if (processingTimes.isNotEmpty()) 1000.0 / averageProcessingTime() else 0.0
    }

    data class RealTimeUpdate(
        val sessionId: String,
        val timestamp: LocalDateTime,
        val status: String,
        val currentResults: List<Any>,
        val metrics: ProcessingMetrics
    )

    data class ProcessingMetrics(
        val averageProcessingTime: Double,
        val totalProcessed: Int,
        val currentThroughput: Double
    )

    data class TextAnalysisResult(
        val content: String,
        val detectedSymptoms: List<String>,
        val sentiment: String,
        val urgency: String,
        val extractedEntities: List<String>
    )

    data class ImageAnalysisResult(
        val imageUrl: String,
        val findings: List<String>,
        val confidence: Double,
        val processingTime: Long
    )

    data class VitalsAnalysisResult(
        val measurements: List<VitalMeasurement>,
        val alerts: List<VitalAlert>,
        val overallStatus: String,
        val trends: Map<String, String>
    )

    data class VitalAlert(
        val message: String,
        val type: String,
        val value: Double,
        val unit: String
    )

    data class GenomicAnalysisResult(
        val sequence: String,
        val gcContent: Double,
        val detectedVariants: List<GeneticVariant>,
        val qualityScore: Double,
        val analysis: String
    )
}