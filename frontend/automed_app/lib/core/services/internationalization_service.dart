import 'dart:convert';
import 'dart:ui';
import 'package:flutter/services.dart';
import 'package:intl/intl.dart';
import 'package:intl/date_symbol_data_local.dart';
import 'package:shared_preferences/shared_preferences.dart';

/// Advanced Internationalization Service for Healthcare Applications
/// Supports ICU message formatting, RTL languages, medical terminology,
/// and cultural adaptations for global healthcare delivery
class InternationalizationService {
  static const String _localeKey = 'app_locale';
  static const String _fallbackLocale = 'en';
  static const List<String> _supportedLocales = [
    'en',
    'es',
    'fr',
    'de',
    'it',
    'pt',
    'ru',
    'zh',
    'ja',
    'ko',
    'ar',
    'he',
    'hi',
    'bn',
    'ur',
    'fa',
    'tr',
    'pl',
    'nl',
    'sv',
    'da',
    'no',
    'fi',
    'cs',
    'sk',
    'hu',
    'ro',
    'bg',
    'hr',
    'sl',
    'et',
    'lv',
    'lt',
    'mt',
    'el',
    'uk',
    'sr',
    'mk',
    'sq',
    'bs'
  ];

  late Map<String, Map<String, dynamic>> _translations;
  late Locale _currentLocale;
  late SharedPreferences _prefs;

  // ICU MessageFormat patterns for complex translations
  final Map<String, String> _icuPatterns = {
    'appointmentReminder':
        '{gender, select, male {Mr. {name}} female {Ms. {name}} other {{name}}}, you have an appointment with {doctor} on {date, date, long} at {time, time, short}.',
    'medicationReminder':
        '{count, plural, =0 {Time for your medication} =1 {Time for {medication}} other {Time for {count} medications including {medication}}}',
    'vitalSigns':
        '{parameter}: {value} {unit} ({status, select, normal {Normal} high {High} low {Low} critical {Critical}})',
    'emergencyAlert':
        '{severity, select, critical {🚨 CRITICAL: {message}} high {⚠️ URGENT: {message}} medium {ℹ️ ALERT: {message}} other {{message}}}',
    'labResults':
        '{test}: {value} {unit} ({range, select, normal {Normal range} abnormal {Outside normal range: {reference}}})'
  };

  // Medical terminology translations
  final Map<String, Map<String, String>> _medicalTerms = {
    'hypertension': {
      'en': 'Hypertension',
      'es': 'Hipertensión',
      'fr': 'Hypertension',
      'de': 'Hypertonie',
      'ar': 'ارتفاع ضغط الدم',
      'zh': '高血压',
      'ja': '高血圧',
      'hi': 'उच्च रक्तचाप'
    },
    'diabetes': {
      'en': 'Diabetes',
      'es': 'Diabetes',
      'fr': 'Diabète',
      'de': 'Diabetes',
      'ar': 'السكري',
      'zh': '糖尿病',
      'ja': '糖尿病',
      'hi': 'मधुमेह'
    },
    'myocardial_infarction': {
      'en': 'Heart Attack',
      'es': 'Infarto de Miocardio',
      'fr': 'Infarctus du Myocarde',
      'de': 'Herzinfarkt',
      'ar': 'نوبة قلبية',
      'zh': '心肌梗死',
      'ja': '心筋梗塞',
      'hi': 'दिल का दौरा'
    }
  };

