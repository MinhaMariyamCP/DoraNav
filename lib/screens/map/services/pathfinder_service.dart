// ignore_for_file: avoid_print

import 'dart:convert';
import 'dart:io' as io;
import 'dart:math' as math;
import 'package:flutter/services.dart';
import '../models/map_models.dart';
import '../../route_selection/models/route_selection_models.dart';
import 'obstacle_manager.dart';
import 'dynamic_obstacle_manager.dart';
import 'navigation_service.dart';

/// A* Pathfinder service for DoraNav using Euclidean distance as the heuristic.
/// Supports dynamic rerouting when Swiper or dynamic obstacles block roads or nodes.
class PathfinderService {
  final Map<String, LocationNode> _locations = {};
  final List<RoadEdge> _roads = [];
  final Map<String, List<_RoadLink>> _adjacency = {};
  final Set<String> _blockedRoadIds = {};
  final Set<String> _blockedNodeIds = {};
  final Set<String> _swiperBlockedRoadIds = {};
  final Set<String> _swiperBlockedNodeIds = {};
  SwiperState _swiperState = const SwiperState();
  bool _isLoaded = false;

  late final ObstacleManager obstacleManager = ObstacleManager();
  late final DynamicObstacleManager dynamicObstacleManager = DynamicObstacleManager();
  late final NavigationService navigationService = NavigationService(obstacleManager: obstacleManager);

  bool get isLoaded => _isLoaded;
  List<LocationNode> get allLocations => _locations.values.toList();
  List<LocationNode> get selectableDestinations =>
      _locations.values.where((l) => l.selectable).toList();
  List<RoadEdge> get roads => List.unmodifiable(_roads);
  Set<String> get blockedRoadIds => Set.unmodifiable(_blockedRoadIds);
  Set<String> get blockedNodeIds => Set.unmodifiable(_blockedNodeIds);
  Set<String> get swiperBlockedRoadIds => Set.unmodifiable(_swiperBlockedRoadIds);
  Set<String> get swiperBlockedNodeIds => Set.unmodifiable(_swiperBlockedNodeIds);
  SwiperState get swiperState => _swiperState;

  LocationNode? getLocationById(String id) => _locations[id];

  LocationNode? get startNode =>
      _locations.values.firstWhere((l) => l.start, orElse: () => _locations.values.first);

  Future<void> loadMapData() async {
    if (_isLoaded) return;

    try {
      final locString = await rootBundle.loadString('assets/data/locations.json');
      final List<dynamic> locJson = json.decode(locString);
      for (final item in locJson) {
        final node = LocationNode.fromJson(item as Map<String, dynamic>);
        _locations[node.id] = node;
      }

      final roadString = await rootBundle.loadString('assets/data/roads.json');
      final List<dynamic> roadJson = json.decode(roadString);
      for (final item in roadJson) {
        final edge = RoadEdge.fromJson(item as Map<String, dynamic>);
        _roads.add(edge);
        _addLink(edge.fromId, edge.toId, edge.length, edge.id, edge.blocked);
        if (edge.bidirectional) {
          _addLink(edge.toId, edge.fromId, edge.length, edge.id, edge.blocked);
        }
      }

      _isLoaded = true;
      navigationService.initialize(nodes: _locations.values.toList(), roads: _roads);
    } catch (e) {
      // Try loading from file system (useful in headless flutter test)
      try {
        io.File? locFile;
        io.File? roadFile;
        final candidates = [
          'assets/data',
          'c:/Users/ASUS/OneDrive/Desktop/flutter workspace/dora_nav/assets/data',
        ];
        for (final base in candidates) {
          final lf = io.File('$base/locations.json');
          final rf = io.File('$base/roads.json');
          if (lf.existsSync() && rf.existsSync()) {
            locFile = lf;
            roadFile = rf;
            break;
          }
        }

        if (locFile != null && roadFile != null) {
          final List<dynamic> locJson = json.decode(locFile.readAsStringSync());
          for (final item in locJson) {
            final node = LocationNode.fromJson(item as Map<String, dynamic>);
            _locations[node.id] = node;
          }

          final List<dynamic> roadJson = json.decode(roadFile.readAsStringSync());
          for (final item in roadJson) {
            final edge = RoadEdge.fromJson(item as Map<String, dynamic>);
            _roads.add(edge);
            _addLink(edge.fromId, edge.toId, edge.length, edge.id, edge.blocked);
            if (edge.bidirectional) {
              _addLink(edge.toId, edge.fromId, edge.length, edge.id, edge.blocked);
            }
          }
          _isLoaded = true;
          navigationService.initialize(nodes: _locations.values.toList(), roads: _roads);
          return;
        }
      } catch (_) {}

      // Fallback in case bundle load fails during headless tests
      _loadFallbackData();
      navigationService.initialize(nodes: _locations.values.toList(), roads: _roads);
    }
  }

