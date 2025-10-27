import 'package:flutter_riverpod/flutter_riverpod.dart';

/// Configuration class for the Automed application
/// Handles environment-specific settings and feature flags
/// Supports development, staging, and production environments
class AppConfig {
  /// Base URL for API endpoints
  final String apiBaseUrl;

  /// Base URL for WebSocket connections
  final String wsBaseUrl;

  /// Current environment (development, staging, production)
  final String environment;

  /// Enable/disable debug logging
  final bool enableLogging;

  /// Enable/disable analytics tracking
  final bool enableAnalytics;

  /// Application version string
  final String version;

  /// Feature flags for enabling/disabling specific functionality
  final Map<String, dynamic> features;

  const AppConfig({
    required this.apiBaseUrl,
    required this.wsBaseUrl,
    required this.environment,
    required this.enableLogging,
    required this.enableAnalytics,
    required this.version,
    required this.features,
  });

  factory AppConfig.development() {
    return const AppConfig(
      apiBaseUrl: 'http://localhost:8080/api/v1',
      wsBaseUrl: 'ws://localhost:8080/ws',
      environment: 'development',
      enableLogging: true,
      enableAnalytics: false,
      version: '1.0.0-dev',
      features: {
        'aiAssistant': true,
        'telemedicine': true,
        'offlineMode': true,
        'biometricAuth': true,
        'emergencyMode': true,
        'multiLanguage': true,
        'darkMode': true,
        'accessibility': true,
      },
    );
  }

  factory AppConfig.staging() {
    return const AppConfig(
      apiBaseUrl: 'https://staging-api.automed.com/api/v1',
      wsBaseUrl: 'wss://staging-api.automed.com/ws',
      environment: 'staging',
      enableLogging: true,
      enableAnalytics: true,
      version: '1.0.0-staging',
      features: {
        'aiAssistant': true,
        'telemedicine': true,
        'offlineMode': true,
        'biometricAuth': true,
        'emergencyMode': true,
        'multiLanguage': true,
        'darkMode': true,
        'accessibility': true,
      },
    );
  }

  factory AppConfig.production() {
    return const AppConfig(
      apiBaseUrl: 'https://api.automed.com/api/v1',
      wsBaseUrl: 'wss://api.automed.com/ws',
      environment: 'production',
      enableLogging: false,
      enableAnalytics: true,
      version: '1.0.0',
      features: {
        'aiAssistant': true,
        'telemedicine': true,
        'offlineMode': true,
        'biometricAuth': true,
        'emergencyMode': true,
        'multiLanguage': true,
        'darkMode': true,
        'accessibility': true,
      },
    );
  }

  bool isFeatureEnabled(String feature) {
    return features[feature] == true;
  }

  bool get isDevelopment => environment == 'development';
  bool get isStaging => environment == 'staging';
  bool get isProduction => environment == 'production';
}

final appConfigProvider = Provider<AppConfig>((ref) {
  // Determine environment from build configuration
  const environment = String.fromEnvironment(
    'ENVIRONMENT',
    defaultValue: 'development',
  );

  switch (environment) {
    case 'staging':
      return AppConfig.staging();
    case 'production':
      return AppConfig.production();
    default:
      return AppConfig.development();
  }
});
