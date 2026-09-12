import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_application_1/screens/map/models/map_models.dart';
import 'package:flutter_application_1/services/navigation_simulation_service.dart';

void main() {
  group('NavigationSimulationService Tests', () {
    const nodeA = LocationNode(
      id: 'L001',
      name: "Dora's House",
      x: 0,
      y: 0,
      selectable: true,
      start: true,
      active: true,
      type: 'start',
      description: 'Start',
      region: 'Jungle',
    );

    const nodeB = LocationNode(
      id: 'L002',
      name: 'Tall Mountain',
      x: 10,
      y: 0,
      selectable: false,
      start: false,
      active: true,
      type: 'intermediate',
      description: 'Mountain',
      region: 'Jungle',
    );

    const nodeC = LocationNode(
      id: 'L003',
      name: "King's Castle",
      x: 20,
      y: 0,
      selectable: true,
      start: false,
      active: true,
      type: 'destination',
      description: 'Castle',
      region: 'Valley',
    );

    final testRoute = NavigationRoute(
      nodes: [nodeA, nodeB, nodeC],
      totalDistance: 20.0,
      etaMinutes: 1,
      nextInstruction: 'Head towards Tall Mountain',
      nextDistanceMeters: 500.0,
    );

    test('Initializes at start node with zero elapsed time', () {
      final service = NavigationSimulationService(
        initialRoute: testRoute,
        initialSpeed: 50.0,
      );

      expect(service.currentPosition, const Offset(0, 0));
      expect(service.currentSegmentIndex, 0);
      expect(service.segmentProgress, 0.0);
      expect(service.elapsedTime, Duration.zero);
      expect(service.isCompleted, false);
      expect(service.currentNode.id, 'L001');
      expect(service.nextNode?.id, 'L002');
      // Total map units = 20. At 50 m/unit = 1000 meters
      expect(service.remainingDistanceMeters, 1000.0);
      // At 50 m/s: 1000 / 50 = 20s ETA
      expect(service.estimatedTimeRemaining.inSeconds, 20);

      service.dispose();
    });

    test('Speed multiplier adjusts effective simulated speed and ETA', () {
      final service = NavigationSimulationService(
        initialRoute: testRoute,
        initialSpeed: 50.0,
      );

      expect(service.simulatedSpeed, 50.0);
      service.setSpeedMultiplier(2.0);
      expect(service.simulatedSpeed, 100.0);
      expect(service.estimatedTimeRemaining.inSeconds, 10);

      service.setSpeedMultiplier(5.0);
      expect(service.simulatedSpeed, 250.0);
      expect(service.estimatedTimeRemaining.inSeconds, 4);

      service.dispose();
    });

    test('Pause and resume control simulation state', () {
      final service = NavigationSimulationService(
        initialRoute: testRoute,
        initialSpeed: 50.0,
      );

      service.start();
      expect(service.isActive, true);
      expect(service.isPaused, false);

      service.pause();
      expect(service.isPaused, true);

      service.resume();
      expect(service.isPaused, false);

      service.dispose();
    });

    test('stepSimulation progresses Dora along path and reaches destination', () {
      bool reachedNodeB = false;
      bool reachedDestination = false;

      final service = NavigationSimulationService(
        initialRoute: testRoute,
        initialSpeed: 50.0,
        onNodeReached: (node) {
          if (node.id == 'L002') reachedNodeB = true;
        },
        onDestinationReached: () {
          reachedDestination = true;
        },
      );

      service.start();

      // Step forward 10 seconds: 50 m/s * 10s = 500m (reaches nodeB exactly)
      service.stepSimulation(10.0);
      expect(reachedNodeB, true);
      expect(service.currentSegmentIndex, 1);
      expect(service.currentPosition.dx, 10.0);
      expect(service.currentPosition.dy, 0.0);

      // Step forward another 10 seconds: 50 m/s * 10s = 500m (reaches nodeC / destination)
      service.stepSimulation(10.0);
      expect(reachedDestination, true);
      expect(service.isCompleted, true);
      expect(service.currentPosition.dx, 20.0);
      expect(service.currentPosition.dy, 0.0);
      expect(service.remainingDistanceMeters, 0.0);

      service.dispose();
    });

    test('updateRoute seamlessly reroutes from current position without resetting stopwatch', () async {
      final service = NavigationSimulationService(
        initialRoute: testRoute,
        initialSpeed: 50.0,
      );

      service.start();
      await Future.delayed(const Duration(milliseconds: 50));

      final initialElapsed = service.elapsedTime;
      expect(initialElapsed > Duration.zero, true);

      // Advance partially along first segment
      service.stepSimulation(5.0); // 250m along segment (dx >= 5)
      expect(service.currentPosition.dx, greaterThanOrEqualTo(5.0));

      // Create alternative route to Castle via Detour
      const detourNode = LocationNode(
        id: 'L_DETOUR',
        name: 'Detour Bridge',
        x: 5,
        y: 10,
        selectable: false,
        start: false,
        active: true,
        type: 'intermediate',
        description: 'Bridge',
        region: 'Jungle',
      );

      final rerouted = NavigationRoute(
        nodes: [nodeA, detourNode, nodeC],
        totalDistance: 25.0,
        etaMinutes: 2,
        nextInstruction: 'Take detour bridge',
        nextDistanceMeters: 250.0,
      );

      final posBefore = service.currentPosition;
      service.updateRoute(rerouted);

      // Dora position should be preserved at the live continuous coordinate
      expect(service.currentPosition.dx, closeTo(posBefore.dx, 0.01));
      expect(service.currentPosition.dy, closeTo(posBefore.dy, 0.01));

      // Elapsed time should NOT have reset to zero
      expect(service.elapsedTime >= initialElapsed, true);

      service.dispose();
    });
  });
}
