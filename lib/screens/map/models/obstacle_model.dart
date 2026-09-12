import 'dart:math' as math;
import 'map_models.dart';
import '../../route_selection/models/route_selection_models.dart';

/// Supported obstacle types in Dora World.
enum ObstacleType {
  swiper,
  crocodile,
  fallenStone,
  blockedBridge,
  blockedRoad,
  dangerousArea,
}

/// Actions for obstacle lifecycle events.
enum ObstacleEventAction {
  add,
  activate,
  deactivate,
  remove,
  move,
}

/// Represents an active or potential hazard on the Dora World graph.
/// Hard obstacles set [blocksNode] or [blocksRoad] to true.
/// Soft obstacles apply an additive [penalty] to edge effectiveCost.
class Obstacle {
  final String id;
  final ObstacleType type;
  final List<String> affectedNodeIds;
  final List<String> affectedRoadIds;
  final bool active;
  final double severity; // 0.0 to 1.0 or scale
  final bool blocksNode;
  final bool blocksRoad;
  final double penalty; // Added to effectiveCost if soft
  final String? description;
  final String? locationNodeId; // For single-node obstacles
  final String? roadId; // For single-edge obstacles
  final bool isDynamic; // Whether moving (e.g., Swiper)

  const Obstacle({
    required this.id,
    required this.type,
    this.affectedNodeIds = const [],
    this.affectedRoadIds = const [],
    this.active = true,
    this.severity = 1.0,
    this.blocksNode = false,
    this.blocksRoad = false,
    this.penalty = 0.0,
    this.description,
    this.locationNodeId,
    this.roadId,
    this.isDynamic = false,
  });

  bool get dynamicObstacle => isDynamic;

  Obstacle copyWith({
    String? id,
    ObstacleType? type,
    List<String>? affectedNodeIds,
    List<String>? affectedRoadIds,
    bool? active,
    double? severity,
    bool? blocksNode,
    bool? blocksRoad,
    double? penalty,
    String? description,
    String? locationNodeId,
    String? roadId,
    bool? isDynamic,
  }) {
    return Obstacle(
      id: id ?? this.id,
      type: type ?? this.type,
      affectedNodeIds: affectedNodeIds ?? this.affectedNodeIds,
      affectedRoadIds: affectedRoadIds ?? this.affectedRoadIds,
      active: active ?? this.active,
      severity: severity ?? this.severity,
      blocksNode: blocksNode ?? this.blocksNode,
      blocksRoad: blocksRoad ?? this.blocksRoad,
      penalty: penalty ?? this.penalty,
      description: description ?? this.description,
      locationNodeId: locationNodeId ?? this.locationNodeId,
      roadId: roadId ?? this.roadId,
      isDynamic: isDynamic ?? this.isDynamic,
    );
  }

  Map<String, dynamic> toJson() => {
    'id': id,
    'type': type.name,
    'affectedNodeIds': affectedNodeIds,
    'affectedRoadIds': affectedRoadIds,
    'active': active,
    'severity': severity,
    'blocksNode': blocksNode,
    'blocksRoad': blocksRoad,
    'penalty': penalty,
    'description': description,
    'locationNodeId': locationNodeId,
    'roadId': roadId,
    'dynamic': isDynamic,
  };

  factory Obstacle.fromJson(Map<String, dynamic> json) {
    ObstacleType parseType(String? val) {
      if (val == null) return ObstacleType.blockedRoad;
      return ObstacleType.values.firstWhere(
        (t) => t.name.toLowerCase() == val.toLowerCase(),
        orElse: () => ObstacleType.blockedRoad,
      );
    }

    final locId = json['locationNodeId'] as String?;
    final rId = json['roadId'] as String? ?? json['affectedRoadId'] as String?;

    final nodesList = (json['affectedNodeIds'] as List<dynamic>?)
            ?.map((e) => e.toString())
            .toList() ??
        (locId != null ? [locId] : <String>[]);
    final roadsList = (json['affectedRoadIds'] as List<dynamic>?)
            ?.map((e) => e.toString())
            .toList() ??
        (rId != null ? [rId] : <String>[]);

    return Obstacle(
      id: json['id'] as String,
      type: parseType(json['type'] as String?),
      affectedNodeIds: nodesList,
      affectedRoadIds: roadsList,
      active: json['active'] as bool? ?? true,
      severity: (json['severity'] as num?)?.toDouble() ?? 1.0,
      blocksNode: json['blocksNode'] as bool? ?? false,
      blocksRoad: json['blocksRoad'] as bool? ?? false,
      penalty: (json['penalty'] as num?)?.toDouble() ?? 0.0,
      description: json['description'] as String?,
      locationNodeId: locId,
      roadId: rId,
      isDynamic: json['dynamic'] as bool? ?? false,
    );
  }
}

/// Event representing obstacle lifecycle updates.
class ObstacleEvent {
  final ObstacleEventAction action;
  final Obstacle obstacle;
  final DateTime timestamp;

  ObstacleEvent({
    required this.action,
    required this.obstacle,
    DateTime? timestamp,
  }) : timestamp = timestamp ?? DateTime.now();
}

/// Active route object describing current path, remaining distance, ETA, and version.
class ActiveRoute {
  final List<LocationNode> nodes;
  final List<RoadEdge> edges;
  final double totalDistance;
  final double remainingDistance;
  final Duration eta;
  final RouteOptionType routePreference;
  final int routeVersion;
  final String currentNodeId;
  final String destinationNodeId;
  final DateTime generatedAt;
  final List<String> instructions;

  const ActiveRoute({
    required this.nodes,
    required this.edges,
    required this.totalDistance,
    required this.remainingDistance,
    required this.eta,
    required this.routePreference,
    required this.routeVersion,
    required this.currentNodeId,
    required this.destinationNodeId,
    required this.generatedAt,
    this.instructions = const [],
  });

  bool get isEmpty => nodes.isEmpty;
  int get etaMinutes => (eta.inSeconds / 60).round();
  List<String> get nodeIds => nodes.map((n) => n.id).toList();
  List<String> get roadIds => edges.map((e) => e.id).toList();
  List<String> get nodeNames => nodes.map((n) => n.name).toList();

  NavigationRoute toNavigationRoute() {
    return NavigationRoute(
      nodes: nodes,
      totalDistance: totalDistance,
      etaMinutes: math.max(1, etaMinutes),
      isAlternative: routeVersion > 1,
      nextInstruction: instructions.isNotEmpty
          ? instructions.first
          : (nodes.length > 1
              ? 'Head towards ${nodes[1].name}'
              : 'You have reached your destination!'),
      nextDistanceMeters: edges.isNotEmpty
          ? (edges.first.length * 100).roundToDouble()
          : 0.0,
    );
  }
}
