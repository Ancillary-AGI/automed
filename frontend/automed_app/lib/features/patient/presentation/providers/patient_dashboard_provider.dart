import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:dio/dio.dart';

import '../../../../core/config/app_config.dart';
import '../models/patient_dashboard_model.dart';

final patientDashboardProvider = FutureProvider<PatientDashboardModel>((
  ref,
) async {
  final dio = Dio();
  final appConfig = ref.watch(appConfigProvider);

  try {
    final response = await dio.get(
      '${appConfig.apiBaseUrl}/patients/dashboard',
    );
    return PatientDashboardModel.fromJson(response.data);
  } catch (e) {
    throw Exception('Failed to load dashboard data: $e');
  }
});
