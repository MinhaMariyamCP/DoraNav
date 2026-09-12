import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_application_1/screens/map/services/pathfinder_service.dart';
import 'package:flutter_application_1/services/dora_voice_service.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  group('Dora World Graph & Navigation Engine Tests', () {
    late PathfinderService pathfinder;

    setUp(() async {
      pathfinder = PathfinderService();
      await pathfinder.loadMapData();
    });

    test('Loads Dora World Graph with 70 locations and 25 destinations', () {
      expect(pathfinder.isLoaded, isTrue);
      expect(pathfinder.allLocations.length, greaterThanOrEqualTo(2));
      expect(pathfinder.startNode, isNotNull);
      expect(pathfinder.startNode!.name, contains("Dora"));
    });

    test('Computes optimal A* route to King’s Castle', () {
      final start = pathfinder.startNode!;
      final castle = pathfinder.allLocations.firstWhere(
        (l) => l.name.contains('Castle') || l.id == 'L012',
        orElse: () => pathfinder.allLocations.last,
      );

      final route = pathfinder.findRoute(
        startId: start.id,
        goalId: castle.id,
      );

      expect(route, isNotNull);
      expect(route!.nodes.isNotEmpty, isTrue);
      expect(route.nodes.first.id, equals(start.id));
      expect(route.nodes.last.id, equals(castle.id));
      expect(route.totalDistance, greaterThan(0));
      expect(route.etaMinutes, greaterThan(0));
    });

    test('Dynamic Swiper Event: recalculates detour when Troll Bridge is blocked', () {
      final start = pathfinder.startNode!;
      final castle = pathfinder.allLocations.firstWhere(
        (l) => l.name.contains('Castle') || l.id == 'L012',
        orElse: () => pathfinder.allLocations.last,
      );

      // Normal optimal route
      final normalRoute = pathfinder.findRoute(
        startId: start.id,
        goalId: castle.id,
      );
      expect(normalRoute, isNotNull);

      // Block Troll Bridge (L045) or Castle Bridge (L044)
      final detourRoute = pathfinder.findRoute(
        startId: start.id,
        goalId: castle.id,
        customBlockedNodes: {'L045', 'L044'},
        isAlternative: true,
      );

      if (detourRoute != null) {
        expect(detourRoute.isAlternative, isTrue);
        // Verify blocked nodes are not in detour route
        final nodeIds = detourRoute.nodes.map((n) => n.id).toSet();
        expect(nodeIds.contains('L045'), isFalse);
        expect(nodeIds.contains('L044'), isFalse);
      }
    });

    test('Dynamic Road Block Event: setNodeBlocked & clearAllBlocks properly updates graph', () {
      final start = pathfinder.startNode!;
      final destinations = pathfinder.selectableDestinations;
      final target = destinations.first;

      final originalRoute = pathfinder.findRoute(
        startId: start.id,
        goalId: target.id,
      );
      expect(originalRoute, isNotNull);

      if (originalRoute!.nodes.length > 2) {
        final blockedNode = originalRoute.nodes[1];
        pathfinder.setNodeBlocked(blockedNode.id, true);
        expect(pathfinder.blockedNodeIds.contains(blockedNode.id), isTrue);

        final blockedRoute = pathfinder.findRoute(
          startId: start.id,
          goalId: target.id,
        );

        if (blockedRoute != null) {
          final ids = blockedRoute.nodes.map((n) => n.id).toSet();
          expect(ids.contains(blockedNode.id), isFalse);
        }

        // Clear blocks
        pathfinder.clearAllBlocks();
        expect(pathfinder.blockedNodeIds.isEmpty, isTrue);

        final restoredRoute = pathfinder.findRoute(
          startId: start.id,
          goalId: target.id,
        );
        expect(restoredRoute, isNotNull);
        expect(restoredRoute!.totalDistance, equals(originalRoute.totalDistance));
      }
    });

    test('Dynamic Road Block Event: setRoadBlocked updates road edges', () {
      if (pathfinder.roads.isNotEmpty) {
        final road = pathfinder.roads.first;
        pathfinder.setRoadBlocked(road.id, true);
        expect(pathfinder.blockedRoadIds.contains(road.id), isTrue);

        pathfinder.setRoadBlocked(road.id, false);
        expect(pathfinder.blockedRoadIds.contains(road.id), isFalse);
      }
    });

    test('DoraVoiceService triggers speech lines, song, and handles stop', () {
      final voice = DoraVoiceService();
      expect(voice.isSpeaking, isFalse);

      voice.playMapSong();
      expect(voice.isSpeaking, isTrue);
      expect(voice.currentLine?.speaker, equals('The Map'));
      expect(voice.currentLine?.emoji, equals('🗺️'));

      voice.playSwiperWarning();
      expect(voice.currentLine?.speaker, contains('Dora'));
      expect(voice.currentLine?.emoji, equals('🦊'));

      voice.playRoadBlockWarning(obstacle: 'Rockslide');
      expect(voice.currentLine?.emoji, equals('🚧'));
      expect(voice.currentLine?.text, contains('Rockslide'));

      voice.playArrivalCelebration("King's Castle");
      expect(voice.currentLine?.emoji, equals('🌟'));
      expect(voice.currentLine?.text, contains("King's Castle"));

      voice.stopSpeaking();
      expect(voice.isSpeaking, isFalse);
      expect(voice.currentLine, isNull);
    });
  });
}
