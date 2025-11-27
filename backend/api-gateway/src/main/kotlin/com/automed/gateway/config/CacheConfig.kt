package com.automed.gateway.config

import com.fasterxml.jackson.databind.ObjectMapper
import com.fasterxml.jackson.databind.type.TypeFactory
import org.springframework.beans.factory.annotation.Value
import org.springframework.cache.CacheManager
import org.springframework.cache.annotation.EnableCaching
import org.springframework.context.annotation.Bean
import org.springframework.context.annotation.Configuration
import org.springframework.context.annotation.Primary
import org.springframework.data.redis.cache.RedisCacheConfiguration
import org.springframework.data.redis.cache.RedisCacheManager
import org.springframework.data.redis.connection.RedisConnectionFactory
import org.springframework.data.redis.core.RedisTemplate
import org.springframework.data.redis.serializer.GenericJackson2JsonRedisSerializer
import org.springframework.data.redis.serializer.StringRedisSerializer
import java.time.Duration

@Configuration
@EnableCaching
class CacheConfig {

    @Value("\${app.cache.redis.host:localhost}")
    private lateinit var redisHost: String

    @Value("\${app.cache.redis.port:6379}")
    private var redisPort: Int = 6379

    @Value("\${app.cache.redis.password:}")
    private lateinit var redisPassword: String

    @Value("\${app.cache.redis.database:0}")
    private var redisDatabase: Int = 0

    @Value("\${app.cache.ttl.default:3600}")
    private var defaultTtlSeconds: Long = 3600

    @Value("\${app.cache.ttl.patient:1800}")
    private var patientTtlSeconds: Long = 1800

    @Value("\${app.cache.ttl.hospital:3600}")
    private var hospitalTtlSeconds: Long = 3600

    @Value("\${app.cache.ttl.ai:7200}")
    private var aiTtlSeconds: Long = 7200

    @Bean
    fun redisTemplate(redisConnectionFactory: RedisConnectionFactory): RedisTemplate<String, Any> {
        val template = RedisTemplate<String, Any>()
        template.connectionFactory = redisConnectionFactory

        // Use JSON serializer for values
        val serializer = GenericJackson2JsonRedisSerializer(ObjectMapper().findAndRegisterModules())
        template.valueSerializer = serializer
        template.hashValueSerializer = serializer

        // Use String serializer for keys
        template.keySerializer = StringRedisSerializer()
        template.hashKeySerializer = StringRedisSerializer()

        template.afterPropertiesSet()
        return template
    }

    @Primary
    @Bean
    fun cacheManager(redisConnectionFactory: RedisConnectionFactory): CacheManager {
        val defaultConfig = RedisCacheConfiguration.defaultCacheConfig()
            .entryTtl(Duration.ofSeconds(defaultTtlSeconds))
            .serializeKeysWith(RedisCacheConfiguration.SerializationPair.fromSerializer(StringRedisSerializer()))
            .serializeValuesWith(RedisCacheConfiguration.SerializationPair.fromSerializer(
                GenericJackson2JsonRedisSerializer(ObjectMapper().findAndRegisterModules())
            ))
            .disableCachingNullValues()
            .computePrefixWith { cacheName -> "$cacheName:" }

        val configMap = mapOf(
            "patient" to RedisCacheConfiguration.defaultCacheConfig()
                .entryTtl(Duration.ofSeconds(patientTtlSeconds)),
            "hospital" to RedisCacheConfiguration.defaultCacheConfig()
                .entryTtl(Duration.ofSeconds(hospitalTtlSeconds)),
            "ai" to RedisCacheConfiguration.defaultCacheConfig()
                .entryTtl(Duration.ofSeconds(aiTtlSeconds)),
            "emergency" to RedisCacheConfiguration.defaultCacheConfig()
                .entryTtl(Duration.ofSeconds(300)), // 5 minutes for emergency data
            "user" to RedisCacheConfiguration.defaultCacheConfig()
                .entryTtl(Duration.ofSeconds(1800)), // 30 minutes for user sessions
            "api" to RedisCacheConfiguration.defaultCacheConfig()
                .entryTtl(Duration.ofSeconds(600)), // 10 minutes for API responses
        )

        return RedisCacheManager.builder(redisConnectionFactory)
            .cacheDefaults(defaultConfig)
            .withInitialCacheConfigurations(configMap)
            .build()
    }

    @Bean
    fun patientCacheConfig(): RedisCacheConfiguration {
        return RedisCacheConfiguration.defaultCacheConfig()
            .entryTtl(Duration.ofSeconds(patientTtlSeconds))
            .serializeKeysWith(RedisCacheConfiguration.SerializationPair.fromSerializer(StringRedisSerializer()))
            .serializeValuesWith(RedisCacheConfiguration.SerializationPair.fromSerializer(
                GenericJackson2JsonRedisSerializer(ObjectMapper().findAndRegisterModules())
            ))
    }

