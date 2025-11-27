import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:go_router/go_router.dart';
import 'package:window_manager/window_manager.dart';

import 'core/di/injection.dart';
import 'core/router/route_names.dart';
import 'core/theme/app_theme.dart';
import 'core/utils/platform_utils.dart';
import 'core/services/firebase_service.dart';
import 'core/providers/theme_provider.dart';
import 'generated/l10n.dart';
import 'features/research/presentation/pages/research_dashboard_page.dart';
import 'features/auth/presentation/pages/login_page.dart';
import 'features/auth/presentation/pages/register_page.dart';

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
    const ProviderScope(
      child: AutomedResearchApp(),
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

  // Platform-specific initializations
  if (PlatformUtils.isAndroid) {
    // Android-specific initialization for research app
    // Configure notification channels for research updates
    await FirebaseMessaging.instance.requestPermission(
      alert: true,
      badge: true,
      sound: true,
      provisional: false,
    );

    // Set up Android notification channel for research notifications
    const AndroidNotificationChannel channel = AndroidNotificationChannel(
      'research_channel',
      'Research Notifications',
      description: 'Notifications for research project updates and results',
      importance: Importance.high,
      playSound: true,
    );

    final FlutterLocalNotificationsPlugin flutterLocalNotificationsPlugin =
        FlutterLocalNotificationsPlugin();

    await flutterLocalNotificationsPlugin
        .resolvePlatformSpecificImplementation<
            AndroidFlutterLocalNotificationsPlugin>()
        ?.createNotificationChannel(channel);
  } else if (PlatformUtils.isIOS) {
    // iOS-specific initialization for research app
    await FirebaseMessaging.instance.requestPermission(
      alert: true,
      badge: true,
      sound: true,
      provisional: false,
    );

    // Configure iOS notification categories for research
    await FirebaseMessaging.instance
        .setForegroundNotificationPresentationOptions(
      alert: true,
      badge: true,
      sound: true,
    );
  } else if (PlatformUtils.isWeb) {
    // Web-specific initialization for research app
    // Configure web-specific Firebase settings
    await FirebaseMessaging.instance.requestPermission();

    // Web-specific notification configuration
    debugPrint('Research app initialized on web platform');
  } else if (PlatformUtils.isDesktop) {
    // Desktop-specific initialization for research app
    // Configure desktop window properties for research interface
    try {
      await windowManager.ensureInitialized();

      const windowOptions = WindowOptions(
        minimumSize: Size(1200, 800),
        size: Size(1400, 900),
        center: true,
        title: 'Automed Research',
        titleBarStyle: TitleBarStyle.normal,
      );

      await windowManager.waitUntilReadyToShow(windowOptions, () async {
        await windowManager.show();
        await windowManager.focus();
      });

      // Configure desktop-specific notification settings
      // Desktop notifications use system-specific implementations

      debugPrint(
          'Research app initialized on desktop platform with enhanced window management');
    } catch (e) {
      debugPrint('Desktop initialization partially failed: $e');
    }
  }
}

