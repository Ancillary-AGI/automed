package com.automed.monitoring.service

import com.automed.monitoring.model.*
import io.micrometer.core.instrument.MeterRegistry
import io.micrometer.core.instrument.Timer
import org.springframework.kafka.core.KafkaTemplate
import org.springframework.scheduling.annotation.Scheduled
import org.springframework.stereotype.Service
import org.springframework.web.client.RestTemplate
import java.time.LocalDateTime
import java.util.concurrent.ConcurrentHashMap
import java.util.concurrent.TimeUnit

@Service
class PerformanceMonitoringService(
    private val meterRegistry: MeterRegistry,
    private val kafkaTemplate: KafkaTemplate<String, Any>,
    private val restTemplate: RestTemplate
) {
    
    private val serviceMetrics = ConcurrentHashMap<String, ServiceMetrics>()
    private val alertThresholds = mapOf(
        "response_time" to 5000.0, // 5 seconds
        "error_rate" to 0.05, // 5%
        "cpu_usage" to 0.8, // 80%
        "memory_usage" to 0.85, // 85%
        "disk_usage" to 0.9 // 90%
    )

    @Scheduled(fixedRate = 30000) // Every 30 seconds
    fun collectMetrics() {
        val services = listOf(
            "patient-service",
            "hospital-service", 
            "consultation-service",
            "ai-service",
            "clinical-decision-service",
            "workflow-automation-service",
            "sync-service"
        )

        services.forEach { serviceName ->
            try {
                collectServiceMetrics(serviceName)
            } catch (e: Exception) {
                handleMetricCollectionError(serviceName, e)
            }
        }
    }

    private fun collectServiceMetrics(serviceName: String) {
        val baseUrl = "http://$serviceName:808${getServicePort(serviceName)}"
        
        // Collect health metrics
        val healthResponse = restTemplate.getForObject("$baseUrl/actuator/health", Map::class.java)
        val isHealthy = healthResponse?.get("status") == "UP"
        
        // Collect performance metrics
        val metricsResponse = restTemplate.getForObject("$baseUrl/actuator/metrics", Map::class.java)
        val prometheusResponse = restTemplate.getForObject("$baseUrl/actuator/prometheus", String::class.java)
        
        val metrics = parseMetrics(prometheusResponse ?: "")
        
        val serviceMetrics = ServiceMetrics(
            serviceName = serviceName,
            timestamp = LocalDateTime.now(),
            isHealthy = isHealthy,
            responseTime = metrics["http_server_requests_seconds_max"] ?: 0.0,
            errorRate = calculateErrorRate(metrics),
            cpuUsage = metrics["process_cpu_usage"] ?: 0.0,
            memoryUsage = calculateMemoryUsage(metrics),
            diskUsage = metrics["disk_free_bytes"]?.let { 1.0 - it } ?: 0.0,
            throughput = metrics["http_server_requests_seconds_count"] ?: 0.0,
            activeConnections = metrics["tomcat_sessions_active_current"] ?: 0.0,
            jvmMetrics = JvmMetrics(
                heapUsed = metrics["jvm_memory_used_bytes_heap"] ?: 0.0,
                heapMax = metrics["jvm_memory_max_bytes_heap"] ?: 0.0,
                nonHeapUsed = metrics["jvm_memory_used_bytes_nonheap"] ?: 0.0,
                gcCount = metrics["jvm_gc_pause_seconds_count"] ?: 0.0,
                gcTime = metrics["jvm_gc_pause_seconds_sum"] ?: 0.0,
                threadCount = metrics["jvm_threads_live"] ?: 0.0
            ),
            databaseMetrics = DatabaseMetrics(
                connectionPoolActive = metrics["hikaricp_connections_active"] ?: 0.0,
                connectionPoolIdle = metrics["hikaricp_connections_idle"] ?: 0.0,
                queryExecutionTime = metrics["spring_data_repository_invocations_seconds_max"] ?: 0.0,
                slowQueries = metrics["slow_query_count"] ?: 0.0
            )
        )
        
        this.serviceMetrics[serviceName] = serviceMetrics
        
        // Record metrics in Micrometer
        recordMicrometerMetrics(serviceMetrics)
        
        // Check for alerts
        checkAlerts(serviceMetrics)
        
        // Publish metrics to Kafka
        publishMetrics(serviceMetrics)
    }

    private fun parseMetrics(prometheusData: String): Map<String, Double> {
        val metrics = mutableMapOf<String, Double>()
        
        prometheusData.lines().forEach { line ->
            if (!line.startsWith("#") && line.contains(" ")) {
                val parts = line.split(" ")
                if (parts.size >= 2) {
                    val metricName = parts[0].substringBefore("{")
                    val value = parts[1].toDoubleOrNull()
                    if (value != null) {
                        metrics[metricName] = value
                    }
                }
            }
        }
        
        return metrics
    }

    private fun calculateErrorRate(metrics: Map<String, Double>): Double {
        val totalRequests = metrics["http_server_requests_seconds_count"] ?: 0.0
        val errorRequests = metrics.filterKeys { it.contains("status=\"5") }.values.sum()
        
        return if (totalRequests > 0) errorRequests / totalRequests else 0.0
    }

    private fun calculateMemoryUsage(metrics: Map<String, Double>): Double {
        val used = metrics["jvm_memory_used_bytes"] ?: 0.0
        val max = metrics["jvm_memory_max_bytes"] ?: 1.0
        
        return if (max > 0) used / max else 0.0
    }

    private fun recordMicrometerMetrics(metrics: ServiceMetrics) {
        val tags = arrayOf("service", metrics.serviceName)
        
        meterRegistry.gauge("service.response_time", tags, metrics.responseTime)
        meterRegistry.gauge("service.error_rate", tags, metrics.errorRate)
        meterRegistry.gauge("service.cpu_usage", tags, metrics.cpuUsage)
        meterRegistry.gauge("service.memory_usage", tags, metrics.memoryUsage)
        meterRegistry.gauge("service.throughput", tags, metrics.throughput)
        meterRegistry.gauge("service.active_connections", tags, metrics.activeConnections)
        
        // JVM Metrics
        meterRegistry.gauge("jvm.heap_used", tags, metrics.jvmMetrics.heapUsed)
        meterRegistry.gauge("jvm.heap_max", tags, metrics.jvmMetrics.heapMax)
        meterRegistry.gauge("jvm.thread_count", tags, metrics.jvmMetrics.threadCount)
        
        // Database Metrics
        meterRegistry.gauge("db.connection_pool_active", tags, metrics.databaseMetrics.connectionPoolActive)
        meterRegistry.gauge("db.query_execution_time", tags, metrics.databaseMetrics.queryExecutionTime)
    }

    private fun checkAlerts(metrics: ServiceMetrics) {
        val alerts = mutableListOf<Alert>()
        
        // Response time alert
        if (metrics.responseTime > alertThresholds["response_time"]!!) {
            alerts.add(Alert(
                id = generateAlertId(),
                serviceName = metrics.serviceName,
                alertType = AlertType.PERFORMANCE,
                severity = AlertSeverity.HIGH,
                message = "High response time: ${metrics.responseTime}ms",
                timestamp = LocalDateTime.now(),
                metricName = "response_time",
                currentValue = metrics.responseTime,
                threshold = alertThresholds["response_time"]!!
            ))
        }
        
        // Error rate alert
        if (metrics.errorRate > alertThresholds["error_rate"]!!) {
            alerts.add(Alert(
                id = generateAlertId(),
                serviceName = metrics.serviceName,
                alertType = AlertType.ERROR,
                severity = AlertSeverity.CRITICAL,
                message = "High error rate: ${(metrics.errorRate * 100).format(2)}%",
                timestamp = LocalDateTime.now(),
                metricName = "error_rate",
                currentValue = metrics.errorRate,
                threshold = alertThresholds["error_rate"]!!
            ))
        }
        
        // CPU usage alert
        if (metrics.cpuUsage > alertThresholds["cpu_usage"]!!) {
            alerts.add(Alert(
                id = generateAlertId(),
                serviceName = metrics.serviceName,
                alertType = AlertType.RESOURCE,
                severity = AlertSeverity.HIGH,
                message = "High CPU usage: ${(metrics.cpuUsage * 100).format(2)}%",
                timestamp = LocalDateTime.now(),
                metricName = "cpu_usage",
                currentValue = metrics.cpuUsage,
                threshold = alertThresholds["cpu_usage"]!!
            ))
        }
        
        // Memory usage alert
        if (metrics.memoryUsage > alertThresholds["memory_usage"]!!) {
            alerts.add(Alert(
                id = generateAlertId(),
                serviceName = metrics.serviceName,
                alertType = AlertType.RESOURCE,
                severity = AlertSeverity.HIGH,
                message = "High memory usage: ${(metrics.memoryUsage * 100).format(2)}%",
                timestamp = LocalDateTime.now(),
                metricName = "memory_usage",
                currentValue = metrics.memoryUsage,
                threshold = alertThresholds["memory_usage"]!!
            ))
        }
        
        // Publish alerts
        alerts.forEach { alert ->
            publishAlert(alert)
        }
    }

    private fun publishMetrics(metrics: ServiceMetrics) {
        kafkaTemplate.send("service-metrics", metrics.serviceName, metrics)
    }

    private fun publishAlert(alert: Alert) {
        kafkaTemplate.send("monitoring-alerts", alert.serviceName, alert)
    }

    private fun handleMetricCollectionError(serviceName: String, error: Exception) {
        val alert = Alert(
            id = generateAlertId(),
            serviceName = serviceName,
            alertType = AlertType.AVAILABILITY,
            severity = AlertSeverity.CRITICAL,
            message = "Service unavailable: ${error.message}",
            timestamp = LocalDateTime.now(),
            metricName = "availability",
            currentValue = 0.0,
            threshold = 1.0
        )
        
        publishAlert(alert)
    }

    private fun getServicePort(serviceName: String): String {
        return when (serviceName) {
            "patient-service" -> "1"
            "hospital-service" -> "2"
            "consultation-service" -> "3"
            "sync-service" -> "4"
            "ai-service" -> "5"
            "clinical-decision-service" -> "6"
            "workflow-automation-service" -> "7"
            else -> "0"
        }
    }

    private fun generateAlertId(): String {
        return "alert_${System.currentTimeMillis()}_${(1000..9999).random()}"
    }

    fun getServiceMetrics(serviceName: String): ServiceMetrics? {
        return serviceMetrics[serviceName]
    }

    fun getAllServiceMetrics(): Map<String, ServiceMetrics> {
        return serviceMetrics.toMap()
    }

    fun getSystemOverview(): SystemOverview {
        val allMetrics = serviceMetrics.values
        
        return SystemOverview(
            totalServices = allMetrics.size,
            healthyServices = allMetrics.count { it.isHealthy },
            avgResponseTime = allMetrics.map { it.responseTime }.average(),
            totalThroughput = allMetrics.sumOf { it.throughput },
            avgCpuUsage = allMetrics.map { it.cpuUsage }.average(),
            avgMemoryUsage = allMetrics.map { it.memoryUsage }.average(),
            totalActiveConnections = allMetrics.sumOf { it.activeConnections }.toInt(),
            timestamp = LocalDateTime.now()
        )
    }
}

private fun Double.format(digits: Int) = "%.${digits}f".format(this)