import 'dart:math' as math;
import 'package:flutter/material.dart';
import '../models/map_models.dart';
import '../services/navigation_camera_service.dart';
import '../services/map_projection_service.dart';
import 'map_legend_sheet.dart';
import 'destination_visual_modal.dart';
import 'dynamic_obstacle_widget.dart';

/// Interactive Map Canvas featuring:
/// - Google Maps-style route framing, dynamic zoom, and camera tracking
/// - Illustrated Dora's World map background
/// - Subtle non-route road network and prominent glowing active route
/// - Compass rose and zoom / center controls
/// - Numbered purple destination pins (dimmed/filtered in active navigation)
/// - Dora current location avatar & Swiper warning badge
class MapCanvasView extends StatefulWidget {
  final List<LocationNode> locations;
  final List<RoadEdge> allRoads;
  final NavigationRoute? activeRoute;
  final NavigationRoute? alternativeRoute;
  final LocationNode? selectedDestination;
  final LocationNode? currentLocation;
  final LocationNode? nextLocation;
  final Offset? simulatedDoraPosition;
  final MapCameraMode cameraMode;
  final ValueChanged<LocationNode>? onLocationSelected;
  final bool showSwiperOnRoute;
  final VoidCallback? onSwiperTap;
  final SwiperState? swiperState;
  final LocationNode? swiperLocation;
  final bool showRoadBlockOnRoute;
  final VoidCallback? onRoadBlockTap;
  final Set<String> blockedRoadIds;
  final Set<String> blockedNodeIds;
  final List<DynamicObstacle> dynamicObstacles;
  final void Function(DynamicObstacle obstacle)? onDynamicObstacleTap;

  const MapCanvasView({
    super.key,
    required this.locations,
    this.allRoads = const [],
    this.activeRoute,
    this.alternativeRoute,
    this.selectedDestination,
    this.currentLocation,
    this.nextLocation,
    this.simulatedDoraPosition,
    this.cameraMode = MapCameraMode.worldOverview,
    this.onLocationSelected,
    this.showSwiperOnRoute = true,
    this.onSwiperTap,
    this.swiperState,
    this.swiperLocation,
    this.showRoadBlockOnRoute = false,
    this.onRoadBlockTap,
    this.blockedRoadIds = const {},
    this.blockedNodeIds = const {},
    this.dynamicObstacles = const [],
    this.onDynamicObstacleTap,
  });

  @override
  State<MapCanvasView> createState() => _MapCanvasViewState();
}

