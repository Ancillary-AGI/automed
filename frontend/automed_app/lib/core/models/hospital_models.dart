import 'package:json_annotation/json_annotation.dart';

part 'hospital_models.g.dart';

@JsonSerializable()
class Hospital {
  final String id;
  final String name;
  final String type;
  final Address address;
  final String phoneNumber;
  final String? email;
  final String? website;
  final List<String> specialties;
  final HospitalStatus status;
  final int capacity;
  final int currentOccupancy;
  final Map<String, dynamic>? facilities;
  final DateTime createdAt;
  final DateTime updatedAt;

  Hospital({
    required this.id,
    required this.name,
    required this.type,
    required this.address,
    required this.phoneNumber,
    this.email,
    this.website,
    required this.specialties,
    required this.status,
    required this.capacity,
    required this.currentOccupancy,
    this.facilities,
    required this.createdAt,
    required this.updatedAt,
  });

  factory Hospital.fromJson(Map<String, dynamic> json) => 
      _$HospitalFromJson(json);
  Map<String, dynamic> toJson() => _$HospitalToJson(this);

  double get occupancyRate => capacity > 0 ? (currentOccupancy / capacity) * 100 : 0;
  int get availableBeds => capacity - currentOccupancy;
}

@JsonSerializable()
class Address {
  final String street;
  final String city;
  final String state;
  final String country;
  final String zipCode;
  final double? latitude;
  final double? longitude;

  Address({
    required this.street,
    required this.city,
    required this.state,
    required this.country,
    required this.zipCode,
    this.latitude,
    this.longitude,
  });

  factory Address.fromJson(Map<String, dynamic> json) => 
      _$AddressFromJson(json);
  Map<String, dynamic> toJson() => _$AddressToJson(this);

  String get fullAddress => '$street, $city, $state $zipCode, $country';
}

@JsonSerializable()
class Staff {
  final String id;
  final String hospitalId;
  final String firstName;
  final String lastName;
  final String role;
  final String department;
  final String? specialization;
  final String email;
  final String phoneNumber;
  final StaffStatus status;
  final DateTime hireDate;
  final List<String> certifications;

  Staff({
    required this.id,
    required this.hospitalId,
    required this.firstName,
    required this.lastName,
    required this.role,
    required this.department,
    this.specialization,
    required this.email,
    required this.phoneNumber,
    required this.status,
    required this.hireDate,
    required this.certifications,
  });

  factory Staff.fromJson(Map<String, dynamic> json) => 
      _$StaffFromJson(json);
  Map<String, dynamic> toJson() => _$StaffToJson(this);

  String get fullName => '$firstName $lastName';
}

@JsonSerializable()
class Equipment {
  final String id;
  final String hospitalId;
  final String name;
  final String type;
  final String manufacturer;
  final String model;
  final String serialNumber;
  final EquipmentStatus status;
  final DateTime purchaseDate;
  final DateTime? lastMaintenanceDate;
  final DateTime? nextMaintenanceDate;
  final String location;
  final Map<String, dynamic>? specifications;

  Equipment({
    required this.id,
    required this.hospitalId,
    required this.name,
    required this.type,
    required this.manufacturer,
    required this.model,
    required this.serialNumber,
    required this.status,
    required this.purchaseDate,
    this.lastMaintenanceDate,
    this.nextMaintenanceDate,
    required this.location,
    this.specifications,
  });

  factory Equipment.fromJson(Map<String, dynamic> json) => 
      _$EquipmentFromJson(json);
  Map<String, dynamic> toJson() => _$EquipmentToJson(this);

  bool get needsMaintenance {
    if (nextMaintenanceDate == null) return false;
    return DateTime.now().isAfter(nextMaintenanceDate!);
  }
}

@JsonSerializable()
class EmergencyAlert {
  final String id;
  final String patientId;
  final String? hospitalId;
  final AlertType type;
  final AlertSeverity severity;
  final String message;
  final String location;
  final DateTime timestamp;
  final AlertStatus status;
  final String? assignedTo;
  final DateTime? responseTime;
  final Map<String, dynamic>? metadata;

