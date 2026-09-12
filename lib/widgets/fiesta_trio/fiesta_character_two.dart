import 'dart:math' as math;
import 'package:flutter/material.dart';

/// Character 2: Orange Grasshopper with Accordion (Center character in Fiesta Trio video).
///
/// Animation Specs (from trio video reference):
/// - Entrance: Pops upward from slightly below with ScaleTransition + FadeTransition
///   and playful bounce (Curves.elasticOut).
/// - Performance: Squeezing and expanding the accordion bellows horizontally,
///   animated head nodding, vertical cheerful spring bounce.
class FiestaCharacterTwo extends StatelessWidget {
  final Animation<double> entranceScale;
  final Animation<double> entranceFade;
  final Animation<Offset> entranceSlide;
  final Animation<double> bodyBounce;
  final Animation<double> performanceLoop; // Continuous 0.0 -> 1.0 loop
  final double width;
  final double height;
  final String? assetPath;

  const FiestaCharacterTwo({
    super.key,
    required this.entranceScale,
    required this.entranceFade,
    required this.entranceSlide,
    required this.bodyBounce,
    required this.performanceLoop,
    this.width = 125.0,
    this.height = 155.0,
    this.assetPath = 'assets/images/fiesta/fiesta_character_two.png',
  });

  @override
  Widget build(BuildContext context) {
    return SlideTransition(
      position: entranceSlide,
      child: FadeTransition(
        opacity: entranceFade,
        child: ScaleTransition(
          scale: entranceScale,
          child: AnimatedBuilder(
            animation: Listenable.merge([bodyBounce, performanceLoop]),
            builder: (context, child) {
              final p = performanceLoop.value;
              // Bouncy upbeat motion
              final bounceY = -math.sin((p + 0.25) * 2 * math.pi).abs() * 14.0;
              // Accordion bellows breathing expansion
              final accordionSqueeze = 1.0 + 0.06 * math.sin(p * 4 * math.pi);
              final headTilt = math.sin((p + 0.25) * 2 * math.pi) * 0.06;

              return Transform.translate(
                offset: Offset(0, bounceY * bodyBounce.value),
                child: Transform.rotate(
                  angle: headTilt * bodyBounce.value,
                  child: Transform.scale(
                    scale: accordionSqueeze,
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
                                : 'assets/images/fiesta/fiesta_character_two.png',
                            width: width,
                            height: height,
                            fit: BoxFit.contain,
                            errorBuilder: (context, error, stackTrace) => _buildPlaceholder(),
                          ),

                          // Musical Sparkle above accordion
                          if (performanceLoop.value > 0)
                            Positioned(
                              top: 6,
                              left: 10,
                              child: Opacity(
                                opacity: (math.sin((p + 0.5) * 4 * math.pi).abs()).clamp(0.0, 0.9),
                                child: const Text('✨', style: TextStyle(fontSize: 16)),
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
        ),
      ),
    );
  }

  Widget _buildPlaceholder() {
    return Container(
      width: width,
      height: height,
      decoration: BoxDecoration(
        color: const Color(0xFFFF9800),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: Colors.white, width: 2),
        boxShadow: const [BoxShadow(color: Colors.black26, blurRadius: 8)],
      ),
      child: const Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Text('🦗', style: TextStyle(fontSize: 36)),
          SizedBox(height: 4),
          Text('🪗 Grasshopper', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 11)),
        ],
      ),
    );
  }
}
