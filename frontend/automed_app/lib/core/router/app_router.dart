import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../features/auth/presentation/pages/login_page.dart';
import '../../features/auth/presentation/pages/register_page.dart';
import '../../features/consultation/presentation/pages/consultation_page.dart';
import '../../features/consultation/presentation/pages/consultations_list_page.dart';
import '../../features/emergency/presentation/pages/emergency_page.dart';
import '../../features/hospital/presentation/pages/hospital_dashboard_page.dart';
import '../../features/medication/presentation/pages/medication_page.dart';
import '../../features/patient/presentation/pages/patient_dashboard_page.dart';
import '../../features/patient/presentation/pages/patient_profile_page.dart';
import '../../features/patient/presentation/pages/patients_list_page.dart';
import '../di/injection.dart';
import 'route_names.dart';

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

      // If logged in and on login/register page, redirect to dashboard
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
        builder: (context, state) => const SplashPage(),
      ),

      // Authentication Routes
      GoRoute(
        path: RouteNames.login,
        name: 'login',
        builder: (context, state) => const LoginPage(),
      ),
      GoRoute(
        path: RouteNames.register,
        name: 'register',
        builder: (context, state) => const RegisterPage(),
      ),

      // Patient Routes
      GoRoute(
        path: RouteNames.patientDashboard,
        name: 'patient-dashboard',
        builder: (context, state) => const PatientDashboardPage(),
        routes: [
          GoRoute(
            path: 'profile',
            name: 'patient-profile',
            builder: (context, state) => const PatientProfilePage(),
          ),
          GoRoute(
            path: 'consultations',
            name: 'patient-consultations',
            builder: (context, state) => const ConsultationsListPage(),
            routes: [
              GoRoute(
                path: ':id',
                name: 'consultation-detail',
                builder: (context, state) {
                  final consultationId = state.pathParameters['id']!;
                  return ConsultationPage(consultationId: consultationId);
                },
              ),
            ],
          ),
          GoRoute(
            path: 'medications',
            name: 'patient-medications',
            builder: (context, state) => const MedicationPage(),
          ),
          GoRoute(
            path: 'emergency',
            name: 'emergency',
            builder: (context, state) => const EmergencyPage(),
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
        builder: (context, state) => const AIFeaturesPage(),
        routes: [
          GoRoute(
            path: 'diagnosis',
            name: 'ai-diagnosis',
            builder: (context, state) => const AIDiagnosisPage(),
          ),
          GoRoute(
            path: 'image-analysis',
            name: 'ai-image-analysis',
            builder: (context, state) => const AIImageAnalysisPage(),
          ),
          GoRoute(
            path: 'voice-analysis',
            name: 'ai-voice-analysis',
            builder: (context, state) => const AIVoiceAnalysisPage(),
          ),
        ],
      ),

      // Settings Routes
      GoRoute(
        path: '/settings',
        name: 'settings',
        builder: (context, state) => const SettingsPage(),
        routes: [
          GoRoute(
            path: 'profile',
            name: 'settings-profile',
            builder: (context, state) => const ProfileSettingsPage(),
          ),
          GoRoute(
            path: 'notifications',
            name: 'settings-notifications',
            builder: (context, state) => const NotificationSettingsPage(),
          ),
          GoRoute(
            path: 'privacy',
            name: 'settings-privacy',
            builder: (context, state) => const PrivacySettingsPage(),
          ),
        ],
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

class AIFeaturesPage extends StatelessWidget {
  const AIFeaturesPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('AI Features')),
      body: const Center(
        child: Text('AI Features Page'),
      ),
    );
  }
}

class AIDiagnosisPage extends StatelessWidget {
  const AIDiagnosisPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('AI Diagnosis')),
      body: const Center(
        child: Text('AI Diagnosis Page'),
      ),
    );
  }
}

class AIImageAnalysisPage extends StatelessWidget {
  const AIImageAnalysisPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('AI Image Analysis')),
      body: const Center(
        child: Text('AI Image Analysis Page'),
      ),
    );
  }
}

class AIVoiceAnalysisPage extends StatelessWidget {
  const AIVoiceAnalysisPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('AI Voice Analysis')),
      body: const Center(
        child: Text('AI Voice Analysis Page'),
      ),
    );
  }
}

class SettingsPage extends StatelessWidget {
  const SettingsPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Settings')),
      body: const Center(
        child: Text('Settings Page'),
      ),
    );
  }
}

class ProfileSettingsPage extends StatelessWidget {
  const ProfileSettingsPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Profile Settings')),
      body: const Center(
        child: Text('Profile Settings Page'),
      ),
    );
  }
}

class NotificationSettingsPage extends StatelessWidget {
  const NotificationSettingsPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Notification Settings')),
      body: const Center(
        child: Text('Notification Settings Page'),
      ),
    );
  }
}

class PrivacySettingsPage extends StatelessWidget {
  const PrivacySettingsPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Privacy Settings')),
      body: const Center(
        child: Text('Privacy Settings Page'),
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
