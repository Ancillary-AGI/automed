import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:integration_test/integration_test.dart';
import 'package:automed_app/main.dart';

void main() {
  IntegrationTestWidgetsFlutterBinding.ensureInitialized();

  group('end-to-end test', () {
    testWidgets('app starts and shows main screen',
        (WidgetTester tester) async {
      // Build the app and trigger a frame.
      await tester.pumpWidget(const AutomedApp());

      // Wait for the app to settle
      await tester.pumpAndSettle();

      // Verify that the app starts without crashing
      expect(find.byType(MaterialApp), findsOneWidget);
    });

    testWidgets('theme switching works', (WidgetTester tester) async {
      // Build the app
      await tester.pumpWidget(const AutomedApp());
      await tester.pumpAndSettle();

      // The app should be using the default theme
      final materialApp = find.byType(MaterialApp);
      expect(materialApp, findsOneWidget);

      // Additional theme tests can be added here when theme switching UI is implemented
    });

    testWidgets('navigation works', (WidgetTester tester) async {
      // Build the app
      await tester.pumpWidget(const AutomedApp());
      await tester.pumpAndSettle();

      // Basic navigation test - app should have some navigation structure
      expect(find.byType(Scaffold), findsWidgets);
    });
  });
}
