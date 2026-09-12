import 'package:flutter/material.dart';
import '../../map/models/map_models.dart';

/// Presentation data for the obstacle alert popup.
class ObstaclePopupData {
  final DynamicObstacleType obstacleType;
  final String title;
  final String description;
  final String icon;
  final bool rerouting;
  final bool newRouteFound;
  final bool noRouteAvailable;
  final bool routeAvailable;

  const ObstaclePopupData({
    required this.obstacleType,
    required this.title,
    required this.description,
    required this.icon,
    this.rerouting = false,
    this.newRouteFound = false,
    this.noRouteAvailable = false,
    this.routeAvailable = false,
  });

  ObstaclePopupData copyWith({
    DynamicObstacleType? obstacleType,
    String? title,
    String? description,
    String? icon,
    bool? rerouting,
    bool? newRouteFound,
    bool? noRouteAvailable,
    bool? routeAvailable,
  }) {
    return ObstaclePopupData(
      obstacleType: obstacleType ?? this.obstacleType,
      title: title ?? this.title,
      description: description ?? this.description,
      icon: icon ?? this.icon,
      rerouting: rerouting ?? this.rerouting,
      newRouteFound: newRouteFound ?? this.newRouteFound,
      noRouteAvailable: noRouteAvailable ?? this.noRouteAvailable,
      routeAvailable: routeAvailable ?? this.routeAvailable,
    );
  }

  /// Factory constructors for each required obstacle alert popup
  factory ObstaclePopupData.forObstacle(DynamicObstacle obstacle, {bool rerouting = true}) {
    switch (obstacle.type) {
      case DynamicObstacleType.swiper:
        return ObstaclePopupData(
          obstacleType: obstacle.type,
          title: '⚠ SWIPER AHEAD! 🦊',
          description: 'Swiper is blocking your current route.',
          icon: '🦊',
          rerouting: rerouting,
        );
      case DynamicObstacleType.crocodile:
        return ObstaclePopupData(
          obstacleType: obstacle.type,
          title: '🐊 CROCODILE ALERT!',
          description: 'A crocodile is blocking the route ahead.\nFinding another way!',
          icon: '🐊',
          rerouting: rerouting,
        );
      case DynamicObstacleType.fallenTree:
        return ObstaclePopupData(
          obstacleType: obstacle.type,
          title: '🌳 PATH BLOCKED!',
          description: 'A fallen tree is blocking the road.\nFinding another route!',
          icon: '🌳',
          rerouting: rerouting,
        );
      case DynamicObstacleType.rockslide:
        return ObstaclePopupData(
          obstacleType: obstacle.type,
          title: '🪨 ROCKSLIDE AHEAD!',
          description: 'The mountain path is blocked.\nFinding another way!',
          icon: '🪨',
          rerouting: rerouting,
        );
    }
  }

  factory ObstaclePopupData.noRoute({DynamicObstacleType type = DynamicObstacleType.swiper}) {
    return ObstaclePopupData(
      obstacleType: type,
      title: '😟 No Safe Route Available',
      description: 'Too many obstacles are blocking the way.\nLet\'s wait for a path to open!',
      icon: '😟',
      noRouteAvailable: true,
    );
  }

  factory ObstaclePopupData.routeAvailable({DynamicObstacleType type = DynamicObstacleType.swiper}) {
    return ObstaclePopupData(
      obstacleType: type,
      title: '🎉 Route Available!',
      description: 'A path has cleared! Resuming our adventure.',
      icon: '🌟',
      routeAvailable: true,
    );
  }
}

/// Reusable animated alert popup for dynamic obstacles on Dora's active route:
/// 1. Scales in (0.85 -> 1.0) with bounce and fade
/// 2. Displays distinct themed title, description, and icon per obstacle type
/// 3. Shows "Finding a safer route..." with spinner
/// 4. Smoothly updates to "New route found!" when A* finishes
/// 5. Automatically dismisses without requiring a user tap
class ObstacleAlertPopup extends StatefulWidget {
  final DynamicObstacleType obstacleType;
  final String title;
  final String description;
  final String icon;
  final bool rerouting;
  final bool newRouteFound;
  final bool noRouteAvailable;
  final bool routeAvailable;
  final VoidCallback? onDismissed;

  const ObstacleAlertPopup({
    super.key,
    required this.obstacleType,
    required this.title,
    required this.description,
    required this.icon,
    this.rerouting = false,
    this.newRouteFound = false,
    this.noRouteAvailable = false,
    this.routeAvailable = false,
    this.onDismissed,
  });

  @override
  State<ObstacleAlertPopup> createState() => _ObstacleAlertPopupState();
}

class _ObstacleAlertPopupState extends State<ObstacleAlertPopup> with SingleTickerProviderStateMixin {
  late AnimationController _animController;
  late Animation<double> _scaleAnimation;
  late Animation<double> _fadeAnimation;

