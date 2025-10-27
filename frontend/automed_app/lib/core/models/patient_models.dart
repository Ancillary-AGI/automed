import 'package:json_annotation/json_annotation.dart';

part 'patient_models.g.dart';

@JsonSerializable()
class Patient {
  final String id;
  final String patientId;
  final String firstName;
  final String lastName;
  final DateTime dateOfBirth;
  final Gender gender;
  final String email;
  final String phoneNumber;
  final Address address;
  final BloodType bloodType;
  final List<String> allergies;
  final List<String> medicalConditions;
  final PatientStatus status;
  final DateTime createdAt;
  final DateTime updatedAt;
  final EmergencyContact? emergencyContact;
  final Insurance? insurance;

  Patient({
    required this.id,
    required this.patientId,
    required this.firstName,
    required this.lastName,
    required this.dateOfBirth,
    required this.gender,
    required this.email,
    required this.phoneNumber,
    required this.address,
    required this.bloodType,
    required this.allergies,
    required this.medicalConditions,
    required this.status,
    required this.createdAt,
    required this.updatedAt,
    this.emergencyContact,
    this.insurance,
  });

  factory Patient.fromJson(Map<String, dynamic> json) => _$PatientFromJson(json);
  Map<String, dynamic> toJson() => _$PatientToJson(this);

  String get fullName => '$firstName $lastName';
  int get age {
    final now = DateTime.now();
    int age = now.year - dateOfBirth.year;
    if (now.month < dateOfBirth.month || 
        (now.month == dateOfBirth.month && now.day < dateOfBirth.day)) {
      age--;
    }
    return age;
  }
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

  factory Address.fromJson(Map<String, dynamic> json) => _$AddressFromJson(json);
  Map<String, dynamic> toJson() => _$AddressToJson(this);

  String get fullAddress => '$street, $city, $state $zipCode, $country';
}

@JsonSerializable()
class EmergencyContact {
  final String name;
  final String relationship;
  final String phoneNumber;
  final String? email;
  final Address? address;

  EmergencyContact({
    required this.name,
    required this.relationship,
    required this.phoneNumber,
    this.email,
    this.address,
  });

  factory EmergencyContact.fromJson(Map<String, dynamic> json) => 
      _$EmergencyContactFromJson(json);
  Map<String, dynamic> toJson() => _$EmergencyContactToJson(this);
}

@JsonSerializable()
class Insurance {
  final String provider;
  final String policyNumber;
  final String groupNumber;
  final DateTime expiryDate;
  final String? notes;

  Insurance({
    required this.provider,
    required this.policyNumber,
    required this.groupNumber,
    required this.expiryDate,
    this.notes,
  });

  factory Insurance.fromJson(Map<String, dynamic> json) => _$InsuranceFromJson(json);
  Map<String, dynamic> toJson() => _$InsuranceToJson(this);

  bool get isExpired => DateTime.now().isAfter(expiryDate);
  bool get isExpiringSoon => 
      DateTime.now().add(const Duration(days: 30)).isAfter(expiryDate);
}

@JsonSerializable()
class MedicalRecord {
  final String id;
  final String patientId;
  final String type;
  final String title;
  final String description;
  final DateTime date;
  final String providerId;
  final String providerName;
  final List<String> attachments;
  final Map<String, dynamic>? metadata;

  MedicalRecord({
    required this.id,
    required this.patientId,
    required this.type,
    required this.title,
    required this.description,
    required this.date,
    required this.providerId,
    required this.providerName,
    required this.attachments,
    this.metadata,
  });

  factory MedicalRecord.fromJson(Map<String, dynamic> json) => 
      _$MedicalRecordFromJson(json);
  Map<String, dynamic> toJson() => _$MedicalRecordToJson(this);
}

@JsonSerializable()
class VitalSigns {
  final String id;
  final String patientId;
  final DateTime timestamp;
  final double? heartRate;
  final BloodPressure? bloodPressure;
  final double? temperature;
  final double? oxygenSaturation;
  final double? respiratoryRate;
  final double? weight;
  final double? height;
  final String? notes;

  VitalSigns({
    required this.id,
    required this.patientId,
    required this.timestamp,
    this.heartRate,
    this.bloodPressure,
    this.temperature,
    this.oxygenSaturation,
    this.respiratoryRate,
    this.weight,
    this.height,
    this.notes,
  });

  factory VitalSigns.fromJson(Map<String, dynamic> json) => 
      _$VitalSignsFromJson(json);
  Map<String, dynamic> toJson() => _$VitalSignsToJson(this);

  double? get bmi {
    if (weight != null && height != null && height! > 0) {
      final heightInMeters = height! / 100;
      return weight! / (heightInMeters * heightInMeters);
    }
    return null;
  }
}

@JsonSerializable()
class BloodPressure {
  final int systolic;
  final int diastolic;

  BloodPressure({
    required this.systolic,
    required this.diastolic,
  });

  factory BloodPressure.fromJson(Map<String, dynamic> json) => 
      _$BloodPressureFromJson(json);
  Map<String, dynamic> toJson() => _$BloodPressureToJson(this);

  String get displayValue => '$systolic/$diastolic';
  
  BloodPressureCategory get category {
    if (systolic < 120 && diastolic < 80) return BloodPressureCategory.normal;
    if (systolic < 130 && diastolic < 80) return BloodPressureCategory.elevated;
    if (systolic < 140 || diastolic < 90) return BloodPressureCategory.stage1;
    if (systolic < 180 || diastolic < 120) return BloodPressureCategory.stage2;
    return BloodPressureCategory.crisis;
  }
}

