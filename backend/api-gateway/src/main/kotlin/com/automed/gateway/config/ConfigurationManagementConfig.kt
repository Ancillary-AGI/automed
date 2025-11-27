package com.automed.gateway.config

import org.springframework.beans.factory.annotation.Value
import org.springframework.boot.context.properties.ConfigurationProperties
import org.springframework.context.annotation.Bean
import org.springframework.context.annotation.Configuration
import org.springframework.core.env.Environment
import org.springframework.core.io.ClassPathResource
import org.springframework.core.io.Resource
import java.time.Duration

@Configuration
@ConfigurationProperties(prefix = "app")
class AppConfig {

    lateinit var name: String
    lateinit var version: String
    lateinit var environment: String

    var features: FeatureFlags = FeatureFlags()
    var security: SecurityConfigProps = SecurityConfigProps()
    var resilience: ResilienceConfigProps = ResilienceConfigProps()
    var observability: ObservabilityConfigProps = ObservabilityConfigProps()

    class FeatureFlags {
        var emergencyResponse: Boolean = true
        var aiPredictions: Boolean = false
        var advancedAnalytics: Boolean = true
        var telemedicine: Boolean = true
        var researchModule: Boolean = false
        var blockchainAudit: Boolean = false
        var multiTenant: Boolean = false
    }

    class SecurityConfigProps {
        var cors: CorsConfig = CorsConfig()
        var jwt: JwtConfig = JwtConfig()
        var rateLimit: RateLimitConfig = RateLimitConfig()

        class CorsConfig {
            lateinit var allowedOrigins: List<String>
            var maxAge: Duration = Duration.ofHours(1)
        }

        class JwtConfig {
            lateinit var issuerUri: String
            var clockSkew: Duration = Duration.ofMinutes(1)
            var leeway: Duration = Duration.ofSeconds(30)
        }

        class RateLimitConfig {
            var enabled: Boolean = true
            var replenishRate: Int = 10
            var burstCapacity: Int = 20
            var requestedTokens: Int = 1
        }
    }

    class ResilienceConfigProps {
        var circuitBreaker: CircuitBreakerConfig = CircuitBreakerConfig()
        var retry: RetryConfig = RetryConfig()
        var bulkhead: BulkheadConfig = BulkheadConfig()
        var timeout: TimeoutConfig = TimeoutConfig()

        class CircuitBreakerConfig {
            var failureRateThreshold: Float = 50.0f
            var waitDurationInOpenState: Duration = Duration.ofSeconds(30)
            var permittedNumberOfCallsInHalfOpenState: Int = 3
            var slidingWindowSize: Int = 10
            var minimumNumberOfCalls: Int = 5
        }

        class RetryConfig {
            var maxAttempts: Int = 3
            var backoff: Duration = Duration.ofMillis(100)
            var jitter: Double = 0.1
        }

        class BulkheadConfig {
            var maxConcurrentCalls: Int = 20
            var maxWaitDuration: Duration = Duration.ofMillis(500)
        }

        class TimeoutConfig {
            var defaultTimeout: Duration = Duration.ofSeconds(30)
            var emergencyTimeout: Duration = Duration.ofSeconds(5)
            var aiTimeout: Duration = Duration.ofMinutes(2)
        }
    }

    class ObservabilityConfigProps {
        var metrics: MetricsConfig = MetricsConfig()
        var tracing: TracingConfig = TracingConfig()
        var logging: LoggingConfig = LoggingConfig()

        class MetricsConfig {
            var enabled: Boolean = true
            var step: Duration = Duration.ofSeconds(30)
            var includeJvmMetrics: Boolean = true
            var includeSystemMetrics: Boolean = true
        }

        class TracingConfig {
            var enabled: Boolean = true
            var samplingRate: Double = 0.1
            var includeHeaders: Boolean = false
        }

        class LoggingConfig {
            var level: String = "INFO"
            var includeCorrelationId: Boolean = true
            var includeRequestId: Boolean = true
            var structuredLogging: Boolean = true
        }
    }
}

@Configuration
class FeatureFlagService(private val appConfig: AppConfig) {

    fun isFeatureEnabled(feature: String): Boolean {
        return when (feature.lowercase()) {
            "emergency_response" -> appConfig.features.emergencyResponse
            "ai_predictions" -> appConfig.features.aiPredictions
            "advanced_analytics" -> appConfig.features.advancedAnalytics
            "telemedicine" -> appConfig.features.telemedicine
            "research_module" -> appConfig.features.researchModule
            "blockchain_audit" -> appConfig.features.blockchainAudit
            "multi_tenant" -> appConfig.features.multiTenant
            else -> false
        }
    }

    fun getEnabledFeatures(): List<String> {
        return listOf(
            "emergency_response" to appConfig.features.emergencyResponse,
            "ai_predictions" to appConfig.features.aiPredictions,
            "advanced_analytics" to appConfig.features.advancedAnalytics,
            "telemedicine" to appConfig.features.telemedicine,
            "research_module" to appConfig.features.researchModule,
            "blockchain_audit" to appConfig.features.blockchainAudit,
            "multi_tenant" to appConfig.features.multiTenant
        ).filter { it.second }.map { it.first }
    }

    fun toggleFeature(feature: String, enabled: Boolean) {
        when (feature.lowercase()) {
            "emergency_response" -> appConfig.features.emergencyResponse = enabled
            "ai_predictions" -> appConfig.features.aiPredictions = enabled
            "advanced_analytics" -> appConfig.features.advancedAnalytics = enabled
            "telemedicine" -> appConfig.features.telemedicine = enabled
            "research_module" -> appConfig.features.researchModule = enabled
            "blockchain_audit" -> appConfig.features.blockchainAudit = enabled
            "multi_tenant" -> appConfig.features.multiTenant = enabled
        }
    }
}

@Configuration
class EnvironmentConfig(private val environment: Environment) {

    @Bean
    fun configResource(): Resource {
        val profile = environment.activeProfiles.firstOrNull() ?: "default"
        return ClassPathResource("config/application-$profile.yml")
    }

    fun getCurrentEnvironment(): String {
        return environment.activeProfiles.firstOrNull() ?: "default"
    }

    fun isProduction(): Boolean {
        return environment.activeProfiles.contains("prod") ||
               environment.activeProfiles.contains("production")
    }

    fun isDevelopment(): Boolean {
        return environment.activeProfiles.contains("dev") ||
               environment.activeProfiles.contains("development") ||
               environment.activeProfiles.isEmpty()
    }

    fun isStaging(): Boolean {
        return environment.activeProfiles.contains("staging") ||
               environment.activeProfiles.contains("stage")
    }

    fun getProperty(key: String, defaultValue: String = ""): String {
        return environment.getProperty(key, defaultValue)
    }

    fun getRequiredProperty(key: String): String {
        return environment.getRequiredProperty(key)
    }
}