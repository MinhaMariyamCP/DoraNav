import 'dart:async';
import 'dart:math' as math;
import '../models/map_models.dart';

/// Configuration schedule for deterministic demo events.
class DemoSchedule {
  final Duration swiperAppear;
  final Duration swiperClear;
  final Duration crocAppear;
  final Duration treeAppear;
  final Duration rockAppear;

  const DemoSchedule({
    this.swiperAppear = const Duration(seconds: 8),
    this.swiperClear = const Duration(seconds: 18),
    this.crocAppear = const Duration(seconds: 25),
    this.treeAppear = const Duration(seconds: 40),
    this.rockAppear = const Duration(seconds: 55),
  });
}

/// Dynamic Obstacle Manager:
/// - Maintains runtime obstacles and road/node blockage maps
/// - Does NOT modify underlying JSON files; maintains runtime state only
/// - Manages moving Swiper and 4 obstacle types (Swiper, Crocodile, Fallen Tree, Rockslide)
/// - Deterministic Demo Schedule runner
/// - Stream of obstacle state changes with built-in debouncing
class DynamicObstacleManager {
  final Map<String, DynamicObstacle> _obstacles = {};
  final Map<String, bool> runtimeRoadBlocked = {};
  final Map<String, double> runtimeRoadPenalty = {};
  final Map<String, bool> runtimeNodeBlocked = {};

  final StreamController<DynamicObstacle> _obstacleEventController =
      StreamController<DynamicObstacle>.broadcast();

  Timer? _debounceTimer;
  final List<Timer> _demoTimers = [];
  bool _isDemoModeActive = false;

  Stream<DynamicObstacle> get onObstacleStateChanged =>
      _obstacleEventController.stream;

  bool get isDemoModeActive => _isDemoModeActive;

  List<DynamicObstacle> get activeObstacles =>
      _obstacles.values.where((o) => o.active).toList();

  DynamicObstacle? getObstacle(String id) => _obstacles[id];

  /// Spawns a dynamic obstacle at a specified coordinate or node/road.
  void spawnObstacle(
    DynamicObstacleType type, {
    String? id,
    String? roadId,
    String? nodeId,
    double x = 100.0,
    double y = 100.0,
    bool blocksRoute = true,
    double penalty = 0.0,
    Duration? lifetime,
  }) {
    final obsId = id ?? '${type.name}_${DateTime.now().millisecondsSinceEpoch}';

    // Prevent duplicate active obstacles with same ID
    if (_obstacles[obsId]?.active == true) return;

    final obstacle = DynamicObstacle(
      id: obsId,
      type: type,
      roadId: roadId,
      nodeId: nodeId,
      x: x,
      y: y,
      active: true,
      blocksRoute: blocksRoute,
      penalty: penalty,
      lifetime: lifetime,
    );

    _obstacles[obsId] = obstacle;

    if (roadId != null) {
      if (blocksRoute) {
        runtimeRoadBlocked[roadId] = true;
      }
      if (penalty > 0) {
        runtimeRoadPenalty[roadId] = (runtimeRoadPenalty[roadId] ?? 0.0) + penalty;
      }
    }

    if (nodeId != null && blocksRoute) {
      runtimeNodeBlocked[nodeId] = true;
    }

    _emitDebounced(obstacle);

    // Auto-remove if lifetime set
    if (lifetime != null) {
      Timer(lifetime, () => removeObstacle(obsId));
    }
  }

  /// Removes an obstacle and clears its runtime graph blocks.
  void removeObstacle(String id) {
    final obstacle = _obstacles[id];
    if (obstacle == null) return;

    obstacle.active = false;

    if (obstacle.roadId != null) {
      runtimeRoadBlocked.remove(obstacle.roadId!);
      runtimeRoadPenalty.remove(obstacle.roadId!);
    }
    if (obstacle.nodeId != null) {
      runtimeNodeBlocked.remove(obstacle.nodeId!);
    }

    _obstacles.remove(id);
    _emitDebounced(obstacle);
  }

  /// Dynamically moves Swiper along coordinates or between roads/nodes.
  void moveSwiper(String id, double targetX, double targetY, {String? newRoadId, String? newNodeId}) {
    final obstacle = _obstacles[id];
    if (obstacle == null || obstacle.type != DynamicObstacleType.swiper) return;

    // Clear previous road/node block if changing roads/nodes
    if (obstacle.roadId != null && obstacle.roadId != newRoadId) {
      runtimeRoadBlocked.remove(obstacle.roadId!);
    }
    if (obstacle.nodeId != null && obstacle.nodeId != newNodeId) {
      runtimeNodeBlocked.remove(obstacle.nodeId!);
    }

    final updated = obstacle.copyWith(
      x: targetX,
      y: targetY,
      roadId: newRoadId,
      nodeId: newNodeId,
    );

    _obstacles[id] = updated;

    if (newRoadId != null && updated.blocksRoute) {
      runtimeRoadBlocked[newRoadId] = true;
    }
    if (newNodeId != null && updated.blocksRoute) {
      runtimeNodeBlocked[newNodeId] = true;
    }

    _emitDebounced(updated);
  }

