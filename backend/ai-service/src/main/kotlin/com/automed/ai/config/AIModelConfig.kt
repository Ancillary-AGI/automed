package com.automed.ai.config

import org.springframework.boot.context.properties.ConfigurationProperties
import org.springframework.context.annotation.Bean
import org.springframework.context.annotation.Configuration

@Configuration
class AIModelConfig {

    @Bean
    @ConfigurationProperties(prefix = "ai.model")
    fun aiModelProperties(): AIModelProperties {
        return AIModelProperties()
    }
}

data class AIModelProperties(
    var defaultModel: String = "claude-sonnet-3.5",
    var enabledModels: MutableMap<String, Boolean> = mutableMapOf(
        "claude-sonnet-3.5" to true,
        "gpt-4" to false,
        "llama-2" to false
    ),
    var apiKeys: MutableMap<String, String> = mutableMapOf()
)