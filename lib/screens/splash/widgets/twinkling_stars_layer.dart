import 'dart:math' as math;
import 'package:flutter/material.dart';
import '../../../themes/app_theme.dart';

/// Interactive animated layer that renders twinkling golden stars
/// in the night sky matching the reference visual style.
class TwinklingStarsLayer extends StatefulWidget {
  final int numberOfStars;
  final double? height;

  const TwinklingStarsLayer({
    super.key,
    this.numberOfStars = 28,
    this.height,
  });

  @override
  State<TwinklingStarsLayer> createState() => _TwinklingStarsLayerState();
}

class _TwinklingStarsLayerState extends State<TwinklingStarsLayer>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late List<_StarParticle> _stars;

  @override
  void initState() {
    super.initState();
    final random = math.Random(42);
    _stars = List.generate(widget.numberOfStars, (index) {
      return _StarParticle(
        relativeX: random.nextDouble(),
        relativeY: random.nextDouble(),
        baseSize: 3.0 + random.nextDouble() * 7.0,
        twinkleSpeed: 0.5 + random.nextDouble() * 1.5,
        phaseOffset: random.nextDouble() * 2 * math.pi,
        isFourPointed: random.nextDouble() > 0.4,
      );
    });

    _controller = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 4),
    )..repeat();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final double effectiveHeight;
        if (widget.height != null) {
          effectiveHeight = widget.height!;
        } else if (constraints.maxHeight.isFinite) {
          effectiveHeight = constraints.maxHeight;
        } else {
          effectiveHeight = 280.0;
        }

        final double effectiveWidth = constraints.maxWidth.isFinite
            ? constraints.maxWidth
            : MediaQuery.of(context).size.width;

        return SizedBox(
          width: effectiveWidth,
          height: effectiveHeight,
          child: AnimatedBuilder(
            animation: _controller,
            builder: (context, child) {
              return CustomPaint(
                painter: _StarPainter(
                  stars: _stars,
                  progress: _controller.value,
                ),
              );
            },
          ),
        );
      },
    );
  }
}

class _StarParticle {
  final double relativeX;
  final double relativeY;
  final double baseSize;
  final double twinkleSpeed;
  final double phaseOffset;
  final bool isFourPointed;

  _StarParticle({
    required this.relativeX,
    required this.relativeY,
    required this.baseSize,
    required this.twinkleSpeed,
    required this.phaseOffset,
    required this.isFourPointed,
  });
}

class _StarPainter extends CustomPainter {
  final List<_StarParticle> stars;
  final double progress;

  _StarPainter({
    required this.stars,
    required this.progress,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final glowPaint = Paint()..style = PaintingStyle.fill;
    final starPaint = Paint()
      ..color = AppColors.starYellow
      ..style = PaintingStyle.fill;

    for (final star in stars) {
      final x = star.relativeX * size.width;
      final y = star.relativeY * size.height;

      // Calculate smooth sine-wave twinkling alpha and scale
      final wave = math.sin((progress * 2 * math.pi * star.twinkleSpeed) + star.phaseOffset);
      final normalizedWave = (wave + 1.0) / 2.0; // 0.0 to 1.0
      final alpha = (0.3 + (normalizedWave * 0.7)).clamp(0.0, 1.0);
      final currentSize = star.baseSize * (0.8 + (normalizedWave * 0.4));

      // Draw soft outer radial glow
      glowPaint.color = AppColors.starYellow.withValues(alpha: alpha * 0.4);
      canvas.drawCircle(Offset(x, y), currentSize * 1.8, glowPaint);

      // Draw sharp 4-pointed diamond star or soft circle
      if (star.isFourPointed) {
        starPaint.color = AppColors.starBright.withValues(alpha: alpha);
        _drawDiamondStar(canvas, Offset(x, y), currentSize, starPaint);
      } else {
        starPaint.color = AppColors.starGold.withValues(alpha: alpha);
        canvas.drawCircle(Offset(x, y), currentSize * 0.6, starPaint);
      }
    }
  }

  void _drawDiamondStar(Canvas canvas, Offset center, double size, Paint paint) {
    final path = Path();
    final half = size / 2;
    final armLength = size * 1.3;
    final inner = half * 0.28;

    path.moveTo(center.dx, center.dy - armLength);
    path.lineTo(center.dx + inner, center.dy - inner);
    path.lineTo(center.dx + armLength, center.dy);
    path.lineTo(center.dx + inner, center.dy + inner);
    path.lineTo(center.dx, center.dy + armLength);
    path.lineTo(center.dx - inner, center.dy + inner);
    path.lineTo(center.dx - armLength, center.dy);
    path.lineTo(center.dx - inner, center.dy - inner);
    path.close();

    canvas.drawPath(path, paint);
  }

  @override
  bool shouldRepaint(covariant _StarPainter oldDelegate) => true;
}
