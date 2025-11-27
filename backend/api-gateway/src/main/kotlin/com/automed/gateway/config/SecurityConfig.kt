package com.automed.gateway.config

import org.springframework.beans.factory.annotation.Value
import org.springframework.context.annotation.Bean
import org.springframework.context.annotation.Configuration
import org.springframework.security.config.annotation.method.configuration.EnableMethodSecurity
import org.springframework.security.config.annotation.web.builders.HttpSecurity
import org.springframework.security.config.annotation.web.configuration.EnableWebSecurity
import org.springframework.security.config.http.SessionCreationPolicy
import org.springframework.security.oauth2.core.DelegatingOAuth2TokenValidator
import org.springframework.security.oauth2.core.OAuth2TokenValidator
import org.springframework.security.oauth2.jwt.*
import org.springframework.security.web.SecurityFilterChain
import org.springframework.security.web.header.writers.ReferrerPolicyHeaderWriter
import org.springframework.web.cors.CorsConfiguration
import org.springframework.web.cors.CorsConfigurationSource
import org.springframework.web.cors.UrlBasedCorsConfigurationSource
import java.time.Duration

@Configuration
@EnableWebSecurity
@EnableMethodSecurity(prePostEnabled = true)
class SecurityConfig {

    @Value("\${app.security.cors.allowed-origins}")
    private lateinit var allowedOrigins: List<String>

    @Value("\${app.security.jwt.issuer-uri}")
    private lateinit var issuerUri: String

    @Value("\${app.security.api-keys.enabled:false}")
    private var apiKeysEnabled: Boolean = false

    @Bean
    fun filterChain(http: HttpSecurity): SecurityFilterChain {
        return http
            // CORS Configuration
            .cors { it.configurationSource(corsConfigurationSource()) }

            // CSRF Protection (disabled for API)
            .csrf { it.disable() }

            // Session Management
            .sessionManagement { it.sessionCreationPolicy(SessionCreationPolicy.STATELESS) }

            // Security Headers
            .headers { headers ->
                headers
                    .contentTypeOptions { }
                    .httpStrictTransportSecurity { hsts ->
                        hsts.maxAgeInSeconds(Duration.ofDays(365).seconds)
                        hsts.includeSubdomains(true)
                    }
                    .frameOptions { it.deny() }
                    .xssProtection { }
                    .referrerPolicy(ReferrerPolicyHeaderWriter.ReferrerPolicy.STRICT_ORIGIN_WHEN_CROSS_ORIGIN)
                    .contentSecurityPolicy("default-src 'self'; script-src 'self' 'unsafe-inline'; style-src 'self' 'unsafe-inline'")
            }

            // Authorization Rules
            .authorizeHttpRequests { authz ->
                authz
                    // Health and Monitoring
                    .requestMatchers("/actuator/**", "/health/**", "/metrics/**").permitAll()

                    // Authentication endpoints
                    .requestMatchers("/api/v1/auth/**", "/oauth2/**").permitAll()

                    // Public API endpoints
                    .requestMatchers("/api/v1/public/**").permitAll()

                    // API Documentation
                    .requestMatchers("/api-docs/**", "/swagger-ui/**", "/v3/api-docs/**").permitAll()

                    // Emergency endpoints (higher priority)
                    .requestMatchers("/api/v1/emergency/**").hasAnyRole("ADMIN", "DOCTOR", "PARAMEDIC")

                    // Admin endpoints
                    .requestMatchers("/api/v1/admin/**").hasRole("ADMIN")

                    // Research endpoints
                    .requestMatchers("/api/v1/research/**").hasAnyRole("ADMIN", "RESEARCHER")

                    // Patient data (HIPAA compliant)
                    .requestMatchers("/api/v1/patients/*/sensitive/**").hasAnyRole("ADMIN", "DOCTOR")

                    // All other requests require authentication
                    .anyRequest().authenticated()
            }

            // OAuth2 Resource Server with JWT
            .oauth2ResourceServer { oauth2 ->
                oauth2.jwt { jwt ->
                    jwt.decoder(jwtDecoder())
                }
                oauth2.bearerTokenResolver { request ->
                    // Support multiple token sources
                    request.getHeader("Authorization")?.takeIf { it.startsWith("Bearer ") }?.substring(7)
                        ?: request.getParameter("access_token")
                        ?: request.cookies.find { it.name == "access_token" }?.value
                }
            }

            // API Key Authentication (if enabled)
            .apply {
                if (apiKeysEnabled) {
                    // Add API key authentication filter
                    // This would be implemented as a custom filter
                }
            }

            .build()
    }

