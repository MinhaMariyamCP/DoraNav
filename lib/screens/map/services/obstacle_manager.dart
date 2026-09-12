import '../models/obstacle_model.dart';

/// ObstacleManager maintains the real-time status of all obstacles (both soft and hard)
/// affecting Dora World nodes and roads.
///
/// Changes to obstacles notify listeners so that NavigationService and the Map UI
/// can respond immediately with validity checks and dynamic rerouting.
class ObstacleManager {
  final Map<String, Obstacle> _obstacles = {};
  final Set<String> _manuallyBlockedNodes = {};
  final Set<String> _manuallyBlockedRoads = {};
  final Map<String, String> _nodeBlockReasons = {};
  final Map<String, String> _roadBlockReasons = {};
  final List<void Function()> _listeners = [];

  void addListener(void Function() listener) => _listeners.add(listener);
  void removeListener(void Function() listener) => _listeners.remove(listener);

  void _notifyListeners() {
    for (final listener in List.of(_listeners)) {
      listener();
    }
  }

  /// Adds a new obstacle to the manager
  void addObstacle(Obstacle obstacle) {
    _obstacles[obstacle.id] = obstacle;
    _notifyListeners();
  }

  /// Removes an obstacle by id
  void removeObstacle(String obstacleId) {
    _obstacles.remove(obstacleId);
    _notifyListeners();
  }

  /// Activates an existing obstacle
  void activateObstacle(String obstacleId) {
    final obs = _obstacles[obstacleId];
    if (obs != null) {
      _obstacles[obstacleId] = obs.copyWith(active: true);
      _notifyListeners();
    }
  }

  /// Deactivates an existing obstacle
  void deactivateObstacle(String obstacleId) {
    final obs = _obstacles[obstacleId];
    if (obs != null) {
      _obstacles[obstacleId] = obs.copyWith(active: false);
      _notifyListeners();
    }
  }

  /// Returns all currently active obstacles
  List<Obstacle> getActiveObstacles() {
    return _obstacles.values.where((o) => o.active).toList();
  }

  /// Returns a list of road IDs affected by active obstacles or manual blocks
  List<String> getAffectedEdges() {
    final edges = <String>{..._manuallyBlockedRoads};
    for (final obs in getActiveObstacles()) {
      edges.addAll(obs.affectedRoadIds);
      if (obs.roadId != null) edges.add(obs.roadId!);
    }
    return edges.toList();
  }

  /// Returns a list of node IDs affected by active obstacles or manual blocks
  List<String> getAffectedNodes() {
    final nodes = <String>{..._manuallyBlockedNodes};
    for (final obs in getActiveObstacles()) {
      nodes.addAll(obs.affectedNodeIds);
      if (obs.locationNodeId != null) nodes.add(obs.locationNodeId!);
    }
    return nodes.toList();
  }

  /// Explicitly blocks a location node (hard obstacle)
  void blockNode(String nodeId, [String? reason]) {
    _manuallyBlockedNodes.add(nodeId);
    if (reason != null) {
      _nodeBlockReasons[nodeId] = reason;
    }
    _notifyListeners();
  }

  /// Unblocks a previously blocked location node
  void unblockNode(String nodeId) {
    _manuallyBlockedNodes.remove(nodeId);
    _nodeBlockReasons.remove(nodeId);
    _notifyListeners();
  }

  /// Explicitly blocks a road edge (hard obstacle)
  void blockRoad(String roadId, [String? reason]) {
    _manuallyBlockedRoads.add(roadId);
    if (reason != null) {
      _roadBlockReasons[roadId] = reason;
    }
    _notifyListeners();
  }

  /// Unblocks a previously blocked road edge
  void unblockRoad(String roadId) {
    _manuallyBlockedRoads.remove(roadId);
    _roadBlockReasons.remove(roadId);
    _notifyListeners();
  }

  /// Returns true if a node is hard-blocked by an active obstacle or manual block
  bool isNodeBlocked(String nodeId) {
    if (_manuallyBlockedNodes.contains(nodeId)) return true;
    for (final obs in getActiveObstacles()) {
      if (obs.blocksNode) {
        if (obs.locationNodeId == nodeId || obs.affectedNodeIds.contains(nodeId)) {
          return true;
        }
      }
    }
    return false;
  }

  /// Returns true if a road edge is hard-blocked by an active obstacle or manual block
  bool isRoadBlocked(String roadId) {
    if (_manuallyBlockedRoads.contains(roadId)) return true;
    for (final obs in getActiveObstacles()) {
      if (obs.blocksRoad) {
        if (obs.roadId == roadId || obs.affectedRoadIds.contains(roadId)) {
          return true;
        }
      }
    }
    return false;
  }

  /// Returns additive cost penalty on a road segment from soft obstacles
  double getRoadPenalty(String roadId) {
    double total = 0.0;
    for (final obs in getActiveObstacles()) {
      if (!obs.blocksRoad && obs.penalty > 0) {
        if (obs.roadId == roadId || obs.affectedRoadIds.contains(roadId)) {
          total += obs.penalty;
        }
      }
    }
    return total;
  }

  /// Returns additive cost penalty on a location node from soft obstacles
  double getNodePenalty(String nodeId) {
    double total = 0.0;
    for (final obs in getActiveObstacles()) {
      if (!obs.blocksNode && obs.penalty > 0) {
        if (obs.locationNodeId == nodeId || obs.affectedNodeIds.contains(nodeId)) {
          total += obs.penalty;
        }
      }
    }
    return total;
  }

  /// Moves a dynamic obstacle (e.g. Swiper) to a new node and/or road
  void moveObstacle(String obstacleId, {String? locationNodeId, String? roadId}) {
    final obs = _obstacles[obstacleId];
    if (obs != null) {
      _obstacles[obstacleId] = obs.copyWith(
        locationNodeId: locationNodeId,
        roadId: roadId,
        affectedNodeIds: locationNodeId != null ? [locationNodeId] : const [],
        affectedRoadIds: roadId != null ? [roadId] : const [],
      );
      _notifyListeners();
    }
  }

  /// Resets all obstacles and manual blocks
  void clear() {
    _obstacles.clear();
    _manuallyBlockedNodes.clear();
    _manuallyBlockedRoads.clear();
    _nodeBlockReasons.clear();
    _roadBlockReasons.clear();
    _notifyListeners();
  }
}
