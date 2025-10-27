import 'package:dio/dio.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../config/app_config.dart';
import '../services/api_service.dart';
import '../services/auth_service.dart';
import '../services/cache_service.dart';
import '../services/connectivity_service.dart';
import '../services/notification_service.dart';
import '../services/storage_service.dart';
import '../services/sync_service.dart';
import '../services/offline_data_service.dart';
import '../services/firebase_service.dart';
import '../models/hive_adapters.dart';

// Core providers
final sharedPreferencesProvider = Provider<SharedPreferences>((ref) {
  throw UnimplementedError('SharedPreferences must be initialized');
});

final secureStorageProvider = Provider<FlutterSecureStorage>((ref) {
  return const FlutterSecureStorage(
    aOptions: AndroidOptions(
      encryptedSharedPreferences: true,
    ),
    iOptions: IOSOptions(
      accessibility: KeychainAccessibility.first_unlock_this_device,
    ),
  );
});

final hiveProvider = Provider<HiveInterface>((ref) {
  return Hive;
});

// Network providers
final dioProvider = Provider<Dio>((ref) {
  final config = ref.watch(appConfigProvider);
  final dio = Dio(BaseOptions(
    baseUrl: config.apiBaseUrl,
    connectTimeout: const Duration(seconds: 30),
    receiveTimeout: const Duration(seconds: 30),
    sendTimeout: const Duration(seconds: 30),
    headers: {
      'Content-Type': 'application/json',
      'Accept': 'application/json',
    },
  ));

  // Add interceptors
  dio.interceptors.add(LogInterceptor(
    requestBody: true,
    responseBody: true,
    logPrint: (obj) => print(obj),
  ));

  // Add auth interceptor
  dio.interceptors.add(InterceptorsWrapper(
    onRequest: (options, handler) async {
      final authService = ref.read(authServiceProvider);
      final token = await authService.getAccessToken();
      if (token != null) {
        options.headers['Authorization'] = 'Bearer $token';
      }
      handler.next(options);
    },
    onError: (error, handler) async {
      if (error.response?.statusCode == 401) {
        final authService = ref.read(authServiceProvider);
        final refreshed = await authService.refreshToken();
        if (refreshed) {
          // Retry the request
          final token = await authService.getAccessToken();
          error.requestOptions.headers['Authorization'] = 'Bearer $token';
          final response = await dio.fetch(error.requestOptions);
          handler.resolve(response);
          return;
        } else {
          // Logout user
          await authService.logout();
        }
      }
      handler.next(error);
    },
  ));

  return dio;
});

// Service providers
final apiServiceProvider = Provider<ApiService>((ref) {
  final dio = ref.watch(dioProvider);
  return ApiService(dio);
});

final authServiceProvider = Provider<AuthService>((ref) {
  final storage = ref.watch(secureStorageProvider);
  final apiService = ref.watch(apiServiceProvider);
  return AuthService(storage, apiService);
});

final storageServiceProvider = Provider<StorageService>((ref) {
  final prefs = ref.watch(sharedPreferencesProvider);
  final secureStorage = ref.watch(secureStorageProvider);
  final hive = ref.watch(hiveProvider);
  return StorageService(prefs, secureStorage, hive);
});

final cacheServiceProvider = Provider<CacheService>((ref) {
  final hive = ref.watch(hiveProvider);
  return CacheService(hive);
});

final connectivityServiceProvider = Provider<ConnectivityService>((ref) {
  return ConnectivityService();
});

final notificationServiceProvider = Provider<NotificationService>((ref) {
  return NotificationService();
});

final syncServiceProvider = Provider<SyncService>((ref) {
  final apiService = ref.watch(apiServiceProvider);
  final storageService = ref.watch(storageServiceProvider);
  final connectivityService = ref.watch(connectivityServiceProvider);
  return SyncService(apiService, storageService, connectivityService);
});

final offlineDataServiceProvider = Provider<OfflineDataService>((ref) {
  final cacheService = ref.watch(cacheServiceProvider);
  final storageService = ref.watch(storageServiceProvider);
  final connectivityService = ref.watch(connectivityServiceProvider);
  final apiService = ref.watch(apiServiceProvider);
  return OfflineDataService(cacheService, storageService, connectivityService, apiService);
});

final firebaseServiceProvider = Provider<FirebaseService>((ref) {
  return FirebaseService.instance;
});

// Initialize dependencies
Future<void> configureDependencies() async {
  // Initialize SharedPreferences
  final sharedPreferences = await SharedPreferences.getInstance();
  
  // Register Hive adapters
  await _registerHiveAdapters();
  
  // Initialize services that need async setup
  await _initializeServices();
}

Future<void> _registerHiveAdapters() async {
  // Register Hive type adapters for offline data storage
  registerHiveAdapters();
}

Future<void> _initializeServices() async {
  // Initialize services that need async setup
  
  // Initialize notification service
  final notificationService = NotificationService();
  await notificationService.initialize();
  
  // Initialize connectivity service
  final connectivityService = ConnectivityService();
  await connectivityService.initialize();
  
  // Initialize Firebase with all services
  try {
    await FirebaseService.instance.initialize();
    
    // Subscribe to healthcare-specific topics
    await FirebaseService.instance.subscribeToTopic('healthcare_alerts');
    await FirebaseService.instance.subscribeToTopic('medication_reminders');
    await FirebaseService.instance.subscribeToTopic('emergency_notifications');
    
    debugPrint('🔥 Firebase services initialized successfully');
  } catch (e) {
    debugPrint('⚠️ Firebase initialization failed: $e');
    // Continue without Firebase if initialization fails
  }
  
  debugPrint('✅ All services initialized successfully');
}

// Override providers for testing
class DependencyOverrides {
  static List<Override> get overrides => [
    // Add test overrides here
  ];
}