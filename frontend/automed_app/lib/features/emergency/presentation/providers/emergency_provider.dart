import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:geolocator/geolocator.dart';

class EmergencyState {
  final bool isActive;
  final String status;
  final Position? location;

  EmergencyState({
    this.isActive = false,
    this.status = 'idle',
    this.location,
  });

  EmergencyState copyWith({
    bool? isActive,
    String? status,
    Position? location,
  }) {
    return EmergencyState(
      isActive: isActive ?? this.isActive,
      status: status ?? this.status,
      location: location ?? this.location,
    );
  }
}

class EmergencyNotifier extends StateNotifier<EmergencyState> {
  EmergencyNotifier() : super(EmergencyState());

  Future<void> triggerEmergency({Position? location}) async {
    // TODO: Implement emergency triggering logic
    state = state.copyWith(
      isActive: true,
      status: 'active',
      location: location,
    );
  }

  void cancelEmergency() {
    // TODO: Implement emergency cancellation logic
    state = state.copyWith(
      isActive: false,
      status: 'cancelled',
    );
  }
}

final emergencyProvider =
    StateNotifierProvider<EmergencyNotifier, EmergencyState>((ref) {
  return EmergencyNotifier();
});
