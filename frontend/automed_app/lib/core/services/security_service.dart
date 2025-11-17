import 'dart:convert';
import 'dart:math';
import 'package:crypto/crypto.dart';
import 'package:encrypt/encrypt.dart' as encrypt;
import 'package:shared_preferences/shared_preferences.dart';
import 'package:automed_app/core/utils/logger.dart';

/// Security service for HIPAA/GDPR compliance and data protection
class SecurityService {
  static final SecurityService _instance = SecurityService._internal();
  factory SecurityService() => _instance;
  SecurityService._internal();

  static const String _encryptionKeyKey = 'encryption_key';
  static const String _auditLogKey = 'audit_log';
  static const String _consentLogKey = 'consent_log';

  late encrypt.Key _encryptionKey;
  late encrypt.Encrypter _encrypter;
  late encrypt.IV _iv;

  List<AuditEntry> _auditLog = [];
  Map<String, ConsentRecord> _consentRecords = {};

  bool _isInitialized = false;

  /// Initialize security service
  Future<void> initialize() async {
    if (_isInitialized) return;

    try {
      await _initializeEncryption();
      await _loadAuditLog();
      await _loadConsentRecords();
      _isInitialized = true;
      Logger.info('Security service initialized successfully');
    } catch (e) {
      Logger.error('Failed to initialize security service: $e');
    }
  }

  /// Encrypt sensitive healthcare data
  String encryptData(String data) {
    if (!_isInitialized) throw Exception('Security service not initialized');

    final encrypted = _encrypter.encrypt(data, iv: _iv);
    return encrypted.base64;
  }

  /// Decrypt sensitive healthcare data
  String decryptData(String encryptedData) {
    if (!_isInitialized) throw Exception('Security service not initialized');

    final encrypted = encrypt.Encrypted.fromBase64(encryptedData);
    return _encrypter.decrypt(encrypted, iv: _iv);
  }

  /// Hash data for integrity checks (not reversible)
  String hashData(String data) {
    final bytes = utf8.encode(data);
    final digest = sha256.convert(bytes);
    return digest.toString();
  }

  /// Generate secure random key for encryption
  String generateSecureKey() {
    final random = Random.secure();
    final keyBytes = List<int>.generate(32, (i) => random.nextInt(256));
    return base64Encode(keyBytes);
  }

  /// Log audit event for compliance
  Future<void> logAuditEvent({
    required String userId,
    required String action,
    required String resource,
    String? details,
    String? ipAddress,
    String? userAgent,
  }) async {
    final entry = AuditEntry(
      id: generateSecureKey(),
      timestamp: DateTime.now(),
      userId: userId,
      action: action,
      resource: resource,
      details: details,
      ipAddress: ipAddress,
      userAgent: userAgent,
    );

    _auditLog.add(entry);
    await _saveAuditLog();

    Logger.info('Audit event logged: $action on $resource by $userId');
  }

  /// Record user consent for data processing
  Future<void> recordConsent({
    required String userId,
    required String consentType,
    required bool consented,
    required String purpose,
    String? details,
  }) async {
    final record = ConsentRecord(
      id: generateSecureKey(),
      userId: userId,
      consentType: consentType,
      consented: consented,
      purpose: purpose,
      timestamp: DateTime.now(),
      details: details,
    );

    _consentRecords[record.id] = record;
    await _saveConsentRecords();

    Logger.info('Consent recorded: $consentType for user $userId');
  }

  /// Check if user has consented to specific data processing
  bool hasUserConsented(String userId, String consentType) {
    final userConsents = _consentRecords.values.where((record) =>
        record.userId == userId && record.consentType == consentType);

    if (userConsents.isEmpty) return false;

    // Return the most recent consent
    final latestConsent =
        userConsents.reduce((a, b) => a.timestamp.isAfter(b.timestamp) ? a : b);

    return latestConsent.consented;
  }

  /// Get audit trail for compliance reporting
  List<AuditEntry> getAuditTrail({
    String? userId,
    String? action,
    DateTime? startDate,
    DateTime? endDate,
  }) {
    var filtered = _auditLog;

    if (userId != null) {
      filtered = filtered.where((entry) => entry.userId == userId).toList();
    }

    if (action != null) {
      filtered = filtered.where((entry) => entry.action == action).toList();
    }

    if (startDate != null) {
      filtered = filtered
          .where((entry) => entry.timestamp.isAfter(startDate))
          .toList();
    }

    if (endDate != null) {
      filtered =
          filtered.where((entry) => entry.timestamp.isBefore(endDate)).toList();
    }

    return filtered;
  }

