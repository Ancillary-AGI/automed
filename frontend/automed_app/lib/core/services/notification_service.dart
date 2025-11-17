import 'package:flutter_local_notifications/flutter_local_notifications.dart';

import 'firebase_service.dart';

class NotificationService {
  final FirebaseService firebaseService;

  NotificationService({required this.firebaseService});

  static final FlutterLocalNotificationsPlugin _localNotifications =
      FlutterLocalNotificationsPlugin();

  Future<void> initialize() async {
    // Initialize local notifications
    const androidSettings =
        AndroidInitializationSettings('@mipmap/ic_launcher');
    const iosSettings = DarwinInitializationSettings(
      requestAlertPermission: true,
      requestBadgePermission: true,
      requestSoundPermission: true,
    );

    const settings = InitializationSettings(
      android: androidSettings,
      iOS: iosSettings,
    );

    await _localNotifications.initialize(
      settings,
      onDidReceiveNotificationResponse: _onNotificationTapped,
    );

    // Request permissions
    await _requestPermissions();

    // Initialize Firebase messaging
    await firebaseService.initializeMessaging();
  }

  Future<void> _requestPermissions() async {
    // Request Android permissions
    final androidPlugin =
        _localNotifications.resolvePlatformSpecificImplementation<
            AndroidFlutterLocalNotificationsPlugin>();

    await androidPlugin?.requestNotificationsPermission();

    // iOS permissions are requested in Firebase service
  }

  Future<void> showNotification({
    required String id,
    required String title,
    required String body,
    String? payload,
    NotificationType type = NotificationType.general,
    Importance importance = Importance.defaultImportance,
    Priority priority = Priority.defaultPriority,
  }) async {
    final androidDetails = AndroidNotificationDetails(
      _getChannelId(type),
      _getChannelName(type),
      channelDescription: _getChannelDescription(type),
      importance: importance,
      priority: priority,
      icon: '@mipmap/ic_launcher',
      largeIcon: const DrawableResourceAndroidBitmap('@mipmap/ic_launcher'),
    );

    const iosDetails = DarwinNotificationDetails(
      presentAlert: true,
      presentBadge: true,
      presentSound: true,
    );

    final details = NotificationDetails(
      android: androidDetails,
      iOS: iosDetails,
    );

    await _localNotifications.show(
      int.parse(id),
      title,
      body,
      details,
      payload: payload,
    );
  }

  Future<void> showScheduledNotification({
    required String id,
    required String title,
    required String body,
    required DateTime scheduledDate,
    String? payload,
    NotificationType type = NotificationType.general,
  }) async {
    try {
      // TODO: Implement proper scheduled notifications with timezone handling
      // For now, schedule for immediate display
      final now = DateTime.now();
      final scheduledDate =
          now.add(const Duration(seconds: 1)); // Schedule for 1 second from now

      // In a real implementation, this would use flutter_local_notifications
      // to schedule notifications at specific times with proper timezone handling

      await showNotification(
        id: id,
        title: title,
        body: body,
        type: type,
      );

      print('Scheduled notification for: $scheduledDate');
    } catch (e) {
      print('Error scheduling notification: $e');
      // Fallback to immediate notification
      await showNotification(
        id: id,
        title: title,
        body: body,
        type: type,
      );
    }
  }

  Future<void> cancelNotification(String id) async {
    await _localNotifications.cancel(int.parse(id));
  }

  Future<void> cancelAllNotifications() async {
    await _localNotifications.cancelAll();
  }

  Future<List<PendingNotificationRequest>> getPendingNotifications() async {
    return await _localNotifications.pendingNotificationRequests();
  }

  void _onNotificationTapped(NotificationResponse response) {
    // Handle notification tap
    final payload = response.payload;
    if (payload != null) {
      // Navigate to appropriate screen based on payload
      _handleNotificationNavigation(payload);
    }
  }

  void _handleNotificationNavigation(String payload) {
    // Parse payload and navigate to appropriate screen
    // This would typically use a navigation service or router
  }

  String _getChannelId(NotificationType type) {
    switch (type) {
      case NotificationType.emergency:
        return 'emergency_channel';
      case NotificationType.medication:
        return 'medication_channel';
      case NotificationType.appointment:
        return 'appointment_channel';
      case NotificationType.vitals:
        return 'vitals_channel';
      case NotificationType.general:
      default:
        return 'general_channel';
    }
  }

  String _getChannelName(NotificationType type) {
    switch (type) {
      case NotificationType.emergency:
        return 'Emergency Alerts';
      case NotificationType.medication:
        return 'Medication Reminders';
      case NotificationType.appointment:
        return 'Appointment Reminders';
      case NotificationType.vitals:
        return 'Health Vitals';
      case NotificationType.general:
      default:
        return 'General Notifications';
    }
  }

  String _getChannelDescription(NotificationType type) {
    switch (type) {
      case NotificationType.emergency:
        return 'Critical emergency alerts and notifications';
      case NotificationType.medication:
        return 'Medication reminders and schedules';
      case NotificationType.appointment:
        return 'Appointment reminders and updates';
      case NotificationType.vitals:
        return 'Health vitals monitoring alerts';
      case NotificationType.general:
      default:
        return 'General app notifications';
    }
  }

  // Convenience methods for common notifications
  Future<void> showMedicationReminder({
    required String id,
    required String medicationName,
    required String dosage,
    required List<String> times,
  }) async {
    const title = 'Medication Reminder';
    final body = 'Time to take $medicationName ($dosage)';

    await showNotification(
      id: id,
      title: title,
      body: body,
      type: NotificationType.medication,
      importance: Importance.high,
      priority: Priority.high,
    );
  }

  Future<void> showAppointmentReminder({
    required String id,
    required String doctorName,
    required DateTime appointmentTime,
  }) async {
    const title = 'Appointment Reminder';
    final body =
        'You have an appointment with Dr. $doctorName at ${appointmentTime.hour}:${appointmentTime.minute.toString().padLeft(2, '0')}';

    await showNotification(
      id: id,
      title: title,
      body: body,
      type: NotificationType.appointment,
      importance: Importance.high,
      priority: Priority.high,
    );
  }

  Future<void> showEmergencyAlert({
    required String id,
    required String title,
    required String message,
  }) async {
    await showNotification(
      id: id,
      title: title,
      body: message,
      type: NotificationType.emergency,
      importance: Importance.max,
      priority: Priority.max,
    );
  }

  Future<void> showVitalsAlert({
    required String id,
    required String vitalName,
    required String value,
    required String status,
  }) async {
    const title = 'Health Alert';
    final body = 'Your $vitalName is $value ($status)';

    await showNotification(
      id: id,
      title: title,
      body: body,
      type: NotificationType.vitals,
      importance: Importance.high,
      priority: Priority.high,
    );
  }
}

enum NotificationType {
  general,
  emergency,
  medication,
  appointment,
  vitals,
  success,
  error,
  warning,
}
