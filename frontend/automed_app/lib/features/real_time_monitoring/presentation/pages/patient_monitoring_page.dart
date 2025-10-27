import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:fl_chart/fl_chart.dart';

import '../../../../core/theme/app_colors.dart';

class PatientMonitoringPage extends ConsumerStatefulWidget {
  final String patientId;
  
  const PatientMonitoringPage({
    super.key,
    required this.patientId,
  });

  @override
  ConsumerState<PatientMonitoringPage> createState() => _PatientMonitoringPageState();
}

class _PatientMonitoringPageState extends ConsumerState<PatientMonitoringPage>
    with TickerProviderStateMixin {
  late AnimationController _heartbeatController;
  late Animation<double> _heartbeatAnimation;
  
  @override
  void initState() {
    super.initState();
    _setupAnimations();
  }

  @override
  void dispose() {
    _heartbeatController.dispose();
    super.dispose();
  }

  void _setupAnimations() {
    _heartbeatController = AnimationController(
      duration: const Duration(milliseconds: 800),
      vsync: this,
    );
    _heartbeatAnimation = Tween<double>(
      begin: 1.0,
      end: 1.3,
    ).animate(CurvedAnimation(
      parent: _heartbeatController,
      curve: Curves.easeInOut,
    ));
    
    _heartbeatController.repeat(reverse: true);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Patient Monitoring'),
        backgroundColor: AppColors.primary,
        foregroundColor: Colors.white,
        actions: [
          IconButton(
            icon: const Icon(Icons.emergency),
            onPressed: _triggerEmergencyAlert,
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            _buildVitalSignsGrid(),
            const SizedBox(height: 24),
            _buildRealTimeCharts(),
            const SizedBox(height: 24),
            _buildAlertsPanel(),
          ],
        ),
      ),
    );
  }

  Widget _buildVitalSignsGrid() {
    return GridView.count(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      crossAxisCount: 2,
      crossAxisSpacing: 16,
      mainAxisSpacing: 16,
      children: [
        _buildVitalSignCard(
          'Heart Rate',
          '72',
          'bpm',
          Icons.favorite,
          AppColors.heartRate,
          isAnimated: true,
        ),
        _buildVitalSignCard(
          'Blood Pressure',
          '120/80',
          'mmHg',
          Icons.bloodtype,
          AppColors.bloodPressure,
        ),
        _buildVitalSignCard(
          'Temperature',
          '98.6',
          '°F',
          Icons.thermostat,
          AppColors.temperature,
        ),
        _buildVitalSignCard(
          'Oxygen Sat',
          '98',
          '%',
          Icons.air,
          AppColors.oxygenSaturation,
        ),
      ],
    );
  }

  Widget _buildVitalSignCard(
    String title,
    String value,
    String unit,
    IconData icon,
    Color color, {
    bool isAnimated = false,
  }) {
    Widget iconWidget = Icon(icon, color: color, size: 32);
    
    if (isAnimated) {
      iconWidget = AnimatedBuilder(
        animation: _heartbeatAnimation,
        builder: (context, child) {
          return Transform.scale(
            scale: _heartbeatAnimation.value,
            child: Icon(icon, color: color, size: 32),
          );
        },
      );
    }

    return Card(
      elevation: 4,
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            iconWidget,
            const SizedBox(height: 8),
            Text(
              value,
              style: const TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
              ),
            ),
            Text(
              unit,
              style: TextStyle(
                fontSize: 12,
                color: AppColors.textSecondary,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              title,
              style: const TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.w500,
              ),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildRealTimeCharts() {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Real-Time Trends',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 16),
            SizedBox(
              height: 200,
              child: LineChart(
                LineChartData(
                  gridData: FlGridData(show: true),
                  titlesData: FlTitlesData(show: true),
                  borderData: FlBorderData(show: true),
                  lineBarsData: [
                    LineChartBarData(
                      spots: _generateHeartRateData(),
                      isCurved: true,
                      color: AppColors.heartRate,
                      barWidth: 2,
                      dotData: FlDotData(show: false),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildAlertsPanel() {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Active Alerts',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 16),
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: AppColors.success.withOpacity(0.1),
                borderRadius: BorderRadius.circular(8),
                border: Border.all(color: AppColors.success.withOpacity(0.3)),
              ),
              child: Row(
                children: [
                  Icon(Icons.check_circle, color: AppColors.success),
                  const SizedBox(width: 12),
                  const Expanded(
                    child: Text(
                      'All vital signs are within normal ranges',
                      style: TextStyle(fontWeight: FontWeight.w500),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  List<FlSpot> _generateHeartRateData() {
    // Generate sample heart rate data
    return List.generate(20, (index) {
      return FlSpot(
        index.toDouble(),
        70 + (index % 3) * 5 + (index % 7) * 2,
      );
    });
  }

  void _triggerEmergencyAlert() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Emergency Alert'),
        content: const Text('Are you sure you want to trigger an emergency alert?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.of(context).pop();
              // Trigger emergency alert
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.error,
            ),
            child: const Text('Confirm'),
          ),
        ],
      ),
    );
  }
}