import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'dart:ui' as ui;

import 'core/di/injection.dart';
import 'core/router/app_router.dart';
import 'core/theme/app_theme.dart';
import 'core/utils/platform_utils.dart';
import 'core/services/firebase_service.dart';
import 'core/providers/theme_provider.dart';
import 'core/utils/logger.dart';
import 'generated/l10n.dart';

// App Lifecycle Observer for professional lifecycle management
class AppLifecycleObserver extends WidgetsBindingObserver {
  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    super.didChangeAppLifecycleState(state);

    switch (state) {
      case AppLifecycleState.resumed:
        _onAppResumed();
        break;
      case AppLifecycleState.inactive:
        _onAppInactive();
        break;
      case AppLifecycleState.paused:
        _onAppPaused();
        break;
      case AppLifecycleState.detached:
        _onAppDetached();
        break;
      case AppLifecycleState.hidden:
        _onAppHidden();
        break;
    }
  }

  void _onAppResumed() {
    Logger.info('App resumed - refreshing data and reconnecting services');
    // Resume background services, refresh data, reconnect WebSocket connections
  }

  void _onAppInactive() {
    Logger.info('App inactive - preparing for background');
    // Save current state, pause non-essential operations
  }

  void _onAppPaused() {
    Logger.info('App paused - entering background');
    // Save state, stop background services if needed
  }

  void _onAppDetached() {
    Logger.info('App detached - cleaning up resources');
    // Final cleanup, save critical state
  }

  void _onAppHidden() {
    Logger.info('App hidden');
    // Handle app being hidden (iOS specific)
  }
}

// Provider Logger for debugging state changes
class ProviderLogger extends ProviderObserver {
  @override
  void didUpdateProvider(
    ProviderBase<Object?> provider,
    Object? previousValue,
    Object? newValue,
    ProviderContainer container,
  ) {
    Logger.debug(
        'Provider ${provider.name ?? provider.runtimeType} updated: $newValue');
  }

  @override
  void didDisposeProvider(
      ProviderBase<Object?> provider, ProviderContainer container) {
    Logger.debug('Provider ${provider.name ?? provider.runtimeType} disposed');
  }
}

// Global error handling setup
void _setupGlobalErrorHandling() {
  // Handle Flutter framework errors
  FlutterError.onError = (FlutterErrorDetails details) {
    Logger.error('Flutter Error: ${details.exception}', details.exception,
        details.stack);
    // Report to crash reporting service (Firebase Crashlytics, Sentry, etc.)
    // FirebaseCrashlytics.instance.recordFlutterError(details);
  };

  // Handle platform errors
  ui.PlatformDispatcher.instance.onError = (error, stack) {
    Logger.error('Platform Error: $error', error, stack);
    return true;
  };
}

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Initialize app lifecycle observer
  final appLifecycleObserver = AppLifecycleObserver();
  WidgetsBinding.instance.addObserver(appLifecycleObserver);

  // Set up Firebase background message handler
  FirebaseMessaging.onBackgroundMessage(firebaseMessagingBackgroundHandler);

  // Initialize Hive for local storage
  await Hive.initFlutter();

  // Initialize dependency injection
  await configureDependencies();

  // Initialize platform-specific configurations
  await _initializePlatformConfigurations();

  // Set up global error handling
  _setupGlobalErrorHandling();

  runApp(
    ProviderScope(
      observers: [ProviderLogger()],
      child: AutomedApp(
        lifecycleObserver: appLifecycleObserver,
      ),
    ),
  );
}

Future<void> _initializePlatformConfigurations() async {
  // Set preferred orientations
  await SystemChrome.setPreferredOrientations([
    DeviceOrientation.portraitUp,
    DeviceOrientation.portraitDown,
    DeviceOrientation.landscapeLeft,
    DeviceOrientation.landscapeRight,
  ]);

  SystemChrome.setEnabledSystemUIMode(SystemUiMode.edgeToEdge);

  // Platform-specific initializations
  if (PlatformUtils.isAndroid) {
    // Android-specific initialization
  } else if (PlatformUtils.isIOS) {
    // iOS-specific initialization
  } else if (PlatformUtils.isWeb) {
    // Web-specific initialization
  } else if (PlatformUtils.isDesktop) {
    // Desktop-specific initialization
  }
}

class AutomedApp extends ConsumerWidget {
  final AppLifecycleObserver lifecycleObserver;

  const AutomedApp({
    super.key,
    required this.lifecycleObserver,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final router = ref.watch(appRouterProvider);
    final themeMode = ref.watch(currentThemeModeProvider);

    return MaterialApp.router(
      title: 'Automed',
      debugShowCheckedModeBanner: false,

      // Theme Configuration
      theme: AppTheme.lightTheme,
      darkTheme: AppTheme.darkTheme,
      themeMode: themeMode,

      // Localization
      localizationsDelegates: const [
        S.delegate,
        GlobalMaterialLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
      ],
      supportedLocales: S.supportedLocales,

      // Routing
      routerConfig: router,

      // Builder for responsive design and platform adaptations
      builder: (context, child) {
        final isDarkMode = themeMode == ThemeMode.dark ||
            (themeMode == ThemeMode.system &&
                MediaQuery.of(context).platformBrightness == Brightness.dark);

        // Configure system UI overlay style
        SystemChrome.setSystemUIOverlayStyle(
          SystemUiOverlayStyle(
            statusBarColor: Colors.transparent,
            statusBarIconBrightness:
                isDarkMode ? Brightness.light : Brightness.dark,
            systemNavigationBarColor: Colors.white,
            systemNavigationBarIconBrightness:
                isDarkMode ? Brightness.light : Brightness.dark,
          ),
        );
        return MediaQuery(
          data: MediaQuery.of(context).copyWith(
            textScaler: MediaQuery.of(context)
                .textScaler
                .clamp(minScaleFactor: 0.8, maxScaleFactor: 1.2),
          ),
          child: child ?? const SizedBox.shrink(),
        );
      },
    );
  }
}
