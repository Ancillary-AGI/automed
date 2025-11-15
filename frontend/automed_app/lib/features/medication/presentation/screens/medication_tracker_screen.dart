import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:automed_app/core/theme/app_colors.dart';
import 'package:automed_app/core/theme/app_text_styles.dart';
import 'package:automed_app/core/widgets/app_card.dart';
import 'package:automed_app/core/widgets/app_scaffold.dart';
import 'package:automed_app/generated/l10n.dart';
import '../providers/medication_provider.dart';
import '../widgets/medication_card.dart';
import '../widgets/medication_schedule_widget.dart';
import '../widgets/add_medication_dialog.dart';

class MedicationTrackerScreen extends ConsumerStatefulWidget {
  const MedicationTrackerScreen({super.key});

  @override
  ConsumerState<MedicationTrackerScreen> createState() =>
      _MedicationTrackerScreenState();
}

class _MedicationTrackerScreenState
    extends ConsumerState<MedicationTrackerScreen> {
  @override
  Widget build(BuildContext context) {
    final medicationsAsync = ref.watch(medicationsProvider);
    final todayScheduleAsync = ref.watch(todayMedicationScheduleProvider);

    return DefaultTabController(
      length: 3,
      child: AppScaffold(
        title: S.of(context).medicationTracker,
        actions: [
          IconButton(
            icon: const Icon(Icons.add),
            onPressed: () => _showAddMedicationDialog(context),
          ),
          IconButton(
            icon: const Icon(Icons.sync),
            onPressed: () => _syncMedications(),
          ),
        ],
        body: Column(
          children: [
            TabBar(
              tabs: [
                Tab(text: S.of(context).today),
                Tab(text: S.of(context).allMedications),
                Tab(text: S.of(context).history),
              ],
            ),
            Expanded(
              child: TabBarView(
                children: [
                  // Today's Schedule
                  _buildTodayTab(todayScheduleAsync),

                  // All Medications
                  _buildAllMedicationsTab(medicationsAsync),

                  // History
                  _buildHistoryTab(),
                ],
              ),
            ),
          ],
        ),
        floatingActionButton: FloatingActionButton(
          onPressed: () => _showAddMedicationDialog(context),
          backgroundColor: AppColors.primary,
          child: const Icon(Icons.add, color: Colors.white),
        ),
      ),
    );
  }

  Widget _buildTodayTab(AsyncValue<List<dynamic>> todayScheduleAsync) {
    return RefreshIndicator(
      onRefresh: () async {
        ref.invalidate(todayMedicationScheduleProvider);
      },
      child: todayScheduleAsync.when(
        data: (schedule) => schedule.isEmpty
            ? _buildEmptyState(S.of(context).noMedicationsToday)
            : ListView.builder(
                padding: const EdgeInsets.all(16),
                itemCount: schedule.length,
                itemBuilder: (context, index) {
                  return Padding(
                    padding: const EdgeInsets.only(bottom: 12),
                    child: MedicationScheduleWidget(),
                  );
                },
              ),
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (error, stack) => _buildErrorState(error.toString()),
      ),
    );
  }

  Widget _buildAllMedicationsTab(AsyncValue<List<dynamic>> medicationsAsync) {
    return RefreshIndicator(
      onRefresh: () async {
        ref.invalidate(medicationsProvider);
      },
      child: medicationsAsync.when(
        data: (medications) => medications.isEmpty
            ? _buildEmptyState(S.of(context).noMedicationsAdded)
            : ListView.builder(
                padding: const EdgeInsets.all(16),
                itemCount: medications.length,
                itemBuilder: (context, index) {
                  final medication = medications[index];
                  return Padding(
                    padding: const EdgeInsets.only(bottom: 12),
                    child: MedicationCard(
                      medication: medication,
                      onEdit: (med) => _editMedication(med),
                      onDelete: (medId) => _deleteMedication(medId),
                      onToggleActive: (medId, isActive) =>
                          _toggleMedicationActive(medId, isActive),
                    ),
                  );
                },
              ),
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (error, stack) => _buildErrorState(error.toString()),
      ),
    );
  }

  Widget _buildHistoryTab() {
    final historyAsync = ref.watch(medicationHistoryProvider);

    return RefreshIndicator(
      onRefresh: () async {
        ref.invalidate(medicationHistoryProvider);
      },
      child: historyAsync.when(
        data: (history) => history.isEmpty
            ? _buildEmptyState(S.of(context).noMedicationHistory)
            : ListView.builder(
                padding: const EdgeInsets.all(16),
                itemCount: history.length,
                itemBuilder: (context, index) {
                  final entry = history[index];
                  return AppCard(
                    margin: const EdgeInsets.only(bottom: 12),
                    child: ListTile(
                      leading: CircleAvatar(
                        backgroundColor: entry.status == 'TAKEN'
                            ? Colors.green
                            : entry.status == 'SKIPPED'
                                ? Colors.orange
                                : Colors.red,
                        child: Icon(
                          entry.status == 'TAKEN'
                              ? Icons.check
                              : entry.status == 'SKIPPED'
                                  ? Icons.skip_next
                                  : Icons.close,
                          color: Colors.white,
                          size: 20,
                        ),
                      ),
                      title: Text(
                        entry.medicationName,
                        style: AppTextStyles.titleMedium,
                      ),
                      subtitle: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            '${entry.dosage} • ${_formatTime(entry.scheduledTime)}',
                            style: AppTextStyles.bodyMedium,
                          ),
                          Text(
                            _formatDate(entry.date),
                            style: AppTextStyles.bodySmall.copyWith(
                              color: Theme.of(context)
                                  .colorScheme
                                  .onSurface
                                  .withOpacity(0.6),
                            ),
                          ),
                        ],
                      ),
                      trailing: entry.notes?.isNotEmpty == true
                          ? IconButton(
                              icon: const Icon(Icons.note),
                              onPressed: () => _showNotesDialog(entry.notes!),
                            )
                          : null,
                    ),
                  );
                },
              ),
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (error, stack) => _buildErrorState(error.toString()),
      ),
    );
  }

  Widget _buildEmptyState(String message) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.medication_outlined,
            size: 64,
            color: Theme.of(context).colorScheme.onSurface.withOpacity(0.3),
          ),
          const SizedBox(height: 16),
          Text(
            message,
            style: AppTextStyles.titleMedium.copyWith(
              color: Theme.of(context).colorScheme.onSurface.withOpacity(0.6),
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 24),
          ElevatedButton.icon(
            onPressed: () => _showAddMedicationDialog(context),
            icon: const Icon(Icons.add),
            label: Text(S.of(context).addMedication),
          ),
        ],
      ),
    );
  }

  Widget _buildErrorState(String error) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.error_outline,
            size: 64,
            color: Theme.of(context).colorScheme.error,
          ),
          const SizedBox(height: 16),
          Text(
            S.of(context).errorLoadingMedications,
            style: AppTextStyles.titleMedium.copyWith(
              color: Theme.of(context).colorScheme.error,
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 8),
          Text(
            error,
            style: AppTextStyles.bodySmall.copyWith(
              color: Theme.of(context).colorScheme.onSurface.withOpacity(0.6),
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 24),
          ElevatedButton(
            onPressed: () {
              ref.invalidate(medicationsProvider);
              ref.invalidate(todayMedicationScheduleProvider);
            },
            child: Text(S.of(context).retry),
          ),
        ],
      ),
    );
  }

  void _showAddMedicationDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => const AddMedicationDialog(),
    );
  }

  void _syncMedications() {
    ref.read(medicationSyncProvider.notifier).syncMedications();
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(S.of(context).syncingMedications),
        backgroundColor: AppColors.primary,
      ),
    );
  }

  void _editMedication(dynamic medication) {
    showDialog(
      context: context,
      builder: (context) => const AddMedicationDialog(),
    );
  }

  void _deleteMedication(String medicationId) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(S.of(context).deleteMedication),
        content: Text(S.of(context).deleteMedicationConfirmation),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: Text(S.of(context).cancel),
          ),
          TextButton(
            onPressed: () {
              ref
                  .read(medicationProvider.notifier)
                  .deleteMedication(medicationId);
              Navigator.of(context).pop();
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  content: Text('Medication deleted successfully'),
                  backgroundColor: AppColors.success,
                ),
              );
            },
            style: TextButton.styleFrom(foregroundColor: Colors.red),
            child: Text(S.of(context).delete),
          ),
        ],
      ),
    );
  }

  void _toggleMedicationActive(String medicationId, bool isActive) {
    ref
        .read(medicationProvider.notifier)
        .toggleMedicationActive(medicationId, isActive);
  }

  void _showNotesDialog(String notes) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(S.of(context).notes),
        content: Text(notes),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: Text(S.of(context).close),
          ),
        ],
      ),
    );
  }

  String _formatTime(DateTime time) {
    return '${time.hour.toString().padLeft(2, '0')}:${time.minute.toString().padLeft(2, '0')}';
  }

  String _formatDate(DateTime date) {
    return '${date.day}/${date.month}/${date.year}';
  }
}
