import 'dart:convert';
import 'dart:io';
import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:hive/hive.dart';
import 'package:dio/dio.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../config/app_config.dart';
import '../models/sync_models.dart';
import '../utils/logger.dart';

class SyncService {
  final Dio _dio;
  final AppConfig _config;
  final Box _syncBox;
  final Box _conflictsBox;
  
  static const String _pendingActionsKey = 'pending_actions';
  static const String _lastSyncKey = 'last_sync_timestamp';
  static const String _deviceIdKey = 'device_id';

  SyncService(this._dio, this._config, this._syncBox, this._conflictsBox);

  /// Queue an action to be synced when online
  Future<void> queueAction(SyncAction action) async {
    try {
      final pendingActions = await _getPendingActions();
      pendingActions.add(action);
      await _syncBox.put(_pendingActionsKey, pendingActions.map((a) => a.toJson()).toList());
      
      Logger.info('Queued action: ${action.type} for entity ${action.entityId}');
      
      // Try to sync immediately if online
      if (await _isOnline()) {
        await syncPendingActions();
      }
    } catch (e) {
      Logger.error('Failed to queue action', e);
    }
  }

  /// Sync all pending actions with the server
  Future<SyncResult> syncPendingActions() async {
    if (!await _isOnline()) {
      return SyncResult(
        success: false,
        message: 'No internet connection',
        syncedCount: 0,
        conflictCount: 0,
      );
    }

    try {
      final pendingActions = await _getPendingActions();
      if (pendingActions.isEmpty) {
        return SyncResult(
          success: true,
          message: 'No actions to sync',
          syncedCount: 0,
          conflictCount: 0,
        );
      }

      final deviceId = await _getDeviceId();
      final uploadRequest = OfflineDataUploadRequest(
        deviceId: deviceId,
        actions: pendingActions,
        timestamp: DateTime.now().millisecondsSinceEpoch,
      );

      final response = await _dio.post(
        '/sync/upload',
        data: uploadRequest.toJson(),
      );

      final syncResponse = SyncResponse.fromJson(response.data);
      
      if (syncResponse.success) {
        // Clear successfully synced actions
        final successfulActionIds = syncResponse.processedActions ?? [];
        final remainingActions = pendingActions
            .where((action) => !successfulActionIds.contains(action.id))
            .toList();
        
        await _syncBox.put(_pendingActionsKey, remainingActions.map((a) => a.toJson()).toList());
        
        // Store conflicts for resolution
        if (syncResponse.conflicts?.isNotEmpty == true) {
          await _storeConflicts(syncResponse.conflicts!);
        }
        
        // Update last sync timestamp
        await _syncBox.put(_lastSyncKey, DateTime.now().millisecondsSinceEpoch);
        
        Logger.info('Sync completed: ${successfulActionIds.length} actions synced, ${syncResponse.conflicts?.length ?? 0} conflicts');
        
        return SyncResult(
          success: true,
          message: 'Sync completed successfully',
          syncedCount: successfulActionIds.length,
          conflictCount: syncResponse.conflicts?.length ?? 0,
          conflicts: syncResponse.conflicts,
        );
      } else {
        Logger.error('Sync failed: ${syncResponse.message}');
        return SyncResult(
          success: false,
          message: syncResponse.message ?? 'Sync failed',
          syncedCount: 0,
          conflictCount: 0,
        );
      }
    } catch (e) {
      Logger.error('Sync error', e);
      return SyncResult(
        success: false,
        message: 'Sync error: ${e.toString()}',
        syncedCount: 0,
        conflictCount: 0,
      );
    }
  }

  /// Download updates from server
  Future<SyncDownloadResult> downloadUpdates() async {
    if (!await _isOnline()) {
      return SyncDownloadResult(
        success: false,
        message: 'No internet connection',
        updates: [],
      );
    }

    try {
      final deviceId = await _getDeviceId();
      final lastSync = await _getLastSyncTimestamp();
      
      final response = await _dio.get(
        '/sync/download/$deviceId',
        queryParameters: {'lastSyncTimestamp': lastSync},
      );

      final downloadResponse = SyncDownloadResponse.fromJson(response.data);
      
      if (downloadResponse.success) {
        // Update last sync timestamp
        await _syncBox.put(_lastSyncKey, DateTime.now().millisecondsSinceEpoch);
        
        Logger.info('Downloaded ${downloadResponse.updates?.length ?? 0} updates');
        
        return SyncDownloadResult(
          success: true,
          message: 'Updates downloaded successfully',
          updates: downloadResponse.updates ?? [],
        );
      } else {
        return SyncDownloadResult(
          success: false,
          message: downloadResponse.message ?? 'Download failed',
          updates: [],
        );
      }
    } catch (e) {
      Logger.error('Download error', e);
      return SyncDownloadResult(
        success: false,
        message: 'Download error: ${e.toString()}',
        updates: [],
      );
    }
  }

