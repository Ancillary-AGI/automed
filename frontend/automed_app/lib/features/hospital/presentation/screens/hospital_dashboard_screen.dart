import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_text_styles.dart';
import '../../../../core/widgets/app_card.dart';
import '../../../../core/widgets/app_scaffold.dart';
import '../../../../generated/l10n.dart';
import '../providers/hospital_dashboard_provider.dart';
import '../widgets/bed_occupancy_card.dart';
import '../widgets/staff_status_card.dart';
import '../widgets/equipment_status_card.dart';
import '../widgets/emergency_alerts_card.dart';
import '../widgets/patient_flow_chart.dart';
import '../widgets/quick_actions_hospital.dart';

class HospitalDashboardScreen extends ConsumerWidget {
  const HospitalDashboardScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final dashboardState = ref.watch(hospitalDashboardProvider);
    final theme = Theme.of(context);

    return AppScaffold(
      body: RefreshIndicator(
        onRefresh: () async {
          // TODO: Implement proper refresh logic
        },
        child: CustomScrollView(
          slivers: [
            // App Bar with Hospital Info
            SliverAppBar(
              expandedHeight: 140,
              floating: true,
              pinned: true,
              backgroundColor: AppColors.primary,
              flexibleSpace: FlexibleSpaceBar(
                title: Column(
                  mainAxisAlignment: MainAxisAlignment.end,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      S.of(context).hospitalDashboard,
                      style: AppTextStyles.headlineSmall.copyWith(
                        color: Colors.white,
                      ),
                    ),
                    dashboardState.when(
                      data: (data) => Text(
                        'Hospital Name', // TODO: Fix data structure
                        style: AppTextStyles.bodyMedium.copyWith(
                          color: Colors.white.withOpacity(0.9),
                        ),
                      ),
                      loading: () => const SizedBox.shrink(),
                      error: (_, __) => const SizedBox.shrink(),
                    ),
                  ],
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
                  icon: const Icon(Icons.emergency_outlined),
                  onPressed: () => context.push('/emergency-center'),
                ),
                IconButton(
                  icon: const Icon(Icons.notifications_outlined),
                  onPressed: () => context.push('/notifications'),
                ),
                PopupMenuButton<String>(
                  onSelected: (value) {
                    switch (value) {
                      case 'settings':
                        context.push('/hospital-settings');
                        break;
                      case 'reports':
                        context.push('/reports');
                        break;
                      case 'logout':
                        // Handle logout
                        break;
                    }
                  },
                  itemBuilder: (context) => [
                    PopupMenuItem(
                      value: 'settings',
                      child: Text(S.of(context).settings),
                    ),
                    PopupMenuItem(
                      value: 'reports',
                      child: Text(S.of(context).reports),
                    ),
                    const PopupMenuDivider(),
                    PopupMenuItem(
                      value: 'logout',
                      child: Text(S.of(context).logout),
                    ),
                  ],
                ),
              ],
            ),

            // Dashboard Content
            SliverPadding(
              padding: const EdgeInsets.all(16),
              sliver: SliverList(
                delegate: SliverChildListDelegate([
                  // Emergency Alerts
                  dashboardState.when(
                    data: (data) => EmergencyAlertsCard(
                      activeAlerts: 0, // TODO: Fix data structure
                    ),
                    loading: () => const _LoadingCard(),
                    error: (error, stack) =>
                        _ErrorCard(error: error.toString()),
                  ),
                  const SizedBox(height: 16),

                  // Quick Actions
                  const QuickActionsHospital(),
                  const SizedBox(height: 16),

                  // Key Metrics Row
                  Row(
                    children: [
                      Expanded(
                        child: dashboardState.when(
                          data: (data) => BedOccupancyCard(
                            occupied: 75,
                            total: 100, // TODO: Fix data structure
                          ),
                          loading: () => const _LoadingCard(),
                          error: (error, stack) =>
                              _ErrorCard(error: error.toString()),
                        ),
                      ),
                      const SizedBox(width: 16),
                      Expanded(
                        child: dashboardState.when(
                          data: (data) => StaffStatusCard(
                            onDuty: 45, total: 50, // TODO: Fix data structure
                          ),
                          loading: () => const _LoadingCard(),
                          error: (error, stack) =>
                              _ErrorCard(error: error.toString()),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),

                  // Equipment Status
                  dashboardState.when(
                    data: (data) => EquipmentStatusCard(
                      operational: 85, total: 100, // TODO: Fix data structure
                    ),
                    loading: () => const _LoadingCard(),
                    error: (error, stack) =>
                        _ErrorCard(error: error.toString()),
                  ),
                  const SizedBox(height: 16),

                  // Patient Flow Chart
                  dashboardState.when(
                    data: (data) => PatientFlowChart(),
                    loading: () => const _LoadingCard(),
                    error: (error, stack) =>
                        _ErrorCard(error: error.toString()),
                  ),
                  const SizedBox(height: 16),

                  // AI Insights
                  AppCard(
                    child: Padding(
                      padding: const EdgeInsets.all(16),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: [
                              Container(
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
                              const SizedBox(width: 12),
                              Text(
                                S.of(context).aiInsights,
                                style: AppTextStyles.titleLarge,
                              ),
                            ],
                          ),
                          const SizedBox(height: 16),
                          dashboardState.when(
                            data: (data) => Column(
                              children: [
                                'AI Insight 1',
                                'AI Insight 2',
                                'AI Insight 3'
                              ] // TODO: Fix data structure
                                  .map(
                                    (insight) => Padding(
                                      padding: const EdgeInsets.only(bottom: 8),
                                      child: Row(
                                        children: [
                                          Icon(
                                            Icons.lightbulb_outline,
                                            size: 16,
                                            color: theme.colorScheme.primary,
                                          ),
                                          const SizedBox(width: 8),
                                          Expanded(
                                            child: Text(
                                              insight,
                                              style: AppTextStyles.bodyMedium,
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),
                                  )
                                  .toList(),
                            ),
                            loading: () => const CircularProgressIndicator(),
                            error: (error, stack) => Text(
                              S.of(context).errorLoadingInsights,
                              style: AppTextStyles.bodyMedium.copyWith(
                                color: theme.colorScheme.error,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),

                  // Bottom padding
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
