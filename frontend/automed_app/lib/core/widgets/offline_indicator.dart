import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../providers/offline_provider.dart';
import '../services/connectivity_service.dart';

class OfflineIndicator extends ConsumerWidget {
  final bool showDetails;
  final VoidCallback? onTap;

  const OfflineIndicator({
    super.key,
    this.showDetails = false,
    this.onTap,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final offlineState = ref.watch(offlineProvider);

    if (!offlineState.isOffline && offlineState.syncStatus != SyncStatus.failed) {
      return const SizedBox.shrink();
    }

    return GestureDetector(
      onTap: onTap ?? () => _showOfflineDetails(context, ref),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
        decoration: BoxDecoration(
          color: _getStatusColor(offlineState),
          borderRadius: BorderRadius.circular(20),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.1),
              blurRadius: 4,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              _getStatusIcon(offlineState),
              color: Colors.white,
              size: 16,
            ),
            const SizedBox(width: 8),
            Text(
              _getStatusText(offlineState),
              style: const TextStyle(
                color: Colors.white,
                fontSize: 12,
                fontWeight: FontWeight.w600,
              ),
            ),
            if (showDetails) ...[
              const SizedBox(width: 4),
              const Icon(
                Icons.info_outline,
                color: Colors.white,
                size: 14,
              ),
            ],
          ],
        ),
      ),
    );
  }

  Color _getStatusColor(OfflineState state) {
    if (state.isSyncing) return Colors.blue;
    if (state.isOffline) {
      return state.canWorkOffline ? Colors.orange : Colors.red;
    }
    if (state.syncStatus == SyncStatus.failed) return Colors.red;
    return Colors.green;
  }

  IconData _getStatusIcon(OfflineState state) {
    if (state.isSyncing) return Icons.sync;
    if (state.isOffline) return Icons.cloud_off;
    if (state.syncStatus == SyncStatus.failed) return Icons.error;
    return Icons.cloud_done;
  }

  String _getStatusText(OfflineState state) {
    if (state.isSyncing) return 'Syncing...';
    if (state.isOffline) {
      return state.canWorkOffline ? 'Offline Mode' : 'Limited Offline';
    }
    if (state.syncStatus == SyncStatus.failed) return 'Sync Failed';
    return 'Online';
  }

  void _showOfflineDetails(BuildContext context, WidgetRef ref) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => OfflineDetailsSheet(),
    );
  }
}

class OfflineDetailsSheet extends ConsumerWidget {
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final offlineState = ref.watch(offlineProvider);
    final offlineNotifier = ref.read(offlineProvider.notifier);

