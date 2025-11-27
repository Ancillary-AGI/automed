package com.automed.gateway.config

import org.springframework.amqp.core.*
import org.springframework.amqp.rabbit.annotation.EnableRabbitListener
import org.springframework.amqp.rabbit.config.SimpleRabbitListenerContainerFactory
import org.springframework.amqp.rabbit.connection.CachingConnectionFactory
import org.springframework.amqp.rabbit.connection.ConnectionFactory
import org.springframework.amqp.rabbit.core.RabbitAdmin
import org.springframework.amqp.rabbit.core.RabbitTemplate
import org.springframework.amqp.support.converter.Jackson2JsonMessageConverter
import org.springframework.amqp.support.converter.MessageConverter
import org.springframework.beans.factory.annotation.Value
import org.springframework.context.annotation.Bean
import org.springframework.context.annotation.Configuration
import org.springframework.retry.backoff.ExponentialBackOffPolicy
import org.springframework.retry.policy.SimpleRetryPolicy
import org.springframework.retry.support.RetryTemplate
import java.util.concurrent.Executor
import java.util.concurrent.Executors

@Configuration
@EnableRabbitListener
class EventDrivenConfig {

    @Value("\${app.messaging.rabbitmq.host:localhost}")
    private lateinit var rabbitHost: String

    @Value("\${app.messaging.rabbitmq.port:5672}")
    private var rabbitPort: Int = 5672

    @Value("\${app.messaging.rabbitmq.username:guest}")
    private lateinit var rabbitUsername: String

    @Value("\${app.messaging.rabbitmq.password:guest}")
    private lateinit var rabbitPassword: String

    @Value("\${app.messaging.rabbitmq.virtual-host:/}")
    private lateinit var rabbitVirtualHost: String

    @Bean
    fun connectionFactory(): ConnectionFactory {
        val factory = CachingConnectionFactory()
        factory.host = rabbitHost
        factory.port = rabbitPort
        factory.username = rabbitUsername
        factory.setPassword(rabbitPassword)
        factory.virtualHost = rabbitVirtualHost

        // Connection settings for high availability
        factory.cacheMode = CachingConnectionFactory.CacheMode.CONNECTION
        factory.channelCacheSize = 10
        factory.connectionLimit = 20

        return factory
    }

    @Bean
    fun rabbitTemplate(connectionFactory: ConnectionFactory): RabbitTemplate {
        val rabbitTemplate = RabbitTemplate(connectionFactory)
        rabbitTemplate.messageConverter = jackson2JsonMessageConverter()
        rabbitTemplate.setRetryTemplate(retryTemplate())
        return rabbitTemplate
    }

    @Bean
    fun rabbitAdmin(connectionFactory: ConnectionFactory): RabbitAdmin {
        return RabbitAdmin(connectionFactory)
    }

    @Bean
    fun jackson2JsonMessageConverter(): MessageConverter {
        return Jackson2JsonMessageConverter()
    }

    @Bean
    fun retryTemplate(): RetryTemplate {
        val retryTemplate = RetryTemplate()

        // Retry policy
        val retryPolicy = SimpleRetryPolicy()
        retryPolicy.maxAttempts = 3
        retryTemplate.setRetryPolicy(retryPolicy)

        // Backoff policy
        val backOffPolicy = ExponentialBackOffPolicy()
        backOffPolicy.initialInterval = 500
        backOffPolicy.multiplier = 2.0
        backOffPolicy.maxInterval = 5000
        retryTemplate.setBackoffPolicy(backOffPolicy)

        return retryTemplate
    }

    @Bean
    fun rabbitListenerContainerFactory(
        connectionFactory: ConnectionFactory,
        messageConverter: MessageConverter
    ): SimpleRabbitListenerContainerFactory {
        val factory = SimpleRabbitListenerContainerFactory()
        factory.setConnectionFactory(connectionFactory)
        factory.setMessageConverter(messageConverter)
        factory.setConcurrentConsumers(3)
        factory.setMaxConcurrentConsumers(10)
        factory.setTaskExecutor(taskExecutor())
        factory.setPrefetchCount(1)
        factory.setDefaultRequeueRejected(false)
        return factory
    }

    @Bean
    fun taskExecutor(): Executor {
        return Executors.newCachedThreadPool { r ->
            val thread = Thread(r)
            thread.name = "rabbit-consumer-"
            thread
        }
    }

    // Exchange Definitions
    @Bean
    fun healthcareExchange(): DirectExchange {
        return DirectExchange("healthcare.exchange", true, false)
    }

    @Bean
    fun patientExchange(): TopicExchange {
        return TopicExchange("patient.exchange", true, false)
    }

    @Bean
    fun emergencyExchange(): FanoutExchange {
        return FanoutExchange("emergency.exchange", true, false)
    }

    @Bean
    fun auditExchange(): HeadersExchange {
        return HeadersExchange("audit.exchange", true, false)
    }

    // Queue Definitions
    @Bean
    fun patientCreatedQueue(): Queue {
        return QueueBuilder.durable("patient.created.queue")
            .withArgument("x-message-ttl", 86400000) // 24 hours
            .withArgument("x-max-length", 10000)
            .build()
    }

    @Bean
    fun patientUpdatedQueue(): Queue {
        return QueueBuilder.durable("patient.updated.queue")
            .withArgument("x-message-ttl", 86400000)
            .withArgument("x-max-length", 10000)
            .build()
    }

    @Bean
    fun emergencyAlertQueue(): Queue {
        return QueueBuilder.durable("emergency.alert.queue")
            .withArgument("x-message-ttl", 3600000) // 1 hour
            .withArgument("x-max-length", 5000)
            .build()
    }