  // Cultural adaptations for healthcare
  final Map<String, Map<String, dynamic>> _culturalAdaptations = {
    'date_formats': {
      'en': 'MM/dd/yyyy',
      'es': 'dd/MM/yyyy',
      'fr': 'dd/MM/yyyy',
      'de': 'dd.MM.yyyy',
      'ar': 'yyyy/MM/dd',
      'zh': 'yyyy年MM月dd日',
      'ja': 'yyyy年MM月dd日',
      'hi': 'dd/MM/yyyy'
    },
    'time_formats': {
      'en': 'h:mm a',
      'es': 'H:mm',
      'fr': 'HH:mm',
      'de': 'HH:mm',
      'ar': 'HH:mm',
      'zh': 'HH:mm',
      'ja': 'HH:mm',
      'hi': 'h:mm a'
    },
    'number_formats': {
      'en': {'decimal': '.', 'thousands': ','},
      'es': {'decimal': ',', 'thousands': '.'},
      'fr': {'decimal': ',', 'thousands': ' '},
      'de': {'decimal': ',', 'thousands': '.'},
      'ar': {'decimal': '.', 'thousands': ','},
      'hi': {'decimal': '.', 'thousands': ','}
    },
    'currencies': {
      'en': 'USD',
      'es': 'EUR',
      'fr': 'EUR',
      'de': 'EUR',
      'ar': 'SAR',
      'zh': 'CNY',
      'ja': 'JPY',
      'hi': 'INR'
    },
    'measurement_units': {
      'weight': {
        'en': 'lbs',
        'es': 'kg',
        'fr': 'kg',
        'de': 'kg',
        'ar': 'kg',
        'zh': 'kg',
        'ja': 'kg',
        'hi': 'kg'
      },
      'height': {
        'en': 'in',
        'es': 'cm',
        'fr': 'cm',
        'de': 'cm',
        'ar': 'cm',
        'zh': 'cm',
        'ja': 'cm',
        'hi': 'cm'
      },
      'temperature': {
        'en': '°F',
        'es': '°C',
        'fr': '°C',
        'de': '°C',
        'ar': '°C',
        'zh': '°C',
        'ja': '°C',
        'hi': '°C'
      }
    }
  };

  // RTL language configurations
  final List<String> _rtlLanguages = ['ar', 'he', 'fa', 'ur'];
  final Map<String, TextDirection> _textDirections = {
    'ar': TextDirection.RTL,
    'he': TextDirection.RTL,
    'fa': TextDirection.RTL,
    'ur': TextDirection.RTL,
  };

  // TextDirection getters for compatibility
  TextDirection get rtl => TextDirection.RTL;
  TextDirection get ltr => TextDirection.LTR;

  // Voice synthesis configurations
  final Map<String, Map<String, dynamic>> _voiceConfigs = {
    'en': {'language': 'en-US', 'voice': 'en-US-Neural2-D', 'gender': 'female'},
    'es': {'language': 'es-ES', 'voice': 'es-ES-Neural2-F', 'gender': 'female'},
    'fr': {'language': 'fr-FR', 'voice': 'fr-FR-Neural2-E', 'gender': 'female'},
    'de': {'language': 'de-DE', 'voice': 'de-DE-Neural2-F', 'gender': 'female'},
    'ar': {'language': 'ar-SA', 'voice': 'ar-SA-Neural2-A', 'gender': 'female'},
    'zh': {'language': 'zh-CN', 'voice': 'zh-CN-Neural2-C', 'gender': 'female'},
    'ja': {'language': 'ja-JP', 'voice': 'ja-JP-Neural2-B', 'gender': 'female'},
    'hi': {'language': 'hi-IN', 'voice': 'hi-IN-Neural2-D', 'gender': 'female'}
  };

  Future<void> initialize() async {
    _prefs = await SharedPreferences.getInstance();
    await _loadTranslations();
    await _initializeLocale();
    await _initializeDateFormatting();
  }

  Future<void> _loadTranslations() async {
    _translations = {};

    for (final locale in _supportedLocales) {
      try {
        final jsonString =
            await rootBundle.loadString('assets/translations/$locale.json');
        _translations[locale] = json.decode(jsonString);
      } catch (e) {
        // Fallback to English for missing translations
        if (locale != _fallbackLocale) {
          _translations[locale] = _translations[_fallbackLocale] ?? {};
        }
      }
    }
  }

