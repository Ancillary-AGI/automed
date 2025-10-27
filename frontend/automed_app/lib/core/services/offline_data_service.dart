import 'dart:convert';
import 'dart:async';
import 'package:flutter/foundation.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'connectivity_service.dart';
import 'cache_service.dart';
import 'storage_service.dart';
import 'api_service.dart';

/// Comprehensive offline data management service for critical healthcare scenarios
class OfflineDataService {
  final CacheService _cacheService;
  final StorageService _storageService;
  final ConnectivityService _connectivityService;
  final ApiService _apiService;
  
  static const String _criticalDataBox = 'critical_healthcare_data';
  static const String _offlineActionsBox = 'offline_actions_queue';
  static const String _emergencyDataBox = 'emergency_data';
  static const String _patientSafetyBox = 'patient_safety_data';
  
  // Critical data retention periods
  static const Duration _criticalDataRetention = Duration(days: 30);
  static const Duration _emergencyDataRetention = Duration(days: 90);
  static const Duration _patientSafetyRetention = Duration(days: 7);
  
  OfflineDataService(
    this._cacheService,
    this._storageService,
    this._connectivityService,
    this._apiService,
  );

  /// Initialize offline data service
  Future<void> initialize() async {
    await _ensureBoxesOpen();
    await _setupPeriodicSync();
    await _cleanupExpiredData();
  }

  // ==================== CRITICAL PATIENT DATA ====================
  
  /// Cache critical patient data that must be available offline
  Future<void> cacheCriticalPatientData(String patientId, CriticalPatientData data) async {
    final box = await _getCriticalDataBox();
    final cacheItem = OfflineCacheItem(
      id: 'critical_patient_$patientId',
      data: data.toJson(),
      timestamp: DateTime.now(),
      expiresAt: DateTime.now().add(_criticalDataRetention),
      priority: CachePriority.critical,
      category: DataCategory.patientCritical,
    );
    
    await box.put('critical_patient_$patientId', cacheItem.toJson());
    
    // Also cache in emergency data for immediate access
    await _cacheEmergencyData('patient_$patientId', data.toJson());
  }

  /// Get critical patient data from offline cache
  Future<CriticalPatientData?> getCriticalPatientData(String patientId) async {
    try {
      final box = await _getCriticalDataBox();
      final cachedData = box.get('critical_patient_$patientId');
      
      if (cachedData != null) {
        final cacheItem = OfflineCacheItem.fromJson(cachedData);
        if (!cacheItem.isExpired) {
          return CriticalPatientData.fromJson(cacheItem.data);
        }
      }
      
      // Fallback to emergency data
      return await _getEmergencyPatientData(patientId);
    } catch (e) {
      debugPrint('Error retrieving critical patient data: $e');
      return null;
    }
  }

  // ==================== EMERGENCY SCENARIOS ====================
  
  /// Cache emergency protocols and procedures
  Future<void> cacheEmergencyProtocols(List<EmergencyProtocol> protocols) async {
    final box = await _getEmergencyDataBox();
    
    for (final protocol in protocols) {
      final cacheItem = OfflineCacheItem(
        id: 'emergency_protocol_${protocol.id}',
        data: protocol.toJson(),
        timestamp: DateTime.now(),
        expiresAt: DateTime.now().add(_emergencyDataRetention),
        priority: CachePriority.critical,
        category: DataCategory.emergency,
      );
      
      await box.put('emergency_protocol_${protocol.id}', cacheItem.toJson());
    }
  }

  /// Get emergency protocol by type
  Future<EmergencyProtocol?> getEmergencyProtocol(String protocolType) async {
    try {
      final box = await _getEmergencyDataBox();
      final keys = box.keys.where((key) => key.toString().startsWith('emergency_protocol_'));
      
      for (final key in keys) {
        final cachedData = box.get(key);
        if (cachedData != null) {
          final cacheItem = OfflineCacheItem.fromJson(cachedData);
          if (!cacheItem.isExpired) {
            final protocol = EmergencyProtocol.fromJson(cacheItem.data);
            if (protocol.type == protocolType) {
              return protocol;
            }
          }
        }
      }
      
      return null;
    } catch (e) {
      debugPrint('Error retrieving emergency protocol: $e');
      return null;
    }
  }

  // ==================== MEDICATION SAFETY ====================
  