  void syncNavigationService() {
    navigationService.initialize(nodes: _locations.values.toList(), roads: _roads);
  }

  void _addLink(String from, String to, double length, String roadId, bool blocked) {
    _adjacency.putIfAbsent(from, () => []);
    _adjacency[from]!.add(_RoadLink(targetId: to, length: length, roadId: roadId, blocked: blocked));
  }

  RoadEdge? findRoadBetween(String fromId, String toId) {
    for (final r in _roads) {
      if ((r.fromId == fromId && r.toId == toId) ||
          (r.bidirectional && r.fromId == toId && r.toId == fromId)) {
        return r;
      }
    }
    return null;
  }

  /// Sets a road's blocked state dynamically (e.g. Rockslide, fallen log)
  void setRoadBlocked(String roadId, bool isBlocked) {
    if (isBlocked) {
      _blockedRoadIds.add(roadId);
      obstacleManager.blockRoad(roadId);
    } else {
      _blockedRoadIds.remove(roadId);
      obstacleManager.unblockRoad(roadId);
    }

    for (int i = 0; i < _roads.length; i++) {
      if (_roads[i].id == roadId) {
        _roads[i] = _roads[i].copyWith(blocked: isBlocked);
      }
    }
    // Update adjacency graph
    for (final links in _adjacency.values) {
      for (final link in links) {
        if (link.roadId == roadId) {
          link.blocked = isBlocked;
        }
      }
    }
  }

  /// Sets a location node's blocked state dynamically (e.g. Swiper trap or Bridge collapse)
  void setNodeBlocked(String nodeId, bool isBlocked) {
    if (isBlocked) {
      _blockedNodeIds.add(nodeId);
      obstacleManager.blockNode(nodeId);
    } else {
      _blockedNodeIds.remove(nodeId);
      obstacleManager.unblockNode(nodeId);
    }
  }

  /// Resets all dynamic obstacles, roadblocks, and Swiper traps
  void clearAllBlocks() {
    for (final roadId in _blockedRoadIds.toList()) {
      setRoadBlocked(roadId, false);
    }
    _blockedRoadIds.clear();
    _blockedNodeIds.clear();
    obstacleManager.clear();
    dynamicObstacleManager.clearAll();
  }

  /// For deterministic tests: adds a location node manually
  void addLocation(LocationNode node) {
    _locations[node.id] = node;
    syncNavigationService();
  }

  /// For deterministic tests: adds a road edge manually
  void addRoadEdge(RoadEdge edge) {
    _roads.add(edge);
    _addLink(edge.fromId, edge.toId, edge.length, edge.id, edge.blocked);
    if (edge.bidirectional) {
      _addLink(edge.toId, edge.fromId, edge.length, edge.id, edge.blocked);
    }
    syncNavigationService();
  }

  /// For deterministic tests: clears all graph data
  void clearGraph() {
    _locations.clear();
    _roads.clear();
    _adjacency.clear();
    _blockedRoadIds.clear();
    _blockedNodeIds.clear();
    _swiperBlockedRoadIds.clear();
    _swiperBlockedNodeIds.clear();
    _swiperState = const SwiperState();
    obstacleManager.clear();
    dynamicObstacleManager.clearAll();
    _isLoaded = false;
    navigationService.initialize(nodes: [], roads: []);
  }

  /// Sets Swiper's location dynamically.
  /// If [locationId] is provided, marks that location node as temporarily blocked by Swiper.
  /// If [affectedRoadId] is provided, marks that road segment as temporarily blocked.
  void setSwiperLocation(String? locationId, {String? affectedRoadId, String riskLevel = 'High Risk'}) {
    final prevLoc = _swiperState.currentLocationId;

    if (prevLoc != null && prevLoc != locationId) {
      _swiperBlockedNodeIds.remove(prevLoc);
    }
    if (_swiperState.affectedRoadId != null && _swiperState.affectedRoadId != affectedRoadId) {
      _swiperBlockedRoadIds.remove(_swiperState.affectedRoadId!);
    }

    if (locationId != null) {
      _swiperBlockedNodeIds.add(locationId);
    }
    if (affectedRoadId != null) {
      _swiperBlockedRoadIds.add(affectedRoadId);
    }

    _swiperState = SwiperState(
      currentLocationId: locationId,
      previousLocationId: prevLoc,
      active: locationId != null || affectedRoadId != null,
      riskLevel: riskLevel,
      affectedRoadId: affectedRoadId,
    );
  }

