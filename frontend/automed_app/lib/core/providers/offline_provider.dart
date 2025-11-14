import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter/foundation.dart';
import 'package:connectivity_plus/connectivity_plus.dart';
import '../di/injection.dart';
import '../services/offline_data_service.dart';
import '../services/connectivity_service.dart';
import '../services/api_service.dart';
import '../services/notification_service.dart' as notification_service;
import '../models/sync_models.dart' as sync_models;

enum ConnectivityStatus {
  unknown,
  connected,
  disconnected,
}

enum SyncStatus {
  unknown,
  syncing,
  success,
  failed,
  offline,
  pending,
}

final offlineProvider =
    StateNotifierProvider<OfflineNotifier, OfflineState>((ref) {
  return OfflineNotifier(
    ref.read(offlineDataServiceProvider),
    ref.read(connectivityServiceProvider),
    ref.read(apiServiceProvider),
    ref.read(notificationServiceProvider),
  );
});

class OfflineNotifier extends StateNotifier<OfflineState> {
  final OfflineDataService _offlineDataService;
  final ConnectivityService _connectivityService;
  final ApiService _apiService;
  final notification_service.NotificationService _notificationService;

  OfflineNotifier(
    this._offlineDataService,
    this._connectivityService,
    this._apiService,
    this._notificationService,
  ) : super(const OfflineState()) {
    _initialize();
  }

  Future<void> _initialize() async {
    // Listen to connectivity changes
    _connectivityService.connectivityStream.listen((status) {
      _handleConnectivityChange(status);
    });

    // Initialize offline data service
    await _offlineDataService.initialize();

    // Check initial connectivity and data integrity
    await _checkDataIntegrity();
    await _syncIfConnected();
  }

  void _handleConnectivityChange(List<ConnectivityResult> results) {
    final wasOffline = state.isOffline;
    final isNowOffline =
        results.any((result) => result == ConnectivityResult.none);

    state = state.copyWith(
      connectivityStatus: isNowOffline
          ? ConnectivityStatus.disconnected
          : ConnectivityStatus.connected,
      isOffline: isNowOffline,
      lastConnectivityChange: DateTime.now(),
    );

    if (wasOffline && !isNowOffline) {
      // Just came back online
      _handleBackOnline();
    } else if (!wasOffline && isNowOffline) {
      // Just went offline
      _handleGoingOffline();
    }
  }

  Future<void> _handleBackOnline() async {
    state = state.copyWith(isSyncing: true);

    try {
      // Sync offline actions
      await _offlineDataService.syncOfflineActions();

      // Refresh critical data
      await _refreshCriticalData();

      // Update sync status
      state = state.copyWith(
        lastSyncTime: DateTime.now(),
        syncStatus: SyncStatus.success,
        isSyncing: false,
      );

      // Show success notification
      await _notificationService.showNotification(
        id: 'sync_success_${DateTime.now().millisecondsSinceEpoch}',
        title: 'Back Online',
        body: 'Data synchronized successfully',
        type: notification_service.NotificationType.success,
      );
    } catch (e) {
      state = state.copyWith(
        syncStatus: SyncStatus.failed,
        isSyncing: false,
        lastError: e.toString(),
      );

      // Show error notification
      await _notificationService.showNotification(
        id: 'sync_error_${DateTime.now().millisecondsSinceEpoch}',
        title: 'Sync Failed',
        body: 'Failed to synchronize data: ${e.toString()}',
        type: notification_service.NotificationType.error,
      );
    }
  }

  Future<void> _handleGoingOffline() async {
    // Create backup of critical data
    await _offlineDataService.createCriticalDataBackup();

    // Show offline notification
    await _notificationService.showNotification(
      id: 'offline_mode_${DateTime.now().millisecondsSinceEpoch}',
      title: 'Offline Mode',
      body: 'Working offline with cached data',
      type: notification_service.NotificationType.warning,
    );

    state = state.copyWith(
      syncStatus: SyncStatus.failed,
    );
  }

  Future<void> _checkDataIntegrity() async {
    try {
      final report = await _offlineDataService.checkDataIntegrity();

      state = state.copyWith(
        dataIntegrityReport: report,
        hasCorruptedData: report.corruptedItems > 0,
      );

      if (report.hasIssues) {
        await _notificationService.showNotification(
          id: 'data_integrity_warning_${DateTime.now().millisecondsSinceEpoch}',
          title: 'Data Integrity Warning',
          body: 'Some cached data may be corrupted or expired',
          type: notification_service.NotificationType.warning,
        );
      }
    } catch (e) {
      debugPrint('Error checking data integrity: $e');
    }
  }