class _MapCanvasViewState extends State<MapCanvasView>
    with TickerProviderStateMixin {
  final TransformationController _transformController = TransformationController();
  late AnimationController _pulseController;
  late AnimationController _cameraAnimController;
  Animation<Matrix4>? _cameraAnimation;
  Size _lastCanvasSize = Size.zero;

  @override
  void initState() {
    super.initState();
    _pulseController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1600),
    )..repeat(reverse: true);

    _cameraAnimController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 750),
    );
  }

  @override
  void didUpdateWidget(MapCanvasView oldWidget) {
    super.didUpdateWidget(oldWidget);

    final routeChanged = widget.activeRoute != oldWidget.activeRoute;
    final locChanged = widget.currentLocation?.id != oldWidget.currentLocation?.id;
    final nextChanged = widget.nextLocation?.id != oldWidget.nextLocation?.id;
    final modeChanged = widget.cameraMode != oldWidget.cameraMode;
    final posChanged = widget.simulatedDoraPosition != oldWidget.simulatedDoraPosition;

    if (_lastCanvasSize != Size.zero &&
        (routeChanged || locChanged || nextChanged || modeChanged || (posChanged && widget.cameraMode == MapCameraMode.activeNavigation))) {
      _evaluateCameraTarget(animated: modeChanged || routeChanged);
    }
  }

  @override
  void dispose() {
    _pulseController.dispose();
    _cameraAnimController.dispose();
    _transformController.dispose();
    super.dispose();
  }

  void _evaluateCameraTarget({bool animated = true}) {
    if (_lastCanvasSize == Size.zero) return;

    Matrix4 targetMatrix;

    switch (widget.cameraMode) {
      case MapCameraMode.routePreview:
        if (widget.activeRoute != null && widget.activeRoute!.nodes.isNotEmpty) {
          targetMatrix = NavigationCameraService.fitToRoute(
            widget.activeRoute!,
            canvasSize: _lastCanvasSize,
          );
        } else {
          targetMatrix = Matrix4.identity();
        }
        break;

      case MapCameraMode.activeNavigation:
        if (widget.simulatedDoraPosition != null) {
          final nextPos = widget.nextLocation != null
              ? Offset(widget.nextLocation!.x, widget.nextLocation!.y)
              : null;
          targetMatrix = NavigationCameraService.followContinuousPosition(
            widget.simulatedDoraPosition!,
            nextPos,
            canvasSize: _lastCanvasSize,
          );
        } else if (widget.currentLocation != null) {
          targetMatrix = NavigationCameraService.followNavigation(
            widget.currentLocation!,
            widget.nextLocation,
            canvasSize: _lastCanvasSize,
          );
        } else if (widget.activeRoute != null && widget.activeRoute!.nodes.isNotEmpty) {
          targetMatrix = NavigationCameraService.fitToRoute(
            widget.activeRoute!,
            canvasSize: _lastCanvasSize,
          );
        } else {
          targetMatrix = Matrix4.identity();
        }
        break;

      case MapCameraMode.newRoute:
        if (widget.activeRoute != null && widget.currentLocation != null) {
          targetMatrix = NavigationCameraService.focusOnReroutedRoute(
            widget.activeRoute!,
            widget.currentLocation!,
            canvasSize: _lastCanvasSize,
          );
        } else if (widget.activeRoute != null) {
          targetMatrix = NavigationCameraService.fitToRoute(
            widget.activeRoute!,
            canvasSize: _lastCanvasSize,
          );
        } else {
          targetMatrix = Matrix4.identity();
        }
        break;

      case MapCameraMode.arrived:
        if (widget.selectedDestination != null) {
          targetMatrix = NavigationCameraService.focusOnLocation(
            widget.selectedDestination!,
            canvasSize: _lastCanvasSize,
            zoom: 2.5,
          );
        } else {
          targetMatrix = Matrix4.identity();
        }
        break;

      case MapCameraMode.rerouting:
        if (widget.currentLocation != null) {
          targetMatrix = NavigationCameraService.followNavigation(
            widget.currentLocation!,
            null,
            canvasSize: _lastCanvasSize,
            zoom: 2.2,
          );
        } else {
          targetMatrix = _transformController.value;
        }
        break;

      case MapCameraMode.worldOverview:
        targetMatrix = Matrix4.identity();
        break;
    }

    _animateToMatrix(targetMatrix, animated: animated);
  }

  void _animateToMatrix(Matrix4 targetMatrix, {bool animated = true}) {
    if (!animated) {
      if (widget.cameraMode == MapCameraMode.activeNavigation) {
        // Soft camera tracking damping for smooth continuous follow
        final currentM = _transformController.value;
        const t = 0.18;
        final lerped = Matrix4.identity();
        for (int i = 0; i < 16; i++) {
          lerped.storage[i] = currentM.storage[i] + (targetMatrix.storage[i] - currentM.storage[i]) * t;
        }
        _transformController.value = lerped;
      } else {
        _transformController.value = targetMatrix;
      }
      return;
    }

    final startMatrix = _transformController.value;
    if (startMatrix == targetMatrix) return;

    _cameraAnimController.stop();
    _cameraAnimation = Matrix4Tween(
      begin: startMatrix,
      end: targetMatrix,
    ).animate(CurvedAnimation(
      parent: _cameraAnimController,
      curve: Curves.easeInOutCubic,
    ))..addListener(() {
      _transformController.value = _cameraAnimation!.value;
    });

    _cameraAnimController.forward(from: 0.0);
  }

  void _zoomIn() {
    final target = Matrix4.copy(_transformController.value)..scaleByDouble(1.25, 1.25, 1.0, 1.0);
    _animateToMatrix(target);
  }

  void _zoomOut() {
    final target = Matrix4.copy(_transformController.value)..scaleByDouble(0.8, 0.8, 1.0, 1.0);
    _animateToMatrix(target);
  }

  void _recenter() {
    _evaluateCameraTarget();
  }

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final canvasWidth = constraints.maxWidth;
        final canvasHeight = constraints.maxHeight;
        final currentSize = Size(canvasWidth, canvasHeight);

        if (_lastCanvasSize != currentSize) {
          final wasZero = _lastCanvasSize == Size.zero;
          _lastCanvasSize = currentSize;
          if (wasZero) {
            WidgetsBinding.instance.addPostFrameCallback((_) {
              if (mounted) _evaluateCameraTarget(animated: false);
            });
          }
        }

        // Active route node IDs for smart pin filtering
        final activeRouteNodeIds = widget.activeRoute?.locationIds.toSet() ?? {};
        final isNavigating = widget.cameraMode == MapCameraMode.activeNavigation ||
            widget.cameraMode == MapCameraMode.rerouting ||
            widget.cameraMode == MapCameraMode.newRoute ||
            widget.cameraMode == MapCameraMode.arrived;

        return Stack(
          children: [
            // 1. Zoomable & Pannable Map Layer
            InteractiveViewer(
              transformationController: _transformController,
              boundaryMargin: const EdgeInsets.all(120.0),
              minScale: 0.7,
              maxScale: 3.8,
              child: SizedBox(
                width: canvasWidth,
                height: canvasHeight,
                child: Stack(
                  fit: StackFit.expand,
                  children: [
                    // 1a. Map Art Backdrop
                    _buildMapBackground(),

                    // 1b. Custom Painted Routes (Background network + Active & Alternative)
                    AnimatedBuilder(
                      animation: _pulseController,
                      builder: (context, _) {
                        return CustomPaint(
                          painter: _RoutePainter(
                            allRoads: widget.allRoads,
                            locations: widget.locations,
                            activeRoute: widget.activeRoute,
                            alternativeRoute: widget.alternativeRoute,
                            pulseValue: _pulseController.value,
                            canvasWidth: canvasWidth,
                            canvasHeight: canvasHeight,
                            blockedNodeIds: widget.blockedNodeIds,
                            isNavigating: isNavigating,
                          ),
                        );
                      },
                    ),

                    // 1c. Location Pins & Interactive Markers
                    ...widget.locations.map((loc) {
                      final isDestination = widget.selectedDestination?.id == loc.id;
                      final isCurrent = widget.currentLocation?.id == loc.id || (widget.currentLocation == null && loc.start);
                      final isNext = widget.nextLocation?.id == loc.id;
                      final isOnActiveRoute = activeRouteNodeIds.contains(loc.id);

                      // In navigation mode, show only route-relevant nodes prominently
                      if (isNavigating && !isOnActiveRoute && !isDestination && !isCurrent) {
                        return const SizedBox.shrink();
                      }

                      final pos = MapProjectionService.nodeToPixel(loc, canvasWidth, canvasHeight);

                      return Positioned(
                        left: pos.dx - 18,
                        top: pos.dy - 20,
                        child: _buildLocationPin(
                          loc,
                          isCurrent: isCurrent,
                          isSelected: isDestination,
                          isNext: isNext,
                          dimmed: isNavigating && !isOnActiveRoute && !isDestination && !isCurrent,
                        ),
                      );
                    }),

                    // 1d. Dynamic Obstacles (Swiper, Crocodile, Fallen Tree, Rockslide)
                    ...widget.dynamicObstacles.map((obs) {
                      final pos = MapProjectionService.coordsToPixel(obs.x, obs.y, canvasWidth, canvasHeight);
                      return Positioned(
                        left: pos.dx - 22,
                        top: pos.dy - 22,
                        child: DynamicObstacleWidget(
                          obstacle: obs,
                          pulseValue: _pulseController.value,
                          onTap: () => widget.onDynamicObstacleTap?.call(obs),
                        ),
                      );
                    }),

                    // 1e. Dora Avatar on Path
                    _buildDoraAvatar(canvasWidth, canvasHeight),

                    // 1f. Legacy Swiper Alert Marker on Route
                    if (widget.showSwiperOnRoute && widget.dynamicObstacles.every((o) => o.type != DynamicObstacleType.swiper))
                      _buildSwiperRouteHazard(canvasWidth, canvasHeight),

                    // 1g. Road Block Hazard Marker
                    if ((widget.showRoadBlockOnRoute ||
                            widget.blockedNodeIds.isNotEmpty ||
                            widget.blockedRoadIds.isNotEmpty) &&
                        widget.dynamicObstacles.isEmpty)
                      _buildRoadBlockHazard(canvasWidth, canvasHeight),
                  ],
                ),
              ),
            ),

            // 2. Floating Map Top Banner (visible in map overview / route preview)
            if (!isNavigating)
              Positioned(
                top: 16,
                left: 68,
                right: 14,
                child: _buildTopBanner(),
              ),

            // 3. Floating Map HUD Controls (Top Left)
            Positioned(
              top: 16,
              left: 14,
              child: _buildMapControls(),
            ),
          ],
        );
      },
    );
  }

  Widget _buildTopBanner() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
      decoration: BoxDecoration(
        color: const Color(0xFF280645).withValues(alpha: 0.88),
        borderRadius: BorderRadius.circular(22),
        border: Border.all(color: Colors.white.withValues(alpha: 0.25), width: 1.2),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.35),
            blurRadius: 10,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      child: Row(
        children: [
          const Text('🗺️', style: TextStyle(fontSize: 20)),
          const SizedBox(width: 8),
          const Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  'DoraNav World Map',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 13,
                    fontWeight: FontWeight.w900,
                    letterSpacing: 0.5,
                  ),
                ),
                Text(
                  '70 Locations • 25 Adventures • Infinite Fun!',
                  style: TextStyle(
                    color: Color(0xFFE1BEE7),
                    fontSize: 9.5,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ],
            ),
          ),
          // Scale bar
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 3),
            decoration: BoxDecoration(
              color: Colors.black.withValues(alpha: 0.25),
              borderRadius: BorderRadius.circular(8),
              border: Border.all(color: Colors.white24, width: 0.8),
            ),
            child: const Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  'SCALE',
                  style: TextStyle(
                    color: Color(0xFFFFD54F),
                    fontSize: 7,
                    fontWeight: FontWeight.w900,
                  ),
                ),
                Text(
                  '0 ── 1 km',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 8,
                    fontWeight: FontWeight.w800,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildMapBackground() {
    return Image.asset(
      'assets/images/stitched_map.png',
      fit: BoxFit.cover,
      errorBuilder: (context, error, stackTrace) {
        return Image.asset(
          'assets/images/doranav_map.png',
          fit: BoxFit.cover,
          errorBuilder: (context, error, stackTrace) {
            return Image.asset(
              'assets/images/map_canvas.jpg',
              fit: BoxFit.cover,
              errorBuilder: (context, error, stackTrace) {
                // High fidelity vector terrain fallback
                return Container(
                  decoration: const BoxDecoration(
                    gradient: RadialGradient(
                      center: Alignment(0.2, -0.3),
                      radius: 1.2,
                      colors: [
                        Color(0xFF66BB6A), // Jungle Green
                        Color(0xFF2E7D32),
                        Color(0xFF1B5E20),
                      ],
                    ),
                  ),
                );
              },
            );
          },
        );
      },
    );
  }

  Widget _buildLocationPin(
    LocationNode loc, {
    required bool isCurrent,
    required bool isSelected,
    bool isNext = false,
    bool dimmed = false,
  }) {
    if (dimmed) {
      return const SizedBox.shrink();
    }

    final numMatch = RegExp(r'(\d+)').firstMatch(loc.id);
    final int? destNum = numMatch != null ? int.tryParse(numMatch.group(1)!) : null;
    final bool isMainDest = (destNum != null && destNum >= 1 && destNum <= 25) || loc.type == 'destination' || loc.start;
    final String badgeText = destNum != null ? destNum.toString().padLeft(2, '0') : loc.id.replaceAll('L', '');

    // Pin theme by region
    Color badgeColor;
    switch (loc.region.toLowerCase()) {
      case 'jungle':
        badgeColor = const Color(0xFF2E7D32);
        break;
      case 'mountains':
        badgeColor = const Color(0xFF283593);
        break;
      case 'coast':
        badgeColor = const Color(0xFF00838F);
        break;
      case 'desert':
        badgeColor = const Color(0xFFE65100);
        break;
      case 'valley':
        badgeColor = const Color(0xFF6A1B9A);
        break;
      default:
        badgeColor = const Color(0xFF880E4F);
    }

    if (isCurrent) {
      badgeColor = const Color(0xFF00C853);
    } else if (isSelected) {
      badgeColor = const Color(0xFFFF6D00);
    } else if (isNext) {
      badgeColor = const Color(0xFF00E5FF);
    }

    return GestureDetector(
      onTap: () {
        widget.onLocationSelected?.call(loc);
        if (isSelected || isMainDest) {
          DestinationVisualModal.show(context, location: loc);
        }
      },
      onLongPress: () {
        DestinationVisualModal.show(context, location: loc);
      },
      child: AnimatedBuilder(
        animation: _pulseController,
        builder: (context, _) {
          final pulse = (isSelected || isCurrent) ? _pulseController.value : 0.0;
          return Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              // Pin Badge
              Stack(
                alignment: Alignment.center,
                children: [
                  // Pulsing halo for current or selected
                  if (isSelected || isCurrent)
                    Container(
                      width: (isMainDest ? 36.0 : 26.0) + (pulse * 8),
                      height: (isMainDest ? 36.0 : 26.0) + (pulse * 8),
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        color: badgeColor.withValues(alpha: 0.35 * (1.0 - pulse)),
                      ),
                    ),
                  // Badge Head
                  Container(
                    width: isMainDest ? 26 : 18,
                    height: isMainDest ? 26 : 18,
                    decoration: BoxDecoration(
                      color: badgeColor,
                      shape: BoxShape.circle,
                      border: Border.all(
                        color: isSelected ? const Color(0xFFFFD54F) : Colors.white,
                        width: isMainDest ? 2.0 : 1.5,
                      ),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withValues(alpha: 0.4),
                          blurRadius: 5,
                          offset: const Offset(0, 2),
                        ),
                      ],
                    ),
                    child: Center(
                      child: isCurrent
                          ? const Icon(Icons.home_rounded, size: 14, color: Colors.white)
                          : (isMainDest
                              ? Text(
                                  badgeText,
                                  style: const TextStyle(
                                    color: Colors.white,
                                    fontSize: 10,
                                    fontWeight: FontWeight.w900,
                                  ),
                                )
                              : Container(
                                  width: 6,
                                  height: 6,
                                  decoration: const BoxDecoration(
                                    color: Colors.white,
                                    shape: BoxShape.circle,
                                  ),
                                )),
                    ),
                  ),
                ],
              ),
              // Location Label
              if (isMainDest || isSelected || isCurrent || isNext)
                Container(
                  margin: const EdgeInsets.only(top: 2),
                  padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 1.5),
                  decoration: BoxDecoration(
                    color: const Color(0xFF2E1B10).withValues(alpha: 0.88),
                    borderRadius: BorderRadius.circular(6),
                    border: Border.all(
                      color: isSelected ? const Color(0xFFFFD54F) : Colors.white.withValues(alpha: 0.4),
                      width: isSelected ? 1.2 : 0.8,
                    ),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withValues(alpha: 0.3),
                        blurRadius: 4,
                        offset: const Offset(0, 1),
                      ),
                    ],
                  ),
                  child: Text(
                    loc.name,
                    style: TextStyle(
                      color: isSelected ? const Color(0xFFFFE082) : Colors.white,
                      fontSize: 8.5,
                      fontWeight: FontWeight.w800,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
            ],
          );
        },
      ),
    );
  }

  Widget _buildDoraAvatar(double w, double h) {
    final cur = widget.currentLocation;
    final next = widget.nextLocation;

    final Offset pos;
    if (cur != null && next != null && widget.simulatedDoraPosition != null) {
      // Calculate progress between cur and next if possible
      final totalDist = math.sqrt(math.pow(next.x - cur.x, 2) + math.pow(next.y - cur.y, 2));
      final simDist = math.sqrt(math.pow(widget.simulatedDoraPosition!.dx - cur.x, 2) + math.pow(widget.simulatedDoraPosition!.dy - cur.y, 2));
      final progress = totalDist > 0 ? (simDist / totalDist).clamp(0.0, 1.0) : 0.0;
      pos = MapProjectionService.interpolatePosition(cur, next, progress, w, h);
    } else if (cur != null) {
      pos = MapProjectionService.nodeToPixel(cur, w, h);
    } else {
      pos = MapProjectionService.coordsToPixel(48, 110, w, h);
    }

    return Positioned(
      left: pos.dx - 18,
      top: pos.dy - 38,
      child: AnimatedBuilder(
        animation: _pulseController,
        builder: (context, child) {
          final scale = 0.95 + (_pulseController.value * 0.1);
          return Transform.scale(
            scale: scale,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Container(
                  width: 38,
                  height: 38,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    border: Border.all(color: Colors.white, width: 2),
                    boxShadow: [
                      BoxShadow(
                        color: const Color(0xFF00E676).withValues(alpha: 0.6),
                        blurRadius: 10,
                        spreadRadius: 2,
                      ),
                    ],
                  ),
                  clipBehavior: Clip.antiAlias,
                  child: Image.asset(
                    'assets/images/dora_avatar.png',
                    fit: BoxFit.cover,
                    errorBuilder: (context, error, stackTrace) => const Icon(
                      Icons.person_pin_circle_rounded,
                      color: Color(0xFFFF4081),
                      size: 28,
                    ),
                  ),
                ),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 1),
                  decoration: BoxDecoration(
                    color: const Color(0xFF00C853),
                    borderRadius: BorderRadius.circular(4),
                  ),
                  child: const Text(
                    "You're Here",
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 7.5,
                      fontWeight: FontWeight.w900,
                    ),
                  ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }

  Widget _buildSwiperRouteHazard(double w, double h) {
    LocationNode? targetLoc;

    if (widget.swiperLocation != null) {
      targetLoc = widget.swiperLocation;
    } else if (widget.swiperState?.currentLocationId != null) {
      final match = widget.locations.where((l) => l.id == widget.swiperState!.currentLocationId);
      if (match.isNotEmpty) targetLoc = match.first;
    } else if (widget.activeRoute != null && widget.activeRoute!.nodes.length > 2) {
      targetLoc = widget.activeRoute!.nodes[widget.activeRoute!.nodes.length ~/ 2];
    }

    final pos = targetLoc != null
        ? MapProjectionService.nodeToPixel(targetLoc, w, h)
        : MapProjectionService.coordsToPixel(105.0, 105.0, w, h);

    return Positioned(
      left: pos.dx - 16,
      top: pos.dy - 20,
      child: GestureDetector(
        onTap: widget.onSwiperTap,
        child: AnimatedBuilder(
          animation: _pulseController,
          builder: (context, child) {
            return Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                // Warning exclamation bubble
                Container(
                  padding: const EdgeInsets.all(3),
                  decoration: const BoxDecoration(
                    color: Color(0xFFFF1744),
                    shape: BoxShape.circle,
                    boxShadow: [
                      BoxShadow(
                        color: Color(0x88FF1744),
                        blurRadius: 8,
                        spreadRadius: 2,
                      ),
                    ],
                  ),
                  child: const Icon(
                    Icons.priority_high_rounded,
                    color: Colors.white,
                    size: 14,
                  ),
                ),
                const SizedBox(height: 2),
                // Swiper sneak avatar
                Container(
                  width: 32,
                  height: 32,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    border: Border.all(color: Colors.redAccent, width: 1.5),
                  ),
                  clipBehavior: Clip.antiAlias,
                  child: Image.asset(
                    'assets/images/swiper_warning.png',
                    fit: BoxFit.cover,
                    errorBuilder: (context, error, stackTrace) => const Icon(
                      Icons.warning_rounded,
                      color: Colors.orange,
                      size: 20,
                    ),
                  ),
                ),
              ],
            );
          },
        ),
      ),
    );
  }

  Widget _buildRoadBlockHazard(double w, double h) {
    LocationNode? targetLoc;

    if (widget.blockedNodeIds.isNotEmpty) {
      final blockedId = widget.blockedNodeIds.first;
      final match = widget.locations.where((l) => l.id == blockedId);
      if (match.isNotEmpty) targetLoc = match.first;
    } else if (widget.activeRoute != null && widget.activeRoute!.nodes.length > 2) {
      targetLoc = widget.activeRoute!.nodes[widget.activeRoute!.nodes.length ~/ 2];
    }

    final pos = targetLoc != null
        ? MapProjectionService.nodeToPixel(targetLoc, w, h)
        : MapProjectionService.coordsToPixel(100.0, 100.0, w, h);

    return Positioned(
      left: pos.dx - 18,
      top: pos.dy - 22,
      child: GestureDetector(
        onTap: widget.onRoadBlockTap,
        child: AnimatedBuilder(
          animation: _pulseController,
          builder: (context, child) {
            final bounce = math.sin(_pulseController.value * math.pi) * 3;
            return Transform.translate(
              offset: Offset(0, -bounce),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 5, vertical: 2),
                    decoration: BoxDecoration(
                      color: const Color(0xFFFF8F00),
                      borderRadius: BorderRadius.circular(10),
                      border: Border.all(color: Colors.white, width: 1.5),
                      boxShadow: [
                        BoxShadow(
                          color: const Color(0xFFFF6F00).withValues(alpha: 0.5),
                          blurRadius: 8,
                          spreadRadius: 1,
                        ),
                      ],
                    ),
                    child: const Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Text('🚧', style: TextStyle(fontSize: 14)),
                        SizedBox(width: 2),
                        Text(
                          'BLOCKED',
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 8,
                            fontWeight: FontWeight.w900,
                            letterSpacing: 0.5,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            );
          },
        ),
      ),
    );
  }

  Widget _buildMapControls() {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        // Compass Rose (Tap to reset rotation & center)
        GestureDetector(
          onTap: _recenter,
          child: Container(
            width: 38,
            height: 38,
            decoration: BoxDecoration(
              color: Colors.white.withValues(alpha: 0.92),
              shape: BoxShape.circle,
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withValues(alpha: 0.25),
                  blurRadius: 6,
                  offset: const Offset(0, 2),
                ),
              ],
            ),
            child: const Center(
              child: Icon(
                Icons.explore_rounded,
                color: Color(0xFF1E88E5),
                size: 26,
              ),
            ),
          ),
        ),
        const SizedBox(height: 10),

        // Zoom / Recenter / Legend Pill
        Container(
          decoration: BoxDecoration(
            color: Colors.white.withValues(alpha: 0.92),
            borderRadius: BorderRadius.circular(18),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: 0.25),
                blurRadius: 6,
                offset: const Offset(0, 2),
              ),
            ],
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              _buildHudButton(Icons.add_rounded, _zoomIn, 'Zoom In'),
              const Divider(height: 1, indent: 4, endIndent: 4),
              _buildHudButton(Icons.remove_rounded, _zoomOut, 'Zoom Out'),
              const Divider(height: 1, indent: 4, endIndent: 4),
              _buildHudButton(Icons.my_location_rounded, _recenter, 'Recenter'),
              const Divider(height: 1, indent: 4, endIndent: 4),
              _buildHudButton(
                Icons.menu_book_rounded,
                () {
                  MapLegendSheet.show(
                    context,
                    locations: widget.locations,
                    onDestinationSelected: (loc) {
                      widget.onLocationSelected?.call(loc);
                      final target = NavigationCameraService.focusOnLocation(
                        loc,
                        canvasSize: _lastCanvasSize,
                        zoom: 2.2,
                      );
                      _animateToMatrix(target);
                    },
                  );
                },
                'Map Legend & Directory',
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildHudButton(IconData icon, VoidCallback onPressed, String tooltip) {
    return IconButton(
      icon: Icon(icon, color: const Color(0xFF424242), size: 18),
      onPressed: onPressed,
      tooltip: tooltip,
      padding: const EdgeInsets.all(6),
      constraints: const BoxConstraints(),
    );
  }
}

