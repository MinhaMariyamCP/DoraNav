/// Data models for the DoraNav World Map and Navigation Engine.
library;

import 'dart:math' as math;
export 'obstacle_model.dart';
export 'dynamic_obstacle_model.dart';

class LocationNode {
  final String id;
  final String name;
  final double x;
  final double y;
  final bool selectable;
  final bool start;
  final bool active;
  final String type;
  final String description;
  final String region;
  final List<String> tags;
  final bool isBlocked;
  final String? blockedReason;

  const LocationNode({
    required this.id,
    required this.name,
    required this.x,
    required this.y,
    required this.selectable,
    required this.start,
    required this.active,
    required this.type,
    required this.description,
    required this.region,
    this.tags = const [],
    this.isBlocked = false,
    this.blockedReason,
  });

  factory LocationNode.fromJson(Map<String, dynamic> json) {
    final meta = json['metadata'] as Map<String, dynamic>? ?? {};
    final tagsList = (json['tags'] as List<dynamic>?)
            ?.map((e) => e.toString())
            .toList() ??
        (meta['tags'] as List<dynamic>?)?.map((e) => e.toString()).toList() ??
        const <String>[];

    return LocationNode(
      id: json['id'] as String,
      name: json['name'] as String,
      x: (json['x'] as num).toDouble(),
      y: (json['y'] as num).toDouble(),
      selectable: json['selectable'] as bool? ?? false,
      start: json['start'] as bool? ?? false,
      active: json['active'] as bool? ?? true,
      type: json['type'] as String? ?? 'intermediate',
      description: meta['description'] as String? ?? '',
      region: meta['region'] as String? ?? 'Jungle',
      tags: tagsList,
      isBlocked: json['isBlocked'] as bool? ?? false,
      blockedReason: json['blockedReason'] as String?,
    );
  }

  LocationNode copyWith({
    bool? isBlocked,
    String? blockedReason,
    bool? active,
  }) {
    return LocationNode(
      id: id,
      name: name,
      x: x,
      y: y,
      selectable: selectable,
      start: start,
      active: active ?? this.active,
      type: type,
      description: description,
      region: region,
      tags: tags,
      isBlocked: isBlocked ?? this.isBlocked,
      blockedReason: blockedReason ?? this.blockedReason,
    );
  }

  double distanceTo(LocationNode other) {
    final dx = x - other.x;
    final dy = y - other.y;
    return math.sqrt(dx * dx + dy * dy);
  }
}

class RoadEdge {
  final String id;
  final String fromId;
  final String toId;
  final bool bidirectional;
  final double length;
  final bool blocked;
  final String fromName;
  final String toName;
  final Map<String, dynamic> metadata;
  final double baseCost;
  final String terrainType;
  final double difficulty;
  final double adventureValue;
  final String? blockedReason;
  final bool temporaryObstacle;
  final String? obstacleId;

  // Aliases for spec compliance
  String get fromNodeId => fromId;
  String get toNodeId => toId;
  double get distance => length;
  bool get isBlocked => blocked;

  const RoadEdge({
    required this.id,
    required this.fromId,
    required this.toId,
    required this.bidirectional,
    required this.length,
    required this.blocked,
    required this.fromName,
    required this.toName,
    required this.metadata,
    double? baseCost,
    this.terrainType = 'trail',
    this.difficulty = 1.0,
    this.adventureValue = 1.0,
    this.blockedReason,
    this.temporaryObstacle = false,
    this.obstacleId,
  }) : baseCost = baseCost ?? length;

  factory RoadEdge.fromJson(Map<String, dynamic> json) {
    final meta = json['metadata'] as Map<String, dynamic>? ?? {};
    final len = (json['length'] as num? ?? json['distance'] as num? ?? 1.0).toDouble();
    return RoadEdge(
      id: json['id'] as String,
      fromId: json['from'] as String? ?? json['fromId'] as String? ?? json['fromNodeId'] as String? ?? '',
      toId: json['to'] as String? ?? json['toId'] as String? ?? json['toNodeId'] as String? ?? '',
      bidirectional: json['bidirectional'] as bool? ?? true,
      length: len,
      blocked: json['blocked'] as bool? ?? json['isBlocked'] as bool? ?? false,
      fromName: meta['from_name'] as String? ?? json['fromName'] as String? ?? '',
      toName: meta['to_name'] as String? ?? json['toName'] as String? ?? '',
      metadata: meta,
      baseCost: (json['baseCost'] as num?)?.toDouble() ?? len,
      terrainType: json['terrainType'] as String? ?? (meta['terrain'] as String? ?? 'trail'),
      difficulty: (json['difficulty'] as num?)?.toDouble() ?? 1.0,
      adventureValue: (json['adventureValue'] as num?)?.toDouble() ?? 1.0,
      blockedReason: json['blockedReason'] as String?,
      temporaryObstacle: json['temporaryObstacle'] as bool? ?? false,
      obstacleId: json['obstacleId'] as String?,
    );
  }

