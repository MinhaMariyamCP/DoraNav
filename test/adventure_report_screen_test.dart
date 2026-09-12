import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_application_1/screens/adventure_report/models/trip_data.dart';
import 'package:flutter_application_1/screens/adventure_report/widgets/adventure_report_screen.dart';

void main() {
  group('AdventureReportScreen Widget Tests', () {
    testWidgets('Renders destination name, score badge, and triggers buttons',
        (WidgetTester tester) async {
      bool viewRouteTapped = false;
      bool backToMapTapped = false;
      bool newAdventureTapped = false;

      final trip = TripData.witchsCastleMock;

      await tester.pumpWidget(
        MaterialApp(
          home: AdventureReportScreen(
            tripData: trip,
            onViewRoute: () => viewRouteTapped = true,
            onBackToMap: () => backToMapTapped = true,
            onStartNewAdventure: () => newAdventureTapped = true,
          ),
        ),
      );

      // Verify header & destination title
      expect(find.text('Adventure Complete!'), findsOneWidget);
      expect(find.text("Witch's Castle!"), findsOneWidget);

      // Verify statistics values
      expect(find.text('2.4 km'), findsOneWidget);
      expect(find.text('7'), findsOneWidget);
      expect(find.text('2'), findsOneWidget);
      expect(find.text('3'), findsOneWidget);
      expect(find.text('1'), findsOneWidget); // Swiper encounters
      expect(find.text('5 times'), findsOneWidget); // Backpack items

      // Verify action buttons exist
      final viewRouteBtn = find.text('View Route');
      final backToMapBtn = find.text('Back to Map');
      final newAdvBtn = find.text('Start New Adventure');

      expect(viewRouteBtn, findsOneWidget);
      expect(backToMapBtn, findsOneWidget);
      expect(newAdvBtn, findsOneWidget);

      // Tap buttons and assert callbacks
      await tester.tap(viewRouteBtn);
      expect(viewRouteTapped, isTrue);

      await tester.tap(backToMapBtn);
      expect(backToMapTapped, isTrue);

      await tester.tap(newAdvBtn);
      expect(newAdventureTapped, isTrue);
    });

    testWidgets('Tapping point breakdown expands score details',
        (WidgetTester tester) async {
      final trip = TripData.sunnyBeachMock;

      // Set surface size large enough to view full report
      tester.view.physicalSize = const Size(1080, 1920);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(tester.view.resetPhysicalSize);

      await tester.pumpWidget(
        MaterialApp(
          home: AdventureReportScreen(tripData: trip),
        ),
      );

      final breakdownTrigger = find.text('View Point Breakdown');
      expect(breakdownTrigger, findsOneWidget);

      // Initially details are collapsed
      expect(find.text('Base Completion'), findsNothing);

      // Scroll into view if needed and tap
      await tester.ensureVisible(breakdownTrigger);
      await tester.tap(breakdownTrigger);
      await tester.pump(const Duration(milliseconds: 300));

      // Now breakdown rows should be visible
      expect(find.text('Base Completion'), findsOneWidget);
      expect(find.text('Hide Details'), findsOneWidget);
    });
  });
}
