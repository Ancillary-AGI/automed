import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

/// Test utilities for Flutter widget testing
class TestUtils {
  /// Creates a testable MaterialApp with proper theme setup
  static Widget createTestableWidget({
    required Widget child,
    ThemeData? theme,
    Locale? locale,
    bool useMaterial3 = true,
  }) {
    return MaterialApp(
      theme: theme ??
          ThemeData(
            useMaterial3: useMaterial3,
            colorScheme: const ColorScheme.light(),
          ),
      locale: locale ?? const Locale('en'),
      home: Scaffold(body: child),
      localizationsDelegates: const [
        // Add localization delegates if needed
      ],
      supportedLocales: const [
        Locale('en'),
        Locale('es'),
        Locale('fr'),
      ],
    );
  }

  /// Creates a testable MaterialApp with dark theme
  static Widget createTestableWidgetDark({
    required Widget child,
    ThemeData? theme,
    Locale? locale,
  }) {
    return MaterialApp(
      theme: theme ??
          ThemeData(
            useMaterial3: true,
            colorScheme: const ColorScheme.dark(),
          ),
      locale: locale ?? const Locale('en'),
      home: Scaffold(body: child),
    );
  }

  /// Pumps a widget and waits for it to settle
  static Future<void> pumpAndSettleWidget(
    WidgetTester tester,
    Widget widget, {
    Duration? duration,
  }) async {
    await tester.pumpWidget(widget);
    await tester.pumpAndSettle(duration ?? const Duration(milliseconds: 100));
  }

  /// Finds a widget by text content
  static Finder findText(String text) {
    return find.text(text);
  }

  /// Finds a widget by key
  static Finder findKey(Key key) {
    return find.byKey(key);
  }

  /// Finds a widget by type
  static Finder findType(Type type) {
    return find.byType(type);
  }

  /// Finds a widget by icon
  static Finder findIcon(IconData icon) {
    return find.byIcon(icon);
  }

  /// Taps on a widget and pumps
  static Future<void> tapAndPump(
    WidgetTester tester,
    Finder finder, {
    Duration? pumpDuration,
  }) async {
    await tester.tap(finder);
    await tester.pump(pumpDuration ?? const Duration(milliseconds: 100));
  }

  /// Enters text into a TextField and pumps
  static Future<void> enterTextAndPump(
    WidgetTester tester,
    Finder finder,
    String text, {
    Duration? pumpDuration,
  }) async {
    await tester.enterText(finder, text);
    await tester.pump(pumpDuration ?? const Duration(milliseconds: 100));
  }

  /// Drags a widget and pumps
  static Future<void> dragAndPump(
    WidgetTester tester,
    Finder finder,
    Offset offset, {
    Duration? pumpDuration,
  }) async {
    await tester.drag(finder, offset);
    await tester.pump(pumpDuration ?? const Duration(milliseconds: 100));
  }

  /// Scrolls and pumps
  static Future<void> scrollAndPump(
    WidgetTester tester,
    Finder finder,
    Offset offset, {
    Duration? pumpDuration,
  }) async {
    await tester.drag(finder, offset);
    await tester.pump(pumpDuration ?? const Duration(milliseconds: 100));
  }
}

/// Extension methods for WidgetTester
extension WidgetTesterExtensions on WidgetTester {
  /// Pumps a widget and waits for it to settle with default settings
  Future<void> pumpAndSettleDefault(Widget widget) async {
    await pumpWidget(widget);
    await pumpAndSettle();
  }

  /// Pumps a widget with a specific duration
  Future<void> pumpWidgetWithDuration(Widget widget, Duration duration) async {
    await pumpWidget(widget);
    await pump(duration);
  }

  /// Ensures a widget is visible by scrolling if necessary
  Future<void> ensureVisibleAndPump(Finder finder) async {
    await ensureVisible(finder);
    await pump();
  }
}

/// Test data builders for common objects
class TestData {
  /// Creates a mock consultation object
  static Map<String, dynamic> createMockConsultation({
    String? type,
    String? doctorName,
    String? status,
    String? startTime,
    String? notes,
  }) {
    return {
      'type': type ?? 'Video Consultation',
      'doctorName': doctorName ?? 'Dr. Smith',
      'status': status ?? 'Active',
      'startTime': startTime ?? '2024-01-15 10:00 AM',
      'notes': notes ?? 'Patient has mild symptoms',
    };
  }

  /// Creates a mock patient object
  static Map<String, dynamic> createMockPatient({
    String? id,
    String? name,
    String? email,
    int? age,
    String? condition,
  }) {
    return {
      'id': id ?? '123',
      'name': name ?? 'John Doe',
      'email': email ?? 'john.doe@example.com',
      'age': age ?? 30,
      'condition': condition ?? 'Healthy',
    };
  }

  /// Creates mock vital signs data
  static Map<String, dynamic> createMockVitals({
    double? heartRate,
    double? bloodPressureSystolic,
    double? bloodPressureDiastolic,
    double? temperature,
    double? oxygenSaturation,
  }) {
    return {
      'heartRate': heartRate ?? 72.0,
      'bloodPressureSystolic': bloodPressureSystolic ?? 120.0,
      'bloodPressureDiastolic': bloodPressureDiastolic ?? 80.0,
      'temperature': temperature ?? 98.6,
      'oxygenSaturation': oxygenSaturation ?? 98.0,
    };
  }
}

/// Custom matchers for common assertions
class CustomMatchers {
  /// Finds a widget that contains specific text
  static Finder containsText(String text) {
    return find.text(text);
  }

  /// Matches a widget that has a specific color
  static Matcher hasColor(Color color) {
    return matchesGoldenFile('color_${color.value}.png');
  }

  /// Matches a widget that is visible
  static Matcher isVisible() {
    return findsOneWidget;
  }

  /// Matches widgets that are not visible
  static Matcher isNotVisible() {
    return findsNothing;
  }
}

/// Test configuration
class TestConfig {
  static const Duration defaultPumpDuration = Duration(milliseconds: 100);
  static const Duration animationDuration = Duration(milliseconds: 300);
  static const int maxPumpIterations = 100;

  /// Default test timeout
  static const Duration testTimeout = Duration(seconds: 30);
}

/// Accessibility test helpers
class AccessibilityTestUtils {
  /// Checks if text has sufficient contrast
  static bool hasGoodContrast(Color foreground, Color background) {
    // Simple contrast calculation (in real app, use a proper library)
    final double contrast = _calculateContrast(foreground, background);
    return contrast >= 4.5; // WCAG AA standard
  }

  static double _calculateContrast(Color fg, Color bg) {
    final double fgLuminance = _calculateLuminance(fg);
    final double bgLuminance = _calculateLuminance(bg);

    final double lighter =
        fgLuminance > bgLuminance ? fgLuminance : bgLuminance;
    final double darker = fgLuminance > bgLuminance ? bgLuminance : fgLuminance;

    return (lighter + 0.05) / (darker + 0.05);
  }

  static double _calculateLuminance(Color color) {
    final double r = color.r / 255.0;
    final double g = color.g / 255.0;
    final double b = color.b / 255.0;

    return 0.2126 * r + 0.7152 * g + 0.0722 * b;
  }

  /// Checks if widget has minimum touch target size
  static bool hasMinimumTouchTarget(Size size) {
    const double minSize = 44.0; // iOS Human Interface Guidelines
    return size.width >= minSize && size.height >= minSize;
  }
}
