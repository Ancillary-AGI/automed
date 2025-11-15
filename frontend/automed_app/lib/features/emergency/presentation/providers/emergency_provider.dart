import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:geolocator/geolocator.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

class EmergencyContact {
  final String id;
  final String name;
  final String phone;
  final String relationship;

  EmergencyContact({
    required this.id,
    required this.name,
    required this.phone,
    required this.relationship,
  });
}

class EmergencyState {
  final bool isActive;
  final String status;
  final Position? location;
  final List<EmergencyContact> emergencyContacts;
  final String? emergencyId;
  final DateTime? triggeredAt;
  final String? message;

  EmergencyState({
    this.isActive = false,
    this.status = 'idle',
    this.location,
    this.emergencyContacts = const [],
    this.emergencyId,
    this.triggeredAt,
    this.message,
  });

  EmergencyState copyWith({
    bool? isActive,
    String? status,
    Position? location,
    List<EmergencyContact>? emergencyContacts,
    String? emergencyId,
    DateTime? triggeredAt,
    String? message,
  }) {
    return EmergencyState(
      isActive: isActive ?? this.isActive,
      status: status ?? this.status,
      location: location ?? this.location,
      emergencyContacts: emergencyContacts ?? this.emergencyContacts,
      emergencyId: emergencyId ?? this.emergencyId,
      triggeredAt: triggeredAt ?? this.triggeredAt,
      message: message ?? this.message,
    );
  }
}

class EmergencyNotifier extends StateNotifier<EmergencyState> {
  static const String _baseUrl = 'http://localhost:8080/api/v1';

  EmergencyNotifier() : super(EmergencyState()) {
    _loadEmergencyContacts();
  }

  void _loadEmergencyContacts() {
    // Load default emergency contacts
    final defaultContacts = _getDefaultContacts();
    state = state.copyWith(emergencyContacts: defaultContacts);
  }

  List<EmergencyContact> _getDefaultContacts() {
    return [
      EmergencyContact(
        id: '1',
        name: 'Emergency Services',
        phone: '911',
        relationship: 'Emergency',
      ),
      EmergencyContact(
        id: '2',
        name: 'Poison Control',
        phone: '1-800-222-1222',
        relationship: 'Medical',
      ),
    ];
  }

  Future<void> triggerEmergency(
      {Position? location, String? customMessage}) async {
    try {
      state = state.copyWith(status: 'requesting_permissions');

      // Request location permission if not provided
      Position? currentLocation = location;
      if (currentLocation == null) {
        final permission = await Permission.location.request();
        if (permission.isGranted) {
          currentLocation = await Geolocator.getCurrentPosition(
            desiredAccuracy: LocationAccuracy.high,
          );
        }
      }

      state = state.copyWith(status: 'triggering');

      // Prepare emergency data
      final emergencyData = {
        'location': currentLocation != null
            ? {
                'latitude': currentLocation.latitude,
                'longitude': currentLocation.longitude,
              }
            : null,
        'message': customMessage ?? 'Medical emergency triggered',
        'triggeredAt': DateTime.now().toIso8601String(),
      };

      // Call emergency API
      final response = await http.post(
        Uri.parse('$_baseUrl/emergency/alert'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode(emergencyData),
      );

      if (response.statusCode == 200 || response.statusCode == 201) {
        final responseData = jsonDecode(response.body);
        final emergencyId = responseData['emergencyId'] ??
            'emergency_${DateTime.now().millisecondsSinceEpoch}';

        // Notify emergency contacts
        await _notifyEmergencyContacts(
            emergencyId, currentLocation, customMessage);

        state = state.copyWith(
          isActive: true,
          status: 'active',
          location: currentLocation,
          emergencyId: emergencyId,
          triggeredAt: DateTime.now(),
          message: customMessage ?? 'Medical emergency triggered',
        );
      } else {
        throw Exception('Failed to trigger emergency: ${response.statusCode}');
      }
    } catch (e) {
      state = state.copyWith(
        status: 'error',
        message: 'Failed to trigger emergency: ${e.toString()}',
      );
    }
  }

  Future<void> _notifyEmergencyContacts(
      String emergencyId, Position? location, String? message) async {
    // Simulate notification delay
    await Future.delayed(const Duration(milliseconds: 500));
    // In a real implementation, this would send SMS/calls to contacts
  }

  Future<void> cancelEmergency() async {
    if (!state.isActive || state.emergencyId == null) return;

    try {
      state = state.copyWith(status: 'cancelling');

      // Call cancel emergency API
      final response = await http.put(
        Uri.parse('$_baseUrl/emergency/alert/${state.emergencyId}/cancel'),
        headers: {'Content-Type': 'application/json'},
      );

      if (response.statusCode == 200) {
        state = state.copyWith(
          isActive: false,
          status: 'cancelled',
          emergencyId: null,
          triggeredAt: null,
          message: null,
        );
      } else {
        throw Exception('Failed to cancel emergency: ${response.statusCode}');
      }
    } catch (e) {
      state = state.copyWith(
        status: 'error',
        message: 'Failed to cancel emergency: ${e.toString()}',
      );
    }
  }

  void addEmergencyContact(EmergencyContact contact) {
    state = state.copyWith(
      emergencyContacts: [...state.emergencyContacts, contact],
    );
  }

  void removeEmergencyContact(String contactId) {
    state = state.copyWith(
      emergencyContacts:
          state.emergencyContacts.where((c) => c.id != contactId).toList(),
    );
  }

  void updateEmergencyContact(EmergencyContact contact) {
    state = state.copyWith(
      emergencyContacts: state.emergencyContacts
          .map((c) => c.id == contact.id ? contact : c)
          .toList(),
    );
  }
}

final emergencyProvider =
    StateNotifierProvider<EmergencyNotifier, EmergencyState>((ref) {
  return EmergencyNotifier();
});
