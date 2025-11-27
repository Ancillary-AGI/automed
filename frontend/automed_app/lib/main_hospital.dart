import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
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
import 'features/hospital/presentation/pages/hospital_dashboard_page.dart';
import 'features/patient/presentation/pages/patients_list_page.dart';
import 'features/patient/presentation/pages/patient_profile_page.dart';
import 'features/consultation/presentation/pages/consultations_list_page.dart';
import 'features/medication/presentation/pages/medication_page.dart';
import 'features/emergency/presentation/pages/emergency_page.dart';
import 'features/advanced_analytics/presentation/pages/advanced_analytics_dashboard.dart';
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
      child: AutomedHospitalApp(),
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
    // Android-specific initialization for hospital app
    // Request critical permissions for emergency response
    await Permission.location.request();
    await Permission.locationWhenInUse.request();
    await Permission.phone.request();

    // Configure critical notification channels for emergency alerts
    const AndroidNotificationChannel emergencyChannel =
        AndroidNotificationChannel(
      'emergency_channel',
      'Emergency Alerts',
      description: 'Critical emergency notifications and patient alerts',
      importance: Importance.max,
      playSound: true,
      enableVibration: true,
      showBadge: true,
    );

    const AndroidNotificationChannel staffChannel = AndroidNotificationChannel(
      'staff_channel',
      'Staff Coordination',
      description: 'Staff assignments and coordination notifications',
      importance: Importance.high,
      playSound: true,
    );

    final FlutterLocalNotificationsPlugin flutterLocalNotificationsPlugin =
        FlutterLocalNotificationsPlugin();

    await flutterLocalNotificationsPlugin
        .resolvePlatformSpecificImplementation<
            AndroidFlutterLocalNotificationsPlugin>()
        ?.createNotificationChannel(emergencyChannel);

    await flutterLocalNotificationsPlugin
        .resolvePlatformSpecificImplementation<
            AndroidFlutterLocalNotificationsPlugin>()
        ?.createNotificationChannel(staffChannel);

    // Request notification permissions with high priority
    await FirebaseMessaging.instance.requestPermission(
      alert: true,
      badge: true,
      sound: true,
      provisional: false,
      criticalAlert: true,
    );
  } else if (PlatformUtils.isIOS) {
    // iOS-specific initialization for hospital app
    // Request critical permissions for emergency response
    await Permission.location.request();
    await Permission.locationWhenInUse.request();
    await Permission.phone.request();

    // Configure iOS critical notifications for emergency response
    await FirebaseMessaging.instance.requestPermission(
      alert: true,
      badge: true,
      sound: true,
      provisional: false,
      criticalAlert: true,
    );

    await FirebaseMessaging.instance
        .setForegroundNotificationPresentationOptions(
      alert: true,
      badge: true,
      sound: true,
    );
  } else if (PlatformUtils.isWeb) {
    // Web-specific initialization for hospital app
    // Configure web-specific critical notification settings
    await FirebaseMessaging.instance.requestPermission();

    debugPrint('Hospital app initialized on web platform');
  } else if (PlatformUtils.isDesktop) {
    // Desktop-specific initialization for hospital app
    // Configure desktop hospital management interface
    try {
      await windowManager.ensureInitialized();

      const windowOptions = WindowOptions(
        minimumSize: Size(1400, 900),
        size: Size(1600, 1000),
        center: true,
        title: 'Automed Hospital Command Center',
        titleBarStyle: TitleBarStyle.normal,
        alwaysOnTop: false, // Can be set to true for critical alerts
      );

      await windowManager.waitUntilReadyToShow(windowOptions, () async {
        await windowManager.show();
        await windowManager.focus();
      });

      // Configure desktop notification system for emergency alerts
      // Desktop notifications use system-specific implementations
      // Custom sounds and critical alert handling for emergencies

      // Set up system tray for hospital command center
      // Configure multiple desktop workspaces for different hospital functions
      // Enable desktop-specific multi-monitor support for hospital dashboards

      // Set up desktop shortcuts for emergency protocols
      // Configure desktop integration with hospital information systems

      debugPrint(
          'Hospital app initialized on desktop platform with command center features');
    } catch (e) {
      debugPrint('Desktop hospital app initialization partially failed: $e');
    }
  }
}

final hospitalRouterProvider = Provider<GoRouter>((ref) {
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

      // If logged in and on login/register page, redirect to hospital dashboard
      if (isLoggedIn && isLoggingIn) {
        return RouteNames.hospitalDashboard;
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

      // Hospital Routes
      GoRoute(
        path: RouteNames.hospitalDashboard,
        name: 'hospital-dashboard',
        builder: (context, state) => const HospitalDashboardPage(),
        routes: [
          GoRoute(
            path: 'patients',
            name: 'patients-list',
            builder: (context, state) => const PatientsListPage(),
            routes: [
              GoRoute(
                path: ':id',
                name: 'patient-detail',
                builder: (context, state) {
                  final patientId = state.pathParameters['id']!;
                  return PatientProfilePage(patientId: patientId);
                },
              ),
            ],
          ),
          GoRoute(
            path: 'consultations',
            name: 'hospital-consultations',
            builder: (context, state) => const ConsultationsListPage(),
          ),
          GoRoute(
            path: 'medications',
            name: 'hospital-medications',
            builder: (context, state) => const MedicationPage(),
          ),
          GoRoute(
            path: 'emergency',
            name: 'hospital-emergency',
            builder: (context, state) => const EmergencyPage(),
          ),
          GoRoute(
            path: 'analytics',
            name: 'advanced-analytics',
            builder: (context, state) => const AdvancedAnalyticsDashboard(),
          ),
        ],
      ),
    ],
    errorBuilder: (context, state) => ErrorPage(error: state.error),
  );
});

class AutomedHospitalApp extends ConsumerWidget {
  const AutomedHospitalApp({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final router = ref.watch(hospitalRouterProvider);
    final themeMode = ref.watch(currentThemeModeProvider);

    return MaterialApp.router(
      title: 'Automed Hospital',
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
              onPressed: () => context.go(RouteNames.hospitalDashboard),
              child: const Text('Go Home'),
            ),
          ],
        ),
      ),
    );
  }
}
