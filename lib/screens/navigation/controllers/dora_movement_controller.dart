import 'dart:math' as math;
import 'package:flutter/animation.dart';
import '../../map/models/map_models.dart';

/// Single-responsibility movement controller that moves Dora smoothly along route
/// segments using linear interpolation or an AnimationController Tween.
class DoraMovementController {
  AnimationController? _activeController;
  Animation<double>? _segmentAnimation;

  DoraRuntimePosition _runtimePosition;
  double simulatedSpeed;

  DoraMovementController({
    required DoraRuntimePosition initialPosition,
    this.simulatedSpeed = 45.0,
  }) : _runtimePosition = initialPosition;

  DoraRuntimePosition get runtimePosition => _runtimePosition;
  bool get isMoving => _activeController?.isAnimating ?? false;

  /// Manually interpolates position between two nodes for testing or direct placement.
  void interpolate({
    required LocationNode from,
    required LocationNode to,
    required double progress,
  }) {
    final curX = from.x + (to.x - from.x) * progress;
    final curY = from.y + (to.y - from.y) * progress;
    _runtimePosition = DoraRuntimePosition(
      x: curX,
      y: curY,
      currentNodeId: from.id,
      nextNodeId: to.id,
    );
  }

  /// Follows route sequentially segment by segment.
  void followRoute({
    required List<LocationNode> routeNodes,
    required TickerProvider vsync,
    required void Function(DoraRuntimePosition pos) onPositionUpdate,
    required void Function(LocationNode reachedNode) onNodeReached,
    required void Function() onDestinationReached,
  }) {
    disposeController();

    if (routeNodes.length < 2) {
      if (routeNodes.isNotEmpty) onDestinationReached();
      return;
    }

    _animateSegment(
      routeNodes: routeNodes,
      segmentIndex: 0,
      vsync: vsync,
      onPositionUpdate: onPositionUpdate,
      onNodeReached: onNodeReached,
      onDestinationReached: onDestinationReached,
    );
  }

  void _animateSegment({
    required List<LocationNode> routeNodes,
    required int segmentIndex,
    required TickerProvider vsync,
    required void Function(DoraRuntimePosition pos) onPositionUpdate,
    required void Function(LocationNode reachedNode) onNodeReached,
    required void Function() onDestinationReached,
  }) {
    if (segmentIndex >= routeNodes.length - 1) {
      onDestinationReached();
      return;
    }

    final startNode = routeNodes[segmentIndex];
    final endNode = routeNodes[segmentIndex + 1];

    final start = Offset(startNode.x, startNode.y);
    final end = Offset(endNode.x, endNode.y);

    final distanceUnits = math.sqrt(math.pow(end.dx - start.dx, 2) + math.pow(end.dy - start.dy, 2));
    final distanceMeters = distanceUnits * 50.0;
    final durationSeconds = (distanceMeters / simulatedSpeed).clamp(0.1, 30.0);
    final duration = Duration(milliseconds: (durationSeconds * 1000).toInt());

    _activeController = AnimationController(vsync: vsync, duration: duration);
    _segmentAnimation = CurvedAnimation(parent: _activeController!, curve: Curves.linear);

    _activeController!.addListener(() {
      final t = _segmentAnimation!.value;
      final curX = start.dx + (end.dx - start.dx) * t;
      final curY = start.dy + (end.dy - start.dy) * t;

      _runtimePosition = DoraRuntimePosition(
        x: curX,
        y: curY,
        currentNodeId: startNode.id,
        nextNodeId: endNode.id,
      );
      onPositionUpdate(_runtimePosition);
    });

    _activeController!.addStatusListener((status) {
      if (status == AnimationStatus.completed) {
        _runtimePosition = DoraRuntimePosition(
          x: end.dx,
          y: end.dy,
          currentNodeId: endNode.id,
          nextNodeId: segmentIndex + 2 < routeNodes.length ? routeNodes[segmentIndex + 2].id : null,
        );
        onNodeReached(endNode);

        _animateSegment(
          routeNodes: routeNodes,
          segmentIndex: segmentIndex + 1,
          vsync: vsync,
          onPositionUpdate: onPositionUpdate,
          onNodeReached: onNodeReached,
          onDestinationReached: onDestinationReached,
        );
      }
    });

    _activeController!.forward();
  }

  /// Safely halts current animation and preserves current continuous coordinates.
  DoraRuntimePosition pauseAndPreservePosition() {
    _activeController?.stop();
    return _runtimePosition;
  }

  /// Disposes single active AnimationController to prevent memory leaks.
  void disposeController() {
    _activeController?.stop();
    _activeController?.dispose();
    _activeController = null;
    _segmentAnimation = null;
  }

  void dispose() {
    disposeController();
  }
}