  Future<void> _initializeLocale() async {
    final savedLocale = _prefs.getString(_localeKey);
    if (savedLocale != null && _supportedLocales.contains(savedLocale)) {
      _currentLocale = Locale(savedLocale);
    } else {
      // Detect system locale
      final systemLocale = PlatformDispatcher.instance.locale;
      final detectedLocale = _findBestMatchingLocale(systemLocale);
      _currentLocale = Locale(detectedLocale);
    }
  }

  Future<void> _initializeDateFormatting() async {
    for (final locale in _supportedLocales) {
      await initializeDateFormatting(locale);
    }
  }

  String _findBestMatchingLocale(Locale systemLocale) {
    // Exact match
    if (_supportedLocales.contains(systemLocale.languageCode)) {
      return systemLocale.languageCode;
    }

    // Language match with script
    final languageWithScript =
        '${systemLocale.languageCode}_${systemLocale.scriptCode}';
    if (_supportedLocales.contains(languageWithScript)) {
      return languageWithScript;
    }

    // Language match with country
    final languageWithCountry =
        '${systemLocale.languageCode}_${systemLocale.countryCode}';
    if (_supportedLocales.contains(languageWithCountry)) {
      return languageWithCountry;
    }

    // Fallback to English
    return _fallbackLocale;
  }

  // Advanced ICU Message Formatting
  String formatMessage(String key, Map<String, dynamic> args) {
    final pattern = _icuPatterns[key] ?? _getTranslation(key);
    return _formatICUMessage(pattern, args);
  }

  String _formatICUMessage(String pattern, Map<String, dynamic> args) {
    String result = pattern;

    // Handle pluralization
    final pluralRegex = RegExp(r'\{(\w+),\s*plural,\s*([^}]+)\}');
    result = result.replaceAllMapped(pluralRegex, (match) {
      final variable = match.group(1)!;
      final options = match.group(2)!;
      final value = args[variable] as num? ?? 0;
      return _resolvePlural(value, options);
    });

    // Handle selection
    final selectRegex = RegExp(r'\{(\w+),\s*select,\s*([^}]+)\}');
    result = result.replaceAllMapped(selectRegex, (match) {
      final variable = match.group(1)!;
      final options = match.group(2)!;
      final value = args[variable]?.toString() ?? 'other';
      return _resolveSelect(value, options);
    });

    // Handle date/time formatting
    final dateRegex = RegExp(r'\{(\w+),\s*date,\s*([^}]+\}[^}]*)\}');
    result = result.replaceAllMapped(dateRegex, (match) {
      final variable = match.group(1)!;
      final format = match.group(2)!;
      final value = args[variable] as DateTime?;
      return value != null
          ? DateFormat(format, _currentLocale.languageCode).format(value)
          : '';
    });

    final timeRegex = RegExp(r'\{(\w+),\s*time,\s*([^}]+\}[^}]*)\}');
    result = result.replaceAllMapped(timeRegex, (match) {
      final variable = match.group(1)!;
      final format = match.group(2)!;
      final value = args[variable] as DateTime?;
      return value != null
          ? DateFormat(format, _currentLocale.languageCode).format(value)
          : '';
    });

    // Replace simple variables
    args.forEach((key, value) {
      result = result.replaceAll('{$key}', value.toString());
    });

    return result;
  }

  String _resolvePlural(num value, String options) {
    final optionMap = _parseOptions(options);
    final pluralKey = _getPluralKey(value);

    return optionMap[pluralKey] ?? optionMap['other'] ?? '';
  }

  String _resolveSelect(String value, String options) {
    final optionMap = _parseOptions(options);
    return optionMap[value] ?? optionMap['other'] ?? '';
  }