  /// Cache critical medication information for offline access
  Future<void> cacheMedicationSafetyData(String medicationId, MedicationSafetyData data) async {
    final box = await _getPatientSafetyBox();
    final cacheItem = OfflineCacheItem(
      id: 'medication_safety_$medicationId',
      data: data.toJson(),
      timestamp: DateTime.now(),
      expiresAt: DateTime.now().add(_patientSafetyRetention),
      priority: CachePriority.high,
      category: DataCategory.medicationSafety,
    );
    
    await box.put('medication_safety_$medicationId', cacheItem.toJson());
  }

  /// Check medication interactions offline
  Future<List<DrugInteraction>> checkMedicationInteractionsOffline(
    List<String> medicationIds,
  ) async {
    final interactions = <DrugInteraction>[];
    
    try {
      final box = await _getPatientSafetyBox();
      
      for (final medicationId in medicationIds) {
        final cachedData = box.get('medication_safety_$medicationId');
        if (cachedData != null) {
          final cacheItem = OfflineCacheItem.fromJson(cachedData);
          if (!cacheItem.isExpired) {
            final safetyData = MedicationSafetyData.fromJson(cacheItem.data);
            
            // Check interactions with other medications
            for (final otherMedId in medicationIds) {
              if (otherMedId != medicationId) {
                final interaction = safetyData.interactions
                    .where((i) => i.medicationId == otherMedId)
                    .firstOrNull;
                if (interaction != null) {
                  interactions.add(interaction);
                }
              }
            }
          }
        }
      }
      
      return interactions;
    } catch (e) {
      debugPrint('Error checking medication interactions offline: $e');
      return [];
    }
  }

  // ==================== VITAL SIGNS MONITORING ====================
  
  /// Cache vital signs thresholds for offline monitoring
  Future<void> cacheVitalSignsThresholds(String patientId, VitalSignsThresholds thresholds) async {
    final box = await _getPatientSafetyBox();
    final cacheItem = OfflineCacheItem(
      id: 'vital_thresholds_$patientId',
      data: thresholds.toJson(),
      timestamp: DateTime.now(),
      expiresAt: DateTime.now().add(_patientSafetyRetention),
      priority: CachePriority.high,
      category: DataCategory.vitalSigns,
    );
    
    await box.put('vital_thresholds_$patientId', cacheItem.toJson());
  }

  /// Validate vital signs against cached thresholds
  Future<List<VitalSignAlert>> validateVitalSignsOffline(
    String patientId,
    VitalSigns vitalSigns,
  ) async {
    final alerts = <VitalSignAlert>[];
    
    try {
      final box = await _getPatientSafetyBox();
      final cachedData = box.get('vital_thresholds_$patientId');
      
      if (cachedData != null) {
        final cacheItem = OfflineCacheItem.fromJson(cachedData);
        if (!cacheItem.isExpired) {
          final thresholds = VitalSignsThresholds.fromJson(cacheItem.data);
          
          // Check each vital sign against thresholds
          if (vitalSigns.heartRate != null) {
            if (vitalSigns.heartRate! < thresholds.heartRateMin ||
                vitalSigns.heartRate! > thresholds.heartRateMax) {
              alerts.add(VitalSignAlert(
                type: VitalSignType.heartRate,
                value: vitalSigns.heartRate!,
                threshold: '${thresholds.heartRateMin}-${thresholds.heartRateMax}',
                severity: _calculateSeverity(vitalSigns.heartRate!, thresholds.heartRateMin, thresholds.heartRateMax),
                timestamp: DateTime.now(),
              ));
            }
          }
          
          // Similar checks for other vital signs...
          // Blood pressure, temperature, oxygen saturation, etc.
        }
      }
      
      return alerts;
    } catch (e) {
      debugPrint('Error validating vital signs offline: $e');
      return [];
    }
  }

  // ==================== OFFLINE ACTIONS QUEUE ====================
  
  /// Queue actions to be performed when connection is restored
  Future<void> queueOfflineAction(OfflineAction action) async {
    final box = await _getOfflineActionsBox();
    final actionId = '${action.type}_${DateTime.now().millisecondsSinceEpoch}';
    
    await box.put(actionId, action.toJson());
    
    // If we're online, try to sync immediately
    if (_connectivityService.isConnected) {
      await _syncOfflineActions();
    }
  }

