import 'package:hive/hive.dart';
import 'patient_models.dart';
import 'consultation_models.dart';
import 'medication_models.dart';
import 'hospital_models.dart';
import 'ai_models.dart';

// Patient Model Adapters
class PatientAdapter extends TypeAdapter<Patient> {
  @override
  final int typeId = 0;

  @override
  Patient read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return Patient(
      id: fields[0] as String,
      firstName: fields[1] as String,
      lastName: fields[2] as String,
      email: fields[3] as String,
      phone: fields[4] as String,
      dateOfBirth: DateTime.fromMillisecondsSinceEpoch(fields[5] as int),
      gender: fields[6] as String,
      bloodType: fields[7] as String?,
      address: fields[8] as Address?,
      emergencyContact: fields[9] as EmergencyContact?,
      medicalHistory: fields[10] as MedicalHistory?,
      insurance: fields[11] as Insurance?,
      createdAt: DateTime.fromMillisecondsSinceEpoch(fields[12] as int),
      updatedAt: DateTime.fromMillisecondsSinceEpoch(fields[13] as int),
    );
  }

  @override
  void write(BinaryWriter writer, Patient obj) {
    writer
      ..writeByte(14)
      ..writeByte(0)
      ..write(obj.id)
      ..writeByte(1)
      ..write(obj.firstName)
      ..writeByte(2)
      ..write(obj.lastName)
      ..writeByte(3)
      ..write(obj.email)
      ..writeByte(4)
      ..write(obj.phone)
      ..writeByte(5)
      ..write(obj.dateOfBirth.millisecondsSinceEpoch)
      ..writeByte(6)
      ..write(obj.gender)
      ..writeByte(7)
      ..write(obj.bloodType)
      ..writeByte(8)
      ..write(obj.address)
      ..writeByte(9)
      ..write(obj.emergencyContact)
      ..writeByte(10)
      ..write(obj.medicalHistory)
      ..writeByte(11)
      ..write(obj.insurance)
      ..writeByte(12)
      ..write(obj.createdAt.millisecondsSinceEpoch)
      ..writeByte(13)
      ..write(obj.updatedAt.millisecondsSinceEpoch);
  }

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is PatientAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;

  @override
  int get hashCode => typeId.hashCode;
}

class AddressAdapter extends TypeAdapter<Address> {
  @override
  final int typeId = 1;

  @override
  Address read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return Address(
      street: fields[0] as String,
      city: fields[1] as String,
      state: fields[2] as String,
      zipCode: fields[3] as String,
      country: fields[4] as String,
    );
  }

  @override
  void write(BinaryWriter writer, Address obj) {
    writer
      ..writeByte(5)
      ..writeByte(0)
      ..write(obj.street)
      ..writeByte(1)
      ..write(obj.city)
      ..writeByte(2)
      ..write(obj.state)
      ..writeByte(3)
      ..write(obj.zipCode)
      ..writeByte(4)
      ..write(obj.country);
  }

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is AddressAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;

  @override
  int get hashCode => typeId.hashCode;
}

class EmergencyContactAdapter extends TypeAdapter<EmergencyContact> {
  @override
  final int typeId = 2;

  @override
  EmergencyContact read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return EmergencyContact(
      name: fields[0] as String,
      phone: fields[1] as String,
      relationship: fields[2] as String,
      email: fields[3] as String?,
    );
  }

  @override
  void write(BinaryWriter writer, EmergencyContact obj) {
    writer
      ..writeByte(4)
      ..writeByte(0)
      ..write(obj.name)
      ..writeByte(1)
      ..write(obj.phone)
      ..writeByte(2)
      ..write(obj.relationship)
      ..writeByte(3)
      ..write(obj.email);
  }

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is EmergencyContactAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;

  @override
  int get hashCode => typeId.hashCode;
}

class MedicalHistoryAdapter extends TypeAdapter<MedicalHistory> {
  @override
  final int typeId = 3;

