import 'package:hive/hive.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:automed_app/core/models/sync_models.dart';
import 'package:automed_app/core/utils/logger.dart';

class OfflineStorageService {
  static const String _patientsBoxName = 'patients';
  static const String _vitalsBoxName = 'vitals';
  static const String _medicationsBoxName = 'medications';
  static const String _consultationsBoxName = 'consultations';
  static const String _syncActionsBoxName = 'sync_actions';

  late Box _patientsBox;
  late Box _vitalsBox;
  late Box _medicationsBox;
  late Box _consultationsBox;
  late Box _syncActionsBox;

  Future<void> initialize() async {
    try {
      _patientsBox = await Hive.openBox(_patientsBoxName);
      _vitalsBox = await Hive.openBox(_vitalsBoxName);
      _medicationsBox = await Hive.openBox(_medicationsBoxName);
      _consultationsBox = await Hive.openBox(_consultationsBoxName);
      _syncActionsBox = await Hive.openBox(_syncActionsBoxName);

      Logger.info('Offline storage initialized successfully');
    } catch (e) {
      Logger.error('Failed to initialize offline storage', e);
      rethrow;
    }
  }

  // Patient data methods
  Future<void> savePatient(Map<String, dynamic> patient) async {
    try {
      await _patientsBox.put(patient['id'], patient);
      await _queueSyncAction('CREATE', 'patient', patient['id'], patient);
      Logger.info('Patient saved offline: ${patient['id']}');
    } catch (e) {
      Logger.error('Failed to save patient offline', e);
    }
  }

  Future<Map<String, dynamic>?> getPatient(String patientId) async {
    try {
      final patient = _patientsBox.get(patientId);
      return patient != null ? Map<String, dynamic>.from(patient) : null;
    } catch (e) {
      Logger.error('Failed to get patient from offline storage', e);
      return null;
    }
  }

  Future<List<Map<String, dynamic>>> getAllPatients() async {
    try {
      return _patientsBox.values
          .map((patient) => Map<String, dynamic>.from(patient))
          .toList();
    } catch (e) {
      Logger.error('Failed to get all patients from offline storage', e);
      return [];
    }
  }

  Future<void> updatePatient(
      String patientId, Map<String, dynamic> updates) async {
    try {
      final existingPatient = _patientsBox.get(patientId);
      if (existingPatient != null) {
        final updatedPatient = Map<String, dynamic>.from(existingPatient)
          ..addAll(updates);
        await _patientsBox.put(patientId, updatedPatient);
        await _queueSyncAction('UPDATE', 'patient', patientId, updates);
        Logger.info('Patient updated offline: $patientId');
      }
    } catch (e) {
      Logger.error('Failed to update patient offline', e);
    }
  }

  // Vitals data methods
  Future<void> saveVitals(Map<String, dynamic> vitals) async {
    try {
      final key = '${vitals['patientId']}_${vitals['timestamp']}';
      await _vitalsBox.put(key, vitals);
      await _queueSyncAction('CREATE', 'vitals', key, vitals);
      Logger.info('Vitals saved offline: $key');
    } catch (e) {
      Logger.error('Failed to save vitals offline', e);
    }
  }

  Future<List<Map<String, dynamic>>> getPatientVitals(String patientId) async {
    try {
      final allVitals = _vitalsBox.values
          .map((vital) => Map<String, dynamic>.from(vital))
          .where((vital) => vital['patientId'] == patientId)
          .toList();

      // Sort by timestamp (most recent first)
      allVitals.sort(
          (a, b) => (b['timestamp'] as int).compareTo(a['timestamp'] as int));
      return allVitals;
    } catch (e) {
      Logger.error('Failed to get patient vitals from offline storage', e);
      return [];
    }
  }

  // Medication data methods
  Future<void> saveMedication(Map<String, dynamic> medication) async {
    try {
      await _medicationsBox.put(medication['id'], medication);
      await _queueSyncAction(
          'CREATE', 'medication', medication['id'], medication);
      Logger.info('Medication saved offline: ${medication['id']}');
    } catch (e) {
      Logger.error('Failed to save medication offline', e);
    }
  }

  Future<List<Map<String, dynamic>>> getPatientMedications(
      String patientId) async {
    try {
      return _medicationsBox.values
          .map((medication) => Map<String, dynamic>.from(medication))
          .where((medication) => medication['patientId'] == patientId)
          .toList();
    } catch (e) {
      Logger.error('Failed to get patient medications from offline storage', e);
      return [];
    }
  }

  Future<void> updateMedicationStatus(
      String medicationId, String status) async {
    try {
      final medication = _medicationsBox.get(medicationId);
      if (medication != null) {
        final updatedMedication = Map<String, dynamic>.from(medication)
          ..['status'] = status
          ..['lastUpdated'] = DateTime.now().millisecondsSinceEpoch;

        await _medicationsBox.put(medicationId, updatedMedication);
        await _queueSyncAction(
            'UPDATE', 'medication', medicationId, {'status': status});
        Logger.info(
            'Medication status updated offline: $medicationId -> $status');
      }
    } catch (e) {
      Logger.error('Failed to update medication status offline', e);
    }
  }

  // Consultation data methods
  Future<void> saveConsultation(Map<String, dynamic> consultation) async {
    try {
      await _consultationsBox.put(consultation['id'], consultation);
      await _queueSyncAction(
          'CREATE', 'consultation', consultation['id'], consultation);
      Logger.info('Consultation saved offline: ${consultation['id']}');
    } catch (e) {
      Logger.error('Failed to save consultation offline', e);
    }
  }