  /// Get all pending offline actions
  Future<List<OfflineAction>> getPendingOfflineActions() async {
    final box = await _getOfflineActionsBox();
    final actions = <OfflineAction>[];
    
    for (final key in box.keys) {
      final actionData = box.get(key);
      if (actionData != null) {
        try {
          final action = OfflineAction.fromJson(actionData);
          actions.add(action);
        } catch (e) {
          debugPrint('Error parsing offline action: $e');
          // Remove corrupted action
          await box.delete(key);
        }
      }
    }
    
    return actions;
  }

  /// Sync offline actions when connection is restored
  Future<void> syncOfflineActions() async {
    if (!_connectivityService.isConnected) {
      debugPrint('Cannot sync offline actions: No internet connection');
      return;
    }
    
    await _syncOfflineActions();
  }

  // ==================== DATA INTEGRITY & SAFETY ====================
  
  /// Verify data integrity of cached critical data
  Future<DataIntegrityReport> verifyDataIntegrity() async {
    final report = DataIntegrityReport();
    
    try {
      final boxes = [
        await _getCriticalDataBox(),
        await _getEmergencyDataBox(),
        await _getPatientSafetyBox(),
      ];
      
      for (final box in boxes) {
        for (final key in box.keys) {
          final data = box.get(key);
          if (data != null) {
            try {
              final cacheItem = OfflineCacheItem.fromJson(data);
              
              if (cacheItem.isExpired) {
                report.expiredItems++;
              } else if (cacheItem.priority == CachePriority.critical) {
                report.criticalItems++;
              }
              
              report.totalItems++;
            } catch (e) {
              report.corruptedItems++;
              // Remove corrupted data
              await box.delete(key);
            }
          }
        }
      }
      
      report.isHealthy = report.corruptedItems == 0 && report.criticalItems > 0;
      
    } catch (e) {
      debugPrint('Error verifying data integrity: $e');
      report.isHealthy = false;
    }
    
    return report;
  }

  /// Create backup of critical data
  Future<void> createCriticalDataBackup() async {
    try {
      final criticalBox = await _getCriticalDataBox();
      final emergencyBox = await _getEmergencyDataBox();
      
      final backup = {
        'critical_data': criticalBox.toMap(),
        'emergency_data': emergencyBox.toMap(),
        'backup_timestamp': DateTime.now().toIso8601String(),
        'version': '1.0',
      };
      
      await _storageService.saveSecureData('critical_data_backup', backup);
      
    } catch (e) {
      debugPrint('Error creating critical data backup: $e');
    }
  }

  /// Restore critical data from backup
  Future<bool> restoreCriticalDataFromBackup() async {
    try {
      final backup = await _storageService.getSecureData('critical_data_backup');
      if (backup == null) return false;
      
      final criticalBox = await _getCriticalDataBox();
      final emergencyBox = await _getEmergencyDataBox();
      
      // Restore critical data
      final criticalData = backup['critical_data'] as Map?;
      if (criticalData != null) {
        await criticalBox.clear();
        await criticalBox.putAll(criticalData);
      }
      
      // Restore emergency data
      final emergencyData = backup['emergency_data'] as Map?;
      if (emergencyData != null) {
        await emergencyBox.clear();
        await emergencyBox.putAll(emergencyData);
      }
      
      return true;
    } catch (e) {
      debugPrint('Error restoring critical data from backup: $e');
      return false;
    }
  }

  // ==================== PRIVATE METHODS ====================
  
  Future<void> _ensureBoxesOpen() async {
    await Hive.openBox(_criticalDataBox);
    await Hive.openBox(_offlineActionsBox);
    await Hive.openBox(_emergencyDataBox);
    await Hive.openBox(_patientSafetyBox);
  }

  Future<Box> _getCriticalDataBox() async {
    if (!Hive.isBoxOpen(_criticalDataBox)) {
      return await Hive.openBox(_criticalDataBox);
    }
    return Hive.box(_criticalDataBox);
  }

  Future<Box> _getOfflineActionsBox() async {
    if (!Hive.isBoxOpen(_offlineActionsBox)) {
      return await Hive.openBox(_offlineActionsBox);
    }
    return Hive.box(_offlineActionsBox);
  }

  Future<Box> _getEmergencyDataBox() async {
    if (!Hive.isBoxOpen(_emergencyDataBox)) {
      return await Hive.openBox(_emergencyDataBox);
    }
    return Hive.box(_emergencyDataBox);
  }

