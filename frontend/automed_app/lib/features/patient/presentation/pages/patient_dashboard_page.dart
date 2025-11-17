import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import 'package:automed_app/core/theme/app_colors.dart';

class PatientDashboardPage extends ConsumerWidget {
  const PatientDashboardPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Patient Dashboard'),
        actions: [
          IconButton(
            icon: const Icon(Icons.notifications),
            onPressed: () {
              context.go('/notifications');
            },
          ),
          IconButton(
            icon: const Icon(Icons.settings),
            onPressed: () {
              context.go('/settings');
            },
          ),
        ],
      ),
      body: const SingleChildScrollView(
        padding: EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _WelcomeCard(),
            SizedBox(height: 16),
            _QuickActionsGrid(),
            SizedBox(height: 16),
            _UpcomingAppointments(),
            SizedBox(height: 16),
            _RecentActivity(),
          ],
        ),
      ),
      bottomNavigationBar: const _PatientBottomNavBar(),
    );
  }
}

class _WelcomeCard extends StatelessWidget {
  const _WelcomeCard();

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Welcome back, John!',
              style: Theme.of(context).textTheme.headlineSmall,
            ),
            const SizedBox(height: 8),
            Text(
              'How are you feeling today?',
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                    color: AppColors.textSecondary,
                  ),
            ),
            const SizedBox(height: 16),
            const Row(
              children: [
                _HealthStatusChip(
                  label: 'Good',
                  color: AppColors.appSuccess,
                  isSelected: true,
                ),
                SizedBox(width: 8),
                _HealthStatusChip(
                  label: 'Fair',
                  color: AppColors.appWarning,
                  isSelected: false,
                ),
                SizedBox(width: 8),
                _HealthStatusChip(
                  label: 'Poor',
                  color: AppColors.appError,
                  isSelected: false,
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

class _HealthStatusChip extends StatelessWidget {
  final String label;
  final Color color;
  final bool isSelected;

  const _HealthStatusChip({
    required this.label,
    required this.color,
    required this.isSelected,
  });

  @override
  Widget build(BuildContext context) {
    return FilterChip(
      label: Text(label),
      selected: isSelected,
      onSelected: (selected) {
        if (selected) {
          // Show health status details
          showDialog(
            context: context,
            builder: (context) => AlertDialog(
              title: Text('$label Status'),
              content: Text(
                  'Current status: $label\nLast updated: ${DateTime.now().toString().substring(0, 16)}'),
              actions: [
                TextButton(
                  onPressed: () => Navigator.pop(context),
                  child: const Text('OK'),
                ),
              ],
            ),
          );
        }
      },
      backgroundColor: color.withValues(alpha: 0.1),
      selectedColor: color.withValues(alpha: 0.2),
      checkmarkColor: color,
    );
  }
}

class _QuickActionsGrid extends StatelessWidget {
  const _QuickActionsGrid();

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Quick Actions',
          style: Theme.of(context).textTheme.titleLarge,
        ),
        const SizedBox(height: 12),
        GridView.count(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          crossAxisCount: 2,
          crossAxisSpacing: 12,
          mainAxisSpacing: 12,
          childAspectRatio: 1.5,
          children: const [
            _QuickActionCard(
              icon: Icons.video_call,
              title: 'Start Consultation',
              subtitle: 'Connect with a doctor',
              color: AppColors.appPrimary,
            ),
            _QuickActionCard(
              icon: Icons.medication,
              title: 'Medications',
              subtitle: 'View & track meds',
              color: AppColors.appSecondary,
            ),
            _QuickActionCard(
              icon: Icons.emergency,
              title: 'Emergency',
              subtitle: 'Get immediate help',
              color: AppColors.emergency,
            ),
            _QuickActionCard(
              icon: Icons.health_and_safety,
              title: 'Health Records',
              subtitle: 'View medical history',
              color: AppColors.appInfo,
            ),
          ],
        ),
      ],
    );
  }
}

