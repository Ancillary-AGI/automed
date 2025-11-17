import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import 'package:automed_app/core/theme/app_colors.dart';
import 'package:automed_app/core/theme/app_text_styles.dart';
import 'package:automed_app/features/research/models/research_models.dart';
import 'package:automed_app/features/research/providers/research_providers.dart';

class ResearchDashboardPage extends ConsumerWidget {
  const ResearchDashboardPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final researchState = ref.watch(researchDashboardProvider);

    return Scaffold(
      appBar: AppBar(
        title: Text(
          'Research Platform',
          style: AppTextStyles.headlineSmall.copyWith(
            color: AppColors.appOnSurface,
            fontWeight: FontWeight.w600,
          ),
        ),
        backgroundColor: AppColors.appSurface,
        elevation: 0,
        actions: [
          IconButton(
            icon: const Icon(Icons.settings),
            onPressed: () => context.push('/research/settings'),
          ),
          IconButton(
            icon: const Icon(Icons.help_outline),
            onPressed: () => context.push('/research/help'),
          ),
        ],
      ),
      body: researchState.when(
        data: (dashboard) => _buildDashboard(context, dashboard),
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (error, stack) => Center(
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
                'Failed to load research dashboard',
                style: AppTextStyles.headlineSmall,
              ),
              const SizedBox(height: 8),
              Text(
                error.toString(),
                style: AppTextStyles.bodyMedium.copyWith(
                  color: AppColors.appOnSurfaceVariant,
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 16),
              ElevatedButton(
                onPressed: () => ref.invalidate(researchDashboardProvider),
                child: const Text('Retry'),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildDashboard(BuildContext context, ResearchDashboard dashboard) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Welcome Section
          _buildWelcomeSection(context, dashboard),

          const SizedBox(height: 24),

          // Active Projects
          _buildActiveProjectsSection(context, dashboard.activeProjects),

          const SizedBox(height: 24),

          // Research Modules Grid
          _buildResearchModulesGrid(context),

          const SizedBox(height: 24),

          // Recent Results
          _buildRecentResultsSection(context, dashboard.recentResults),

          const SizedBox(height: 24),

          // System Status
          _buildSystemStatusSection(context, dashboard.systemStatus),
        ],
      ),
    );
  }

