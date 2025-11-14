package com.automed.imaging.config

import org.springframework.context.annotation.Bean
import org.springframework.context.annotation.Configuration
import org.springframework.security.config.annotation.method.configuration.EnableMethodSecurity
import org.springframework.security.config.annotation.web.builders.HttpSecurity
import org.springframework.security.config.annotation.web.configuration.EnableWebSecurity
import org.springframework.security.config.http.SessionCreationPolicy
import org.springframework.security.core.authority.SimpleGrantedAuthority
import org.springframework.security.oauth2.jwt.JwtDecoder
import org.springframework.security.oauth2.jwt.NimbusJwtDecoder
import org.springframework.security.oauth2.server.resource.authentication.JwtAuthenticationConverter
import org.springframework.security.web.SecurityFilterChain
import org.springframework.security.web.access.AccessDeniedHandler
import org.springframework.security.web.authentication.UsernamePasswordAuthenticationFilter
import org.springframework.web.cors.CorsConfiguration
import org.springframework.web.cors.CorsConfigurationSource
import org.springframework.web.cors.UrlBasedCorsConfigurationSource
import javax.servlet.http.HttpServletResponse

@Configuration
@EnableWebSecurity
@EnableMethodSecurity(prePostEnabled = true)
class SecurityConfig {

    @Bean
    fun securityFilterChain(http: HttpSecurity): SecurityFilterChain {
        http
            .csrf { it.disable() }
            .cors { it.configurationSource(corsConfigurationSource()) }
            .sessionManagement { it.sessionCreationPolicy(SessionCreationPolicy.STATELESS) }
            .authorizeHttpRequests { authz ->
                authz
                    .requestMatchers("/actuator/**").permitAll()
                    .requestMatchers("/api/v1/imaging/health").permitAll()
                    .requestMatchers("/api/v1/imaging/dicom/store").hasAnyRole("RADIOLOGIST", "ADMIN", "SYSTEM")
                    .requestMatchers("/api/v1/imaging/dicom/retrieve/**").hasAnyRole("RADIOLOGIST", "PHYSICIAN", "ADMIN", "SYSTEM")
                    .requestMatchers("/api/v1/imaging/process/**").hasAnyRole("RADIOLOGIST", "ADMIN", "SYSTEM")
                    .requestMatchers("/api/v1/imaging/ai/**").hasAnyRole("RADIOLOGIST", "ADMIN", "SYSTEM")
                    .requestMatchers("/api/v1/imaging/pacs/**").hasAnyRole("RADIOLOGIST", "ADMIN", "SYSTEM")
                    .requestMatchers("/api/v1/imaging/batch/**").hasAnyRole("RADIOLOGIST", "ADMIN", "SYSTEM")
                    .anyRequest().authenticated()
            }
            .oauth2ResourceServer { oauth2 ->
                oauth2
                    .jwt { jwt ->
                        jwt.decoder(jwtDecoder())
                        jwt.jwtAuthenticationConverter(jwtAuthenticationConverter())
                    }
                    .accessDeniedHandler(hipaaAccessDeniedHandler())
            }
            .addFilterBefore(auditLoggingFilter(), UsernamePasswordAuthenticationFilter::class.java)

        return http.build()
    }

    @Bean
    fun jwtDecoder(): JwtDecoder {
        return NimbusJwtDecoder.withJwkSetUri("http://localhost:8080/realms/automed/protocol/openid-connect/certs")
            .build()
    }

    @Bean
    fun jwtAuthenticationConverter(): JwtAuthenticationConverter {
        val converter = JwtAuthenticationConverter()
        converter.setJwtGrantedAuthoritiesConverter { jwt ->
            val realmAccess = jwt.getClaim<Map<String, Any>>("realm_access")
            val roles = realmAccess?.get("roles") as? List<String> ?: emptyList()
            roles.map { SimpleGrantedAuthority("ROLE_$it") }
        }
        return converter
    }

    @Bean
    fun corsConfigurationSource(): CorsConfigurationSource {
        val configuration = CorsConfiguration()
        configuration.allowedOriginPatterns = listOf("*")
        configuration.allowedMethods = listOf("GET", "POST", "PUT", "DELETE", "OPTIONS")
        configuration.allowedHeaders = listOf("*")
        configuration.allowCredentials = true
        configuration.maxAge = 3600L

        val source = UrlBasedCorsConfigurationSource()
        source.registerCorsConfiguration("/api/**", configuration)
        return source
    }

    @Bean
    fun hipaaAccessDeniedHandler(): AccessDeniedHandler {
        return AccessDeniedHandler { request, response, accessDeniedException ->
            response.status = HttpServletResponse.SC_FORBIDDEN
            response.contentType = "application/json"
            response.writer.write("""
                {
                    "error": "Access Denied",
                    "message": "You do not have sufficient privileges to access this medical imaging resource",
                    "code": "HIPAA_ACCESS_DENIED",
                    "timestamp": "${java.time.LocalDateTime.now()}"
                }
            """.trimIndent())
        }
    }

    @Bean
    fun auditLoggingFilter(): AuditLoggingFilter {
        return AuditLoggingFilter()
    }
}