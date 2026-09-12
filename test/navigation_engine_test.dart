import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_application_1/screens/map/models/map_models.dart';
import 'package:flutter_application_1/screens/map/services/obstacle_manager.dart';
import 'package:flutter_application_1/screens/map/services/navigation_service.dart';
import 'package:flutter_application_1/screens/map/services/pathfinder_service.dart';
import 'package:flutter_application_1/screens/route_selection/models/route_selection_models.dart';

void main() {
  group('Deterministic Test Graph (Specification Requirement)', () {
    late ObstacleManager obstacleManager;
    late NavigationService navigationService;

    // Nodes: A, B, C, D, E, F, G, H
    // Coordinates placed so Euclidean distance <= path distance (admissible heuristic)
    final nodeA = const LocationNode(id: 'A', name: 'Node A', x: 0.0, y: 0.0, selectable: true, start: true, active: true, type: 'start', description: '', region: 'Test');
    final nodeB = const LocationNode(id: 'B', name: 'Node B', x: 0.5, y: 0.0, selectable: true, start: false, active: true, type: 'waypoint', description: '', region: 'Test');
    final nodeC = const LocationNode(id: 'C', name: 'Node C', x: 1.0, y: 0.0, selectable: true, start: false, active: true, type: 'waypoint', description: '', region: 'Test');
    final nodeD = const LocationNode(id: 'D', name: 'Node D', x: 1.5, y: 0.0, selectable: true, start: false, active: true, type: 'destination', description: '', region: 'Test');

    final nodeE = const LocationNode(id: 'E', name: 'Node E', x: 0.5, y: 0.5, selectable: true, start: false, active: true, type: 'waypoint', description: '', region: 'Test');
    final nodeF = const LocationNode(id: 'F', name: 'Node F', x: 1.0, y: 0.5, selectable: true, start: false, active: true, type: 'waypoint', description: '', region: 'Test');

    final nodeG = const LocationNode(id: 'G', name: 'Node G', x: 0.5, y: 1.0, selectable: true, start: false, active: true, type: 'waypoint', description: '', region: 'Test');
    final nodeH = const LocationNode(id: 'H', name: 'Node H', x: 1.0, y: 1.0, selectable: true, start: false, active: true, type: 'waypoint', description: '', region: 'Test');

    final allDeterministicNodes = [nodeA, nodeB, nodeC, nodeD, nodeE, nodeF, nodeG, nodeH];

    // Edges:
    // Path 1 (A-B-C-D) = 0.5 + 0.5 + 0.5 = 1.5
    final edgeAB = const RoadEdge(id: 'R_AB', fromId: 'A', toId: 'B', bidirectional: true, length: 0.5, blocked: false, fromName: 'A', toName: 'B', metadata: {});
    final edgeBC = const RoadEdge(id: 'R_BC', fromId: 'B', toId: 'C', bidirectional: true, length: 0.5, blocked: false, fromName: 'B', toName: 'C', metadata: {});
    final edgeCD = const RoadEdge(id: 'R_CD', fromId: 'C', toId: 'D', bidirectional: true, length: 0.5, blocked: false, fromName: 'C', toName: 'D', metadata: {});

    // Path 2 (A-E-F-D) = 0.7 + 0.7 + 0.7 = 2.1
    final edgeAE = const RoadEdge(id: 'R_AE', fromId: 'A', toId: 'E', bidirectional: true, length: 0.7, blocked: false, fromName: 'A', toName: 'E', metadata: {});
    final edgeEF = const RoadEdge(id: 'R_EF', fromId: 'E', toId: 'F', bidirectional: true, length: 0.7, blocked: false, fromName: 'E', toName: 'F', metadata: {});
    final edgeFD = const RoadEdge(id: 'R_FD', fromId: 'F', toId: 'D', bidirectional: true, length: 0.7, blocked: false, fromName: 'F', toName: 'D', metadata: {});

    // Path 3 (A-G-H-D) = 1.0 + 1.0 + 1.0 = 3.0
    final edgeAG = const RoadEdge(id: 'R_AG', fromId: 'A', toId: 'G', bidirectional: true, length: 1.0, blocked: false, fromName: 'A', toName: 'G', metadata: {});
    final edgeGH = const RoadEdge(id: 'R_GH', fromId: 'G', toId: 'H', bidirectional: true, length: 1.0, blocked: false, fromName: 'G', toName: 'H', metadata: {});
    final edgeHD = const RoadEdge(id: 'R_HD', fromId: 'H', toId: 'D', bidirectional: true, length: 1.0, blocked: false, fromName: 'H', toName: 'D', metadata: {});

    final allDeterministicRoads = [edgeAB, edgeBC, edgeCD, edgeAE, edgeEF, edgeFD, edgeAG, edgeGH, edgeHD];

    setUp(() {
      obstacleManager = ObstacleManager();
      navigationService = NavigationService(obstacleManager: obstacleManager);
      navigationService.initialize(nodes: allDeterministicNodes, roads: allDeterministicRoads);
    });

    test('1. Initial route from A to D returns A -> B -> C -> D (Cost 1.5)', () {
      final route1 = navigationService.startNavigation('A', 'D', RouteOptionType.normal);

      expect(route1, isNotNull);
      expect(route1!.nodeIds, equals(['A', 'B', 'C', 'D']));
      expect(route1.roadIds, equals(['R_AB', 'R_BC', 'R_CD']));
      expect(route1.routeVersion, equals(1));
    });

    test('2. Block C (node or B-C edge) -> Rerun A* from A -> D => A -> E -> F -> D (Cost 2.1)', () {
      final route1 = navigationService.startNavigation('A', 'D', RouteOptionType.normal);
      expect(route1!.nodeIds, equals(['A', 'B', 'C', 'D']));

      // Activate obstacle on node C
      final obsC = const Obstacle(
        id: 'obs_C',
        type: ObstacleType.swiper,
        locationNodeId: 'C',
        affectedNodeIds: ['C'],
        active: true,
        blocksNode: true,
      );
      navigationService.handleObstacleEvent(
        ObstacleEvent(action: ObstacleEventAction.add, obstacle: obsC),
      );

      final activeRoute = navigationService.getActiveRoute();
      expect(activeRoute, isNotNull);
      expect(activeRoute!.nodeIds, equals(['A', 'E', 'F', 'D']));
      expect(activeRoute.roadIds, equals(['R_AE', 'R_EF', 'R_FD']));
      expect(activeRoute.routeVersion, equals(2));
    });

    test('3. Then block E (or A-E) -> Rerun => A -> G -> H -> D (Cost 3.0)', () {
      navigationService.startNavigation('A', 'D', RouteOptionType.normal);

      // Block C
      final obsC = const Obstacle(
        id: 'obs_C',
        type: ObstacleType.swiper,
        locationNodeId: 'C',
        affectedNodeIds: ['C'],
        active: true,
        blocksNode: true,
      );
      navigationService.handleObstacleEvent(
        ObstacleEvent(action: ObstacleEventAction.add, obstacle: obsC),
      );

      // Block E
      final obsE = const Obstacle(
        id: 'obs_E',
        type: ObstacleType.blockedBridge,
        locationNodeId: 'E',
        affectedNodeIds: ['E'],
        active: true,
        blocksNode: true,
      );
      navigationService.handleObstacleEvent(
        ObstacleEvent(action: ObstacleEventAction.add, obstacle: obsE),
      );

      final activeRoute = navigationService.getActiveRoute();
      expect(activeRoute, isNotNull);
      expect(activeRoute!.nodeIds, equals(['A', 'G', 'H', 'D']));
      expect(activeRoute.roadIds, equals(['R_AG', 'R_GH', 'R_HD']));
      expect(activeRoute.routeVersion, equals(3));
    });

    test('4. Then block G or H -> Rerun => NO_ROUTE_AVAILABLE', () {
      navigationService.startNavigation('A', 'D', RouteOptionType.normal);

      // Block C
      navigationService.handleObstacleEvent(
        ObstacleEvent(
          action: ObstacleEventAction.add,
          obstacle: const Obstacle(
            id: 'obs_C',
            type: ObstacleType.swiper,
            locationNodeId: 'C',
            affectedNodeIds: ['C'],
            active: true,
            blocksNode: true,
          ),
        ),
      );

      // Block E
      navigationService.handleObstacleEvent(
        ObstacleEvent(
          action: ObstacleEventAction.add,
          obstacle: const Obstacle(
            id: 'obs_E',
            type: ObstacleType.blockedBridge,
            locationNodeId: 'E',
            affectedNodeIds: ['E'],
            active: true,
            blocksNode: true,
          ),
        ),
      );

      // Block G
      navigationService.handleObstacleEvent(
        ObstacleEvent(
          action: ObstacleEventAction.add,
          obstacle: const Obstacle(
            id: 'obs_G',
            type: ObstacleType.crocodile,
            locationNodeId: 'G',
            affectedNodeIds: ['G'],
            active: true,
            blocksNode: true,
          ),
        ),
      );

      final activeRoute = navigationService.getActiveRoute();
      expect(activeRoute, isNull); // NO_ROUTE_AVAILABLE
      expect(navigationService.routeVersion, equals(4));
    });
  });

  group('Real Dora World Acceptance Test (Specification Requirement)', () {
    late PathfinderService pathfinder;
    late NavigationService navigationService;
    late ObstacleManager obstacleManager;

    setUp(() async {
      pathfinder = PathfinderService();
      await pathfinder.loadMapData();
      obstacleManager = pathfinder.obstacleManager;
      navigationService = pathfinder.navigationService;
    });

    test('Loads full Dora World Graph: 70 nodes and 119 roads', () {
      expect(pathfinder.allLocations.length, equals(70));
      expect(pathfinder.roads.length, equals(119));
      expect(navigationService.allNodes.length, equals(70));
      expect(navigationService.allRoads.length, equals(119));
    });

    test('Sequential multi-obstacle rerouting chain: Route1 -> Swiper -> Route2 -> Blocked Bridge -> Route3 -> Crocodile -> Route4', () {
      // Step 1: Start at Dora's House (L001), Goal: King's Castle (L012)
      final route1 = navigationService.startNavigation('L001', 'L012', RouteOptionType.normal);
      expect(route1, isNotNull);
      expect(route1!.nodeIds.first, equals('L001'));
      expect(route1.nodeIds.last, equals('L012'));
      expect(route1.routeVersion, equals(1));
      final r1Path = List<String>.from(route1.nodeIds);
      expect(r1Path.contains('L040'), isTrue); // Passes through Forest Garden

      // Step 2: Activate Swiper on Route1 (at Forest Garden L040)
      final swiperObstacle = const Obstacle(
        id: 'obs_swiper_forest_garden',
        type: ObstacleType.swiper,
        locationNodeId: 'L040',
        affectedNodeIds: ['L040'],
        active: true,
        blocksNode: true,
        description: 'Sneaky Swiper',
        isDynamic: true,
      );
      navigationService.handleObstacleEvent(
        ObstacleEvent(action: ObstacleEventAction.add, obstacle: swiperObstacle),
      );

      final route2 = navigationService.getActiveRoute();
      expect(route2, isNotNull);
      expect(route2!.routeVersion, equals(2));
      expect(route2.nodeIds.contains('L040'), isFalse); // Bypassed Swiper
      expect(route2.nodeIds.first, equals('L001'));
      expect(route2.nodeIds.last, equals('L012'));
      final r2Roads = List<String>.from(route2.roadIds);
      expect(r2Roads.contains('R061'), isTrue); // Uses road R061 towards Big Tree

      // Step 3: Activate Blocked Bridge on Route2 (blocking road R061)
      final bridgeObstacle = const Obstacle(
        id: 'obs_bridge_collapse',
        type: ObstacleType.blockedBridge,
        roadId: 'R061',
        affectedRoadIds: ['R061'],
        active: true,
        blocksRoad: true,
        description: 'Collapsed Wooden Bridge',
      );
      navigationService.handleObstacleEvent(
        ObstacleEvent(action: ObstacleEventAction.add, obstacle: bridgeObstacle),
      );

      final route3 = navigationService.getActiveRoute();
      expect(route3, isNotNull);
      expect(route3!.routeVersion, equals(3));
      expect(route3.roadIds.contains('R061'), isFalse); // Bypassed collapsed bridge
      expect(route3.nodeIds.contains('L040'), isFalse); // Still avoiding Swiper
      expect(route3.nodeIds.contains('L029'), isTrue); // Diverts via Nutty Forest (L029)

      // Step 4: Activate Crocodile on Route3 (at Nutty Forest L029)
      final crocObstacle = const Obstacle(
        id: 'obs_croc_nutty_forest',
        type: ObstacleType.crocodile,
        locationNodeId: 'L029',
        affectedNodeIds: ['L029'],
        active: true,
        blocksNode: true,
        description: 'Hungry River Crocodile',
      );
      navigationService.handleObstacleEvent(
        ObstacleEvent(action: ObstacleEventAction.add, obstacle: crocObstacle),
      );

      final route4 = navigationService.getActiveRoute();
      expect(route4, isNotNull);
      expect(route4!.routeVersion, equals(4));
      expect(route4.nodeIds.contains('L029'), isFalse); // Bypassed crocodile
      expect(route4.roadIds.contains('R061'), isFalse); // Bypassed bridge
      expect(route4.nodeIds.contains('L040'), isFalse); // Bypassed Swiper
      expect(route4.nodeIds.contains('L028'), isTrue); // Detours via Flower Field (L028)
      expect(route4.nodeIds.last, equals('L012'));
    });

    test('Reroute from CURRENT user node preserves user progress', () {
      // Start navigation
      final route1 = navigationService.startNavigation('L001', 'L012', RouteOptionType.normal);
      expect(route1, isNotNull);

      // User walks to Jungle Entrance (L026)
      navigationService.updateCurrentLocation('L026');
      expect(navigationService.currentNodeId, equals('L026'));

      // Swiper blocks next node on Route1 (Adventure Forest L031)
      final swiper = const Obstacle(
        id: 'obs_swiper_adv_forest',
        type: ObstacleType.swiper,
        locationNodeId: 'L031',
        affectedNodeIds: ['L031'],
        active: true,
        blocksNode: true,
        description: 'Swiper behind the tree',
      );
      navigationService.handleObstacleEvent(
        ObstacleEvent(action: ObstacleEventAction.add, obstacle: swiper),
      );

      final rerouted = navigationService.getActiveRoute();
      expect(rerouted, isNotNull);
      // Crucial: Must start from L026 (current location), NOT from L001 (Dora's House)!
      expect(rerouted!.nodeIds.first, equals('L026'));
      expect(rerouted.nodeIds.contains('L031'), isFalse);
      expect(rerouted.nodeIds.last, equals('L012'));
    });

    test('Soft obstacle penalties influence path selection without hard-blocking', () {
      // Clear all obstacles
      obstacleManager.clear();

      // Start navigation
      final normalRoute = navigationService.startNavigation('L001', 'L012', RouteOptionType.normal);
      expect(normalRoute, isNotNull);

      // Place a soft dangerous area obstacle with high penalty (+200) on L031
      final dangerousArea = const Obstacle(
        id: 'obs_muddy_swamp',
        type: ObstacleType.dangerousArea,
        locationNodeId: 'L031',
        affectedNodeIds: ['L031'],
        active: true,
        blocksNode: false, // Soft obstacle!
        penalty: 200.0,
      );
      obstacleManager.addObstacle(dangerousArea);

      // With heavy penalty, A* finds a cheaper bypass route
      final penalizedRoute = navigationService.findRoute('L001', 'L012', RouteOptionType.normal);
      expect(penalizedRoute, isNotNull);
      expect(penalizedRoute!.nodeIds.contains('L031'), isFalse);
    });

    test('Route preference SWIPER_SAFE avoids proximity to active Swiper', () {
      obstacleManager.clear();

      // Swiper is near Forest Garden (L040)
      final swiper = const Obstacle(
        id: 'obs_swiper_scout',
        type: ObstacleType.swiper,
        locationNodeId: 'L040',
        affectedNodeIds: ['L040'],
        active: true,
        blocksNode: false, // Soft penalty proximity
        isDynamic: true,
      );
      obstacleManager.addObstacle(swiper);

      final safeRoute = navigationService.findRoute('L001', 'L012', RouteOptionType.swiperSafe);
      expect(safeRoute, isNotNull);
      // SWIPER_SAFE route preference avoids L040
      expect(safeRoute!.nodeIds.contains('L040'), isFalse);
    });
  });
}
