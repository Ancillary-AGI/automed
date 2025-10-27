package com.automed.monitoring

import org.springframework.boot.autoconfigure.SpringBootApplication
import org.springframework.boot.runApplication
import org.springframework.cloud.netflix.eureka.EnableEurekaClient
import org.springframework.scheduling.annotation.EnableScheduling

@SpringBootApplication
@EnableEurekaClient
@EnableScheduling
class MonitoringServiceApplication

fun main(args: Array<String>) {
    runApplication<MonitoringServiceApplication>(*args)
}