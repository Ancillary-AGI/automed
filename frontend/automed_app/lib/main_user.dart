import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:geolocator/geolocator.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:go_router/go_router.dart';
import 'package:window_manager/window_manager.dart';

import 'core/di/injection.dart';
import 'core/router/route_names.dart';
import 'core/theme/app_theme.dart';
import 'core/utils/platform_utils.dart';
import 'core/services/firebase_service.dart';
import 'core/providers/theme_provider.dart';
import 'generated/l10n.dart';
import 'features/patient/presentation/pages/patient_dashboard_page.dart';
import 'features/patient/presentation/pages/patient_profile_page.dart';
import 'features/patient/presentation/pages/health_records_page.dart';
import 'features/patient/presentation/pages/notifications_page.dart';
import 'features/consultation/presentation/pages/consultation_page.dart';
import 'features/consultation/presentation/pages/consultations_list_page.dart';
import 'features/medication/presentation/pages/medication_page.dart';
import 'features/emergency/presentation/pages/emergency_page.dart';
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
      child: AutomedUserApp(),
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
    // Android-specific initialization for user app
    // Request location permissions for emergency services
    await Permission.location.request();
    await Permission.locationWhenInUse.request();

    // Configure notification channels for medication reminders and appointments
    const AndroidNotificationChannel medicationChannel =
        AndroidNotificationChannel(
      'medication_channel',
      'Medication Reminders',
      description: 'Reminders for medication schedules and refills',
      importance: Importance.high,
      playSound: true,
    );

    const AndroidNotificationChannel appointmentChannel =
        AndroidNotificationChannel(
      'appointment_channel',
      'Appointment Reminders',
      description: 'Reminders for upcoming medical appointments',
      importance: Importance.high,
      playSound: true,
    );

    final FlutterLocalNotificationsPlugin flutterLocalNotificationsPlugin =
        FlutterLocalNotificationsPlugin();

    await flutterLocalNotificationsPlugin
        .resolvePlatformSpecificImplementation<
            AndroidFlutterLocalNotificationsPlugin>()
        ?.createNotificationChannel(medicationChannel);

    await flutterLocalNotificationsPlugin
        .resolvePlatformSpecificImplementation<
            AndroidFlutterLocalNotificationsPlugin>()
        ?.createNotificationChannel(appointmentChannel);

    // Request notification permissions
    await FirebaseMessaging.instance.requestPermission(
      alert: true,
      badge: true,
      sound: true,
      provisional: false,
    );
  } else if (PlatformUtils.isIOS) {
    // iOS-specific initialization for user app
    // Request location permissions for emergency services
    await Permission.location.request();
    await Permission.locationWhenInUse.request();

    // Configure iOS notification settings for health reminders
    await FirebaseMessaging.instance.requestPermission(
      alert: true,
      badge: true,
      sound: true,
      provisional: false,
    );

    await FirebaseMessaging.instance
        .setForegroundNotificationPresentationOptions(
      alert: true,
      badge: true,
      sound: true,
    );
  } else if (PlatformUtils.isWeb) {
    // Web-specific initialization for user app
    // Request notification permissions for medication reminders
    await FirebaseMessaging.instance.requestPermission();

    // Check location services availability
    bool serviceEnabled = await Geolocator.isLocationServiceEnabled();
    if (!serviceEnabled) {
      debugPrint('Location services are disabled on web');
    }

    debugPrint('User app initialized on web platform');
  } else if (PlatformUtils.isDesktop) {
    // Desktop-specific initialization for user app
    // Configure desktop-specific health monitoring features
    try {
      await windowManager.ensureInitialized();

      const windowOptions = WindowOptions(
        minimumSize: Size(1000, 700),
        size: Size(1200, 800),
        center: true,
        title: 'Automed Patient Portal',
        titleBarStyle: TitleBarStyle.normal,
      );

      await windowManager.waitUntilReadyToShow(windowOptions, () async {
        await windowManager.show();
        await windowManager.focus();
      });

      // Configure desktop notification system for medication reminders
      // Desktop notifications use system-specific implementations

      // Set up system tray for quick access to medication reminders
      // Configure desktop-specific accessibility features
      // Enable high contrast mode detection for accessibility

      debugPrint(
          'User app initialized on desktop platform with health monitoring features');
    } catch (e) {
      debugPrint('Desktop user app initialization partially failed: $e');
    }
  }
}

