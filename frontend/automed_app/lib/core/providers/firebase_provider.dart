import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import '../services/firebase_service.dart';
import '../di/injection.dart';

final firebaseNotificationProvider = StateNotifierProvider<
    FirebaseNotificationNotifier, FirebaseNotificationState>((ref) {
  return FirebaseNotificationNotifier(ref.read(firebaseServiceProvider));
});

class FirebaseNotificationNotifier
    extends StateNotifier<FirebaseNotificationState> {
  final FirebaseService _firebaseService;

  FirebaseNotificationNotifier(this._firebaseService)
      : super(const FirebaseNotificationState()) {
    _initialize();
  }

  Future<void> _initialize() async {
    if (_firebaseService.isInitialized) {
      await _setupNotificationHandlers();
      await _getFCMToken();
    }
  }

  Future<void> _setupNotificationHandlers() async {
    // Listen to foreground messages
    FirebaseMessaging.onMessage.listen((RemoteMessage message) {
      _handleNotification(message, NotificationContext.foreground);
    });

    // Listen to background messages
    FirebaseMessaging.onMessageOpenedApp.listen((RemoteMessage message) {
      _handleNotification(message, NotificationContext.background);
    });

    // Handle terminated app messages
    final initialMessage = await FirebaseMessaging.instance.getInitialMessage();
    if (initialMessage != null) {
      _handleNotification(initialMessage, NotificationContext.terminated);
    }
  }

  void _handleNotification(RemoteMessage message, NotificationContext context) {
    final notification =
        HealthcareNotification.fromRemoteMessage(message, context);

    state = state.copyWith(
      lastNotification: notification,
      notificationCount: state.notificationCount + 1,
      lastUpdated: DateTime.now(),
    );

    // Handle specific healthcare notification types
    _processHealthcareNotification(notification);
  }

  void _processHealthcareNotification(HealthcareNotification notification) {
    switch (notification.type) {
      case HealthcareNotificationType.criticalAlert:
        _handleCriticalAlert(notification);
        break;
      case HealthcareNotificationType.medicationReminder:
        _handleMedicationReminder(notification);
        break;
      case HealthcareNotificationType.appointmentReminder:
        _handleAppointmentReminder(notification);
        break;
      case HealthcareNotificationType.vitalSignsAlert:
        _handleVitalSignsAlert(notification);
        break;
      case HealthcareNotificationType.emergencyAlert:
        _handleEmergencyAlert(notification);
        break;
      case HealthcareNotificationType.labResults:
        _handleLabResults(notification);
        break;
      case HealthcareNotificationType.consultationRequest:
        _handleConsultationRequest(notification);
        break;
      case HealthcareNotificationType.general:
        // Handle general notifications
        break;
    }
  }

  void _handleCriticalAlert(HealthcareNotification notification) {
    // Log critical alert
    _firebaseService.logEvent('critical_alert_handled', parameters: {
      'patient_id': notification.patientId,
      'alert_type': notification.data['alert_type'],
      'severity': notification.data['severity'],
    });

    // Update state with critical alert
    state = state.copyWith(
      hasCriticalAlerts: true,
      criticalAlertCount: state.criticalAlertCount + 1,
    );
  }

  void _handleMedicationReminder(HealthcareNotification notification) {
    _firebaseService.logEvent('medication_reminder_handled', parameters: {
      'patient_id': notification.patientId,
      'medication': notification.data['medication'],
    });
  }

  void _handleAppointmentReminder(HealthcareNotification notification) {
    _firebaseService.logEvent('appointment_reminder_handled', parameters: {
      'patient_id': notification.patientId,
      'appointment_time': notification.data['appointment_time'],
    });
  }

  void _handleVitalSignsAlert(HealthcareNotification notification) {
    _firebaseService.logEvent('vital_signs_alert_handled', parameters: {
      'patient_id': notification.patientId,
      'vital_type': notification.data['vital_type'],
      'value': notification.data['value'],
    });
  }

  void _handleEmergencyAlert(HealthcareNotification notification) {
    _firebaseService.logEvent('emergency_alert_handled', parameters: {
      'patient_id': notification.patientId,
      'emergency_type': notification.data['emergency_type'],
      'location': notification.data['location'],
    });

    // Update state with emergency alert
    state = state.copyWith(
      hasEmergencyAlerts: true,
      emergencyAlertCount: state.emergencyAlertCount + 1,
    );
  }

  void _handleLabResults(HealthcareNotification notification) {
    _firebaseService.logEvent('lab_results_handled', parameters: {
      'patient_id': notification.patientId,
      'test_type': notification.data['test_type'],
    });
  }

  void _handleConsultationRequest(HealthcareNotification notification) {
    _firebaseService.logEvent('consultation_request_handled', parameters: {
      'patient_id': notification.patientId,
      'consultation_type': notification.data['consultation_type'],
    });
  }

  Future<void> _getFCMToken() async {
    try {
      final token = await _firebaseService.getFCMToken();
      if (token != null) {
        state = state.copyWith(fcmToken: token);

        // Send token to backend for user association
        await _sendTokenToBackend(token);
      }
    } catch (e) {
      _firebaseService.recordError(e, StackTrace.current);
    }
  }

  Future<void> _sendTokenToBackend(String token) async {
    // This would send the FCM token to your backend
    // so it can send targeted notifications to this device
    _firebaseService.logEvent('fcm_token_registered', parameters: {
      'token': token,
      'platform': 'flutter',
    });
  }

  // Public methods
  Future<void> subscribeToPatientNotifications(String patientId) async {
    await _firebaseService.subscribeToTopic('patient_$patientId');

    final currentPatients = Set<String>.from(state.subscribedPatients);
    currentPatients.add(patientId);

    state = state.copyWith(subscribedPatients: currentPatients);
  }

  Future<void> unsubscribeFromPatientNotifications(String patientId) async {
    await _firebaseService.unsubscribeFromTopic('patient_$patientId');

    final currentPatients = Set<String>.from(state.subscribedPatients);
    currentPatients.remove(patientId);

    state = state.copyWith(subscribedPatients: currentPatients);
  }

  Future<void> subscribeToHospitalNotifications(String hospitalId) async {
    await _firebaseService.subscribeToTopic('hospital_$hospitalId');

    final currentHospitals = Set<String>.from(state.subscribedHospitals);
    currentHospitals.add(hospitalId);

    state = state.copyWith(subscribedHospitals: currentHospitals);
  }

  Future<void> unsubscribeFromHospitalNotifications(String hospitalId) async {
    await _firebaseService.unsubscribeFromTopic('hospital_$hospitalId');

    final currentHospitals = Set<String>.from(state.subscribedHospitals);
    currentHospitals.remove(hospitalId);

    state = state.copyWith(subscribedHospitals: currentHospitals);
  }

  void clearCriticalAlerts() {
    state = state.copyWith(
      hasCriticalAlerts: false,
      criticalAlertCount: 0,
    );
  }

  void clearEmergencyAlerts() {
    state = state.copyWith(
      hasEmergencyAlerts: false,
      emergencyAlertCount: 0,
    );
  }

  void markNotificationAsRead(String notificationId) {
    final readNotifications = Set<String>.from(state.readNotifications);
    readNotifications.add(notificationId);

    state = state.copyWith(readNotifications: readNotifications);
  }
}

