import 'dart:convert';
import 'dart:io';

import 'package:flutter/foundation.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:timezone/timezone.dart' as tz;

class NotificationService {
  static final NotificationService _instance = NotificationService._internal();
  factory NotificationService() => _instance;
  NotificationService._internal();

  final FlutterLocalNotificationsPlugin _flutterLocalNotificationsPlugin =
      FlutterLocalNotificationsPlugin();

  bool _isInitialized = false;

  Future<void> initialize() async {
    if (_isInitialized) return;

    const AndroidInitializationSettings initializationSettingsAndroid =
        AndroidInitializationSettings('@mipmap/ic_launcher');

    const DarwinInitializationSettings initializationSettingsIOS =
        DarwinInitializationSettings(
      requestAlertPermission: true,
      requestBadgePermission: true,
      requestSoundPermission: true,
    );

    const InitializationSettings initializationSettings =
        InitializationSettings(
      android: initializationSettingsAndroid,
      iOS: initializationSettingsIOS,
      macOS: initializationSettingsIOS,
    );

    await _flutterLocalNotificationsPlugin.initialize(
      initializationSettings,
      onDidReceiveNotificationResponse: _onNotificationTapped,
    );

    _isInitialized = true;
  }

  Future<bool> requestPermissions() async {
    if (Platform.isIOS || Platform.isMacOS) {
      return await _flutterLocalNotificationsPlugin
              .resolvePlatformSpecificImplementation<
                  IOSFlutterLocalNotificationsPlugin>()
              ?.requestPermissions(
                alert: true,
                badge: true,
                sound: true,
              ) ??
          false;
    } else if (Platform.isAndroid) {
      final AndroidFlutterLocalNotificationsPlugin? androidImplementation =
          _flutterLocalNotificationsPlugin.resolvePlatformSpecificImplementation<
              AndroidFlutterLocalNotificationsPlugin>();

      return await androidImplementation?.requestPermission() ?? false;
    }
    return true;
  }

  Future<void> showNotification({
    required int id,
    required String title,
    required String body,
    String? payload,
    NotificationPriority priority = NotificationPriority.defaultPriority,
    NotificationCategory category = NotificationCategory.general,
  }) async {
    await _flutterLocalNotificationsPlugin.show(
      id,
      title,
      body,
      _getNotificationDetails(priority: priority, category: category),
      payload: payload,
    );
  }

  Future<void> showMedicationReminder({
    required int id,
    required String medicationName,
    required String dosage,
    required DateTime scheduledTime,
  }) async {
    await showNotification(
      id: id,
      title: 'Medication Reminder',
      body: 'Time to take $medicationName ($dosage)',
      priority: NotificationPriority.high,
      category: NotificationCategory.medication,
      payload: jsonEncode({
        'type': 'medication_reminder',
        'medicationName': medicationName,
        'dosage': dosage,
        'scheduledTime': scheduledTime.toIso8601String(),
      }),
    );
  }

  Future<void> showAppointmentReminder({
    required int id,
    required String doctorName,
    required DateTime appointmentTime,
    required String location,
  }) async {
    await showNotification(
      id: id,
      title: 'Appointment Reminder',
      body: 'Appointment with Dr. $doctorName in 30 minutes',
      priority: NotificationPriority.high,
      category: NotificationCategory.appointment,
      payload: jsonEncode({
        'type': 'appointment_reminder',
        'doctorName': doctorName,
        'appointmentTime': appointmentTime.toIso8601String(),
        'location': location,
      }),
    );
  }

  Future<void> showEmergencyAlert({
    required int id,
    required String message,
    required String location,
  }) async {
    await showNotification(
      id: id,
      title: 'Emergency Alert',
      body: message,
      priority: NotificationPriority.max,
      category: NotificationCategory.emergency,
      payload: jsonEncode({
        'type': 'emergency_alert',
        'message': message,
        'location': location,
        'timestamp': DateTime.now().toIso8601String(),
      }),
    );
  }

  Future<void> showConsultationNotification({
    required int id,
    required String patientName,
    required String consultationType,
    required DateTime scheduledTime,
  }) async {
    await showNotification(
      id: id,
      title: 'Consultation Starting',
      body: '$consultationType with $patientName is starting now',
      priority: NotificationPriority.high,
      category: NotificationCategory.consultation,
      payload: jsonEncode({
        'type': 'consultation_notification',
        'patientName': patientName,
        'consultationType': consultationType,
        'scheduledTime': scheduledTime.toIso8601String(),
      }),
    );
  }

