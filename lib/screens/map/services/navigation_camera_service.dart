import 'dart:math' as math;
import 'package:flutter/material.dart';
import '../models/map_models.dart';
import 'map_projection_service.dart';

/// Service responsible for calculating and animating the map camera transformation
/// based on route bounds, current location, next waypoint, and navigation events.
class NavigationCameraService {
  static const double virtualWidth = 200.0;
  static const double virtualHeight = 200.0;

  /// Converts a world coordinate (0..200, 0..200) into pixel coordinate for a given canvas size.
  static Offset toPixel(double x, double y, Size canvasSize) {
    return MapProjectionService.coordsToPixel(x, y, canvasSize.width, canvasSize.height);
  }

  /// Converts a [LocationNode] into calibrated pixel coordinate for a given canvas size.
  static Offset toPixelNode(LocationNode node, Size canvasSize) {
    return MapProjectionService.nodeToPixel(node, canvasSize.width, canvasSize.height);
  }

  /// Calculates a camera matrix that fits the given [route] onto the canvas with [padding].
  static Matrix4 fitToRoute(
    NavigationRoute route, {
    required Size canvasSize,
    EdgeInsets padding = const EdgeInsets.all(40.0),
  }) {
    if (route.nodes.isEmpty || canvasSize.width <= 0 || canvasSize.height <= 0) {
      return Matrix4.identity();
    }

    debugPrint('[Map] Route calculated:');
    debugPrint(route.nodes.map((n) => n.name).join(' → '));
    debugPrint('[Map] Fitting camera to route.');

    // 1. Get pixel coordinates of all route nodes
    final pixelPoints = route.nodes.map((n) => toPixelNode(n, canvasSize)).toList();

    double minPx = pixelPoints.first.dx;
    double maxPx = pixelPoints.first.dx;
    double minPy = pixelPoints.first.dy;
    double maxPy = pixelPoints.first.dy;

    for (final p in pixelPoints) {
      if (p.dx < minPx) minPx = p.dx;
      if (p.dx > maxPx) maxPx = p.dx;
      if (p.dy < minPy) minPy = p.dy;
      if (p.dy > maxPy) maxPy = p.dy;
    }

    final double contentWidth = math.max(maxPx - minPx, 40.0);
    final double contentHeight = math.max(maxPy - minPy, 40.0);

    final double availableWidth = canvasSize.width - (padding.left + padding.right);
    final double availableHeight = canvasSize.height - (padding.top + padding.bottom);

    // Calculate scale factor, clamping between 1.05 and 3.2
    final double scaleX = availableWidth / contentWidth;
    final double scaleY = availableHeight / contentHeight;
    final double targetScale = math.min(scaleX, scaleY).clamp(1.05, 3.2);

    // Center of the route in pixel space
    final double routeCenterPx = (minPx + maxPx) / 2;
    final double routeCenterPy = (minPy + maxPy) / 2;

    // Center of the canvas viewport
    final double viewportCenterPx = canvasSize.width / 2;
    final double viewportCenterPy = canvasSize.height / 2;

    // Translation so that routeCenter is aligned with viewportCenter after scaling
    final double tx = viewportCenterPx - (routeCenterPx * targetScale);
    final double ty = viewportCenterPy - (routeCenterPy * targetScale);

    final matrix = Matrix4.identity()
      ..translateByDouble(tx, ty, 0.0, 1.0)
      ..scaleByDouble(targetScale, targetScale, 1.0, 1.0);

    return matrix;
  }

  /// Calculates a camera matrix focusing on the user's [current] position and the [next] waypoint segment.
  static Matrix4 followNavigation(
    LocationNode current,
    LocationNode? next, {
    required Size canvasSize,
    double zoom = 2.4,
  }) {
    if (canvasSize.width <= 0 || canvasSize.height <= 0) {
      return Matrix4.identity();
    }

    debugPrint('[Map] Current location: ${current.name}');
    if (next != null) {
      debugPrint('[Map] Next location: ${next.name}');
    }

    final curPx = toPixelNode(current, canvasSize);

    double focusPx = curPx.dx;
    double focusPy = curPx.dy;

    if (next != null) {
      final nextPx = toPixelNode(next, canvasSize);
      // Bias camera slightly forward toward next waypoint (65% current, 35% next)
      focusPx = (curPx.dx * 0.65) + (nextPx.dx * 0.35);
      focusPy = (curPx.dy * 0.65) + (nextPx.dy * 0.35);
    }

    final double targetScale = zoom.clamp(1.5, 3.4);
    final double viewportCenterPx = canvasSize.width / 2;
    // Bias slightly lower vertically so ahead trail is visible
    final double viewportCenterPy = canvasSize.height * 0.55;

    final double tx = viewportCenterPx - (focusPx * targetScale);
    final double ty = viewportCenterPy - (focusPy * targetScale);

    final matrix = Matrix4.identity()
      ..translateByDouble(tx, ty, 0.0, 1.0)
      ..scaleByDouble(targetScale, targetScale, 1.0, 1.0);

    return matrix;
  }

