import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:dio/dio.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:local_auth/local_auth.dart';
import 'package:riverpod/riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../config/app_config.dart';
import '../services/api_service.dart';
import '../services/auth_service.dart';
import '../services/cache_service.dart';
import '../services/connectivity_service.dart';
import '../services/firebase_service.dart';
import '../services/notification_service.dart';
import '../services/offline_data_service.dart';
import '../services/storage_service.dart';
import '../services/sync_service.dart';

// External dependencies providers
final dioProvider = Provider<Dio>((ref) {
  final dio = Dio(BaseOptions(
    connectTimeout: const Duration(seconds: 30),
    receiveTimeout: const Duration(seconds: 30),
    sendTimeout: const Duration(seconds: 30),
    headers: {
      'Content-Type': 'application/json',
      'Accept': 'application/json',
    },
  ));

  // Add interceptors for logging, authentication, error handling
  dio.interceptors.addAll([
    LogInterceptor(
      request: true,
      requestHeader: false,
      requestBody: false,
      responseHeader: false,
      responseBody: true,
      error: true,
    ),
    InterceptorsWrapper(
      onRequest: (options, handler) async {
        // Add authentication token if available
        final secureStorage = ref.read(secureStorageProvider);
        final token = await secureStorage.read(key: 'auth_token');
        if (token != null) {
          options.headers['Authorization'] = 'Bearer $token';
        }
        return handler.next(options);
      },
      onError: (error, handler) async {
        // Handle token refresh on 401
        if (error.response?.statusCode == 401) {
          // Attempt token refresh logic here
          // For now, just pass through
        }
        return handler.next(error);
      },
    ),
  ]);

  return dio;
});

final connectivityProvider = Provider<Connectivity>((ref) {
  return Connectivity();
});

final secureStorageProvider = Provider<FlutterSecureStorage>((ref) {
  return const FlutterSecureStorage();
});

final sharedPreferencesProvider = FutureProvider<SharedPreferences>((ref) {
  return SharedPreferences.getInstance();
});

final localAuthProvider = Provider<LocalAuthentication>((ref) {
  return LocalAuthentication();
});

final hiveProvider = Provider<Box>((ref) {
  throw UnimplementedError('Hive box must be initialized');
});

// App config provider
final appConfigProvider = Provider<AppConfig>((ref) {
  return AppConfig.development();
});

// Service providers
final connectivityServiceProvider = Provider<ConnectivityService>((ref) {
  final connectivity = ref.watch(connectivityProvider);
  return ConnectivityService(connectivity);
});

final apiServiceProvider = Provider<ApiService>((ref) {
  final dio = ref.watch(dioProvider);
  final appConfig = ref.watch(appConfigProvider);
  return ApiService(dio: dio, appConfig: appConfig);
});

final authServiceProvider = Provider<AuthService>((ref) {
  final apiService = ref.watch(apiServiceProvider);
  final secureStorage = ref.watch(secureStorageProvider);
  final localAuth = ref.watch(localAuthProvider);
  return AuthService(
    apiService: apiService,
    secureStorage: secureStorage,
    localAuth: localAuth,
  );
});

final cacheServiceProvider = Provider<CacheService>((ref) {
  final box = ref.watch(hiveProvider);
  return CacheService(box);
});

final storageServiceProvider = Provider<StorageService>((ref) {
  final secureStorage = ref.watch(secureStorageProvider);
  final sharedPreferencesAsync = ref.watch(sharedPreferencesProvider);
  return sharedPreferencesAsync.maybeWhen(
    data: (sharedPreferences) => StorageService(
      secureStorage: secureStorage,
      sharedPreferences: sharedPreferences,
    ),
    orElse: () => throw Exception('SharedPreferences not initialized'),
  );
});

final offlineDataServiceProvider = Provider<OfflineDataService>((ref) {
  final storageService = ref.watch(storageServiceProvider);
  final cacheService = ref.watch(cacheServiceProvider);
  final appConfig = ref.watch(appConfigProvider);
  final apiService = ref.watch(apiServiceProvider);
  return OfflineDataService(
    storageService: storageService,
    cacheService: cacheService,
    appConfig: appConfig,
    apiService: apiService,
  );
});

final syncServiceProvider = Provider<SyncService>((ref) {
  final apiService = ref.watch(apiServiceProvider);
  final offlineDataService = ref.watch(offlineDataServiceProvider);
  final connectivityService = ref.watch(connectivityServiceProvider);
  final appConfig = ref.watch(appConfigProvider);
  return SyncService(
    apiService: apiService,
    offlineDataService: offlineDataService,
    connectivityService: connectivityService,
    appConfig: appConfig,
  );
});

final firebaseServiceProvider = Provider<FirebaseService>((ref) {
  return FirebaseService();
});

final notificationServiceProvider = Provider<NotificationService>((ref) {
  final firebaseService = ref.watch(firebaseServiceProvider);
  return NotificationService(firebaseService: firebaseService);
});

// Initialization function
Future<void> configureDependencies() async {
  // Initialize Hive
  await Hive.initFlutter();

  // Initialize Firebase
  await FirebaseService.initializeFirebase();
}
