// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'patient_models.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

Patient _$PatientFromJson(Map<String, dynamic> json) => Patient(
      id: json['id'] as String,
      patientId: json['patientId'] as String,
      firstName: json['firstName'] as String,
      lastName: json['lastName'] as String,
      dateOfBirth: DateTime.parse(json['dateOfBirth'] as String),
      gender: $enumDecode(_$GenderEnumMap, json['gender']),
      email: json['email'] as String,
      phoneNumber: json['phoneNumber'] as String,
      address: Address.fromJson(json['address'] as Map<String, dynamic>),
      bloodType: $enumDecode(_$BloodTypeEnumMap, json['bloodType']),
      allergies:
          (json['allergies'] as List<dynamic>).map((e) => e as String).toList(),
      medicalConditions: (json['medicalConditions'] as List<dynamic>)
          .map((e) => e as String)
          .toList(),
      status: $enumDecode(_$PatientStatusEnumMap, json['status']),
      createdAt: DateTime.parse(json['createdAt'] as String),
      updatedAt: DateTime.parse(json['updatedAt'] as String),
      emergencyContact: json['emergencyContact'] == null
          ? null
          : EmergencyContact.fromJson(
              json['emergencyContact'] as Map<String, dynamic>),
      insurance: json['insurance'] == null
          ? null
          : Insurance.fromJson(json['insurance'] as Map<String, dynamic>),
    );

Map<String, dynamic> _$PatientToJson(Patient instance) => <String, dynamic>{
      'id': instance.id,
      'patientId': instance.patientId,
      'firstName': instance.firstName,
      'lastName': instance.lastName,
      'dateOfBirth': instance.dateOfBirth.toIso8601String(),
      'gender': _$GenderEnumMap[instance.gender]!,
      'email': instance.email,
      'phoneNumber': instance.phoneNumber,
      'address': instance.address,
      'bloodType': _$BloodTypeEnumMap[instance.bloodType]!,
      'allergies': instance.allergies,
      'medicalConditions': instance.medicalConditions,
      'status': _$PatientStatusEnumMap[instance.status]!,
      'createdAt': instance.createdAt.toIso8601String(),
      'updatedAt': instance.updatedAt.toIso8601String(),
      'emergencyContact': instance.emergencyContact,
      'insurance': instance.insurance,
    };

const _$GenderEnumMap = {
  Gender.male: 'MALE',
  Gender.female: 'FEMALE',
  Gender.other: 'OTHER',
  Gender.preferNotToSay: 'PREFER_NOT_TO_SAY',
};

const _$BloodTypeEnumMap = {
  BloodType.aPositive: 'A_POSITIVE',
  BloodType.aNegative: 'A_NEGATIVE',
  BloodType.bPositive: 'B_POSITIVE',
  BloodType.bNegative: 'B_NEGATIVE',
  BloodType.abPositive: 'AB_POSITIVE',
  BloodType.abNegative: 'AB_NEGATIVE',
  BloodType.oPositive: 'O_POSITIVE',
  BloodType.oNegative: 'O_NEGATIVE',
  BloodType.unknown: 'UNKNOWN',
};

const _$PatientStatusEnumMap = {
  PatientStatus.active: 'ACTIVE',
  PatientStatus.inactive: 'INACTIVE',
  PatientStatus.deceased: 'DECEASED',
  PatientStatus.unknown: 'UNKNOWN',
};

Address _$AddressFromJson(Map<String, dynamic> json) => Address(
      street: json['street'] as String,
      city: json['city'] as String,
      state: json['state'] as String,
      country: json['country'] as String,
      zipCode: json['zipCode'] as String,
      latitude: (json['latitude'] as num?)?.toDouble(),
      longitude: (json['longitude'] as num?)?.toDouble(),
    );

Map<String, dynamic> _$AddressToJson(Address instance) => <String, dynamic>{
      'street': instance.street,
      'city': instance.city,
      'state': instance.state,
      'country': instance.country,
      'zipCode': instance.zipCode,
      'latitude': instance.latitude,
      'longitude': instance.longitude,
    };

EmergencyContact _$EmergencyContactFromJson(Map<String, dynamic> json) =>
    EmergencyContact(
      name: json['name'] as String,
      relationship: json['relationship'] as String,
      phoneNumber: json['phoneNumber'] as String,
      email: json['email'] as String?,
      address: json['address'] == null
          ? null
          : Address.fromJson(json['address'] as Map<String, dynamic>),
    );