  /// Generate compliance report
  Future<ComplianceReport> generateComplianceReport({
    required DateTime startDate,
    required DateTime endDate,
  }) async {
    final auditEntries = getAuditTrail(startDate: startDate, endDate: endDate);
    final consentRecords = _consentRecords.values
        .where((record) =>
            record.timestamp.isAfter(startDate) &&
            record.timestamp.isBefore(endDate))
        .toList();

    return ComplianceReport(
      period: DateRange(startDate, endDate),
      totalAuditEntries: auditEntries.length,
      totalConsentRecords: consentRecords.length,
      dataAccessEvents:
          auditEntries.where((e) => e.action == 'data_access').length,
      dataModificationEvents:
          auditEntries.where((e) => e.action == 'data_modify').length,
      consentGranted: consentRecords.where((c) => c.consented).length,
      consentRevoked: consentRecords.where((c) => !c.consented).length,
      securityIncidents:
          auditEntries.where((e) => e.action == 'security_incident').length,
    );
  }

  /// Anonymize data for research/analytics (GDPR compliance)
  String anonymizeData(String data) {
    // Remove or hash personally identifiable information
    final anonymized = data
        .replaceAll(RegExp(r'\b\d{3}-\d{2}-\d{4}\b'), 'XXX-XX-XXXX') // SSN
        .replaceAll(
            RegExp(r'\b[A-Za-z0-9._%+-]+@[A-Za-z0-9.-]+\.[A-Z|a-z]{2,}\b'),
            'user@domain.com') // Email
        .replaceAll(RegExp(r'\b\d{10}\b'), 'XXXXXXXXXX'); // Phone

    return hashData(anonymized);
  }

  /// Validate data access permissions (RBAC)
  Future<bool> validateDataAccess({
    required String userId,
    required String resource,
    required String action,
    required List<String> userRoles,
  }) async {
    // Check if user has required permissions based on roles
    final requiredPermissions = _getRequiredPermissions(resource, action);

    final hasPermission =
        userRoles.any((role) => requiredPermissions.contains(role));

    if (!hasPermission) {
      await logAuditEvent(
        userId: userId,
        action: 'access_denied',
        resource: resource,
        details: 'Insufficient permissions for action: $action',
      );
    }

    return hasPermission;
  }

  /// Implement data retention policy
  Future<void> enforceDataRetention() async {
    const retentionPeriod =
        Duration(days: 2555); // ~7 years for medical records
    final cutoffDate = DateTime.now().subtract(retentionPeriod);

    // Remove old audit entries
    _auditLog.removeWhere((entry) => entry.timestamp.isBefore(cutoffDate));

    // Remove old consent records
    _consentRecords
        .removeWhere((key, record) => record.timestamp.isBefore(cutoffDate));

    await _saveAuditLog();
    await _saveConsentRecords();

    Logger.info('Data retention policy enforced');
  }

  // Private helper methods

  Future<void> _initializeEncryption() async {
    final prefs = await SharedPreferences.getInstance();
    String? storedKey = prefs.getString(_encryptionKeyKey);

    if (storedKey == null) {
      storedKey = generateSecureKey();
      await prefs.setString(_encryptionKeyKey, storedKey);
    }

    _encryptionKey = encrypt.Key(base64Decode(storedKey));
    _encrypter = encrypt.Encrypter(encrypt.AES(_encryptionKey));
    _iv = encrypt.IV.fromLength(16);
  }

  Future<void> _loadAuditLog() async {
    final prefs = await SharedPreferences.getInstance();
    final auditJson = prefs.getString(_auditLogKey);

    if (auditJson != null) {
      final auditList = jsonDecode(auditJson) as List;
      _auditLog = auditList.map((item) => AuditEntry.fromJson(item)).toList();
    }
  }

  Future<void> _saveAuditLog() async {
    final prefs = await SharedPreferences.getInstance();
    final auditJson = jsonEncode(_auditLog.map((e) => e.toJson()).toList());
    await prefs.setString(_auditLogKey, auditJson);
  }

  Future<void> _loadConsentRecords() async {
    final prefs = await SharedPreferences.getInstance();
    final consentJson = prefs.getString(_consentLogKey);

    if (consentJson != null) {
      final consentMap = jsonDecode(consentJson) as Map<String, dynamic>;
      _consentRecords = consentMap
          .map((key, value) => MapEntry(key, ConsentRecord.fromJson(value)));
    }
  }

  Future<void> _saveConsentRecords() async {
    final prefs = await SharedPreferences.getInstance();
    final consentJson = jsonEncode(
        _consentRecords.map((key, value) => MapEntry(key, value.toJson())));
    await prefs.setString(_consentLogKey, consentJson);
  }

  List<String> _getRequiredPermissions(String resource, String action) {
    // Define role-based permissions
    const permissions = {
      'patient_data': {
        'read': ['patient', 'doctor', 'admin'],
        'write': ['doctor', 'admin'],
        'delete': ['admin'],
      },
      'medical_records': {
        'read': ['patient', 'doctor', 'admin'],
        'write': ['doctor', 'admin'],
        'delete': ['admin'],
      },
      'system_settings': {
        'read': ['admin'],
        'write': ['admin'],
        'delete': ['admin'],
      },
    };

    return permissions[resource]?[action] ?? ['admin'];
  }
}