  @override
  void initState() {
    super.initState();
    _animController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 380),
    );

    _scaleAnimation = CurvedAnimation(
      parent: _animController,
      curve: Curves.easeOutBack,
    );

    _fadeAnimation = CurvedAnimation(
      parent: _animController,
      curve: Curves.easeIn,
    );

    _animController.forward();
  }

  @override
  void dispose() {
    _animController.dispose();
    super.dispose();
  }

  Color get _accentColor {
    switch (widget.obstacleType) {
      case DynamicObstacleType.swiper:
        return const Color(0xFFFF6D00); // Fox orange
      case DynamicObstacleType.crocodile:
        return const Color(0xFF2E7D32); // Croc green
      case DynamicObstacleType.fallenTree:
        return const Color(0xFF8D6E63); // Tree brown
      case DynamicObstacleType.rockslide:
        return const Color(0xFF5E35B1); // Rockslide slate purple
    }
  }

  List<Color> get _backgroundGradient {
    if (widget.noRouteAvailable) {
      return const [Color(0xFFFFF3E0), Color(0xFFFFFFFF)];
    }
    if (widget.newRouteFound || widget.routeAvailable) {
      return const [Color(0xFFE8F5E9), Color(0xFFFFFFFF)];
    }
    switch (widget.obstacleType) {
      case DynamicObstacleType.swiper:
        return const [Color(0xFFFFF8E1), Color(0xFFFFFFFF)];
      case DynamicObstacleType.crocodile:
        return const [Color(0xFFE8F8F5), Color(0xFFFFFFFF)];
      case DynamicObstacleType.fallenTree:
        return const [Color(0xFFEFEBE9), Color(0xFFFFFFFF)];
      case DynamicObstacleType.rockslide:
        return const [Color(0xFFEDE7F6), Color(0xFFFFFFFF)];
    }
  }

  @override
  Widget build(BuildContext context) {
    return FadeTransition(
      opacity: _fadeAnimation,
      child: ScaleTransition(
        scale: _scaleAnimation,
        child: Container(
          constraints: const BoxConstraints(maxWidth: 340),
          margin: const EdgeInsets.symmetric(horizontal: 16),
          padding: const EdgeInsets.fromLTRB(16, 14, 16, 14),
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: _backgroundGradient,
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
            ),
            borderRadius: BorderRadius.circular(22),
            border: Border.all(color: _accentColor, width: 2.2),
            boxShadow: [
              BoxShadow(
                color: _accentColor.withValues(alpha: 0.28),
                blurRadius: 18,
                offset: const Offset(0, 6),
              ),
              BoxShadow(
                color: Colors.black.withValues(alpha: 0.15),
                blurRadius: 8,
                offset: const Offset(0, 2),
              ),
            ],
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              // Header with animated badge icon & title
              Row(
                children: [
                  Container(
                    width: 44,
                    height: 44,
                    decoration: BoxDecoration(
                      color: _accentColor.withValues(alpha: 0.14),
                      shape: BoxShape.circle,
                      border: Border.all(color: _accentColor.withValues(alpha: 0.4), width: 1.5),
                    ),
                    alignment: Alignment.center,
                    child: Text(
                      widget.icon,
                      style: const TextStyle(fontSize: 24),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          widget.title,
                          style: TextStyle(
                            color: _accentColor,
                            fontSize: 15.5,
                            fontWeight: FontWeight.w900,
                            letterSpacing: 0.3,
                          ),
                        ),
                        const SizedBox(height: 2),
                        Text(
                          widget.description,
                          style: const TextStyle(
                            color: Color(0xFF37474F),
                            fontSize: 12.5,
                            fontWeight: FontWeight.w600,
                            height: 1.25,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 10),

              // Status State Indicator Box
              if (widget.rerouting) ...[
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 7),
                  decoration: BoxDecoration(
                    color: const Color(0xFF7B61FF).withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: const Color(0xFF7B61FF).withValues(alpha: 0.4), width: 1.2),
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      const SizedBox(
                        width: 14,
                        height: 14,
                        child: CircularProgressIndicator(
                          strokeWidth: 2.2,
                          valueColor: AlwaysStoppedAnimation<Color>(Color(0xFF7B61FF)),
                        ),
                      ),
                      const SizedBox(width: 8),
                      const Flexible(
                        child: Text(
                          'Finding a safer route...',
                          style: TextStyle(
                            color: Color(0xFF5E35B1),
                            fontSize: 12,
                            fontWeight: FontWeight.w800,
                          ),
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                    ],
                  ),
                ),
              ] else if (widget.newRouteFound) ...[
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 7),
                  decoration: BoxDecoration(
                    color: const Color(0xFF4CAF50).withValues(alpha: 0.15),
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: const Color(0xFF4CAF50), width: 1.4),
                  ),
                  child: const Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(Icons.check_circle_rounded, color: Color(0xFF2E7D32), size: 16),
                      SizedBox(width: 6),
                      Flexible(
                        child: Text(
                          'New route found!',
                          style: TextStyle(
                            color: Color(0xFF1B5E20),
                            fontSize: 12.5,
                            fontWeight: FontWeight.w900,
                          ),
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                    ],
                  ),
                ),
              ] else if (widget.noRouteAvailable) ...[
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 7),
                  decoration: BoxDecoration(
                    color: const Color(0xFFE53935).withValues(alpha: 0.12),
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: const Color(0xFFE53935), width: 1.4),
                  ),
                  child: const Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(Icons.pause_circle_filled_rounded, color: Color(0xFFC62828), size: 16),
                      SizedBox(width: 6),
                      Flexible(
                        child: Text(
                          'Waiting for a path to open...',
                          style: TextStyle(
                            color: Color(0xFFB71C1C),
                            fontSize: 12,
                            fontWeight: FontWeight.w800,
                          ),
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                    ],
                  ),
                ),
              ] else if (widget.routeAvailable) ...[
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 7),
                  decoration: BoxDecoration(
                    color: const Color(0xFF00ACC1).withValues(alpha: 0.15),
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: const Color(0xFF00ACC1), width: 1.4),
                  ),
                  child: const Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(Icons.play_circle_fill_rounded, color: Color(0xFF00838F), size: 16),
                      SizedBox(width: 6),
                      Flexible(
                        child: Text(
                          'Route Available! Resuming...',
                          style: TextStyle(
                            color: Color(0xFF006064),
                            fontSize: 12.5,
                            fontWeight: FontWeight.w900,
                          ),
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }
}
