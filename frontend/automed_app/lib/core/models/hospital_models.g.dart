// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'hospital_models.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

Hospital _$HospitalFromJson(Map<String, dynamic> json) => Hospital(
      id: json['id'] as String,
      name: json['name'] as String,
      type: json['type'] as String,
      address: Address.fromJson(json['address'] as Map<String, dynamic>),
      phoneNumber: json['phoneNumber'] as String,
      email: json['email'] as String?,
      website: json['website'] as String?,
      specialties: (json['specialties'] as List<dynamic>)
          .map((e) => e as String)
          .toList(),
      status: $enumDecode(_$HospitalStatusEnumMap, json['status']),
      capacity: (json['capacity'] as num).toInt(),
      currentOccupancy: (json['currentOccupancy'] as num).toInt(),
      facilities: json['facilities'] as Map<String, dynamic>?,
      createdAt: DateTime.parse(json['createdAt'] as String),
      updatedAt: DateTime.parse(json['updatedAt'] as String),
    );

Map<String, dynamic> _$HospitalToJson(Hospital instance) => <String, dynamic>{
      'id': instance.id,
      'name': instance.name,
      'type': instance.type,
      'address': instance.address,
      'phoneNumber': instance.phoneNumber,
      'email': instance.email,
      'website': instance.website,
      'specialties': instance.specialties,
      'status': _$HospitalStatusEnumMap[instance.status]!,
      'capacity': instance.capacity,
      'currentOccupancy': instance.currentOccupancy,
      'facilities': instance.facilities,
      'createdAt': instance.createdAt.toIso8601String(),
      'updatedAt': instance.updatedAt.toIso8601String(),
    };

const _$HospitalStatusEnumMap = {
  HospitalStatus.active: 'ACTIVE',
  HospitalStatus.inactive: 'INACTIVE',
  HospitalStatus.maintenance: 'MAINTENANCE',
  HospitalStatus.emergencyOnly: 'EMERGENCY_ONLY',
};

Staff _$StaffFromJson(Map<String, dynamic> json) => Staff(
      id: json['id'] as String,
      hospitalId: json['hospitalId'] as String,
      firstName: json['firstName'] as String,
      lastName: json['lastName'] as String,
      role: json['role'] as String,
      department: json['department'] as String,
      specialization: json['specialization'] as String?,
      email: json['email'] as String,
      phoneNumber: json['phoneNumber'] as String,
      status: $enumDecode(_$StaffStatusEnumMap, json['status']),
      hireDate: DateTime.parse(json['hireDate'] as String),
      certifications: (json['certifications'] as List<dynamic>)
          .map((e) => e as String)
          .toList(),
    );

Map<String, dynamic> _$StaffToJson(Staff instance) => <String, dynamic>{
      'id': instance.id,
      'hospitalId': instance.hospitalId,
      'firstName': instance.firstName,
      'lastName': instance.lastName,
      'role': instance.role,
      'department': instance.department,
      'specialization': instance.specialization,
      'email': instance.email,
      'phoneNumber': instance.phoneNumber,
      'status': _$StaffStatusEnumMap[instance.status]!,
      'hireDate': instance.hireDate.toIso8601String(),
      'certifications': instance.certifications,
    };

const _$StaffStatusEnumMap = {
  StaffStatus.active: 'ACTIVE',
  StaffStatus.inactive: 'INACTIVE',
  StaffStatus.onLeave: 'ON_LEAVE',
  StaffStatus.suspended: 'SUSPENDED',
};

Equipment _$EquipmentFromJson(Map<String, dynamic> json) => Equipment(
      id: json['id'] as String,
      hospitalId: json['hospitalId'] as String,
      name: json['name'] as String,
      type: json['type'] as String,
      manufacturer: json['manufacturer'] as String,
      model: json['model'] as String,
      serialNumber: json['serialNumber'] as String,
      status: $enumDecode(_$EquipmentStatusEnumMap, json['status']),
      purchaseDate: DateTime.parse(json['purchaseDate'] as String),
      lastMaintenanceDate: json['lastMaintenanceDate'] == null
          ? null
          : DateTime.parse(json['lastMaintenanceDate'] as String),
      nextMaintenanceDate: json['nextMaintenanceDate'] == null
          ? null
          : DateTime.parse(json['nextMaintenanceDate'] as String),
      location: json['location'] as String,
      specifications: json['specifications'] as Map<String, dynamic>?,
    );

Map<String, dynamic> _$EquipmentToJson(Equipment instance) => <String, dynamic>{
      'id': instance.id,
      'hospitalId': instance.hospitalId,
      'name': instance.name,
      'type': instance.type,
      'manufacturer': instance.manufacturer,
      'model': instance.model,
      'serialNumber': instance.serialNumber,
      'status': _$EquipmentStatusEnumMap[instance.status]!,
      'purchaseDate': instance.purchaseDate.toIso8601String(),
      'lastMaintenanceDate': instance.lastMaintenanceDate?.toIso8601String(),
      'nextMaintenanceDate': instance.nextMaintenanceDate?.toIso8601String(),
      'location': instance.location,
      'specifications': instance.specifications,
    };

const _$EquipmentStatusEnumMap = {
  EquipmentStatus.operational: 'OPERATIONAL',
  EquipmentStatus.maintenance: 'MAINTENANCE',
  EquipmentStatus.outOfOrder: 'OUT_OF_ORDER',
  EquipmentStatus.retired: 'RETIRED',
};