class _RoutePainter extends CustomPainter {
  final List<RoadEdge> allRoads;
  final List<LocationNode> locations;
  final NavigationRoute? activeRoute;
  final NavigationRoute? alternativeRoute;
  final double pulseValue;
  final double canvasWidth;
  final double canvasHeight;
  final Set<String> blockedNodeIds;
  final bool isNavigating;

  _RoutePainter({
    this.allRoads = const [],
    this.locations = const [],
    required this.activeRoute,
    required this.alternativeRoute,
    required this.pulseValue,
    required this.canvasWidth,
    required this.canvasHeight,
    this.blockedNodeIds = const {},
    this.isNavigating = false,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final locMap = {for (final l in locations) l.id: l};

    // 1. Draw subtle biome-tinted non-route road network
    if (allRoads.isNotEmpty) {
      for (final road in allRoads) {
        final fromNode = locMap[road.fromId];
        final toNode = locMap[road.toId];
        if (fromNode == null || toNode == null) continue;

        final p1 = MapProjectionService.nodeToPixel(fromNode, canvasWidth, canvasHeight);
        final p2 = MapProjectionService.nodeToPixel(toNode, canvasWidth, canvasHeight);

        // Biome road color coding matching reference map
        Color roadBaseColor;
        final region = fromNode.region.toLowerCase();
        if (region.contains('jungle')) {
          roadBaseColor = const Color(0xFF4CAF50); // Jungle green
        } else if (region.contains('mountain')) {
          roadBaseColor = const Color(0xFF3F51B5); // Mountain indigo
        } else if (region.contains('coast') || region.contains('water')) {
          roadBaseColor = const Color(0xFF00BCD4); // Coastal cyan
        } else if (region.contains('desert')) {
          roadBaseColor = const Color(0xFFFF9800); // Desert orange
        } else if (region.contains('valley')) {
          roadBaseColor = const Color(0xFF9C27B0); // Royal purple
        } else {
          roadBaseColor = const Color(0xFFFFC107); // Gold town road
        }

        final nonRouteRoadPaint = Paint()
          ..color = roadBaseColor.withValues(alpha: isNavigating ? 0.20 : 0.45)
          ..style = PaintingStyle.stroke
          ..strokeCap = StrokeCap.round
          ..strokeWidth = isNavigating ? 1.8 : 2.6;

        canvas.drawLine(p1, p2, nonRouteRoadPaint);
      }
    }

    // 2. Draw alternative route (dashed bright cyan/amber)
    if (alternativeRoute != null && alternativeRoute!.nodes.length > 1) {
      final altPath = _createCurvedPath(alternativeRoute!.nodes);
      final altPaint = Paint()
        ..color = const Color(0xFF00E5FF).withValues(alpha: 0.85)
        ..style = PaintingStyle.stroke
        ..strokeCap = StrokeCap.round
        ..strokeWidth = 4.5;
      _drawDashedPath(canvas, altPath, altPaint);
    }

    // 3. Draw active main route (vibrant solid purple with neon cyan-gold glow)
    if (activeRoute != null && activeRoute!.nodes.length > 1) {
      final mainPath = _createCurvedPath(activeRoute!.nodes);

      // Outer animated pulse glow
      final glowPaint = Paint()
        ..color = const Color(0xFFFFD54F).withValues(alpha: 0.35 + (pulseValue * 0.30))
        ..style = PaintingStyle.stroke
        ..strokeWidth = 12.0 + (pulseValue * 4.0)
        ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 7);
      canvas.drawPath(mainPath, glowPaint);

      // Main thick route stroke (bold Dora purple)
      final strokePaint = Paint()
        ..color = const Color(0xFF7E57C2)
        ..style = PaintingStyle.stroke
        ..strokeCap = StrokeCap.round
        ..strokeJoin = StrokeJoin.round
        ..strokeWidth = 6.5;
      canvas.drawPath(mainPath, strokePaint);

      // Inner bright neon white/cyan center highlight
      final corePaint = Paint()
        ..color = const Color(0xFFEDE7F6)
        ..style = PaintingStyle.stroke
        ..strokeCap = StrokeCap.round
        ..strokeWidth = 2.5;
      canvas.drawPath(mainPath, corePaint);
    }
  }