    @Bean
    fun hospitalCacheConfig(): RedisCacheConfiguration {
        return RedisCacheConfiguration.defaultCacheConfig()
            .entryTtl(Duration.ofSeconds(hospitalTtlSeconds))
            .serializeKeysWith(RedisCacheConfiguration.SerializationPair.fromSerializer(StringRedisSerializer()))
            .serializeValuesWith(RedisCacheConfiguration.SerializationPair.fromSerializer(
                GenericJackson2JsonRedisSerializer(ObjectMapper().findAndRegisterModules())
            ))
    }

    @Bean
    fun aiCacheConfig(): RedisCacheConfiguration {
        return RedisCacheConfiguration.defaultCacheConfig()
            .entryTtl(Duration.ofSeconds(aiTtlSeconds))
            .serializeKeysWith(RedisCacheConfiguration.SerializationPair.fromSerializer(StringRedisSerializer()))
            .serializeValuesWith(RedisCacheConfiguration.SerializationPair.fromSerializer(
                GenericJackson2JsonRedisSerializer(ObjectMapper().findAndRegisterModules())
            ))
    }
}

// Advanced caching strategies
@Configuration
class AdvancedCacheConfig {

    @Bean
    fun multiLevelCacheManager(
        redisCacheManager: CacheManager,
        caffeineCacheManager: com.github.benmanes.caffeine.cache.CacheManager
    ): MultiLevelCacheManager {
        return MultiLevelCacheManager(redisCacheManager, caffeineCacheManager)
    }
}

class MultiLevelCacheManager(
    private val redisCacheManager: CacheManager,
    private val caffeineCacheManager: com.github.benmanes.caffeine.cache.CacheManager
) : CacheManager {

    override fun getCache(name: String): org.springframework.cache.Cache? {
        // Try L1 cache first (Caffeine)
        val l1Cache = caffeineCacheManager.getCache(name)
        if (l1Cache != null) {
            return l1Cache
        }

        // Fall back to L2 cache (Redis)
        return redisCacheManager.getCache(name)
    }

    override fun getCacheNames(): Collection<String> {
        val names = mutableSetOf<String>()
        names.addAll(caffeineCacheManager.cacheNames)
        names.addAll(redisCacheManager.cacheNames)
        return names
    }
}

// Cache warming service
@Configuration
class CacheWarmupConfig {

    @Bean
    fun cacheWarmupService(
        cacheManager: CacheManager,
        patientService: Any, // Inject actual service
        hospitalService: Any  // Inject actual service
    ): CacheWarmupService {
        return CacheWarmupService(cacheManager, patientService, hospitalService)
    }
}

class CacheWarmupService(
    private val cacheManager: CacheManager,
    private val patientService: Any,
    private val hospitalService: Any
) {

    fun warmupCaches() {
        // Warm up frequently accessed data
        warmupPatientData()
        warmupHospitalData()
        warmupReferenceData()
    }

    private fun warmupPatientData() {
        // Pre-load commonly accessed patient data
        val patientCache = cacheManager.getCache("patient")
        // Implementation would load frequently accessed patients
    }

    private fun warmupHospitalData() {
        // Pre-load hospital information
        val hospitalCache = cacheManager.getCache("hospital")
        // Implementation would load hospital data
    }

    private fun warmupReferenceData() {
        // Pre-load reference data like specialties, medications, etc.
        val referenceCache = cacheManager.getCache("reference")
        // Implementation would load reference data
    }
}

// Cache invalidation service
@Configuration
class CacheInvalidationConfig {

    @Bean
    fun cacheInvalidationService(cacheManager: CacheManager): CacheInvalidationService {
        return CacheInvalidationService(cacheManager)
    }
}

class CacheInvalidationService(private val cacheManager: CacheManager) {

    fun invalidatePatientCache(patientId: String) {
        cacheManager.getCache("patient")?.evict(patientId)
        // Also invalidate related caches
        cacheManager.getCache("emergency")?.evict("patient:$patientId")
    }

    fun invalidateHospitalCache(hospitalId: String) {
        cacheManager.getCache("hospital")?.evict(hospitalId)
        // Also invalidate related caches
        cacheManager.getCache("patient")?.evict("hospital:$hospitalId")
    }

    fun invalidateAllCaches() {
        cacheManager.cacheNames.forEach { cacheName ->
            cacheManager.getCache(cacheName)?.clear()
        }
    }

    fun invalidateByPattern(pattern: String) {
        // Implementation would use Redis SCAN to find keys matching pattern
        // and evict them from cache
    }
}