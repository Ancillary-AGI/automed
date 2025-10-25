class PatientDashboardModel {
  final HealthMetrics healthMetrics;
  final List<UpcomingAppointment> upcomingAppointments;
  final List<MedicationReminder> medications;

  const PatientDashboardModel({
    required this.healthMetrics,
    required this.upcomingAppointments,
    required this.medications,
  });

  factory PatientDashboardModel.fromJson(Map<String, dynamic> json) {
    return PatientDashboardModel(
      healthMetrics: HealthMetrics.fromJson(json['healthMetrics']),
      upcomingAppointments: (json['upcomingAppointments'] as List)
          .map((e) => UpcomingAppointment.fromJson(e))
          .toList(),
      medications: (json['medications'] as List)
          .map((e) => MedicationReminder.fromJson(e))
          .toList(),
    );
  }
}

class HealthMetrics {
  final double heartRate;
  final double bloodPressure;
  final double temperature;
  final double oxygenSaturation;

  const HealthMetrics({
    required this.heartRate,
    required this.bloodPressure,
    required this.temperature,
    required this.oxygenSaturation,
  });

  factory HealthMetrics.fromJson(Map<String, dynamic> json) {
    return HealthMetrics(
      heartRate: json['heartRate'].toDouble(),
      bloodPressure: json['bloodPressure'].toDouble(),
      temperature: json['temperature'].toDouble(),
      oxygenSaturation: json['oxygenSaturation'].toDouble(),
    );
  }
}

class UpcomingAppointment {
  final String id;
  final String doctorName;
  final String specialty;
  final DateTime dateTime;
  final String status;

  const UpcomingAppointment({
    required this.id,
    required this.doctorName,
    required this.specialty,
    required this.dateTime,
    required this.status,
  });

  factory UpcomingAppointment.fromJson(Map<String, dynamic> json) {
    return UpcomingAppointment(
      id: json['id'],
      doctorName: json['doctorName'],
      specialty: json['specialty'],
      dateTime: DateTime.parse(json['dateTime']),
      status: json['status'],
    );
  }
}

class MedicationReminder {
  final String id;
  final String name;
  final String dosage;
  final List<String> times;
  final bool taken;

  const MedicationReminder({
    required this.id,
    required this.name,
    required this.dosage,
    required this.times,
    required this.taken,
  });

  factory MedicationReminder.fromJson(Map<String, dynamic> json) {
    return MedicationReminder(
      id: json['id'],
      name: json['name'],
      dosage: json['dosage'],
      times: List<String>.from(json['times']),
      taken: json['taken'],
    );
  }
}
