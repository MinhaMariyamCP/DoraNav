import 'package:flutter/material.dart';
import '../models/map_models.dart';

/// Animated widget for rendering any of the 4 dynamic obstacle types on the map:
/// - Swiper (special animated sneak movement & alert pulse)
/// - Crocodile (river/road hazard with snapping jaws)
/// - Fallen Tree (fallen log with branches across trail)
/// - Rockslide (tumbled boulders with dust particles)
class DynamicObstacleWidget extends StatelessWidget {
  final DynamicObstacle obstacle;
  final VoidCallback? onTap;
  final double pulseValue;

  const DynamicObstacleWidget({
    super.key,
    required this.obstacle,
    this.onTap,
    this.pulseValue = 0.0,
  });

  @override
  Widget build(BuildContext context) {
    if (!obstacle.active) return const SizedBox.shrink();

    return GestureDetector(
      onTap: onTap,
      child: Stack(
        alignment: Alignment.center,
        clipBehavior: Clip.none,
        children: [
          // 1. Radiant pulsing risk halo
          Container(
            width: 44 + (pulseValue * 12),
            height: 44 + (pulseValue * 12),
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: _getObstacleColor().withValues(alpha: 0.28 * (1.0 - pulseValue)),
            ),
          ),

          // 2. Obstacle Main Body
          Container(
            width: 38,
            height: 38,
            decoration: BoxDecoration(
              color: Colors.white,
              shape: BoxShape.circle,
              border: Border.all(color: _getObstacleColor(), width: 2.0),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withValues(alpha: 0.35),
                  blurRadius: 6,
                  offset: const Offset(0, 2),
                ),
              ],
            ),
            child: Center(
              child: Text(
                _getObstacleEmoji(),
                style: const TextStyle(fontSize: 20),
              ),
            ),
          ),

          // 3. Status Badge Label
          Positioned(
            bottom: -14,
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 5, vertical: 1.5),
              decoration: BoxDecoration(
                color: _getObstacleColor(),
                borderRadius: BorderRadius.circular(8),
                boxShadow: const [BoxShadow(color: Colors.black26, blurRadius: 4)],
              ),
              child: Text(
                _getObstacleLabel(),
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 7.5,
                  fontWeight: FontWeight.w900,
                  letterSpacing: 0.4,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Color _getObstacleColor() {
    switch (obstacle.type) {
      case DynamicObstacleType.swiper:
        return const Color(0xFFD32F2F); // Swiper Red
      case DynamicObstacleType.crocodile:
        return const Color(0xFF2E7D32); // Croc Green
      case DynamicObstacleType.fallenTree:
        return const Color(0xFF795548); // Wood Brown
      case DynamicObstacleType.rockslide:
        return const Color(0xFFE65100); // Rock Orange
    }
  }

  String _getObstacleEmoji() {
    switch (obstacle.type) {
      case DynamicObstacleType.swiper:
        return '🦊';
      case DynamicObstacleType.crocodile:
        return '🐊';
      case DynamicObstacleType.fallenTree:
        return '🪵';
      case DynamicObstacleType.rockslide:
        return '🪨';
    }
  }

  String _getObstacleLabel() {
    switch (obstacle.type) {
      case DynamicObstacleType.swiper:
        return 'SWIPER';
      case DynamicObstacleType.crocodile:
        return 'CROC';
      case DynamicObstacleType.fallenTree:
        return 'LOG';
      case DynamicObstacleType.rockslide:
        return 'ROCKS';
    }
  }
}
