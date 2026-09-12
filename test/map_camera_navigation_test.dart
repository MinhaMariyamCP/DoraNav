import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_application_1/screens/map/models/map_models.dart';
import 'package:flutter_application_1/screens/map/services/navigation_camera_service.dart';

void main() {
  group('NavigationCameraService & Route Focus Tests', () {
    const canvasSize = Size(400, 600);

    const nodeA = LocationNode(
      id: 'L001',
      name: "Dora's House",
      x: 35,
      y: 110,
      selectable: true,
      start: true,
      active: true,
      type: 'start',
      description: 'Start',
      region: 'Jungle',
    );

    const nodeB = LocationNode(
      id: 'L002',
      name: 'Jungle Entrance',
      x: 52,
      y: 110,
      selectable: false,
      start: false,
      active: true,
      type: 'intermediate',
      description: 'Jungle Entrance',
      region: 'Jungle',
    );

    const nodeC = LocationNode(
      id: 'L003',
      name: 'Adventure Forest',
      x: 75,
      y: 112,
      selectable: false,
      start: false,
      active: true,
      type: 'intermediate',
      description: 'Forest',
      region: 'Jungle',
    );

    const nodeCastle = LocationNode(
      id: 'L012',
      name: "King's Castle",
      x: 162,
      y: 130,
      selectable: true,
      start: false,
      active: true,
      type: 'destination',
      description: 'Castle',
      region: 'Valley',
    );

    test('Short route produces significant zoom-in compared to full world view', () {
      const shortRoute = NavigationRoute(
        nodes: [nodeA, nodeB],
        totalDistance: 0.8,
        etaMinutes: 3,
        nextInstruction: 'Head towards Jungle Entrance',
        nextDistanceMeters: 150,
      );

      final matrix = NavigationCameraService.fitToRoute(
        shortRoute,
        canvasSize: canvasSize,
      );

      // Extract scale factor from transformation matrix (element (0,0))
      final scale = matrix.storage[0];

      // A short route should have dynamic high scale (> 2.0), not 1.0
      expect(scale, greaterThan(2.0));
      expect(scale, lessThanOrEqualTo(3.2));
    });

    test('Long route scales appropriately to fit entire path inside viewport', () {
      const longRoute = NavigationRoute(
        nodes: [nodeA, nodeB, nodeC, nodeCastle],
        totalDistance: 7.5,
        etaMinutes: 28,
        nextInstruction: 'Follow trail to Castle',
        nextDistanceMeters: 500,
      );

      final matrix = NavigationCameraService.fitToRoute(
        longRoute,
        canvasSize: canvasSize,
      );

      final scale = matrix.storage[0];

      // Long route scale should be moderate to fit both start and distant destination
      expect(scale, greaterThanOrEqualTo(1.05));
      expect(scale, lessThan(2.2));
    });

    test('Active navigation camera centers around current location and upcoming route', () {
      final matrix = NavigationCameraService.followNavigation(
        nodeB,
        nodeC,
        canvasSize: canvasSize,
        zoom: 2.5,
      );

      final scale = matrix.storage[0];
      final tx = matrix.storage[12];
      final ty = matrix.storage[13];

      expect(scale, equals(2.5));
      // Translation values must be non-zero and offset to place focused point near center
      expect(tx, isNot(equals(0.0)));
      expect(ty, isNot(equals(0.0)));
    });

    test('Rerouted camera focuses on remaining detour path without resetting to world overview', () {
      const detourRoute = NavigationRoute(
        nodes: [nodeA, nodeB, nodeC, nodeCastle],
        totalDistance: 8.0,
        etaMinutes: 30,
        nextInstruction: 'Take safe detour',
        nextDistanceMeters: 200,
      );

      // Swiper detected ahead of nodeB -> user is at nodeB
      final matrix = NavigationCameraService.focusOnReroutedRoute(
        detourRoute,
        nodeB,
        canvasSize: canvasSize,
      );

      final scale = matrix.storage[0];
      expect(scale, greaterThan(1.05));
      expect(scale, isNot(equals(1.0)));
    });

    test('Arrival camera focuses cleanly on destination', () {
      final matrix = NavigationCameraService.focusOnLocation(
        nodeCastle,
        canvasSize: canvasSize,
        zoom: 2.6,
      );

      final scale = matrix.storage[0];
      expect(scale, equals(2.6));
    });
  });
}