  RoadEdge copyWith({
    bool? blocked,
    String? blockedReason,
    bool? temporaryObstacle,
    String? obstacleId,
  }) {
    return RoadEdge(
      id: id,
      fromId: fromId,
      toId: toId,
      bidirectional: bidirectional,
      length: length,
      blocked: blocked ?? this.blocked,
      fromName: fromName,
      toName: toName,
      metadata: metadata,
      baseCost: baseCost,
      terrainType: terrainType,
      difficulty: difficulty,
      adventureValue: adventureValue,
      blockedReason: blockedReason ?? this.blockedReason,
      temporaryObstacle: temporaryObstacle ?? this.temporaryObstacle,
      obstacleId: obstacleId ?? this.obstacleId,
    );
  }
}

enum NavigationRouteStatus {
  normal,
  swiperDetected,
  rerouting,
  rerouted,
  noAlternativeRoute,
}

enum MapCameraMode {
  worldOverview,
  routePreview,
  activeNavigation,
  rerouting,
  newRoute,
  arrived,
}

class NavigationRoute {
  final List<LocationNode> nodes;
  final double totalDistance;
  final int etaMinutes;
  final bool isAlternative;
  final String nextInstruction;
  final double nextDistanceMeters;

  const NavigationRoute({
    required this.nodes,
    required this.totalDistance,
    required this.etaMinutes,
    this.isAlternative = false,
    required this.nextInstruction,
    required this.nextDistanceMeters,
  });

  bool get isEmpty => nodes.isEmpty;
  List<LocationNode> get path => nodes;
  LocationNode? get destination => nodes.isNotEmpty ? nodes.last : null;
  List<String> get locationIds => nodes.map((n) => n.id).toList();
  List<String> get nodeNames => nodes.map((n) => n.name).toList();
  double get totalDistanceKm => totalDistance;
  int get estimatedMinutes => etaMinutes;
  bool containsNode(String nodeId) => nodes.any((n) => n.id == nodeId);

  /// Computes the bounding box of the route coordinates in world space (minX, maxX, minY, maxY)
  math.Rectangle<double> computeBoundingBox({double margin = 12.0}) {
    if (nodes.isEmpty) return const math.Rectangle<double>(0, 0, 200, 200);

    double minX = nodes.first.x;
    double maxX = nodes.first.x;
    double minY = nodes.first.y;
    double maxY = nodes.first.y;

    for (final node in nodes) {
      if (node.x < minX) minX = node.x;
      if (node.x > maxX) maxX = node.x;
      if (node.y < minY) minY = node.y;
      if (node.y > maxY) maxY = node.y;
    }

    final double width = (maxX - minX + margin * 2).clamp(20.0, 200.0);
    final double height = (maxY - minY + margin * 2).clamp(20.0, 200.0);
    final double left = (minX - margin).clamp(0.0, 200.0 - width);
    final double top = (minY - margin).clamp(0.0, 200.0 - height);

    return math.Rectangle<double>(left, top, width, height);
  }

  /// Replaces the remaining route after `fromIndex` with `newRemainingNodes`
  NavigationRoute spliceRemaining({
    required int fromIndex,
    required List<LocationNode> newRemainingNodes,
    required double totalNewDistance,
    required int totalNewEta,
    required String newInstruction,
    required double newDistanceMeters,
  }) {
    final travelled = fromIndex > 0 ? nodes.sublist(0, fromIndex) : <LocationNode>[];
    final combined = [...travelled, ...newRemainingNodes];
    return NavigationRoute(
      nodes: combined,
      totalDistance: totalNewDistance,
      etaMinutes: totalNewEta,
      isAlternative: true,
      nextInstruction: newInstruction,
      nextDistanceMeters: newDistanceMeters,
    );
  }
}

class SwiperState {
  final String? currentLocationId;
  final String? previousLocationId;
  final bool active;
  final String riskLevel; // 'None', 'Low', 'Medium', 'High'
  final String? affectedRoadId;
  final double distanceFromUser;
  final double distanceFromRoute;

  const SwiperState({
    this.currentLocationId,
    this.previousLocationId,
    this.active = false,
    this.riskLevel = 'None',
    this.affectedRoadId,
    this.distanceFromUser = double.infinity,
    this.distanceFromRoute = double.infinity,
  });

  SwiperState copyWith({
    String? currentLocationId,
    String? previousLocationId,
    bool? active,
    String? riskLevel,
    String? affectedRoadId,
    double? distanceFromUser,
    double? distanceFromRoute,
  }) {
    return SwiperState(
      currentLocationId: currentLocationId ?? this.currentLocationId,
      previousLocationId: previousLocationId ?? this.previousLocationId,
      active: active ?? this.active,
      riskLevel: riskLevel ?? this.riskLevel,
      affectedRoadId: affectedRoadId ?? this.affectedRoadId,
      distanceFromUser: distanceFromUser ?? this.distanceFromUser,
      distanceFromRoute: distanceFromRoute ?? this.distanceFromRoute,
    );
  }
}

class SwiperHazard {
  final String roadId;
  final String locationName;
  final String warning;
  final String riskLevel; // 'Low', 'Medium', 'High'
  final bool isActive;

  const SwiperHazard({
    required this.roadId,
    required this.locationName,
    required this.warning,
    this.riskLevel = 'Low Risk',
    this.isActive = true,
  });
}
