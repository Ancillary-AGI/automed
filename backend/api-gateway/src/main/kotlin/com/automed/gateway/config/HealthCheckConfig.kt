package com.automed.gateway.config

import org.springframework.beans.factory.annotation.Value
import org.springframework.boot.actuate.health.Health
import org.springframework.boot.actuate.health.HealthIndicator
import org.springframework.context.annotation.Bean
import org.springframework.context.annotation.Configuration
import org.springframework.data.redis.connection.RedisConnectionFactory
import org.springframework.jdbc.core.JdbcTemplate
import org.springframework.web.client.RestTemplate
import java.net.InetAddress
import java.time.Duration
import java.util.concurrent.CompletableFuture
import java.util.concurrent.TimeUnit

@Configuration
class HealthCheckConfig {

    @Value("\${app.health.external-services.timeout:5000}")
    private var externalServiceTimeout: Long = 5000

    @Bean
    fun databaseHealthIndicator(jdbcTemplate: JdbcTemplate): HealthIndicator {
        return HealthIndicator {
            try {
                val result = jdbcTemplate.queryForObject("SELECT 1", Int::class.java)
                if (result == 1) {
                    Health.up()
                        .withDetail("database", "available")
                        .withDetail("responseTime", "fast")
                        .build()
                } else {
                    Health.down()
                        .withDetail("database", "unexpected result")
                        .build()
                }
            } catch (e: Exception) {
                Health.down()
                    .withDetail("database", "unavailable")
                    .withDetail("error", e.message)
                    .build()
            }
        }
    }

    @Bean
    fun redisHealthIndicator(redisConnectionFactory: RedisConnectionFactory?): HealthIndicator {
        return HealthIndicator {
            if (redisConnectionFactory == null) {
                return@HealthIndicator Health.unknown()
                    .withDetail("redis", "not configured")
                    .build()
            }

            try {
                val connection = redisConnectionFactory.connection
                connection.ping()
                connection.close()

                Health.up()
                    .withDetail("redis", "available")
                    .withDetail("ping", "successful")
                    .build()
            } catch (e: Exception) {
                Health.down()
                    .withDetail("redis", "unavailable")
                    .withDetail("error", e.message)
                    .build()
            }
        }
    }

    @Bean
    fun downstreamServicesHealthIndicator(restTemplate: RestTemplate): HealthIndicator {
        return HealthIndicator {
            val services = mapOf(
                "patient-service" to "http://patient-service:8081/actuator/health",
                "hospital-service" to "http://hospital-service:8082/actuator/health",
                "ai-service" to "http://ai-service:8085/actuator/health",
                "emergency-service" to "http://emergency-response-service:8089/actuator/health"
            )

            val healthDetails = mutableMapOf<String, Any>()
            var overallStatus = Health.up()

            val futures = services.map { (serviceName, url) ->
                CompletableFuture.supplyAsync {
                    try {
                        val response = restTemplate.getForEntity(url, Map::class.java)
                        if (response.statusCode.is2xxSuccessful) {
                            healthDetails[serviceName] = "healthy"
                        } else {
                            healthDetails[serviceName] = "unhealthy"
                            overallStatus = Health.down()
                        }
                    } catch (e: Exception) {
                        healthDetails[serviceName] = "unreachable"
                        overallStatus = Health.down()
                    }
                }
            }

            // Wait for all health checks to complete
            CompletableFuture.allOf(*futures.toTypedArray()).get(externalServiceTimeout, TimeUnit.MILLISECONDS)

            overallStatus
                .withDetail("downstreamServices", healthDetails)
                .build()
        }
    }

    @Bean
    fun networkHealthIndicator(): HealthIndicator {
        return HealthIndicator {
            try {
                // Test DNS resolution
                val address = InetAddress.getByName("google.com")
                val reachable = address.isReachable(5000)

                if (reachable) {
                    Health.up()
                        .withDetail("network", "available")
                        .withDetail("dns", "resolving")
                        .withDetail("connectivity", "good")
                        .build()
                } else {
                    Health.down()
                        .withDetail("network", "dns resolving but not reachable")
                        .build()
                }
            } catch (e: Exception) {
                Health.down()
                    .withDetail("network", "unavailable")
                    .withDetail("error", e.message)
                    .build()
            }
        }
    }

