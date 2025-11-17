import 'package:flutter/foundation.dart';

class AppConfig {
  final String apiBaseUrl;
  final String wsBaseUrl;
  final bool enableLogging;
  final String version;
  final Map<String, dynamic> features;

  const AppConfig({
    required this.apiBaseUrl,
    required this.wsBaseUrl,
    required this.enableLogging,
    required this.version,
    required this.features,
  });

  factory AppConfig.fromEnvironment() {
    return const AppConfig(
      apiBaseUrl: String.fromEnvironment(
        'API_BASE_URL',
        defaultValue: 'http://localhost:8080/api/v1',
      ),
      wsBaseUrl: String.fromEnvironment(
        'WS_BASE_URL',
        defaultValue: 'ws://localhost:8080/ws',
      ),
      enableLogging: bool.fromEnvironment(
        'ENABLE_LOGGING',
        defaultValue: kDebugMode,
      ),
      version: String.fromEnvironment(
        'APP_VERSION',
        defaultValue: '1.0.0',
      ),
      features: {
        'ai_assistant':
            bool.fromEnvironment('FEATURE_AI_ASSISTANT', defaultValue: true),
        'telemedicine':
            bool.fromEnvironment('FEATURE_TELEMEDICINE', defaultValue: true),
        'emergency_response': bool.fromEnvironment('FEATURE_EMERGENCY_RESPONSE',
            defaultValue: true),
        'offline_mode':
            bool.fromEnvironment('FEATURE_OFFLINE_MODE', defaultValue: true),
        'real_time_monitoring': bool.fromEnvironment(
            'FEATURE_REAL_TIME_MONITORING',
            defaultValue: true),
        'predictive_analytics': bool.fromEnvironment(
            'FEATURE_PREDICTIVE_ANALYTICS',
            defaultValue: true),
        'smart_medication': bool.fromEnvironment('FEATURE_SMART_MEDICATION',
            defaultValue: true),
        'multi_tenant':
            bool.fromEnvironment('FEATURE_MULTI_TENANT', defaultValue: false),
      },
    );
  }

  // Development configuration
  factory AppConfig.development() {
    return const AppConfig(
      apiBaseUrl: 'http://localhost:8080/api/v1',
      wsBaseUrl: 'ws://localhost:8080/ws',
      enableLogging: true,
      version: '1.0.0-dev',
      features: {
        'ai_assistant': true,
        'telemedicine': true,
        'emergency_response': true,
        'offline_mode': true,
        'real_time_monitoring': true,
        'predictive_analytics': true,
        'smart_medication': true,
        'multi_tenant': false,
      },
    );
  }

  // Production configuration
  factory AppConfig.production() {
    return const AppConfig(
      apiBaseUrl: 'https://api.automed.com/api/v1',
      wsBaseUrl: 'wss://api.automed.com/ws',
      enableLogging: false,
      version: '1.0.0',
      features: {
        'ai_assistant': true,
        'telemedicine': true,
        'emergency_response': true,
        'offline_mode': true,
        'real_time_monitoring': true,
        'predictive_analytics': true,
        'smart_medication': true,
        'multi_tenant': true,
      },
    );
  }

  // Staging configuration
  factory AppConfig.staging() {
    return const AppConfig(
      apiBaseUrl: 'https://staging-api.automed.com/api/v1',
      wsBaseUrl: 'wss://staging-api.automed.com/ws',
      enableLogging: true,
      version: '1.0.0-staging',
      features: {
        'ai_assistant': true,
        'telemedicine': true,
        'emergency_response': true,
        'offline_mode': true,
        'real_time_monitoring': true,
        'predictive_analytics': true,
        'smart_medication': true,
        'multi_tenant': false,
      },
    );
  }

  bool isFeatureEnabled(String feature) {
    return features[feature] == true;
  }

  @override
  String toString() {
    return 'AppConfig(apiBaseUrl: $apiBaseUrl, wsBaseUrl: $wsBaseUrl, enableLogging: $enableLogging, version: $version, features: $features)';
  }
}
