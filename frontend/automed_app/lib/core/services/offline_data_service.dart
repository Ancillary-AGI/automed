import 'dart:convert';

import '../../core/config/app_config.dart';
import 'api_service.dart';
import 'cache_service.dart';
import 'storage_service.dart';

class OfflineDataService {
  final StorageService storageService;
  final CacheService cacheService;
  final AppConfig appConfig;
  final ApiService apiService;

  OfflineDataService({
    required this.storageService,
    required this.cacheService,
    required this.appConfig,
    required this.apiService,
  });

  // Queue for offline actions
  final List<SyncAction> _offlineQueue = [];

  // Sync status
  bool _isOnline = true;
  DateTime? _lastSyncTime;

  // Patient data management
  Future<void> savePatientDataLocally(
      String patientId, Map<String, dynamic> data) async {
    final key = 'patient_$patientId';
    await storageService.saveString(key, jsonEncode(data));
  }

  Future<Map<String, dynamic>?> getPatientDataLocally(String patientId) async {
    final key = 'patient_$patientId';
    final data = storageService.getString(key);
    if (data != null) {
      return jsonDecode(data);
    }
    return null;
  }

  Future<void> savePatientVitalsLocally(
      String patientId, Map<String, dynamic> vitals) async {
    final key = 'vitals_$patientId';
    final existingVitals = await getPatientVitalsLocally(patientId) ?? [];
    existingVitals.add({
      ...vitals,
      'timestamp': DateTime.now().toIso8601String(),
      'synced': false,
    });

    await storageService.saveString(key, jsonEncode(existingVitals));
  }

  Future<List<Map<String, dynamic>>?> getPatientVitalsLocally(
      String patientId) async {
    final key = 'vitals_$patientId';
    final data = storageService.getString(key);
    if (data != null) {
      return List<Map<String, dynamic>>.from(jsonDecode(data));
    }
    return null;
  }

  // Medication management
  Future<void> saveMedicationsLocally(
      List<Map<String, dynamic>> medications) async {
    await storageService.saveString('medications', jsonEncode(medications));
  }

  Future<List<Map<String, dynamic>>?> getMedicationsLocally() async {
    final data = storageService.getString('medications');
    if (data != null) {
      return List<Map<String, dynamic>>.from(jsonDecode(data));
    }
    return null;
  }

  Future<void> saveMedicationAdministrationLocally(
      Map<String, dynamic> administration) async {
    final key = 'medication_admin_${DateTime.now().millisecondsSinceEpoch}';
    await storageService.saveString(key, jsonEncode(administration));

    // Add to offline queue
    addToOfflineQueue(SyncAction(
      id: key,
      type: SyncActionType.medicationAdministration,
      data: administration,
      timestamp: DateTime.now(),
    ));
  }

  // Appointments management
  Future<void> saveAppointmentsLocally(
      List<Map<String, dynamic>> appointments) async {
    await storageService.saveString('appointments', jsonEncode(appointments));
  }

  Future<List<Map<String, dynamic>>?> getAppointmentsLocally() async {
    final data = storageService.getString('appointments');
    if (data != null) {
      return List<Map<String, dynamic>>.from(jsonDecode(data));
    }
    return null;
  }

  // Offline queue management
  void addToOfflineQueue(SyncAction action) {
    _offlineQueue.add(action);
    _saveOfflineQueue();
  }

  void removeFromOfflineQueue(String actionId) {
    _offlineQueue.removeWhere((action) => action.id == actionId);
    _saveOfflineQueue();
  }

  List<SyncAction> getOfflineQueue() {
    return List.unmodifiable(_offlineQueue);
  }

  Future<void> _saveOfflineQueue() async {
    final queueData = _offlineQueue.map((action) => action.toJson()).toList();
    await storageService.saveString('offline_queue', jsonEncode(queueData));
  }

  Future<void> _loadOfflineQueue() async {
    final data = storageService.getString('offline_queue');
    if (data != null) {
      final queueData = List<Map<String, dynamic>>.from(jsonDecode(data));
      _offlineQueue.clear();
      _offlineQueue.addAll(queueData.map((item) => SyncAction.fromJson(item)));
    }
  }

  // Sync operations
  Future<SyncResult> syncData() async {
    if (!_isOnline) {
      return SyncResult(
        success: false,
        message: 'Device is offline',
        syncedItems: 0,
        failedItems: _offlineQueue.length,
      );
    }

    await _loadOfflineQueue();
    int syncedItems = 0;
    int failedItems = 0;
    final errors = <String>[];

    for (final action in List.from(_offlineQueue)) {
      try {
        await _syncAction(action);
        removeFromOfflineQueue(action.id);
        syncedItems++;
      } catch (e) {
        failedItems++;
        errors.add('Failed to sync ${action.type}: $e');
      }
    }

    _lastSyncTime = DateTime.now();
    await storageService.saveString(
        'last_sync_time', _lastSyncTime!.toIso8601String());

    return SyncResult(
      success: failedItems == 0,
      message: failedItems == 0
          ? 'Sync completed successfully'
          : 'Sync completed with errors',
      syncedItems: syncedItems,
      failedItems: failedItems,
      errors: errors,
    );
  }

