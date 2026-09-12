import 'dart:async';
import 'dart:math' as math;
import 'package:flutter/foundation.dart';
import 'package:flutter/painting.dart';
import '../screens/map/models/map_models.dart';

/// Service responsible for real-time continuous movement simulation along an A* route.
///
/// Features:
/// - Smooth interpolation of Dora's coordinates along route edges
/// - Real-time elapsed journey timer (Stopwatch)
/// - Continuous distance & ETA computation driven by simulatedSpeed
/// - Dynamic route swapping on reroute without resetting elapsed journey time
/// - Configurable speed and speed multipliers for fast testing
class NavigationSimulationService extends ChangeNotifier {
  /// Base simulated travel speed in meters per second (default 45 m/s ~ 160 km/h in Dora scale)
  static const double defaultSimulatedSpeed = 45.0;

  /// Conversion factor from map coordinate units to meters (1 unit ~ 50 meters)
  static const double metersPerMapUnit = 50.0;

  NavigationRoute _activeRoute;
  int _currentSegmentIndex = 0;
  double _segmentProgress = 0.0; // 0.0 -> 1.0 along current segment
  Offset _currentPosition;
  final double _baseSpeed;
  double _speedMultiplier = 1.0;

  final Stopwatch _journeyStopwatch = Stopwatch();
  Timer? _simulationTimer;
  DateTime? _lastTickTime;

  bool _isActive = false;
  bool _isPaused = false;
  bool _isCompleted = false;

  VoidCallback? onDestinationReached;
  void Function(LocationNode visitedNode)? onNodeReached;
  void Function(String instruction)? onInstructionChanged;

  NavigationSimulationService({
    required NavigationRoute initialRoute,
    double initialSpeed = defaultSimulatedSpeed,
    this.onDestinationReached,
    this.onNodeReached,
    this.onInstructionChanged,
  })  : _activeRoute = initialRoute,
        _baseSpeed = initialSpeed,
        _currentPosition = initialRoute.nodes.isNotEmpty
            ? Offset(initialRoute.nodes.first.x, initialRoute.nodes.first.y)
            : const Offset(48.0, 110.0);

  // ---------------------------------------------------------------------------
  // Getters
  // ---------------------------------------------------------------------------

  NavigationRoute get activeRoute => _activeRoute;
  int get currentSegmentIndex => _currentSegmentIndex;
  double get segmentProgress => _segmentProgress;
  Offset get currentPosition => _currentPosition;
  double get simulatedSpeed => _baseSpeed * _speedMultiplier;
  double get speedMultiplier => _speedMultiplier;
  bool get isActive => _isActive;
  bool get isPaused => _isPaused;
  bool get isCompleted => _isCompleted;
  Duration get elapsedTime => _journeyStopwatch.elapsed;

  LocationNode get startNode => _activeRoute.nodes.isNotEmpty
      ? _activeRoute.nodes.first
      : const LocationNode(
          id: 'start', name: 'Start', x: 48, y: 110, selectable: false, start: true, active: true, type: 'start', description: '', region: '');

  LocationNode get destination => _activeRoute.nodes.isNotEmpty
      ? _activeRoute.nodes.last
      : const LocationNode(
          id: 'goal', name: 'Goal', x: 180, y: 180, selectable: true, start: false, active: true, type: 'destination', description: '', region: '');

  LocationNode get currentNode {
    if (_activeRoute.nodes.isEmpty) return startNode;
    if (_currentSegmentIndex >= _activeRoute.nodes.length) {
      return _activeRoute.nodes.last;
    }
    return _activeRoute.nodes[_currentSegmentIndex];
  }

  LocationNode? get nextNode {
    if (_currentSegmentIndex + 1 < _activeRoute.nodes.length) {
      return _activeRoute.nodes[_currentSegmentIndex + 1];
    }
    return null;
  }

  /// Continuous runtime position with current and next node properties
  DoraRuntimePosition get doraRuntimePosition => DoraRuntimePosition(
        x: _currentPosition.dx,
        y: _currentPosition.dy,
        currentNodeId: currentNode.id,
        nextNodeId: nextNode?.id,
      );