// Data classes

class AuditEntry {
  final String id;
  final DateTime timestamp;
  final String userId;
  final String action;
  final String resource;
  final String? details;
  final String? ipAddress;
  final String? userAgent;

  AuditEntry({
    required this.id,
    required this.timestamp,
    required this.userId,
    required this.action,
    required this.resource,
    this.details,
    this.ipAddress,
    this.userAgent,
  });

  Map<String, dynamic> toJson() => {
        'id': id,
        'timestamp': timestamp.toIso8601String(),
        'userId': userId,
        'action': action,
        'resource': resource,
        'details': details,
        'ipAddress': ipAddress,
        'userAgent': userAgent,
      };

  factory AuditEntry.fromJson(Map<String, dynamic> json) {
    return AuditEntry(
      id: json['id'],
      timestamp: DateTime.parse(json['timestamp']),
      userId: json['userId'],
      action: json['action'],
      resource: json['resource'],
      details: json['details'],
      ipAddress: json['ipAddress'],
      userAgent: json['userAgent'],
    );
  }
}

class ConsentRecord {
  final String id;
  final String userId;
  final String consentType;
  final bool consented;
  final String purpose;
  final DateTime timestamp;
  final String? details;

  ConsentRecord({
    required this.id,
    required this.userId,
    required this.consentType,
    required this.consented,
    required this.purpose,
    required this.timestamp,
    this.details,
  });

  Map<String, dynamic> toJson() => {
        'id': id,
        'userId': userId,
        'consentType': consentType,
        'consented': consented,
        'purpose': purpose,
        'timestamp': timestamp.toIso8601String(),
        'details': details,
      };

  factory ConsentRecord.fromJson(Map<String, dynamic> json) {
    return ConsentRecord(
      id: json['id'],
      userId: json['userId'],
      consentType: json['consentType'],
      consented: json['consented'],
      purpose: json['purpose'],
      timestamp: DateTime.parse(json['timestamp']),
      details: json['details'],
    );
  }
}

class ComplianceReport {
  final DateRange period;
  final int totalAuditEntries;
  final int totalConsentRecords;
  final int dataAccessEvents;
  final int dataModificationEvents;
  final int consentGranted;
  final int consentRevoked;
  final int securityIncidents;

  ComplianceReport({
    required this.period,
    required this.totalAuditEntries,
    required this.totalConsentRecords,
    required this.dataAccessEvents,
    required this.dataModificationEvents,
    required this.consentGranted,
    required this.consentRevoked,
    required this.securityIncidents,
  });

  Map<String, dynamic> toJson() => {
        'period': period.toJson(),
        'totalAuditEntries': totalAuditEntries,
        'totalConsentRecords': totalConsentRecords,
        'dataAccessEvents': dataAccessEvents,
        'dataModificationEvents': dataModificationEvents,
        'consentGranted': consentGranted,
        'consentRevoked': consentRevoked,
        'securityIncidents': securityIncidents,
      };
}

class DateRange {
  final DateTime start;
  final DateTime end;

  DateRange(this.start, this.end);

  Map<String, dynamic> toJson() => {
        'start': start.toIso8601String(),
        'end': end.toIso8601String(),
      };
}

class VitalEmergencyData {
  final double heartRate;
  final double oxygenSaturation;
  final bool isCardiacArrest;
  final bool isSeverePain;
  final bool isUnconscious;

  VitalEmergencyData({
    required this.heartRate,
    required this.oxygenSaturation,
    this.isCardiacArrest = false,
    this.isSeverePain = false,
    this.isUnconscious = false,
  });
}

class EmergencyContact {
  final String id;
  final String name;
  final String phoneNumber;
  final String relationship;
  final bool isPrimary;

  EmergencyContact({
    required this.id,
    required this.name,
    required this.phoneNumber,
    required this.relationship,
    this.isPrimary = false,
  });

  Map<String, dynamic> toJson() => {
        'id': id,
        'name': name,
        'phoneNumber': phoneNumber,
        'relationship': relationship,
        'isPrimary': isPrimary,
      };

  factory EmergencyContact.fromJson(Map<String, dynamic> json) {
    return EmergencyContact(
      id: json['id'],
      name: json['name'],
      phoneNumber: json['phoneNumber'],
      relationship: json['relationship'],
      isPrimary: json['isPrimary'] ?? false,
    );
  }
}

class EmergencySettings {
  final bool autoEmergencyEnabled;

  EmergencySettings({
    this.autoEmergencyEnabled = true,
  });

  Map<String, dynamic> toJson() => {
        'autoEmergencyEnabled': autoEmergencyEnabled,
      };

  factory EmergencySettings.fromJson(Map<String, dynamic> json) {
    return EmergencySettings(
      autoEmergencyEnabled: json['autoEmergencyEnabled'] ?? true,
    );
  }
}
