package com.automed.consultation

import org.springframework.boot.autoconfigure.SpringBootApplication
import org.springframework.boot.runApplication
import org.springframework.cloud.client.discovery.EnableDiscoveryClient
import org.springframework.kafka.annotation.EnableKafka

@SpringBootApplication
@EnableDiscoveryClient
@EnableKafka
class ConsultationServiceApplication

fun main(args: Array<String>) {
    runApplication<ConsultationServiceApplication>(*args)
}