  Future<Box> _getPatientSafetyBox() async {
    if (!Hive.isBoxOpen(_patientSafetyBox)) {
      return await Hive.openBox(_patientSafetyBox);
    }
    return Hive.box(_patientSafetyBox);
  }

  Future<void> _cacheEmergencyData(String key, Map<String, dynamic> data) async {
    final box = await _getEmergencyDataBox();
    final cacheItem = OfflineCacheItem(
      id: key,
      data: data,
      timestamp: DateTime.now(),
      expiresAt: DateTime.now().add(_emergencyDataRetention),
      priority: CachePriority.critical,
      category: DataCategory.emergency,
    );
    
    await box.put(key, cacheItem.toJson());
  }

  Future<CriticalPatientData?> _getEmergencyPatientData(String patientId) async {
    try {
      final box = await _getEmergencyDataBox();
      final cachedData = box.get('patient_$patientId');
      
      if (cachedData != null) {
        final cacheItem = OfflineCacheItem.fromJson(cachedData);
        if (!cacheItem.isExpired) {
          return CriticalPatientData.fromJson(cacheItem.data);
        }
      }
      
      return null;
    } catch (e) {
      debugPrint('Error retrieving emergency patient data: $e');
      return null;
    }
  }

  Future<void> _setupPeriodicSync() async {
    Timer.periodic(const Duration(minutes: 5), (timer) async {
      if (_connectivityService.isConnected) {
        await _syncOfflineActions();
      }
    });
  }

  Future<void> _syncOfflineActions() async {
    final actions = await getPendingOfflineActions();
    final box = await _getOfflineActionsBox();
    
    for (final action in actions) {
      try {
        // Here you would implement the actual sync logic
        // This is a placeholder for the sync implementation
        final success = await _performOfflineAction(action);
        
        if (success) {
          // Remove successfully synced action
          final keys = box.keys.where((key) {
            final actionData = box.get(key);
            if (actionData != null) {
              final storedAction = OfflineAction.fromJson(actionData);
              return storedAction.id == action.id;
            }
            return false;
          });
          
          for (final key in keys) {
            await box.delete(key);
          }
        }
      } catch (e) {
        debugPrint('Error syncing offline action: $e');
      }
    }
  }

  Future<bool> _performOfflineAction(OfflineAction action) async {
    try {
      switch (action.type) {
        case 'patient_update':
          final response = await _apiService.put('/patients/${action.data['patientId']}', action.data);
          return response != null;
          
        case 'vital_signs_entry':
          final response = await _apiService.post('/patients/${action.data['patientId']}/vitals', action.data);
          return response != null;
          
        case 'medication_administration':
          final response = await _apiService.post('/medications/administration', action.data);
          return response != null;
          
        case 'consultation_notes':
          final response = await _apiService.put('/consultations/${action.data['consultationId']}/notes', action.data);
          return response != null;
          
        case 'emergency_alert':
          final response = await _apiService.post('/emergency/alerts', action.data);
          return response != null;
          
        default:
          debugPrint('Unknown offline action type: ${action.type}');
          return false;
      }
    } catch (e) {
      debugPrint('Error performing offline action: $e');
      return false;
    }
  }

  Future<void> _cleanupExpiredData() async {
    final boxes = [
      await _getCriticalDataBox(),
      await _getEmergencyDataBox(),
      await _getPatientSafetyBox(),
    ];
    
    for (final box in boxes) {
      final keysToDelete = <dynamic>[];
      
      for (final key in box.keys) {
        final data = box.get(key);
        if (data != null) {
          try {
            final cacheItem = OfflineCacheItem.fromJson(data);
            if (cacheItem.isExpired) {
              keysToDelete.add(key);
            }
          } catch (e) {
            // Remove corrupted data
            keysToDelete.add(key);
          }
        }
      }
      
      for (final key in keysToDelete) {
        await box.delete(key);
      }
    }
  }

  AlertSeverity _calculateSeverity(double value, double min, double max) {
    final range = max - min;
    final deviation = value < min ? min - value : value - max;
    final percentDeviation = deviation / range;
    
    if (percentDeviation > 0.5) return AlertSeverity.critical;
    if (percentDeviation > 0.3) return AlertSeverity.high;
    if (percentDeviation > 0.1) return AlertSeverity.medium;
    return AlertSeverity.low;
  }
}

// ==================== DATA MODELS ====================