Map<String, dynamic> _$EmergencyContactToJson(EmergencyContact instance) =>
    <String, dynamic>{
      'name': instance.name,
      'relationship': instance.relationship,
      'phoneNumber': instance.phoneNumber,
      'email': instance.email,
      'address': instance.address,
    };

Insurance _$InsuranceFromJson(Map<String, dynamic> json) => Insurance(
      provider: json['provider'] as String,
      policyNumber: json['policyNumber'] as String,
      groupNumber: json['groupNumber'] as String,
      expiryDate: DateTime.parse(json['expiryDate'] as String),
      notes: json['notes'] as String?,
    );

Map<String, dynamic> _$InsuranceToJson(Insurance instance) => <String, dynamic>{
      'provider': instance.provider,
      'policyNumber': instance.policyNumber,
      'groupNumber': instance.groupNumber,
      'expiryDate': instance.expiryDate.toIso8601String(),
      'notes': instance.notes,
    };

MedicalRecord _$MedicalRecordFromJson(Map<String, dynamic> json) =>
    MedicalRecord(
      id: json['id'] as String,
      patientId: json['patientId'] as String,
      type: json['type'] as String,
      title: json['title'] as String,
      description: json['description'] as String,
      date: DateTime.parse(json['date'] as String),
      providerId: json['providerId'] as String,
      providerName: json['providerName'] as String,
      attachments: (json['attachments'] as List<dynamic>)
          .map((e) => e as String)
          .toList(),
      metadata: json['metadata'] as Map<String, dynamic>?,
    );

Map<String, dynamic> _$MedicalRecordToJson(MedicalRecord instance) =>
    <String, dynamic>{
      'id': instance.id,
      'patientId': instance.patientId,
      'type': instance.type,
      'title': instance.title,
      'description': instance.description,
      'date': instance.date.toIso8601String(),
      'providerId': instance.providerId,
      'providerName': instance.providerName,
      'attachments': instance.attachments,
      'metadata': instance.metadata,
    };

VitalSigns _$VitalSignsFromJson(Map<String, dynamic> json) => VitalSigns(
      id: json['id'] as String,
      patientId: json['patientId'] as String,
      timestamp: DateTime.parse(json['timestamp'] as String),
      heartRate: (json['heartRate'] as num?)?.toDouble(),
      bloodPressure: json['bloodPressure'] == null
          ? null
          : BloodPressure.fromJson(
              json['bloodPressure'] as Map<String, dynamic>),
      temperature: (json['temperature'] as num?)?.toDouble(),
      oxygenSaturation: (json['oxygenSaturation'] as num?)?.toDouble(),
      respiratoryRate: (json['respiratoryRate'] as num?)?.toDouble(),
      weight: (json['weight'] as num?)?.toDouble(),
      height: (json['height'] as num?)?.toDouble(),
      notes: json['notes'] as String?,
    );

Map<String, dynamic> _$VitalSignsToJson(VitalSigns instance) =>
    <String, dynamic>{
      'id': instance.id,
      'patientId': instance.patientId,
      'timestamp': instance.timestamp.toIso8601String(),
      'heartRate': instance.heartRate,
      'bloodPressure': instance.bloodPressure,
      'temperature': instance.temperature,
      'oxygenSaturation': instance.oxygenSaturation,
      'respiratoryRate': instance.respiratoryRate,
      'weight': instance.weight,
      'height': instance.height,
      'notes': instance.notes,
    };

BloodPressure _$BloodPressureFromJson(Map<String, dynamic> json) =>
    BloodPressure(
      systolic: (json['systolic'] as num).toInt(),
      diastolic: (json['diastolic'] as num).toInt(),
    );

Map<String, dynamic> _$BloodPressureToJson(BloodPressure instance) =>
    <String, dynamic>{
      'systolic': instance.systolic,
      'diastolic': instance.diastolic,
    };

CreatePatientRequest _$CreatePatientRequestFromJson(
        Map<String, dynamic> json) =>
    CreatePatientRequest(
      firstName: json['firstName'] as String,
      lastName: json['lastName'] as String,
      dateOfBirth: DateTime.parse(json['dateOfBirth'] as String),
      gender: $enumDecode(_$GenderEnumMap, json['gender']),
      email: json['email'] as String,
      phoneNumber: json['phoneNumber'] as String,
      address: Address.fromJson(json['address'] as Map<String, dynamic>),
      bloodType: $enumDecode(_$BloodTypeEnumMap, json['bloodType']),
      allergies:
          (json['allergies'] as List<dynamic>).map((e) => e as String).toList(),
      medicalConditions: (json['medicalConditions'] as List<dynamic>)
          .map((e) => e as String)
          .toList(),
      emergencyContact: json['emergencyContact'] == null
          ? null
          : EmergencyContact.fromJson(
              json['emergencyContact'] as Map<String, dynamic>),
      insurance: json['insurance'] == null
          ? null
          : Insurance.fromJson(json['insurance'] as Map<String, dynamic>),
    );