final userRouterProvider = Provider<GoRouter>((ref) {
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

      // If logged in and on login/register page, redirect to patient dashboard
      if (isLoggedIn && isLoggingIn) {
        return RouteNames.patientDashboard;
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

      // Patient Routes
      GoRoute(
        path: RouteNames.patientDashboard,
        name: 'patient-dashboard',
        pageBuilder: (context, state) => CustomTransitionPage(
          key: state.pageKey,
          child: const PatientDashboardPage(),
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
        routes: [
          GoRoute(
            path: 'profile',
            name: 'patient-profile',
            pageBuilder: (context, state) => CustomTransitionPage(
              key: state.pageKey,
              child: const PatientProfilePage(),
              transitionsBuilder:
                  (context, animation, secondaryAnimation, child) {
                const begin = Offset(1.0, 0.0);
                const end = Offset.zero;
                const curve = Curves.easeInOut;
                var tween = Tween(begin: begin, end: end)
                    .chain(CurveTween(curve: curve));
                return SlideTransition(
                  position: animation.drive(tween),
                  child: child,
                );
              },
            ),
          ),
          GoRoute(
            path: 'consultations',
            name: 'patient-consultations',
            pageBuilder: (context, state) => CustomTransitionPage(
              key: state.pageKey,
              child: const ConsultationsListPage(),
              transitionsBuilder:
                  (context, animation, secondaryAnimation, child) {
                const begin = Offset(1.0, 0.0);
                const end = Offset.zero;
                const curve = Curves.easeInOut;
                var tween = Tween(begin: begin, end: end)
                    .chain(CurveTween(curve: curve));
                return SlideTransition(
                  position: animation.drive(tween),
                  child: child,
                );
              },
            ),
            routes: [
              GoRoute(
                path: ':id',
                name: 'consultation-detail',
                pageBuilder: (context, state) => CustomTransitionPage(
                  key: state.pageKey,
                  child: ConsultationPage(
                      consultationId: state.pathParameters['id']!),
                  transitionsBuilder:
                      (context, animation, secondaryAnimation, child) {
                    const begin = Offset(1.0, 0.0);
                    const end = Offset.zero;
                    const curve = Curves.easeInOut;
                    var tween = Tween(begin: begin, end: end)
                        .chain(CurveTween(curve: curve));
                    return SlideTransition(
                      position: animation.drive(tween),
                      child: child,
                    );
                  },
                ),
              ),
            ],
          ),
          GoRoute(
            path: 'medications',
            name: 'patient-medications',
            pageBuilder: (context, state) => CustomTransitionPage(
              key: state.pageKey,
              child: const MedicationPage(),
              transitionsBuilder:
                  (context, animation, secondaryAnimation, child) {
                const begin = Offset(1.0, 0.0);
                const end = Offset.zero;
                const curve = Curves.easeInOut;
                var tween = Tween(begin: begin, end: end)
                    .chain(CurveTween(curve: curve));
                return SlideTransition(
                  position: animation.drive(tween),
                  child: child,
                );
              },
            ),
          ),
          GoRoute(
            path: 'emergency',
            name: 'emergency',
            pageBuilder: (context, state) => CustomTransitionPage(
              key: state.pageKey,
              child: const EmergencyPage(),
              transitionsBuilder:
                  (context, animation, secondaryAnimation, child) {
                const begin = Offset(0.0, 1.0);
                const end = Offset.zero;
                const curve = Curves.easeInOut;
                var tween = Tween(begin: begin, end: end)
                    .chain(CurveTween(curve: curve));
                return SlideTransition(
                  position: animation.drive(tween),
                  child: child,
                );
              },
            ),
          ),
        ],
      ),

      // Notifications Route
      GoRoute(
        path: '/notifications',
        name: 'notifications',
        pageBuilder: (context, state) => CustomTransitionPage(
          key: state.pageKey,
          child: const NotificationsPage(),
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

      // Health Records Route
      GoRoute(
        path: '/health-records',
        name: 'health-records',
        pageBuilder: (context, state) => CustomTransitionPage(
          key: state.pageKey,
          child: const HealthRecordsPage(),
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
    ],
    errorBuilder: (context, state) => ErrorPage(error: state.error),
  );
});

class AutomedUserApp extends ConsumerWidget {
  const AutomedUserApp({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final router = ref.watch(userRouterProvider);
    final themeMode = ref.watch(currentThemeModeProvider);

    return MaterialApp.router(
      title: 'Automed User',
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
              onPressed: () => context.go(RouteNames.patientDashboard),
              child: const Text('Go Home'),
            ),
          ],
        ),
      ),
    );
  }
}