class FirebaseNotificationState {
  final HealthcareNotification? lastNotification;
  final int notificationCount;
  final int criticalAlertCount;
  final int emergencyAlertCount;
  final bool hasCriticalAlerts;
  final bool hasEmergencyAlerts;
  final String? fcmToken;
  final Set<String> subscribedPatients;
  final Set<String> subscribedHospitals;
  final Set<String> readNotifications;
  final DateTime? lastUpdated;

  const FirebaseNotificationState({
    this.lastNotification,
    this.notificationCount = 0,
    this.criticalAlertCount = 0,
    this.emergencyAlertCount = 0,
    this.hasCriticalAlerts = false,
    this.hasEmergencyAlerts = false,
    this.fcmToken,
    this.subscribedPatients = const {},
    this.subscribedHospitals = const {},
    this.readNotifications = const {},
    this.lastUpdated,
  });

  FirebaseNotificationState copyWith({
    HealthcareNotification? lastNotification,
    int? notificationCount,
    int? criticalAlertCount,
    int? emergencyAlertCount,
    bool? hasCriticalAlerts,
    bool? hasEmergencyAlerts,
    String? fcmToken,
    Set<String>? subscribedPatients,
    Set<String>? subscribedHospitals,
    Set<String>? readNotifications,
    DateTime? lastUpdated,
  }) {
    return FirebaseNotificationState(
      lastNotification: lastNotification ?? this.lastNotification,
      notificationCount: notificationCount ?? this.notificationCount,
      criticalAlertCount: criticalAlertCount ?? this.criticalAlertCount,
      emergencyAlertCount: emergencyAlertCount ?? this.emergencyAlertCount,
      hasCriticalAlerts: hasCriticalAlerts ?? this.hasCriticalAlerts,
      hasEmergencyAlerts: hasEmergencyAlerts ?? this.hasEmergencyAlerts,
      fcmToken: fcmToken ?? this.fcmToken,
      subscribedPatients: subscribedPatients ?? this.subscribedPatients,
      subscribedHospitals: subscribedHospitals ?? this.subscribedHospitals,
      readNotifications: readNotifications ?? this.readNotifications,
      lastUpdated: lastUpdated ?? this.lastUpdated,
    );
  }
}

