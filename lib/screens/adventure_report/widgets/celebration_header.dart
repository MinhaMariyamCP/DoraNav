import 'dart:math' as math;
import 'package:flutter/material.dart';

/// Top Celebratory Header featuring Dora & Boots waving excitedly with purple banner ribbon
class CelebrationHeader extends StatefulWidget {
  final String title;
  final String bannerText;

  const CelebrationHeader({
    super.key,
    this.title = 'Adventure Complete!',
    this.bannerText = 'Amazing adventure!',
  });

  @override
  State<CelebrationHeader> createState() => _CelebrationHeaderState();
}

class _CelebrationHeaderState extends State<CelebrationHeader>
    with SingleTickerProviderStateMixin {
  late AnimationController _confettiController;

  @override
  void initState() {
    super.initState();
    _confettiController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 4),
    )..repeat();
  }

  @override
  void dispose() {
    _confettiController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Stack(
      alignment: Alignment.center,
      children: [
        // Confetti Particle Background Canvas
        Positioned.fill(
          child: AnimatedBuilder(
            animation: _confettiController,
            builder: (context, child) {
              return CustomPaint(
                painter: _ConfettiPainter(progress: _confettiController.value),
              );
            },
          ),
        ),

        // Characters & Celebratory Titles
        Padding(
          padding: const EdgeInsets.only(top: 8, bottom: 12, left: 16, right: 16),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              // Left: Cheerful Dora Avatar
              _buildAvatarCard('👧🏽', const Color(0xFFFF80AB)),

              // Center: Titles & Ribbon
              Expanded(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    // Sparkly Stars & Title
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        const Text('⭐', style: TextStyle(fontSize: 20)),
                        const SizedBox(width: 6),
                        Flexible(
                          child: Text(
                            widget.title,
                            textAlign: TextAlign.center,
                            style: const TextStyle(
                              fontSize: 24,
                              fontWeight: FontWeight.w900,
                              color: Colors.white,
                              letterSpacing: -0.5,
                              shadows: [
                                Shadow(
                                  color: Color(0xFF311B92),
                                  offset: Offset(0, 2),
                                  blurRadius: 4,
                                ),
                              ],
                            ),
                          ),
                        ),
                        const SizedBox(width: 6),
                        const Text('⭐', style: TextStyle(fontSize: 20)),
                      ],
                    ),
                    const SizedBox(height: 6),

                    // Purple Ribbon Badge: "Amazing adventure!"
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
                      decoration: BoxDecoration(
                        color: const Color(0xFF6A1B9A),
                        borderRadius: BorderRadius.circular(16),
                        border: Border.all(color: const Color(0xFFBA68C8), width: 1.5),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withValues(alpha: 0.2),
                            blurRadius: 4,
                            offset: const Offset(0, 2),
                          ),
                        ],
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          const Text('⭐', style: TextStyle(fontSize: 12)),
                          const SizedBox(width: 6),
                          Text(
                            widget.bannerText,
                            style: const TextStyle(
                              fontSize: 13,
                              fontWeight: FontWeight.w900,
                              color: Color(0xFFFFEB3B),
                              letterSpacing: 0.3,
                            ),
                          ),
                          const SizedBox(width: 6),
                          const Text('⭐', style: TextStyle(fontSize: 12)),
                        ],
                      ),
                    ),
                  ],
                ),
              ),

              // Right: Cheerful Boots Avatar
              _buildAvatarCard('🐒', const Color(0xFF64B5F6)),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildAvatarCard(String emoji, Color accentColor) {
    return Container(
      width: 58,
      height: 58,
      decoration: BoxDecoration(
        color: Colors.white,
        shape: BoxShape.circle,
        border: Border.all(color: accentColor, width: 2.5),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.2),
            blurRadius: 8,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      child: Center(
        child: Text(emoji, style: const TextStyle(fontSize: 34)),
      ),
    );
  }
}

class _ConfettiPainter extends CustomPainter {
  final double progress;

  _ConfettiPainter({required this.progress});

  static final List<Color> _colors = [
    const Color(0xFFFF4081),
    const Color(0xFFFFD700),
    const Color(0xFF00E676),
    const Color(0xFF00B0FF),
    const Color(0xFFFF9100),
    const Color(0xFFE040FB),
  ];

  @override
  void paint(Canvas canvas, Size size) {
    final rand = math.Random(42);
    final paint = Paint()..style = PaintingStyle.fill;

    for (int i = 0; i < 30; i++) {
      paint.color = _colors[i % _colors.length];
      final startX = rand.nextDouble() * size.width;
      final speed = 0.5 + rand.nextDouble();
      final y = (rand.nextDouble() * size.height + progress * size.height * speed) % size.height;
      final rot = (progress * 2 * math.pi * speed) + i;
      final shapeType = i % 3;

      canvas.save();
      canvas.translate(startX, y);
      canvas.rotate(rot);

      if (shapeType == 0) {
        // Little confetti rectangle
        canvas.drawRect(const Rect.fromLTWH(-4, -2, 8, 4), paint);
      } else if (shapeType == 1) {
        // Little confetti circle
        canvas.drawCircle(Offset.zero, 3, paint);
      } else {
        // Little star
        final path = Path()
          ..moveTo(0, -4)
          ..lineTo(1.5, -1)
          ..lineTo(4, 0)
          ..lineTo(1.5, 1)
          ..lineTo(0, 4)
          ..lineTo(-1.5, 1)
          ..lineTo(-4, 0)
          ..lineTo(-1.5, -1)
          ..close();
        canvas.drawPath(path, paint);
      }
      canvas.restore();
    }
  }

  @override
  bool shouldRepaint(covariant _ConfettiPainter oldDelegate) =>
      oldDelegate.progress != progress;
}
