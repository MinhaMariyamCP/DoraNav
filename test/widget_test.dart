import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_application_1/screens/map/widgets/map_top_bar.dart';
import 'package:flutter_application_1/screens/map/widgets/quick_actions_bar.dart';
import 'package:flutter_application_1/screens/splash/splash_screen.dart';
import 'package:flutter_application_1/screens/splash/widgets/dora_nav_logo.dart';
import 'package:flutter_application_1/screens/splash/widgets/splash_loading_progress.dart';
import 'package:flutter_application_1/widgets/shared/adventure_button.dart';

void main() {
  group('DoraNav Splash Screen Tests', () {
    testWidgets('DoraNavLogo renders title and subtitle correctly', (WidgetTester tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(
            body: DoraNavLogo(
              titleDora: 'Dora',
              titleNav: 'Nav',
              subtitle: "Navigation for Dora's World",
              tagline: 'Explore. Navigate. Adventure!',
            ),
          ),
        ),
      );

      // Verify the 3D title words and subtitle texts appear
      expect(find.text("Navigation for Dora's World"), findsOneWidget);
      expect(find.text('Explore. Navigate. Adventure!'), findsOneWidget);
      expect(find.text('Dora'), findsWidgets);
      expect(find.text('Nav'), findsWidgets);
    });

    testWidgets('SplashLoadingProgress renders status and progress correctly', (WidgetTester tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(
            body: SplashLoadingProgress(
              progress: 0.75,
              statusMessage: 'Packing the purple backpack...',
            ),
          ),
        ),
      );

      expect(find.text('Packing the purple backpack...'), findsOneWidget);
      expect(find.text('75%'), findsOneWidget);
      expect(find.byIcon(Icons.explore_rounded), findsOneWidget);
    });

    testWidgets('AdventureButton triggers callback when pressed', (WidgetTester tester) async {
      bool pressed = false;

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: AdventureButton(
              label: "¡Vámonos! Let's Go!",
              onPressed: () => pressed = true,
            ),
          ),
        ),
      );

      expect(find.text("¡Vámonos! Let's Go!"), findsOneWidget);
      await tester.tap(find.text("¡Vámonos! Let's Go!"));
      await tester.pumpAndSettle();

      expect(pressed, isTrue);
    });

    testWidgets('SplashScreen mounts and unmounts cleanly', (WidgetTester tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: SplashScreen(),
        ),
      );

      // Pump 1 frame to mount
      await tester.pump(const Duration(milliseconds: 100));

      expect(find.byType(SplashScreen), findsOneWidget);

      // Unmount cleanly to prevent pending timers from lingering
      await tester.pumpWidget(const SizedBox());
    });
  });

  group('DoraNav World Map Screen Tests', () {
    testWidgets('MapTopBar renders bilingual title and search', (WidgetTester tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(
            body: MapTopBar(
              swiperRiskLevel: 'Low Risk',
            ),
          ),
        ),
      );

      expect(find.text('DORA NAV'), findsOneWidget);
      expect(find.text('Where do you want to go?'), findsOneWidget);
      expect(find.text('Swiper Alert'), findsOneWidget);
      expect(find.text('Low Risk'), findsOneWidget);
    });

    testWidgets('MapQuickActionsBar renders all buttons', (WidgetTester tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(
            body: MapQuickActionsBar(),
          ),
        ),
      );

      expect(find.text('Backpack'), findsOneWidget);
      expect(find.text('Lost Mode'), findsOneWidget);
      expect(find.text('Achievements'), findsOneWidget);
      expect(find.text('Voice Guide'), findsOneWidget);
      expect(find.text('End Trip'), findsOneWidget);
    });
  });
}
