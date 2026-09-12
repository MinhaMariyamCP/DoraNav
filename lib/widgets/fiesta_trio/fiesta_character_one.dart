import 'dart:math' as math;
import 'package:flutter/material.dart';

/// Character 1: Blue Frog Drummer (Left character in Fiesta Trio video).
///
/// Animation Specs (from trio video reference):
/// - Entrance: Slides in from left (0 to 800ms) with slight overshoot bounce (Curves.easeOutBack).
/// - Performance: Side-to-side body rock, rhythmic up-down bouncing,
///   alternating drumstick beat strikes synchronized with drum impact vibration.
class FiestaCharacterOne extends StatelessWidget {
  final Animation<Offset> entranceSlide;
  final Animation<double> bodyBounce;
  final Animation<double> performanceLoop; // Continuous 0.0 -> 1.0 loop
  final double width;
  final double height;
  final String? assetPath;

  const FiestaCharacterOne({
    super.key,
    required this.entranceSlide,
    required this.bodyBounce,
    required this.performanceLoop,
    this.width = 115.0,
    this.height = 145.0,
    this.assetPath = 'assets/images/fiesta/fiesta_character_one.png',
  });

  @override
  Widget build(BuildContext context) {
    return SlideTransition(
      position: entranceSlide,
      child: AnimatedBuilder(
        animation: Listenable.merge([bodyBounce, performanceLoop]),
        builder: (context, child) {
          final p = performanceLoop.value;
          final bounceY = -math.sin(p * 2 * math.pi).abs() * 10.0;
          final swayAngle = math.sin(p * 2 * math.pi) * 0.08;
          final pulse = 1.0 + 0.04 * math.sin(p * 4 * math.pi);

          return Transform.translate(
            offset: Offset(0, bounceY * bodyBounce.value),
            child: Transform.rotate(
              angle: swayAngle * bodyBounce.value,
              child: Transform.scale(
                scale: pulse,
                child: SizedBox(
                  width: width,
                  height: height,
                  child: Stack(
                    alignment: Alignment.center,
                    clipBehavior: Clip.none,
                    children: [
                      // Character Visual
                      Image.asset(
                        (assetPath != null && assetPath!.isNotEmpty)
                            ? assetPath!
                            : 'assets/images/fiesta/fiesta_character_one.png',
                        width: width,
                        height: height,
                        fit: BoxFit.contain,
                        errorBuilder: (context, error, stackTrace) => _buildPlaceholder(),
                      ),

                      // Rhythmic musical pulse effect from drum
                      if (performanceLoop.value > 0)
                        Positioned(
                          bottom: 2,
                          right: 18,
                          child: Opacity(
                            opacity: (math.sin(p * 4 * math.pi).abs()).clamp(0.0, 0.85),
                            child: Transform.scale(
                              scale: 0.6 + (0.5 * math.sin(p * 4 * math.pi).abs()),
                              child: const Text('💥', style: TextStyle(fontSize: 14)),
                            ),
                          ),
                        ),
                    ],
                  ),
                ),
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _buildPlaceholder() {
    return Container(
      width: width,
      height: height,
      decoration: BoxDecoration(
        color: const Color(0xFF3F51B5),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: Colors.white, width: 2),
        boxShadow: const [BoxShadow(color: Colors.black26, blurRadius: 8)],
      ),
      child: const Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Text('🐸', style: TextStyle(fontSize: 36)),
          SizedBox(height: 4),
          Text('🥁 Frog', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 12)),
        ],
      ),
    );
  }
}