class HealthcareNotification {
  final String id;
  final String title;
  final String body;
  final HealthcareNotificationType type;
  final String? patientId;
  final String? hospitalId;
  final Map<String, dynamic> data;
  final DateTime timestamp;
  final NotificationContext context;

  HealthcareNotification({
    required this.id,
    required this.title,
    required this.body,
    required this.type,
    this.patientId,
    this.hospitalId,
    required this.data,
    required this.timestamp,
    required this.context,
  });

  factory HealthcareNotification.fromRemoteMessage(
    RemoteMessage message,
    NotificationContext context,
  ) {
    final data = message.data;
    final notification = message.notification;

    return HealthcareNotification(
      id: message.messageId ?? DateTime.now().millisecondsSinceEpoch.toString(),
      title: notification?.title ?? 'Automed',
      body: notification?.body ?? '',
      type: _parseNotificationType(data['type']),
      patientId: data['patient_id'],
      hospitalId: data['hospital_id'],
      data: data,
      timestamp: DateTime.now(),
      context: context,
    );
  }

  static HealthcareNotificationType _parseNotificationType(String? type) {
    switch (type) {
      case 'critical_alert':
        return HealthcareNotificationType.criticalAlert;
      case 'medication_reminder':
        return HealthcareNotificationType.medicationReminder;
      case 'appointment_reminder':
        return HealthcareNotificationType.appointmentReminder;
      case 'vital_signs_alert':
        return HealthcareNotificationType.vitalSignsAlert;
      case 'emergency_alert':
        return HealthcareNotificationType.emergencyAlert;
      case 'lab_results':
        return HealthcareNotificationType.labResults;
      case 'consultation_request':
        return HealthcareNotificationType.consultationRequest;
      default:
        return HealthcareNotificationType.general;
    }
  }
}

enum HealthcareNotificationType {
  general,
  criticalAlert,
  medicationReminder,
  appointmentReminder,
  vitalSignsAlert,
  emergencyAlert,
  labResults,
  consultationRequest,
}

enum NotificationContext {
  foreground,
  background,
  terminated,
}
