import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:automed_app/core/di/injection.dart';
import '../models/patient_dashboard_model.dart';

final patientDashboardProvider =
    FutureProvider<PatientDashboardModel>((ref) async {
  final apiService = ref.watch(apiServiceProvider);

  try {
    final resp = await apiService.getTyped<PatientDashboardModel>(
      '/patients/dashboard',
      (json) => PatientDashboardModel.fromJson(json as Map<String, dynamic>),
    );

    if (resp.success && resp.data != null) {
      return resp.data!;
    }

    // Log and surface a friendly error
    // ignore: avoid_print
    print(
        '[ERROR] [patientDashboardProvider] API returned error: ${resp.message}');
    throw Exception(resp.errorMessage);
  } catch (e, stack) {
    // Log error for semantic bug detection
    // ignore: avoid_print
    print(
        '[ERROR] [patientDashboardProvider] Failed to load dashboard data: $e\n$stack');
    // Provide user-friendly error message
    throw Exception(
        'Unable to load patient dashboard. Please check your connection or try again later.');
  }
});