  /// Remaining distance to destination in meters, computed continuously from currentPosition
  double get remainingDistanceMeters {
    if (_isCompleted || _activeRoute.nodes.length < 2) return 0.0;
    if (_currentSegmentIndex >= _activeRoute.nodes.length - 1) return 0.0;

    final toNode = _activeRoute.nodes[_currentSegmentIndex + 1];

    // Distance remaining on current segment
    final curTarget = Offset(toNode.x, toNode.y);
    final dx = curTarget.dx - _currentPosition.dx;
    final dy = curTarget.dy - _currentPosition.dy;
    final distOnCurrentUnit = math.sqrt(dx * dx + dy * dy);
    double remainingMeters = distOnCurrentUnit * metersPerMapUnit;

    // Add distances of all subsequent segments
    for (int i = _currentSegmentIndex + 1; i < _activeRoute.nodes.length - 1; i++) {
      final a = _activeRoute.nodes[i];
      final b = _activeRoute.nodes[i + 1];
      remainingMeters += a.distanceTo(b) * metersPerMapUnit;
    }

    return remainingMeters;
  }

  /// Live estimated time remaining based on remaining distance and current simulatedSpeed
  Duration get estimatedTimeRemaining {
    final dist = remainingDistanceMeters;
    final speed = simulatedSpeed;
    if (speed <= 0 || dist <= 0) return Duration.zero;
    final seconds = (dist / speed).round();
    return Duration(seconds: seconds);
  }

  /// Distance to the immediate next node/turn in meters
  double get distanceToNextNodeMeters {
    if (nextNode == null) return 0.0;
    final target = Offset(nextNode!.x, nextNode!.y);
    final dx = target.dx - _currentPosition.dx;
    final dy = target.dy - _currentPosition.dy;
    return math.sqrt(dx * dx + dy * dy) * metersPerMapUnit;
  }

  /// Formatted instruction string for the current navigation step
  String get currentInstruction {
    if (_isCompleted) {
      return 'Arrived at ${destination.name}! 🎉';
    }
    if (nextNode != null) {
      return 'Continue straight towards ${nextNode!.name}';
    }
    return 'Head to ${destination.name}';
  }

  /// Formatted elapsed time (mm:ss)
  String get formattedElapsedTime {
    final totalSecs = _journeyStopwatch.elapsed.inSeconds;
    final mins = (totalSecs ~/ 60).toString().padLeft(2, '0');
    final secs = (totalSecs % 60).toString().padLeft(2, '0');
    return '$mins:$secs';
  }

  /// Formatted remaining ETA (mm:ss)
  String get formattedEta {
    final totalSecs = estimatedTimeRemaining.inSeconds;
    final mins = (totalSecs ~/ 60).toString().padLeft(2, '0');
    final secs = (totalSecs % 60).toString().padLeft(2, '0');
    return '$mins:$secs';
  }

  /// Formatted remaining distance string (e.g. "1.2 km" or "450 m")
  String get formattedRemainingDistance {
    final meters = remainingDistanceMeters;
    if (meters >= 1000) {
      return '${(meters / 1000).toStringAsFixed(1)} km';
    }
    return '${meters.toInt()} m';
  }

  /// Formatted distance to next node (e.g. "250 m")
  String get formattedDistanceToNextNode {
    final meters = distanceToNextNodeMeters;
    if (meters >= 1000) {
      return '${(meters / 1000).toStringAsFixed(1)} km';
    }
    return '${meters.toInt()} m';
  }

  // ---------------------------------------------------------------------------
  // Control Methods
  // ---------------------------------------------------------------------------

  /// Starts the continuous navigation simulation and elapsed journey stopwatch
  void start() {
    if (_isActive || _isCompleted) return;
    _isActive = true;
    _isPaused = false;
    _journeyStopwatch.start();
    _lastTickTime = DateTime.now();

    _simulationTimer?.cancel();
    _simulationTimer = Timer.periodic(const Duration(milliseconds: 16), _onSimulationTick);
    notifyListeners();
  }

  /// Pauses the simulation and stopwatch
  void pause() {
    if (!_isActive || _isPaused) return;
    _isPaused = true;
    _journeyStopwatch.stop();
    _simulationTimer?.cancel();
    notifyListeners();
  }

  /// Resumes the simulation and stopwatch
  void resume() {
    if (!_isActive || !_isPaused) return;
    _isPaused = false;
    _journeyStopwatch.start();
    _lastTickTime = DateTime.now();
    _simulationTimer = Timer.periodic(const Duration(milliseconds: 16), _onSimulationTick);
    notifyListeners();
  }

  /// Stops the simulation completely
  void stop() {
    _isActive = false;
    _journeyStopwatch.stop();
    _simulationTimer?.cancel();
    _simulationTimer = null;
    notifyListeners();
  }

  /// Sets speed multiplier for test acceleration (e.g. 1.0, 2.0, 5.0)
  void setSpeedMultiplier(double mult) {
    if (mult <= 0) return;
    _speedMultiplier = mult;
    notifyListeners();
  }