@JsonSerializable()
class CreatePatientRequest {
  final String firstName;
  final String lastName;
  final DateTime dateOfBirth;
  final Gender gender;
  final String email;
  final String phoneNumber;
  final Address address;
  final BloodType bloodType;
  final List<String> allergies;
  final List<String> medicalConditions;
  final EmergencyContact? emergencyContact;
  final Insurance? insurance;

  CreatePatientRequest({
    required this.firstName,
    required this.lastName,
    required this.dateOfBirth,
    required this.gender,
    required this.email,
    required this.phoneNumber,
    required this.address,
    required this.bloodType,
    required this.allergies,
    required this.medicalConditions,
    this.emergencyContact,
    this.insurance,
  });

  factory CreatePatientRequest.fromJson(Map<String, dynamic> json) => 
      _$CreatePatientRequestFromJson(json);
  Map<String, dynamic> toJson() => _$CreatePatientRequestToJson(this);
}

@JsonSerializable()
class UpdatePatientRequest {
  final String? firstName;
  final String? lastName;
  final DateTime? dateOfBirth;
  final Gender? gender;
  final String? email;
  final String? phoneNumber;
  final Address? address;
  final BloodType? bloodType;
  final List<String>? allergies;
  final List<String>? medicalConditions;
  final EmergencyContact? emergencyContact;
  final Insurance? insurance;
  final PatientStatus? status;

  UpdatePatientRequest({
    this.firstName,
    this.lastName,
    this.dateOfBirth,
    this.gender,
    this.email,
    this.phoneNumber,
    this.address,
    this.bloodType,
    this.allergies,
    this.medicalConditions,
    this.emergencyContact,
    this.insurance,
    this.status,
  });

  factory UpdatePatientRequest.fromJson(Map<String, dynamic> json) => 
      _$UpdatePatientRequestFromJson(json);
  Map<String, dynamic> toJson() => _$UpdatePatientRequestToJson(this);

  Map<String, dynamic> getUpdatedFields() {
    final fields = <String, dynamic>{};
    if (firstName != null) fields['firstName'] = firstName;
    if (lastName != null) fields['lastName'] = lastName;
    if (dateOfBirth != null) fields['dateOfBirth'] = dateOfBirth;
    if (gender != null) fields['gender'] = gender;
    if (email != null) fields['email'] = email;
    if (phoneNumber != null) fields['phoneNumber'] = phoneNumber;
    if (address != null) fields['address'] = address;
    if (bloodType != null) fields['bloodType'] = bloodType;
    if (allergies != null) fields['allergies'] = allergies;
    if (medicalConditions != null) fields['medicalConditions'] = medicalConditions;
    if (emergencyContact != null) fields['emergencyContact'] = emergencyContact;
    if (insurance != null) fields['insurance'] = insurance;
    if (status != null) fields['status'] = status;
    return fields;
  }
}

enum Gender {
  @JsonValue('MALE')
  male,
  @JsonValue('FEMALE')
  female,
  @JsonValue('OTHER')
  other,
  @JsonValue('PREFER_NOT_TO_SAY')
  preferNotToSay,
}

enum BloodType {
  @JsonValue('A_POSITIVE')
  aPositive,
  @JsonValue('A_NEGATIVE')
  aNegative,
  @JsonValue('B_POSITIVE')
  bPositive,
  @JsonValue('B_NEGATIVE')
  bNegative,
  @JsonValue('AB_POSITIVE')
  abPositive,
  @JsonValue('AB_NEGATIVE')
  abNegative,
  @JsonValue('O_POSITIVE')
  oPositive,
  @JsonValue('O_NEGATIVE')
  oNegative,
  @JsonValue('UNKNOWN')
  unknown,
}

enum PatientStatus {
  @JsonValue('ACTIVE')
  active,
  @JsonValue('INACTIVE')
  inactive,
  @JsonValue('DECEASED')
  deceased,
  @JsonValue('UNKNOWN')
  unknown,
}

enum BloodPressureCategory {
  normal,
  elevated,
  stage1,
  stage2,
  crisis,
}

// Extension methods for enums
extension GenderExtension on Gender {
  String get displayName {
    switch (this) {
      case Gender.male:
        return 'Male';
      case Gender.female:
        return 'Female';
      case Gender.other:
        return 'Other';
      case Gender.preferNotToSay:
        return 'Prefer not to say';
    }
  }
}

extension BloodTypeExtension on BloodType {
  String get displayName {
    switch (this) {
      case BloodType.aPositive:
        return 'A+';
      case BloodType.aNegative:
        return 'A-';
      case BloodType.bPositive:
        return 'B+';
      case BloodType.bNegative:
        return 'B-';
      case BloodType.abPositive:
        return 'AB+';
      case BloodType.abNegative:
        return 'AB-';
      case BloodType.oPositive:
        return 'O+';
      case BloodType.oNegative:
        return 'O-';
      case BloodType.unknown:
        return 'Unknown';
    }
  }
}

extension PatientStatusExtension on PatientStatus {
  String get displayName {
    switch (this) {
      case PatientStatus.active:
        return 'Active';
      case PatientStatus.inactive:
        return 'Inactive';
      case PatientStatus.deceased:
        return 'Deceased';
      case PatientStatus.unknown:
        return 'Unknown';
    }
  }
}