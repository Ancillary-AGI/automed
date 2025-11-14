package com.automed.drugdiscovery.config

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

@Configuration
@EnableWebSecurity
@EnableMethodSecurity(prePostEnabled = true)
class SecurityConfig {

    @Bean
    fun filterChain(http: HttpSecurity): SecurityFilterChain {
        return http
            .cors { it.configurationSource(corsConfigurationSource()) }
            .csrf { it.disable() }
            .sessionManagement { it.sessionCreationPolicy(SessionCreationPolicy.STATELESS) }
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
            }
            .authorizeHttpRequests { authz ->
                authz
                    .requestMatchers("/actuator/**", "/health/**").permitAll()
                    .requestMatchers("/api/v1/auth/**").permitAll()
                    .requestMatchers("/api/v1/public/**").permitAll()
                    // Drug discovery endpoints with role-based access
                    .requestMatchers("/api/v1/drug-discovery/molecular-data/**").hasAnyRole("RESEARCHER", "ADMIN")
                    .requestMatchers("/api/v1/drug-discovery/clinical-trials/**").hasAnyRole("RESEARCHER", "CLINICIAN", "ADMIN")
                    .requestMatchers("/api/v1/drug-discovery/toxicity/**").hasAnyRole("RESEARCHER", "ADMIN")
                    .requestMatchers("/api/v1/drug-discovery/virtual-screening/**").hasAnyRole("RESEARCHER", "ADMIN")
                    .requestMatchers("/api/v1/drug-discovery/quantum/**").hasAnyRole("RESEARCHER", "ADMIN")
                    .anyRequest().authenticated()
            }
            .oauth2ResourceServer { oauth2 ->
                oauth2.jwt { }
            }
            .build()
    }

    @Bean
    fun corsConfigurationSource(): CorsConfigurationSource {
        val configuration = CorsConfiguration().apply {
            allowedOriginPatterns = listOf("*")
            allowedMethods = listOf("GET", "POST", "PUT", "DELETE", "OPTIONS")
            allowedHeaders = listOf("*")
            allowCredentials = true
            maxAge = 3600L
        }

        return UrlBasedCorsConfigurationSource().apply {
            registerCorsConfiguration("/**", configuration)
        }
    }
}