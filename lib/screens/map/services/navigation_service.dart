// ignore_for_file: avoid_print

import 'dart:math' as math;
import '../models/map_models.dart';
import '../../route_selection/models/route_selection_models.dart';
import 'obstacle_manager.dart';

/// Link between adjacent nodes in the Dora World navigation graph
class _NavigationLink {
  final String targetNodeId;
  final RoadEdge edge;

  const _NavigationLink({
    required this.targetNodeId,
    required this.edge,
  });
}

/// Dynamic A* Navigation Engine for Dora World.
/// Supports many concurrent and sequential obstacles, event-driven A* search,
/// and continuous dynamic rerouting from the current user location.
class NavigationService {
  final ObstacleManager obstacleManager;

  final Map<String, LocationNode> _nodes = {};
  final List<RoadEdge> _roads = [];
  final Map<String, List<_NavigationLink>> _adjacency = {};
  final List<void Function(ActiveRoute?)> _subscribers = [];

  ActiveRoute? _activeRoute;
  String _currentNodeId = '';
  String _destinationNodeId = '';
  RouteOptionType _preference = RouteOptionType.normal;
  int _routeVersion = 0;

  NavigationService({ObstacleManager? obstacleManager})
      : obstacleManager = obstacleManager ?? ObstacleManager() {
    this.obstacleManager.addListener(_onObstacleManagerChanged);
  }

  ActiveRoute? get activeRoute => _activeRoute;
  int get routeVersion => _routeVersion;
  String get currentNodeId => _currentNodeId;
  String get destinationNodeId => _destinationNodeId;
  RouteOptionType get routePreference => _preference;
  List<LocationNode> get allNodes => _nodes.values.toList();
  List<RoadEdge> get allRoads => List.unmodifiable(_roads);

  /// Initializes the navigation graph with locations and road edges
  void initialize({
    required List<LocationNode> nodes,
    required List<RoadEdge> roads,
  }) {
    _nodes.clear();
    _roads.clear();
    _adjacency.clear();

    for (final node in nodes) {
      _nodes[node.id] = node;
    }

    for (final road in roads) {
      _roads.add(road);
      _adjacency.putIfAbsent(road.fromId, () => []);
      _adjacency[road.fromId]!.add(
        _NavigationLink(targetNodeId: road.toId, edge: road),
      );
      if (road.bidirectional) {
        _adjacency.putIfAbsent(road.toId, () => []);
        _adjacency[road.toId]!.add(
          _NavigationLink(targetNodeId: road.fromId, edge: road),
        );
      }
    }

    print('[GRAPH] Loaded ${_nodes.length} nodes and ${_roads.length} roads.');
  }

  /// Starts navigation from startNodeId to destinationNodeId with routePreference
  ActiveRoute? startNavigation(
    String startNodeId,
    String destinationNodeId,
    RouteOptionType preference,
  ) {
    _currentNodeId = startNodeId;
    _destinationNodeId = destinationNodeId;
    _preference = preference;
    _routeVersion = 1;

    final route = findRoute(
      startNodeId,
      destinationNodeId,
      preference,
      currentUserNodeId: startNodeId,
      version: _routeVersion,
    );

    _activeRoute = route;

    if (route != null) {
      print('[A*] Route found: ${route.nodeNames.join(' → ')}');
      print('[MAP] Active route updated. routeVersion=$_routeVersion');
      _notifySubscribers(route);
    } else {
      print('[A*] No route available');
      _notifySubscribers(null);
    }

    return route;
  }

  /// Subscribes to route updates
  void subscribeToRouteUpdates(void Function(ActiveRoute?) callback) {
    _subscribers.add(callback);
  }

  /// Unsubscribes from route updates
  void unsubscribeFromRouteUpdates(void Function(ActiveRoute?) callback) {
    _subscribers.remove(callback);
  }

  void _notifySubscribers(ActiveRoute? route) {
    for (final sub in List.of(_subscribers)) {
      sub(route);
    }
  }

  /// Returns current active route
  ActiveRoute? getActiveRoute() => _activeRoute;

  /// Updates current user location node during navigation and recalculates remaining distance
  void updateCurrentLocation(String nodeId) {
    if (_currentNodeId == nodeId) return;
    _currentNodeId = nodeId;

    if (_activeRoute != null) {
      final nodeIdx = _activeRoute!.nodes.indexWhere((n) => n.id == nodeId);
      if (nodeIdx != -1) {
        // Recalculate remaining distance from current node
        double remaining = 0.0;
        for (int i = nodeIdx; i < _activeRoute!.edges.length; i++) {
          remaining += _activeRoute!.edges[i].length;
        }
        final double distKm = (remaining * 0.05).clamp(0.1, 999.0);
        final int etaMin = math.max(1, (distKm * 4.3).round());

        _activeRoute = ActiveRoute(
          nodes: _activeRoute!.nodes,
          edges: _activeRoute!.edges,
          totalDistance: _activeRoute!.totalDistance,
          remainingDistance: double.parse(distKm.toStringAsFixed(1)),
          eta: Duration(minutes: etaMin),
          routePreference: _activeRoute!.routePreference,
          routeVersion: _activeRoute!.routeVersion,
          currentNodeId: nodeId,
          destinationNodeId: _activeRoute!.destinationNodeId,
          generatedAt: _activeRoute!.generatedAt,
          instructions: _activeRoute!.instructions,
        );
      } else {
        // User deviated from route -> trigger reroute
        rerouteIfNeeded();
      }
    }
  }

