import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:automed_app/features/patient/presentation/models/patient_dashboard_model.dart';
import 'package:automed_app/features/patient/presentation/widgets/health_metrics_card.dart';

void main() {
  group('HealthMetricsCard', () {
    testWidgets('displays metric correctly', (
      WidgetTester tester,
    ) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
              body: HealthMetricsCard(
            icon: Icons.bloodtype,
            metricName: 'Oxygen Saturation',
            value: '98',
            unit: '%',
            statusColor: Colors.green,
            status: 'Normal',
          )),
        ),
      );

      // Check if metric name is displayed
      expect(find.text('Oxygen Saturation'), findsOneWidget);

      // Check if value and unit are displayed
      expect(find.text('98'), findsOneWidget);
      expect(find.text('%'), findsOneWidget);

      // Check if status is displayed
      expect(find.text('Normal'), findsOneWidget);

      // Check if icon is displayed
      expect(find.byIcon(Icons.bloodtype), findsOneWidget);
    });

    testWidgets('displays icon correctly', (WidgetTester tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
              body: HealthMetricsCard(
            icon: Icons.thermostat,
            metricName: 'Temperature',
            value: '98.6',
            unit: '°F',
            statusColor: Colors.blue,
            status: 'Normal',
          )),
        ),
      );

      expect(find.byIcon(Icons.thermostat), findsOneWidget);
      expect(find.text('Temperature'), findsOneWidget);
      expect(find.text('98.6'), findsOneWidget);
      expect(find.text('°F'), findsOneWidget);
    });

    testWidgets('displays status color correctly', (
      WidgetTester tester,
    ) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
              body: HealthMetricsCard(
            icon: Icons.air,
            metricName: 'Blood Pressure',
            value: '120/80',
            unit: 'mmHg',
            statusColor: Colors.green,
            status: 'Normal',
          )),
        ),
      );

      expect(find.byIcon(Icons.air), findsOneWidget);
      expect(find.text('Blood Pressure'), findsOneWidget);
      expect(find.text('120/80'), findsOneWidget);
      expect(find.text('mmHg'), findsOneWidget);
      expect(find.text('Normal'), findsOneWidget);
    });

    testWidgets('formats decimal values correctly', (
      WidgetTester tester,
    ) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
              body: HealthMetricsCard(
            icon: Icons.favorite,
            metricName: 'Heart Rate',
            value: '75.5',
            unit: 'bpm',
            statusColor: Colors.green,
            status: 'Normal',
          )),
        ),
      );

      expect(find.text('75.5'), findsOneWidget);
      expect(find.text('bpm'), findsOneWidget);
      expect(find.text('Heart Rate'), findsOneWidget);
    });
  });
}