  Map<String, String> _parseOptions(String options) {
    final map = <String, String>{};
    final pairs = options.split(' ');

    for (int i = 0; i < pairs.length; i += 2) {
      if (i + 1 < pairs.length) {
        final key = pairs[i];
        final value = pairs[i + 1].replaceAll('\'', '');
        map[key] = value;
      }
    }

    return map;
  }

  String _getPluralKey(num value) {
    if (value == 0) return '=0';
    if (value == 1) return '=1';
    if (value == 2) return '=2';
    return 'other';
  }

  // Medical Terminology Translation
  String translateMedicalTerm(String term, [String? targetLanguage]) {
    final language = targetLanguage ?? _currentLocale.languageCode;
    return _medicalTerms[term]?[language] ??
        _medicalTerms[term]?[_fallbackLocale] ??
        term;
  }

  // Cultural Formatting
  String formatDate(DateTime date, [String? format]) {
    final dateFormat = format ??
        _culturalAdaptations['date_formats']?[_currentLocale.languageCode] ??
        'yyyy-MM-dd';
    return DateFormat(dateFormat, _currentLocale.languageCode).format(date);
  }

  String formatTime(DateTime time, [String? format]) {
    final timeFormat = format ??
        _culturalAdaptations['time_formats']?[_currentLocale.languageCode] ??
        'HH:mm';
    return DateFormat(timeFormat, _currentLocale.languageCode).format(time);
  }

  String formatNumber(num number, [String? format]) {
    final numberFormat =
        NumberFormat(format ?? '#,##0.##', _currentLocale.languageCode);
    return numberFormat.format(number);
  }

  String formatCurrency(num amount, [String? currency]) {
    final currencyCode = currency ??
        _culturalAdaptations['currencies']?[_currentLocale.languageCode] ??
        'USD';
    final currencyFormat = NumberFormat.currency(
        locale: _currentLocale.languageCode, symbol: currencyCode);
    return currencyFormat.format(amount);
  }

  String formatMeasurement(num value, String type, String unit) {
    final preferredUnit = _culturalAdaptations['measurement_units']?[type]
            ?[_currentLocale.languageCode] ??
        unit;
    final formattedValue = formatNumber(value);
    return '$formattedValue $preferredUnit';
  }

  // RTL Support
  bool isRTLLocale() {
    return _rtlLanguages.contains(_currentLocale.languageCode);
  }

  TextDirection getTextDirection() {
    return _textDirections[_currentLocale.languageCode] ?? TextDirection.LTR;
  }

  // Voice Synthesis and Recognition
  Future<void> speak(String text,
      {String? language, double? rate, double? pitch}) async {
    final voiceConfig =
        _voiceConfigs[language ?? _currentLocale.languageCode] ??
            _voiceConfigs[_fallbackLocale]!;

    // Implementation would integrate with platform TTS services
    // For now, this is a placeholder for the actual TTS implementation
    print('Speaking in ${voiceConfig['language']}: $text');
  }

  Future<String?> listenForSpeech({String? language, Duration? timeout}) async {
    final voiceConfig =
        _voiceConfigs[language ?? _currentLocale.languageCode] ??
            _voiceConfigs[_fallbackLocale]!;

    // Implementation would integrate with platform speech recognition
    // For now, this is a placeholder for the actual speech recognition implementation
    print('Listening for speech in ${voiceConfig['language']}');
    return null;
  }

  // Translation Management
  Future<void> updateTranslation(
      String key, String value, String locale) async {
    if (!_translations.containsKey(locale)) {
      _translations[locale] = {};
    }
    _translations[locale]![key] = value;

    // In a real implementation, this would save to a translation management system
    // and trigger a rebuild of the app with new translations
  }

  Future<void> exportTranslations() async {
    // Export translations for external translation services
    final exportData = {
      'metadata': {
        'exported_at': DateTime.now().toIso8601String(),
        'version': '1.0',
        'locales': _supportedLocales
      },
      'translations': _translations
    };

    // In a real implementation, this would save to a file or send to a translation service
    print('Translations exported: ${json.encode(exportData)}');
  }

