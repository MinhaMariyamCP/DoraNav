import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_application_1/screens/backpack/backpack_screen.dart';
import 'package:flutter_application_1/screens/backpack/models/backpack_context.dart';
import 'package:flutter_application_1/screens/backpack/services/mock_recommendation_service.dart';

void main() {
  group('MockRecommendationService Unit Tests', () {
    final service = MockRecommendationService();

    test('Always includes essential Map and Boots', () async {
      const context = BackpackContext(destination: "Dora's House");
      final response = await service.getRecommendations(context);

      final hasMap = response.suggestions.any((i) => i.id == 'map_01' && i.essential);
      final hasBoots = response.suggestions.any((i) => i.id == 'boots_01' && i.essential);

      expect(hasMap, isTrue);
      expect(hasBoots, isTrue);
      expect(response.alwaysAvailable, containsAll(['map_01', 'boots_01']));
    });

    test('Suggests raft, life jacket, and rope for River Crossing', () async {
      final context = MockRecommendationService.getScenarioContext(BackpackScenario.riverCrossing);
      final response = await service.getRecommendations(context);

      final itemIds = response.suggestions.map((i) => i.id).toList();
      expect(itemIds, contains('raft_01'));
      expect(itemIds, contains('life_jacket_01'));
      expect(itemIds, contains('rope_01'));
      expect(itemIds, contains('water_01'));
      expect(response.situationTitle, contains('river'));
    });

    test('Suggests flashlight, lantern, and glow stick for Cave/Night', () async {
      final context = MockRecommendationService.getScenarioContext(BackpackScenario.nightCave);
      final response = await service.getRecommendations(context);

      final itemIds = response.suggestions.map((i) => i.id).toList();
      expect(itemIds, contains('flashlight_01'));
      expect(itemIds, contains('lantern_01'));
      expect(itemIds, contains('glow_01'));
    });

    test('Suggests warm clothes, gloves, and blanket for Snowy Mountain', () async {
      final context = MockRecommendationService.getScenarioContext(BackpackScenario.snowyMountain);
      final response = await service.getRecommendations(context);

      final itemIds = response.suggestions.map((i) => i.id).toList();
      expect(itemIds, contains('clothes_01'));
      expect(itemIds, contains('gloves_01'));
      expect(itemIds, contains('blanket_01'));
    });

    test('Suggests Swiper Bell when Swiper is detected', () async {
      final context = MockRecommendationService.getScenarioContext(BackpackScenario.swiperSpotted);
      final response = await service.getRecommendations(context);

      final itemIds = response.suggestions.map((i) => i.id).toList();
      expect(itemIds, contains('swiper_01'));
    });

    test('Search filters catalog correctly', () async {
      const context = BackpackContext(destination: 'Jungle Trail');
      final searchResponse = await service.searchItems('raft', context);

      expect(searchResponse.suggestions.any((i) => i.name.contains('Raft')), isTrue);
    });
  });

  group('BackpackScreen Widget Tests', () {
    testWidgets('Renders BackpackScreen and switches between states', (WidgetTester tester) async {
      tester.view.physicalSize = const Size(800, 1200);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(tester.view.resetPhysicalSize);

      await tester.pumpWidget(
        const MaterialApp(
          home: BackpackScreen(
            initialScenario: BackpackScenario.riverCrossing,
          ),
        ),
      );

      // Verify thinking / loading state completes
      await tester.pump(const Duration(milliseconds: 500));
      await tester.pumpAndSettle();

      // Top bar title exists
      expect(find.text('Backpack'), findsOneWidget);

      // Search prompt exists
      expect(find.text('What do we need?'), findsOneWidget);

      // Category chips exist
      expect(find.text('All'), findsOneWidget);
      expect(find.text('Tools'), findsOneWidget);
      expect(find.text('Safety'), findsOneWidget);

      // Inflatable Raft card is shown in River Crossing
      expect(find.text('Inflatable Raft'), findsOneWidget);

      // Test adding an item
      final addButtons = find.text('Add');
      expect(addButtons, findsWidgets);

      await tester.tap(addButtons.first);
      await tester.pumpAndSettle();

      // Item should show "Added" and counter badge updates
      expect(find.text('Added'), findsOneWidget);
      expect(find.text('Selected Items (1)'), findsOneWidget);
    });

    testWidgets('Renders Empty State correctly when toggled', (WidgetTester tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: BackpackScreen(
            startInEmptyState: true,
          ),
        ),
      );

      await tester.pumpAndSettle();

      expect(find.text('Your backpack is empty!'), findsOneWidget);
      expect(find.text('Ask Dora what we need\nand I\'ll find the right things!'), findsOneWidget);
    });
  });
}
