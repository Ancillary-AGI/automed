import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_text_styles.dart';
import '../../../../core/widgets/app_card.dart';
import '../../../../core/widgets/app_scaffold.dart';
import '../../../../generated/l10n.dart';
import '../providers/patient_dashboard_provider.dart';
import '../widgets/health_metrics_card.dart';
import '../widgets/quick_actions_grid.dart';
import '../widgets/upcoming_appointments_card.dart';
import '../widgets/medication_reminders_card.dart';
import '../widgets/emergency_button.dart';

class PatientDashboardScreen extends ConsumerWidget {
  const PatientDashboardScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final dashboardState = ref.watch(patientDashboardProvider);
    final theme = Theme.of(context);
    
    return AppScaffold(
      body: RefreshIndicator(
        onRefresh: () => ref.refresh(patientDashboardProvider.future),
        child: CustomScrollView(
          slivers: [
            // App Bar
            SliverAppBar(
              expandedHeight: 120,
              floating: true,
              pinned: true,
              backgroundColor: AppColors.primary,
              flexibleSpace: FlexibleSpaceBar(
                title: Text(
                  S.of(context).dashboard,
                  style: AppTextStyles.headlineMedium.copyWith(
                    color: Colors.white,
                  ),
                ),
                background: Container(
                  decoration: const BoxDecoration(
                    gradient: LinearGradient(
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                      colors: [
                        AppColors.primary,
                        AppColors.primaryDark,
                      ],
                    ),
                  ),
                ),
              ),
              actions: [
                IconButton(
                  icon: const Icon(Icons.notifications_outlined),
                  onPressed: () => context.push('/notifications'),
                ),
                IconButton(
                  icon: const Icon(Icons.person_outline),
                  onPressed: () => context.push('/profile'),
                ),
              ],
            ),
            
            // Dashboard Content
            SliverPadding(
              padding: const EdgeInsets.all(16),
              sliver: SliverList(
                delegate: SliverChildListDelegate([
                  // Emergency Button
                  const EmergencyButton(),
                  const SizedBox(height: 16),
                  
                  // Health Metrics
                  dashboardState.when(
                    data: (data) => HealthMetricsCard(metrics: data.healthMetrics),
                    loading: () => const _LoadingCard(),
                    error: (error, stack) => _ErrorCard(error: error.toString()),
                  ),
                  const SizedBox(height: 16),
                  
                  // Quick Actions
                  const QuickActionsGrid(),
                  const SizedBox(height: 16),
                  
                  // Upcoming Appointments
                  dashboardState.when(
                    data: (data) => UpcomingAppointmentsCard(
                      appointments: data.upcomingAppointments,
                    ),
                    loading: () => const _LoadingCard(),
                    error: (error, stack) => _ErrorCard(error: error.toString()),
                  ),
                  const SizedBox(height: 16),
                  
                  // Medication Reminders
                  dashboardState.when(
                    data: (data) => MedicationRemindersCard(
                      medications: data.medications,
                    ),
                    loading: () => const _LoadingCard(),
                    error: (error, stack) => _ErrorCard(error: error.toString()),
                  ),
                  const SizedBox(height: 16),
                  
                  // AI Health Assistant
                  AppCard(
                    child: ListTile(
                      leading: Container(
                        padding: const EdgeInsets.all(8),
                        decoration: BoxDecoration(
                          color: AppColors.secondary.withOpacity(0.1),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: const Icon(
                          Icons.psychology_outlined,
                          color: AppColors.secondary,
                        ),
                      ),
                      title: Text(
                        S.of(context).aiHealthAssistant,
                        style: AppTextStyles.titleMedium,
                      ),
                      subtitle: Text(
                        S.of(context).askHealthQuestions,
                        style: AppTextStyles.bodyMedium.copyWith(
                          color: theme.colorScheme.onSurface.withOpacity(0.7),
                        ),
                      ),
                      trailing: const Icon(Icons.arrow_forward_ios),
                      onTap: () => context.push('/ai-assistant'),
                    ),
                  ),
                  
                  // Bottom padding for safe area
                  const SizedBox(height: 32),
                ]),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _LoadingCard extends StatelessWidget {
  const _LoadingCard();

  @override
  Widget build(BuildContext context) {
    return AppCard(
      child: Container(
        height: 120,
        child: const Center(
          child: CircularProgressIndicator(),
        ),
      ),
    );
  }
}

class _ErrorCard extends StatelessWidget {
  final String error;
  
  const _ErrorCard({required this.error});

  @override
  Widget build(BuildContext context) {
    return AppCard(
      child: Container(
        height: 120,
        child: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                Icons.error_outline,
                color: Theme.of(context).colorScheme.error,
                size: 32,
              ),
              const SizedBox(height: 8),
              Text(
                S.of(context).errorLoadingData,
                style: AppTextStyles.bodyMedium.copyWith(
                  color: Theme.of(context).colorScheme.error,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}