  /// Handles obstacle events (add, activate, deactivate, remove, move)
  void handleObstacleEvent(ObstacleEvent event) {
    final obs = event.obstacle;
    final targetDesc = obs.description ?? obs.type.name;
    final targetId = obs.locationNodeId ??
        obs.roadId ??
        (obs.affectedNodeIds.isNotEmpty
            ? obs.affectedNodeIds.join(', ')
            : obs.affectedRoadIds.join(', '));

    switch (event.action) {
      case ObstacleEventAction.add:
        obstacleManager.addObstacle(obs);
        if (obs.active) {
          print('[OBSTACLE] $targetDesc activated at $targetId');
        }
        break;
      case ObstacleEventAction.activate:
        obstacleManager.activateObstacle(obs.id);
        print('[OBSTACLE] $targetDesc activated at $targetId');
        break;
      case ObstacleEventAction.deactivate:
        obstacleManager.deactivateObstacle(obs.id);
        break;
      case ObstacleEventAction.remove:
        obstacleManager.removeObstacle(obs.id);
        break;
      case ObstacleEventAction.move:
        obstacleManager.moveObstacle(
          obs.id,
          locationNodeId: obs.locationNodeId,
          roadId: obs.roadId,
        );
        if (obs.active) {
          print('[OBSTACLE] $targetDesc activated at $targetId');
        }
        break;
    }

    rerouteIfNeeded();
  }

  void _onObstacleManagerChanged() {
    // Check validity whenever obstacle manager state updates
    rerouteIfNeeded();
  }

  /// Verifies whether the remaining path in the active route is free of obstacles
  bool checkRouteValidity() {
    if (_activeRoute == null || _activeRoute!.nodes.isEmpty) return false;

    final currentIdx = _activeRoute!.nodes.indexWhere((n) => n.id == _currentNodeId);
    final startIndex = currentIdx != -1 ? currentIdx : 0;

    // 1. Check all remaining upcoming nodes (excluding current user node to avoid impossible state)
    for (int i = startIndex + 1; i < _activeRoute!.nodes.length; i++) {
      final node = _activeRoute!.nodes[i];
      if (node.isBlocked || obstacleManager.isNodeBlocked(node.id)) {
        return false;
      }
    }

    // 2. Check all remaining upcoming edges
    for (int i = startIndex; i < _activeRoute!.edges.length; i++) {
      final edge = _activeRoute!.edges[i];
      if (edge.isBlocked || obstacleManager.isRoadBlocked(edge.id)) {
        return false;
      }
    }

    return true;
  }

  /// Evaluates active route validity and triggers rerouting if compromised
  bool rerouteIfNeeded() {
    if (_activeRoute == null) return false;

    if (!checkRouteValidity()) {
      print('[NAVIGATION] Current route invalid.');
      print('[NAVIGATION] Recalculating...');
      final newRoute = reroute();
      return newRoute != null;
    }

    return false;
  }

  /// Reroutes from the CURRENT user node to the destination
  ActiveRoute? reroute() {
    _routeVersion++;

    final newRoute = findRoute(
      _currentNodeId,
      _destinationNodeId,
      _preference,
      currentUserNodeId: _currentNodeId,
      version: _routeVersion,
    );

    _activeRoute = newRoute;

    if (newRoute != null) {
      print('[A*] Route found: ${newRoute.nodeNames.join(' → ')}');
      print('[MAP] Active route updated. routeVersion=$_routeVersion');
      _notifySubscribers(newRoute);
    } else {
      print('[A*] No route available');
      _notifySubscribers(null);
    }

    return newRoute;
  }

