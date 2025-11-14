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

    // Kotlin
    implementation("org.jetbrains.kotlin:kotlin-reflect")
    implementation("org.jetbrains.kotlin:kotlin-stdlib-jdk8")
    implementation("com.fasterxml.jackson.module:jackson-module-kotlin")
    implementation("io.projectreactor.kotlin:reactor-kotlin-extensions")
    implementation("org.jetbrains.kotlinx:kotlinx-coroutines-reactor")

    // DICOM Support
    implementation("org.dcm4che:dcm4che-core:5.31.0")
    implementation("org.dcm4che:dcm4che-imageio:5.31.0")
    implementation("org.dcm4che:dcm4che-net:5.31.0")

    // Medical Imaging Libraries
    implementation("org.itk:itk-java:5.3.0")
    implementation("com.github.dcm4che:dcm4che-tool-common:5.31.0")

    // AI/ML for Medical Imaging
    implementation("org.tensorflow:tensorflow-core-platform:0.5.0")
    implementation("org.deeplearning4j:deeplearning4j-core:1.0.0-M2.1")
    implementation("org.deeplearning4j:deeplearning4j-modelimport:1.0.0-M2.1")
    implementation("org.nd4j:nd4j-native-platform:1.0.0-M2.1")

    // Diffusion Models and Generative AI
    implementation("ai.djl:api:0.24.0")
    implementation("ai.djl.pytorch:pytorch-engine:0.24.0")
    implementation("ai.djl.huggingface:tokenizers:0.24.0")

    // Image Processing
    implementation("org.imgscalr:imgscalr-lib:4.2")
    implementation("com.github.jai-imageio:jai-imageio-core:1.4.0")

    // HIPAA Compliance and Security
    implementation("org.bouncycastle:bcpkix-jdk18on:1.77")
    implementation("org.springframework.security:spring-security-crypto")
    implementation("com.github.ulisesbocchio:jasypt-spring-boot-starter:3.0.5")

    // Federated Learning
    implementation("org.apache.commons:commons-math3:3.6.1")
    implementation("com.google.guava:guava:32.1.3-jre")

    // PACS Integration
    implementation("org.dcm4che:dcm4che-tool-storescp:5.31.0")
    implementation("org.dcm4che:dcm4che-tool-storescu:5.31.0")

    // Observability
    implementation("io.micrometer:micrometer-tracing-bridge-brave")

    // Resilience
    implementation("io.github.resilience4j:resilience4j-spring-boot3:2.1.0")
    implementation("io.github.resilience4j:resilience4j-circuitbreaker:2.1.0")
    implementation("io.github.resilience4j:resilience4j-retry:2.1.0")

    // Logging
    implementation("net.logstash.logback:logstash-logback-encoder:7.4")

    testImplementation("org.springframework.boot:spring-boot-starter-test")
    testImplementation("org.springframework.kafka:spring-kafka-test")
    testImplementation("io.projectreactor:reactor-test")
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