  Future<void> showHealthAlert({
    required int id,
    required String alertType,
    required String message,
    required Map<String, dynamic> vitals,
  }) async {
    await showNotification(
      id: id,
      title: 'Health Alert',
      body: '$alertType: $message',
      priority: NotificationPriority.high,
      category: NotificationCategory.health,
      payload: jsonEncode({
        'type': 'health_alert',
        'alertType': alertType,
        'message': message,
        'vitals': vitals,
        'timestamp': DateTime.now().toIso8601String(),
      }),
    );
  }

  // Scheduled notifications
  Future<void> scheduleMedicationReminder({
    required int id,
    required String medicationName,
    required String dosage,
    required DateTime scheduledTime,
  }) async {
    await _flutterLocalNotificationsPlugin.zonedSchedule(
      id,
      'Medication Reminder',
      'Time to take $medicationName ($dosage)',
      tz.TZDateTime.from(scheduledTime, tz.local),
      _getNotificationDetails(
        priority: NotificationPriority.high,
        category: NotificationCategory.medication,
      ),
      payload: jsonEncode({
        'type': 'medication_reminder',
        'medicationName': medicationName,
        'dosage': dosage,
        'scheduledTime': scheduledTime.toIso8601String(),
      }),
      androidScheduleMode: AndroidScheduleMode.exactAllowWhileIdle,
      uiLocalNotificationDateInterpretation:
          UILocalNotificationDateInterpretation.absoluteTime,
    );
  }

  Future<void> scheduleAppointmentReminder({
    required int id,
    required String doctorName,
    required DateTime appointmentTime,
    required String location,
  }) async {
    // Schedule 30 minutes before appointment
    final reminderTime = appointmentTime.subtract(const Duration(minutes: 30));

    await _flutterLocalNotificationsPlugin.zonedSchedule(
      id,
      'Appointment Reminder',
      'Appointment with Dr. $doctorName in 30 minutes',
      tz.TZDateTime.from(reminderTime, tz.local),
      _getNotificationDetails(
        priority: NotificationPriority.high,
        category: NotificationCategory.appointment,
      ),
      payload: jsonEncode({
        'type': 'appointment_reminder',
        'doctorName': doctorName,
        'appointmentTime': appointmentTime.toIso8601String(),
        'location': location,
      }),
      androidScheduleMode: AndroidScheduleMode.exactAllowWhileIdle,
      uiLocalNotificationDateInterpretation:
          UILocalNotificationDateInterpretation.absoluteTime,
    );
  }

  // Recurring notifications
  Future<void> scheduleRecurringMedicationReminder({
    required int id,
    required String medicationName,
    required String dosage,
    required Time time,
    required RepeatInterval interval,
  }) async {
    await _flutterLocalNotificationsPlugin.periodicallyShow(
      id,
      'Medication Reminder',
      'Time to take $medicationName ($dosage)',
      interval,
      _getNotificationDetails(
        priority: NotificationPriority.high,
        category: NotificationCategory.medication,
      ),
      payload: jsonEncode({
        'type': 'recurring_medication_reminder',
        'medicationName': medicationName,
        'dosage': dosage,
        'time': '${time.hour}:${time.minute}',
      }),
      androidScheduleMode: AndroidScheduleMode.exactAllowWhileIdle,
    );
  }

  // Notification management
  Future<void> cancelNotification(int id) async {
    await _flutterLocalNotificationsPlugin.cancel(id);
  }

  Future<void> cancelAllNotifications() async {
    await _flutterLocalNotificationsPlugin.cancelAll();
  }

  Future<List<PendingNotificationRequest>> getPendingNotifications() async {
    return await _flutterLocalNotificationsPlugin.pendingNotificationRequests();
  }

  Future<List<ActiveNotification>> getActiveNotifications() async {
    if (Platform.isAndroid) {
      final androidImplementation = _flutterLocalNotificationsPlugin
          .resolvePlatformSpecificImplementation<
              AndroidFlutterLocalNotificationsPlugin>();
      return await androidImplementation?.getActiveNotifications() ?? [];
    }
    return [];
  }

