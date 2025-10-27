import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:dio/dio.dart';

import '../services/api_service.dart';
import '../models/patient_models.dart';
import '../models/hospital_models.dart';
import '../models/consultation_models.dart';
import '../models/ai_models.dart';
import '../models/medication_models.dart';

// Healthcare Ecosystem State
class HealthcareEcosystemState {
  final List<Patient> patients;
  final List<Hospital> hospitals;
  final List<Consultation> consultations;
  final List<Medication> medications;
  final List<EmergencyAlert> emergencyAlerts;
  final bool isLoading;
  final String? error;

  const HealthcareEcosystemState({
    this.patients = const [],
    this.hospitals = const [],
    this.consultations = const [],
    this.medications = const [],
    this.emergencyAlerts = const [],
    this.isLoading = false,
    this.error,
  });

  HealthcareEcosystemState copyWith({
    List<Patient>? patients,
    List<Hospital>? hospitals,
    List<Consultation>? consultations,
    List<Medication>? medications,
    List<EmergencyAlert>? emergencyAlerts,
    bool? isLoading,
    String? error,
  }) {
    return HealthcareEcosystemState(
      patients: patients ?? this.patients,
      hospitals: hospitals ?? this.hospitals,
      consultations: consultations ?? this.consultations,
      medications: medications ?? this.medications,
      emergencyAlerts: emergencyAlerts ?? this.emergencyAlerts,
      isLoading: isLoading ?? this.isLoading,
      error: error ?? this.error,
    );
  }
}

// Healthcare Ecosystem Provider
class HealthcareEcosystemNotifier extends StateNotifier<HealthcareEcosystemState> {
  final ApiService _apiService;

  HealthcareEcosystemNotifier(this._apiService) : super(const HealthcareEcosystemState());

  // Load all healthcare data
  Future<void> loadHealthcareData() async {
    state = state.copyWith(isLoading: true, error: null);
    
    try {
      // Load data in parallel
      final futures = await Future.wait([
        _loadPatients(),
        _loadHospitals(),
        _loadConsultations(),
        _loadMedications(),
        _loadEmergencyAlerts(),
      ]);

      state = state.copyWith(
        patients: futures[0] as List<Patient>,
        hospitals: futures[1] as List<Hospital>,
        consultations: futures[2] as List<Consultation>,
        medications: futures[3] as List<Medication>,
        emergencyAlerts: futures[4] as List<EmergencyAlert>,
        isLoading: false,
      );
    } catch (e) {
      state = state.copyWith(
        isLoading: false,
        error: e.toString(),
      );
    }
  }

  // Load patients
  Future<List<Patient>> _loadPatients() async {
    try {
      final response = await _apiService.getPatients(0, 100, null);
      if (response.success && response.data != null) {
        return response.data!.content;
      }
      return [];
    } catch (e) {
      return [];
    }
  }

  // Load hospitals
  Future<List<Hospital>> _loadHospitals() async {
    try {
      final response = await _apiService.getHospitals(0, 100, null);
      if (response.success && response.data != null) {
        return response.data!.content;
      }
      return [];
    } catch (e) {
      return [];
    }
  }

  // Load consultations
  Future<List<Consultation>> _loadConsultations() async {
    try {
      final response = await _apiService.getConsultations(0, 100, null);
      if (response.success && response.data != null) {
        return response.data!.content;
      }
      return [];
    } catch (e) {
      return [];
    }
  }

  // Load medications
  Future<List<Medication>> _loadMedications() async {
    try {
      final response = await _apiService.getMedications(0, 100, null);
      if (response.success && response.data != null) {
        return response.data!.content;
      }
      return [];
    } catch (e) {
      return [];
    }
  }

  // Load emergency alerts
  Future<List<EmergencyAlert>> _loadEmergencyAlerts() async {
    try {
      final response = await _apiService.getEmergencyAlerts();
      if (response.success && response.data != null) {
        return response.data!;
      }
      return [];
    } catch (e) {
      return [];
    }
  }

  // Create new patient
  Future<void> createPatient(CreatePatientRequest request) async {
    try {
      final response = await _apiService.createPatient(request);
      if (response.success && response.data != null) {
        state = state.copyWith(
          patients: [...state.patients, response.data!],
        );
      }
    } catch (e) {
      state = state.copyWith(error: e.toString());
    }
  }

  // Update patient
  Future<void> updatePatient(String id, UpdatePatientRequest request) async {
    try {
      final response = await _apiService.updatePatient(id, request);
      if (response.success && response.data != null) {
        final updatedPatients = state.patients.map((patient) {
          return patient.id == id ? response.data! : patient;
        }).toList();
        
        state = state.copyWith(patients: updatedPatients);
      }
    } catch (e) {
      state = state.copyWith(error: e.toString());
    }
  }

  // Create consultation
  Future<void> createConsultation(CreateConsultationRequest request) async {
    try {
      final response = await _apiService.createConsultation(request);
      if (response.success && response.data != null) {
        state = state.copyWith(
          consultations: [...state.consultations, response.data!],
        );
      }
    } catch (e) {
      state = state.copyWith(error: e.toString());
    }
  }

  // Create medication
  Future<void> createMedication(CreateMedicationRequest request) async {
    try {
      final response = await _apiService.createMedication(request);
      if (response.success && response.data != null) {
        state = state.copyWith(
          medications: [...state.medications, response.data!],
        );
      }
    } catch (e) {
      state = state.copyWith(error: e.toString());
    }
  }

  // Create emergency alert
  Future<void> createEmergencyAlert(EmergencyAlertRequest request) async {
    try {
      final response = await _apiService.createEmergencyAlert(request);
      if (response.success && response.data != null) {
        state = state.copyWith(
          emergencyAlerts: [...state.emergencyAlerts, response.data!],
        );
      }
    } catch (e) {
      state = state.copyWith(error: e.toString());
    }
  }

  // Refresh data
  Future<void> refresh() async {
    await loadHealthcareData();
  }

  // Clear error
  void clearError() {
    state = state.copyWith(error: null);
  }
}

// Provider
final healthcareEcosystemProvider = StateNotifierProvider<HealthcareEcosystemNotifier, HealthcareEcosystemState>((ref) {
  final apiService = ref.watch(apiServiceProvider);
  return HealthcareEcosystemNotifier(apiService);
});

// Individual providers for specific data
final patientsProvider = Provider<List<Patient>>((ref) {
  return ref.watch(healthcareEcosystemProvider).patients;
});

final hospitalsProvider = Provider<List<Hospital>>((ref) {
  return ref.watch(healthcareEcosystemProvider).hospitals;
});

final consultationsProvider = Provider<List<Consultation>>((ref) {
  return ref.watch(healthcareEcosystemProvider).consultations;
});

final medicationsProvider = Provider<List<Medication>>((ref) {
  return ref.watch(healthcareEcosystemProvider).medications;
});

final emergencyAlertsProvider = Provider<List<EmergencyAlert>>((ref) {
  return ref.watch(healthcareEcosystemProvider).emergencyAlerts;
});

// Loading state provider
final isLoadingProvider = Provider<bool>((ref) {
  return ref.watch(healthcareEcosystemProvider).isLoading;
});

// Error provider
final errorProvider = Provider<String?>((ref) {
  return ref.watch(healthcareEcosystemProvider).error;
});