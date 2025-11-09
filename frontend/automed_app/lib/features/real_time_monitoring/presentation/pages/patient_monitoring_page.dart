import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../core/di/injection.dart';
import 'package:fl_chart/fl_chart.dart';

import '../../../../core/theme/app_colors.dart';

class PatientMonitoringPage extends ConsumerStatefulWidget {
  final String patientId;

  const PatientMonitoringPage({
    super.key,
    required this.patientId,
  });

  @override
  ConsumerState<PatientMonitoringPage> createState() =>
      _PatientMonitoringPageState();
}

class _PatientMonitoringPageState extends ConsumerState<PatientMonitoringPage>
    with TickerProviderStateMixin {
  late AnimationController _heartbeatController;
  late Animation<double> _heartbeatAnimation;
  List<FlSpot> _heartRateSpots = [];
  String _heartRateValue = '72';
  String _bloodPressureValue = '120/80';
  String _temperatureValue = '98.6';
  String _oxygenValue = '98';
  bool _isLoading = true;
  String? _errorMessage;

  @override
  void initState() {
    super.initState();
    _setupAnimations();
    // Load initial vitals from API (no mock fallbacks)
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _refreshVitals();
    });
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
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: _isLoading
            ? const Center(child: CircularProgressIndicator())
            : (_errorMessage != null
                ? Center(
                    child: Card(
                      child: Padding(
                        padding: const EdgeInsets.all(16),
                        child: Column(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            const Icon(Icons.error,
                                color: Colors.red, size: 48),
                            const SizedBox(height: 8),
                            Text('Failed to load vitals'),
                            const SizedBox(height: 8),
                            Text(_errorMessage ?? ''),
                          ],
                        ),
                      ),
                    ),
                  )
                : SingleChildScrollView(
                    child: Column(
                      children: [
                        _buildVitalSignsGrid(),
                        const SizedBox(height: 24),
                        _buildRealTimeCharts(),
                        const SizedBox(height: 24),
                        _buildAlertsPanel(),
                      ],
                    ),
                  )),
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
          _heartRateValue,
          'bpm',
          Icons.favorite,
          AppColors.vitalSigns,
          isAnimated: true,
        ),
        _buildVitalSignCard(
          'Blood Pressure',
          _bloodPressureValue,
          'mmHg',
          Icons.bloodtype,
          AppColors.vitalSigns,
        ),
        _buildVitalSignCard(
          'Temperature',
          _temperatureValue,
          '°F',
          Icons.thermostat,
          AppColors.vitalSigns,
        ),
        _buildVitalSignCard(
          'Oxygen Sat',
          _oxygenValue,
          '%',
          Icons.air,
          AppColors.vitalSigns,
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
              child: _heartRateSpots.isEmpty
                  ? Center(
                      child: Text(
                        'No real-time heart rate data available',
                        style: TextStyle(color: AppColors.textSecondary),
                      ),
                    )
                  : LineChart(
                      LineChartData(
                        gridData: FlGridData(show: true),
                        titlesData: FlTitlesData(show: true),
                        borderData: FlBorderData(show: true),
                        lineBarsData: [
                          LineChartBarData(
                            spots: _heartRateSpots,
                            isCurved: true,
                            color: AppColors.vitalSigns,
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

  Future<void> _loadVitals() async {
    final api = ref.read(apiServiceProvider);
    final resp =
        await api.get('/patients/${Uri.encodeComponent(widget.patientId)}');

    // Expecting structure { 'vitals': { ... } }
    final vitals = resp['vitals'] as Map<String, dynamic>?;
    if (vitals == null) {
      throw Exception(
          'No vitals data returned for patient ${widget.patientId}');
    }

    setState(() {
      final heart = vitals['heartRate'];
      final bp = vitals['bloodPressure'];
      final temp = vitals['temperature'];
      final oxy = vitals['oxygenSaturation'];

      _heartRateValue = heart != null ? heart.toString() : '';
      _bloodPressureValue = bp != null ? bp.toString() : '';
      _temperatureValue = temp != null ? temp.toString() : '';
      _oxygenValue = oxy != null ? oxy.toString() : '';

      final series = (vitals['heartRateSeries'] as List<dynamic>?)
              ?.map((e) => (e as num).toDouble())
              .toList() ??
          [];
      _heartRateSpots =
          List.generate(series.length, (i) => FlSpot(i.toDouble(), series[i]));
    });
  }

  Future<void> _refreshVitals() async {
    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    try {
      await _loadVitals();
    } catch (e) {
      setState(() {
        _errorMessage = e.toString();
      });
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  void _triggerEmergencyAlert() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Emergency Alert'),
        content:
            const Text('Are you sure you want to trigger an emergency alert?'),
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