    @Bean
    fun consultationQueue(): Queue {
        return QueueBuilder.durable("consultation.queue")
            .withArgument("x-message-ttl", 86400000)
            .withArgument("x-max-length", 20000)
            .build()
    }

    @Bean
    fun auditQueue(): Queue {
        return QueueBuilder.durable("audit.queue")
            .withArgument("x-message-ttl", 604800000) // 7 days
            .withArgument("x-max-length", 50000)
            .build()
    }

    // Binding Definitions
    @Bean
    fun patientCreatedBinding(
        patientCreatedQueue: Queue,
        patientExchange: TopicExchange
    ): Binding {
        return BindingBuilder.bind(patientCreatedQueue)
            .to(patientExchange)
            .with("patient.created.#")
    }

    @Bean
    fun patientUpdatedBinding(
        patientUpdatedQueue: Queue,
        patientExchange: TopicExchange
    ): Binding {
        return BindingBuilder.bind(patientUpdatedQueue)
            .to(patientExchange)
            .with("patient.updated.#")
    }

    @Bean
    fun emergencyAlertBinding(
        emergencyAlertQueue: Queue,
        emergencyExchange: FanoutExchange
    ): Binding {
        return BindingBuilder.bind(emergencyAlertQueue)
            .to(emergencyExchange)
    }

    @Bean
    fun consultationBinding(
        consultationQueue: Queue,
        healthcareExchange: DirectExchange
    ): Binding {
        return BindingBuilder.bind(consultationQueue)
            .to(healthcareExchange)
            .with("consultation")
    }

    @Bean
    fun auditBinding(
        auditQueue: Queue,
        auditExchange: HeadersExchange
    ): Binding {
        return BindingBuilder.bind(auditQueue)
            .to(auditExchange)
            .whereAll(mapOf("audit" to "true")).match()
    }
}

// Event Publisher Service
@Configuration
class EventPublisherConfig {

    @Bean
    fun eventPublisher(rabbitTemplate: RabbitTemplate): EventPublisher {
        return EventPublisher(rabbitTemplate)
    }
}

class EventPublisher(private val rabbitTemplate: RabbitTemplate) {

    fun publishPatientEvent(eventType: String, patientId: String, data: Any) {
        val event = PatientEvent(eventType, patientId, data, System.currentTimeMillis())
        rabbitTemplate.convertAndSend("patient.exchange", "patient.$eventType", event)
    }

    fun publishEmergencyAlert(alert: EmergencyAlert) {
        rabbitTemplate.convertAndSend("emergency.exchange", "", alert)
    }

    fun publishConsultationEvent(eventType: String, consultationId: String, data: Any) {
        val event = ConsultationEvent(eventType, consultationId, data, System.currentTimeMillis())
        rabbitTemplate.convertAndSend("healthcare.exchange", "consultation", event)
    }

    fun publishAuditEvent(action: String, userId: String, resource: String, details: Map<String, Any>) {
        val auditEvent = AuditEvent(action, userId, resource, details, System.currentTimeMillis())
        val headers = mapOf("audit" to "true", "action" to action, "resource" to resource)
        rabbitTemplate.convertAndSend("audit.exchange", "", auditEvent, MessageProperties().apply {
            this.headers.putAll(headers)
        })
    }
}

// Event Data Classes
data class PatientEvent(
    val eventType: String,
    val patientId: String,
    val data: Any,
    val timestamp: Long
)

data class EmergencyAlert(
    val alertId: String,
    val patientId: String,
    val severity: String,
    val message: String,
    val location: String,
    val timestamp: Long
)

data class ConsultationEvent(
    val eventType: String,
    val consultationId: String,
    val data: Any,
    val timestamp: Long
)

data class AuditEvent(
    val action: String,
    val userId: String,
    val resource: String,
    val details: Map<String, Any>,
    val timestamp: Long
)

// Event Consumer Service
@Configuration
class EventConsumerConfig {

    @Bean
    fun eventConsumer(eventPublisher: EventPublisher): EventConsumer {
        return EventConsumer(eventPublisher)
    }
}

class EventConsumer(private val eventPublisher: EventPublisher) {

    @org.springframework.amqp.rabbit.annotation.RabbitListener(queues = ["patient.created.queue"])
    fun handlePatientCreated(event: PatientEvent) {
        // Process patient created event
        // Update search indices, send notifications, etc.
        println("Processing patient created event: ${event.patientId}")
    }

    @org.springframework.amqp.rabbit.annotation.RabbitListener(queues = ["patient.updated.queue"])
    fun handlePatientUpdated(event: PatientEvent) {
        // Process patient updated event
        // Update caches, send notifications, etc.
        println("Processing patient updated event: ${event.patientId}")
    }

    @org.springframework.amqp.rabbit.annotation.RabbitListener(queues = ["emergency.alert.queue"])
    fun handleEmergencyAlert(alert: EmergencyAlert) {
        // Process emergency alert
        // Notify emergency services, update dashboards, etc.
        println("Processing emergency alert: ${alert.alertId}")
    }

    @org.springframework.amqp.rabbit.annotation.RabbitListener(queues = ["consultation.queue"])
    fun handleConsultationEvent(event: ConsultationEvent) {
        // Process consultation event
        // Update schedules, send reminders, etc.
        println("Processing consultation event: ${event.consultationId}")
    }

    @org.springframework.amqp.rabbit.annotation.RabbitListener(queues = ["audit.queue"])
    fun handleAuditEvent(event: AuditEvent) {
        // Process audit event
        // Log to audit database, send alerts for suspicious activity, etc.
        println("Processing audit event: ${event.action} on ${event.resource}")
    }
}