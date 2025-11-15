import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:firebase_messaging/firebase_messaging.dart';

import 'core/di/injection.dart';
import 'core/router/app_router.dart';
import 'core/theme/app_theme.dart';
import 'core/utils/platform_utils.dart';
import 'core/services/firebase_service.dart';
import 'generated/l10n.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Set up Firebase background message handler
  FirebaseMessaging.onBackgroundMessage(firebaseMessagingBackgroundHandler);

  // Initialize Hive for local storage
  await Hive.initFlutter();

  // Initialize dependency injection
  await configureDependencies();

  // Initialize platform-specific configurations
  await _initializePlatformConfigurations();

  runApp(
    ProviderScope(
      child: AutomedApp(),
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

  // Configure system UI overlay style
  SystemChrome.setSystemUIOverlayStyle(
    const SystemUiOverlayStyle(
      statusBarColor: Colors.transparent,
      statusBarIconBrightness: Brightness.dark,
      systemNavigationBarColor: Colors.white,
      systemNavigationBarIconBrightness: Brightness.dark,
    ),
  );

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
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final router = ref.watch(appRouterProvider);

    return MaterialApp.router(
      title: 'Automed',
      debugShowCheckedModeBanner: false,

      // Theme Configuration
      theme: AppTheme.lightTheme,
      darkTheme: AppTheme.darkTheme,
      themeMode: ThemeMode.system,

      // Localization
      localizationsDelegates: const [
        S.delegate,
        GlobalMaterialLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
      ],
      supportedLocales: S.delegate.supportedLocales,

      // Routing
      routerConfig: router,

      // Builder for responsive design and platform adaptations
      builder: (context, child) {
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
