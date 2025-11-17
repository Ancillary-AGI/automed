package com.automed.patient.config

import org.springframework.context.annotation.Bean
import org.springframework.context.annotation.Configuration
import org.springframework.security.config.annotation.method.configuration.EnableMethodSecurity
import org.springframework.security.config.annotation.web.builders.HttpSecurity
import org.springframework.security.config.annotation.web.configuration.EnableWebSecurity
import org.springframework.security.config.http.SessionCreationPolicy
import org.springframework.security.web.SecurityFilterChain
import org.springframework.security.web.header.writers.ReferrerPolicyHeaderWriter
import org.springframework.web.cors.CorsConfiguration
import org.springframework.web.cors.CorsConfigurationSource
import org.springframework.web.cors.UrlBasedCorsConfigurationSource
import org.springframework.security.web.authentication.www.BasicAuthenticationFilter
import org.springframework.security.web.firewall.HttpFirewall
import org.springframework.security.web.firewall.StrictHttpFirewall
import org.springframework.beans.factory.annotation.Value

@Configuration
@EnableWebSecurity
@EnableMethodSecurity(prePostEnabled = true, securedEnabled = true, jsr250Enabled = true)
class SecurityConfig {

    @Value("\${app.security.cors.allowed-origins:*}")
    private lateinit var allowedOrigins: String

    @Bean
    fun filterChain(http: HttpSecurity): SecurityFilterChain {
        return http
            // HIPAA/GDPR Security Headers
            .headers { headers ->
                headers
                    .contentTypeOptions { }
                    .httpStrictTransportSecurity { hsts ->
                        hsts.maxAgeInSeconds(31536000)
                        hsts.includeSubdomains(true)
                    }
                    .frameOptions { it.deny() }
                    .xssProtection { }
                    .referrerPolicy(ReferrerPolicyHeaderWriter.ReferrerPolicy.STRICT_ORIGIN_WHEN_CROSS_ORIGIN)
                    .contentSecurityPolicy("default-src 'self'; script-src 'self' 'unsafe-inline'; style-src 'self' 'unsafe-inline'; img-src 'self' data: https:; font-src 'self' data:; connect-src 'self' https://api.automed.com")
            }
            // CORS Configuration
            .cors { it.configurationSource(corsConfigurationSource()) }
            // CSRF Protection (enabled for web forms, disabled for API)
            .csrf { csrf ->
                csrf.ignoringRequestMatchers("/api/**")
            }
            // Session Management
            .sessionManagement { session ->
                session.sessionCreationPolicy(SessionCreationPolicy.STATELESS)
                session.maximumSessions(1)
                session.maxSessionsPreventsLogin(true)
            }
            // Authorization Rules
            .authorizeHttpRequests { authz ->
                authz
                    // Health and monitoring endpoints
                    .requestMatchers("/actuator/health", "/actuator/info").permitAll()
                    .requestMatchers("/actuator/**").hasRole("ADMIN")

                    // Authentication endpoints
                    .requestMatchers("/api/v1/auth/login", "/api/v1/auth/register", "/api/v1/auth/refresh").permitAll()
                    .requestMatchers("/api/v1/auth/**").authenticated()

                    // Public endpoints
                    .requestMatchers("/api/v1/public/**").permitAll()

                    // Patient data access (role-based)
                    .requestMatchers("/api/v1/patients/{patientId}/**").access("@securityService.canAccessPatientData(authentication, #patientId)")
                    .requestMatchers("/api/v1/patients").hasAnyRole("DOCTOR", "NURSE", "ADMIN")
                    .requestMatchers("/api/v1/patients/**").hasAnyRole("PATIENT", "DOCTOR", "NURSE", "ADMIN")

                    // Medical records (strict access control)
                    .requestMatchers("/api/v1/medical-records/**").hasAnyRole("DOCTOR", "NURSE", "ADMIN")

                    // Emergency access (bypass normal restrictions)
                    .requestMatchers("/api/v1/emergency/**").permitAll()

                    // Audit and compliance
                    .requestMatchers("/api/v1/audit/**").hasRole("ADMIN")
                    .requestMatchers("/api/v1/compliance/**").hasRole("ADMIN")

                    // All other requests require authentication
                    .anyRequest().authenticated()
            }
            // OAuth2 Resource Server for JWT
            .oauth2ResourceServer { oauth2 ->
                oauth2.jwt { jwt ->
                    jwt.jwtAuthenticationConverter(jwtAuthenticationConverter())
                }
            }
            // Custom filters
            .addFilterBefore(AuditLoggingFilter(), BasicAuthenticationFilter::class.java)
            .addFilterBefore(RateLimitingFilter(), AuditLoggingFilter::class.java)
            .addFilterBefore(DataEncryptionFilter(), RateLimitingFilter::class.java)
            .build()
    }

    @Bean
    fun corsConfigurationSource(): CorsConfigurationSource {
        val configuration = CorsConfiguration().apply {
            // Restrictive CORS for HIPAA compliance
            allowedOriginPatterns = allowedOrigins.split(",").map { it.trim() }
            allowedMethods = listOf("GET", "POST", "PUT", "DELETE", "OPTIONS", "PATCH")
            allowedHeaders = listOf(
                "Authorization",
                "Content-Type",
                "X-Requested-With",
                "Accept",
                "Origin",
                "Access-Control-Request-Method",
                "Access-Control-Request-Headers"
            )
            exposedHeaders = listOf(
                "X-Total-Count",
                "X-Rate-Limit-Remaining",
                "X-Rate-Limit-Reset"
            )
            allowCredentials = true
            maxAge = 3600L
        }

        return UrlBasedCorsConfigurationSource().apply {
            registerCorsConfiguration("/api/**", configuration)
        }
    }

    @Bean
    fun httpFirewall(): HttpFirewall {
        val firewall = StrictHttpFirewall()
        // Allow common characters in URLs
        firewall.setAllowUrlEncodedPercent(true)
        firewall.setAllowUrlEncodedSlash(true)
        firewall.setAllowSemicolon(true)
        return firewall
    }

    @Bean
    fun jwtAuthenticationConverter() = CustomJwtAuthenticationConverter()

    @Bean
    fun securityService() = SecurityService()
}
