import 'package:dio/dio.dart';
import 'package:retrofit/retrofit.dart';

import '../models/api_response.dart';
import '../models/patient_models.dart';
import '../models/consultation_models.dart';
import '../models/ai_models.dart';

part 'api_service.g.dart';

@RestApi()
abstract class ApiService {
  factory ApiService(Dio dio, {String baseUrl}) = _ApiService;

  // Authentication endpoints
  @POST('/auth/login')
  Future<ApiResponse<AuthResponse>> login(@Body() LoginRequest request);

  @POST('/auth/register')
  Future<ApiResponse<AuthResponse>> register(@Body() RegisterRequest request);

  @POST('/auth/refresh')
  Future<ApiResponse<AuthResponse>> refreshToken(@Body() RefreshTokenRequest request);

  @POST('/auth/logout')
  Future<ApiResponse<void>> logout();

  // Patient endpoints
  @GET('/api/v1/patients')
  Future<ApiResponse<PaginatedResponse<Patient>>> getPatients(
    @Query('page') int page,
    @Query('size') int size,
    @Query('search') String? search,
  );

  @GET('/api/v1/patients/{id}')
  Future<ApiResponse<Patient>> getPatient(@Path('id') String id);

  @POST('/api/v1/patients')
  Future<ApiResponse<Patient>> createPatient(@Body() CreatePatientRequest request);

  @PUT('/api/v1/patients/{id}')
  Future<ApiResponse<Patient>> updatePatient(
    @Path('id') String id,
    @Body() UpdatePatientRequest request,
  );

  @DELETE('/api/v1/patients/{id}')
  Future<ApiResponse<void>> deletePatient(@Path('id') String id);

  @GET('/api/v1/patients/{id}/medical-history')
  Future<ApiResponse<List<MedicalRecord>>> getMedicalHistory(@Path('id') String id);

  // Consultation endpoints
  @GET('/api/v1/consultations')
  Future<ApiResponse<PaginatedResponse<Consultation>>> getConsultations(
    @Query('page') int page,
    @Query('size') int size,
    @Query('status') String? status,
  );

  @GET('/api/v1/consultations/{id}')
  Future<ApiResponse<Consultation>> getConsultation(@Path('id') String id);

  @POST('/api/v1/consultations')
  Future<ApiResponse<Consultation>> createConsultation(@Body() CreateConsultationRequest request);

  @PUT('/api/v1/consultations/{id}')
  Future<ApiResponse<Consultation>> updateConsultation(
    @Path('id') String id,
    @Body() UpdateConsultationRequest request,
  );

  @POST('/api/v1/consultations/{id}/start')
  Future<ApiResponse<ConsultationSession>> startConsultation(@Path('id') String id);

  @POST('/api/v1/consultations/{id}/end')
  Future<ApiResponse<void>> endConsultation(@Path('id') String id);

  @POST('/api/v1/consultations/{id}/join')
  Future<ApiResponse<ConsultationSession>> joinConsultation(@Path('id') String id);

  // Hospital endpoints
  @GET('/api/v1/hospitals')
  Future<ApiResponse<PaginatedResponse<Hospital>>> getHospitals(
    @Query('page') int page,
    @Query('size') int size,
    @Query('search') String? search,
  );

  @GET('/api/v1/hospitals/{id}')
  Future<ApiResponse<Hospital>> getHospital(@Path('id') String id);

  @GET('/api/v1/hospitals/{id}/staff')
  Future<ApiResponse<List<Staff>>> getHospitalStaff(@Path('id') String id);

  @GET('/api/v1/hospitals/{id}/equipment')
  Future<ApiResponse<List<Equipment>>> getHospitalEquipment(@Path('id') String id);

  // AI Service endpoints
  @POST('/api/v1/ai/predict-diagnosis')
  Future<ApiResponse<DiagnosisPrediction>> predictDiagnosis(@Body() DiagnosisRequest request);

  @POST('/api/v1/ai/analyze-symptoms')
  Future<ApiResponse<SymptomAnalysis>> analyzeSymptoms(@Body() SymptomAnalysisRequest request);

  @POST('/api/v1/ai/triage')
  Future<ApiResponse<TriageResult>> performTriage(@Body() TriageRequest request);

  @POST('/api/v1/ai/analyze-medical-image')
  Future<ApiResponse<ImageAnalysisResult>> analyzeMedicalImage(@Body() ImageAnalysisRequest request);

  @POST('/api/v1/ai/analyze-wearable-data')
  Future<ApiResponse<WearableAnalysisResult>> analyzeWearableData(@Body() WearableDataRequest request);

  @POST('/api/v1/ai/analyze-voice')
  Future<ApiResponse<VoiceAnalysisResult>> analyzeVoice(@Body() VoiceAnalysisRequest request);

  @POST('/api/v1/ai/population-health')
  Future<ApiResponse<PopulationHealthAnalysis>> analyzePopulationHealth(@Body() PopulationHealthRequest request);

  @POST('/api/v1/ai/detect-outbreak')
  Future<ApiResponse<OutbreakDetection>> detectOutbreak(@Body() OutbreakDetectionRequest request);

  @GET('/api/v1/ai/models')
  Future<ApiResponse<List<AIModel>>> getAvailableModels();

  // Sync endpoints
  @POST('/api/v1/sync/upload')
  Future<ApiResponse<SyncResult>> uploadOfflineData(@Body() OfflineDataUpload request);

  @GET('/api/v1/sync/download/{deviceId}')
  Future<ApiResponse<SyncData>> downloadUpdates(@Path('deviceId') String deviceId);

  @POST('/api/v1/sync/resolve-conflicts')
  Future<ApiResponse<ConflictResolution>> resolveConflicts(@Body() ConflictResolutionRequest request);

  @POST('/api/v1/sync/heartbeat')
  Future<ApiResponse<void>> sendHeartbeat(@Body() HeartbeatRequest request);

  // Medication endpoints
  @GET('/api/v1/medications')
  Future<ApiResponse<PaginatedResponse<Medication>>> getMedications(
    @Query('page') int page,
    @Query('size') int size,
    @Query('patientId') String? patientId,
  );

  @POST('/api/v1/medications')
  Future<ApiResponse<Medication>> createMedication(@Body() CreateMedicationRequest request);

  @PUT('/api/v1/medications/{id}')
  Future<ApiResponse<Medication>> updateMedication(
    @Path('id') String id,
    @Body() UpdateMedicationRequest request,
  );

  @POST('/api/v1/medications/{id}/take')
  Future<ApiResponse<MedicationLog>> takeMedication(@Path('id') String id);

  // Emergency endpoints
  @POST('/api/v1/emergency/alert')
  Future<ApiResponse<EmergencyAlert>> createEmergencyAlert(@Body() EmergencyAlertRequest request);

  @GET('/api/v1/emergency/alerts')
  Future<ApiResponse<List<EmergencyAlert>>> getEmergencyAlerts();

  @PUT('/api/v1/emergency/alerts/{id}/respond')
  Future<ApiResponse<void>> respondToEmergencyAlert(
    @Path('id') String id,
    @Body() EmergencyResponse response,
  );

  // File upload endpoints
  @POST('/api/v1/files/upload')
  @MultiPart()
  Future<ApiResponse<FileUploadResult>> uploadFile(@Part() MultipartFile file);

  @GET('/api/v1/files/{id}')
  Future<HttpResponse<ResponseBody>> downloadFile(@Path('id') String id);
}