import 'dart:math' as math;
import 'package:flutter/material.dart';

/// Character 3: Pink Snail with Brass Cymbals (Right character in Fiesta Trio video).
///
/// Animation Specs (from trio video reference):
/// - Entrance: Slides in from right (300 to 900ms) with bouncy easing (Curves.easeOutBack).
/// - Performance: Rhythmic cymbal clashing action, shell bob, side-to-side joy sway,
///   sparkle ring emissions on each cymbal clap.
class FiestaCharacterThree extends StatelessWidget {
  final Animation<Offset> entranceSlide;
  final Animation<double> bodyBounce;
  final Animation<double> performanceLoop; // Continuous 0.0 -> 1.0 loop
  final double width;
  final double height;
  final String? assetPath;

  const FiestaCharacterThree({
    super.key,
    required this.entranceSlide,
    required this.bodyBounce,
    required this.performanceLoop,
    this.width = 115.0,
    this.height = 145.0,
    this.assetPath = 'assets/images/fiesta/fiesta_character_three.png',
  });

  @override
  Widget build(BuildContext context) {
    return SlideTransition(
      position: entranceSlide,
      child: AnimatedBuilder(
        animation: Listenable.merge([bodyBounce, performanceLoop]),
        builder: (context, child) {
          final p = performanceLoop.value;
          final bounceY = -math.sin((p + 0.5) * 2 * math.pi).abs() * 11.0;
          final swayAngle = math.sin((p + 0.5) * 2 * math.pi) * 0.09;
          final pulse = 1.0 + 0.05 * math.sin((p + 0.5) * 4 * math.pi);

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
                            : 'assets/images/fiesta/fiesta_character_three.png',
                        width: width,
                        height: height,
                        fit: BoxFit.contain,
                        errorBuilder: (context, error, stackTrace) => _buildPlaceholder(),
                      ),

                      // Cymbal clash acoustic wave
                      if (performanceLoop.value > 0)
                        Positioned(
                          left: 12,
                          bottom: 24,
                          child: Opacity(
                            opacity: (math.sin((p + 0.2) * 4 * math.pi).abs()).clamp(0.0, 0.9),
                            child: const Text('🔔', style: TextStyle(fontSize: 14)),
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
        color: const Color(0xFFE91E63),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: Colors.white, width: 2),
        boxShadow: const [BoxShadow(color: Colors.black26, blurRadius: 8)],
      ),
      child: const Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Text('🐌', style: TextStyle(fontSize: 36)),
          SizedBox(height: 4),
          Text('🔔 Snail', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 12)),
        ],
      ),
    );
  }
}