  @override
  MedicalHistory read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return MedicalHistory(
      allergies: (fields[0] as List).cast<String>(),
      chronicConditions: (fields[1] as List).cast<String>(),
      surgeries: (fields[2] as List).cast<String>(),
      familyHistory: (fields[3] as List).cast<String>(),
      currentMedications: (fields[4] as List).cast<String>(),
      notes: fields[5] as String?,
    );
  }

  @override
  void write(BinaryWriter writer, MedicalHistory obj) {
    writer
      ..writeByte(6)
      ..writeByte(0)
      ..write(obj.allergies)
      ..writeByte(1)
      ..write(obj.chronicConditions)
      ..writeByte(2)
      ..write(obj.surgeries)
      ..writeByte(3)
      ..write(obj.familyHistory)
      ..writeByte(4)
      ..write(obj.currentMedications)
      ..writeByte(5)
      ..write(obj.notes);
  }

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is MedicalHistoryAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;

  @override
  int get hashCode => typeId.hashCode;
}

class InsuranceAdapter extends TypeAdapter<Insurance> {
  @override
  final int typeId = 4;

  @override
  Insurance read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return Insurance(
      provider: fields[0] as String,
      policyNumber: fields[1] as String,
      groupNumber: fields[2] as String?,
      expiryDate: fields[3] != null ? DateTime.fromMillisecondsSinceEpoch(fields[3] as int) : null,
    );
  }

  @override
  void write(BinaryWriter writer, Insurance obj) {
    writer
      ..writeByte(4)
      ..writeByte(0)
      ..write(obj.provider)
      ..writeByte(1)
      ..write(obj.policyNumber)
      ..writeByte(2)
      ..write(obj.groupNumber)
      ..writeByte(3)
      ..write(obj.expiryDate?.millisecondsSinceEpoch);
  }

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is InsuranceAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;

  @override
  int get hashCode => typeId.hashCode;
}

// Consultation Model Adapters
class ConsultationAdapter extends TypeAdapter<Consultation> {
  @override
  final int typeId = 5;

  @override
  Consultation read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return Consultation(
      id: fields[0] as String,
      patientId: fields[1] as String,
      doctorId: fields[2] as String,
      type: ConsultationType.values[fields[3] as int],
      status: ConsultationStatus.values[fields[4] as int],
      scheduledAt: DateTime.fromMillisecondsSinceEpoch(fields[5] as int),
      startedAt: fields[6] != null ? DateTime.fromMillisecondsSinceEpoch(fields[6] as int) : null,
      endedAt: fields[7] != null ? DateTime.fromMillisecondsSinceEpoch(fields[7] as int) : null,
      notes: fields[8] as String?,
      prescription: fields[9] as String?,
      followUpRequired: fields[10] as bool,
      createdAt: DateTime.fromMillisecondsSinceEpoch(fields[11] as int),
      updatedAt: DateTime.fromMillisecondsSinceEpoch(fields[12] as int),
    );
  }

  @override
  void write(BinaryWriter writer, Consultation obj) {
    writer
      ..writeByte(13)
      ..writeByte(0)
      ..write(obj.id)
      ..writeByte(1)
      ..write(obj.patientId)
      ..writeByte(2)
      ..write(obj.doctorId)
      ..writeByte(3)
      ..write(obj.type.index)
      ..writeByte(4)
      ..write(obj.status.index)
      ..writeByte(5)
      ..write(obj.scheduledAt.millisecondsSinceEpoch)
      ..writeByte(6)
      ..write(obj.startedAt?.millisecondsSinceEpoch)
      ..writeByte(7)
      ..write(obj.endedAt?.millisecondsSinceEpoch)
      ..writeByte(8)
      ..write(obj.notes)
      ..writeByte(9)
      ..write(obj.prescription)
      ..writeByte(10)
      ..write(obj.followUpRequired)
      ..writeByte(11)
      ..write(obj.createdAt.millisecondsSinceEpoch)
      ..writeByte(12)
      ..write(obj.updatedAt.millisecondsSinceEpoch);
  }

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is ConsultationAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;

  @override
  int get hashCode => typeId.hashCode;
}

