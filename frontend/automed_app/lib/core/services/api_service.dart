import 'package:dio/dio.dart';

import 'package:automed_app/core/config/app_config.dart';
import 'package:automed_app/core/models/api_response.dart';

class ApiService {
  final Dio dio;
  final AppConfig appConfig;

  ApiService({
    required this.dio,
    required this.appConfig,
  }) {
    _configureDio();
  }

  void _configureDio() {
    dio.options.baseUrl = appConfig.apiBaseUrl;
    dio.options.headers = {
      'Content-Type': 'application/json',
      'Accept': 'application/json',
    };

    // Add interceptors
    dio.interceptors.addAll([
      LogInterceptor(
        request: appConfig.enableLogging,
        requestHeader: appConfig.enableLogging,
        requestBody: appConfig.enableLogging,
        responseHeader: appConfig.enableLogging,
        responseBody: appConfig.enableLogging,
        error: true,
      ),
    ]);
  }

  // Generic GET request
  Future<Map<String, dynamic>> get(String endpoint) async {
    try {
      final response = await dio.get(endpoint);
      return response.data;
    } catch (e) {
      throw _handleError(e);
    }
  }

  // Generic POST request
  Future<Map<String, dynamic>> post(String endpoint, {dynamic data}) async {
    try {
      final response = await dio.post(endpoint, data: data);
      return response.data;
    } catch (e) {
      throw _handleError(e);
    }
  }

  // Generic PUT request
  Future<Map<String, dynamic>> put(String endpoint, {dynamic data}) async {
    try {
      final response = await dio.put(endpoint, data: data);
      return response.data;
    } catch (e) {
      throw _handleError(e);
    }
  }

  // Generic DELETE request
  Future<Map<String, dynamic>> delete(String endpoint) async {
    try {
      final response = await dio.delete(endpoint);
      return response.data;
    } catch (e) {
      throw _handleError(e);
    }
  }

  // Handle errors
  Exception _handleError(dynamic error) {
    if (error is DioException) {
      switch (error.type) {
        case DioExceptionType.connectionTimeout:
        case DioExceptionType.sendTimeout:
        case DioExceptionType.receiveTimeout:
          return Exception('Connection timeout');
        case DioExceptionType.badResponse:
          return Exception('Server error: ${error.response?.statusCode}');
        case DioExceptionType.cancel:
          return Exception('Request cancelled');
        default:
          return Exception('Network error');
      }
    }
    return Exception('Unknown error: $error');
  }

  // Patient endpoints
  Future<Map<String, dynamic>> getPatientDashboard() async {
    return get('/patients/dashboard');
  }

  // Typed GET that returns ApiResponse<T>
  Future<ApiResponse<T>> getTyped<T>(
      String endpoint, T Function(Object? json) fromJsonT) async {
    final raw = await get(endpoint);
    return ApiResponse<T>(
      success: raw['success'] ?? true,
      data: fromJsonT(raw['data'] ?? raw),
      message: raw['message'],
      statusCode: raw['statusCode'],
      timestamp: raw['timestamp'],
    );
  }

  Future<Map<String, dynamic>> getPatient(String patientId) async {
    return get('/patients/$patientId');
  }

  Future<Map<String, dynamic>> createPatient(
      Map<String, dynamic> patientData) async {
    return post('/patients', data: patientData);
  }

  Future<Map<String, dynamic>> updatePatient(
      String patientId, Map<String, dynamic> patientData) async {
    return put('/patients/$patientId', data: patientData);
  }

  // Consultation endpoints
  Future<Map<String, dynamic>> getConsultations() async {
    return get('/consultations');
  }

  Future<Map<String, dynamic>> createConsultation(
      Map<String, dynamic> consultationData) async {
    return post('/consultations', data: consultationData);
  }

  // Hospital endpoints
  Future<Map<String, dynamic>> getHospitals() async {
    return get('/hospitals');
  }

  Future<Map<String, dynamic>> getHospital(String hospitalId) async {
    return get('/hospitals/$hospitalId');
  }

  // AI endpoints
  Future<Map<String, dynamic>> analyzeSymptoms(
      Map<String, dynamic> symptomsData) async {
    return post('/ai/analyze-symptoms', data: symptomsData);
  }

  // Typed POST that returns ApiResponse<T>
  Future<ApiResponse<T>> postTyped<T>(String endpoint,
      {dynamic data, required T Function(Object? json) fromJsonT}) async {
    final raw = await post(endpoint, data: data);
    return ApiResponse<T>(
      success: raw['success'] ?? true,
      data: fromJsonT(raw['data'] ?? raw),
      message: raw['message'],
      statusCode: raw['statusCode'],
      timestamp: raw['timestamp'],
    );
  }

  Future<Map<String, dynamic>> predictDiagnosis(
      Map<String, dynamic> diagnosisData) async {
    return post('/ai/predict-diagnosis', data: diagnosisData);
  }

  // Emergency endpoints
  Future<Map<String, dynamic>> createEmergencyAlert(
      Map<String, dynamic> emergencyData) async {
    return post('/emergency/alert', data: emergencyData);
  }

  // Medication endpoints
  Future<Map<String, dynamic>> getMedications() async {
    return get('/medications');
  }

  Future<Map<String, dynamic>> createMedication(
      Map<String, dynamic> medicationData) async {
    return post('/medications', data: medicationData);
  }

  // Analytics endpoints
  Future<Map<String, dynamic>> getAnalytics() async {
    return get('/analytics');
  }

  // Sync endpoints
  Future<Map<String, dynamic>> syncData(Map<String, dynamic> syncData) async {
    return post('/sync', data: syncData);
  }

  // Additional methods needed by providers
  Future<Map<String, dynamic>> getPatients(
      int page, int limit, String? search) async {
    final queryParams = {
      'page': page.toString(),
      'limit': limit.toString(),
      if (search != null && search.isNotEmpty) 'search': search,
    };
    final queryString =
        queryParams.entries.map((e) => '${e.key}=${e.value}').join('&');
    return get('/patients?$queryString');
  }

  Future<Map<String, dynamic>> getEmergencyAlerts() async {
    return get('/emergency/alerts');
  }

  // Additional methods needed by providers
  Future<Map<String, dynamic>> getHospitalsPaginated(
      int page, int limit, String? search) async {
    final queryParams = {
      'page': page.toString(),
      'limit': limit.toString(),
      if (search != null && search.isNotEmpty) 'search': search,
    };
    final queryString =
        queryParams.entries.map((e) => '${e.key}=${e.value}').join('&');
    return get('/hospitals?$queryString');
  }

  Future<Map<String, dynamic>> getConsultationsPaginated(
      int page, int limit, String? search) async {
    final queryParams = {
      'page': page.toString(),
      'limit': limit.toString(),
      if (search != null && search.isNotEmpty) 'search': search,
    };
    final queryString =
        queryParams.entries.map((e) => '${e.key}=${e.value}').join('&');
    return get('/consultations?$queryString');
  }

  Future<Map<String, dynamic>> getMedicationsPaginated(
      int page, int limit, String? search) async {
    final queryParams = {
      'page': page.toString(),
      'limit': limit.toString(),
      if (search != null && search.isNotEmpty) 'search': search,
    };
    final queryString =
        queryParams.entries.map((e) => '${e.key}=${e.value}').join('&');
    return get('/medications?$queryString');
  }
}