final researchRouterProvider = Provider<GoRouter>((ref) {
  final authService = ref.watch(authServiceProvider);

  return GoRouter(
    initialLocation: RouteNames.splash,
    debugLogDiagnostics: true,
    redirect: (context, state) async {
      final isLoggedIn = await authService.isLoggedIn();
      final isLoggingIn = state.matchedLocation == RouteNames.login ||
          state.matchedLocation == RouteNames.register;

      // If not logged in and not on login/register page, redirect to login
      if (!isLoggedIn && !isLoggingIn) {
        return RouteNames.login;
      }

      // If logged in and on login/register page, redirect to research dashboard
      if (isLoggedIn && isLoggingIn) {
        return RouteNames.researchDashboard;
      }

      return null;
    },
    routes: [
      // Splash Screen
      GoRoute(
        path: RouteNames.splash,
        name: 'splash',
        pageBuilder: (context, state) => CustomTransitionPage(
          key: state.pageKey,
          child: const SplashPage(),
          transitionsBuilder: (context, animation, secondaryAnimation, child) {
            return FadeTransition(
              opacity: animation,
              child: child,
            );
          },
        ),
      ),

      // Authentication Routes
      GoRoute(
        path: RouteNames.login,
        name: 'login',
        pageBuilder: (context, state) => CustomTransitionPage(
          key: state.pageKey,
          child: const LoginPage(),
          transitionsBuilder: (context, animation, secondaryAnimation, child) {
            const begin = Offset(1.0, 0.0);
            const end = Offset.zero;
            const curve = Curves.easeInOut;
            var tween =
                Tween(begin: begin, end: end).chain(CurveTween(curve: curve));
            return SlideTransition(
              position: animation.drive(tween),
              child: child,
            );
          },
        ),
      ),
      GoRoute(
        path: RouteNames.register,
        name: 'register',
        pageBuilder: (context, state) => CustomTransitionPage(
          key: state.pageKey,
          child: const RegisterPage(),
          transitionsBuilder: (context, animation, secondaryAnimation, child) {
            const begin = Offset(1.0, 0.0);
            const end = Offset.zero;
            const curve = Curves.easeInOut;
            var tween =
                Tween(begin: begin, end: end).chain(CurveTween(curve: curve));
            return SlideTransition(
              position: animation.drive(tween),
              child: child,
            );
          },
        ),
      ),

      // Research Routes
      GoRoute(
        path: RouteNames.researchDashboard,
        name: 'research-dashboard',
        pageBuilder: (context, state) => CustomTransitionPage(
          key: state.pageKey,
          child: const ResearchDashboardPage(),
          transitionsBuilder: (context, animation, secondaryAnimation, child) {
            const begin = Offset(0.0, 1.0);
            const end = Offset.zero;
            const curve = Curves.easeInOut;
            var tween =
                Tween(begin: begin, end: end).chain(CurveTween(curve: curve));
            return SlideTransition(
              position: animation.drive(tween),
              child: child,
            );
          },
        ),
      ),
    ],
    errorBuilder: (context, state) => ErrorPage(error: state.error),
  );
});

class AutomedResearchApp extends ConsumerWidget {
  const AutomedResearchApp({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final router = ref.watch(researchRouterProvider);
    final themeMode = ref.watch(currentThemeModeProvider);

    return MaterialApp.router(
      title: 'Automed Research',
      debugShowCheckedModeBanner: false,

      // Theme Configuration
      theme: AppTheme.lightTheme,
      darkTheme: AppTheme.darkTheme,
      themeMode: themeMode,

      // Localization
      localizationsDelegates: S.localizationsDelegates,
      supportedLocales: S.supportedLocales,

      // Routing
      routerConfig: router,

      // Builder for responsive design and platform adaptations
      builder: (context, child) {
        final isDarkMode = themeMode == ThemeMode.dark ||
            (themeMode == ThemeMode.system &&
                MediaQuery.of(context).platformBrightness == Brightness.dark);

        // Configure system UI overlay style based on app theme
        SystemChrome.setSystemUIOverlayStyle(
          SystemUiOverlayStyle(
            statusBarColor: Colors.transparent,
            statusBarIconBrightness:
                isDarkMode ? Brightness.light : Brightness.dark,
            systemNavigationBarColor:
                isDarkMode ? Colors.grey[900] : Colors.white,
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

// Application pages
class SplashPage extends StatelessWidget {
  const SplashPage({super.key});

  @override
  Widget build(BuildContext context) {
    return const Scaffold(
      body: Center(
        child: CircularProgressIndicator(),
      ),
    );
  }
}

class ErrorPage extends StatelessWidget {
  final Exception? error;

  const ErrorPage({super.key, this.error});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Error')),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.error, size: 64, color: Colors.red),
            const SizedBox(height: 16),
            Text('An error occurred: ${error?.toString() ?? 'Unknown error'}'),
            const SizedBox(height: 16),
            ElevatedButton(
              onPressed: () => context.go(RouteNames.researchDashboard),
              child: const Text('Go Home'),
            ),
          ],
        ),
      ),
    );
  }
}