  Widget _buildWelcomeSection(
      BuildContext context, ResearchDashboard dashboard) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [AppColors.appPrimary, AppColors.withOpacity(AppColors.appPrimary, 0.8)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: AppColors.appPrimary.withOpacity(0.3),
            blurRadius: 8,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Icon(
                Icons.science,
                color: AppColors.onPrimary,
                size: 32,
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Text(
                  'Welcome to AutoMed Research',
                  style: AppTextStyles.headlineMedium.copyWith(
                    color: AppColors.onPrimary,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Text(
            'Advanced computational tools for cutting-edge medical research',
            style: AppTextStyles.bodyLarge.copyWith(
              color: AppColors.onPrimary.withOpacity(0.9),
            ),
          ),
          const SizedBox(height: 16),
          Row(
            children: [
              _buildStatCard(
                'Active Projects',
                dashboard.activeProjects.length.toString(),
                Icons.folder_open,
              ),
              const SizedBox(width: 16),
              _buildStatCard(
                'GPU Hours Used',
                dashboard.gpuHoursUsed.toString(),
                Icons.memory,
              ),
              const SizedBox(width: 16),
              _buildStatCard(
                'Publications',
                dashboard.publicationsCount.toString(),
                Icons.article,
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildStatCard(String label, String value, IconData icon) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: AppColors.onPrimary.withOpacity(0.1),
          borderRadius: BorderRadius.circular(8),
        ),
        child: Column(
          children: [
            Icon(
              icon,
              color: AppColors.onPrimary,
              size: 20,
            ),
            const SizedBox(height: 4),
            Text(
              value,
              style: AppTextStyles.titleMedium.copyWith(
                color: AppColors.onPrimary,
                fontWeight: FontWeight.w600,
              ),
            ),
            Text(
              label,
              style: AppTextStyles.labelSmall.copyWith(
                color: AppColors.onPrimary.withOpacity(0.8),
              ),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildActiveProjectsSection(
      BuildContext context, List<ResearchProject> projects) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Text(
              'Active Projects',
              style: AppTextStyles.titleLarge.copyWith(
                fontWeight: FontWeight.w600,
              ),
            ),
            const Spacer(),
            TextButton(
              onPressed: () => context.push('/research/projects'),
              child: const Text('View All'),
            ),
          ],
        ),
        const SizedBox(height: 12),
        if (projects.isEmpty)
          Container(
            padding: const EdgeInsets.all(32),
            decoration: BoxDecoration(
              color: AppColors.appSurfaceVariant,
              borderRadius: BorderRadius.circular(12),
            ),
            child: Column(
              children: [
                const Icon(
                  Icons.folder_open,
                  size: 48,
                  color: AppColors.appOnSurfaceVariant,
                ),
                const SizedBox(height: 16),
                Text(
                  'No active projects',
                  style: AppTextStyles.titleMedium.copyWith(
                    color: AppColors.appOnSurfaceVariant,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  'Start your first research project',
                  style: AppTextStyles.bodyMedium.copyWith(
                    color: AppColors.appOnSurfaceVariant,
                  ),
                ),
                const SizedBox(height: 16),
                ElevatedButton(
                  onPressed: () => context.push('/research/projects/new'),
                  child: const Text('Create Project'),
                ),
              ],
            ),
          )
        else
          SizedBox(
            height: 200,
            child: ListView.builder(
              scrollDirection: Axis.horizontal,
              itemCount: projects.length,
              itemBuilder: (context, index) {
                final project = projects[index];
                return Container(
                  width: 280,
                  margin: const EdgeInsets.only(right: 12),
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: AppColors.appSurface,
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: AppColors.outline),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Icon(
                            _getProjectIcon(project.type),
                            color: AppColors.appPrimary,
                            size: 20,
                          ),
                          const SizedBox(width: 8),
                          Expanded(
                            child: Text(
                              project.title,
                              style: AppTextStyles.titleSmall.copyWith(
                                fontWeight: FontWeight.w600,
                              ),
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 8),
                      Text(
                        project.description,
                        style: AppTextStyles.bodySmall.copyWith(
                          color: AppColors.appOnSurfaceVariant,
                        ),
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                      ),
                      const Spacer(),
                      Row(
                        children: [
                          const Icon(
                            Icons.access_time,
                            size: 16,
                            color: AppColors.appOnSurfaceVariant,
                          ),
                          const SizedBox(width: 4),
                          Text(
                            '${project.progress}%',
                            style: AppTextStyles.labelSmall,
                          ),
                          const Spacer(),
                          Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 8,
                              vertical: 2,
                            ),
                            decoration: BoxDecoration(
                              color: _getStatusColor(project.status),
                              borderRadius: BorderRadius.circular(12),
                            ),
                            child: Text(
                              project.status.name,
                              style: AppTextStyles.labelSmall.copyWith(
                                color: AppColors.onPrimary,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                );
              },
            ),
          ),
      ],
    );
  }

  Widget _buildResearchModulesGrid(BuildContext context) {
    final modules = [
      const ResearchModule(
        title: 'Molecular Simulation',
        description: 'Drug-target interactions, molecular dynamics',
        icon: Icons.science,
        color: Colors.blue,
        route: '/research/molecular',
      ),
      const ResearchModule(
        title: 'Cancer Research',
        description: 'Tumor modeling, drug resistance, immunotherapy',
        icon: Icons.biotech,
        color: Colors.red,
        route: '/research/cancer',
      ),
      const ResearchModule(
        title: 'Tissue Engineering',
        description: 'Scaffold design, stem cell differentiation',
        icon: Icons.healing,
        color: Colors.green,
        route: '/research/tissue',
      ),
      const ResearchModule(
        title: 'Medical Robotics',
        description: 'Surgical planning, rehabilitation systems',
        icon: Icons.precision_manufacturing,
        color: Colors.orange,
        route: '/research/robotics',
      ),
      const ResearchModule(
        title: 'Computational Biology',
        description: 'Genomics, proteomics, systems biology',
        icon: Icons.analytics,
        color: Colors.purple,
        route: '/research/biology',
      ),
      const ResearchModule(
        title: 'Drug Development',
        description: 'Virtual screening, ADMET prediction',
        icon: Icons.medication,
        color: Colors.teal,
        route: '/research/drug-dev',
      ),
    ];

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Research Modules',
          style: AppTextStyles.titleLarge.copyWith(
            fontWeight: FontWeight.w600,
          ),
        ),
        const SizedBox(height: 12),
        GridView.builder(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: 2,
            crossAxisSpacing: 12,
            mainAxisSpacing: 12,
            childAspectRatio: 1.2,
          ),
          itemCount: modules.length,
          itemBuilder: (context, index) {
            final module = modules[index];
            return InkWell(
              onTap: () => context.push(module.route),
              borderRadius: BorderRadius.circular(12),
              child: Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: AppColors.appSurface,
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: AppColors.outline),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Icon(
                      module.icon,
                      color: module.color,
                      size: 32,
                    ),
                    const SizedBox(height: 8),
                    Text(
                      module.title,
                      style: AppTextStyles.titleSmall.copyWith(
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Expanded(
                      child: Text(
                        module.description,
                        style: AppTextStyles.bodySmall.copyWith(
                          color: AppColors.appOnSurfaceVariant,
                        ),
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                  ],
                ),
              ),
            );
          },
        ),
      ],
    );
  }

  Widget _buildRecentResultsSection(
      BuildContext context, List<ResearchResult> results) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Text(
              'Recent Results',
              style: AppTextStyles.titleLarge.copyWith(
                fontWeight: FontWeight.w600,
              ),
            ),
            const Spacer(),
            TextButton(
              onPressed: () => context.push('/research/results'),
              child: const Text('View All'),
            ),
          ],
        ),
        const SizedBox(height: 12),
        if (results.isEmpty)
          Container(
            padding: const EdgeInsets.all(32),
            decoration: BoxDecoration(
              color: AppColors.appSurfaceVariant,
              borderRadius: BorderRadius.circular(12),
            ),
            child: Center(
              child: Text(
                'No recent results',
                style: AppTextStyles.bodyLarge.copyWith(
                  color: AppColors.appOnSurfaceVariant,
                ),
              ),
            ),
          )
        else
          ListView.builder(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            itemCount: results.take(3).length,
            itemBuilder: (context, index) {
              final result = results[index];
              return Container(
                margin: const EdgeInsets.only(bottom: 8),
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: AppColors.appSurface,
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(color: AppColors.outline),
                ),
                child: Row(
                  children: [
                    Icon(
                      _getResultIcon(result.type),
                      color: AppColors.appPrimary,
                      size: 24,
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            result.title,
                            style: AppTextStyles.titleSmall.copyWith(
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                          Text(
                            result.description,
                            style: AppTextStyles.bodySmall.copyWith(
                              color: AppColors.appOnSurfaceVariant,
                            ),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(width: 12),
                    Text(
                      _formatDate(result.createdAt),
                      style: AppTextStyles.labelSmall.copyWith(
                        color: AppColors.appOnSurfaceVariant,
                      ),
                    ),
                  ],
                ),
              );
            },
          ),
      ],
    );
  }

  Widget _buildSystemStatusSection(BuildContext context, SystemStatus status) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.appSurface,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppColors.outline),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Text(
                'System Status',
                style: AppTextStyles.titleMedium.copyWith(
                  fontWeight: FontWeight.w600,
                ),
              ),
              const Spacer(),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(
                  color: status.overallHealth == 'healthy'
                      ? Colors.green
                      : status.overallHealth == 'warning'
                          ? Colors.orange
                          : Colors.red,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Text(
                  status.overallHealth.toUpperCase(),
                  style: AppTextStyles.labelSmall.copyWith(
                    color: AppColors.onPrimary,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              Expanded(
                child: _buildStatusMetric(
                  'GPU Usage',
                  '${status.gpuUsage}%',
                  Icons.memory,
                ),
              ),
              Expanded(
                child: _buildStatusMetric(
                  'Storage',
                  '${status.storageUsage}%',
                  Icons.storage,
                ),
              ),
              Expanded(
                child: _buildStatusMetric(
                  'Active Jobs',
                  status.activeJobs.toString(),
                  Icons.play_circle,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildStatusMetric(String label, String value, IconData icon) {
    return Column(
      children: [
        Icon(
          icon,
          color: AppColors.appPrimary,
          size: 20,
        ),
        const SizedBox(height: 4),
        Text(
          value,
          style: AppTextStyles.titleSmall.copyWith(
            fontWeight: FontWeight.w600,
          ),
        ),
        Text(
          label,
          style: AppTextStyles.labelSmall.copyWith(
            color: AppColors.appOnSurfaceVariant,
          ),
          textAlign: TextAlign.center,
        ),
      ],
    );
  }

  IconData _getProjectIcon(ProjectType type) {
    return switch (type) {
      ProjectType.molecular => Icons.science,
      ProjectType.cancer => Icons.biotech,
      ProjectType.tissue => Icons.healing,
      ProjectType.robotics => Icons.precision_manufacturing,
      ProjectType.biology => Icons.analytics,
      ProjectType.drug => Icons.medication,
      ProjectType.cancerResearch => Icons.biotech,
      ProjectType.computationalBiology => Icons.analytics,
      ProjectType.medicalRobotics => Icons.precision_manufacturing,
      ProjectType.molecularSimulation => Icons.science,
      ProjectType.tissueEngineering => Icons.healing,
    };
  }

  Color _getStatusColor(ProjectStatus status) {
    return switch (status) {
      ProjectStatus.active => Colors.green,
      ProjectStatus.paused => Colors.orange,
      ProjectStatus.completed => Colors.blue,
      ProjectStatus.failed => Colors.red,
      ProjectStatus.planning => Colors.grey,
      ProjectStatus.cancelled => Colors.red,
    };
  }

  IconData _getResultIcon(ResultType type) {
    return switch (type) {
      ResultType.simulation => Icons.science,
      ResultType.analysis => Icons.analytics,
      ResultType.prediction => Icons.trending_up,
      ResultType.visualization => Icons.visibility,
      ResultType.publication => Icons.article,
      ResultType.patent => Icons.lightbulb,
      ResultType.clinicalTrial => Icons.medical_services,
      ResultType.software => Icons.computer,
      ResultType.data => Icons.table_chart,
    };
  }

  String _formatDate(DateTime date) {
    final now = DateTime.now();
    final difference = now.difference(date);

    if (difference.inDays == 0) {
      return 'Today';
    } else if (difference.inDays == 1) {
      return 'Yesterday';
    } else if (difference.inDays < 7) {
      return '${difference.inDays} days ago';
    } else {
      return '${date.month}/${date.day}/${date.year}';
    }
  }
}

class ResearchModule {
  final String title;
  final String description;
  final IconData icon;
  final Color color;
  final String route;

  const ResearchModule({
    required this.title,
    required this.description,
    required this.icon,
    required this.color,
    required this.route,
  });
}