Map<String, dynamic> _$CreatePatientRequestToJson(
        CreatePatientRequest instance) =>
    <String, dynamic>{
      'firstName': instance.firstName,
      'lastName': instance.lastName,
      'dateOfBirth': instance.dateOfBirth.toIso8601String(),
      'gender': _$GenderEnumMap[instance.gender]!,
      'email': instance.email,
      'phoneNumber': instance.phoneNumber,
      'address': instance.address,
      'bloodType': _$BloodTypeEnumMap[instance.bloodType]!,
      'allergies': instance.allergies,
      'medicalConditions': instance.medicalConditions,
      'emergencyContact': instance.emergencyContact,
      'insurance': instance.insurance,
    };

UpdatePatientRequest _$UpdatePatientRequestFromJson(
        Map<String, dynamic> json) =>
    UpdatePatientRequest(
      firstName: json['firstName'] as String?,
      lastName: json['lastName'] as String?,
      dateOfBirth: json['dateOfBirth'] == null
          ? null
          : DateTime.parse(json['dateOfBirth'] as String),
      gender: $enumDecodeNullable(_$GenderEnumMap, json['gender']),
      email: json['email'] as String?,
      phoneNumber: json['phoneNumber'] as String?,
      address: json['address'] == null
          ? null
          : Address.fromJson(json['address'] as Map<String, dynamic>),
      bloodType: $enumDecodeNullable(_$BloodTypeEnumMap, json['bloodType']),
      allergies: (json['allergies'] as List<dynamic>?)
          ?.map((e) => e as String)
          .toList(),
      medicalConditions: (json['medicalConditions'] as List<dynamic>?)
          ?.map((e) => e as String)
          .toList(),
      emergencyContact: json['emergencyContact'] == null
          ? null
          : EmergencyContact.fromJson(
              json['emergencyContact'] as Map<String, dynamic>),
      insurance: json['insurance'] == null
          ? null
          : Insurance.fromJson(json['insurance'] as Map<String, dynamic>),
      status: $enumDecodeNullable(_$PatientStatusEnumMap, json['status']),
    );

Map<String, dynamic> _$UpdatePatientRequestToJson(
        UpdatePatientRequest instance) =>
    <String, dynamic>{
      'firstName': instance.firstName,
      'lastName': instance.lastName,
      'dateOfBirth': instance.dateOfBirth?.toIso8601String(),
      'gender': _$GenderEnumMap[instance.gender],
      'email': instance.email,
      'phoneNumber': instance.phoneNumber,
      'address': instance.address,
      'bloodType': _$BloodTypeEnumMap[instance.bloodType],
      'allergies': instance.allergies,
      'medicalConditions': instance.medicalConditions,
      'emergencyContact': instance.emergencyContact,
      'insurance': instance.insurance,
      'status': _$PatientStatusEnumMap[instance.status],
    };

MedicalHistory _$MedicalHistoryFromJson(Map<String, dynamic> json) =>
    MedicalHistory(
      allergies:
          (json['allergies'] as List<dynamic>).map((e) => e as String).toList(),
      chronicConditions: (json['chronicConditions'] as List<dynamic>)
          .map((e) => e as String)
          .toList(),
      surgeries:
          (json['surgeries'] as List<dynamic>).map((e) => e as String).toList(),
      familyHistory: (json['familyHistory'] as List<dynamic>)
          .map((e) => e as String)
          .toList(),
      currentMedications: (json['currentMedications'] as List<dynamic>)
          .map((e) => e as String)
          .toList(),
      notes: json['notes'] as String?,
    );

Map<String, dynamic> _$MedicalHistoryToJson(MedicalHistory instance) =>
    <String, dynamic>{
      'allergies': instance.allergies,
      'chronicConditions': instance.chronicConditions,
      'surgeries': instance.surgeries,
      'familyHistory': instance.familyHistory,
      'currentMedications': instance.currentMedications,
      'notes': instance.notes,
    };
