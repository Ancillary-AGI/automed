import 'dart:io';
import 'package:flutter_phone_direct_caller/flutter_phone_direct_caller.dart';
import 'package:automed_app/core/utils/logger.dart';
import 'package:automed_app/core/services/api_service.dart';
import 'package:geolocator/geolocator.dart';

enum EmergencyType {
  cardiacArrest,
  heartAttack,
  stroke,
  respiratory_distress,
  severe_bleeding,
  unconsciousness,
  seizure,
  diabetic_emergency,
  allergic_reaction,
  trauma,
  poisoning,
  mental_health_crisis,
  fire,
  accident,
  other
}

/// Emergency service for handling critical situations and emergency calls
class EmergencyService {
  static EmergencyService? _instance;
  factory EmergencyService(ApiService apiService) {
    _instance ??= EmergencyService._internal(apiService);
    return _instance!;
  }
  EmergencyService._internal(this._apiService);

  final ApiService _apiService;
  final List<EmergencyContact> _emergencyContacts = [
    EmergencyContact(
      id: '1',
      name: 'Emergency Services',
      phoneNumber: '911',
      relationship: 'Emergency',
      isPrimary: true,
    ),
  ];

  final EmergencySettings _settings = EmergencySettings();

  bool _isInitialized = false;

  /// Initialize emergency service
  Future<void> initialize() async {
    if (_isInitialized) return;

    try {
      _isInitialized = true;
      Logger.info('Emergency service initialized successfully');
    } catch (e) {
      Logger.error('Failed to initialize emergency service: $e');
    }
  }

  /// Call emergency services
  Future<bool> callEmergencyServices() async {
    try {
      final emergencyNumber = _getEmergencyNumber();
      final success =
          await FlutterPhoneDirectCaller.callNumber(emergencyNumber) ?? false;

      if (success) {
        Logger.info('Emergency call initiated to $emergencyNumber');
      }

      return success;
    } catch (e) {
      Logger.error('Failed to call emergency services: $e');
      return false;
    }
  }

  /// Call specific emergency contact
  Future<bool> callEmergencyContact(String contactId) async {
    try {
      final contact = _emergencyContacts.firstWhere(
        (c) => c.id == contactId,
        orElse: () => throw Exception('Contact not found'),
      );

      final success =
          await FlutterPhoneDirectCaller.callNumber(contact.phoneNumber) ??
              false;

      if (success) {
        Logger.info('Emergency contact call initiated to ${contact.name}');
      }

      return success;
    } catch (e) {
      Logger.error('Failed to call emergency contact: $e');
      return false;
    }
  }

  /// Send emergency alert to backend service
  Future<bool> sendEmergencyAlert({
    required EmergencyType type,
    required String location,
    required String description,
    String? patientId,
    int? severity,
  }) async {
    try {
      final request = {
        'type': type.toString().split('.').last.toUpperCase(),
        'location': location,
        'description': description,
        'reportedBy': 'patient_app', // TODO: Get from auth service
        'patientId': patientId,
        'severity': severity,
      };

      final response =
          await _apiService.post('/emergency/alert', data: request);
      Logger.warning('Emergency alert sent: $description');
      return response != null;
    } catch (e) {
      Logger.error('Failed to send emergency alert: $e');
      return false;
    }
  }

  /// Update emergency location
  Future<bool> updateEmergencyLocation(Position position) async {
    try {
      final request = {
        'latitude': position.latitude,
        'longitude': position.longitude,
        'timestamp': DateTime.now().toIso8601String(),
        'accuracy': position.accuracy,
        'speed': position.speed,
        'altitude': position.altitude,
        'heading': position.heading,
        'userId': 'current_user', // TODO: Get from auth service
      };

      final response =
          await _apiService.post('/emergency/location/update', data: request);
      return response != null;
    } catch (e) {
      Logger.error('Failed to update emergency location: $e');
      return false;
    }
  }

  /// Get all emergency contacts
  List<EmergencyContact> getEmergencyContacts() {
    return List.unmodifiable(_emergencyContacts);
  }

  /// Check if emergency mode is active
  bool isEmergencyModeActive() {
    return _settings.autoEmergencyEnabled;
  }

  /// Trigger emergency response based on vital signs
  Future<void> triggerVitalEmergency(VitalEmergencyData data) async {
    if (!isEmergencyModeActive()) return;

    if (_isEmergencyVitals(data)) {
      Logger.warning('Emergency triggered by vital signs');

      // Determine emergency type based on vitals
      EmergencyType emergencyType = EmergencyType.other;
      if (data.isCardiacArrest) {
        emergencyType = EmergencyType.cardiacArrest;
      } else if (data.heartRate < 40 || data.heartRate > 150) {
        emergencyType = EmergencyType.heartAttack;
      } else if (data.oxygenSaturation < 90) {
        emergencyType = EmergencyType.respiratory_distress;
      }

      await sendEmergencyAlert(
        type: emergencyType,
        location: 'Current location', // TODO: Get actual location
        description:
            'CRITICAL: Abnormal vital signs detected! Heart rate: ${data.heartRate}, Oxygen: ${data.oxygenSaturation}%',
        severity: 10,
      );
      await callEmergencyServices();
    }
  }

  // Private helper methods

  String _getEmergencyNumber() {
    if (Platform.isAndroid || Platform.isIOS) {
      return '911'; // US emergency
    }
    return '112'; // European emergency fallback
  }

  bool _isEmergencyVitals(VitalEmergencyData data) {
    return data.heartRate < 40 ||
        data.heartRate > 150 ||
        data.oxygenSaturation < 90 ||
        data.isCardiacArrest ||
        data.isSeverePain;
  }
}

// Data classes
class EmergencyContact {
  final String id;
  final String name;
  final String phoneNumber;
  final String relationship;
  final bool isPrimary;

  EmergencyContact({
    required this.id,
    required this.name,
    required this.phoneNumber,
    required this.relationship,
    this.isPrimary = false,
  });

  Map<String, dynamic> toJson() => {
        'id': id,
        'name': name,
        'phoneNumber': phoneNumber,
        'relationship': relationship,
        'isPrimary': isPrimary,
      };

  factory EmergencyContact.fromJson(Map<String, dynamic> json) {
    return EmergencyContact(
      id: json['id'],
      name: json['name'],
      phoneNumber: json['phoneNumber'],
      relationship: json['relationship'],
      isPrimary: json['isPrimary'] ?? false,
    );
  }
}

class EmergencySettings {
  final bool autoEmergencyEnabled;

  EmergencySettings({
    this.autoEmergencyEnabled = true,
  });

  Map<String, dynamic> toJson() => {
        'autoEmergencyEnabled': autoEmergencyEnabled,
      };

  factory EmergencySettings.fromJson(Map<String, dynamic> json) {
    return EmergencySettings(
      autoEmergencyEnabled: json['autoEmergencyEnabled'] ?? true,
    );
  }
}

class VitalEmergencyData {
  final double heartRate;
  final double oxygenSaturation;
  final bool isCardiacArrest;
  final bool isSeverePain;
  final bool isUnconscious;

  VitalEmergencyData({
    required this.heartRate,
    required this.oxygenSaturation,
    this.isCardiacArrest = false,
    this.isSeverePain = false,
    this.isUnconscious = false,
  });
}
