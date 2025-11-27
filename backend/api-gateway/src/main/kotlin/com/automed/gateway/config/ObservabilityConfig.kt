package com.automed.gateway.config

import io.micrometer.core.instrument.MeterRegistry
import io.micrometer.core.instrument.binder.jvm.JvmGcMetrics
import io.micrometer.core.instrument.binder.jvm.JvmMemoryMetrics
import io.micrometer.core.instrument.binder.jvm.JvmThreadMetrics
import io.micrometer.core.instrument.binder.system.ProcessorMetrics
import io.micrometer.core.instrument.binder.system.UptimeMetrics
import org.slf4j.MDC
import org.springframework.beans.factory.annotation.Value
import org.springframework.boot.actuate.autoconfigure.metrics.MeterRegistryCustomizer
import org.springframework.cloud.sleuth.Tracer
import org.springframework.context.annotation.Bean
import org.springframework.context.annotation.Configuration
import org.springframework.web.filter.OncePerRequestFilter
import org.springframework.web.server.WebFilter
import java.util.*
import javax.servlet.FilterChain
import javax.servlet.http.HttpServletRequest
import javax.servlet.http.HttpServletResponse

@Configuration
class ObservabilityConfig {

    @Value("\${app.observability.service-name:api-gateway}")
    private lateinit var serviceName: String

    @Value("\${app.observability.service-version:1.0.0}")
    private lateinit var serviceVersion: String

    @Bean
    fun metricsCommonTags(): MeterRegistryCustomizer<MeterRegistry> {
        return MeterRegistryCustomizer { registry ->
            registry.config().commonTags(
                "service", serviceName,
                "version", serviceVersion,
                "environment", System.getProperty("spring.profiles.active", "default"),
                "region", System.getProperty("app.region", "us-central1")
            )
        }
    }

    @Bean
    fun jvmMetrics(): JvmGcMetrics {
        return JvmGcMetrics()
    }

    @Bean
    fun jvmMemoryMetrics(): JvmMemoryMetrics {
        return JvmMemoryMetrics()
    }

    @Bean
    fun jvmThreadMetrics(): JvmThreadMetrics {
        return JvmThreadMetrics()
    }

    @Bean
    fun processorMetrics(): ProcessorMetrics {
        return ProcessorMetrics()
    }

    @Bean
    fun uptimeMetrics(): UptimeMetrics {
        return UptimeMetrics()
    }

    @Bean
    fun correlationIdFilter(): OncePerRequestFilter {
        return object : OncePerRequestFilter() {
            override fun doFilterInternal(
                request: HttpServletRequest,
                response: HttpServletResponse,
                filterChain: FilterChain
            ) {
                val correlationId = request.getHeader("X-Correlation-ID")
                    ?: request.getHeader("X-Request-ID")
                    ?: UUID.randomUUID().toString()

                MDC.put("correlationId", correlationId)
                MDC.put("requestId", correlationId)
                MDC.put("userAgent", request.getHeader("User-Agent") ?: "unknown")
                MDC.put("clientIp", getClientIpAddress(request))
                MDC.put("method", request.method)
                MDC.put("uri", request.requestURI)

                response.setHeader("X-Correlation-ID", correlationId)
                response.setHeader("X-Request-ID", correlationId)

                try {
                    filterChain.doFilter(request, response)
                } finally {
                    MDC.clear()
                }
            }

            private fun getClientIpAddress(request: HttpServletRequest): String {
                val xForwardedFor = request.getHeader("X-Forwarded-For")
                if (xForwardedFor != null && xForwardedFor.isNotEmpty()) {
                    return xForwardedFor.split(",")[0].trim()
                }

                val xRealIp = request.getHeader("X-Real-IP")
                if (xRealIp != null && xRealIp.isNotEmpty()) {
                    return xRealIp
                }

                return request.remoteAddr ?: "unknown"
            }
        }
    }

    @Bean
    fun requestTracingFilter(tracer: Tracer): WebFilter {
        return WebFilter { exchange, chain ->
            val span = tracer.nextSpan().name("gateway-request").start()
            val scope = tracer.withSpan(span)

            try {
                scope.use {
                    span.tag("http.method", exchange.request.methodValue ?: "UNKNOWN")
                    span.tag("http.uri", exchange.request.uri.toString())
                    span.tag("http.path", exchange.request.path.value())
                    span.tag("service.name", serviceName)

                    // Add correlation ID to span
                    val correlationId = exchange.request.headers.getFirst("X-Correlation-ID")
                        ?: exchange.request.headers.getFirst("X-Request-ID")
                        ?: UUID.randomUUID().toString()

                    span.tag("correlation.id", correlationId)

                    // Continue with the chain
                    chain.filter(exchange).doOnSuccess {
                        span.tag("http.status_code", exchange.response.statusCode?.value()?.toString() ?: "UNKNOWN")
                        span.end()
                    }.doOnError { error ->
                        span.tag("error", "true")
                        span.tag("error.message", error.message ?: "Unknown error")
                        span.end()
                    }
                }
            } catch (e: Exception) {
                span.tag("error", "true")
                span.tag("error.message", e.message ?: "Unknown error")
                span.end()
                throw e
            }
        }
    }
}

// Custom metrics for API Gateway
@Configuration
class GatewayMetricsConfig {

    @Bean
    fun gatewayMetricsBinder(registry: MeterRegistry): GatewayMetricsBinder {
        return GatewayMetricsBinder(registry)
    }
}

class GatewayMetricsBinder(private val registry: MeterRegistry) {

    init {
        // Custom metrics for gateway operations
        registry.gauge("gateway.active_connections", this) { getActiveConnections() }
        registry.gauge("gateway.request_queue_size", this) { getRequestQueueSize() }
        registry.counter("gateway.requests_total", "method", "GET")
        registry.counter("gateway.requests_total", "method", "POST")
        registry.counter("gateway.requests_total", "method", "PUT")
        registry.counter("gateway.requests_total", "method", "DELETE")
    }

    private fun getActiveConnections(): Double {
        // Implementation would track actual active connections
        return 0.0
    }

    private fun getRequestQueueSize(): Double {
        // Implementation would track request queue size
        return 0.0
    }
}