import 'dart:async';
import 'dart:io';

import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:firebase_crashlytics/firebase_crashlytics.dart';
import 'package:firebase_analytics/firebase_analytics.dart';
import 'package:firebase_performance/firebase_performance.dart';
import 'package:firebase_remote_config/firebase_remote_config.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';

import 'notification_service.dart';
import '../../firebase_options.dart';

class FirebaseService {
  static FirebaseService? _instance;
  static FirebaseService get instance => _instance ??= FirebaseService._();
  
  FirebaseService._();

  // Firebase instances
  FirebaseMessaging? _messaging;
  FirebaseCrashlytics? _crashlytics;
  FirebaseAnalytics? _analytics;
  FirebasePerformance? _performance;
  FirebaseRemoteConfig? _remoteConfig;
  FirebaseAuth? _auth;
  FirebaseFirestore? _firestore;
  FirebaseStorage? _storage;

  // Getters
  FirebaseMessaging get messaging => _messaging!;
  FirebaseCrashlytics get crashlytics => _crashlytics!;
  FirebaseAnalytics get analytics => _analytics!;
  FirebasePerformance get performance => _performance!;
  FirebaseRemoteConfig get remoteConfig => _remoteConfig!;
  FirebaseAuth get auth => _auth!;
  FirebaseFirestore get firestore => _firestore!;
  FirebaseStorage get storage => _storage!;

  bool _isInitialized = false;
  bool get isInitialized => _isInitialized;

  /// Initialize Firebase with all services
  Future<void> initialize() async {
    if (_isInitialized) return;

    try {
      // Initialize Firebase Core
      await Firebase.initializeApp(
        options: _getFirebaseOptions(),
      );

      // Initialize all Firebase services
      await _initializeMessaging();
      await _initializeCrashlytics();
      await _initializeAnalytics();
      await _initializePerformance();
      await _initializeRemoteConfig();
      await _initializeAuth();
      await _initializeFirestore();
      await _initializeStorage();

      _isInitialized = true;
      debugPrint('🔥 Firebase initialized successfully');
    } catch (e) {
      debugPrint('❌ Firebase initialization failed: $e');
      rethrow;
    }
  }

  /// Initialize Firebase Messaging for push notifications
  Future<void> _initializeMessaging() async {
    _messaging = FirebaseMessaging.instance;

    // Request permission for notifications
    final settings = await _messaging!.requestPermission(
      alert: true,
      announcement: false,
      badge: true,
      carPlay: false,
      criticalAlert: true,
      provisional: false,
      sound: true,
    );

    if (settings.authorizationStatus == AuthorizationStatus.authorized) {
      debugPrint('✅ Push notifications permission granted');
      
      // Get FCM token
      final token = await _messaging!.getToken();
      debugPrint('📱 FCM Token: $token');
      
      // Set up message handlers
      _setupMessageHandlers();
    } else {
      debugPrint('❌ Push notifications permission denied');
    }
  }

  /// Set up Firebase Messaging handlers
  void _setupMessageHandlers() {
    // Handle foreground messages
    FirebaseMessaging.onMessage.listen((RemoteMessage message) {
      debugPrint('📨 Foreground message received: ${message.notification?.title}');
      _handleForegroundMessage(message);
    });

    // Handle background messages
    FirebaseMessaging.onMessageOpenedApp.listen((RemoteMessage message) {
      debugPrint('📨 Background message opened: ${message.notification?.title}');
      _handleBackgroundMessage(message);
    });

    // Handle terminated app messages
    FirebaseMessaging.instance.getInitialMessage().then((RemoteMessage? message) {
      if (message != null) {
        debugPrint('📨 Terminated app message: ${message.notification?.title}');
        _handleTerminatedMessage(message);
      }
    });
  }

  /// Handle foreground messages
  void _handleForegroundMessage(RemoteMessage message) {
    final notification = message.notification;
    if (notification != null) {
      // Show local notification
      NotificationService.instance.showNotification(
        title: notification.title ?? 'Automed',
        body: notification.body ?? '',
        type: _getNotificationTypeFromData(message.data),
        data: message.data,
      );
    }

    // Handle healthcare-specific notifications
    _handleHealthcareNotification(message);
  }

  /// Handle background messages
  void _handleBackgroundMessage(RemoteMessage message) {
    // Navigate to specific screen based on message data
    _navigateToScreen(message.data);
    _handleHealthcareNotification(message);
  }

  /// Handle terminated app messages
  void _handleTerminatedMessage(RemoteMessage message) {
    // Handle app launch from notification
    _navigateToScreen(message.data);
    _handleHealthcareNotification(message);
  }