    return Container(
      height: MediaQuery.of(context).size.height * 0.7,
      decoration: const BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      child: Column(
        children: [
          // Handle
          Container(
            width: 40,
            height: 4,
            margin: const EdgeInsets.symmetric(vertical: 12),
            decoration: BoxDecoration(
              color: Colors.grey[300],
              borderRadius: BorderRadius.circular(2),
            ),
          ),
          
          // Header
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20),
            child: Row(
              children: [
                Icon(
                  _getStatusIcon(offlineState),
                  color: _getStatusColor(offlineState),
                  size: 24,
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        _getStatusTitle(offlineState),
                        style: const TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      Text(
                        _getStatusSubtitle(offlineState),
                        style: TextStyle(
                          fontSize: 14,
                          color: Colors.grey[600],
                        ),
                      ),
                    ],
                  ),
                ),
                if (!offlineState.isOffline)
                  IconButton(
                    onPressed: () => offlineNotifier.manualSync(),
                    icon: const Icon(Icons.refresh),
                    tooltip: 'Manual Sync',
                  ),
              ],
            ),
          ),
          
          const Divider(height: 32),
          
          // Content
          Expanded(
            child: SingleChildScrollView(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Connection Status
                  _buildSection(
                    'Connection Status',
                    _buildConnectionStatus(offlineState),
                  ),
                  
                  const SizedBox(height: 24),
                  
                  // Offline Capabilities
                  _buildSection(
                    'Offline Capabilities',
                    _buildOfflineCapabilities(offlineNotifier),
                  ),
                  
                  const SizedBox(height: 24),
                  
                  // Data Status
                  if (offlineState.dataIntegrityReport != null)
                    _buildSection(
                      'Data Status',
                      _buildDataStatus(offlineState.dataIntegrityReport!),
                    ),
                  
                  const SizedBox(height: 24),
                  
                  // Pending Actions
                  if (offlineState.pendingActionsCount > 0)
                    _buildSection(
                      'Pending Actions',
                      _buildPendingActions(offlineState),
                    ),
                  
                  const SizedBox(height: 24),
                  
                  // Actions
                  _buildActions(context, ref, offlineState),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSection(String title, Widget content) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          title,
          style: const TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.w600,
          ),
        ),
        const SizedBox(height: 12),
        content,
      ],
    );
  }

  Widget _buildConnectionStatus(OfflineState state) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.grey[50],
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.grey[200]!),
      ),
      child: Column(
        children: [
          Row(
            children: [
              Icon(
                _getConnectivityIcon(state.connectivityStatus),
                color: _getStatusColor(state),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      _getConnectivityText(state.connectivityStatus),
                      style: const TextStyle(fontWeight: FontWeight.w500),
                    ),
                    if (state.lastConnectivityChange != null)
                      Text(
                        'Last change: ${_formatTime(state.lastConnectivityChange!)}',
                        style: TextStyle(
                          fontSize: 12,
                          color: Colors.grey[600],
                        ),
                      ),
                  ],
                ),
              ),
            ],
          ),
          if (state.lastSyncTime != null) ...[
            const SizedBox(height: 12),
            Row(
              children: [
                Icon(Icons.sync, color: Colors.grey[600], size: 16),
                const SizedBox(width: 8),
                Text(
                  'Last sync: ${_formatTime(state.lastSyncTime!)}',
                  style: TextStyle(
                    fontSize: 12,
                    color: Colors.grey[600],
                  ),
                ),
              ],
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildOfflineCapabilities(OfflineNotifier notifier) {
    return FutureBuilder<OfflineCapabilities>(
      future: Future.value(notifier.getOfflineCapabilities()),
      builder: (context, snapshot) {
        if (!snapshot.hasData) {
          return const CircularProgressIndicator();
        }

        final capabilities = snapshot.data!;
        
        return Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: Colors.grey[50],
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: Colors.grey[200]!),
          ),
          child: Column(
            children: [
              _buildCapabilityItem(
                'Patient Data Access',
                capabilities.canAccessPatientData,
                'View critical patient information',
              ),
              _buildCapabilityItem(
                'Medication Checking',
                capabilities.canCheckMedications,
                'Check drug interactions and safety',
              ),
              _buildCapabilityItem(
                'Emergency Protocols',
                capabilities.canAccessEmergencyProtocols,
                'Access emergency procedures',
              ),
              _buildCapabilityItem(
                'Vital Signs Validation',
                capabilities.canValidateVitalSigns,
                'Validate against patient thresholds',
              ),
              _buildCapabilityItem(
                'Action Queuing',
                capabilities.canQueueActions,
                'Queue actions for when online',
              ),
              const SizedBox(height: 12),
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: capabilities.hasFullCapabilities 
                      ? Colors.green[50] 
                      : Colors.orange[50],
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Row(
                  children: [
                    Icon(
                      Icons.access_time,
                      color: capabilities.hasFullCapabilities 
                          ? Colors.green[700] 
                          : Colors.orange[700],
                      size: 16,
                    ),
                    const SizedBox(width: 8),
                    Text(
                      'Estimated offline time: ${_formatDuration(capabilities.estimatedOfflineTime)}',
                      style: TextStyle(
                        fontSize: 12,
                        color: capabilities.hasFullCapabilities 
                            ? Colors.green[700] 
                            : Colors.orange[700],
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildCapabilityItem(String title, bool available, String description) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        children: [
          Icon(
            available ? Icons.check_circle : Icons.cancel,
            color: available ? Colors.green : Colors.red,
            size: 20,
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: const TextStyle(fontWeight: FontWeight.w500),
                ),
                Text(
                  description,
                  style: TextStyle(
                    fontSize: 12,
                    color: Colors.grey[600],
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDataStatus(DataIntegrityReport report) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.grey[50],
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.grey[200]!),
      ),
      child: Column(
        children: [
          Row(
            children: [
              Icon(
                report.isHealthy ? Icons.verified : Icons.warning,
                color: report.isHealthy ? Colors.green : Colors.orange,
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Text(
                  report.isHealthy ? 'Data is healthy' : 'Data needs attention',
                  style: const TextStyle(fontWeight: FontWeight.w500),
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: [
              _buildDataMetric('Total', report.totalItems.toString()),
              _buildDataMetric('Critical', report.criticalItems.toString()),
              _buildDataMetric('Expired', report.expiredItems.toString()),
              _buildDataMetric('Corrupted', report.corruptedItems.toString()),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildDataMetric(String label, String value) {
    return Column(
      children: [
        Text(
          value,
          style: const TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.bold,
          ),
        ),
        Text(
          label,
          style: TextStyle(
            fontSize: 12,
            color: Colors.grey[600],
          ),
        ),
      ],
    );
  }

  Widget _buildPendingActions(OfflineState state) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.blue[50],
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.blue[200]!),
      ),
      child: Row(
        children: [
          Icon(Icons.queue, color: Colors.blue[700]),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  '${state.pendingActionsCount} actions queued',
                  style: const TextStyle(fontWeight: FontWeight.w500),
                ),
                Text(
                  'Will sync when connection is restored',
                  style: TextStyle(
                    fontSize: 12,
                    color: Colors.grey[600],
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildActions(BuildContext context, WidgetRef ref, OfflineState state) {
    final offlineNotifier = ref.read(offlineProvider.notifier);
    
    return Column(
      children: [
        if (!state.isOffline) ...[
          SizedBox(
            width: double.infinity,
            child: ElevatedButton.icon(
              onPressed: state.isSyncing ? null : () => offlineNotifier.manualSync(),
              icon: Icon(state.isSyncing ? Icons.sync : Icons.refresh),
              label: Text(state.isSyncing ? 'Syncing...' : 'Manual Sync'),
            ),
          ),
          const SizedBox(height: 12),
        ],
        
        SizedBox(
          width: double.infinity,
          child: OutlinedButton.icon(
            onPressed: () => offlineNotifier.checkDataIntegrity(),
            icon: const Icon(Icons.health_and_safety),
            label: const Text('Check Data Integrity'),
          ),
        ),
        
        if (state.hasCorruptedData) ...[
          const SizedBox(height: 12),
          SizedBox(
            width: double.infinity,
            child: ElevatedButton.icon(
              onPressed: () async {
                final success = await offlineNotifier.restoreFromBackup();
                if (success && context.mounted) {
                  Navigator.of(context).pop();
                }
              },
              icon: const Icon(Icons.restore),
              label: const Text('Restore from Backup'),
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.orange,
                foregroundColor: Colors.white,
              ),
            ),
          ),
        ],
        
        const SizedBox(height: 12),
        
        TextButton(
          onPressed: () => Navigator.of(context).pop(),
          child: const Text('Close'),
        ),
      ],
    );
  }

  // Helper methods
  Color _getStatusColor(OfflineState state) {
    if (state.isSyncing) return Colors.blue;
    if (state.isOffline) {
      return state.canWorkOffline ? Colors.orange : Colors.red;
    }
    if (state.syncStatus == SyncStatus.failed) return Colors.red;
    return Colors.green;
  }

  IconData _getStatusIcon(OfflineState state) {
    if (state.isSyncing) return Icons.sync;
    if (state.isOffline) return Icons.cloud_off;
    if (state.syncStatus == SyncStatus.failed) return Icons.error;
    return Icons.cloud_done;
  }

  String _getStatusTitle(OfflineState state) {
    if (state.isSyncing) return 'Synchronizing Data';
    if (state.isOffline) return 'Working Offline';
    if (state.syncStatus == SyncStatus.failed) return 'Sync Failed';
    return 'Connected';
  }

  String _getStatusSubtitle(OfflineState state) {
    if (state.isSyncing) return 'Updating data from server';
    if (state.isOffline) {
      return state.canWorkOffline 
          ? 'Critical data available offline'
          : 'Limited functionality available';
    }
    if (state.syncStatus == SyncStatus.failed) return 'Unable to sync with server';
    return 'All features available';
  }

  IconData _getConnectivityIcon(ConnectivityStatus status) {
    switch (status) {
      case ConnectivityStatus.connected:
        return Icons.wifi;
      case ConnectivityStatus.disconnected:
        return Icons.wifi_off;
      case ConnectivityStatus.limited:
        return Icons.wifi_1_bar;
      case ConnectivityStatus.unknown:
        return Icons.help_outline;
    }
  }

  String _getConnectivityText(ConnectivityStatus status) {
    switch (status) {
      case ConnectivityStatus.connected:
        return 'Connected to Internet';
      case ConnectivityStatus.disconnected:
        return 'No Internet Connection';
      case ConnectivityStatus.limited:
        return 'Limited Connectivity';
      case ConnectivityStatus.unknown:
        return 'Connection Status Unknown';
    }
  }

  String _formatTime(DateTime time) {
    final now = DateTime.now();
    final difference = now.difference(time);
    
    if (difference.inMinutes < 1) {
      return 'Just now';
    } else if (difference.inHours < 1) {
      return '${difference.inMinutes}m ago';
    } else if (difference.inDays < 1) {
      return '${difference.inHours}h ago';
    } else {
      return '${difference.inDays}d ago';
    }
  }

  String _formatDuration(Duration duration) {
    if (duration.inDays > 0) {
      return '${duration.inDays} days';
    } else if (duration.inHours > 0) {
      return '${duration.inHours} hours';
    } else {
      return '${duration.inMinutes} minutes';
    }
  }
}