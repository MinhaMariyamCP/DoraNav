import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_application_1/screens/map/models/map_models.dart';
import 'package:flutter_application_1/screens/map/services/pathfinder_service.dart';

void main() {
  group('Dynamic Swiper Rerouting Tests', () {
    late PathfinderService pathfinder;

    setUp(() {
      pathfinder = PathfinderService();
    });

    test('Deterministic graph: A -> B -> C -> D reroutes to A -> B -> E -> F -> D when C is blocked by Swiper', () {
      // Setup isolated test graph
      pathfinder.clearGraph();

      // Nodes
      const nodeA = LocationNode(
        id: 'A',
        name: 'Start A',
        x: 0,
        y: 0,
        selectable: false,
        start: true,
        active: true,
        type: 'start',
        description: 'Start',
        region: 'Region 1',
      );
      const nodeB = LocationNode(
        id: 'B',
        name: 'Node B',
        x: 10,
        y: 0,
        selectable: false,
        start: false,
        active: true,
        type: 'intermediate',
        description: 'B',
        region: 'Region 1',
      );
      const nodeC = LocationNode(
        id: 'C',
        name: 'Node C',
        x: 20,
        y: 0,
        selectable: false,
        start: false,
        active: true,
        type: 'intermediate',
        description: 'C',
        region: 'Region 1',
      );
      const nodeD = LocationNode(
        id: 'D',
        name: 'Goal D',
        x: 30,
        y: 0,
        selectable: true,
        start: false,
        active: true,
        type: 'destination',
        description: 'Goal',
        region: 'Region 1',
      );
      const nodeE = LocationNode(
        id: 'E',
        name: 'Node E',
        x: 10,
        y: 10,
        selectable: false,
        start: false,
        active: true,
        type: 'intermediate',
        description: 'E',
        region: 'Region 1',
      );
      const nodeF = LocationNode(
        id: 'F',
        name: 'Node F',
        x: 20,
        y: 10,
        selectable: false,
        start: false,
        active: true,
        type: 'intermediate',
        description: 'F',
        region: 'Region 1',
      );

      pathfinder.addLocation(nodeA);
      pathfinder.addLocation(nodeB);
      pathfinder.addLocation(nodeC);
      pathfinder.addLocation(nodeD);
      pathfinder.addLocation(nodeE);
      pathfinder.addLocation(nodeF);

      // Primary shorter path: A-B (1.0), B-C (1.0), C-D (1.0) => Total = 3.0 km
      pathfinder.addRoadEdge(const RoadEdge(
        id: 'e_AB',
        fromId: 'A',
        toId: 'B',
        bidirectional: true,
        length: 1.0,
        blocked: false,
        fromName: 'Start A',
        toName: 'Node B',
        metadata: {},
      ));
      pathfinder.addRoadEdge(const RoadEdge(
        id: 'e_BC',
        fromId: 'B',
        toId: 'C',
        bidirectional: true,
        length: 1.0,
        blocked: false,
        fromName: 'Node B',
        toName: 'Node C',
        metadata: {},
      ));
      pathfinder.addRoadEdge(const RoadEdge(
        id: 'e_CD',
        fromId: 'C',
        toId: 'D',
        bidirectional: true,
        length: 1.0,
        blocked: false,
        fromName: 'Node C',
        toName: 'Goal D',
        metadata: {},
      ));

      // Alternative longer path: B-E (1.5), E-F (1.5), F-D (1.5) => Total from B = 4.5 km
      pathfinder.addRoadEdge(const RoadEdge(
        id: 'e_BE',
        fromId: 'B',
        toId: 'E',
        bidirectional: true,
        length: 1.5,
        blocked: false,
        fromName: 'Node B',
        toName: 'Node E',
        metadata: {},
      ));
      pathfinder.addRoadEdge(const RoadEdge(
        id: 'e_EF',
        fromId: 'E',
        toId: 'F',
        bidirectional: true,
        length: 1.5,
        blocked: false,
        fromName: 'Node E',
        toName: 'Node F',
        metadata: {},
      ));
      pathfinder.addRoadEdge(const RoadEdge(
        id: 'e_FD',
        fromId: 'F',
        toId: 'D',
        bidirectional: true,
        length: 1.5,
        blocked: false,
        fromName: 'Node F',
        toName: 'Goal D',
        metadata: {},
      ));

      // 1. Initial route without Swiper
      final initialRoute = pathfinder.findRoute(startId: 'A', goalId: 'D');
      expect(initialRoute, isNotNull);
      expect(initialRoute!.locationIds, equals(['A', 'B', 'C', 'D']));
      expect(initialRoute.totalDistanceKm, greaterThan(0));

      // 2. Swiper appears at node C!
      pathfinder.setSwiperLocation('C');
      expect(pathfinder.swiperState.active, isTrue);
      expect(pathfinder.swiperBlockedNodeIds.contains('C'), isTrue);

      // 3. Trigger A* reroute from current position B
      final reroutedFromB = pathfinder.rerouteAroundSwiper(
        currentLocationId: 'B',
        destinationId: 'D',
      );

      expect(reroutedFromB, isNotNull);
      // Must take the alternative path B -> E -> F -> D!
      expect(reroutedFromB!.locationIds, equals(['B', 'E', 'F', 'D']));
      expect(reroutedFromB.locationIds.contains('C'), isFalse);
      expect(reroutedFromB.totalDistanceKm, greaterThan(0));

      // If calculating full route from A with C blocked:
      final reroutedFromA = pathfinder.rerouteAroundSwiper(
        currentLocationId: 'A',
        destinationId: 'D',
      );
      expect(reroutedFromA, isNotNull);
      expect(reroutedFromA!.locationIds, equals(['A', 'B', 'E', 'F', 'D']));

      // 4. Clear Swiper and verify original optimal path is restored
      pathfinder.clearSwiper();
      expect(pathfinder.swiperState.active, isFalse);
      expect(pathfinder.swiperBlockedNodeIds.isEmpty, isTrue);

      final restoredRoute = pathfinder.findRoute(startId: 'A', goalId: 'D');
      expect(restoredRoute, isNotNull);
      expect(restoredRoute!.locationIds, equals(['A', 'B', 'C', 'D']));
    });

    test('No alternative route returns null when only passage is blocked', () {
      pathfinder.clearGraph();

      const nodeA = LocationNode(
        id: 'A',
        name: 'Start A',
        x: 0,
        y: 0,
        selectable: false,
        start: true,
        active: true,
        type: 'start',
        description: 'Start',
        region: 'Region 1',
      );
      const nodeB = LocationNode(
        id: 'B',
        name: 'Bridge B',
        x: 10,
        y: 0,
        selectable: false,
        start: false,
        active: true,
        type: 'intermediate',
        description: 'B',
        region: 'Region 1',
      );
      const nodeC = LocationNode(
        id: 'C',
        name: 'Goal C',
        x: 20,
        y: 0,
        selectable: true,
        start: false,
        active: true,
        type: 'destination',
        description: 'C',
        region: 'Region 1',
      );

      pathfinder.addLocation(nodeA);
      pathfinder.addLocation(nodeB);
      pathfinder.addLocation(nodeC);

      pathfinder.addRoadEdge(const RoadEdge(
        id: 'e_AB',
        fromId: 'A',
        toId: 'B',
        bidirectional: true,
        length: 1.0,
        blocked: false,
        fromName: 'Start A',
        toName: 'Bridge B',
        metadata: {},
      ));
      pathfinder.addRoadEdge(const RoadEdge(
        id: 'e_BC',
        fromId: 'B',
        toId: 'C',
        bidirectional: true,
        length: 1.0,
        blocked: false,
        fromName: 'Bridge B',
        toName: 'Goal C',
        metadata: {},
      ));

      // Swiper blocks the only choke point (Bridge B)
      pathfinder.setSwiperLocation('B');

      final reroute = pathfinder.rerouteAroundSwiper(
        currentLocationId: 'A',
        destinationId: 'C',
      );

      expect(reroute, isNull);
    });

    test('Real Dora World Graph: Dynamic reroute around Swiper on live map', () async {
      await pathfinder.loadMapData();

      // Start at Dora's House (L001) to King's Castle (L012)
      final initialRoute = pathfinder.findRoute(startId: 'L001', goalId: 'L012');
      expect(initialRoute, isNotNull);
      expect(initialRoute!.path.first.id, equals('L001'));
      expect(initialRoute.path.last.id, equals('L012'));

      // Find an intermediate node along this route (e.g. index 2 or 3)
      expect(initialRoute.path.length, greaterThanOrEqualTo(4));
      final swiperTargetNode = initialRoute.path[2];
      final currentPositionNode = initialRoute.path[1];

      // Swiper appears at swiperTargetNode!
      pathfinder.setSwiperLocation(swiperTargetNode.id);

      // Recalculate from current position
      final rerouted = pathfinder.rerouteAroundSwiper(
        currentLocationId: currentPositionNode.id,
        destinationId: 'L012',
      );

      expect(rerouted, isNotNull);
      expect(rerouted!.path.first.id, equals(currentPositionNode.id));
      expect(rerouted.path.last.id, equals('L012'));
      // Rerouted path must NOT pass through the Swiper-blocked node
      expect(rerouted.locationIds.contains(swiperTargetNode.id), isFalse);
      // Rerouted path must be a valid, distinct route
      expect(rerouted.path.length, greaterThanOrEqualTo(2));
    });
  });
}
