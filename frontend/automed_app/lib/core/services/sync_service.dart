import '../../core/config/app_config.dart';
import 'api_service.dart';
import 'connectivity_service.dart';
import 'offline_data_service.dart';

class SyncService {
  final ApiService apiService;
  final OfflineDataService offlineDataService;
  final ConnectivityService connectivityService;
  final AppConfig appConfig;

  SyncService({
    required this.apiService,
    required this.offlineDataService,
    required this.connectivityService,
    required this.appConfig,
  });

  Future<SyncResult> performFullSync() async {
    if (!await connectivityService.isConnected) {
      return SyncResult.failure('No internet connection');
    }

    try {
      final results = await Future.wait([
        _syncPatientData(),
        _syncMedications(),
        _syncAppointments(),
        _syncOfflineActions(),
      ]);

      final totalSynced =
          results.fold<int>(0, (sum, result) => sum + result.syncedItems);
      final totalFailed =
          results.fold<int>(0, (sum, result) => sum + result.failedItems);
      final allErrors = results.expand((result) => result.errors).toList();

      return SyncResult(
        success: totalFailed == 0,
        syncedItems: totalSynced,
        failedItems: totalFailed,
        errors: allErrors,
        message: totalFailed == 0
            ? 'Full sync completed successfully'
            : 'Sync completed with $totalFailed errors',
      );
    } catch (e) {
      return SyncResult.failure('Sync failed: $e');
    }
  }

  Future<SyncResult> syncPatientData() async {
    return _syncPatientData();
  }

  Future<SyncResult> syncMedications() async {
    return _syncMedications();
  }

  Future<SyncResult> syncAppointments() async {
    return _syncAppointments();
  }

  Future<SyncResult> syncOfflineActions() async {
    return _syncOfflineActions();
  }

  Future<SyncResult> _syncPatientData() async {
    try {
      // Get local patient data
      final localPatients = await _getLocalPatientData();

      if (localPatients.isEmpty) {
        return SyncResult.success('No patient data to sync');
      }

      int synced = 0;
      int failed = 0;
      final errors = <String>[];

      for (final patient in localPatients) {
        try {
          await apiService.updatePatient(patient['id'], patient);
          synced++;
        } catch (e) {
          failed++;
          errors.add('Failed to sync patient ${patient['id']}: $e');
        }
      }

      return SyncResult(
        success: failed == 0,
        syncedItems: synced,
        failedItems: failed,
        errors: errors,
      );
    } catch (e) {
      return SyncResult.failure('Patient data sync failed: $e');
    }
  }

  Future<SyncResult> _syncMedications() async {
    try {
      final localMedications = await offlineDataService.getMedicationsLocally();

      if (localMedications == null || localMedications.isEmpty) {
        return SyncResult.success('No medications to sync');
      }

      // Sync medications with server
      await apiService.post('/medications/sync', data: {
        'medications': localMedications,
      });

      return SyncResult.success('Medications synced successfully');
    } catch (e) {
      return SyncResult.failure('Medications sync failed: $e');
    }
  }

  Future<SyncResult> _syncAppointments() async {
    try {
      final localAppointments =
          await offlineDataService.getAppointmentsLocally();

      if (localAppointments == null || localAppointments.isEmpty) {
        return SyncResult.success('No appointments to sync');
      }

      // Sync appointments with server
      await apiService.post('/appointments/sync', data: {
        'appointments': localAppointments,
      });

      return SyncResult.success('Appointments synced successfully');
    } catch (e) {
      return SyncResult.failure('Appointments sync failed: $e');
    }
  }

  Future<SyncResult> _syncOfflineActions() async {
    final result = await offlineDataService.syncData();
    return SyncResult(
      success: result.success,
      message: result.message,
      syncedItems: result.syncedItems,
      failedItems: result.failedItems,
      errors: result.errors ?? [],
    );
  }

  Future<List<Map<String, dynamic>>> _getLocalPatientData() async {
    // This would typically query a local database
    // For now, return empty list as we don't have local patient storage implemented
    return [];
  }

  Future<void> schedulePeriodicSync(
      {Duration interval = const Duration(minutes: 15)}) async {
    // This would typically use a background task scheduler
    // For now, it's a placeholder
  }

  Future<void> cancelPeriodicSync() async {
    // Cancel any scheduled sync tasks
  }

  Future<SyncStatus> getSyncStatus() async {
    final isOnline = await connectivityService.isConnected;
    final lastSyncTime = offlineDataService.lastSyncTime;
    final pendingActions = offlineDataService.getOfflineQueue().length;

    return SyncStatus(
      isOnline: isOnline,
      lastSyncTime: lastSyncTime,
      pendingActions: pendingActions,
      isSyncing: false, // This would be tracked separately
    );
  }

  Stream<SyncStatus> get syncStatusStream {
    // This would provide real-time sync status updates
    // For now, return empty stream
    return const Stream.empty();
  }

  Future<void> forceSync() async {
    await performFullSync();
  }

  Future<void> clearSyncData() async {
    // Clear any cached sync data
  }
}

class SyncResult {
  final bool success;
  final String message;
  final int syncedItems;
  final int failedItems;
  final List<String> errors;

  SyncResult({
    required this.success,
    this.message = '',
    this.syncedItems = 0,
    this.failedItems = 0,
    this.errors = const [],
  });

  factory SyncResult.success(String message, {int syncedItems = 0}) {
    return SyncResult(
      success: true,
      message: message,
      syncedItems: syncedItems,
    );
  }

  factory SyncResult.failure(String message, {int failedItems = 0}) {
    return SyncResult(
      success: false,
      message: message,
      failedItems: failedItems,
    );
  }
}

class SyncStatus {
  final bool isOnline;
  final DateTime? lastSyncTime;
  final int pendingActions;
  final bool isSyncing;

  SyncStatus({
    required this.isOnline,
    this.lastSyncTime,
    required this.pendingActions,
    required this.isSyncing,
  });

  bool get hasPendingActions => pendingActions > 0;
  bool get needsSync => hasPendingActions && isOnline;
}