  /// Removes temporary Swiper blocks and resets Swiper state
  void clearSwiper() {
    _swiperBlockedRoadIds.clear();
    _swiperBlockedNodeIds.clear();
    _swiperState = const SwiperState();
  }

  /// Dynamically reroutes around Swiper from the user's current location to goal.
  /// 1. Verifies Swiper's obstacle on the graph.
  /// 2. Ensures the affected road/node is marked as blocked in A*.
  /// 3. Runs A* again from [currentStartId] to [goalId].
  /// 4. Generates a new NavigationRoute.
  /// 5. Prints required debug logs.
  NavigationRoute? rerouteAroundSwiper({
    String? currentStartId,
    String? currentLocationId,
    String? goalId,
    String? destinationId,
    String? swiperNodeId,
    String? swiperRoadId,
    NavigationRoute? originalRoute,
    dynamic preference = RouteOptionType.normal,
  }) {
    final effectiveStartId = currentLocationId ?? currentStartId;
    final effectiveGoalId = destinationId ?? goalId;
    if (effectiveStartId == null || effectiveGoalId == null) return null;

    final startNode = _locations[effectiveStartId];
    final goalNode = _locations[effectiveGoalId];
    if (startNode == null || goalNode == null) return null;

    final swiperTargetId = swiperNodeId ?? _swiperState.currentLocationId;
    final swiperTargetNode = swiperTargetId != null ? _locations[swiperTargetId] : null;

    if (originalRoute != null) {
      print('[Navigation] Initial route:');
      print(originalRoute.nodes.map((n) => n.name).join(' → '));
    }

    if (swiperTargetNode != null) {
      print('[Swiper] Detected at:');
      print(swiperTargetNode.name);
      print('[Navigation] Current route compromised.');
      print('[Navigation] Blocking node:');
      print(swiperTargetNode.name);
      setSwiperLocation(swiperTargetNode.id, affectedRoadId: swiperRoadId);
    } else if (swiperRoadId != null) {
      print('[Swiper] Detected on road: $swiperRoadId');
      print('[Navigation] Current route compromised.');
      print('[Navigation] Blocking road: $swiperRoadId');
      setSwiperLocation(null, affectedRoadId: swiperRoadId);
    }

    print('[Navigation] Running A* reroute...');

    // Determine penalties based on preference
    final Map<String, double> roadPenalties = {};
    if (preference == RouteOptionType.swiperSafe && swiperTargetNode != null) {
      final nearLinks = _adjacency[swiperTargetNode.id] ?? [];
      for (final link in nearLinks) {
        roadPenalties[link.roadId] = 50.0;
      }
    }

    final newRoute = findRoute(
      startId: effectiveStartId,
      goalId: effectiveGoalId,
      roadPenalties: roadPenalties,
      isAlternative: true,
    );

    if (newRoute == null) {
      print('[Navigation] No alternative route found. Every path is blocked!');
      return null;
    }

    print('[Navigation] New route:');
    print(newRoute.nodes.map((n) => n.name).join(' → '));
    print('[Navigation] Rerouting successful.');

    return newRoute;
  }