  /// Starts the deterministic demo schedule.
  /// If [getActiveRemainingNodes] is provided, dynamically places obstacles ahead on Dora's active route.
  void startDemoMode({
    DemoSchedule schedule = const DemoSchedule(),
    List<LocationNode> availableNodes = const [],
    List<RoadEdge> availableRoads = const [],
    List<LocationNode> Function()? getActiveRemainingNodes,
    List<RoadEdge> Function()? getActiveRoads,
  }) {
    stopDemoMode();
    _isDemoModeActive = true;

    // Helper to find upcoming node on active route
    LocationNode? getUpcomingNode(int offsetIndex, LocationNode? fallback) {
      if (getActiveRemainingNodes != null) {
        final remaining = getActiveRemainingNodes();
        if (remaining.length > offsetIndex) {
          return remaining[offsetIndex];
        } else if (remaining.length > 1) {
          return remaining[1];
        }
      }
      return fallback;
    }

    // Fallback node for Swiper
    final fallbackSwiper = availableNodes.length > 5 ? availableNodes[3] : null;

    // Single Swiper appears ahead on active route (only obstacle)
    _demoTimers.add(Timer(schedule.swiperAppear, () {
      if (!_isDemoModeActive) return;
      final target = getUpcomingNode(2, fallbackSwiper);
      spawnObstacle(
        DynamicObstacleType.swiper,
        id: 'demo_swiper',
        nodeId: target?.id ?? 'L003',
        x: target?.x ?? 85.0,
        y: target?.y ?? 155.0,
        blocksRoute: true,
      );
    }));
  }

  Timer? _autoEncounterTimer;
  bool _isAutoEncounterActive = false;
  bool _swiperOccurredThisTrip = false;

  bool get isAutoEncounterActive => _isAutoEncounterActive;
  bool get swiperOccurredThisTrip => _swiperOccurredThisTrip;

  /// Automatically spawns exactly ONE dynamic Swiper obstacle along Dora's route per trip.
  /// All other obstacle types are removed. Once Swiper occurs on a trip, no further obstacles appear.
  void startAutoEncounters({
    required List<LocationNode> Function() getActiveRemainingNodes,
    required List<RoadEdge> Function() getActiveRoads,
    Duration initialDelay = const Duration(seconds: 12),
  }) {
    stopAutoEncounters();
    _isAutoEncounterActive = true;
    _swiperOccurredThisTrip = false; // Reset for new trip

    _autoEncounterTimer = Timer(initialDelay, () {
      if (!_isAutoEncounterActive || _swiperOccurredThisTrip) return;

      final remaining = getActiveRemainingNodes();

      // Only spawn if Dora is still en route and has upcoming nodes before destination
      if (remaining.length >= 2) {
        // Target an upcoming node ahead of Dora on the remaining route
        final targetNode = remaining.length > 2 ? remaining[1] : remaining.first;
        final timestamp = DateTime.now().millisecondsSinceEpoch;

        spawnObstacle(
          DynamicObstacleType.swiper,
          id: 'swiper_$timestamp',
          nodeId: targetNode.id,
          x: targetNode.x,
          y: targetNode.y,
          blocksRoute: true,
        );

        _swiperOccurredThisTrip = true;
        // Exactly ONE Swiper per trip: stop scheduling any more encounters!
        stopAutoEncounters();
      }
    });
  }

  /// Stops automatic dynamic obstacle encounters.
  void stopAutoEncounters() {
    _isAutoEncounterActive = false;
    _autoEncounterTimer?.cancel();
    _autoEncounterTimer = null;
  }

  /// Cancels all scheduled demo timers and clears dynamic obstacles.
  void stopDemoMode() {
    _isDemoModeActive = false;
    for (final timer in _demoTimers) {
      timer.cancel();
    }
    _demoTimers.clear();
  }

  /// Clears all runtime obstacles.
  void clearAll() {
    stopDemoMode();
    stopAutoEncounters();
    _obstacles.clear();
    runtimeRoadBlocked.clear();
    runtimeRoadPenalty.clear();
    runtimeNodeBlocked.clear();
  }

  void _emitDebounced(DynamicObstacle obstacle) {
    _debounceTimer?.cancel();
    _debounceTimer = Timer(const Duration(milliseconds: 150), () {
      if (!_obstacleEventController.isClosed) {
        _obstacleEventController.add(obstacle);
      }
    });
  }

  void dispose() {
    stopDemoMode();
    stopAutoEncounters();
    _debounceTimer?.cancel();
    _obstacleEventController.close();
  }
}
