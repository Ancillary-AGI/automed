package com.automed.tenant

import org.springframework.boot.autoconfigure.SpringBootApplication
import org.springframework.boot.runApplication
import org.springframework.cloud.netflix.eureka.EnableEurekaClient
import org.springframework.data.jpa.repository.config.EnableJpaRepositories

@SpringBootApplication
@EnableEurekaClient
@EnableJpaRepositories
class TenantServiceApplication

fun main(args: Array<String>) {
    runApplication<TenantServiceApplication>(*args)
}