  /// Calculates a camera matrix focusing on Dora's continuous simulated coordinate.
  static Matrix4 followContinuousPosition(
    Offset currentPos,
    Offset? nextPos, {
    required Size canvasSize,
    double zoom = 2.4,
  }) {
    if (canvasSize.width <= 0 || canvasSize.height <= 0) {
      return Matrix4.identity();
    }

    final curPx = toPixel(currentPos.dx, currentPos.dy, canvasSize);

    double focusPx = curPx.dx;
    double focusPy = curPx.dy;

    if (nextPos != null) {
      final nextPx = toPixel(nextPos.dx, nextPos.dy, canvasSize);
      // Bias camera slightly forward toward next waypoint (70% current, 30% next)
      focusPx = (curPx.dx * 0.70) + (nextPx.dx * 0.30);
      focusPy = (curPx.dy * 0.70) + (nextPx.dy * 0.30);
    }

    final double targetScale = zoom.clamp(1.5, 3.4);
    final double viewportCenterPx = canvasSize.width / 2;
    // Bias slightly lower vertically (58%) so ahead trail is prominently visible
    final double viewportCenterPy = canvasSize.height * 0.58;

    final double tx = viewportCenterPx - (focusPx * targetScale);
    final double ty = viewportCenterPy - (focusPy * targetScale);

    return Matrix4.identity()
      ..translateByDouble(tx, ty, 0.0, 1.0)
      ..scaleByDouble(targetScale, targetScale, 1.0, 1.0);
  }

  /// Focuses specifically on [location] (e.g. arrival at destination).
  static Matrix4 focusOnLocation(
    LocationNode location, {
    required Size canvasSize,
    double zoom = 2.6,
  }) {
    if (canvasSize.width <= 0 || canvasSize.height <= 0) {
      return Matrix4.identity();
    }

    final locPx = toPixelNode(location, canvasSize);
    final double targetScale = zoom.clamp(1.5, 3.4);

    final double tx = (canvasSize.width / 2) - (locPx.dx * targetScale);
    final double ty = (canvasSize.height / 2) - (locPx.dy * targetScale);

    final matrix = Matrix4.identity()
      ..translateByDouble(tx, ty, 0.0, 1.0)
      ..scaleByDouble(targetScale, targetScale, 1.0, 1.0);

    return matrix;
  }

  /// Calculates a camera matrix focusing on the rerouted route without jumping back to world overview.
  static Matrix4 focusOnReroutedRoute(
    NavigationRoute newRoute,
    LocationNode currentLocation, {
    required Size canvasSize,
  }) {
    debugPrint('[Map] Swiper detected on active route.');
    debugPrint('[Map] Rerouting...');
    debugPrint('[Map] New route:');
    debugPrint(newRoute.nodes.map((n) => n.name).join(' → '));
    debugPrint('[Map] Camera updated to new route.');

    // Focus on remaining portion of route starting from currentLocation
    final startIndex = newRoute.nodes.indexWhere((n) => n.id == currentLocation.id);
    final remainingNodes = startIndex >= 0
        ? newRoute.nodes.sublist(startIndex)
        : newRoute.nodes;

    final partialRoute = NavigationRoute(
      nodes: remainingNodes.length > 1 ? remainingNodes : newRoute.nodes,
      totalDistance: newRoute.totalDistance,
      etaMinutes: newRoute.etaMinutes,
      nextInstruction: newRoute.nextInstruction,
      nextDistanceMeters: newRoute.nextDistanceMeters,
    );

    return fitToRoute(
      partialRoute,
      canvasSize: canvasSize,
      padding: const EdgeInsets.symmetric(horizontal: 48, vertical: 64),
    );
  }
}
