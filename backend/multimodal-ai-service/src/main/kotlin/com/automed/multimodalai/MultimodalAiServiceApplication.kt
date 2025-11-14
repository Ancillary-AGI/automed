package com.automed.multimodalai

import org.springframework.boot.autoconfigure.SpringBootApplication
import org.springframework.boot.runApplication
import org.springframework.cloud.client.discovery.EnableDiscoveryClient
import org.springframework.kafka.annotation.EnableKafka
import org.springframework.scheduling.annotation.EnableAsync

@SpringBootApplication
@EnableDiscoveryClient
@EnableKafka
@EnableAsync
class MultimodalAiServiceApplication

fun main(args: Array<String>) {
    runApplication<MultimodalAiServiceApplication>(*args)
}