  /// Core A* pathfinding algorithm over the current Dora World graph
  ActiveRoute? findRoute(
    String startNodeId,
    String destinationNodeId,
    RouteOptionType preference, {
    String? currentUserNodeId,
    int? version,
  }) {
    if (!_nodes.containsKey(startNodeId) || !_nodes.containsKey(destinationNodeId)) {
      return null;
    }

    final start = _nodes[startNodeId]!;
    final goal = _nodes[destinationNodeId]!;

    print('[A*] Start: ${start.name}');
    print('[A*] Goal: ${goal.name}');

    if (startNodeId == destinationNodeId) {
      return ActiveRoute(
        nodes: [start],
        edges: const [],
        totalDistance: 0.0,
        remainingDistance: 0.0,
        eta: Duration.zero,
        routePreference: preference,
        routeVersion: version ?? _routeVersion,
        currentNodeId: startNodeId,
        destinationNodeId: destinationNodeId,
        generatedAt: DateTime.now(),
        instructions: const ['You have arrived at your destination!'],
      );
    }

    final openSet = <String>{startNodeId};
    final cameFrom = <String, String>{};
    final cameFromEdge = <String, RoadEdge>{};
    final gScore = <String, double>{for (var id in _nodes.keys) id: double.infinity};
    final fScore = <String, double>{for (var id in _nodes.keys) id: double.infinity};

    gScore[startNodeId] = 0.0;
    fScore[startNodeId] = _heuristic(start, goal);

    while (openSet.isNotEmpty) {
      // Find node with lowest fScore in openSet
      String currentId = openSet.first;
      double lowestF = fScore[currentId]!;
      for (final id in openSet) {
        final f = fScore[id] ?? double.infinity;
        if (f < lowestF) {
          lowestF = f;
          currentId = id;
        }
      }

      if (currentId == destinationNodeId) {
        // Goal reached: reconstruct path
        final pathNodes = <LocationNode>[];
        final pathEdges = <RoadEdge>[];
        String? curr = destinationNodeId;

        while (curr != null) {
          pathNodes.insert(0, _nodes[curr]!);
          final edge = cameFromEdge[curr];
          if (edge != null) {
            pathEdges.insert(0, edge);
          }
          curr = cameFrom[curr];
        }

        double totalDistRaw = 0.0;
        for (final edge in pathEdges) {
          totalDistRaw += edge.length;
        }

        // Distance & ETA calculation
        final double distKm = (totalDistRaw * 0.05).clamp(0.5, 999.0);
        final int etaMin = math.max(1, (distKm * 4.3).round());

        // Step instructions
        final instructions = <String>[];
        for (int i = 0; i < pathNodes.length - 1; i++) {
          final from = pathNodes[i];
          final to = pathNodes[i + 1];
          instructions.add('From ${from.name}, head towards ${to.name}');
        }
        instructions.add('Arrive at ${goal.name}!');

        return ActiveRoute(
          nodes: pathNodes,
          edges: pathEdges,
          totalDistance: double.parse(distKm.toStringAsFixed(1)),
          remainingDistance: double.parse(distKm.toStringAsFixed(1)),
          eta: Duration(minutes: etaMin),
          routePreference: preference,
          routeVersion: version ?? _routeVersion,
          currentNodeId: startNodeId,
          destinationNodeId: destinationNodeId,
          generatedAt: DateTime.now(),
          instructions: instructions,
        );
      }

      openSet.remove(currentId);

      final links = _adjacency[currentId] ?? [];
      for (final link in links) {
        final edge = link.edge;
        final targetId = link.targetNodeId;
        final targetNode = _nodes[targetId];
        if (targetNode == null) continue;

        // Skip fully blocked edges completely
        if (edge.isBlocked || obstacleManager.isRoadBlocked(edge.id)) {
          continue;
        }

        // Skip fully blocked nodes, EXCEPT if it's the current user node (avoid impossible state)
        if (targetId != currentUserNodeId) {
          if (targetNode.isBlocked || obstacleManager.isNodeBlocked(targetId)) {
            continue;
          }
        }

        // Effective cost calculation
        final double baseDistance = edge.length;
        final double difficultyPenalty = (edge.difficulty - 1.0).clamp(0.0, 5.0) * 0.2;
        final double obstaclePenalty = obstacleManager.getRoadPenalty(edge.id) +
            obstacleManager.getNodePenalty(targetId);

        double preferencePenalty = 0.0;
        if (preference == RouteOptionType.swiperSafe) {
          final isNearSwiper = obstacleManager.getActiveObstacles().any((o) =>
              o.type == ObstacleType.swiper &&
              (o.affectedRoadIds.contains(edge.id) ||
                  o.affectedNodeIds.contains(targetId) ||
                  o.locationNodeId == targetId ||
                  o.roadId == edge.id));
          if (isNearSwiper) {
            preferencePenalty += 50.0;
          }
        } else if (preference == RouteOptionType.bootsRoute) {
          if (edge.difficulty > 2.0) {
            preferencePenalty += 15.0; // Avoid steep/rough climbs
          }
        } else if (preference == RouteOptionType.mostAdventurous) {
          preferencePenalty += (5.0 - edge.adventureValue).clamp(0.0, 5.0);
        }

        final double effectiveCost =
            baseDistance + difficultyPenalty + obstaclePenalty + preferencePenalty;
        final double tentativeG = gScore[currentId]! + effectiveCost;

        if (tentativeG < (gScore[targetId] ?? double.infinity)) {
          cameFrom[targetId] = currentId;
          cameFromEdge[targetId] = edge;
          gScore[targetId] = tentativeG;
          fScore[targetId] = tentativeG + _heuristic(targetNode, goal);
          openSet.add(targetId);
        }
      }
    }

    return null; // NO_ROUTE_AVAILABLE
  }

  /// Euclidean distance heuristic in Dora World 2D coordinate space
  double _heuristic(LocationNode a, LocationNode b) {
    final dx = a.x - b.x;
    final dy = a.y - b.y;
    return math.sqrt(dx * dx + dy * dy);
  }
}
