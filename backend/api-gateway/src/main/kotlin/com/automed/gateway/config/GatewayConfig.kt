package com.automed.gateway.config

import org.springframework.cloud.gateway.route.RouteLocator
import org.springframework.cloud.gateway.route.builder.RouteLocatorBuilder
import org.springframework.context.annotation.Bean
import org.springframework.context.annotation.Configuration
import org.springframework.http.HttpMethod

@Configuration
class GatewayConfig {

    @Bean
    fun customRouteLocator(builder: RouteLocatorBuilder): RouteLocator {
        return builder.routes()
            // Patient Service Routes
            .route("patient-service") { r ->
                r.path("/api/v1/patients/**")
                    .filters { f ->
                        f.stripPrefix(2)
                            .circuitBreaker { config ->
                                config.name = "patient-service-cb"
                                    .fallbackUri = "forward:/fallback/patients"
                            }
                            .retry { config ->
                                config.retries = 3
                                    .methods = setOf(HttpMethod.GET, HttpMethod.POST)
                            }
                    }
                    .uri("lb://patient-service")
            }
            // Hospital Service Routes
            .route("hospital-service") { r ->
                r.path("/api/v1/hospitals/**")
                    .filters { f ->
                        f.stripPrefix(2)
                            .circuitBreaker { config ->
                                config.name = "hospital-service-cb"
                                    .fallbackUri = "forward:/fallback/hospitals"
                            }
                    }
                    .uri("lb://hospital-service")
            }
            // AI Service Routes
            .route("ai-service") { r ->
                r.path("/api/v1/ai/**")
                    .filters { f ->
                        f.stripPrefix(2)
                            .circuitBreaker { config ->
                                config.name = "ai-service-cb"
                                    .fallbackUri = "forward:/fallback/ai"
                            }
                    }
                    .uri("lb://ai-service")
            }
            // WebSocket Routes for Real-time Communication
            .route("websocket-route") { r ->
                r.path("/ws/**")
                    .uri("lb://communication-service")
            }
            .build()
    }
}