  /// Dynamically updates the active route (e.g. after A* rerouting around an obstacle).
  ///
  /// Seamlessly bridges Dora's current continuous position into the new route:
  /// - Elapsed journey timer is PRESERVED.
  /// - Position is NOT reset to start.
  /// - Creates a direct segment from current continuous position into the new route.
  void updateRoute(NavigationRoute newRoute) {
    if (newRoute.nodes.isEmpty) return;

    final currentPos = _currentPosition;

    // Create a virtual node representing Dora's exact live position
    final liveNode = LocationNode(
      id: '__live_pos__',
      name: 'Current Position',
      x: currentPos.dx,
      y: currentPos.dy,
      selectable: false,
      start: false,
      active: true,
      type: 'live',
      description: 'Continuous simulated location',
      region: 'Jungle',
    );

    final List<LocationNode> stitchedNodes = [liveNode];

    // If the first node in new route is close to live position (< 2 units), skip it to avoid stutter
    final firstNewNode = newRoute.nodes.first;
    final distToFirst = math.sqrt(
      math.pow(firstNewNode.x - currentPos.dx, 2) + math.pow(firstNewNode.y - currentPos.dy, 2),
    );

    if (distToFirst < 2.0 && newRoute.nodes.length > 1) {
      stitchedNodes.addAll(newRoute.nodes.sublist(1));
    } else {
      stitchedNodes.addAll(newRoute.nodes);
    }

    _activeRoute = NavigationRoute(
      nodes: stitchedNodes,
      totalDistance: newRoute.totalDistance,
      etaMinutes: newRoute.etaMinutes,
      isAlternative: true,
      nextInstruction: newRoute.nextInstruction,
      nextDistanceMeters: newRoute.nextDistanceMeters,
    );

    _currentSegmentIndex = 0;
    _segmentProgress = 0.0;
    _isCompleted = false;

    onInstructionChanged?.call(currentInstruction);
    notifyListeners();
  }

  // ---------------------------------------------------------------------------
  // Internal Simulation Loop
  // ---------------------------------------------------------------------------

  void _onSimulationTick(Timer timer) {
    if (!_isActive || _isPaused || _isCompleted) return;

    final now = DateTime.now();
    final dt = _lastTickTime != null
        ? (now.difference(_lastTickTime!).inMicroseconds / 1000000.0)
        : 0.016;
    _lastTickTime = now;

    stepSimulation(dt);
  }

  /// Advances continuous simulation forward by [dt] seconds.
  ///
  /// Correctly handles edge traversals across variable frame-times and speeds,
  /// triggering intermediate node events in sequence without dropping waypoints.
  void stepSimulation(double dt) {
    if (_isCompleted || _activeRoute.nodes.length < 2) return;

    double moveDistance = simulatedSpeed * dt;

    while (moveDistance > 0 && _currentSegmentIndex < _activeRoute.nodes.length - 1) {
      final fromNode = _activeRoute.nodes[_currentSegmentIndex];
      final toNode = _activeRoute.nodes[_currentSegmentIndex + 1];

      final segmentDistUnits = fromNode.distanceTo(toNode);
      final segmentDistMeters = math.max(0.001, segmentDistUnits * metersPerMapUnit);

      final distanceRemainingOnSegment = (1.0 - _segmentProgress) * segmentDistMeters;

      if (moveDistance >= distanceRemainingOnSegment) {
        moveDistance -= distanceRemainingOnSegment;
        _segmentProgress = 0.0;
        _currentSegmentIndex++;
        _currentPosition = Offset(toNode.x, toNode.y);

        onNodeReached?.call(toNode);

        if (_currentSegmentIndex >= _activeRoute.nodes.length - 1) {
          _completeJourney();
          return;
        } else {
          onInstructionChanged?.call(currentInstruction);
        }
      } else {
        _segmentProgress += moveDistance / segmentDistMeters;
        moveDistance = 0.0;

        final fromX = fromNode.x;
        final fromY = fromNode.y;
        final toX = toNode.x;
        final toY = toNode.y;

        _currentPosition = Offset(
          fromX + (toX - fromX) * _segmentProgress,
          fromY + (toY - fromY) * _segmentProgress,
        );
      }
    }

    notifyListeners();
  }

  void _completeJourney() {
    if (_isCompleted) return;
    _isCompleted = true;
    _isActive = false;
    _journeyStopwatch.stop();
    _simulationTimer?.cancel();
    _simulationTimer = null;

    if (_activeRoute.nodes.isNotEmpty) {
      final dest = _activeRoute.nodes.last;
      _currentPosition = Offset(dest.x, dest.y);
    }

    notifyListeners();
    onDestinationReached?.call();
  }

  @override
  void dispose() {
    _simulationTimer?.cancel();
    _journeyStopwatch.stop();
    super.dispose();
  }
}
