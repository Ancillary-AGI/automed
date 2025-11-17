import 'package:flutter_riverpod/flutter_riverpod.dart';

final mobileDashboardProvider = FutureProvider<MobileDashboardData>((ref) async {
  // Simulate loading dashboard data
  await Future.delayed(const Duration(seconds: 1));
  
  return MobileDashboardData(
    currentUser: User(name: 'Dr. Smith'),
    activePatients: 24,
    criticalAlerts: [
      Alert(
        id: '1',
        type: 'vital_alert',
        title: 'High Blood Pressure',
        description: 'Patient John Doe - BP: 180/120',
        timestamp: DateTime.now().subtract(const Duration(minutes: 5)),
      ),
      Alert(
        id: '2',
        type: 'medication_alert',
        title: 'Medication Due',
        description: 'Patient Jane Smith - Insulin injection',
        timestamp: DateTime.now().subtract(const Duration(minutes: 15)),
      ),
    ],
    recentActivities: [
      Activity(
        type: 'patient_admission',
        title: 'New Patient Admission',
        description: 'John Doe admitted to ICU',
        timestamp: DateTime.now().subtract(const Duration(hours: 1)),
      ),
      Activity(
        type: 'vital_alert',
        title: 'Vital Signs Alert',
        description: 'Abnormal heart rate detected',
        timestamp: DateTime.now().subtract(const Duration(hours: 2)),
      ),
      Activity(
        type: 'consultation_completed',
        title: 'Consultation Completed',
        description: 'Video call with patient completed',
        timestamp: DateTime.now().subtract(const Duration(hours: 3)),
      ),
    ],
    avgResponseTime: 4.2,
    bedOccupancy: 85,
  );
});

class MobileDashboardData {
  final User? currentUser;
  final int activePatients;
  final List<Alert> criticalAlerts;
  final List<Activity> recentActivities;
  final double avgResponseTime;
  final int bedOccupancy;

  MobileDashboardData({
    this.currentUser,
    required this.activePatients,
    required this.criticalAlerts,
    required this.recentActivities,
    required this.avgResponseTime,
    required this.bedOccupancy,
  });
}

class User {
  final String name;

  User({required this.name});
}

class Alert {
  final String id;
  final String type;
  final String title;
  final String description;
  final DateTime timestamp;

  Alert({
    required this.id,
    required this.type,
    required this.title,
    required this.description,
    required this.timestamp,
  });
}

class Activity {
  final String type;
  final String title;
  final String description;
  final DateTime timestamp;

  Activity({
    required this.type,
    required this.title,
    required this.description,
    required this.timestamp,
  });
}