// Medication Model Adapters
class MedicationAdapter extends TypeAdapter<Medication> {
  @override
  final int typeId = 6;

  @override
  Medication read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return Medication(
      id: fields[0] as String,
      name: fields[1] as String,
      genericName: fields[2] as String?,
      dosage: fields[3] as String,
      frequency: fields[4] as String,
      route: fields[5] as String,
      startDate: DateTime.fromMillisecondsSinceEpoch(fields[6] as int),
      endDate: fields[7] != null ? DateTime.fromMillisecondsSinceEpoch(fields[7] as int) : null,
      prescribedBy: fields[8] as String,
      instructions: fields[9] as String?,
      sideEffects: (fields[10] as List?)?.cast<String>(),
      interactions: (fields[11] as List?)?.cast<String>(),
      isActive: fields[12] as bool,
      createdAt: DateTime.fromMillisecondsSinceEpoch(fields[13] as int),
      updatedAt: DateTime.fromMillisecondsSinceEpoch(fields[14] as int),
    );
  }

  @override
  void write(BinaryWriter writer, Medication obj) {
    writer
      ..writeByte(15)
      ..writeByte(0)
      ..write(obj.id)
      ..writeByte(1)
      ..write(obj.name)
      ..writeByte(2)
      ..write(obj.genericName)
      ..writeByte(3)
      ..write(obj.dosage)
      ..writeByte(4)
      ..write(obj.frequency)
      ..writeByte(5)
      ..write(obj.route)
      ..writeByte(6)
      ..write(obj.startDate.millisecondsSinceEpoch)
      ..writeByte(7)
      ..write(obj.endDate?.millisecondsSinceEpoch)
      ..writeByte(8)
      ..write(obj.prescribedBy)
      ..writeByte(9)
      ..write(obj.instructions)
      ..writeByte(10)
      ..write(obj.sideEffects)
      ..writeByte(11)
      ..write(obj.interactions)
      ..writeByte(12)
      ..write(obj.isActive)
      ..writeByte(13)
      ..write(obj.createdAt.millisecondsSinceEpoch)
      ..writeByte(14)
      ..write(obj.updatedAt.millisecondsSinceEpoch);
  }

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is MedicationAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;

  @override
  int get hashCode => typeId.hashCode;
}

// Hospital Model Adapters
class HospitalAdapter extends TypeAdapter<Hospital> {
  @override
  final int typeId = 7;

  @override
  Hospital read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return Hospital(
      id: fields[0] as String,
      name: fields[1] as String,
      address: fields[2] as Address,
      phone: fields[3] as String,
      email: fields[4] as String,
      website: fields[5] as String?,
      type: HospitalType.values[fields[6] as int],
      capacity: fields[7] as HospitalCapacity,
      departments: (fields[8] as List).cast<Department>(),
      accreditation: (fields[9] as List?)?.cast<String>(),
      emergencyServices: fields[10] as bool,
      createdAt: DateTime.fromMillisecondsSinceEpoch(fields[11] as int),
      updatedAt: DateTime.fromMillisecondsSinceEpoch(fields[12] as int),
    );
  }

  @override
  void write(BinaryWriter writer, Hospital obj) {
    writer
      ..writeByte(13)
      ..writeByte(0)
      ..write(obj.id)
      ..writeByte(1)
      ..write(obj.name)
      ..writeByte(2)
      ..write(obj.address)
      ..writeByte(3)
      ..write(obj.phone)
      ..writeByte(4)
      ..write(obj.email)
      ..writeByte(5)
      ..write(obj.website)
      ..writeByte(6)
      ..write(obj.type.index)
      ..writeByte(7)
      ..write(obj.capacity)
      ..writeByte(8)
      ..write(obj.departments)
      ..writeByte(9)
      ..write(obj.accreditation)
      ..writeByte(10)
      ..write(obj.emergencyServices)
      ..writeByte(11)
      ..write(obj.createdAt.millisecondsSinceEpoch)
      ..writeByte(12)
      ..write(obj.updatedAt.millisecondsSinceEpoch);
  }

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is HospitalAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;

  @override
  int get hashCode => typeId.hashCode;
}