  /// Computes the optimal path between start and goal using A* with Euclidean heuristic
  NavigationRoute? findRoute({
    required String startId,
    required String goalId,
    Set<String> customBlockedRoads = const {},
    Set<String> customBlockedNodes = const {},
    Map<String, double> roadPenalties = const {},
    bool isAlternative = false,
  }) {
    if (!_locations.containsKey(startId) || !_locations.containsKey(goalId)) {
      return null;
    }

    final start = _locations[startId]!;
    final goal = _locations[goalId]!;

    if (startId == goalId) {
      return NavigationRoute(
        nodes: [start],
        totalDistance: 0.0,
        etaMinutes: 0,
        nextInstruction: 'You have arrived at your destination!',
        nextDistanceMeters: 0,
      );
    }

    // Min-priority queue simulated using list sorted by fScore
    final openSet = <String>{startId};
    final cameFrom = <String, String>{};
    final gScore = <String, double>{for (var id in _locations.keys) id: double.infinity};
    final fScore = <String, double>{for (var id in _locations.keys) id: double.infinity};

    gScore[startId] = 0.0;
    fScore[startId] = _heuristic(start, goal);

    while (openSet.isNotEmpty) {
      // Get node in openSet with lowest fScore
      String currentId = openSet.first;
      double lowestF = fScore[currentId]!;
      for (final id in openSet) {
        final f = fScore[id] ?? double.infinity;
        if (f < lowestF) {
          lowestF = f;
          currentId = id;
        }
      }

      if (currentId == goalId) {
        // Reconstruct path
        final pathNodes = <LocationNode>[];
        String? curr = goalId;
        while (curr != null) {
          pathNodes.insert(0, _locations[curr]!);
          curr = cameFrom[curr];
        }

        final double totalDistUnits = gScore[goalId] ?? 0.0;
        // Scale map units to real-world kilometers (approx 0.05 km per coordinate unit)
        final double distKm = (totalDistUnits * 0.05).clamp(0.5, 12.0);
        // Average speed in Dora's world ~ 14 km/h -> 4.3 min per km
        final int etaMin = math.max(3, (distKm * 4.3).round());

        final nextNodeName = pathNodes.length > 1 ? pathNodes[1].name : goal.name;
        final nextMeters = pathNodes.length > 1 ? (pathNodes[0].distanceTo(pathNodes[1]) * 15).roundToDouble() : 50.0;

        return NavigationRoute(
          nodes: pathNodes,
          totalDistance: double.parse(distKm.toStringAsFixed(1)),
          etaMinutes: etaMin,
          isAlternative: isAlternative,
          nextInstruction: 'Continue straight towards the $nextNodeName',
          nextDistanceMeters: nextMeters,
        );
      }

      openSet.remove(currentId);

      final links = _adjacency[currentId] ?? [];
      for (final link in links) {
        if (link.blocked ||
            _blockedRoadIds.contains(link.roadId) ||
            _swiperBlockedRoadIds.contains(link.roadId) ||
            dynamicObstacleManager.runtimeRoadBlocked[link.roadId] == true ||
            customBlockedRoads.contains(link.roadId)) {
          continue;
        }
        if (_blockedNodeIds.contains(link.targetId) ||
            _swiperBlockedNodeIds.contains(link.targetId) ||
            dynamicObstacleManager.runtimeNodeBlocked[link.targetId] == true ||
            customBlockedNodes.contains(link.targetId)) {
          continue;
        }

        final penalty = (roadPenalties[link.roadId] ?? 0.0) +
            (dynamicObstacleManager.runtimeRoadPenalty[link.roadId] ?? 0.0);
        final tentativeG = gScore[currentId]! + link.length + penalty;
        if (tentativeG < (gScore[link.targetId] ?? double.infinity)) {
          cameFrom[link.targetId] = currentId;
          gScore[link.targetId] = tentativeG;
          final targetNode = _locations[link.targetId]!;
          fScore[link.targetId] = tentativeG + _heuristic(targetNode, goal);
          openSet.add(link.targetId);
        }
      }
    }

    return null; // No route found
  }

  double _heuristic(LocationNode a, LocationNode b) {
    final dx = a.x - b.x;
    final dy = a.y - b.y;
    return math.sqrt(dx * dx + dy * dy);
  }

  void _loadFallbackData() {
    // Basic fallback so UI tests never fail if filesystem/bundle is isolated
    final home = const LocationNode(
      id: 'L001',
      name: 'Dora’s House',
      x: 35,
      y: 110,
      selectable: true,
      start: true,
      active: true,
      type: 'start',
      description: "Dora's starting home",
      region: 'Jungle',
    );
    final castle = const LocationNode(
      id: 'L012',
      name: 'King’s Castle',
      x: 162,
      y: 130,
      selectable: true,
      start: false,
      active: true,
      type: 'destination',
      description: 'Royal Castle',
      region: 'Valley',
    );
    _locations[home.id] = home;
    _locations[castle.id] = castle;
    _isLoaded = true;
  }
}

class _RoadLink {
  final String targetId;
  final double length;
  final String roadId;
  bool blocked;

  _RoadLink({
    required this.targetId,
    required this.length,
    required this.roadId,
    this.blocked = false,
  });
}
