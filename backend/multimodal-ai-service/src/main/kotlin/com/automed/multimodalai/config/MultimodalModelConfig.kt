package com.automed.multimodalai.config

import ai.djl.Model
import ai.djl.engine.Engine
import ai.djl.modality.cv.Image
import ai.djl.modality.nlp.SimpleVocabulary
import ai.djl.modality.nlp.Vocabulary
import ai.djl.modality.nlp.bert.BertTokenizer
import ai.djl.ndarray.NDManager
import ai.djl.pytorch.engine.PtEngine
import ai.djl.repository.zoo.Criteria
import ai.djl.repository.zoo.ZooModel
import ai.djl.translate.Translator
import org.springframework.context.annotation.Bean
import org.springframework.context.annotation.Configuration
import java.nio.file.Paths

@Configuration
class MultimodalModelConfig {

    @Bean
    fun ndManager(): NDManager {
        return NDManager.newBaseManager()
    }

    @Bean
    fun bertTokenizer(): BertTokenizer {
        return BertTokenizer.builder()
            .optTokenizerPath(Paths.get("models/bert-base-uncased"))
            .build()
    }

    @Bean
    fun visionModel(): ZooModel<Image, FloatArray> {
        val criteria = Criteria.builder()
            .setTypes(Image::class.java, FloatArray::class.java)
            .optModelUrls("https://resources.djl.ai/test-models/pytorch/resnet18.zip")
            .optEngine(Engine.getEngine(PtEngine.ENGINE_NAME))
            .build()

        return criteria.loadModel()
    }

    @Bean
    fun textModel(): ZooModel<String, FloatArray> {
        val criteria = Criteria.builder()
            .setTypes(String::class.java, FloatArray::class.java)
            .optModelUrls("https://resources.djl.ai/test-models/pytorch/bert-base-uncased.zip")
            .optEngine(Engine.getEngine(PtEngine.ENGINE_NAME))
            .build()

        return criteria.loadModel()
    }

    @Bean
    fun genomicsVocabulary(): Vocabulary {
        // Simple vocabulary for genomics - in production, this would be more comprehensive
        val tokens = listOf(
            "[UNK]", "[CLS]", "[SEP]", "[PAD]", "[MASK]",
            "A", "T", "C", "G", "N" // DNA nucleotides
        )
        return SimpleVocabulary(tokens)
    }
}