  Future<void> _syncIfConnected() async {
    final isConnected = await _connectivityService.isConnected;
    if (isConnected) {
      await _handleBackOnline();
    }
  }

  Future<void> _refreshCriticalData() async {
    // Fetch and cache the latest critical data from the server
    try {
      // Refresh emergency protocols
      final protocols = await _apiService.get('/emergency/protocols');
      final protocolList = protocols['data'] as List<Map<String, dynamic>>;
      await _offlineDataService.cacheEmergencyProtocols(protocolList);
    
      // Refresh medication safety data
      final medications = await _apiService.get('/medications/safety-data');
      for (final med in medications['data'] as List<Map<String, dynamic>>) {
        await _offlineDataService.cacheMedicationSafetyData(
          med['medicationId'] as String,
          med,
        );
      }
        } catch (e) {
      debugPrint('Error refreshing critical data: $e');
    }
  }

  // Public methods for UI interaction

  /// Get critical patient data (works offline)
  Future<sync_models.CriticalPatientData?> getCriticalPatientData(
      String patientId) async {
    try {
      final json = await _offlineDataService.getCriticalPatientData(patientId);
      return json != null
          ? sync_models.CriticalPatientData.fromJson(json)
          : null;
    } catch (e) {
      state = state.copyWith(lastError: e.toString());
      return null;
    }
  }

  /// Cache critical patient data for offline access
  Future<void> cacheCriticalPatientData(
      String patientId, sync_models.CriticalPatientData data) async {
    try {
      await _offlineDataService.cacheCriticalPatientData(
          patientId, data.toJson());
    } catch (e) {
      state = state.copyWith(lastError: e.toString());
    }
  }

  /// Get emergency protocol (works offline)
  Future<sync_models.EmergencyProtocol?> getEmergencyProtocol(
      String protocolType) async {
    try {
      final json = await _offlineDataService.getEmergencyProtocol(protocolType);
      return json != null ? sync_models.EmergencyProtocol.fromJson(json) : null;
    } catch (e) {
      state = state.copyWith(lastError: e.toString());
      return null;
    }
  }

  /// Check medication interactions offline
  Future<List<sync_models.DrugInteraction>> checkMedicationInteractions(
      List<String> medicationIds) async {
    try {
      final jsonList = await _offlineDataService
          .checkMedicationInteractionsOffline(medicationIds);
      return jsonList
          .map((json) => sync_models.DrugInteraction.fromJson(json))
          .toList();
    } catch (e) {
      state = state.copyWith(lastError: e.toString());
      return [];
    }
  }

  /// Validate vital signs against cached thresholds
  Future<List<sync_models.VitalSignAlert>> validateVitalSigns(
      String patientId, sync_models.VitalSigns vitalSigns) async {
    try {
      final jsonList = await _offlineDataService.validateVitalSignsOffline(
          patientId, vitalSigns.toJson());
      return jsonList
          .map((json) => sync_models.VitalSignAlert.fromJson(json))
          .toList();
    } catch (e) {
      state = state.copyWith(lastError: e.toString());
      return [];
    }
  }

  /// Queue an action to be performed when online
  Future<void> queueOfflineAction(sync_models.OfflineAction action) async {
    try {
      await _offlineDataService.queueOfflineAction(action.toJson());

      final pendingActions =
          await _offlineDataService.getPendingOfflineActions();
      state = state.copyWith(pendingActionsCount: pendingActions.length);
    } catch (e) {
      state = state.copyWith(lastError: e.toString());
    }
  }

  /// Manually trigger sync (if online)
  Future<void> manualSync() async {
    final isConnected = await _connectivityService.isConnected;
    if (!isConnected) {
      await _notificationService.showNotification(
        id: 'sync_failed_${DateTime.now().millisecondsSinceEpoch}',
        title: 'Sync Failed',
        body: 'No internet connection available',
        type: notification_service.NotificationType.error,
      );
      return;
    }

    await _handleBackOnline();
  }

  /// Force data integrity check
  Future<void> checkDataIntegrity() async {
    await _checkDataIntegrity();
  }

