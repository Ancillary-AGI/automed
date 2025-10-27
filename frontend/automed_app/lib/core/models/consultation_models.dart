import 'package:json_annotation/json_annotation.dart';

part 'consultation_models.g.dart';

@JsonSerializable()
class Consultation {
  final String id;
  final String patientId;
  final String providerId;
  final String type;
  final ConsultationStatus status;
  final DateTime scheduledTime;
  final DateTime? startTime;
  final DateTime? endTime;
  final String? notes;
  final List<String> attachments;
  final Map<String, dynamic>? metadata;

  Consultation({
    required this.id,
    required this.patientId,
    required this.providerId,
    required this.type,
    required this.status,
    required this.scheduledTime,
    this.startTime,
    this.endTime,
    this.notes,
    required this.attachments,
    this.metadata,
  });

  factory Consultation.fromJson(Map<String, dynamic> json) => 
      _$ConsultationFromJson(json);
  Map<String, dynamic> toJson() => _$ConsultationToJson(this);
}

@JsonSerializable()
class ConsultationSession {
  final String sessionId;
  final String consultationId;
  final String roomId;
  final List<Participant> participants;
  final SessionStatus status;
  final DateTime createdAt;
  final Map<String, dynamic>? settings;

  ConsultationSession({
    required this.sessionId,
    required this.consultationId,
    required this.roomId,
    required this.participants,
    required this.status,
    required this.createdAt,
    this.settings,
  });

  factory ConsultationSession.fromJson(Map<String, dynamic> json) => 
      _$ConsultationSessionFromJson(json);
  Map<String, dynamic> toJson() => _$ConsultationSessionToJson(this);
}

@JsonSerializable()
class Participant {
  final String userId;
  final String name;
  final ParticipantRole role;
  final bool isConnected;
  final DateTime joinedAt;
  final DateTime? leftAt;

  Participant({
    required this.userId,
    required this.name,
    required this.role,
    required this.isConnected,
    required this.joinedAt,
    this.leftAt,
  });

  factory Participant.fromJson(Map<String, dynamic> json) => 
      _$ParticipantFromJson(json);
  Map<String, dynamic> toJson() => _$ParticipantToJson(this);
}

@JsonSerializable()
class CreateConsultationRequest {
  final String patientId;
  final String providerId;
  final String type;
  final DateTime scheduledTime;
  final String? notes;
  final Map<String, dynamic>? metadata;

  CreateConsultationRequest({
    required this.patientId,
    required this.providerId,
    required this.type,
    required this.scheduledTime,
    this.notes,
    this.metadata,
  });

  factory CreateConsultationRequest.fromJson(Map<String, dynamic> json) => 
      _$CreateConsultationRequestFromJson(json);
  Map<String, dynamic> toJson() => _$CreateConsultationRequestToJson(this);
}

@JsonSerializable()
class UpdateConsultationRequest {
  final DateTime? scheduledTime;
  final String? notes;
  final ConsultationStatus? status;
  final Map<String, dynamic>? metadata;

  UpdateConsultationRequest({
    this.scheduledTime,
    this.notes,
    this.status,
    this.metadata,
  });

  factory UpdateConsultationRequest.fromJson(Map<String, dynamic> json) => 
      _$UpdateConsultationRequestFromJson(json);
  Map<String, dynamic> toJson() => _$UpdateConsultationRequestToJson(this);
}

enum ConsultationStatus {
  @JsonValue('SCHEDULED')
  scheduled,
  @JsonValue('IN_PROGRESS')
  inProgress,
  @JsonValue('COMPLETED')
  completed,
  @JsonValue('CANCELLED')
  cancelled,
  @JsonValue('NO_SHOW')
  noShow,
}

enum SessionStatus {
  @JsonValue('WAITING')
  waiting,
  @JsonValue('ACTIVE')
  active,
  @JsonValue('ENDED')
  ended,
}

enum ParticipantRole {
  @JsonValue('PATIENT')
  patient,
  @JsonValue('PROVIDER')
  provider,
  @JsonValue('OBSERVER')
  observer,
}

// Extension methods
extension ConsultationStatusExtension on ConsultationStatus {
  String get displayName {
    switch (this) {
      case ConsultationStatus.scheduled:
        return 'Scheduled';
      case ConsultationStatus.inProgress:
        return 'In Progress';
      case ConsultationStatus.completed:
        return 'Completed';
      case ConsultationStatus.cancelled:
        return 'Cancelled';
      case ConsultationStatus.noShow:
        return 'No Show';
    }
  }
}