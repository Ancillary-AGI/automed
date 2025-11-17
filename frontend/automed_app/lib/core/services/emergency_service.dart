import 'dart:io';
import 'package:flutter_phone_direct_caller/flutter_phone_direct_caller.dart';
import 'package:automed_app/core/utils/logger.dart';

/// Emergency service for handling critical situations and emergency calls
class EmergencyService {
  static final EmergencyService _instance = EmergencyService._internal();
  factory EmergencyService() => _instance;
  EmergencyService._internal();

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

  /// Send emergency alert (simplified - would send SMS/push in real app)
  Future<void> sendEmergencyAlert(String message) async {
    try {
      Logger.warning('Emergency alert: $message');
      // In a real implementation, this would send SMS or push notifications
    } catch (e) {
      Logger.error('Failed to send emergency alert: $e');
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
      await sendEmergencyAlert('CRITICAL: Abnormal vital signs detected!');
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
