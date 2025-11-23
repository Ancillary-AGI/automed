import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../widgets/mobile_quick_actions.dart';
import '../widgets/mobile_patient_summary.dart';
import '../widgets/mobile_alerts_panel.dart';
import '../widgets/mobile_vitals_monitor.dart';
import '../providers/mobile_dashboard_provider.dart';

class MobileDashboard extends ConsumerStatefulWidget {
  const MobileDashboard({super.key});

  @override
  ConsumerState<MobileDashboard> createState() => _MobileDashboardState();
}

class _MobileDashboardState extends ConsumerState<MobileDashboard>
    with TickerProviderStateMixin {
  late TabController _tabController;
  final PageController _pageController = PageController();

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 4, vsync: this);
  }

  @override
  Widget build(BuildContext context) {
    final dashboardState = ref.watch(mobileDashboardProvider);
    final screenSize = MediaQuery.of(context).size;
    final isTablet = screenSize.width > 600;

    return Scaffold(
      body: SafeArea(
        child: dashboardState.when(
          data: (data) =>
              isTablet ? _buildTabletLayout(data) : _buildPhoneLayout(data),
          loading: () => const Center(child: CircularProgressIndicator()),
          error: (error, stack) => _buildErrorState(error),
        ),
      ),
      bottomNavigationBar: _buildBottomNavigation(),
      floatingActionButton: _buildFloatingActionButton(),
      floatingActionButtonLocation: FloatingActionButtonLocation.centerDocked,
    );
  }

  Widget _buildPhoneLayout(dynamic data) {
    return CustomScrollView(
      slivers: [
        _buildSliverAppBar(data),
        SliverToBoxAdapter(
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Quick Actions
                const MobileQuickActions(),
                const SizedBox(height: 16),

                // Critical Alerts
                if (data.criticalAlerts.isNotEmpty) ...[
                  const MobileAlertsPanel(),
                  const SizedBox(height: 16),
                ],

                // Patient Summary Cards
                const MobilePatientSummary(),
                const SizedBox(height: 16),

                // Vital Signs Monitor
                const MobileVitalsMonitor(),
                const SizedBox(height: 16),

                // Recent Activities
                _buildRecentActivities(data.recentActivities),
                const SizedBox(height: 80), // Space for FAB
              ],
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildTabletLayout(dynamic data) {
    return Row(
      children: [
        // Left Panel - Navigation and Quick Actions
        Container(
          width: 300,
          decoration: BoxDecoration(
            color: Theme.of(context).colorScheme.surface,
            border: Border(
              right: BorderSide(color: Colors.grey[300]!),
            ),
          ),
          child: Column(
            children: [
              _buildTabletHeader(data),
              const Expanded(child: MobileQuickActions()),
            ],
          ),
        ),

        // Main Content Area
        Expanded(
          child: Column(
            children: [
              // Top Bar with Alerts
              if (data.criticalAlerts.isNotEmpty)
                Container(
                  height: 80,
                  padding: const EdgeInsets.all(16),
                  child: const MobileAlertsPanel(),
                ),

              // Content Tabs
              Expanded(
                child: TabBarView(
                  controller: _tabController,
                  children: [
                    const MobilePatientSummary(),
                    const MobileVitalsMonitor(),
                    _buildRecentActivities(data.recentActivities),
                    _buildAnalyticsSummary(data),
                  ],
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildSliverAppBar(dynamic data) {
    return SliverAppBar(
      expandedHeight: 120,
      floating: false,
      pinned: true,
      backgroundColor: Theme.of(context).colorScheme.primary,
      flexibleSpace: FlexibleSpaceBar(
        title: const Text(
          'Automed Mobile',
          style: TextStyle(color: Colors.white),
        ),
        background: Container(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [
                Theme.of(context).colorScheme.primary,
                Theme.of(context).colorScheme.primary.withValues(alpha: 0.8),
              ],
            ),
          ),
          child: Padding(
            padding: const EdgeInsets.fromLTRB(16, 60, 16, 16),
            child: Row(
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisAlignment: MainAxisAlignment.end,
                    children: [
                      Text(
                        'Welcome back, Dr. ${data.currentUser?.name ?? 'User'}',
                        style: const TextStyle(
                          color: Colors.white70,
                          fontSize: 14,
                        ),
                      ),
                      Text(
                        '${data.activePatients} active patients',
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 16,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ],
                  ),
                ),
                CircleAvatar(
                  radius: 20,
                  backgroundColor: Colors.white.withValues(alpha: 0.2),
                  child: const Icon(Icons.person, color: Colors.white),
                ),
              ],
            ),
          ),
        ),
      ),
      actions: [
        IconButton(
          icon: const Icon(Icons.notifications, color: Colors.white),
          onPressed: () => _showNotifications(),
        ),
        IconButton(
          icon: const Icon(Icons.search, color: Colors.white),
          onPressed: () => _showSearch(),
        ),
      ],
    );
  }

  Widget _buildTabletHeader(dynamic data) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.primary,
        borderRadius: const BorderRadius.only(
          bottomRight: Radius.circular(16),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              CircleAvatar(
                radius: 24,
                backgroundColor: Colors.white.withValues(alpha: 0.2),
                child: const Icon(Icons.person, color: Colors.white),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Dr. ${data.currentUser?.name ?? 'User'}',
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    Text(
                      '${data.activePatients} active patients',
                      style: const TextStyle(
                        color: Colors.white70,
                        fontSize: 14,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          TabBar(
            controller: _tabController,
            indicatorColor: Colors.white,
            labelColor: Colors.white,
            unselectedLabelColor: Colors.white70,
            tabs: const [
              Tab(text: 'Patients'),
              Tab(text: 'Vitals'),
              Tab(text: 'Activity'),
              Tab(text: 'Analytics'),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildRecentActivities(List<dynamic> activities) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Recent Activities',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 16),
            ...activities
                .take(10)
                .map((activity) => _buildActivityTile(activity)),
          ],
        ),
      ),
    );
  }

  Widget _buildActivityTile(dynamic activity) {
    IconData icon;
    Color iconColor;

    switch (activity.type) {
      case 'patient_admission':
        icon = Icons.person_add;
        iconColor = Colors.green;
        break;
      case 'vital_alert':
        icon = Icons.warning;
        iconColor = Colors.orange;
        break;
      case 'medication_administered':
        icon = Icons.medication;
        iconColor = Colors.blue;
        break;
      case 'consultation_completed':
        icon = Icons.video_call;
        iconColor = Colors.purple;
        break;
      default:
        icon = Icons.info;
        iconColor = Colors.grey;
    }

    return ListTile(
      leading: CircleAvatar(
        backgroundColor: iconColor.withValues(alpha: 0.2),
        child: Icon(icon, color: iconColor),
      ),
      title: Text(activity.title),
      subtitle: Text(activity.description),
      trailing: Text(
        _formatTime(activity.timestamp),
        style: TextStyle(
          fontSize: 12,
          color: Colors.grey[600],
        ),
      ),
    );
  }

  Widget _buildAnalyticsSummary(dynamic data) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        children: [
          // Key Metrics
          GridView.count(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            crossAxisCount: 2,
            childAspectRatio: 1.5,
            crossAxisSpacing: 16,
            mainAxisSpacing: 16,
            children: [
              _buildMetricCard('Patient Load', '${data.activePatients}',
                  Icons.people, Colors.blue),
              _buildMetricCard('Avg Response', '${data.avgResponseTime}min',
                  Icons.timer, Colors.green),
              _buildMetricCard('Bed Occupancy', '${data.bedOccupancy}%',
                  Icons.bed, Colors.orange),
              _buildMetricCard('Critical Alerts',
                  '${data.criticalAlerts.length}', Icons.warning, Colors.red),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildMetricCard(
      String title, String value, IconData icon, Color color) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icon, color: color, size: 32),
            const SizedBox(height: 8),
            Text(
              value,
              style: const TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
              ),
            ),
            Text(
              title,
              style: TextStyle(
                color: Colors.grey[600],
                fontSize: 12,
              ),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildBottomNavigation() {
    return BottomAppBar(
      shape: const CircularNotchedRectangle(),
      notchMargin: 8,
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        children: [
          IconButton(
            icon: const Icon(Icons.dashboard),
            onPressed: () {},
          ),
          IconButton(
            icon: const Icon(Icons.people),
            onPressed: () {},
          ),
          const SizedBox(width: 40), // Space for FAB
          IconButton(
            icon: const Icon(Icons.analytics),
            onPressed: () {},
          ),
          IconButton(
            icon: const Icon(Icons.settings),
            onPressed: () {},
          ),
        ],
      ),
    );
  }

  Widget _buildFloatingActionButton() {
    return FloatingActionButton(
      onPressed: () => _showQuickActions(),
      child: const Icon(Icons.add),
    );
  }

  Widget _buildErrorState(dynamic error) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.error_outline, size: 64, color: Colors.red[300]),
          const SizedBox(height: 16),
          Text('Error loading dashboard: $error'),
          const SizedBox(height: 16),
          ElevatedButton(
            onPressed: () => ref.refresh(mobileDashboardProvider),
            child: const Text('Retry'),
          ),
        ],
      ),
    );
  }

  void _showNotifications() {
    // Show notifications bottom sheet
  }

  void _showSearch() {
    // Show search interface
  }

  void _showQuickActions() {
    showModalBottomSheet(
      context: context,
      builder: (context) => const MobileQuickActions(),
    );
  }

  String _formatTime(DateTime timestamp) {
    final now = DateTime.now();
    final difference = now.difference(timestamp);

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

  @override
  void dispose() {
    _tabController.dispose();
    _pageController.dispose();
    super.dispose();
  }
}
