import 'dart:async';

import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:automed_app/core/di/injection.dart';
import 'package:automed_app/core/theme/app_colors.dart';

class RealTimeVitalsWidget extends ConsumerStatefulWidget {
  final String patientId;
  final bool isFullScreen;

  const RealTimeVitalsWidget({
    super.key,
    required this.patientId,
    this.isFullScreen = false,
  });

  @override
  ConsumerState<RealTimeVitalsWidget> createState() =>
      _RealTimeVitalsWidgetState();
}

class _RealTimeVitalsWidgetState extends ConsumerState<RealTimeVitalsWidget>
    with TickerProviderStateMixin {
  late AnimationController _heartbeatController;
  late Animation<double> _heartbeatAnimation;

  Timer? _dataUpdateTimer;
  List<VitalSignData> _heartRateData = [];
  final List<VitalSignData> _bloodPressureData = [];
  final List<VitalSignData> _oxygenSatData = [];
  final List<VitalSignData> _temperatureData = [];

  VitalSigns _currentVitals = VitalSigns.normal();
  List<VitalAlert> _activeAlerts = [];

  @override
  void initState() {
    super.initState();
    _setupAnimations();
    _startRealTimeUpdates();
  }

  @override
  void dispose() {
    _heartbeatController.dispose();
    _dataUpdateTimer?.cancel();
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

  void _startRealTimeUpdates() {
    // Poll backend for latest vitals periodically. No synthetic/mock data used.
    _dataUpdateTimer =
        Timer.periodic(const Duration(seconds: 1), (timer) async {
      await _fetchVitalsFromApi();
      _checkForAlerts();
    });
  }

  Future<void> _fetchVitalsFromApi() async {
    try {
      final api = ref.read(apiServiceProvider);
      final resp =
          await api.get('/patients/${Uri.encodeComponent(widget.patientId)}');
      final vitals = resp['vitals'] as Map<String, dynamic>?;
      if (vitals == null) return;

      if (!mounted) return;
      setState(() {
        final now = DateTime.now();

        _currentVitals = VitalSigns(
          heartRate: (vitals['heartRate'] as num?)?.toDouble() ??
              _currentVitals.heartRate,
          systolicBP: (vitals['systolicBP'] as num?)?.toDouble() ??
              _currentVitals.systolicBP,
          diastolicBP: (vitals['diastolicBP'] as num?)?.toDouble() ??
              _currentVitals.diastolicBP,
          oxygenSaturation: (vitals['oxygenSaturation'] as num?)?.toDouble() ??
              _currentVitals.oxygenSaturation,
          temperature: (vitals['temperature'] as num?)?.toDouble() ??
              _currentVitals.temperature,
          respiratoryRate: (vitals['respiratoryRate'] as num?)?.toDouble() ??
              _currentVitals.respiratoryRate,
        );

        // Append to time series if provided
        final hrSeries = (vitals['heartRateSeries'] as List<dynamic>?)
            ?.map((e) => (e as num).toDouble())
            .toList();
        if (hrSeries != null && hrSeries.isNotEmpty) {
          _heartRateData = hrSeries
              .map((v) => VitalSignData(timestamp: now, value: v))
              .toList();
        } else {
          // If single value present, append it
          final hr = (vitals['heartRate'] as num?)?.toDouble();
          if (hr != null) {
            _heartRateData.add(VitalSignData(timestamp: now, value: hr));
          }
        }

        final bpValue = (vitals['systolicBP'] as num?)?.toDouble();
        if (bpValue != null) {
          _bloodPressureData.add(VitalSignData(timestamp: now, value: bpValue));
        }

        final oxy = (vitals['oxygenSaturation'] as num?)?.toDouble();
        if (oxy != null) {
          _oxygenSatData.add(VitalSignData(timestamp: now, value: oxy));
        }

        final temp = (vitals['temperature'] as num?)?.toDouble();
        if (temp != null) {
          _temperatureData.add(VitalSignData(timestamp: now, value: temp));
        }

        // Keep only last 60 data points
        if (_heartRateData.length > 60) _heartRateData.removeAt(0);
        if (_bloodPressureData.length > 60) _bloodPressureData.removeAt(0);
        if (_oxygenSatData.length > 60) _oxygenSatData.removeAt(0);
        if (_temperatureData.length > 60) _temperatureData.removeAt(0);
      });
    } catch (e) {
      // Surface errors quietly; do not synthesize data
      // ignore: avoid_print
      print('Failed to fetch realtime vitals for ${widget.patientId}: $e');
    }
  }

  void _checkForAlerts() {
    final alerts = <VitalAlert>[];

    if (_currentVitals.heartRate > 100) {
      alerts.add(VitalAlert(
        type: VitalAlertType.tachycardia,
        severity: AlertSeverity.warning,
        message: 'Heart rate elevated: ${_currentVitals.heartRate.toInt()} bpm',
        timestamp: DateTime.now(),
      ));
    }

    if (_currentVitals.oxygenSaturation < 95) {
      alerts.add(VitalAlert(
        type: VitalAlertType.hypoxemia,
        severity: AlertSeverity.critical,
        message:
            'Low oxygen saturation: ${_currentVitals.oxygenSaturation.toStringAsFixed(1)}%',
        timestamp: DateTime.now(),
      ));
    }

    if (_currentVitals.systolicBP > 140) {
      alerts.add(VitalAlert(
        type: VitalAlertType.hypertension,
        severity: AlertSeverity.warning,
        message:
            'Blood pressure elevated: ${_currentVitals.systolicBP.toInt()}/${_currentVitals.diastolicBP.toInt()}',
        timestamp: DateTime.now(),
      ));
    }

    setState(() {
      _activeAlerts = alerts;
    });
  }

  @override
  Widget build(BuildContext context) {
    if (widget.isFullScreen) {
      return _buildFullScreenView();
    } else {
      return _buildCompactView();
    }
  }

  Widget _buildFullScreenView() {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Real-Time Vitals'),
        backgroundColor: AppColors.appPrimary,
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
            if (_activeAlerts.isNotEmpty) _buildAlertsPanel(),
            const SizedBox(height: 16),
            _buildVitalSignsGrid(),
            const SizedBox(height: 24),
            _buildRealTimeCharts(),
          ],
        ),
      ),
    );
  }

  Widget _buildCompactView() {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                const Text(
                  'Real-Time Vitals',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const Spacer(),
                if (_activeAlerts.isNotEmpty)
                  Container(
                    padding:
                        const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                    decoration: BoxDecoration(
                      color: AppColors.appError,
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Text(
                      '${_activeAlerts.length} Alert${_activeAlerts.length > 1 ? 's' : ''}',
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 12,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
              ],
            ),
            const SizedBox(height: 16),
            _buildCompactVitalSigns(),
          ],
        ),
      ),
    );
  }

  Widget _buildAlertsPanel() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.appError.withOpacity(0.1),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppColors.appError.withOpacity(0.3)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Row(
            children: [
              Icon(Icons.warning, color: AppColors.appError),
              SizedBox(width: 8),
              Text(
                'Active Alerts',
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 16,
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          ..._activeAlerts.map((alert) => Padding(
                padding: const EdgeInsets.only(bottom: 8),
                child: Row(
                  children: [
                    Icon(
                      _getAlertIcon(alert.type),
                      color: _getAlertColor(alert.severity),
                      size: 16,
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        alert.message,
                        style: const TextStyle(fontSize: 14),
                      ),
                    ),
                  ],
                ),
              )),
        ],
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
          _currentVitals.heartRate.toInt().toString(),
          'bpm',
          Icons.favorite,
          AppColors.vitalSigns,
          isAnimated: true,
        ),
        _buildVitalSignCard(
          'Blood Pressure',
          '${_currentVitals.systolicBP.toInt()}/${_currentVitals.diastolicBP.toInt()}',
          'mmHg',
          Icons.bloodtype,
          AppColors.vitalSigns,
        ),
        _buildVitalSignCard(
          'Oxygen Sat',
          _currentVitals.oxygenSaturation.toStringAsFixed(1),
          '%',
          Icons.air,
          AppColors.vitalSigns,
        ),
        _buildVitalSignCard(
          'Temperature',
          _currentVitals.temperature.toStringAsFixed(1),
          '°F',
          Icons.thermostat,
          AppColors.vitalSigns,
        ),
      ],
    );
  }

  Widget _buildCompactVitalSigns() {
    return Row(
      children: [
        Expanded(
          child: _buildCompactVitalCard(
            'HR',
            _currentVitals.heartRate.toInt().toString(),
            'bpm',
            AppColors.heartRate,
          ),
        ),
        const SizedBox(width: 8),
        Expanded(
          child: _buildCompactVitalCard(
            'BP',
            '${_currentVitals.systolicBP.toInt()}/${_currentVitals.diastolicBP.toInt()}',
            'mmHg',
            AppColors.bloodPressure,
          ),
        ),
        const SizedBox(width: 8),
        Expanded(
          child: _buildCompactVitalCard(
            'SpO2',
            _currentVitals.oxygenSaturation.toStringAsFixed(1),
            '%',
            AppColors.oxygenSaturation,
          ),
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
              style: const TextStyle(
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

  Widget _buildCompactVitalCard(
      String label, String value, String unit, Color color) {
    return Container(
      padding: const EdgeInsets.all(8),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: color.withOpacity(0.3)),
      ),
      child: Column(
        children: [
          Text(
            label,
            style: TextStyle(
              fontSize: 10,
              color: color,
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(height: 2),
          Text(
            value,
            style: const TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.bold,
            ),
          ),
          Text(
            unit,
            style: const TextStyle(
              fontSize: 8,
              color: AppColors.textSecondary,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildRealTimeCharts() {
    return Column(
      children: [
        _buildChart('Heart Rate', _heartRateData, AppColors.vitalSigns, 'bpm'),
        const SizedBox(height: 16),
        _buildChart(
            'Blood Pressure', _bloodPressureData, AppColors.vitalSigns, 'mmHg'),
        const SizedBox(height: 16),
        _buildChart(
            'Oxygen Saturation', _oxygenSatData, AppColors.vitalSigns, '%'),
      ],
    );
  }

  Widget _buildChart(
      String title, List<VitalSignData> data, Color color, String unit) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              title,
              style: const TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 16),
            SizedBox(
              height: 150,
              child: LineChart(
                LineChartData(
                  gridData: const FlGridData(show: true),
                  titlesData: const FlTitlesData(
                    leftTitles: AxisTitles(
                      sideTitles: SideTitles(
                        showTitles: true,
                        reservedSize: 40,
                      ),
                    ),
                    bottomTitles: AxisTitles(
                      sideTitles: SideTitles(showTitles: false),
                    ),
                    topTitles: AxisTitles(
                      sideTitles: SideTitles(showTitles: false),
                    ),
                    rightTitles: AxisTitles(
                      sideTitles: SideTitles(showTitles: false),
                    ),
                  ),
                  borderData: FlBorderData(show: true),
                  lineBarsData: [
                    LineChartBarData(
                      spots: data.asMap().entries.map((entry) {
                        return FlSpot(entry.key.toDouble(), entry.value.value);
                      }).toList(),
                      isCurved: true,
                      color: color,
                      barWidth: 2,
                      dotData: const FlDotData(show: false),
                      belowBarData: BarAreaData(
                        show: true,
                        color: color.withOpacity(0.1),
                      ),
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

  IconData _getAlertIcon(VitalAlertType type) {
    switch (type) {
      case VitalAlertType.tachycardia:
        return Icons.favorite;
      case VitalAlertType.hypoxemia:
        return Icons.air;
      case VitalAlertType.hypertension:
        return Icons.bloodtype;
      default:
        return Icons.warning;
    }
  }

  Color _getAlertColor(AlertSeverity severity) {
    switch (severity) {
      case AlertSeverity.critical:
        return AppColors.appError;
      case AlertSeverity.warning:
        return AppColors.appWarning;
      case AlertSeverity.info:
        return AppColors.appInfo;
    }
  }

  void _triggerEmergencyAlert() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Emergency Alert'),
        content: const Text('Trigger emergency response for this patient?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.of(context).pop();
              // Trigger emergency protocol
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.appError,
            ),
            child: const Text('Confirm'),
          ),
        ],
      ),
    );
  }
}

// Data classes
class VitalSigns {
  final double heartRate;
  final double systolicBP;
  final double diastolicBP;
  final double oxygenSaturation;
  final double temperature;
  final double respiratoryRate;

  VitalSigns({
    required this.heartRate,
    required this.systolicBP,
    required this.diastolicBP,
    required this.oxygenSaturation,
    required this.temperature,
    required this.respiratoryRate,
  });

  factory VitalSigns.normal() {
    return VitalSigns(
      heartRate: 72,
      systolicBP: 120,
      diastolicBP: 80,
      oxygenSaturation: 98,
      temperature: 98.6,
      respiratoryRate: 16,
    );
  }
}

class VitalSignData {
  final DateTime timestamp;
  final double value;

  VitalSignData({
    required this.timestamp,
    required this.value,
  });
}

class VitalAlert {
  final VitalAlertType type;
  final AlertSeverity severity;
  final String message;
  final DateTime timestamp;

  VitalAlert({
    required this.type,
    required this.severity,
    required this.message,
    required this.timestamp,
  });
}

enum VitalAlertType {
  tachycardia,
  bradycardia,
  hypertension,
  hypotension,
  hypoxemia,
  hyperthermia,
  hypothermia,
}

enum AlertSeverity {
  info,
  warning,
  critical,
}
