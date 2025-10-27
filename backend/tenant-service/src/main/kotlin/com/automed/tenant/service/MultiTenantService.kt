package com.automed.tenant.service

import com.automed.tenant.model.*
import com.automed.tenant.repository.TenantRepository
import com.automed.tenant.repository.TenantConfigurationRepository
import org.springframework.stereotype.Service
import org.springframework.transaction.annotation.Transactional
import java.time.LocalDateTime
import java.util.*

@Service
@Transactional
class MultiTenantService(
    private val tenantRepository: TenantRepository,
    private val tenantConfigurationRepository: TenantConfigurationRepository,
    private val tenantDatabaseService: TenantDatabaseService,
    private val tenantSecurityService: TenantSecurityService
) {

    fun createTenant(request: CreateTenantRequest): Tenant {
        // Validate tenant data
        validateTenantRequest(request)
        
        // Create tenant entity
        val tenant = Tenant(
            id = UUID.randomUUID().toString(),
            name = request.name,
            subdomain = request.subdomain,
            domain = request.domain,
            status = TenantStatus.PROVISIONING,
            subscriptionPlan = request.subscriptionPlan,
            maxUsers = getMaxUsersForPlan(request.subscriptionPlan),
            maxPatients = getMaxPatientsForPlan(request.subscriptionPlan),
            features = getFeaturesForPlan(request.subscriptionPlan),
            createdAt = LocalDateTime.now(),
            updatedAt = LocalDateTime.now(),
            contactInfo = TenantContactInfo(
                primaryContactName = request.primaryContactName,
                primaryContactEmail = request.primaryContactEmail,
                primaryContactPhone = request.primaryContactPhone,
                address = request.address,
                city = request.city,
                state = request.state,
                country = request.country,
                postalCode = request.postalCode
            ),
            billingInfo = TenantBillingInfo(
                billingEmail = request.billingEmail,
                billingAddress = request.billingAddress,
                paymentMethod = request.paymentMethod,
                billingCycle = request.billingCycle
            )
        )
        
        // Save tenant
        val savedTenant = tenantRepository.save(tenant)
        
        // Create tenant database schema
        tenantDatabaseService.createTenantSchema(savedTenant.id)
        
        // Setup tenant security configuration
        tenantSecurityService.setupTenantSecurity(savedTenant)
        
        // Create default configuration
        createDefaultConfiguration(savedTenant)
        
        // Update status to active
        savedTenant.status = TenantStatus.ACTIVE
        tenantRepository.save(savedTenant)
        
        return savedTenant
    }

    fun getTenant(tenantId: String): Tenant? {
        return tenantRepository.findById(tenantId).orElse(null)
    }

    fun getTenantBySubdomain(subdomain: String): Tenant? {
        return tenantRepository.findBySubdomain(subdomain)
    }

    fun getTenantByDomain(domain: String): Tenant? {
        return tenantRepository.findByDomain(domain)
    }

    fun updateTenant(tenantId: String, request: UpdateTenantRequest): Tenant {
        val tenant = getTenant(tenantId) ?: throw TenantNotFoundException("Tenant not found: $tenantId")
        
        // Update tenant fields
        request.name?.let { tenant.name = it }
        request.domain?.let { tenant.domain = it }
        request.subscriptionPlan?.let { 
            tenant.subscriptionPlan = it
            tenant.maxUsers = getMaxUsersForPlan(it)
            tenant.maxPatients = getMaxPatientsForPlan(it)
            tenant.features = getFeaturesForPlan(it)
        }
        
        tenant.updatedAt = LocalDateTime.now()
        
        return tenantRepository.save(tenant)
    }

    fun suspendTenant(tenantId: String, reason: String): Tenant {
        val tenant = getTenant(tenantId) ?: throw TenantNotFoundException("Tenant not found: $tenantId")
        
        tenant.status = TenantStatus.SUSPENDED
        tenant.suspensionReason = reason
        tenant.suspendedAt = LocalDateTime.now()
        tenant.updatedAt = LocalDateTime.now()
        
        // Disable tenant access
        tenantSecurityService.disableTenantAccess(tenantId)
        
        return tenantRepository.save(tenant)
    }

    fun reactivateTenant(tenantId: String): Tenant {
        val tenant = getTenant(tenantId) ?: throw TenantNotFoundException("Tenant not found: $tenantId")
        
        tenant.status = TenantStatus.ACTIVE
        tenant.suspensionReason = null
        tenant.suspendedAt = null
        tenant.updatedAt = LocalDateTime.now()
        
        // Re-enable tenant access
        tenantSecurityService.enableTenantAccess(tenantId)
        
        return tenantRepository.save(tenant)
    }

    fun deleteTenant(tenantId: String) {
        val tenant = getTenant(tenantId) ?: throw TenantNotFoundException("Tenant not found: $tenantId")
        
        // Mark as deleted (soft delete)
        tenant.status = TenantStatus.DELETED
        tenant.deletedAt = LocalDateTime.now()
        tenant.updatedAt = LocalDateTime.now()
        
        // Disable access
        tenantSecurityService.disableTenantAccess(tenantId)
        
        // Schedule data cleanup
        tenantDatabaseService.scheduleTenantDataCleanup(tenantId)
        
        tenantRepository.save(tenant)
    }

    fun getTenantConfiguration(tenantId: String): TenantConfiguration? {
        return tenantConfigurationRepository.findByTenantId(tenantId)
    }

    fun updateTenantConfiguration(tenantId: String, configuration: Map<String, Any>): TenantConfiguration {
        val existingConfig = getTenantConfiguration(tenantId)
        
        val tenantConfig = existingConfig ?: TenantConfiguration(
            id = UUID.randomUUID().toString(),
            tenantId = tenantId,
            configuration = mutableMapOf(),
            createdAt = LocalDateTime.now(),
            updatedAt = LocalDateTime.now()
        )
        
        // Update configuration
        tenantConfig.configuration.putAll(configuration)
        tenantConfig.updatedAt = LocalDateTime.now()
        
        return tenantConfigurationRepository.save(tenantConfig)
    }

    fun getTenantUsage(tenantId: String): TenantUsage {
        val tenant = getTenant(tenantId) ?: throw TenantNotFoundException("Tenant not found: $tenantId")
        
        // Get usage statistics from various services
        val userCount = tenantDatabaseService.getUserCount(tenantId)
        val patientCount = tenantDatabaseService.getPatientCount(tenantId)
        val storageUsage = tenantDatabaseService.getStorageUsage(tenantId)
        val apiCallsThisMonth = tenantDatabaseService.getApiCallsThisMonth(tenantId)
        
        return TenantUsage(
            tenantId = tenantId,
            userCount = userCount,
            patientCount = patientCount,
            storageUsageBytes = storageUsage,
            apiCallsThisMonth = apiCallsThisMonth,
            maxUsers = tenant.maxUsers,
            maxPatients = tenant.maxPatients,
            maxStorageBytes = getMaxStorageForPlan(tenant.subscriptionPlan),
            maxApiCallsPerMonth = getMaxApiCallsForPlan(tenant.subscriptionPlan),
            timestamp = LocalDateTime.now()
        )
    }

    fun getAllTenants(page: Int = 0, size: Int = 20): List<Tenant> {
        return tenantRepository.findAllByStatusNot(TenantStatus.DELETED, 
            org.springframework.data.domain.PageRequest.of(page, size)).content
    }

    fun searchTenants(query: String, page: Int = 0, size: Int = 20): List<Tenant> {
        return tenantRepository.findByNameContainingIgnoreCaseOrSubdomainContainingIgnoreCase(
            query, query, org.springframework.data.domain.PageRequest.of(page, size)).content
    }

    private fun validateTenantRequest(request: CreateTenantRequest) {
        // Check if subdomain is already taken
        if (tenantRepository.existsBySubdomain(request.subdomain)) {
            throw TenantValidationException("Subdomain already exists: ${request.subdomain}")
        }
        
        // Check if domain is already taken
        if (request.domain != null && tenantRepository.existsByDomain(request.domain)) {
            throw TenantValidationException("Domain already exists: ${request.domain}")
        }
        
        // Validate subdomain format
        if (!isValidSubdomain(request.subdomain)) {
            throw TenantValidationException("Invalid subdomain format: ${request.subdomain}")
        }
        
        // Validate email format
        if (!isValidEmail(request.primaryContactEmail)) {
            throw TenantValidationException("Invalid email format: ${request.primaryContactEmail}")
        }
    }

    private fun createDefaultConfiguration(tenant: Tenant) {
        val defaultConfig = mapOf(
            "theme" to mapOf(
                "primaryColor" to "#2196F3",
                "secondaryColor" to "#FFC107",
                "logo" to ""
            ),
            "features" to mapOf(
                "aiAssistant" to tenant.features.contains(TenantFeature.AI_ASSISTANT),
                "telemedicine" to tenant.features.contains(TenantFeature.TELEMEDICINE),
                "predictiveAnalytics" to tenant.features.contains(TenantFeature.PREDICTIVE_ANALYTICS),
                "realTimeMonitoring" to tenant.features.contains(TenantFeature.REAL_TIME_MONITORING),
                "smartMedication" to tenant.features.contains(TenantFeature.SMART_MEDICATION),
                "emergencyResponse" to tenant.features.contains(TenantFeature.EMERGENCY_RESPONSE)
            ),
            "security" to mapOf(
                "passwordPolicy" to mapOf(
                    "minLength" to 8,
                    "requireUppercase" to true,
                    "requireLowercase" to true,
                    "requireNumbers" to true,
                    "requireSpecialChars" to true
                ),
                "sessionTimeout" to 3600,
                "maxLoginAttempts" to 5,
                "twoFactorAuth" to false
            ),
            "notifications" to mapOf(
                "emailNotifications" to true,
                "smsNotifications" to false,
                "pushNotifications" to true
            ),
            "integrations" to mapOf(
                "hl7Fhir" to true,
                "dicom" to tenant.features.contains(TenantFeature.MEDICAL_IMAGING),
                "labSystems" to true,
                "pharmacySystems" to tenant.features.contains(TenantFeature.SMART_MEDICATION)
            )
        )
        
        updateTenantConfiguration(tenant.id, defaultConfig)
    }

    private fun getMaxUsersForPlan(plan: SubscriptionPlan): Int {
        return when (plan) {
            SubscriptionPlan.BASIC -> 10
            SubscriptionPlan.PROFESSIONAL -> 50
            SubscriptionPlan.ENTERPRISE -> 500
            SubscriptionPlan.UNLIMITED -> Int.MAX_VALUE
        }
    }

    private fun getMaxPatientsForPlan(plan: SubscriptionPlan): Int {
        return when (plan) {
            SubscriptionPlan.BASIC -> 100
            SubscriptionPlan.PROFESSIONAL -> 1000
            SubscriptionPlan.ENTERPRISE -> 10000
            SubscriptionPlan.UNLIMITED -> Int.MAX_VALUE
        }
    }

    private fun getMaxStorageForPlan(plan: SubscriptionPlan): Long {
        return when (plan) {
            SubscriptionPlan.BASIC -> 1024L * 1024 * 1024 * 5 // 5GB
            SubscriptionPlan.PROFESSIONAL -> 1024L * 1024 * 1024 * 50 // 50GB
            SubscriptionPlan.ENTERPRISE -> 1024L * 1024 * 1024 * 500 // 500GB
            SubscriptionPlan.UNLIMITED -> Long.MAX_VALUE
        }
    }

    private fun getMaxApiCallsForPlan(plan: SubscriptionPlan): Long {
        return when (plan) {
            SubscriptionPlan.BASIC -> 10000
            SubscriptionPlan.PROFESSIONAL -> 100000
            SubscriptionPlan.ENTERPRISE -> 1000000
            SubscriptionPlan.UNLIMITED -> Long.MAX_VALUE
        }
    }

    private fun getFeaturesForPlan(plan: SubscriptionPlan): Set<TenantFeature> {
        return when (plan) {
            SubscriptionPlan.BASIC -> setOf(
                TenantFeature.PATIENT_MANAGEMENT,
                TenantFeature.BASIC_ANALYTICS
            )
            SubscriptionPlan.PROFESSIONAL -> setOf(
                TenantFeature.PATIENT_MANAGEMENT,
                TenantFeature.BASIC_ANALYTICS,
                TenantFeature.TELEMEDICINE,
                TenantFeature.SMART_MEDICATION,
                TenantFeature.REAL_TIME_MONITORING
            )
            SubscriptionPlan.ENTERPRISE -> setOf(
                TenantFeature.PATIENT_MANAGEMENT,
                TenantFeature.BASIC_ANALYTICS,
                TenantFeature.TELEMEDICINE,
                TenantFeature.SMART_MEDICATION,
                TenantFeature.REAL_TIME_MONITORING,
                TenantFeature.AI_ASSISTANT,
                TenantFeature.PREDICTIVE_ANALYTICS,
                TenantFeature.EMERGENCY_RESPONSE,
                TenantFeature.MEDICAL_IMAGING,
                TenantFeature.ADVANCED_REPORTING
            )
            SubscriptionPlan.UNLIMITED -> TenantFeature.values().toSet()
        }
    }

    private fun isValidSubdomain(subdomain: String): Boolean {
        val regex = "^[a-z0-9]([a-z0-9-]{0,61}[a-z0-9])?$".toRegex()
        return subdomain.matches(regex) && subdomain.length >= 3
    }

    private fun isValidEmail(email: String): Boolean {
        val regex = "^[A-Za-z0-9+_.-]+@([A-Za-z0-9.-]+\\.[A-Za-z]{2,})$".toRegex()
        return email.matches(regex)
    }
}

class TenantNotFoundException(message: String) : Exception(message)
class TenantValidationException(message: String) : Exception(message)