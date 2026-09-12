import 'dart:math' as math;
import 'package:flutter/material.dart';

/// Animated instrument widget providing vivid playing motion for each Fiesta Trio member:
/// 1. [FrogTrumpetVisual]: Frog blowing the golden trumpet with puffed cheeks, oscillating bell angle, and musical sound rings.
/// 2. [SnailDrumVisual]: Snail hammering the drum with alternating mallets and vibration ripple rings.
/// 3. [GrasshopperTriangleVisual]: Grasshopper striking the musical triangle with a metallic ding striker and chime sparkles.

enum FiestaInstrumentType {
  trumpet,
  drum,
  triangle,
}

/// Trumpet / Horn performance with animated sound wave blasts
class FrogTrumpetVisual extends StatelessWidget {
  final double playProgress; // 0.0 to 1.0 looping
  final double size;

  const FrogTrumpetVisual({
    super.key,
    required this.playProgress,
    this.size = 70.0,
  });

  @override
  Widget build(BuildContext context) {
    // Blast wave pulse
    final blastProgress = (playProgress * 2.5) % 1.0;
    // Cheeks & horn puff scale
    final puff = 1.0 + 0.12 * math.sin(playProgress * 4 * math.pi);
    // Horn tilt oscillation
    final hornTilt = -0.15 + 0.12 * math.sin(playProgress * 4 * math.pi);

    return SizedBox(
      width: size,
      height: size * 0.75,
      child: Stack(
        clipBehavior: Clip.none,
        alignment: Alignment.center,
        children: [
          // Sound blast rings expanding outwards from trumpet bell
          Positioned(
            left: size * 0.58,
            top: size * 0.10,
            child: Opacity(
              opacity: (1.0 - blastProgress).clamp(0.0, 1.0),
              child: Transform.scale(
                scale: 0.3 + (blastProgress * 1.0),
                child: Container(
                  width: 24,
                  height: 24,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    border: Border.all(
                      color: const Color(0xFFFFD700).withValues(alpha: 0.9),
                      width: 2.5,
                    ),
                  ),
                ),
              ),
            ),
          ),

          // Musical note blowing out of trumpet
          Positioned(
            left: size * 0.62 + (blastProgress * 16),
            top: size * 0.04 - (blastProgress * 12),
            child: Opacity(
              opacity: (1.0 - blastProgress).clamp(0.0, 1.0),
              child: Transform.rotate(
                angle: blastProgress * 0.4,
                child: const Text(
                  '🎺',
                  style: TextStyle(fontSize: 16),
                ),
              ),
            ),
          ),

          // Main Trumpet Bell & Body
          Transform.rotate(
            angle: hornTilt,
            child: Transform.scale(
              scale: puff,
              child: Container(
                width: size * 0.65,
                height: size * 0.38,
                decoration: BoxDecoration(
                  gradient: const LinearGradient(
                    colors: [Color(0xFFFFD54F), Color(0xFFFFB300), Color(0xFFFFA000)],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                  borderRadius: const BorderRadius.horizontal(
                    left: Radius.circular(6),
                    right: Radius.circular(18),
                  ),
                  border: Border.all(color: const Color(0xFFFFF9C4), width: 1.5),
                  boxShadow: [
                    BoxShadow(
                      color: const Color(0xFFFFB300).withValues(alpha: 0.6),
                      blurRadius: 8,
                      spreadRadius: 1,
                    ),
                  ],
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    // Mouthpiece
                    Container(
                      width: 6,
                      height: 10,
                      decoration: BoxDecoration(
                        color: const Color(0xFFFF8F00),
                        borderRadius: BorderRadius.circular(2),
                      ),
                    ),
                    // Valves
                    Flexible(
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: List.generate(3, (i) {
                          final pressed = (math.sin(playProgress * 8 * math.pi + (i * 1.5)) > 0);
                          return Container(
                            width: 4,
                            height: pressed ? 8 : 12,
                            margin: const EdgeInsets.symmetric(horizontal: 1),
                            decoration: BoxDecoration(
                              color: const Color(0xFFFFF176),
                              borderRadius: BorderRadius.circular(2),
                              border: Border.all(color: const Color(0xFFE65100), width: 0.8),
                            ),
                          );
                        }),
                      ),
                    ),
                    // Flared Horn Bell
                    Container(
                      width: 14,
                      height: 24,
                      decoration: const BoxDecoration(
                        color: Color(0xFFFFD54F),
                        borderRadius: BorderRadius.horizontal(right: Radius.circular(14)),
                        border: Border(
                          right: BorderSide(color: Color(0xFFFFF9C4), width: 2),
                        ),
                      ),
                      child: const Center(
                        child: Text('✨', style: TextStyle(fontSize: 8)),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

/// Snail Drum with animated left and right mallet strikes
class SnailDrumVisual extends StatelessWidget {
  final double playProgress; // 0.0 to 1.0 looping
  final double size;

  const SnailDrumVisual({
    super.key,
    required this.playProgress,
    this.size = 75.0,
  });

  @override
  Widget build(BuildContext context) {
    // Alternating drum strikes
    final leftStrike = math.sin(playProgress * 6 * math.pi).clamp(-1.0, 1.0);
    final rightStrike = -leftStrike;

    // Drum bounce vibration
    final drumVibe = (leftStrike.abs() > 0.6) ? 2.5 : 0.0;

    return SizedBox(
      width: size,
      height: size * 0.8,
      child: Stack(
        clipBehavior: Clip.none,
        alignment: Alignment.center,
        children: [
          // Drum strike impact ripples
          if (drumVibe > 0)
            Positioned(
              top: size * 0.18,
              child: Container(
                width: size * 0.68,
                height: 14,
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(
                    color: const Color(0xFFFFD54F).withValues(alpha: 0.8),
                    width: 1.5,
                  ),
                ),
              ),
            ),

          // Snare Drum Body
          Transform.translate(
            offset: Offset(0, drumVibe),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                // Drum Head (Top Rim)
                Container(
                  width: size * 0.72,
                  height: 16,
                  decoration: BoxDecoration(
                    color: const Color(0xFFFFF9C4),
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(color: const Color(0xFFD32F2F), width: 2),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withValues(alpha: 0.2),
                        blurRadius: 3,
                        offset: const Offset(0, 1),
                      ),
                    ],
                  ),
                  child: const Center(
                    child: Text('🥁', style: TextStyle(fontSize: 10)),
                  ),
                ),

                // Drum Cylinder with Festive Zig-Zag cord
                Container(
                  width: size * 0.66,
                  height: 26,
                  decoration: BoxDecoration(
                    gradient: const LinearGradient(
                      colors: [Color(0xFFE53935), Color(0xFFC62828)],
                      begin: Alignment.topCenter,
                      end: Alignment.bottomCenter,
                    ),
                    borderRadius: const BorderRadius.vertical(bottom: Radius.circular(6)),
                    border: Border.all(color: const Color(0xFFFFD54F), width: 1.5),
                    boxShadow: [
                      BoxShadow(
                        color: const Color(0xFFE53935).withValues(alpha: 0.4),
                        blurRadius: 6,
                        offset: const Offset(0, 3),
                      ),
                    ],
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                    children: List.generate(4, (i) {
                      return Transform.rotate(
                        angle: (i.isEven ? 0.2 : -0.2),
                        child: Container(
                          width: 2,
                          height: 22,
                          color: const Color(0xFFFFEB3B),
                        ),
                      );
                    }),
                  ),
                ),
              ],
            ),
          ),

          // Left Drumstick / Mallet
          Positioned(
            left: size * 0.08,
            top: size * 0.10 - (leftStrike * 8),
            child: Transform.rotate(
              angle: 0.35 + (leftStrike * 0.3),
              child: _buildMallet(),
            ),
          ),

          // Right Drumstick / Mallet
          Positioned(
            right: size * 0.08,
            top: size * 0.10 - (rightStrike * 8),
            child: Transform.rotate(
              angle: -0.35 - (rightStrike * 0.3),
              child: _buildMallet(),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildMallet() {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        // Yellow ball tip
        Container(
          width: 10,
          height: 10,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            color: const Color(0xFFFFEB3B),
            border: Border.all(color: const Color(0xFFF57F17), width: 1),
          ),
        ),
        // Wooden stick
        Container(
          width: 3,
          height: 22,
          decoration: BoxDecoration(
            color: const Color(0xFF8D6E63),
            borderRadius: BorderRadius.circular(1.5),
          ),
        ),
      ],
    );
  }
}

/// Grasshopper Musical Triangle with metallic wand strike & chime sparkle
class GrasshopperTriangleVisual extends StatelessWidget {
  final double playProgress; // 0.0 to 1.0 looping
  final double size;

  const GrasshopperTriangleVisual({
    super.key,
    required this.playProgress,
    this.size = 65.0,
  });

  @override
  Widget build(BuildContext context) {
    // Striker tap cycle (strikes every beat)
    final tapCycle = math.sin(playProgress * 8 * math.pi);
    final isStriking = tapCycle > 0.65;
    // Chime sparkle animation
    final chimeProgress = (playProgress * 4) % 1.0;

    return SizedBox(
      width: size,
      height: size * 0.8,
      child: Stack(
        clipBehavior: Clip.none,
        alignment: Alignment.center,
        children: [
          // Triangle Chime Wave
          if (isStriking)
            Positioned(
              right: size * 0.20,
              top: size * 0.15,
              child: Opacity(
                opacity: (1.0 - chimeProgress).clamp(0.0, 1.0),
                child: const Text('✨', style: TextStyle(fontSize: 14)),
              ),
            ),

          // Metallic Triangle Frame
          CustomPaint(
            size: Size(size * 0.6, size * 0.6),
            painter: _TriangleInstrumentPainter(
              vibration: isStriking ? 1.5 : 0.0,
            ),
          ),

          // Striker Wand
          Positioned(
            right: size * 0.10 - (tapCycle.clamp(0.0, 1.0) * 8),
            top: size * 0.20,
            child: Transform.rotate(
              angle: -0.3 + (tapCycle.clamp(0.0, 1.0) * 0.4),
              child: Container(
                width: 4,
                height: 26,
                decoration: BoxDecoration(
                  gradient: const LinearGradient(
                    colors: [Color(0xFFE0E0E0), Color(0xFF9E9E9E)],
                  ),
                  borderRadius: BorderRadius.circular(2),
                  border: Border.all(color: Colors.white, width: 0.8),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _TriangleInstrumentPainter extends CustomPainter {
  final double vibration;

  _TriangleInstrumentPainter({required this.vibration});

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = const Color(0xFFFFD54F)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 3.5
      ..strokeCap = StrokeCap.round
      ..strokeJoin = StrokeJoin.round;

    final highlightPaint = Paint()
      ..color = Colors.white
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.5
      ..strokeCap = StrokeCap.round;

    final path = Path();
    final top = Offset(size.width / 2 + vibration, 4);
    final bottomL = Offset(4, size.height - 4);
    final bottomR = Offset(size.width - 4, size.height - 4);

    // Unclosed loop (standard musical triangle opening at bottom right corner)
    path.moveTo(bottomR.dx - 8, bottomR.dy);
    path.lineTo(bottomL.dx, bottomL.dy);
    path.lineTo(top.dx, top.dy);
    path.lineTo(bottomR.dx, bottomR.dy - 8);

    canvas.drawPath(path, paint);
    canvas.drawPath(path, highlightPaint);
  }

  @override
  bool shouldRepaint(covariant _TriangleInstrumentPainter oldDelegate) {
    return oldDelegate.vibration != vibration;
  }
}