class OfflineCacheItem {
  final String id;
  final Map<String, dynamic> data;
  final DateTime timestamp;
  final DateTime expiresAt;
  final CachePriority priority;
  final DataCategory category;

  OfflineCacheItem({
    required this.id,
    required this.data,
    required this.timestamp,
    required this.expiresAt,
    required this.priority,
    required this.category,
  });

  bool get isExpired => DateTime.now().isAfter(expiresAt);

  Map<String, dynamic> toJson() => {
    'id': id,
    'data': data,
    'timestamp': timestamp.toIso8601String(),
    'expiresAt': expiresAt.toIso8601String(),
    'priority': priority.index,
    'category': category.index,
  };

  factory OfflineCacheItem.fromJson(Map<String, dynamic> json) => OfflineCacheItem(
    id: json['id'],
    data: json['data'],
    timestamp: DateTime.parse(json['timestamp']),
    expiresAt: DateTime.parse(json['expiresAt']),
    priority: CachePriority.values[json['priority']],
    category: DataCategory.values[json['category']],
  );
}

enum CachePriority { low, medium, high, critical }
enum DataCategory { patientCritical, emergency, medicationSafety, vitalSigns, general }
enum AlertSeverity { low, medium, high, critical }
enum VitalSignType { heartRate, bloodPressure, temperature, oxygenSaturation, respiratoryRate }

class CriticalPatientData {
  final String patientId;
  final String name;
  final DateTime dateOfBirth;
  final List<String> allergies;
  final List<String> chronicConditions;
  final List<String> currentMedications;
  final String bloodType;
  final String emergencyContact;
  final Map<String, dynamic> vitalSignsThresholds;

  CriticalPatientData({
    required this.patientId,
    required this.name,
    required this.dateOfBirth,
    required this.allergies,
    required this.chronicConditions,
    required this.currentMedications,
    required this.bloodType,
    required this.emergencyContact,
    required this.vitalSignsThresholds,
  });

  Map<String, dynamic> toJson() => {
    'patientId': patientId,
    'name': name,
    'dateOfBirth': dateOfBirth.toIso8601String(),
    'allergies': allergies,
    'chronicConditions': chronicConditions,
    'currentMedications': currentMedications,
    'bloodType': bloodType,
    'emergencyContact': emergencyContact,
    'vitalSignsThresholds': vitalSignsThresholds,
  };

  factory CriticalPatientData.fromJson(Map<String, dynamic> json) => CriticalPatientData(
    patientId: json['patientId'],
    name: json['name'],
    dateOfBirth: DateTime.parse(json['dateOfBirth']),
    allergies: List<String>.from(json['allergies']),
    chronicConditions: List<String>.from(json['chronicConditions']),
    currentMedications: List<String>.from(json['currentMedications']),
    bloodType: json['bloodType'],
    emergencyContact: json['emergencyContact'],
    vitalSignsThresholds: json['vitalSignsThresholds'],
  );
}

class EmergencyProtocol {
  final String id;
  final String type;
  final String title;
  final List<String> steps;
  final Map<String, dynamic> parameters;
  final int priority;

  EmergencyProtocol({
    required this.id,
    required this.type,
    required this.title,
    required this.steps,
    required this.parameters,
    required this.priority,
  });

  Map<String, dynamic> toJson() => {
    'id': id,
    'type': type,
    'title': title,
    'steps': steps,
    'parameters': parameters,
    'priority': priority,
  };

  factory EmergencyProtocol.fromJson(Map<String, dynamic> json) => EmergencyProtocol(
    id: json['id'],
    type: json['type'],
    title: json['title'],
    steps: List<String>.from(json['steps']),
    parameters: json['parameters'],
    priority: json['priority'],
  );
}

class MedicationSafetyData {
  final String medicationId;
  final String name;
  final List<DrugInteraction> interactions;
  final List<String> contraindications;
  final Map<String, dynamic> dosageGuidelines;

  MedicationSafetyData({
    required this.medicationId,
    required this.name,
    required this.interactions,
    required this.contraindications,
    required this.dosageGuidelines,
  });

  Map<String, dynamic> toJson() => {
    'medicationId': medicationId,
    'name': name,
    'interactions': interactions.map((i) => i.toJson()).toList(),
    'contraindications': contraindications,
    'dosageGuidelines': dosageGuidelines,
  };