  // Private methods
  NotificationDetails _getNotificationDetails({
    NotificationPriority priority = NotificationPriority.defaultPriority,
    NotificationCategory category = NotificationCategory.general,
  }) {
    return NotificationDetails(
      android: AndroidNotificationDetails(
        _getChannelId(category),
        _getChannelName(category),
        channelDescription: _getChannelDescription(category),
        importance: _getImportance(priority),
        priority: _getPriority(priority),
        icon: '@mipmap/ic_launcher',
        color: _getNotificationColor(category),
        enableVibration: true,
        playSound: true,
      ),
      iOS: DarwinNotificationDetails(
        presentAlert: true,
        presentBadge: true,
        presentSound: true,
        categoryIdentifier: _getChannelId(category),
      ),
    );
  }

  String _getChannelId(NotificationCategory category) {
    switch (category) {
      case NotificationCategory.medication:
        return 'medication_channel';
      case NotificationCategory.appointment:
        return 'appointment_channel';
      case NotificationCategory.emergency:
        return 'emergency_channel';
      case NotificationCategory.consultation:
        return 'consultation_channel';
      case NotificationCategory.health:
        return 'health_channel';
      case NotificationCategory.general:
        return 'general_channel';
    }
  }

  String _getChannelName(NotificationCategory category) {
    switch (category) {
      case NotificationCategory.medication:
        return 'Medication Reminders';
      case NotificationCategory.appointment:
        return 'Appointment Reminders';
      case NotificationCategory.emergency:
        return 'Emergency Alerts';
      case NotificationCategory.consultation:
        return 'Consultation Notifications';
      case NotificationCategory.health:
        return 'Health Alerts';
      case NotificationCategory.general:
        return 'General Notifications';
    }
  }

  String _getChannelDescription(NotificationCategory category) {
    switch (category) {
      case NotificationCategory.medication:
        return 'Reminders for taking medications';
      case NotificationCategory.appointment:
        return 'Reminders for upcoming appointments';
      case NotificationCategory.emergency:
        return 'Critical emergency alerts';
      case NotificationCategory.consultation:
        return 'Notifications about consultations';
      case NotificationCategory.health:
        return 'Health monitoring alerts';
      case NotificationCategory.general:
        return 'General app notifications';
    }
  }

  Importance _getImportance(NotificationPriority priority) {
    switch (priority) {
      case NotificationPriority.min:
        return Importance.min;
      case NotificationPriority.low:
        return Importance.low;
      case NotificationPriority.defaultPriority:
        return Importance.defaultImportance;
      case NotificationPriority.high:
        return Importance.high;
      case NotificationPriority.max:
        return Importance.max;
    }
  }

  Priority _getPriority(NotificationPriority priority) {
    switch (priority) {
      case NotificationPriority.min:
        return Priority.min;
      case NotificationPriority.low:
        return Priority.low;
      case NotificationPriority.defaultPriority:
        return Priority.defaultPriority;
      case NotificationPriority.high:
        return Priority.high;
      case NotificationPriority.max:
        return Priority.max;
    }
  }

  int? _getNotificationColor(NotificationCategory category) {
    switch (category) {
      case NotificationCategory.emergency:
        return 0xFFD32F2F; // Red
      case NotificationCategory.health:
        return 0xFFFF9800; // Orange
      case NotificationCategory.medication:
        return 0xFF4CAF50; // Green
      case NotificationCategory.appointment:
        return 0xFF2196F3; // Blue
      case NotificationCategory.consultation:
        return 0xFF9C27B0; // Purple
      case NotificationCategory.general:
        return 0xFF607D8B; // Blue Grey
    }
  }

  void _onNotificationTapped(NotificationResponse notificationResponse) {
    final payload = notificationResponse.payload;
    if (payload != null) {
      try {
        final data = jsonDecode(payload);
        _handleNotificationTap(data);
      } catch (e) {
        debugPrint('Error parsing notification payload: $e');
      }
    }
  }

  void _handleNotificationTap(Map<String, dynamic> data) {
    final type = data['type'] as String?;
    
    switch (type) {
      case 'medication_reminder':
        // Navigate to medication screen
        break;
      case 'appointment_reminder':
        // Navigate to appointment screen
        break;
      case 'emergency_alert':
        // Navigate to emergency screen
        break;
      case 'consultation_notification':
        // Navigate to consultation screen
        break;
      case 'health_alert':
        // Navigate to health monitoring screen
        break;
      default:
        // Navigate to home screen
        break;
    }
  }
}

enum NotificationPriority {
  min,
  low,
  defaultPriority,
  high,
  max,
}

enum NotificationCategory {
  general,
  medication,
  appointment,
  emergency,
  consultation,
  health,
}