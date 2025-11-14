import org.jetbrains.kotlin.gradle.tasks.KotlinCompile

plugins {
    id("org.springframework.boot") version "3.2.0"
    id("io.spring.dependency-management") version "1.1.4"
    kotlin("jvm") version "1.9.20"
    kotlin("plugin.spring") version "1.9.20"
}

group = "com.automed"
version = "1.0.0"
java.sourceCompatibility = JavaVersion.VERSION_21

repositories {
    mavenCentral()
    maven { url = uri("https://jitpack.io") }
}

extra["springCloudVersion"] = "2023.0.0"

dependencies {
    implementation("org.springframework.boot:spring-boot-starter-web")
    implementation("org.springframework.boot:spring-boot-starter-webflux")
    implementation("org.springframework.boot:spring-boot-starter-validation")
    implementation("org.springframework.boot:spring-boot-starter-security")
    implementation("org.springframework.boot:spring-boot-starter-oauth2-resource-server")
    implementation("org.springframework.cloud:spring-cloud-starter-netflix-eureka-client")
    implementation("org.springframework.kafka:spring-kafka")
    implementation("org.springframework.boot:spring-boot-starter-actuator")
    implementation("io.micrometer:micrometer-registry-prometheus")
    implementation("org.springframework.boot:spring-boot-starter-data-redis")
    implementation("org.springframework.boot:spring-boot-starter-data-jpa")
    implementation("org.springframework.boot:spring-boot-starter-data-mongodb")

    // Kotlin
    implementation("org.jetbrains.kotlin:kotlin-reflect")
    implementation("org.jetbrains.kotlin:kotlin-stdlib-jdk8")
    implementation("com.fasterxml.jackson.module:jackson-module-kotlin")
    implementation("io.projectreactor.kotlin:reactor-kotlin-extensions")
    implementation("org.jetbrains.kotlinx:kotlinx-coroutines-reactor")

    // AI/ML Libraries for Drug Discovery
    implementation("org.tensorflow:tensorflow-core-platform:0.5.0")
    implementation("org.deeplearning4j:deeplearning4j-core:1.0.0-M2.1")
    implementation("org.deeplearning4j:deeplearning4j-modelimport:1.0.0-M2.1")
    implementation("org.nd4j:nd4j-native-platform:1.0.0-M2.1")
    implementation("org.deeplearning4j:deeplearning4j-nn:1.0.0-M2.1")

    // Graph Neural Networks
    implementation("org.jgrapht:jgrapht-core:1.5.2")
    implementation("org.jgrapht:jgrapht-ext:1.5.2")

    // Chemistry Libraries
    implementation("org.openscience.cdk:cdk-bundle:2.8")
    implementation("uk.ac.ebi:chebi-ws-client:2.0.1")
    implementation("org.openscience.cdk:cdk-smiles:2.8")
    implementation("org.openscience.cdk:cdk-fingerprint:2.8")
    implementation("org.openscience.cdk:cdk-qsar:2.8")

    // Molecular Docking and Virtual Screening
    implementation("org.openscience.cdk:cdk-docking:2.8")

    // Quantum Computing Integration
    implementation("com.github.Qiskit:qiskit-terra:0.23.0")
    implementation("com.github.D-Wave:dwave-system:1.17.0")

    // Multi-omics Data Processing
    implementation("org.biojava:biojava-core:6.1.0")
    implementation("org.biojava:biojava-structure:6.1.0")
    implementation("org.biojava:biojava-alignment:6.1.0")

    // Statistical Analysis and Machine Learning
    implementation("org.apache.commons:commons-math3:3.6.1")
    implementation("com.google.guava:guava:32.1.3-jre")
    implementation("org.apache.spark:spark-core_2.13:3.5.0")
    implementation("org.apache.spark:spark-mllib_2.13:3.5.0")
    implementation("org.apache.spark:spark-sql_2.13:3.5.0")

    // HTTP Client for external services
    implementation("org.springframework.boot:spring-boot-starter-webflux")

    // Database for molecular data
    implementation("org.postgresql:postgresql")
    implementation("org.mongodb:mongodb-driver-sync")

    // Observability
    implementation("io.micrometer:micrometer-tracing-bridge-brave")

    // Resilience
    implementation("io.github.resilience4j:resilience4j-spring-boot3:2.1.0")
    implementation("io.github.resilience4j:resilience4j-circuitbreaker:2.1.0")
    implementation("io.github.resilience4j:resilience4j-retry:2.1.0")

    // Logging
    implementation("net.logstash.logback:logstash-logback-encoder:7.4")

    // Regulatory Compliance (GDPR, HIPAA)
    implementation("com.github.owasp:java-html-sanitizer:20240325.1")

    testImplementation("org.springframework.boot:spring-boot-starter-test")
    testImplementation("org.springframework.kafka:spring-kafka-test")
    testImplementation("io.projectreactor:reactor-test")
    testImplementation("org.mockito:mockito-core")
    testImplementation("com.ninja-squad:springmockk:4.0.2")
}

dependencyManagement {
    imports {
        mavenBom("org.springframework.cloud:spring-cloud-dependencies:${property("springCloudVersion")}")
    }
}

tasks.withType<KotlinCompile> {
    kotlinOptions {
        freeCompilerArgs = listOf("-Xjsr305=strict")
        jvmTarget = "21"
    }
}

tasks.withType<Test> {
    useJUnitPlatform()
}