EmergencyAlert _$EmergencyAlertFromJson(Map<String, dynamic> json) =>
    EmergencyAlert(
      id: json['id'] as String,
      patientId: json['patientId'] as String,
      hospitalId: json['hospitalId'] as String?,
      type: $enumDecode(_$AlertTypeEnumMap, json['type']),
      severity: $enumDecode(_$AlertSeverityEnumMap, json['severity']),
      message: json['message'] as String,
      location: json['location'] as String,
      timestamp: DateTime.parse(json['timestamp'] as String),
      status: $enumDecode(_$AlertStatusEnumMap, json['status']),
      assignedTo: json['assignedTo'] as String?,
      responseTime: json['responseTime'] == null
          ? null
          : DateTime.parse(json['responseTime'] as String),
      metadata: json['metadata'] as Map<String, dynamic>?,
    );

Map<String, dynamic> _$EmergencyAlertToJson(EmergencyAlert instance) =>
    <String, dynamic>{
      'id': instance.id,
      'patientId': instance.patientId,
      'hospitalId': instance.hospitalId,
      'type': _$AlertTypeEnumMap[instance.type]!,
      'severity': _$AlertSeverityEnumMap[instance.severity]!,
      'message': instance.message,
      'location': instance.location,
      'timestamp': instance.timestamp.toIso8601String(),
      'status': _$AlertStatusEnumMap[instance.status]!,
      'assignedTo': instance.assignedTo,
      'responseTime': instance.responseTime?.toIso8601String(),
      'metadata': instance.metadata,
    };

const _$AlertTypeEnumMap = {
  AlertType.cardiacArrest: 'CARDIAC_ARREST',
  AlertType.respiratoryDistress: 'RESPIRATORY_DISTRESS',
  AlertType.trauma: 'TRAUMA',
  AlertType.stroke: 'STROKE',
  AlertType.allergicReaction: 'ALLERGIC_REACTION',
  AlertType.fall: 'FALL',
  AlertType.other: 'OTHER',
};

const _$AlertSeverityEnumMap = {
  AlertSeverity.low: 'LOW',
  AlertSeverity.medium: 'MEDIUM',
  AlertSeverity.high: 'HIGH',
  AlertSeverity.critical: 'CRITICAL',
};

const _$AlertStatusEnumMap = {
  AlertStatus.pending: 'PENDING',
  AlertStatus.acknowledged: 'ACKNOWLEDGED',
  AlertStatus.inProgress: 'IN_PROGRESS',
  AlertStatus.resolved: 'RESOLVED',
  AlertStatus.cancelled: 'CANCELLED',
};

EmergencyAlertRequest _$EmergencyAlertRequestFromJson(
        Map<String, dynamic> json) =>
    EmergencyAlertRequest(
      patientId: json['patientId'] as String,
      type: $enumDecode(_$AlertTypeEnumMap, json['type']),
      severity: $enumDecode(_$AlertSeverityEnumMap, json['severity']),
      message: json['message'] as String,
      location: json['location'] as String,
      vitals: json['vitals'] as Map<String, dynamic>?,
      metadata: json['metadata'] as Map<String, dynamic>?,
    );

Map<String, dynamic> _$EmergencyAlertRequestToJson(
        EmergencyAlertRequest instance) =>
    <String, dynamic>{
      'patientId': instance.patientId,
      'type': _$AlertTypeEnumMap[instance.type]!,
      'severity': _$AlertSeverityEnumMap[instance.severity]!,
      'message': instance.message,
      'location': instance.location,
      'vitals': instance.vitals,
      'metadata': instance.metadata,
    };

EmergencyResponse _$EmergencyResponseFromJson(Map<String, dynamic> json) =>
    EmergencyResponse(
      alertId: json['alertId'] as String,
      responderId: json['responderId'] as String,
      response: json['response'] as String,
      timestamp: DateTime.parse(json['timestamp'] as String),
      actions: json['actions'] as Map<String, dynamic>?,
    );

Map<String, dynamic> _$EmergencyResponseToJson(EmergencyResponse instance) =>
    <String, dynamic>{
      'alertId': instance.alertId,
      'responderId': instance.responderId,
      'response': instance.response,
      'timestamp': instance.timestamp.toIso8601String(),
      'actions': instance.actions,
    };

HospitalCapacity _$HospitalCapacityFromJson(Map<String, dynamic> json) =>
    HospitalCapacity(
      totalBeds: (json['totalBeds'] as num).toInt(),
      availableBeds: (json['availableBeds'] as num).toInt(),
      icuBeds: (json['icuBeds'] as num).toInt(),
      emergencyBeds: (json['emergencyBeds'] as num).toInt(),
      operatingRooms: (json['operatingRooms'] as num).toInt(),
      lastUpdated: DateTime.parse(json['lastUpdated'] as String),
    );

Map<String, dynamic> _$HospitalCapacityToJson(HospitalCapacity instance) =>
    <String, dynamic>{
      'totalBeds': instance.totalBeds,
      'availableBeds': instance.availableBeds,
      'icuBeds': instance.icuBeds,
      'emergencyBeds': instance.emergencyBeds,
      'operatingRooms': instance.operatingRooms,
      'lastUpdated': instance.lastUpdated.toIso8601String(),
    };

Department _$DepartmentFromJson(Map<String, dynamic> json) => Department(
      id: json['id'] as String,
      name: json['name'] as String,
      description: json['description'] as String?,
      headOfDepartment: json['headOfDepartment'] as String?,
      staffCount: (json['staffCount'] as num).toInt(),
      services:
          (json['services'] as List<dynamic>).map((e) => e as String).toList(),
    );

Map<String, dynamic> _$DepartmentToJson(Department instance) =>
    <String, dynamic>{
      'id': instance.id,
      'name': instance.name,
      'description': instance.description,
      'headOfDepartment': instance.headOfDepartment,
      'staffCount': instance.staffCount,
      'services': instance.services,
    };