  /// Handle healthcare-specific notifications
  void _handleHealthcareNotification(RemoteMessage message) {
    final data = message.data;
    final type = data['type'];

    switch (type) {
      case 'critical_alert':
        _handleCriticalAlert(data);
        break;
      case 'medication_reminder':
        _handleMedicationReminder(data);
        break;
      case 'appointment_reminder':
        _handleAppointmentReminder(data);
        break;
      case 'vital_signs_alert':
        _handleVitalSignsAlert(data);
        break;
      case 'emergency_alert':
        _handleEmergencyAlert(data);
        break;
      default:
        debugPrint('Unknown notification type: $type');
    }
  }

  /// Initialize Firebase Crashlytics
  Future<void> _initializeCrashlytics() async {
    _crashlytics = FirebaseCrashlytics.instance;

    // Enable crash collection in release mode
    await _crashlytics!.setCrashlyticsCollectionEnabled(!kDebugMode);

    // Set up automatic crash reporting
    FlutterError.onError = _crashlytics!.recordFlutterFatalError;

    // Set up async error handling
    PlatformDispatcher.instance.onError = (error, stack) {
      _crashlytics!.recordError(error, stack, fatal: true);
      return true;
    };

    debugPrint('💥 Crashlytics initialized');
  }

  /// Initialize Firebase Analytics
  Future<void> _initializeAnalytics() async {
    _analytics = FirebaseAnalytics.instance;

    // Enable analytics collection
    await _analytics!.setAnalyticsCollectionEnabled(true);

    // Set default parameters
    await _analytics!.setDefaultParameters({
      'app_type': 'healthcare',
      'platform': Platform.operatingSystem,
    });

    debugPrint('📊 Analytics initialized');
  }

  /// Initialize Firebase Performance
  Future<void> _initializePerformance() async {
    _performance = FirebasePerformance.instance;

    // Enable performance collection
    await _performance!.setPerformanceCollectionEnabled(true);

    debugPrint('⚡ Performance monitoring initialized');
  }

  /// Initialize Firebase Remote Config
  Future<void> _initializeRemoteConfig() async {
    _remoteConfig = FirebaseRemoteConfig.instance;

    // Set config settings
    await _remoteConfig!.setConfigSettings(
      RemoteConfigSettings(
        fetchTimeout: const Duration(minutes: 1),
        minimumFetchInterval: const Duration(hours: 1),
      ),
    );

    // Set default values
    await _remoteConfig!.setDefaults({
      'feature_ai_assistant': true,
      'feature_telemedicine': true,
      'feature_offline_mode': true,
      'max_offline_days': 7,
      'emergency_contact': '+1-800-EMERGENCY',
      'api_timeout_seconds': 30,
      'cache_duration_hours': 24,
    });

    // Fetch and activate
    try {
      await _remoteConfig!.fetchAndActivate();
      debugPrint('🔧 Remote Config initialized and activated');
    } catch (e) {
      debugPrint('⚠️ Remote Config fetch failed: $e');
    }
  }

  /// Initialize Firebase Auth
  Future<void> _initializeAuth() async {
    _auth = FirebaseAuth.instance;

    // Set up auth state listener
    _auth!.authStateChanges().listen((User? user) {
      if (user != null) {
        debugPrint('👤 User signed in: ${user.uid}');
        _setUserProperties(user);
      } else {
        debugPrint('👤 User signed out');
      }
    });

    debugPrint('🔐 Firebase Auth initialized');
  }

  /// Initialize Cloud Firestore
  Future<void> _initializeFirestore() async {
    _firestore = FirebaseFirestore.instance;

    // Configure Firestore settings
    await _firestore!.enablePersistence();

    debugPrint('🗄️ Firestore initialized');
  }

  /// Initialize Firebase Storage
  Future<void> _initializeStorage() async {
    _storage = FirebaseStorage.instance;

    debugPrint('📁 Firebase Storage initialized');
  }

  /// Get Firebase options for different platforms
  FirebaseOptions _getFirebaseOptions() {
    return DefaultFirebaseOptions.currentPlatform;
  }

  /// Set user properties for analytics
  void _setUserProperties(User user) {
    _analytics?.setUserId(user.uid);
    _analytics?.setUserProperty(name: 'user_type', value: 'healthcare_provider');
  }

  /// Get notification type from message data
  NotificationType _getNotificationTypeFromData(Map<String, dynamic> data) {
    final type = data['type'];
    switch (type) {
      case 'critical_alert':
      case 'emergency_alert':
        return NotificationType.error;
      case 'medication_reminder':
      case 'appointment_reminder':
        return NotificationType.warning;
      default:
        return NotificationType.info;
    }
  }

  /// Navigate to specific screen based on notification data
  void _navigateToScreen(Map<String, dynamic> data) {
    final screen = data['screen'];
    final patientId = data['patient_id'];
    
    // This would integrate with your navigation system
    debugPrint('Navigate to: $screen with patient: $patientId');
  }

