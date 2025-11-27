package com.automed.gateway.config

import org.springframework.cloud.gateway.filter.ratelimit.KeyResolver
import org.springframework.cloud.gateway.filter.ratelimit.RedisRateLimiter
import org.springframework.cloud.gateway.route.RouteLocator
import org.springframework.cloud.gateway.route.builder.RouteLocatorBuilder
import org.springframework.context.annotation.Bean
import org.springframework.context.annotation.Configuration
import org.springframework.http.HttpMethod
import org.springframework.http.HttpStatus
import reactor.core.publisher.Mono
import java.time.Duration

@Configuration
class GatewayConfig {

    @Bean
    fun customRouteLocator(builder: RouteLocatorBuilder): RouteLocator {
        return builder.routes()
            // Patient Service Routes with Advanced Features
            .route("patient-service-v1") { r ->
                r.path("/api/v1/patients/**")
                    .and().method(HttpMethod.GET, HttpMethod.POST, HttpMethod.PUT, HttpMethod.DELETE)
                    .filters { f ->
                        f.stripPrefix(2)
                            .addRequestHeader("X-API-Version", "v1")
                            .addRequestHeader("X-Gateway-Timestamp", System.currentTimeMillis().toString())
                            .requestRateLimiter { config ->
                                config.rateLimiter = redisRateLimiter()
                                config.keyResolver = userKeyResolver()
                            }
                            .circuitBreaker { config ->
                                config.name = "patient-service-cb"
                                config.fallbackUri = "forward:/fallback/patients"
                                config.timeout = Duration.ofSeconds(5)
                                config.failureRateThreshold = 50.0f
                                config.waitDurationInOpenState = Duration.ofSeconds(30)
                                config.permittedNumberOfCallsInHalfOpenState = 3
                                config.slidingWindowSize = 10
                                config.minimumNumberOfCalls = 5
                            }
                            .retry { config ->
                                config.retries = 3
                                config.methods = setOf(HttpMethod.GET, HttpMethod.POST)
                                config.backoff = Duration.ofMillis(100)
                                config.jitter = 0.1
                            }
                            .dedupeResponseHeader("X-Request-ID", "X-Response-Time", "X-Rate-Limit-Remaining")
                            .setResponseHeader("X-Gateway-Version", "2.0.0")
                            .modifyResponseBody(String::class.java, String::class.java) { request, response ->
                                // Add response transformation logic here
                                Mono.just(response + " [Processed by Gateway]")
                            }
                    }
                    .uri("lb://patient-service")
            }

            // Hospital Service Routes with Enhanced Resilience
            .route("hospital-service-v1") { r ->
                r.path("/api/v1/hospitals/**")
                    .filters { f ->
                        f.stripPrefix(2)
                            .addRequestHeader("X-API-Version", "v1")
                            .addRequestHeader("X-Service-Name", "hospital-service")
                            .requestRateLimiter { config ->
                                config.rateLimiter = redisRateLimiter()
                                config.keyResolver = userKeyResolver()
                            }
                            .circuitBreaker { config ->
                                config.name = "hospital-service-cb"
                                config.fallbackUri = "forward:/fallback/hospitals"
                                config.timeout = Duration.ofSeconds(10)
                                config.failureRateThreshold = 60.0f
                                config.waitDurationInOpenState = Duration.ofSeconds(60)
                                config.permittedNumberOfCallsInHalfOpenState = 5
                            }
                            .bulkhead { config ->
                                config.maxConcurrentCalls = 20
                                config.maxWaitDuration = Duration.ofMillis(500)
                            }
                            .setResponseHeader("X-Gateway-Processed", "true")
                    }
                    .uri("lb://hospital-service")
            }

            // AI Service Routes with Advanced Caching
            .route("ai-service-v1") { r ->
                r.path("/api/v1/ai/**")
                    .filters { f ->
                        f.stripPrefix(2)
                            .addRequestHeader("X-API-Version", "v1")
                            .addRequestHeader("X-Compute-Intensive", "true")
                            .requestRateLimiter { config ->
                                config.rateLimiter = redisRateLimiter()
                                config.keyResolver = userKeyResolver()
                            }
                            .circuitBreaker { config ->
                                config.name = "ai-service-cb"
                                config.fallbackUri = "forward:/fallback/ai"
                                config.timeout = Duration.ofSeconds(30) // Longer timeout for AI processing
                            }
                            .cacheRequest { config ->
                                config.timeToLive = Duration.ofMinutes(5)
                            }
                            .setResponseHeader("X-AI-Processed", "true")
                    }
                    .uri("lb://ai-service")
            }

            // Emergency Service Routes with High Priority
            .route("emergency-service-v1") { r ->
                r.path("/api/v1/emergency/**")
                    .filters { f ->
                        f.stripPrefix(2)
                            .addRequestHeader("X-Priority", "HIGH")
                            .addRequestHeader("X-Emergency", "true")
                            .requestRateLimiter { config ->
                                config.rateLimiter = redisRateLimiter()
                                config.keyResolver = userKeyResolver()
                                config.statusCode = HttpStatus.TOO_MANY_REQUESTS
                            }
                            .circuitBreaker { config ->
                                config.name = "emergency-service-cb"
                                config.fallbackUri = "forward:/fallback/emergency"
                                config.timeout = Duration.ofSeconds(2) // Fast timeout for emergencies
                            }
                            .setResponseHeader("X-Emergency-Response", "true")
                    }
                    .uri("lb://emergency-response-service")
            }

            // Research Service Routes
            .route("research-service-v1") { r ->
                r.path("/api/v1/research/**")
                    .filters { f ->
                        f.stripPrefix(2)
                            .addRequestHeader("X-API-Version", "v1")
                            .addRequestHeader("X-Research-Service", "true")
                            .requestRateLimiter { config ->
                                config.rateLimiter = redisRateLimiter()
                                config.keyResolver = userKeyResolver()
                            }
                            .circuitBreaker { config ->
                                config.name = "research-service-cb"
                                config.fallbackUri = "forward:/fallback/research"
                            }
                    }
                    .uri("lb://research-service")
            }

            // WebSocket Routes for Real-time Communication with Enhanced Features
            .route("websocket-route") { r ->
                r.path("/ws/**")
                    .filters { f ->
                        f.addRequestHeader("X-WebSocket", "true")
                        f.addRequestHeader("X-Connection-Type", "websocket")
                    }
                    .uri("lb://consultation-service")
            }

            // API Documentation Routes
            .route("api-docs") { r ->
                r.path("/api-docs/**", "/swagger-ui/**", "/v3/api-docs/**")
                    .filters { f ->
                        f.stripPrefix(0)
                    }
                    .uri("lb://api-gateway")
            }

            // Health Check Routes
            .route("health-checks") { r ->
                r.path("/health/**", "/actuator/**")
                    .filters { f ->
                        f.addRequestHeader("X-Health-Check", "true")
                    }
                    .uri("lb://api-gateway")
            }

            .build()
    }

    @Bean
    fun redisRateLimiter(): RedisRateLimiter {
        return RedisRateLimiter(10, 20, 1) // replenishRate, burstCapacity, requestedTokens
    }

    @Bean
    fun userKeyResolver(): KeyResolver {
        return KeyResolver { exchange ->
            val authHeader = exchange.request.headers.getFirst("Authorization")
            if (authHeader != null && authHeader.startsWith("Bearer ")) {
                // Extract user ID from JWT token (simplified)
                return@KeyResolver Mono.just(authHeader.substring(7))
            }
            // Fallback to IP address
            return@KeyResolver Mono.just(exchange.request.remoteAddress?.address?.hostAddress ?: "anonymous")
        }
    }

    @Bean
    fun ipKeyResolver(): KeyResolver {
        return KeyResolver { exchange ->
            Mono.just(exchange.request.remoteAddress?.address?.hostAddress ?: "unknown")
        }
    }
}