  factory MedicationSafetyData.fromJson(Map<String, dynamic> json) => MedicationSafetyData(
    medicationId: json['medicationId'],
    name: json['name'],
    interactions: (json['interactions'] as List).map((i) => DrugInteraction.fromJson(i)).toList(),
    contraindications: List<String>.from(json['contraindications']),
    dosageGuidelines: json['dosageGuidelines'],
  );
}

class DrugInteraction {
  final String medicationId;
  final String interactionType;
  final String severity;
  final String description;

  DrugInteraction({
    required this.medicationId,
    required this.interactionType,
    required this.severity,
    required this.description,
  });

  Map<String, dynamic> toJson() => {
    'medicationId': medicationId,
    'interactionType': interactionType,
    'severity': severity,
    'description': description,
  };

  factory DrugInteraction.fromJson(Map<String, dynamic> json) => DrugInteraction(
    medicationId: json['medicationId'],
    interactionType: json['interactionType'],
    severity: json['severity'],
    description: json['description'],
  );
}

class VitalSignsThresholds {
  final double heartRateMin;
  final double heartRateMax;
  final double systolicBPMin;
  final double systolicBPMax;
  final double diastolicBPMin;
  final double diastolicBPMax;
  final double temperatureMin;
  final double temperatureMax;
  final double oxygenSaturationMin;

  VitalSignsThresholds({
    required this.heartRateMin,
    required this.heartRateMax,
    required this.systolicBPMin,
    required this.systolicBPMax,
    required this.diastolicBPMin,
    required this.diastolicBPMax,
    required this.temperatureMin,
    required this.temperatureMax,
    required this.oxygenSaturationMin,
  });

  Map<String, dynamic> toJson() => {
    'heartRateMin': heartRateMin,
    'heartRateMax': heartRateMax,
    'systolicBPMin': systolicBPMin,
    'systolicBPMax': systolicBPMax,
    'diastolicBPMin': diastolicBPMin,
    'diastolicBPMax': diastolicBPMax,
    'temperatureMin': temperatureMin,
    'temperatureMax': temperatureMax,
    'oxygenSaturationMin': oxygenSaturationMin,
  };

  factory VitalSignsThresholds.fromJson(Map<String, dynamic> json) => VitalSignsThresholds(
    heartRateMin: json['heartRateMin'],
    heartRateMax: json['heartRateMax'],
    systolicBPMin: json['systolicBPMin'],
    systolicBPMax: json['systolicBPMax'],
    diastolicBPMin: json['diastolicBPMin'],
    diastolicBPMax: json['diastolicBPMax'],
    temperatureMin: json['temperatureMin'],
    temperatureMax: json['temperatureMax'],
    oxygenSaturationMin: json['oxygenSaturationMin'],
  );
}

class VitalSigns {
  final double? heartRate;
  final double? systolicBP;
  final double? diastolicBP;
  final double? temperature;
  final double? oxygenSaturation;
  final double? respiratoryRate;

  VitalSigns({
    this.heartRate,
    this.systolicBP,
    this.diastolicBP,
    this.temperature,
    this.oxygenSaturation,
    this.respiratoryRate,
  });
}

class VitalSignAlert {
  final VitalSignType type;
  final double value;
  final String threshold;
  final AlertSeverity severity;
  final DateTime timestamp;

  VitalSignAlert({
    required this.type,
    required this.value,
    required this.threshold,
    required this.severity,
    required this.timestamp,
  });
}

class OfflineAction {
  final String id;
  final String type;
  final Map<String, dynamic> data;
  final DateTime timestamp;
  final int retryCount;

  OfflineAction({
    required this.id,
    required this.type,
    required this.data,
    required this.timestamp,
    this.retryCount = 0,
  });

  Map<String, dynamic> toJson() => {
    'id': id,
    'type': type,
    'data': data,
    'timestamp': timestamp.toIso8601String(),
    'retryCount': retryCount,
  };

  factory OfflineAction.fromJson(Map<String, dynamic> json) => OfflineAction(
    id: json['id'],
    type: json['type'],
    data: json['data'],
    timestamp: DateTime.parse(json['timestamp']),
    retryCount: json['retryCount'] ?? 0,
  );
}

class DataIntegrityReport {
  int totalItems = 0;
  int criticalItems = 0;
  int expiredItems = 0;
  int corruptedItems = 0;
  bool isHealthy = false;
}