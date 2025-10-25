class ConsultationModel {
  final String id;
  final String patientId;
  final String doctorId;
  final String hospitalId;
  final ConsultationType type;
  final ConsultationStatus status;
  final DateTime scheduledAt;
  final DateTime? startedAt;
  final DateTime? endedAt;
  final String? notes;
  final String? diagnosis;
  final String? prescription;
  final String? sessionId;
  final String? recordingUrl;
  final List<String> symptoms;
  final Map<String, String> vitals;
  final Priority priority;
  final DateTime createdAt;
  final DateTime updatedAt;

  const ConsultationModel({
    required this.id,
    required this.patientId,
    required this.doctorId,
    required this.hospitalId,
    required this.type,
    required this.status,
    required this.scheduledAt,
    this.startedAt,
    this.endedAt,
    this.notes,
    this.diagnosis,
    this.prescription,
    this.sessionId,
    this.recordingUrl,
    this.symptoms = const [],
    this.vitals = const {},
    this.priority = Priority.normal,
    required this.createdAt,
    required this.updatedAt,
  });

  factory ConsultationModel.fromJson(Map<String, dynamic> json) {
    return ConsultationModel(
      id: json['id'],
      patientId: json['patientId'],
      doctorId: json['doctorId'],
      hospitalId: json['hospitalId'],
      type: ConsultationType.values[json['type'] as int],
      status: ConsultationStatus.values[json['status'] as int],
      scheduledAt: DateTime.parse(json['scheduledAt']),
      startedAt: json['startedAt'] != null
          ? DateTime.parse(json['startedAt'])
          : null,
      endedAt: json['endedAt'] != null ? DateTime.parse(json['endedAt']) : null,
      notes: json['notes'],
      diagnosis: json['diagnosis'],
      prescription: json['prescription'],
      sessionId: json['sessionId'],
      recordingUrl: json['recordingUrl'],
      symptoms: json['symptoms'] != null
          ? List<String>.from(json['symptoms'])
          : [],
      vitals: json['vitals'] != null
          ? Map<String, String>.from(json['vitals'])
          : {},
      priority: json['priority'] != null
          ? Priority.values[json['priority'] as int]
          : Priority.normal,
      createdAt: DateTime.parse(json['createdAt']),
      updatedAt: DateTime.parse(json['updatedAt']),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'patientId': patientId,
      'doctorId': doctorId,
      'hospitalId': hospitalId,
      'type': type.index,
      'status': status.index,
      'scheduledAt': scheduledAt.toIso8601String(),
      'startedAt': startedAt?.toIso8601String(),
      'endedAt': endedAt?.toIso8601String(),
      'notes': notes,
      'diagnosis': diagnosis,
      'prescription': prescription,
      'sessionId': sessionId,
      'recordingUrl': recordingUrl,
      'symptoms': symptoms,
      'vitals': vitals,
      'priority': priority.index,
      'createdAt': createdAt.toIso8601String(),
      'updatedAt': updatedAt.toIso8601String(),
    };
  }
}

enum ConsultationType { videoCall, audioCall, chat, inPerson, emergency }

enum ConsultationStatus { scheduled, inProgress, completed, cancelled, noShow }

enum Priority { low, normal, high, critical, emergency }
