import 'package:dio/dio.dart';

import '../../core/config/app_config.dart';

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

  Future<Map<String, dynamic>> getPatient(String patientId) async {
    return get('/patients/$patientId');
  }

  Future<Map<String, dynamic>> createPatient(Map<String, dynamic> patientData) async {
    return post('/patients', data: patientData);
  }

  Future<Map<String, dynamic>> updatePatient(String patientId, Map<String, dynamic> patientData) async {
    return put('/patients/$patientId', data: patientData);
  }

  // Consultation endpoints
  Future<Map<String, dynamic>> getConsultations() async {
    return get('/consultations');
  }

  Future<Map<String, dynamic>> createConsultation(Map<String, dynamic> consultationData) async {
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
  Future<Map<String, dynamic>> analyzeSymptoms(Map<String, dynamic> symptomsData) async {
    return post('/ai/analyze-symptoms', data: symptomsData);
  }

  Future<Map<String, dynamic>> predictDiagnosis(Map<String, dynamic> diagnosisData) async {
    return post('/ai/predict-diagnosis', data: diagnosisData);
  }

  // Emergency endpoints
  Future<Map<String, dynamic>> createEmergencyAlert(Map<String, dynamic> emergencyData) async {
    return post('/emergency/alert', data: emergencyData);
  }

  // Medication endpoints
  Future<Map<String, dynamic>> getMedications() async {
    return get('/medications');
  }

  Future<Map<String, dynamic>> createMedication(Map<String, dynamic> medicationData) async {
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
}