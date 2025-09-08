import 'package:freezed_annotation/freezed_annotation.dart';

part 'consultation_model.freezed.dart';
part 'consultation_model.g.dart';

@freezed
class ConsultationModel with _$ConsultationModel {
  const factory ConsultationModel({
    required String id,
    required String patientId,
    required String doctorId,
    required String hospitalId,
    required ConsultationType type,
    required ConsultationStatus status,
    required DateTime scheduledAt,
    DateTime? startedAt,
    DateTime? endedAt,
    String? notes,
    String? diagnosis,
    String? prescription,
    String? sessionId,
    String? recordingUrl,
    @Default([]) List<String> symptoms,
    @Default({}) Map<String, String> vitals,
    @Default(Priority.normal) Priority priority,
    required DateTime createdAt,
    required DateTime updatedAt,
  }) = _ConsultationModel;

  factory ConsultationModel.fromJson(Map<String, dynamic> json) =>
      _$ConsultationModelFromJson(json);
}

enum ConsultationType {
  @JsonValue('VIDEO_CALL')
  videoCall,
  @JsonValue('AUDIO_CALL')
  audioCall,
  @JsonValue('CHAT')
  chat,
  @JsonValue('IN_PERSON')
  inPerson,
  @JsonValue('EMERGENCY')
  emergency,
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

enum Priority {
  @JsonValue('LOW')
  low,
  @JsonValue('NORMAL')
  normal,
  @JsonValue('HIGH')
  high,
  @JsonValue('CRITICAL')
  critical,
  @JsonValue('EMERGENCY')
  emergency,
}