  Future<void> importTranslations(Map<String, dynamic> importData) async {
    final importedTranslations =
        importData['translations'] as Map<String, dynamic>;
    _translations.addAll(importedTranslations
        .map((key, value) => MapEntry(key, value as Map<String, dynamic>)));

    // Trigger UI refresh with new translations
    // In a real implementation, this would notify listeners to rebuild
  }

  // Locale Management
  Future<void> setLocale(String languageCode) async {
    if (!_supportedLocales.contains(languageCode)) {
      throw ArgumentError('Unsupported locale: $languageCode');
    }

    _currentLocale = Locale(languageCode);
    await _prefs.setString(_localeKey, languageCode);

    // Reinitialize date formatting for new locale
    await initializeDateFormatting(languageCode);

    // Notify the app to rebuild with new locale
    // In a real implementation, this would trigger a locale change event
  }

  Locale getCurrentLocale() => _currentLocale;

  List<Locale> getSupportedLocales() {
    return _supportedLocales.map((code) => Locale(code)).toList();
  }

  // Translation Retrieval
  String _getTranslation(String key) {
    return _translations[_currentLocale.languageCode]?[key] ??
        _translations[_fallbackLocale]?[key] ??
        key;
  }

  String translate(String key, {Map<String, String>? args}) {
    String translation = _getTranslation(key);

    if (args != null) {
      args.forEach((argKey, value) {
        translation = translation.replaceAll('{$argKey}', value);
      });
    }

    return translation;
  }

  // Healthcare-specific formatting
  String formatVitalSigns(
      String parameter, num value, String unit, String status) {
    return formatMessage('vitalSigns', {
      'parameter': translate(parameter),
      'value': formatNumber(value),
      'unit': unit,
      'status': status.toLowerCase()
    });
  }

  String formatAppointmentReminder(
      String name, String gender, String doctor, DateTime dateTime) {
    return formatMessage('appointmentReminder', {
      'name': name,
      'gender': gender.toLowerCase(),
      'doctor': doctor,
      'date': dateTime,
      'time': dateTime
    });
  }

  String formatMedicationReminder(List<String> medications) {
    return formatMessage('medicationReminder', {
      'count': medications.length,
      'medication': medications.isNotEmpty ? medications.first : ''
    });
  }

  String formatEmergencyAlert(String message, String severity) {
    return formatMessage('emergencyAlert',
        {'message': message, 'severity': severity.toLowerCase()});
  }

  String formatLabResults(
      String test, num value, String unit, String range, String reference) {
    return formatMessage('labResults', {
      'test': translate(test),
      'value': formatNumber(value),
      'unit': unit,
      'range': range.toLowerCase(),
      'reference': reference
    });
  }

  // Advanced features for healthcare
  String formatPrescription(
      String medication, num dosage, String frequency, int duration) {
    const prescriptionKey = 'prescription';
    return formatMessage(prescriptionKey, {
      'medication': translateMedicalTerm(medication),
      'dosage': formatNumber(dosage),
      'frequency': translate(frequency),
      'duration': formatNumber(duration)
    });
  }

  String formatDiagnosis(
      String condition, String severity, List<String> symptoms) {
    const diagnosisKey = 'diagnosis';
    return formatMessage(diagnosisKey, {
      'condition': translateMedicalTerm(condition),
      'severity': translate(severity),
      'symptoms': symptoms.map((s) => translate(s)).join(', ')
    });
  }

  String formatTreatmentPlan(
      List<String> treatments, int duration, List<String> precautions) {
    const treatmentKey = 'treatment_plan';
    return formatMessage(treatmentKey, {
      'treatments': treatments.map((t) => translate(t)).join(', '),
      'duration': formatNumber(duration),
      'precautions': precautions.map((p) => translate(p)).join(', ')
    });
  }
}