    @Bean
    fun jwtDecoder(): JwtDecoder {
        val jwtDecoder = JwtDecoders.fromIssuerLocation(issuerUri) as NimbusJwtDecoder

        // Custom token validators
        val validators = listOf<OAuth2TokenValidator<Jwt>>(
            JwtTimestampValidator(Duration.ofSeconds(60)), // Allow 60 seconds clock skew
            JwtIssuerValidator(issuerUri),
            CustomJwtClaimsValidator() // Custom claims validation
        )

        jwtDecoder.setJwtValidator(DelegatingOAuth2TokenValidator(validators))
        return jwtDecoder
    }

    @Bean
    fun corsConfigurationSource(): CorsConfigurationSource {
        val configuration = CorsConfiguration().apply {
            // Use configured allowed origins instead of wildcard
            allowedOriginPatterns = allowedOrigins.ifEmpty { listOf("https://*.automed.com", "http://localhost:*") }
            allowedMethods = listOf("GET", "POST", "PUT", "DELETE", "OPTIONS", "PATCH")
            allowedHeaders = listOf(
                "Authorization",
                "Content-Type",
                "X-Requested-With",
                "Accept",
                "Origin",
                "Access-Control-Request-Method",
                "Access-Control-Request-Headers",
                "X-API-Key",
                "X-Request-ID",
                "X-Correlation-ID"
            )
            exposedHeaders = listOf(
                "X-Request-ID",
                "X-Correlation-ID",
                "X-Rate-Limit-Remaining",
                "X-Rate-Limit-Reset"
            )
            allowCredentials = true
            maxAge = 3600L
        }

        return UrlBasedCorsConfigurationSource().apply {
            registerCorsConfiguration("/**", configuration)
        }
    }
}

// Custom JWT Claims Validator for Healthcare Domain
class CustomJwtClaimsValidator : OAuth2TokenValidator<Jwt> {

    override fun validate(token: Jwt): OAuth2TokenValidatorResult {
        val errors = mutableListOf<OAuth2Error>()

        // Validate required claims for healthcare
        val requiredClaims = listOf("sub", "iss", "exp", "iat", "scope")
        for (claim in requiredClaims) {
            if (!token.claims.containsKey(claim)) {
                errors.add(OAuth2Error("invalid_token", "Missing required claim: $claim", null))
            }
        }

        // Validate healthcare-specific claims
        val roles = token.claims["roles"] as? List<String>
        if (roles.isNullOrEmpty()) {
            errors.add(OAuth2Error("invalid_token", "Missing or empty roles claim", null))
        }

        // Validate organization claim
        val organization = token.claims["organization"] as? String
        if (organization.isNullOrBlank()) {
            errors.add(OAuth2Error("invalid_token", "Missing organization claim", null))
        }

        // Validate license information for healthcare providers
        if (roles?.contains("DOCTOR") == true || roles?.contains("NURSE") == true) {
            val licenseNumber = token.claims["license_number"] as? String
            if (licenseNumber.isNullOrBlank()) {
                errors.add(OAuth2Error("invalid_token", "Missing license number for healthcare provider", null))
            }
        }

        return if (errors.isEmpty()) {
            OAuth2TokenValidatorResult.success()
        } else {
            OAuth2TokenValidatorResult.failure(*errors.toTypedArray())
        }
    }
}