  Future<void> _syncAction(SyncAction action) async {
    switch (action.type) {
      case SyncActionType.patientUpdate:
        await apiService.put('/patients/${action.data['patientId']}',
            data: action.data);
        break;
      case SyncActionType.vitalsRecording:
        await apiService.post('/patients/${action.data['patientId']}/vitals',
            data: action.data);
        break;
      case SyncActionType.medicationAdministration:
        await apiService.post('/medications/administration', data: action.data);
        break;
      case SyncActionType.appointmentBooking:
        await apiService.post('/appointments', data: action.data);
        break;
      case SyncActionType.emergencyReport:
        await apiService.post('/emergency/report', data: action.data);
        break;
    }
  }

  // Data integrity and backup
  Future<DataIntegrityReport> checkDataIntegrity() async {
    final report = DataIntegrityReport();
    final keys = storageService.getKeys();

    // Check for corrupted data
    for (final key in keys) {
      if (key.startsWith('patient_') ||
          key.startsWith('vitals_') ||
          key.startsWith('medications')) {
        try {
          final data = storageService.getString(key);
          if (data != null) {
            jsonDecode(data); // Try to parse
            report.validItems++;
          }
        } catch (e) {
          report.corruptedItems++;
          report.corruptedKeys.add(key);
        }
      }
    }

    // Check offline queue
    report.pendingSyncItems = _offlineQueue.length;

    // Check storage usage
    final stats = storageService.getStorageStats();
    report.storageUsage = stats;

    // Determine overall health
    report.criticalItems = report.corruptedItems;
    report.warningItems = report.pendingSyncItems > 10 ? 1 : 0;

    return report;
  }

  Future<void> createDataBackup() async {
    final backup = <String, dynamic>{};
    final keys = storageService.getKeys();

    for (final key in keys) {
      if (key.startsWith('patient_') ||
          key.startsWith('vitals_') ||
          key.startsWith('medications') ||
          key.startsWith('appointments')) {
        final data = storageService.getString(key);
        if (data != null) {
          backup[key] = data;
        }
      }
    }

    final backupData = jsonEncode(backup);
    await storageService.saveSecureData('critical_data_backup', backupData);
  }

  Future<void> restoreFromBackup() async {
    final backupData =
        await storageService.getSecureData('critical_data_backup');
    if (backupData != null) {
      final backup = Map<String, dynamic>.from(jsonDecode(backupData));

      for (final entry in backup.entries) {
        await storageService.saveString(entry.key, entry.value);
      }
    }
  }

  // Connectivity management
  void setOnlineStatus(bool isOnline) {
    _isOnline = isOnline;
  }

  bool get isOnline => _isOnline;

  DateTime? get lastSyncTime => _lastSyncTime;

  // Cleanup operations
  Future<void> clearExpiredData() async {
    await storageService.clearExpiredCache();
    await cacheService.clearExpiredCache();
  }

  Future<void> clearAllLocalData() async {
    // Clear storage
    await storageService.clearAll();

    // Clear cache
    await cacheService.clear();

    // Clear offline queue
    _offlineQueue.clear();
    await storageService.remove('offline_queue');
  }

  // Initialization
  Future<void> initialize() async {
    await _loadOfflineQueue();

    // Load last sync time
    final lastSyncString = storageService.getString('last_sync_time');
    if (lastSyncString != null) {
      _lastSyncTime = DateTime.parse(lastSyncString);
    }
  }
}

// Supporting classes
enum SyncActionType {
  patientUpdate,
  vitalsRecording,
  medicationAdministration,
  appointmentBooking,
  emergencyReport,
}

class SyncAction {
  final String id;
  final SyncActionType type;
  final Map<String, dynamic> data;
  final DateTime timestamp;

  SyncAction({
    required this.id,
    required this.type,
    required this.data,
    required this.timestamp,
  });

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'type': type.name,
      'data': data,
      'timestamp': timestamp.toIso8601String(),
    };
  }

  factory SyncAction.fromJson(Map<String, dynamic> json) {
    return SyncAction(
      id: json['id'],
      type: SyncActionType.values.firstWhere((e) => e.name == json['type']),
      data: json['data'],
      timestamp: DateTime.parse(json['timestamp']),
    );
  }
}

class SyncResult {
  final bool success;
  final String message;
  final int syncedItems;
  final int failedItems;
  final List<String>? errors;

  SyncResult({
    required this.success,
    required this.message,
    required this.syncedItems,
    required this.failedItems,
    this.errors,
  });
}

class DataIntegrityReport {
  int validItems = 0;
  int corruptedItems = 0;
  int pendingSyncItems = 0;
  int criticalItems = 0;
  int warningItems = 0;
  final List<String> corruptedKeys = [];
  late final Map<String, dynamic> storageUsage;

  bool get hasIssues =>
      corruptedItems > 0 || warningItems > 0 || criticalItems > 0;
}