class HospitalCapacityAdapter extends TypeAdapter<HospitalCapacity> {
  @override
  final int typeId = 8;

  @override
  HospitalCapacity read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return HospitalCapacity(
      totalBeds: fields[0] as int,
      availableBeds: fields[1] as int,
      icuBeds: fields[2] as int,
      emergencyBeds: fields[3] as int,
      operatingRooms: fields[4] as int,
      lastUpdated: DateTime.fromMillisecondsSinceEpoch(fields[5] as int),
    );
  }

  @override
  void write(BinaryWriter writer, HospitalCapacity obj) {
    writer
      ..writeByte(6)
      ..writeByte(0)
      ..write(obj.totalBeds)
      ..writeByte(1)
      ..write(obj.availableBeds)
      ..writeByte(2)
      ..write(obj.icuBeds)
      ..writeByte(3)
      ..write(obj.emergencyBeds)
      ..writeByte(4)
      ..write(obj.operatingRooms)
      ..writeByte(5)
      ..write(obj.lastUpdated.millisecondsSinceEpoch);
  }

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is HospitalCapacityAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;

  @override
  int get hashCode => typeId.hashCode;
}

class DepartmentAdapter extends TypeAdapter<Department> {
  @override
  final int typeId = 9;

  @override
  Department read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return Department(
      id: fields[0] as String,
      name: fields[1] as String,
      description: fields[2] as String?,
      headOfDepartment: fields[3] as String?,
      staffCount: fields[4] as int,
      services: (fields[5] as List).cast<String>(),
    );
  }

  @override
  void write(BinaryWriter writer, Department obj) {
    writer
      ..writeByte(6)
      ..writeByte(0)
      ..write(obj.id)
      ..writeByte(1)
      ..write(obj.name)
      ..writeByte(2)
      ..write(obj.description)
      ..writeByte(3)
      ..write(obj.headOfDepartment)
      ..writeByte(4)
      ..write(obj.staffCount)
      ..writeByte(5)
      ..write(obj.services);
  }

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is DepartmentAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;

  @override
  int get hashCode => typeId.hashCode;
}

// AI Model Adapters
class AIMessageAdapter extends TypeAdapter<AIMessage> {
  @override
  final int typeId = 10;

  @override
  AIMessage read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return AIMessage(
      id: fields[0] as String,
      content: fields[1] as String,
      isUser: fields[2] as bool,
      timestamp: DateTime.fromMillisecondsSinceEpoch(fields[3] as int),
      type: MessageType.values[fields[4] as int],
      metadata: fields[5] as Map<String, dynamic>?,
    );
  }

  @override
  void write(BinaryWriter writer, AIMessage obj) {
    writer
      ..writeByte(6)
      ..writeByte(0)
      ..write(obj.id)
      ..writeByte(1)
      ..write(obj.content)
      ..writeByte(2)
      ..write(obj.isUser)
      ..writeByte(3)
      ..write(obj.timestamp.millisecondsSinceEpoch)
      ..writeByte(4)
      ..write(obj.type.index)
      ..writeByte(5)
      ..write(obj.metadata);
  }

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is AIMessageAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;

  @override
  int get hashCode => typeId.hashCode;
}

// Function to register all adapters
void registerHiveAdapters() {
  // Patient models
  Hive.registerAdapter(PatientAdapter());
  Hive.registerAdapter(AddressAdapter());
  Hive.registerAdapter(EmergencyContactAdapter());
  Hive.registerAdapter(MedicalHistoryAdapter());
  Hive.registerAdapter(InsuranceAdapter());
  
  // Consultation models
  Hive.registerAdapter(ConsultationAdapter());
  
  // Medication models
  Hive.registerAdapter(MedicationAdapter());
  
  // Hospital models
  Hive.registerAdapter(HospitalAdapter());
  Hive.registerAdapter(HospitalCapacityAdapter());
  Hive.registerAdapter(DepartmentAdapter());
  
  // AI models
  Hive.registerAdapter(AIMessageAdapter());
}