  /// Restore data from backup
  Future<bool> restoreFromBackup() async {
    try {
      final success = await _offlineDataService.restoreCriticalDataFromBackup();

      if (success) {
        await _notificationService.showNotification(
          id: 'data_restored_${DateTime.now().millisecondsSinceEpoch}',
          title: 'Data Restored',
          body: 'Critical data restored from backup',
          type: notification_service.NotificationType.success,
        );

        // Refresh data integrity report
        await _checkDataIntegrity();
      }

      return success;
    } catch (e) {
      state = state.copyWith(lastError: e.toString());
      return false;
    }
  }

  /// Get offline capabilities status
  OfflineCapabilities getOfflineCapabilities() {
    final hasCriticalData = (state.dataIntegrityReport?.criticalItems ?? 0) > 0;
    return OfflineCapabilities(
      canAccessPatientData: hasCriticalData,
      canCheckMedications: true, // Always available if cached
      canAccessEmergencyProtocols: true, // Always available if cached
      canValidateVitalSigns: true, // Always available if thresholds cached
      canQueueActions: true, // Always available
      estimatedOfflineTime: _estimateOfflineTime(),
    );
  }

  Duration _estimateOfflineTime() {
    // Estimate how long the app can work offline based on cached data
    final report = state.dataIntegrityReport;
    if (report == null || report.criticalItems == 0) {
      return const Duration(hours: 1); // Minimal offline time
    }

    // Estimate based on data freshness and amount
    if (report.criticalItems > 10 && !report.hasIssues) {
      return const Duration(days: 7); // Good offline capability
    } else if (report.criticalItems > 5) {
      return const Duration(days: 3); // Moderate offline capability
    } else {
      return const Duration(hours: 24); // Limited offline capability
    }
  }
}

class OfflineState {
  final ConnectivityStatus connectivityStatus;
  final bool isOffline;
  final bool isSyncing;
  final SyncStatus syncStatus;
  final DateTime? lastSyncTime;
  final DateTime? lastConnectivityChange;
  final DataIntegrityReport? dataIntegrityReport;
  final bool hasCorruptedData;
  final int pendingActionsCount;
  final String? lastError;

  const OfflineState({
    this.connectivityStatus = ConnectivityStatus.unknown,
    this.isOffline = false,
    this.isSyncing = false,
    this.syncStatus = SyncStatus.pending,
    this.lastSyncTime,
    this.lastConnectivityChange,
    this.dataIntegrityReport,
    this.hasCorruptedData = false,
    this.pendingActionsCount = 0,
    this.lastError,
  });

  OfflineState copyWith({
    ConnectivityStatus? connectivityStatus,
    bool? isOffline,
    bool? isSyncing,
    SyncStatus? syncStatus,
    DateTime? lastSyncTime,
    DateTime? lastConnectivityChange,
    DataIntegrityReport? dataIntegrityReport,
    bool? hasCorruptedData,
    int? pendingActionsCount,
    String? lastError,
  }) {
    return OfflineState(
      connectivityStatus: connectivityStatus ?? this.connectivityStatus,
      isOffline: isOffline ?? this.isOffline,
      isSyncing: isSyncing ?? this.isSyncing,
      syncStatus: syncStatus ?? this.syncStatus,
      lastSyncTime: lastSyncTime ?? this.lastSyncTime,
      lastConnectivityChange:
          lastConnectivityChange ?? this.lastConnectivityChange,
      dataIntegrityReport: dataIntegrityReport ?? this.dataIntegrityReport,
      hasCorruptedData: hasCorruptedData ?? this.hasCorruptedData,
      pendingActionsCount: pendingActionsCount ?? this.pendingActionsCount,
      lastError: lastError,
    );
  }

  bool get canWorkOffline => !(dataIntegrityReport?.hasIssues ?? true);
  bool get hasRecentSync =>
      lastSyncTime != null &&
      DateTime.now().difference(lastSyncTime!).inHours < 24;
}

class OfflineCapabilities {
  final bool canAccessPatientData;
  final bool canCheckMedications;
  final bool canAccessEmergencyProtocols;
  final bool canValidateVitalSigns;
  final bool canQueueActions;
  final Duration estimatedOfflineTime;

  OfflineCapabilities({
    required this.canAccessPatientData,
    required this.canCheckMedications,
    required this.canAccessEmergencyProtocols,
    required this.canValidateVitalSigns,
    required this.canQueueActions,
    required this.estimatedOfflineTime,
  });

  bool get hasBasicCapabilities =>
      canAccessPatientData &&
      canCheckMedications &&
      canAccessEmergencyProtocols;

  bool get hasFullCapabilities =>
      hasBasicCapabilities && canValidateVitalSigns && canQueueActions;
}
