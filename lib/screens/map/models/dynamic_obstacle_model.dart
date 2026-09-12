import 'dart:math' as math;
import 'map_models.dart';

/// Types of dynamic obstacles in Dora's World.
enum DynamicObstacleType {
  swiper,
  crocodile,
  fallenTree,
  rockslide,
}

/// Continuous runtime position of Dora on the navigation map.
class DoraRuntimePosition {
  final double x;
  final double y;
  final String? currentNodeId; // node behind or node just reached
  final String? nextNodeId;    // upcoming node on route

  const DoraRuntimePosition({
    required this.x,
    required this.y,
    this.currentNodeId,
    this.nextNodeId,
  });

  DoraRuntimePosition copyWith({
    double? x,
    double? y,
    String? currentNodeId,
    String? nextNodeId,
  }) {
    return DoraRuntimePosition(
      x: x ?? this.x,
      y: y ?? this.y,
      currentNodeId: currentNodeId ?? this.currentNodeId,
      nextNodeId: nextNodeId ?? this.nextNodeId,
    );
  }

  double distanceToCoords(double targetX, double targetY) {
    final dx = x - targetX;
    final dy = y - targetY;
    return math.sqrt(dx * dx + dy * dy);
  }

  @override
  String toString() => 'DoraRuntimePosition(x: ${x.toStringAsFixed(1)}, y: ${y.toStringAsFixed(1)}, current: $currentNodeId, next: $nextNodeId)';
}

/// Dynamic obstacle entity spawned and managed at runtime.
class DynamicObstacle {
  final String id;
  final DynamicObstacleType type;
  String? nodeId;         // if placed at node
  String? roadId;         // if placed on a road
  double x;
  double y;
  bool active;
  final double riskRadius; // in coordinate units
  Duration? lifetime;      // optional for demo/ephemeral mode
  final bool blocksRoute;  // hard block vs soft delay
  final double penalty;    // additive penalty for soft avoidance

  DynamicObstacle({
    required this.id,
    required this.type,
    this.nodeId,
    this.roadId,
    required this.x,
    required this.y,
    this.active = true,
    this.riskRadius = 15.0,
    this.lifetime,
    this.blocksRoute = true,
    this.penalty = 0.0,
  });

  DynamicObstacle copyWith({
    String? nodeId,
    String? roadId,
    double? x,
    double? y,
    bool? active,
    double? riskRadius,
    Duration? lifetime,
    bool? blocksRoute,
    double? penalty,
  }) {
    return DynamicObstacle(
      id: id,
      type: type,
      nodeId: nodeId ?? this.nodeId,
      roadId: roadId ?? this.roadId,
      x: x ?? this.x,
      y: y ?? this.y,
      active: active ?? this.active,
      riskRadius: riskRadius ?? this.riskRadius,
      lifetime: lifetime ?? this.lifetime,
      blocksRoute: blocksRoute ?? this.blocksRoute,
      penalty: penalty ?? this.penalty,
    );
  }

  /// Determines whether this obstacle directly affects any segment of the remaining route.
  bool affectsActiveRoute({
    required List<LocationNode> remainingNodes,
    List<RoadEdge> roads = const [],
  }) {
    if (!active || remainingNodes.isEmpty) return false;

    // 1. Direct node match
    if (nodeId != null) {
      if (remainingNodes.any((n) => n.id == nodeId)) {
        return true;
      }
    }

    // 2. Direct road match along remaining route
    if (roadId != null) {
      if (roads.isNotEmpty) {
        for (int i = 0; i < remainingNodes.length - 1; i++) {
          final a = remainingNodes[i].id;
          final b = remainingNodes[i + 1].id;
          final isMatched = roads.any((r) =>
              r.id == roadId &&
              ((r.fromId == a && r.toId == b) || (r.bidirectional && r.fromId == b && r.toId == a)));
          if (isMatched) return true;
        }
      } else {
        // Fallback when edge map not provided directly
        return true;
      }
    }

    // 3. Proximity check within risk radius to remaining nodes
    if (nodeId == null && roadId == null) {
      for (final n in remainingNodes) {
        final dx = n.x - x;
        final dy = n.y - y;
        if (math.sqrt(dx * dx + dy * dy) <= riskRadius) {
          return true;
        }
      }
    }

    return false;
  }
}
