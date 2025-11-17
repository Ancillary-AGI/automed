import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import 'package:automed_app/core/widgets/app_scaffold.dart';
import 'package:automed_app/core/theme/app_colors.dart';
import 'package:automed_app/core/theme/app_text_styles.dart';
import '../providers/patient_dashboard_provider.dart';
import '../models/patient_dashboard_model.dart';
import '../widgets/health_metrics_card.dart';
import '../widgets/quick_actions_grid.dart';
import '../widgets/emergency_button.dart';
import '../widgets/upcoming_appointments_card.dart';
import '../widgets/medication_reminders_card.dart';

class PatientDashboardScreen extends ConsumerStatefulWidget {
  const PatientDashboardScreen({super.key});

  @override
  ConsumerState<PatientDashboardScreen> createState() =>
      _PatientDashboardScreenState();
}

class _PatientDashboardScreenState
    extends ConsumerState<PatientDashboardScreen> {
  @override
  Widget build(BuildContext context) {
    final dashboardAsync = ref.watch(patientDashboardProvider);

    return AppScaffold(
      title: 'Patient Dashboard',
      body: RefreshIndicator(
        onRefresh: () => ref.refresh(patientDashboardProvider.future),
        child: dashboardAsync.when(
          data: (dashboard) => _buildDashboardContent(context, dashboard),
          loading: () => const Center(child: CircularProgressIndicator()),
          error: (error, stack) => _buildErrorView(context, error),
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => context.push('/emergency'),
        backgroundColor: AppColors.emergency,
        tooltip: 'Emergency',
        child: const Icon(Icons.emergency),
      ),
    );
  }

  Widget _buildDashboardContent(
      BuildContext context, PatientDashboardModel dashboard) {
    return CustomScrollView(
      slivers: [
        // Sliver App Bar with flexible header
        SliverAppBar(
          expandedHeight: 200.0,
          floating: false,
          pinned: true,
          flexibleSpace: FlexibleSpaceBar(
            title: const Text('Patient Dashboard'),
            background: Container(
              decoration: const BoxDecoration(
                gradient: LinearGradient(
                  colors: [AppColors.appPrimary, AppColors.appPrimaryLight],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
              ),
              child: Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    CircleAvatar(
                      radius: 40,
                      backgroundColor: Colors.white.withValues(alpha: 0.2),
                      child: const Icon(
                        Icons.person,
                        size: 40,
                        color: Colors.white,
                      ),
                    ),
                    const SizedBox(height: 16),
                    Text(
                      'Welcome back!',
                      style: AppTextStyles.headline5.copyWith(
                        color: Colors.white,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    Text(
                      'How are you feeling today?',
                      style: AppTextStyles.body1.copyWith(
                        color: Colors.white.withValues(alpha: 0.9),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),

        // Welcome Section
        SliverToBoxAdapter(
          child: Container(
            margin:
                const EdgeInsets.symmetric(horizontal: 16.0, vertical: 16.0),
            padding: const EdgeInsets.all(20.0),
            decoration: BoxDecoration(
              color: AppColors.appSurface,
              borderRadius: BorderRadius.circular(16.0),
              boxShadow: [
                BoxShadow(
                  color: AppColors.shadow.withValues(alpha: 0.1),
                  blurRadius: 8.0,
                  offset: const Offset(0, 2),
                ),
              ],
            ),
            child: Row(
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Health Overview',
                        style: AppTextStyles.headline6.copyWith(
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        'Monitor your vital signs and stay on top of your health',
                        style: AppTextStyles.body2.copyWith(
                          color: AppColors.textSecondary,
                        ),
                      ),
                    ],
                  ),
                ),
                const Icon(
                  Icons.health_and_safety,
                  size: 48,
                  color: AppColors.appPrimary,
                ),
              ],
            ),
          ),
        ),

        // Health Metrics
        SliverToBoxAdapter(
          child: _buildHealthMetricsSection(context, dashboard.healthMetrics),
        ),

        const SliverToBoxAdapter(
          child: SizedBox(height: 24),
        ),

        // Quick Actions
        const SliverToBoxAdapter(
          child: QuickActionsGrid(),
        ),

        const SliverToBoxAdapter(
          child: SizedBox(height: 24),
        ),

        // Upcoming Appointments
        const SliverToBoxAdapter(
          child: UpcomingAppointmentsCard(),
        ),

        const SliverToBoxAdapter(
          child: SizedBox(height: 24),
        ),

        // Medication Reminders
        const SliverToBoxAdapter(
          child: MedicationRemindersCard(),
        ),

        const SliverToBoxAdapter(
          child: SizedBox(height: 24),
        ),

        // Emergency Button
        const SliverToBoxAdapter(
          child: EmergencyButton(),
        ),

        const SliverToBoxAdapter(
          child: SizedBox(height: 32),
        ),
      ],
    );
  }

  Widget _buildHealthMetricsSection(
      BuildContext context, HealthMetrics metrics) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Health Metrics',
            style: AppTextStyles.headline6.copyWith(
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(height: 16),
          Row(
            children: [
              Expanded(
                child: HealthMetricsCard(
                  metricName: 'Heart Rate',
                  value: metrics.heartRate.toStringAsFixed(0),
                  unit: 'bpm',
                  status: _getHeartRateStatus(metrics.heartRate),
                  statusColor: _getHeartRateColor(metrics.heartRate),
                  icon: Icons.favorite,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: HealthMetricsCard(
                  metricName: 'Blood Pressure',
                  value: metrics.bloodPressure.toStringAsFixed(0),
                  unit: 'mmHg',
                  status: _getBloodPressureStatus(metrics.bloodPressure),
                  statusColor: _getBloodPressureColor(metrics.bloodPressure),
                  icon: Icons.bloodtype,
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              Expanded(
                child: HealthMetricsCard(
                  metricName: 'Temperature',
                  value: metrics.temperature.toStringAsFixed(1),
                  unit: '°C',
                  status: _getTemperatureStatus(metrics.temperature),
                  statusColor: _getTemperatureColor(metrics.temperature),
                  icon: Icons.thermostat,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: HealthMetricsCard(
                  metricName: 'Oxygen Saturation',
                  value:
                      (metrics.oxygenSaturation * 100).toStringAsFixed(0),
                  unit: '%',
                  status: _getOxygenStatus(metrics.oxygenSaturation),
                  statusColor: _getOxygenColor(metrics.oxygenSaturation),
                  icon: Icons.air,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildErrorView(BuildContext context, Object error) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Icon(
            Icons.error_outline,
            size: 64,
            color: AppColors.appError,
          ),
          const SizedBox(height: 16),
          const Text(
            'Unable to load dashboard',
            style: AppTextStyles.headline6,
          ),
          const SizedBox(height: 8),
          Text(
            error.toString(),
            style: AppTextStyles.body2.copyWith(
              color: AppColors.textSecondary,
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 24),
          ElevatedButton(
            onPressed: () => ref.refresh(patientDashboardProvider),
            child: const Text('Try Again'),
          ),
        ],
      ),
    );
  }

  String _getHeartRateStatus(double heartRate) {
    if (heartRate < 60) return 'Low';
    if (heartRate > 100) return 'High';
    return 'Normal';
  }

  Color _getHeartRateColor(double heartRate) {
    if (heartRate < 60 || heartRate > 100) return AppColors.appError;
    return AppColors.appSuccess;
  }

  String _getBloodPressureStatus(double bloodPressure) {
    if (bloodPressure < 90) return 'Low';
    if (bloodPressure > 140) return 'High';
    return 'Normal';
  }

  Color _getBloodPressureColor(double bloodPressure) {
    if (bloodPressure < 90 || bloodPressure > 140) return AppColors.appWarning;
    return AppColors.appSuccess;
  }

  String _getTemperatureStatus(double temperature) {
    if (temperature < 36.1) return 'Low';
    if (temperature > 37.5) return 'High';
    return 'Normal';
  }

  Color _getTemperatureColor(double temperature) {
    if (temperature < 36.1 || temperature > 37.5) return AppColors.appError;
    return AppColors.appSuccess;
  }

  String _getOxygenStatus(double oxygen) {
    if (oxygen < 0.95) return 'Low';
    return 'Normal';
  }

  Color _getOxygenColor(double oxygen) {
    if (oxygen < 0.95) return AppColors.appError;
    return AppColors.appSuccess;
  }
}