  Path _createCurvedPath(List<LocationNode> nodes) {
    final path = Path();
    if (nodes.isEmpty) return path;

    final first = MapProjectionService.nodeToPixel(nodes[0], canvasWidth, canvasHeight);
    path.moveTo(first.dx, first.dy);

    for (int i = 0; i < nodes.length - 1; i++) {
      final p1 = MapProjectionService.nodeToPixel(nodes[i], canvasWidth, canvasHeight);
      final p2 = MapProjectionService.nodeToPixel(nodes[i + 1], canvasWidth, canvasHeight);

      // Smooth bezier curve for organic path feeling
      final midX = (p1.dx + p2.dx) / 2;
      final midY = (p1.dy + p2.dy) / 2;
      path.quadraticBezierTo(p1.dx, p1.dy, midX, midY);
    }

    final last = MapProjectionService.nodeToPixel(nodes.last, canvasWidth, canvasHeight);
    path.lineTo(last.dx, last.dy);
    return path;
  }

  void _drawDashedPath(Canvas canvas, Path path, Paint paint) {
    const dashWidth = 8.0;
    const dashSpace = 6.0;

    for (final metric in path.computeMetrics()) {
      double distance = 0.0;
      while (distance < metric.length) {
        final len = math.min(dashWidth, metric.length - distance);
        canvas.drawPath(metric.extractPath(distance, distance + len), paint);
        distance += dashWidth + dashSpace;
      }
    }
  }

  @override
  bool shouldRepaint(covariant _RoutePainter oldDelegate) => true;
}
