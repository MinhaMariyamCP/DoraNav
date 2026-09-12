import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_application_1/screens/map/models/map_models.dart';
import 'package:flutter_application_1/screens/map/services/dynamic_obstacle_manager.dart';
import 'package:flutter_application_1/screens/map/services/pathfinder_service.dart';
import 'package:flutter_application_1/screens/navigation/controllers/dora_movement_controller.dart';
import 'package:flutter_application_1/screens/navigation/widgets/obstacle_alert_popup.dart';
import 'package:flutter_application_1/services/navigation_simulation_service.dart';

void main() {
  group('Dynamic Navigation & Obstacles Test Suite', () {
    late PathfinderService pathfinder;
    late DynamicObstacleManager obstacleManager;

    const nodeA = LocationNode(
      id: 'A',
      name: "Dora's House",
      x: 0,
      y: 0,
      selectable: false,
      start: true,
      active: true,
      type: 'start',
      description: 'Start',
      region: 'Jungle',
    );

    const nodeB = LocationNode(
      id: 'B',
      name: 'River Crossing',
      x: 10,
      y: 0,
      selectable: false,
      start: false,
      active: true,
      type: 'intermediate',
      description: 'River',
      region: 'Jungle',
    );

    const nodeC = LocationNode(
      id: 'C',
      name: 'Forest Path',
      x: 20,
      y: 0,
      selectable: false,
      start: false,
      active: true,
      type: 'intermediate',
      description: 'Forest',
      region: 'Jungle',
    );

    const nodeD = LocationNode(
      id: 'D',
      name: 'Crystal Castle',
      x: 30,
      y: 0,
      selectable: true,
      start: false,
      active: true,
      type: 'destination',
      description: 'Castle',
      region: 'Valley',
    );

    const detourNodeE = LocationNode(
      id: 'E',
      name: 'Upper Ridge',
      x: 10,
      y: 10,
      selectable: false,
      start: false,
      active: true,
      type: 'intermediate',
      description: 'Ridge',
      region: 'Mountains',
    );

    const detourNodeF = LocationNode(
      id: 'F',
      name: 'High Lookout',
      x: 20,
      y: 10,
      selectable: false,
      start: false,
      active: true,
      type: 'intermediate',
      description: 'Lookout',
      region: 'Mountains',
    );

    setUp(() {
      pathfinder = PathfinderService();
      pathfinder.clearGraph();

      for (final n in [nodeA, nodeB, nodeC, nodeD, detourNodeE, detourNodeF]) {
        pathfinder.addLocation(n);
      }

      // Primary road: A -> B -> C -> D
      pathfinder.addRoadEdge(const RoadEdge(id: 'R_AB', fromId: 'A', toId: 'B', bidirectional: true, length: 10.0, blocked: false, fromName: 'A', toName: 'B', metadata: {}));
      pathfinder.addRoadEdge(const RoadEdge(id: 'R_BC', fromId: 'B', toId: 'C', bidirectional: true, length: 10.0, blocked: false, fromName: 'B', toName: 'C', metadata: {}));
      pathfinder.addRoadEdge(const RoadEdge(id: 'R_CD', fromId: 'C', toId: 'D', bidirectional: true, length: 10.0, blocked: false, fromName: 'C', toName: 'D', metadata: {}));

      // Detour bypass: A -> E -> F -> D
      pathfinder.addRoadEdge(const RoadEdge(id: 'R_AE', fromId: 'A', toId: 'E', bidirectional: true, length: 14.1, blocked: false, fromName: 'A', toName: 'E', metadata: {}));
      pathfinder.addRoadEdge(const RoadEdge(id: 'R_EF', fromId: 'E', toId: 'F', bidirectional: true, length: 10.0, blocked: false, fromName: 'E', toName: 'F', metadata: {}));
      pathfinder.addRoadEdge(const RoadEdge(id: 'R_FD', fromId: 'F', toId: 'D', bidirectional: true, length: 14.1, blocked: false, fromName: 'F', toName: 'D', metadata: {}));

      obstacleManager = pathfinder.dynamicObstacleManager;
      obstacleManager.clearAll();
    });

    tearDown(() {
      obstacleManager.dispose();
    });

    test('1. Continuous Dora runtime position interpolation', () {
      final posStart = DoraRuntimePosition(x: 0, y: 0, currentNodeId: 'A', nextNodeId: 'B');
      final controller = DoraMovementController(initialPosition: posStart, simulatedSpeed: 50.0);

      expect(controller.runtimePosition.x, 0.0);
      expect(controller.runtimePosition.y, 0.0);
      expect(controller.runtimePosition.currentNodeId, 'A');
      expect(controller.runtimePosition.nextNodeId, 'B');

      // Interpolate 50% along segment to B(10, 0)
      controller.interpolate(from: nodeA, to: nodeB, progress: 0.5);

      expect(controller.runtimePosition.x, 5.0);
      expect(controller.runtimePosition.y, 0.0);
      expect(controller.runtimePosition.currentNodeId, 'A');
      expect(controller.runtimePosition.nextNodeId, 'B');

      // Pause and preserve position
      controller.pauseAndPreservePosition();
      expect(controller.isMoving, false);
      expect(controller.runtimePosition.x, 5.0);

      controller.disposeController();
    });

    test('2. Dynamic obstacle spawning for all 4 types and state tracking', () {
      // Crocodile blocking river road R_BC
      obstacleManager.spawnObstacle(
        DynamicObstacleType.crocodile,
        id: 'croc_1',
        roadId: 'R_BC',
        blocksRoute: true,
        penalty: 100.0,
      );

      // Fallen Tree with penalty cost on R_CD
      obstacleManager.spawnObstacle(
        DynamicObstacleType.fallenTree,
        id: 'tree_1',
        roadId: 'R_CD',
        blocksRoute: false,
        penalty: 30.0,
      );

      // Rockslide blocking node C
      obstacleManager.spawnObstacle(
        DynamicObstacleType.rockslide,
        id: 'rock_1',
        nodeId: 'C',
        blocksRoute: true,
        penalty: 50.0,
      );

      // Swiper moving obstacle
      obstacleManager.spawnObstacle(
        DynamicObstacleType.swiper,
        id: 'swiper_1',
        nodeId: 'B',
        blocksRoute: true,
        penalty: 200.0,
      );

      expect(obstacleManager.activeObstacles.length, 4);
      expect(obstacleManager.runtimeRoadBlocked['R_BC'], true);
      expect(obstacleManager.runtimeNodeBlocked['C'], true);
      expect(obstacleManager.runtimeNodeBlocked['B'], true);
      expect(obstacleManager.runtimeRoadPenalty['R_CD'], 30.0);

      // Moving Swiper from B to E
      obstacleManager.moveSwiper('swiper_1', 10.0, 10.0, newNodeId: 'E', newRoadId: 'R_EF');
      final swiper = obstacleManager.activeObstacles.firstWhere((o) => o.id == 'swiper_1');
      expect(swiper.nodeId, 'E');
      expect(swiper.roadId, 'R_EF');
      expect(obstacleManager.runtimeNodeBlocked['B'], isNull);
      expect(obstacleManager.runtimeNodeBlocked['E'], true);

      // Remove crocodile
      obstacleManager.removeObstacle('croc_1');
      expect(obstacleManager.runtimeRoadBlocked['R_BC'], isNull);
      expect(obstacleManager.activeObstacles.length, 3);
    });

    test('3. Event-driven A* recalculation bypasses blocked roads and nodes', () {
      // Default shortest route from A to D is A -> B -> C -> D (distance 30)
      final normalRoute = pathfinder.findRoute(startId: 'A', goalId: 'D');
      expect(normalRoute, isNotNull);
      expect(normalRoute!.nodeNames, ['Dora\'s House', 'River Crossing', 'Forest Path', 'Crystal Castle']);

      // Spawn Swiper blocking node B
      obstacleManager.spawnObstacle(
        DynamicObstacleType.swiper,
        id: 'swiper_block_B',
        nodeId: 'B',
        blocksRoute: true,
      );

      // Pathfinder A* should automatically detour via Upper Ridge (E) and High Lookout (F)
      final detourRoute = pathfinder.findRoute(startId: 'A', goalId: 'D');
      expect(detourRoute, isNotNull);
      expect(detourRoute!.nodeNames, ['Dora\'s House', 'Upper Ridge', 'High Lookout', 'Crystal Castle']);
      expect(detourRoute.nodes.any((n) => n.id == 'B'), false);

      // Clear Swiper and verify return to optimal path
      obstacleManager.removeObstacle('swiper_block_B');
      final restoredRoute = pathfinder.findRoute(startId: 'A', goalId: 'D');
      expect(restoredRoute!.nodeNames, ['Dora\'s House', 'River Crossing', 'Forest Path', 'Crystal Castle']);
    });

    test('4. Reroute from Dora live position without resetting journey timer or restarting at house', () {
      final initialRoute = pathfinder.findRoute(startId: 'A', goalId: 'D')!;
      final simService = NavigationSimulationService(
        initialRoute: initialRoute,
        initialSpeed: 50.0,
      );

      simService.start();

      // Step simulation forward partially along A -> B
      simService.stepSimulation(2.0); // 100 meters
      final initialTime = simService.elapsedTime;
      final doraRuntime = simService.doraRuntimePosition;

      expect(doraRuntime.x, greaterThan(0.0));
      expect(doraRuntime.currentNodeId, 'A');
      expect(doraRuntime.nextNodeId, 'B');

      // Now block road R_BC ahead
      obstacleManager.spawnObstacle(
        DynamicObstacleType.crocodile,
        id: 'croc_ahead',
        roadId: 'R_BC',
        blocksRoute: true,
      );

      // Recalculate route from current position node (A)
      final rerouted = pathfinder.findRoute(startId: doraRuntime.currentNodeId!, goalId: 'D');
      expect(rerouted, isNotNull);
      expect(rerouted!.nodeNames, ['Dora\'s House', 'Upper Ridge', 'High Lookout', 'Crystal Castle']);

      // Update simulation route
      simService.updateRoute(rerouted);

      // Timer MUST NOT reset
      expect(simService.elapsedTime >= initialTime, true);

      // Dora must NOT reset to (0,0) if advanced
      expect(simService.currentPosition.dx, doraRuntime.x);

      simService.dispose();
    });

    test('5. Obstacle state change stream debounces and notifies listeners', () async {
      int notifyCount = 0;
      final subscription = obstacleManager.onObstacleStateChanged.listen((_) {
        notifyCount++;
      });

      obstacleManager.spawnObstacle(
        DynamicObstacleType.fallenTree,
        id: 'test_obs_1',
        roadId: 'R_AB',
        penalty: 15.0,
      );

      // Wait past the 250ms debounce window
      await Future.delayed(const Duration(milliseconds: 350));
      expect(notifyCount, greaterThanOrEqualTo(1));

      await subscription.cancel();
    });

    test('6. DynamicObstacleManager and DoraMovementController dispose cleanly without memory leaks', () {
      final tempManager = DynamicObstacleManager();
      tempManager.spawnObstacle(
        DynamicObstacleType.swiper,
        id: 'temp_swiper',
        nodeId: 'A',
      );
      tempManager.startDemoMode();
      expect(tempManager.isDemoModeActive, true);

      // Disposing terminates timers and closes streams
      tempManager.dispose();
      expect(tempManager.isDemoModeActive, false);

      final tempController = DoraMovementController(
        initialPosition: DoraRuntimePosition(x: 0, y: 0, currentNodeId: 'A', nextNodeId: 'B'),
      );
      expect(() => tempController.disposeController(), returnsNormally);
    });

    test('7. ObstacleAlertPopup data creation for all 4 types and states', () {
      final swiper = DynamicObstacle(id: 's1', type: DynamicObstacleType.swiper, x: 10, y: 10);
      final croc = DynamicObstacle(id: 'c1', type: DynamicObstacleType.crocodile, x: 20, y: 20);
      final tree = DynamicObstacle(id: 't1', type: DynamicObstacleType.fallenTree, x: 30, y: 30);
      final rock = DynamicObstacle(id: 'r1', type: DynamicObstacleType.rockslide, x: 40, y: 40);

      final pSwiper = ObstaclePopupData.forObstacle(swiper);
      expect(pSwiper.title, contains('SWIPER AHEAD'));
      expect(pSwiper.icon, '🦊');
      expect(pSwiper.rerouting, true);

      final pCroc = ObstaclePopupData.forObstacle(croc);
      expect(pCroc.title, contains('CROCODILE ALERT'));
      expect(pCroc.icon, '🐊');

      final pTree = ObstaclePopupData.forObstacle(tree);
      expect(pTree.title, contains('PATH BLOCKED'));
      expect(pTree.icon, '🌳');

      final pRock = ObstaclePopupData.forObstacle(rock);
      expect(pRock.title, contains('ROCKSLIDE AHEAD'));
      expect(pRock.icon, '🪨');

      final pNoRoute = ObstaclePopupData.noRoute();
      expect(pNoRoute.title, contains('No Safe Route Available'));
      expect(pNoRoute.noRouteAvailable, true);

      final pRestored = ObstaclePopupData.routeAvailable();
      expect(pRestored.title, contains('Route Available'));
      expect(pRestored.routeAvailable, true);
    });

    test('8. affectsActiveRoute correctly detects obstacles on remaining route segments', () {
      final remaining = [nodeA, nodeB, nodeC, nodeD];
      final roads = pathfinder.roads;

      // Obstacle on upcoming node B -> affects
      final obsOnB = DynamicObstacle(id: 'o_b', type: DynamicObstacleType.swiper, nodeId: 'B', x: 10, y: 0);
      expect(obsOnB.affectsActiveRoute(remainingNodes: remaining, roads: roads), true);

      // Obstacle on off-route node E -> does NOT affect
      final obsOnE = DynamicObstacle(id: 'o_e', type: DynamicObstacleType.crocodile, nodeId: 'E', x: 10, y: 10);
      expect(obsOnE.affectsActiveRoute(remainingNodes: remaining, roads: roads), false);

      // Obstacle on road R_BC -> affects
      final obsOnRoadBC = DynamicObstacle(id: 'o_rbc', type: DynamicObstacleType.fallenTree, roadId: 'R_BC', x: 15, y: 0);
      expect(obsOnRoadBC.affectsActiveRoute(remainingNodes: remaining, roads: roads), true);

      // Obstacle on road R_EF -> does NOT affect
      final obsOnRoadEF = DynamicObstacle(id: 'o_ref', type: DynamicObstacleType.rockslide, roadId: 'R_EF', x: 15, y: 10);
      expect(obsOnRoadEF.affectsActiveRoute(remainingNodes: remaining, roads: roads), false);
    });

    test('9. Multiple active obstacles accumulate and A* avoids ALL of them dynamically without hardcoded routes', () {
      // Add a third branch: A -> G -> H -> D
      const nodeG = LocationNode(id: 'G', name: 'Valley Way', x: 10, y: -10, selectable: false, start: false, active: true, type: 'intermediate', description: '', region: 'Valley');
      const nodeH = LocationNode(id: 'H', name: 'Valley Exit', x: 20, y: -10, selectable: false, start: false, active: true, type: 'intermediate', description: '', region: 'Valley');
      pathfinder.addLocation(nodeG);
      pathfinder.addLocation(nodeH);

      pathfinder.addRoadEdge(const RoadEdge(id: 'R_AG', fromId: 'A', toId: 'G', bidirectional: true, length: 15.0, blocked: false, fromName: 'A', toName: 'G', metadata: {}));
      pathfinder.addRoadEdge(const RoadEdge(id: 'R_GH', fromId: 'G', toId: 'H', bidirectional: true, length: 10.0, blocked: false, fromName: 'G', toName: 'H', metadata: {}));
      pathfinder.addRoadEdge(const RoadEdge(id: 'R_HD', fromId: 'H', toId: 'D', bidirectional: true, length: 15.0, blocked: false, fromName: 'H', toName: 'D', metadata: {}));

      // Initially, shortest path is A -> B -> C -> D
      var route = pathfinder.findRoute(startId: 'A', goalId: 'D');
      expect(route!.nodeNames, ['Dora\'s House', 'River Crossing', 'Forest Path', 'Crystal Castle']);

      // 1. Swiper blocks node B
      obstacleManager.spawnObstacle(DynamicObstacleType.swiper, id: 's_block', nodeId: 'B', blocksRoute: true);
      route = pathfinder.findRoute(startId: 'A', goalId: 'D');
      expect(route!.nodeNames, ['Dora\'s House', 'Upper Ridge', 'High Lookout', 'Crystal Castle']);

      // 2. Crocodile ALSO blocks detour road R_EF (both Swiper and Crocodile active!)
      obstacleManager.spawnObstacle(DynamicObstacleType.crocodile, id: 'c_block', roadId: 'R_EF', blocksRoute: true);
      route = pathfinder.findRoute(startId: 'A', goalId: 'D');
      // A* dynamically searches graph and finds third path via Valley (G -> H)
      expect(route!.nodeNames, ['Dora\'s House', 'Valley Way', 'Valley Exit', 'Crystal Castle']);

      // 3. Fallen tree blocks Valley road R_GH (all three branches blocked!)
      obstacleManager.spawnObstacle(DynamicObstacleType.fallenTree, id: 't_block', roadId: 'R_GH', blocksRoute: true);
      route = pathfinder.findRoute(startId: 'A', goalId: 'D');
      // No path available!
      expect(route, isNull);

      // 4. Crocodile is cleared! A* immediately restores path via Upper Ridge
      obstacleManager.removeObstacle('c_block');
      route = pathfinder.findRoute(startId: 'A', goalId: 'D');
      expect(route, isNotNull);
      expect(route!.nodeNames, ['Dora\'s House', 'Upper Ridge', 'High Lookout', 'Crystal Castle']);
    });

    testWidgets('10. ObstacleAlertPopup renders themed UI and updates state', (tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(
            body: ObstacleAlertPopup(
              obstacleType: DynamicObstacleType.swiper,
              title: '⚠ SWIPER AHEAD! 🦊',
              description: 'Swiper is blocking your current route.',
              icon: '🦊',
              rerouting: true,
            ),
          ),
        ),
      );

      await tester.pump(const Duration(milliseconds: 400));

      expect(find.text('⚠ SWIPER AHEAD! 🦊'), findsOneWidget);
      expect(find.text('Swiper is blocking your current route.'), findsOneWidget);
      expect(find.text('Finding a safer route...'), findsOneWidget);

      // Pump updated widget with newRouteFound: true
      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(
            body: ObstacleAlertPopup(
              obstacleType: DynamicObstacleType.swiper,
              title: '⚠ SWIPER AHEAD! 🦊',
              description: 'Swiper is blocking your current route.',
              icon: '🦊',
              rerouting: false,
              newRouteFound: true,
            ),
          ),
        ),
      );

      await tester.pump(const Duration(milliseconds: 400));

      expect(find.text('New route found!'), findsOneWidget);
      expect(find.byIcon(Icons.check_circle_rounded), findsOneWidget);
    });
  });
}