  Future<List<Map<String, dynamic>>> getPatientConsultations(
      String patientId) async {
    try {
      return _consultationsBox.values
          .map((consultation) => Map<String, dynamic>.from(consultation))
          .where((consultation) => consultation['patientId'] == patientId)
          .toList();
    } catch (e) {
      Logger.error(
          'Failed to get patient consultations from offline storage', e);
      return [];
    }
  }

  // Sync actions methods
  Future<void> _queueSyncAction(
    String operation,
    String entityType,
    String entityId,
    Map<String, dynamic> data,
  ) async {
    try {
      final syncAction = SyncActionRecord(
        id: '${entityType}_${entityId}_${DateTime.now().millisecondsSinceEpoch}',
        type: operation,
        entityId: entityId,
        data: data,
        timestamp: DateTime.now(),
        actionType: _getActionType(operation),
      );

      await _syncActionsBox.put(syncAction.id, syncAction.toJson());
      Logger.debug('Sync action queued: ${syncAction.id}');
    } catch (e) {
      Logger.error('Failed to queue sync action', e);
    }
  }

  ActionType _getActionType(String operation) {
    switch (operation.toUpperCase()) {
      case 'CREATE':
        return ActionType.create;
      case 'UPDATE':
        return ActionType.update;
      case 'DELETE':
        return ActionType.delete;
      default:
        return ActionType.create;
    }
  }

  Future<List<SyncActionRecord>> getPendingSyncActions() async {
    try {
      return _syncActionsBox.values
          .map((action) =>
              SyncActionRecord.fromJson(Map<String, dynamic>.from(action)))
          .toList();
    } catch (e) {
      Logger.error('Failed to get pending sync actions', e);
      return [];
    }
  }

  Future<void> removeSyncAction(String actionId) async {
    try {
      await _syncActionsBox.delete(actionId);
      Logger.debug('Sync action removed: $actionId');
    } catch (e) {
      Logger.error('Failed to remove sync action', e);
    }
  }

  Future<void> clearSyncActions() async {
    try {
      await _syncActionsBox.clear();
      Logger.info('All sync actions cleared');
    } catch (e) {
      Logger.error('Failed to clear sync actions', e);
    }
  }

  // Search methods
  Future<List<Map<String, dynamic>>> searchPatients(String query) async {
    try {
      final allPatients = await getAllPatients();
      final lowercaseQuery = query.toLowerCase();

      return allPatients.where((patient) {
        final firstName = (patient['firstName'] as String? ?? '').toLowerCase();
        final lastName = (patient['lastName'] as String? ?? '').toLowerCase();
        final email = (patient['email'] as String? ?? '').toLowerCase();
        final patientId = (patient['patientId'] as String? ?? '').toLowerCase();

        return firstName.contains(lowercaseQuery) ||
            lastName.contains(lowercaseQuery) ||
            email.contains(lowercaseQuery) ||
            patientId.contains(lowercaseQuery);
      }).toList();
    } catch (e) {
      Logger.error('Failed to search patients', e);
      return [];
    }
  }

  // Statistics methods
  Future<Map<String, int>> getStorageStats() async {
    try {
      return {
        'patients': _patientsBox.length,
        'vitals': _vitalsBox.length,
        'medications': _medicationsBox.length,
        'consultations': _consultationsBox.length,
        'pendingSyncActions': _syncActionsBox.length,
      };
    } catch (e) {
      Logger.error('Failed to get storage stats', e);
      return {};
    }
  }

  // Cleanup methods
  Future<void> clearAllData() async {
    try {
      await _patientsBox.clear();
      await _vitalsBox.clear();
      await _medicationsBox.clear();
      await _consultationsBox.clear();
      await _syncActionsBox.clear();
      Logger.info('All offline data cleared');
    } catch (e) {
      Logger.error('Failed to clear all offline data', e);
    }
  }

  Future<void> clearOldData({int daysToKeep = 30}) async {
    try {
      final cutoffTime = DateTime.now()
          .subtract(Duration(days: daysToKeep))
          .millisecondsSinceEpoch;

      // Clear old vitals
      final vitalsToRemove = <String>[];
      for (final entry in _vitalsBox.toMap().entries) {
        final vital = Map<String, dynamic>.from(entry.value);
        if ((vital['timestamp'] as int? ?? 0) < cutoffTime) {
          vitalsToRemove.add(entry.key.toString());
        }
      }

      for (final key in vitalsToRemove) {
        await _vitalsBox.delete(key);
      }

      Logger.info('Cleared ${vitalsToRemove.length} old vital records');
    } catch (e) {
      Logger.error('Failed to clear old data', e);
    }
  }

  Future<void> dispose() async {
    try {
      await _patientsBox.close();
      await _vitalsBox.close();
      await _medicationsBox.close();
      await _consultationsBox.close();
      await _syncActionsBox.close();
      Logger.info('Offline storage disposed');
    } catch (e) {
      Logger.error('Failed to dispose offline storage', e);
    }
  }
}

// Provider
final offlineStorageServiceProvider = Provider<OfflineStorageService>((ref) {
  throw UnimplementedError(
      'OfflineStorageService must be initialized in main()');
});
