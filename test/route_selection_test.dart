import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_application_1/screens/map/models/map_models.dart';
import 'package:flutter_application_1/screens/map/services/pathfinder_service.dart';
import 'package:flutter_application_1/screens/route_selection/models/route_selection_models.dart';
import 'package:flutter_application_1/screens/route_selection/services/route_recommendation_engine.dart';

void main() {
  group('RouteRecommendationEngine Mood & Adventure Tests', () {
    late PathfinderService pathfinder;
    late RouteRecommendationEngine engine;
    late LocationNode startNode;
    late LocationNode goalNode;

    setUpAll(() async {
      TestWidgetsFlutterBinding.ensureInitialized();
      pathfinder = PathfinderService();
      await pathfinder.loadMapData();
      engine = RouteRecommendationEngine(pathfinder);
      startNode = pathfinder.startNode!;
      goalNode = pathfinder.selectableDestinations.first;
    });

    test('Worried mood always recommends Swiper-Safe Route', () {
      final routes = engine.generateOptions(
        start: startNode,
        destination: goalNode,
        mood: DoraMood.worried,
        adventureLevel: AdventureLevel.extreme,
      );

      final recommended = routes.firstWhere((r) => r.isRecommended);
      expect(recommended.type, equals(RouteOptionType.swiperSafe));
      expect(routes.first.type, equals(RouteOptionType.swiperSafe));
    });

    test('Brave mood recommends Most Adventurous Route', () {
      final routes = engine.generateOptions(
        start: startNode,
        destination: goalNode,
        mood: DoraMood.brave,
        adventureLevel: AdventureLevel.calm,
      );

      final recommended = routes.firstWhere((r) => r.isRecommended);
      expect(recommended.type, equals(RouteOptionType.mostAdventurous));
    });

    test('Tired mood recommends Normal Route for easy walking', () {
      final routes = engine.generateOptions(
        start: startNode,
        destination: goalNode,
        mood: DoraMood.tired,
        adventureLevel: AdventureLevel.extreme,
      );

      final recommended = routes.firstWhere((r) => r.isRecommended);
      expect(recommended.type, equals(RouteOptionType.normal));
    });

    test('Curious mood recommends Boots Route', () {
      final routes = engine.generateOptions(
        start: startNode,
        destination: goalNode,
        mood: DoraMood.curious,
        adventureLevel: AdventureLevel.normal,
      );

      final recommended = routes.firstWhere((r) => r.isRecommended);
      expect(recommended.type, equals(RouteOptionType.bootsRoute));
    });

    test('Happy mood scales with adventure level', () {
      final calmRoutes = engine.generateOptions(
        start: startNode,
        destination: goalNode,
        mood: DoraMood.happy,
        adventureLevel: AdventureLevel.calm,
      );
      expect(calmRoutes.first.type, equals(RouteOptionType.normal));

      final adventurousRoutes = engine.generateOptions(
        start: startNode,
        destination: goalNode,
        mood: DoraMood.happy,
        adventureLevel: AdventureLevel.adventurous,
      );
      expect(adventurousRoutes.first.type, equals(RouteOptionType.mostAdventurous));
    });
  });
}
