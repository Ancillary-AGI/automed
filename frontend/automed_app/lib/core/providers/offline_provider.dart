import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter/foundation.dart';
import '../services/offline_data_service.dart';
import '../services/connectivity_service.dart';
import '../services/api_service.dart';
import '../services/notification_service.dart';

final offlineProvider = StateNotifierProvider<OfflineNotifier, OfflineState>((ref) {
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
  final NotificationService _notificationService;

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

  void _handleConnectivityChange(ConnectivityStatus status) {
    final wasOffline = state.isOffline;
    final isNowOffline = status == ConnectivityStatus.disconnected;

    state = state.copyWith(
      connectivityStatus: status,
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
        title: 'Back Online',
        body: 'Data synchronized successfully',
        type: NotificationType.success,
      );

    } catch (e) {
      state = state.copyWith(
        syncStatus: SyncStatus.failed,
        isSyncing: false,
        lastError: e.toString(),
      );

      // Show error notification
      await _notificationService.showNotification(
        title: 'Sync Failed',
        body: 'Failed to synchronize data: ${e.toString()}',
        type: NotificationType.error,
      );
    }
  }

  Future<void> _handleGoingOffline() async {
    // Create backup of critical data
    await _offlineDataService.createCriticalDataBackup();

    // Show offline notification
    await _notificationService.showNotification(
      title: 'Offline Mode',
      body: 'Working offline with cached data',
      type: NotificationType.warning,
    );

    state = state.copyWith(
      syncStatus: SyncStatus.offline,
    );
  }

  Future<void> _checkDataIntegrity() async {
    try {
      final report = await _offlineDataService.verifyDataIntegrity();
      
      state = state.copyWith(
        dataIntegrityReport: report,
        hasCorruptedData: report.corruptedItems > 0,
      );

      if (!report.isHealthy) {
        await _notificationService.showNotification(
          title: 'Data Integrity Warning',
          body: 'Some cached data may be corrupted or expired',
          type: NotificationType.warning,
        );
      }
    } catch (e) {
      debugPrint('Error checking data integrity: $e');
    }
  }

  Future<void> _syncIfConnected() async {
    if (_connectivityService.isConnected) {
      await _handleBackOnline();
    }
  }

  Future<void> _refreshCriticalData() async {
    // This would fetch and cache the latest critical data from the server
    // Implementation depends on your specific API endpoints
    try {
      // Example: Refresh emergency protocols
      final protocols = await _apiService.get('/emergency/protocols');
      if (protocols != null) {
        final protocolList = (protocols['data'] as List)
            .map((p) => EmergencyProtocol.fromJson(p))
            .toList();
        await _offlineDataService.cacheEmergencyProtocols(protocolList);
      }

      // Refresh medication safety data
      final medications = await _apiService.get('/medications/safety-data');
      if (medications != null) {
        for (final med in medications['data']) {
          final safetyData = MedicationSafetyData.fromJson(med);
          await _offlineDataService.cacheMedicationSafetyData(
            safetyData.medicationId,
            safetyData,
          );
        }
      }

    } catch (e) {
      debugPrint('Error refreshing critical data: $e');
    }
  }

  // Public methods for UI interaction

  /// Get critical patient data (works offline)
  Future<CriticalPatientData?> getCriticalPatientData(String patientId) async {
    try {
      return await _offlineDataService.getCriticalPatientData(patientId);
    } catch (e) {
      state = state.copyWith(lastError: e.toString());
      return null;
    }
  }

  /// Cache critical patient data for offline access
  Future<void> cacheCriticalPatientData(String patientId, CriticalPatientData data) async {
    try {
      await _offlineDataService.cacheCriticalPatientData(patientId, data);
    } catch (e) {
      state = state.copyWith(lastError: e.toString());
    }
  }

  /// Get emergency protocol (works offline)
  Future<EmergencyProtocol?> getEmergencyProtocol(String protocolType) async {
    try {
      return await _offlineDataService.getEmergencyProtocol(protocolType);
    } catch (e) {
      state = state.copyWith(lastError: e.toString());
      return null;
    }
  }

  /// Check medication interactions offline
  Future<List<DrugInteraction>> checkMedicationInteractions(List<String> medicationIds) async {
    try {
      return await _offlineDataService.checkMedicationInteractionsOffline(medicationIds);
    } catch (e) {
      state = state.copyWith(lastError: e.toString());
      return [];
    }
  }

  /// Validate vital signs against cached thresholds
  Future<List<VitalSignAlert>> validateVitalSigns(String patientId, VitalSigns vitalSigns) async {
    try {
      return await _offlineDataService.validateVitalSignsOffline(patientId, vitalSigns);
    } catch (e) {
      state = state.copyWith(lastError: e.toString());
      return [];
    }
  }

  /// Queue an action to be performed when online
  Future<void> queueOfflineAction(OfflineAction action) async {
    try {
      await _offlineDataService.queueOfflineAction(action);
      
      final pendingActions = await _offlineDataService.getPendingOfflineActions();
      state = state.copyWith(pendingActionsCount: pendingActions.length);
      
    } catch (e) {
      state = state.copyWith(lastError: e.toString());
    }
  }

  /// Manually trigger sync (if online)
  Future<void> manualSync() async {
    if (!_connectivityService.isConnected) {
      await _notificationService.showNotification(
        title: 'Sync Failed',
        body: 'No internet connection available',
        type: NotificationType.error,
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
          title: 'Data Restored',
          body: 'Critical data restored from backup',
          type: NotificationType.success,
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
    return OfflineCapabilities(
      canAccessPatientData: state.dataIntegrityReport?.criticalItems ?? 0 > 0,
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
    if (report.criticalItems > 10 && report.expiredItems < report.totalItems * 0.1) {
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
    this.syncStatus = SyncStatus.unknown,
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
      lastConnectivityChange: lastConnectivityChange ?? this.lastConnectivityChange,
      dataIntegrityReport: dataIntegrityReport ?? this.dataIntegrityReport,
      hasCorruptedData: hasCorruptedData ?? this.hasCorruptedData,
      pendingActionsCount: pendingActionsCount ?? this.pendingActionsCount,
      lastError: lastError,
    );
  }

  bool get canWorkOffline => dataIntegrityReport?.isHealthy ?? false;
  bool get hasRecentSync => lastSyncTime != null && 
      DateTime.now().difference(lastSyncTime!).inHours < 24;
}

enum SyncStatus {
  unknown,
  syncing,
  success,
  failed,
  offline,
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
      canAccessPatientData && canCheckMedications && canAccessEmergencyProtocols;
  
  bool get hasFullCapabilities => 
      hasBasicCapabilities && canValidateVitalSigns && canQueueActions;
}