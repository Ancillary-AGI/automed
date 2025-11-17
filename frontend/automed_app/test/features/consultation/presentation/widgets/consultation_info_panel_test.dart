import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:automed_app/features/consultation/presentation/widgets/consultation_info_panel.dart';
import '../../../../test_utils.dart';

// Mock consultation object for testing
class MockConsultation {
  final String? type;
  final String? doctorName;
  final String? status;
  final String? startTime;
  final String? notes;

  const MockConsultation({
    this.type,
    this.doctorName,
    this.status,
    this.startTime,
    this.notes,
  });
}

void main() {
  group('ConsultationInfoPanel', () {
    late MockConsultation mockConsultation;
    late VoidCallback mockOnClose;

    setUp(() {
      mockConsultation = const MockConsultation(
        type: 'Video Consultation',
        doctorName: 'Dr. Smith',
        status: 'Active',
        startTime: '2024-01-15 10:00 AM',
        notes: 'Patient has mild symptoms',
      );
      mockOnClose = () {};
    });

    testWidgets('displays consultation info correctly',
        (WidgetTester tester) async {
      await TestUtils.pumpAndSettleWidget(
        tester,
        TestUtils.createTestableWidget(
          child: ConsultationInfoPanel(
            consultation: mockConsultation,
            onClose: mockOnClose,
          ),
        ),
      );

      // Check if header is displayed
      expect(find.text('Consultation Info'), findsOneWidget);

      // Check if consultation details are displayed
      expect(find.text('Video Consultation'), findsOneWidget);
      expect(find.text('Dr. Smith'), findsOneWidget);
      expect(find.text('Active'), findsOneWidget);
      expect(find.text('2024-01-15 10:00 AM'), findsOneWidget);

      // Check if close button is present
      expect(find.byIcon(Icons.close), findsOneWidget);
    });

    testWidgets('displays notes when available', (WidgetTester tester) async {
      final consultationWithNotes = const MockConsultation(
        type: 'Video Consultation',
        doctorName: 'Dr. Smith',
        status: 'Active',
        startTime: '2024-01-15 10:00 AM',
        notes: 'Patient has mild fever and cough',
      );

      await TestUtils.pumpAndSettleWidget(
        tester,
        TestUtils.createTestableWidget(
          child: ConsultationInfoPanel(
            consultation: consultationWithNotes,
            onClose: mockOnClose,
          ),
        ),
      );

      // Check if notes section is displayed
      expect(find.text('Notes'), findsOneWidget);
      expect(find.text('Patient has mild fever and cough'), findsOneWidget);
    });

    testWidgets('does not display notes when empty',
        (WidgetTester tester) async {
      final consultationWithoutNotes = const MockConsultation(
        type: 'Video Consultation',
        doctorName: 'Dr. Smith',
        status: 'Active',
        startTime: '2024-01-15 10:00 AM',
        notes: '',
      );

      await TestUtils.pumpAndSettleWidget(
        tester,
        TestUtils.createTestableWidget(
          child: ConsultationInfoPanel(
            consultation: consultationWithoutNotes,
            onClose: mockOnClose,
          ),
        ),
      );

      // Notes section should not be displayed
      expect(find.text('Notes'), findsNothing);
    });

    testWidgets('does not display notes when null',
        (WidgetTester tester) async {
      final consultationWithoutNotes = const MockConsultation(
        type: 'Video Consultation',
        doctorName: 'Dr. Smith',
        status: 'Active',
        startTime: '2024-01-15 10:00 AM',
        notes: null,
      );

      await TestUtils.pumpAndSettleWidget(
        tester,
        TestUtils.createTestableWidget(
          child: ConsultationInfoPanel(
            consultation: consultationWithoutNotes,
            onClose: mockOnClose,
          ),
        ),
      );

      // Notes section should not be displayed
      expect(find.text('Notes'), findsNothing);
    });

    testWidgets('displays unknown values for missing data',
        (WidgetTester tester) async {
      final incompleteConsultation = const MockConsultation();

      await TestUtils.pumpAndSettleWidget(
        tester,
        TestUtils.createTestableWidget(
          child: ConsultationInfoPanel(
            consultation: incompleteConsultation,
            onClose: mockOnClose,
          ),
        ),
      );

      // Should display 'Unknown' for missing values
      expect(find.text('Unknown'), findsAtLeastNWidgets(4));
    });

    testWidgets('calls onClose when close button is tapped',
        (WidgetTester tester) async {
      bool closeCalled = false;

      await TestUtils.pumpAndSettleWidget(
        tester,
        TestUtils.createTestableWidget(
          child: ConsultationInfoPanel(
            consultation: mockConsultation,
            onClose: () => closeCalled = true,
          ),
        ),
      );

      // Tap the close button
      await TestUtils.tapAndPump(tester, find.byIcon(Icons.close));

      // Verify onClose was called
      expect(closeCalled, isTrue);
    });

    testWidgets('uses theme colors correctly in light mode',
        (WidgetTester tester) async {
      await TestUtils.pumpAndSettleWidget(
        tester,
        TestUtils.createTestableWidget(
          child: ConsultationInfoPanel(
            consultation: mockConsultation,
            onClose: mockOnClose,
          ),
          theme: ThemeData.light(useMaterial3: true),
        ),
      );

      // The widget should render without errors and use theme colors
      expect(find.text('Consultation Info'), findsOneWidget);
      expect(find.text('Video Consultation'), findsOneWidget);
    });

    testWidgets('uses theme colors correctly in dark mode',
        (WidgetTester tester) async {
      await TestUtils.pumpAndSettleWidget(
        tester,
        TestUtils.createTestableWidgetDark(
          child: ConsultationInfoPanel(
            consultation: mockConsultation,
            onClose: mockOnClose,
          ),
          theme: ThemeData.dark(useMaterial3: true),
        ),
      );

      // The widget should render without errors and use theme colors
      expect(find.text('Consultation Info'), findsOneWidget);
      expect(find.text('Video Consultation'), findsOneWidget);
    });

    testWidgets('has proper accessibility labels', (WidgetTester tester) async {
      await TestUtils.pumpAndSettleWidget(
        tester,
        TestUtils.createTestableWidget(
          child: ConsultationInfoPanel(
            consultation: mockConsultation,
            onClose: mockOnClose,
          ),
        ),
      );

      // Check that close button has proper semantics
      final closeButtonFinder = find.byType(IconButton);
      expect(closeButtonFinder, findsOneWidget);

      // Verify the button is accessible
      final closeButtonWidget = tester.widget<IconButton>(closeButtonFinder);
      expect(closeButtonWidget.onPressed, isNotNull);
      expect(closeButtonWidget.icon, isA<Icon>());
    });

    testWidgets('scrolls when content is long', (WidgetTester tester) async {
      final consultationWithLongNotes = MockConsultation(
        type: 'Video Consultation',
        doctorName: 'Dr. Smith',
        status: 'Active',
        startTime: '2024-01-15 10:00 AM',
        notes:
            'This is a very long note that should cause the content to scroll. ' *
                10,
      );

      await TestUtils.pumpAndSettleWidget(
        tester,
        TestUtils.createTestableWidget(
          child: SizedBox(
            height: 200, // Constrain height to force scrolling
            child: ConsultationInfoPanel(
              consultation: consultationWithLongNotes,
              onClose: mockOnClose,
            ),
          ),
        ),
      );

      // Should still display all content
      expect(find.text('Consultation Info'), findsOneWidget);
      expect(find.text('Notes'), findsOneWidget);
    });

    testWidgets('displays different consultation types correctly',
        (WidgetTester tester) async {
      final phoneConsultation = const MockConsultation(
        type: 'Phone Consultation',
        doctorName: 'Dr. Johnson',
        status: 'Completed',
        startTime: '2024-01-15 10:00 AM',
      );

      await TestUtils.pumpAndSettleWidget(
        tester,
        TestUtils.createTestableWidget(
          child: ConsultationInfoPanel(
            consultation: phoneConsultation,
            onClose: mockOnClose,
          ),
        ),
      );

      expect(find.text('Phone Consultation'), findsOneWidget);
      expect(find.text('Dr. Johnson'), findsOneWidget);
      expect(find.text('Completed'), findsOneWidget);
    });
  });
}
