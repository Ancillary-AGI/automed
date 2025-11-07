package com.automed.patient.config

import org.springframework.context.MessageSource
import org.springframework.context.annotation.Bean
import org.springframework.context.annotation.Configuration
import org.springframework.context.support.ReloadableResourceBundleMessageSource
import org.springframework.web.servlet.LocaleResolver
import org.springframework.web.servlet.i18n.AcceptHeaderLocaleResolver
import java.util.*

@Configuration
class InternationalizationConfig {

    @Bean
    fun messageSource(): MessageSource {
        val messageSource = ReloadableResourceBundleMessageSource()
        messageSource.setBasename("classpath:messages/messages")
        messageSource.setDefaultEncoding("UTF-8")
        messageSource.setCacheSeconds(3600) // Cache for 1 hour
        messageSource.setFallbackToSystemLocale(true)
        return messageSource
    }

    @Bean
    fun localeResolver(): LocaleResolver {
        val localeResolver = AcceptHeaderLocaleResolver()

        // Supported locales for healthcare platform
        val supportedLocales = listOf(
            Locale.ENGLISH,
            Locale.forLanguageTag("es"), // Spanish
            Locale.forLanguageTag("fr"), // French
            Locale.forLanguageTag("de"), // German
            Locale.forLanguageTag("it"), // Italian
            Locale.forLanguageTag("pt"), // Portuguese
            Locale.forLanguageTag("ru"), // Russian
            Locale.forLanguageTag("zh"), // Chinese
            Locale.forLanguageTag("ja"), // Japanese
            Locale.forLanguageTag("ko"), // Korean
            Locale.forLanguageTag("ar"), // Arabic
            Locale.forLanguageTag("he"), // Hebrew
            Locale.forLanguageTag("hi"), // Hindi
            Locale.forLanguageTag("bn"), // Bengali
            Locale.forLanguageTag("ur"), // Urdu
            Locale.forLanguageTag("fa"), // Persian
            Locale.forLanguageTag("tr"), // Turkish
            Locale.forLanguageTag("pl"), // Polish
            Locale.forLanguageTag("nl"), // Dutch
            Locale.forLanguageTag("sv"), // Swedish
            Locale.forLanguageTag("da"), // Danish
            Locale.forLanguageTag("no"), // Norwegian
            Locale.forLanguageTag("fi"), // Finnish
            Locale.forLanguageTag("cs"), // Czech
            Locale.forLanguageTag("sk"), // Slovak
            Locale.forLanguageTag("hu"), // Hungarian
            Locale.forLanguageTag("ro"), // Romanian
            Locale.forLanguageTag("bg"), // Bulgarian
            Locale.forLanguageTag("hr"), // Croatian
            Locale.forLanguageTag("sl"), // Slovenian
            Locale.forLanguageTag("et"), // Estonian
            Locale.forLanguageTag("lv"), // Latvian
            Locale.forLanguageTag("lt"), // Lithuanian
            Locale.forLanguageTag("mt"), // Maltese
            Locale.forLanguageTag("el"), // Greek
            Locale.forLanguageTag("uk"), // Ukrainian
            Locale.forLanguageTag("sr"), // Serbian
            Locale.forLanguageTag("mk"), // Macedonian
            Locale.forLanguageTag("sq"), // Albanian
            Locale.forLanguageTag("bs")  // Bosnian
        )

        localeResolver.setSupportedLocales(supportedLocales)
        localeResolver.setDefaultLocale(Locale.ENGLISH)

        return localeResolver
    }
}