  EmergencyAlert({
    required this.id,
    required this.patientId,
    this.hospitalId,
    required this.type,
    required this.severity,
    required this.message,
    required this.location,
    required this.timestamp,
    required this.status,
    this.assignedTo,
    this.responseTime,
    this.metadata,
  });

  factory EmergencyAlert.fromJson(Map<String, dynamic> json) => 
      _$EmergencyAlertFromJson(json);
  Map<String, dynamic> toJson() => _$EmergencyAlertToJson(this);
}

@JsonSerializable()
class EmergencyAlertRequest {
  final String patientId;
  final AlertType type;
  final AlertSeverity severity;
  final String message;
  final String location;
  final Map<String, dynamic>? vitals;
  final Map<String, dynamic>? metadata;

  EmergencyAlertRequest({
    required this.patientId,
    required this.type,
    required this.severity,
    required this.message,
    required this.location,
    this.vitals,
    this.metadata,
  });

  factory EmergencyAlertRequest.fromJson(Map<String, dynamic> json) => 
      _$EmergencyAlertRequestFromJson(json);
  Map<String, dynamic> toJson() => _$EmergencyAlertRequestToJson(this);
}

@JsonSerializable()
class EmergencyResponse {
  final String alertId;
  final String responderId;
  final String response;
  final DateTime timestamp;
  final Map<String, dynamic>? actions;

  EmergencyResponse({
    required this.alertId,
    required this.responderId,
    required this.response,
    required this.timestamp,
    this.actions,
  });

  factory EmergencyResponse.fromJson(Map<String, dynamic> json) => 
      _$EmergencyResponseFromJson(json);
  Map<String, dynamic> toJson() => _$EmergencyResponseToJson(this);
}

// Enums
enum HospitalStatus {
  @JsonValue('ACTIVE')
  active,
  @JsonValue('INACTIVE')
  inactive,
  @JsonValue('MAINTENANCE')
  maintenance,
  @JsonValue('EMERGENCY_ONLY')
  emergencyOnly,
}

enum StaffStatus {
  @JsonValue('ACTIVE')
  active,
  @JsonValue('INACTIVE')
  inactive,
  @JsonValue('ON_LEAVE')
  onLeave,
  @JsonValue('SUSPENDED')
  suspended,
}

enum EquipmentStatus {
  @JsonValue('OPERATIONAL')
  operational,
  @JsonValue('MAINTENANCE')
  maintenance,
  @JsonValue('OUT_OF_ORDER')
  outOfOrder,
  @JsonValue('RETIRED')
  retired,
}

enum AlertType {
  @JsonValue('CARDIAC_ARREST')
  cardiacArrest,
  @JsonValue('RESPIRATORY_DISTRESS')
  respiratoryDistress,
  @JsonValue('TRAUMA')
  trauma,
  @JsonValue('STROKE')
  stroke,
  @JsonValue('ALLERGIC_REACTION')
  allergicReaction,
  @JsonValue('FALL')
  fall,
  @JsonValue('OTHER')
  other,
}

enum AlertSeverity {
  @JsonValue('LOW')
  low,
  @JsonValue('MEDIUM')
  medium,
  @JsonValue('HIGH')
  high,
  @JsonValue('CRITICAL')
  critical,
}

enum AlertStatus {
  @JsonValue('PENDING')
  pending,
  @JsonValue('ACKNOWLEDGED')
  acknowledged,
  @JsonValue('IN_PROGRESS')
  inProgress,
  @JsonValue('RESOLVED')
  resolved,
  @JsonValue('CANCELLED')
  cancelled,
}

// Extension methods
extension HospitalStatusExtension on HospitalStatus {
  String get displayName {
    switch (this) {
      case HospitalStatus.active:
        return 'Active';
      case HospitalStatus.inactive:
        return 'Inactive';
      case HospitalStatus.maintenance:
        return 'Under Maintenance';
      case HospitalStatus.emergencyOnly:
        return 'Emergency Only';
    }
  }
}

extension AlertSeverityExtension on AlertSeverity {
  String get displayName {
    switch (this) {
      case AlertSeverity.low:
        return 'Low';
      case AlertSeverity.medium:
        return 'Medium';
      case AlertSeverity.high:
        return 'High';
      case AlertSeverity.critical:
        return 'Critical';
    }
  }
}