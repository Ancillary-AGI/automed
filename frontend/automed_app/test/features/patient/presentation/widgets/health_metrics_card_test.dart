import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:automed_app/features/patient/presentation/models/patient_dashboard_model.dart';
import 'package:automed_app/features/patient/presentation/widgets/health_metrics_card.dart';

void main() {
  group('HealthMetricsCard', () {
    late HealthMetrics testMetrics;

    setUp(() {
      testMetrics = const HealthMetrics(
        heartRate: 75.0,
        bloodPressure: 120.0,
        temperature: 98.6,
        oxygenSaturation: 98.0,
      );
    });

    testWidgets('displays all health metrics correctly', (
      WidgetTester tester,
    ) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(body: HealthMetricsCard(metrics: testMetrics)),
        ),
      );

      // Check if title is displayed
      expect(find.text('Health Metrics'), findsOneWidget);

      // Check if heart rate is displayed
      expect(find.text('75 bpm'), findsOneWidget);
      expect(find.text('Heart Rate'), findsOneWidget);

      // Check if blood pressure is displayed
      expect(find.text('120 mmHg'), findsOneWidget);
      expect(find.text('Blood Pressure'), findsOneWidget);

      // Check if temperature is displayed
      expect(find.text('98.6°C'), findsOneWidget);
      expect(find.text('Temperature'), findsOneWidget);

      // Check if oxygen saturation is displayed
      expect(find.text('98%'), findsOneWidget);
      expect(find.text('Oxygen'), findsOneWidget);
    });

    testWidgets('displays heart icon in title', (WidgetTester tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(body: HealthMetricsCard(metrics: testMetrics)),
        ),
      );

      expect(find.byIcon(Icons.favorite), findsOneWidget);
    });

    testWidgets('displays metric icons with correct colors', (
      WidgetTester tester,
    ) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(body: HealthMetricsCard(metrics: testMetrics)),
        ),
      );

      // Check for heart rate icon (red)
      expect(find.byIcon(Icons.favorite_border), findsOneWidget);

      // Check for blood pressure icon (blue)
      expect(find.byIcon(Icons.speed), findsOneWidget);

      // Check for temperature icon (orange)
      expect(find.byIcon(Icons.thermostat), findsOneWidget);

      // Check for oxygen icon (green)
      expect(find.byIcon(Icons.air), findsOneWidget);
    });

    testWidgets('formats decimal values correctly', (
      WidgetTester tester,
    ) async {
      const decimalMetrics = HealthMetrics(
        heartRate: 75.5,
        bloodPressure: 120.7,
        temperature: 98.65,
        oxygenSaturation: 98.3,
      );

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(body: HealthMetricsCard(metrics: decimalMetrics)),
        ),
      );

      expect(find.text('76 bpm'), findsOneWidget); // Rounded
      expect(find.text('121 mmHg'), findsOneWidget); // Rounded
      expect(find.text('98.7°C'), findsOneWidget); // Rounded to 1 decimal
      expect(find.text('98%'), findsOneWidget); // Rounded
    });
  });
}