  /// Get pending conflicts that need resolution
  Future<List<DataConflict>> getPendingConflicts() async {
    try {
      final conflictsData = _conflictsBox.get('conflicts', defaultValue: <Map<String, dynamic>>[]);
      return (conflictsData as List)
          .map((data) => DataConflict.fromJson(Map<String, dynamic>.from(data)))
          .toList();
    } catch (e) {
      Logger.error('Failed to get pending conflicts', e);
      return [];
    }
  }

  /// Resolve a conflict with user's choice
  Future<bool> resolveConflict(String conflictId, ConflictResolution resolution) async {
    try {
      if (!await _isOnline()) {
        // Store resolution for later sync
        await _storeConflictResolution(conflictId, resolution);
        return true;
      }

      final request = ConflictResolutionRequest(
        conflictId: conflictId,
        resolution: resolution,
        deviceId: await _getDeviceId(),
      );

      final response = await _dio.post(
        '/sync/resolve-conflicts',
        data: request.toJson(),
      );

      final resolutionResponse = ConflictResolutionResponse.fromJson(response.data);
      
      if (resolutionResponse.success) {
        // Remove resolved conflict from local storage
        await _removeConflict(conflictId);
        Logger.info('Conflict resolved: $conflictId');
        return true;
      } else {
        Logger.error('Failed to resolve conflict: ${resolutionResponse.message}');
        return false;
      }
    } catch (e) {
      Logger.error('Error resolving conflict', e);
      return false;
    }
  }

  /// Send heartbeat to server
  Future<void> sendHeartbeat() async {
    if (!await _isOnline()) return;

    try {
      final deviceId = await _getDeviceId();
      final pendingActions = await _getPendingActions();
      
      final request = DeviceHeartbeatRequest(
        deviceId: deviceId,
        timestamp: DateTime.now().millisecondsSinceEpoch,
        pendingActionsCount: pendingActions.length,
        appVersion: _config.version,
      );

      await _dio.post('/sync/heartbeat', data: request.toJson());
      Logger.debug('Heartbeat sent');
    } catch (e) {
      Logger.error('Heartbeat failed', e);
    }
  }

  /// Get sync status
  Future<SyncStatus> getSyncStatus() async {
    final pendingActions = await _getPendingActions();
    final pendingConflicts = await getPendingConflicts();
    final lastSync = await _getLastSyncTimestamp();
    final isOnline = await _isOnline();

    return SyncStatus(
      isOnline: isOnline,
      pendingActionsCount: pendingActions.length,
      pendingConflictsCount: pendingConflicts.length,
      lastSyncTimestamp: lastSync,
      deviceId: await _getDeviceId(),
    );
  }

  // Private helper methods

  Future<List<SyncAction>> _getPendingActions() async {
    try {
      final actionsData = _syncBox.get(_pendingActionsKey, defaultValue: <Map<String, dynamic>>[]);
      return (actionsData as List)
          .map((data) => SyncAction.fromJson(Map<String, dynamic>.from(data)))
          .toList();
    } catch (e) {
      Logger.error('Failed to get pending actions', e);
      return [];
    }
  }

  Future<String> _getDeviceId() async {
    String? deviceId = _syncBox.get(_deviceIdKey);
    if (deviceId == null) {
      deviceId = _generateDeviceId();
      await _syncBox.put(_deviceIdKey, deviceId);
    }
    return deviceId;
  }

  String _generateDeviceId() {
    final timestamp = DateTime.now().millisecondsSinceEpoch;
    final random = (timestamp * 1000 + (timestamp % 1000)).toString();
    return 'device_$random';
  }

  Future<int> _getLastSyncTimestamp() async {
    return _syncBox.get(_lastSyncKey, defaultValue: 0);
  }

  Future<bool> _isOnline() async {
    try {
      final connectivityResult = await Connectivity().checkConnectivity();
      return connectivityResult != ConnectivityResult.none;
    } catch (e) {
      return false;
    }
  }

  Future<void> _storeConflicts(List<DataConflict> conflicts) async {
    final existingConflicts = await getPendingConflicts();
    final allConflicts = [...existingConflicts, ...conflicts];
    
    // Remove duplicates based on conflict ID
    final uniqueConflicts = <String, DataConflict>{};
    for (final conflict in allConflicts) {
      uniqueConflicts[conflict.id] = conflict;
    }
    
    await _conflictsBox.put('conflicts', uniqueConflicts.values.map((c) => c.toJson()).toList());
  }

  Future<void> _removeConflict(String conflictId) async {
    final conflicts = await getPendingConflicts();
    final updatedConflicts = conflicts.where((c) => c.id != conflictId).toList();
    await _conflictsBox.put('conflicts', updatedConflicts.map((c) => c.toJson()).toList());
  }

  Future<void> _storeConflictResolution(String conflictId, ConflictResolution resolution) async {
    // Store for later sync when online
    final resolutions = _conflictsBox.get('pending_resolutions', defaultValue: <String, dynamic>{});
    resolutions[conflictId] = resolution.toJson();
    await _conflictsBox.put('pending_resolutions', resolutions);
  }
}

// Provider
final syncServiceProvider = Provider<SyncService>((ref) {
  throw UnimplementedError('SyncService must be initialized in main()');
});