  /// Handle critical healthcare alerts
  void _handleCriticalAlert(Map<String, dynamic> data) {
    final patientId = data['patient_id'];
    final alertType = data['alert_type'];
    final severity = data['severity'];
    
    debugPrint('🚨 Critical Alert: $alertType for patient $patientId (Severity: $severity)');
    
    // Log critical event
    _analytics?.logEvent(
      name: 'critical_alert_received',
      parameters: {
        'patient_id': patientId,
        'alert_type': alertType,
        'severity': severity,
      },
    );
  }

  /// Handle medication reminders
  void _handleMedicationReminder(Map<String, dynamic> data) {
    final patientId = data['patient_id'];
    final medication = data['medication'];
    
    debugPrint('💊 Medication Reminder: $medication for patient $patientId');
    
    _analytics?.logEvent(
      name: 'medication_reminder_received',
      parameters: {
        'patient_id': patientId,
        'medication': medication,
      },
    );
  }

  /// Handle appointment reminders
  void _handleAppointmentReminder(Map<String, dynamic> data) {
    final patientId = data['patient_id'];
    final appointmentTime = data['appointment_time'];
    
    debugPrint('📅 Appointment Reminder: $appointmentTime for patient $patientId');
    
    _analytics?.logEvent(
      name: 'appointment_reminder_received',
      parameters: {
        'patient_id': patientId,
        'appointment_time': appointmentTime,
      },
    );
  }

  /// Handle vital signs alerts
  void _handleVitalSignsAlert(Map<String, dynamic> data) {
    final patientId = data['patient_id'];
    final vitalType = data['vital_type'];
    final value = data['value'];
    
    debugPrint('❤️ Vital Signs Alert: $vitalType = $value for patient $patientId');
    
    _analytics?.logEvent(
      name: 'vital_signs_alert_received',
      parameters: {
        'patient_id': patientId,
        'vital_type': vitalType,
        'value': value,
      },
    );
  }

  /// Handle emergency alerts
  void _handleEmergencyAlert(Map<String, dynamic> data) {
    final patientId = data['patient_id'];
    final emergencyType = data['emergency_type'];
    final location = data['location'];
    
    debugPrint('🚨 Emergency Alert: $emergencyType for patient $patientId at $location');
    
    _analytics?.logEvent(
      name: 'emergency_alert_received',
      parameters: {
        'patient_id': patientId,
        'emergency_type': emergencyType,
        'location': location,
      },
    );
  }

  /// Log custom analytics event
  Future<void> logEvent(String name, Map<String, dynamic> parameters) async {
    await _analytics?.logEvent(name: name, parameters: parameters);
  }

  /// Log custom error
  void recordError(dynamic exception, StackTrace? stackTrace, {bool fatal = false}) {
    _crashlytics?.recordError(exception, stackTrace, fatal: fatal);
  }

  /// Get remote config value
  T getRemoteConfigValue<T>(String key, T defaultValue) {
    try {
      final value = _remoteConfig?.getValue(key);
      if (value == null) return defaultValue;
      
      if (T == bool) {
        return value.asBool() as T;
      } else if (T == int) {
        return value.asInt() as T;
      } else if (T == double) {
        return value.asDouble() as T;
      } else if (T == String) {
        return value.asString() as T;
      }
      
      return defaultValue;
    } catch (e) {
      debugPrint('Error getting remote config value for $key: $e');
      return defaultValue;
    }
  }

  /// Subscribe to topic for push notifications
  Future<void> subscribeToTopic(String topic) async {
    await _messaging?.subscribeToTopic(topic);
    debugPrint('📢 Subscribed to topic: $topic');
  }

  /// Unsubscribe from topic
  Future<void> unsubscribeFromTopic(String topic) async {
    await _messaging?.unsubscribeFromTopic(topic);
    debugPrint('📢 Unsubscribed from topic: $topic');
  }

  /// Get FCM token
  Future<String?> getFCMToken() async {
    return await _messaging?.getToken();
  }

  /// Upload file to Firebase Storage
  Future<String?> uploadFile(String path, List<int> data, {String? contentType}) async {
    try {
      final ref = _storage!.ref().child(path);
      final uploadTask = ref.putData(
        Uint8List.fromList(data),
        SettableMetadata(contentType: contentType),
      );
      
      final snapshot = await uploadTask;
      final downloadUrl = await snapshot.ref.getDownloadURL();
      
      debugPrint('📁 File uploaded: $path');
      return downloadUrl;
    } catch (e) {
      debugPrint('❌ File upload failed: $e');
      recordError(e, StackTrace.current);
      return null;
    }
  }

  /// Start performance trace
  Trace startTrace(String name) {
    return _performance!.newTrace(name);
  }
}

// Background message handler (must be top-level function)
@pragma('vm:entry-point')
Future<void> firebaseMessagingBackgroundHandler(RemoteMessage message) async {
  await Firebase.initializeApp();
  debugPrint('📨 Background message: ${message.notification?.title}');
}