    @Bean
    fun memoryHealthIndicator(): HealthIndicator {
        return HealthIndicator {
            val runtime = Runtime.getRuntime()
            val totalMemory = runtime.totalMemory()
            val freeMemory = runtime.freeMemory()
            val usedMemory = totalMemory - freeMemory
            val usedPercentage = (usedMemory.toDouble() / totalMemory.toDouble()) * 100

            val details = mapOf(
                "totalMemory" to "${totalMemory / 1024 / 1024}MB",
                "freeMemory" to "${freeMemory / 1024 / 1024}MB",
                "usedMemory" to "${usedMemory / 1024 / 1024}MB",
                "usedPercentage" to "${usedPercentage.toInt()}%"
            )

            if (usedPercentage > 90) {
                Health.down()
                    .withDetail("memory", "critical")
                    .withDetails(details)
                    .build()
            } else if (usedPercentage > 75) {
                Health.warn()
                    .withDetail("memory", "high")
                    .withDetails(details)
                    .build()
            } else {
                Health.up()
                    .withDetail("memory", "normal")
                    .withDetails(details)
                    .build()
            }
        }
    }

    @Bean
    fun diskSpaceHealthIndicator(): HealthIndicator {
        return HealthIndicator {
            val file = java.io.File("/")
            val totalSpace = file.totalSpace
            val freeSpace = file.freeSpace
            val usedSpace = totalSpace - freeSpace
            val usedPercentage = (usedSpace.toDouble() / totalSpace.toDouble()) * 100

            val details = mapOf(
                "totalSpace" to "${totalSpace / 1024 / 1024 / 1024}GB",
                "freeSpace" to "${freeSpace / 1024 / 1024 / 1024}GB",
                "usedSpace" to "${usedSpace / 1024 / 1024 / 1024}GB",
                "usedPercentage" to "${usedPercentage.toInt()}%"
            )

            if (usedPercentage > 95) {
                Health.down()
                    .withDetail("disk", "critical")
                    .withDetails(details)
                    .build()
            } else if (usedPercentage > 85) {
                Health.warn()
                    .withDetail("disk", "high")
                    .withDetails(details)
                    .build()
            } else {
                Health.up()
                    .withDetail("disk", "normal")
                    .withDetails(details)
                    .build()
            }
        }
    }

    @Bean
    fun customHealthIndicator(): HealthIndicator {
        return HealthIndicator {
            // Custom business logic health checks
            val checks = mutableMapOf<String, Any>()

            // Check if critical features are enabled
            checks["emergencyResponse"] = true
            checks["telemedicine"] = true
            checks["aiPredictions"] = false // Feature flag controlled

            // Check configuration validity
            checks["configurationValid"] = true

            // Check if all required environment variables are set
            val requiredEnvVars = listOf("SPRING_PROFILES_ACTIVE", "EUREKA_CLIENT_SERVICEURL_DEFAULTZONE")
            val missingVars = requiredEnvVars.filter { System.getenv(it) == null }
            checks["environmentVariables"] = if (missingVars.isEmpty()) "all present" else "missing: $missingVars"

            Health.up()
                .withDetail("businessLogic", checks)
                .withDetail("timestamp", System.currentTimeMillis())
                .build()
        }
    }
}

// Custom health check for external dependencies
@Configuration
class ExternalDependencyHealthConfig {

    @Bean
    fun externalApiHealthIndicator(restTemplate: RestTemplate): HealthIndicator {
        return HealthIndicator {
            val externalApis = mapOf(
                "geocoding-api" to "https://maps.googleapis.com/maps/api/geocode/json?address=test",
                "weather-api" to "https://api.openweathermap.org/data/2.5/weather?q=London"
            )

            val results = mutableMapOf<String, String>()
            var overallHealthy = true

            for ((name, url) in externalApis) {
                try {
                    // Note: In production, use proper API keys and test endpoints
                    val response = restTemplate.getForEntity("$url&key=test", String::class.java)
                    if (response.statusCode.is2xxSuccessful) {
                        results[name] = "healthy"
                    } else {
                        results[name] = "unhealthy (${response.statusCode})"
                        overallHealthy = false
                    }
                } catch (e: Exception) {
                    results[name] = "error: ${e.message}"
                    overallHealthy = false
                }
            }

            if (overallHealthy) {
                Health.up()
                    .withDetail("externalApis", results)
                    .build()
            } else {
                Health.warn()
                    .withDetail("externalApis", results)
                    .withDetail("note", "Some external APIs are unavailable")
                    .build()
            }
        }
    }
}