class _QuickActionCard extends StatelessWidget {
  final IconData icon;
  final String title;
  final String subtitle;
  final Color color;

  const _QuickActionCard({
    required this.icon,
    required this.title,
    required this.subtitle,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      child: InkWell(
        onTap: () {
          switch (title) {
            case 'Start Consultation':
              context.go('/patient-dashboard/consultations');
              break;
            case 'Medications':
              context.go('/patient-dashboard/medications');
              break;
            case 'Emergency':
              context.go('/emergency');
              break;
            case 'Health Records':
              context.go('/health-records');
              break;
          }
        },
        borderRadius: BorderRadius.circular(12),
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Icon(
                icon,
                color: color,
                size: 32,
              ),
              const SizedBox(height: 8),
              Text(
                title,
                style: Theme.of(context).textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.w600,
                    ),
              ),
              Text(
                subtitle,
                style: Theme.of(context).textTheme.bodySmall?.copyWith(
                      color: AppColors.textSecondary,
                    ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _UpcomingAppointments extends StatelessWidget {
  const _UpcomingAppointments();

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              'Upcoming Appointments',
              style: Theme.of(context).textTheme.titleLarge,
            ),
            TextButton(
              onPressed: () {
                context.go('/patient-dashboard/consultations');
              },
              child: const Text('View All'),
            ),
          ],
        ),
        const SizedBox(height: 12),
        Card(
          child: ListTile(
            leading: CircleAvatar(
              backgroundColor: AppColors.appPrimary.withValues(alpha: 0.1),
              child: const Icon(Icons.person, color: AppColors.appPrimary),
            ),
            title: const Text('Dr. Sarah Johnson'),
            subtitle: const Text('General Consultation • Tomorrow 2:00 PM'),
            trailing: const Icon(Icons.chevron_right),
            onTap: () {
              context.go('/patient-dashboard/consultations');
            },
          ),
        ),
      ],
    );
  }
}

class _RecentActivity extends StatelessWidget {
  const _RecentActivity();

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Recent Activity',
          style: Theme.of(context).textTheme.titleLarge,
        ),
        const SizedBox(height: 12),
        const Card(
          child: Column(
            children: [
              ListTile(
                leading: Icon(Icons.medication, color: AppColors.appSuccess),
                title: Text('Medication taken'),
                subtitle: Text('Aspirin 100mg • 2 hours ago'),
                trailing:
                    Icon(Icons.check_circle, color: AppColors.appSuccess),
              ),
              Divider(height: 1),
              ListTile(
                leading: Icon(Icons.favorite, color: AppColors.heartRate),
                title: Text('Vitals recorded'),
                subtitle: Text('Heart rate: 72 bpm • 4 hours ago'),
                trailing: Icon(Icons.chevron_right),
              ),
            ],
          ),
        ),
      ],
    );
  }
}

class _PatientBottomNavBar extends StatelessWidget {
  const _PatientBottomNavBar();

  @override
  Widget build(BuildContext context) {
    return BottomNavigationBar(
      type: BottomNavigationBarType.fixed,
      currentIndex: 0,
      items: const [
        BottomNavigationBarItem(
          icon: Icon(Icons.home),
          label: 'Home',
        ),
        BottomNavigationBarItem(
          icon: Icon(Icons.calendar_today),
          label: 'Appointments',
        ),
        BottomNavigationBarItem(
          icon: Icon(Icons.medication),
          label: 'Medications',
        ),
        BottomNavigationBarItem(
          icon: Icon(Icons.person),
          label: 'Profile',
        ),
      ],
      onTap: (index) {
        switch (index) {
          case 0:
            // Already on dashboard
            break;
          case 1:
            context.go('/patient-dashboard/consultations');
            break;
          case 2:
            context.go('/patient-dashboard/medications');
            break;
          case 3:
            context.go('/patient-dashboard/profile');
            break;
        }
      },
    );
  }
}
