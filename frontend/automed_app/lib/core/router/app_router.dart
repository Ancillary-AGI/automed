import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import 'package:automed_app/features/ai_assistant/presentation/pages/ai_assistant_page.dart';
import 'package:automed_app/features/auth/presentation/pages/login_page.dart';
import 'package:automed_app/features/auth/presentation/pages/register_page.dart';
import 'package:automed_app/features/consultation/presentation/pages/consultation_page.dart';
import 'package:automed_app/features/consultation/presentation/pages/consultations_list_page.dart';
import 'package:automed_app/features/emergency/presentation/pages/emergency_page.dart';
import 'package:automed_app/features/hospital/presentation/pages/hospital_dashboard_page.dart';
import 'package:automed_app/features/medication/presentation/pages/medication_page.dart';
import 'package:automed_app/features/patient/presentation/pages/health_records_page.dart';
import 'package:automed_app/features/patient/presentation/pages/notifications_page.dart';
import 'package:automed_app/features/patient/presentation/pages/patient_dashboard_page.dart';
import 'package:automed_app/features/patient/presentation/pages/patient_profile_page.dart';
import 'package:automed_app/features/patient/presentation/pages/patients_list_page.dart';
import 'package:automed_app/features/settings/presentation/pages/settings_page.dart';
import 'package:automed_app/core/di/injection.dart';
import 'package:automed_app/core/router/route_names.dart';

const bool isUserApp = bool.fromEnvironment('IS_USER_APP', defaultValue: true);

final appRouterProvider = Provider<GoRouter>((ref) {
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

      // If logged in and on login/register page, redirect to appropriate dashboard
      if (isLoggedIn && isLoggingIn) {
        final userType = await authService.getUserType();
        return userType == 'patient'
            ? RouteNames.patientDashboard
            : RouteNames.hospitalDashboard;
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

      // Hospital/Healthcare Provider Routes
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
        ],
      ),

      // AI Features Routes
      GoRoute(
        path: '/ai',
        name: 'ai-features',
        builder: (context, state) => const AIAssistantPage(),
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

      // Settings Routes
      GoRoute(
        path: '/settings',
        name: 'settings',
        pageBuilder: (context, state) => CustomTransitionPage(
          key: state.pageKey,
          child: const SettingsPage(),
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
