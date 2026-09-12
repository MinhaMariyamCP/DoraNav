import 'dart:math' as math;
import 'package:flutter/material.dart';
import '../theme/backpack_theme.dart';

/// Kid-friendly vector illustrations for Dora, Backpack, Boots, and Items.
/// Using CustomPainters ensures 100% reliable crisp graphics without external asset assets.

/// Cheerful Dora avatar with her signature bob hair and happy smile.
class DoraAvatarWidget extends StatelessWidget {
  final double size;
  const DoraAvatarWidget({super.key, this.size = 48});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        color: const Color(0xFFFFD180),
        border: Border.all(color: Colors.white, width: 2.5),
        boxShadow: [
          BoxShadow(
            color: BackpackColors.primaryPurple.withValues(alpha: 0.25),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: ClipOval(
        child: CustomPaint(
          painter: _DoraAvatarPainter(),
        ),
      ),
    );
  }
}

class _DoraAvatarPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final w = size.width;
    final h = size.height;

    // Face skin
    final skinPaint = Paint()..color = const Color(0xFFE0A96D);
    canvas.drawCircle(Offset(w * 0.5, h * 0.55), w * 0.38, skinPaint);

    // Signature Bob Hair (Dark Brown)
    final hairPaint = Paint()..color = const Color(0xFF3E2723);
    final hairPath = Path();
    hairPath.moveTo(w * 0.12, h * 0.55);
    hairPath.quadraticBezierTo(w * 0.08, h * 0.2, w * 0.5, h * 0.15);
    hairPath.quadraticBezierTo(w * 0.92, h * 0.2, w * 0.88, h * 0.55);
    hairPath.quadraticBezierTo(w * 0.92, h * 0.7, w * 0.82, h * 0.75);
    hairPath.quadraticBezierTo(w * 0.75, h * 0.4, w * 0.5, h * 0.35);
    hairPath.quadraticBezierTo(w * 0.25, h * 0.4, w * 0.18, h * 0.75);
    hairPath.close();
    canvas.drawPath(hairPath, hairPaint);

    // Big expressive brown eyes
    final eyeWhite = Paint()..color = Colors.white;
    final eyeIris = Paint()..color = const Color(0xFF4E342E);
    final eyePupil = Paint()..color = Colors.black;
    final eyeHighlight = Paint()..color = Colors.white;

    // Left Eye
    canvas.drawOval(Rect.fromCenter(center: Offset(w * 0.38, h * 0.52), width: w * 0.16, height: h * 0.20), eyeWhite);
    canvas.drawOval(Rect.fromCenter(center: Offset(w * 0.39, h * 0.52), width: w * 0.11, height: h * 0.15), eyeIris);
    canvas.drawCircle(Offset(w * 0.40, h * 0.52), w * 0.04, eyePupil);
    canvas.drawCircle(Offset(w * 0.37, h * 0.48), w * 0.025, eyeHighlight);

    // Right Eye
    canvas.drawOval(Rect.fromCenter(center: Offset(w * 0.62, h * 0.52), width: w * 0.16, height: h * 0.20), eyeWhite);
    canvas.drawOval(Rect.fromCenter(center: Offset(w * 0.61, h * 0.52), width: w * 0.11, height: h * 0.15), eyeIris);
    canvas.drawCircle(Offset(w * 0.60, h * 0.52), w * 0.04, eyePupil);
    canvas.drawCircle(Offset(w * 0.59, h * 0.48), w * 0.025, eyeHighlight);

    // Warm friendly smile
    final mouthPaint = Paint()
      ..color = const Color(0xFFC2185B)
      ..style = PaintingStyle.stroke
      ..strokeWidth = w * 0.05
      ..strokeCap = StrokeCap.round;
    final mouthPath = Path();
    mouthPath.moveTo(w * 0.40, h * 0.68);
    mouthPath.quadraticBezierTo(w * 0.5, h * 0.76, w * 0.60, h * 0.68);
    canvas.drawPath(mouthPath, mouthPaint);

    // Rosy Cheeks
    final cheekPaint = Paint()..color = const Color(0xFFFF80AB).withValues(alpha: 0.5);
    canvas.drawCircle(Offset(w * 0.26, h * 0.62), w * 0.07, cheekPaint);
    canvas.drawCircle(Offset(w * 0.74, h * 0.62), w * 0.07, cheekPaint);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}

/// The cheerful purple Backpack character with smiling face and yellow star zipper.
class BackpackCharacterWidget extends StatelessWidget {
  final double width;
  final double height;
  final bool animate;

  const BackpackCharacterWidget({
    super.key,
    this.width = 160,
    this.height = 170,
    this.animate = true,
  });

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: width,
      height: height,
      child: CustomPaint(
        painter: _BackpackCharacterPainter(),
      ),
    );
  }
}

class _BackpackCharacterPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final w = size.width;
    final h = size.height;

    // Shadow on ground
    final shadowPaint = Paint()..color = const Color(0xFF81C784).withValues(alpha: 0.4);
    canvas.drawOval(
      Rect.fromCenter(center: Offset(w * 0.5, h * 0.92), width: w * 0.85, height: h * 0.16),
      shadowPaint,
    );

    // Purple Backpack Body
    final bodyPaint = Paint()..color = const Color(0xFF7E57C2);
    final bodyRRect = RRect.fromRectAndRadius(
      Rect.fromLTWH(w * 0.18, h * 0.18, w * 0.64, h * 0.70),
      const Radius.circular(38),
    );
    canvas.drawRRect(bodyRRect, bodyPaint);

    // Backpack Top Flap
    final flapPaint = Paint()..color = const Color(0xFF673AB7);
    final flapPath = Path();
    flapPath.moveTo(w * 0.20, h * 0.38);
    flapPath.quadraticBezierTo(w * 0.5, h * 0.48, w * 0.80, h * 0.38);
    flapPath.lineTo(w * 0.80, h * 0.22);
    flapPath.quadraticBezierTo(w * 0.5, h * 0.16, w * 0.20, h * 0.22);
    flapPath.close();
    canvas.drawPath(flapPath, flapPaint);

    // Left & Right Straps
    final strapPaint = Paint()
      ..color = const Color(0xFF5E35B1)
      ..style = PaintingStyle.stroke
      ..strokeWidth = w * 0.08
      ..strokeCap = StrokeCap.round;
    canvas.drawLine(Offset(w * 0.22, h * 0.25), Offset(w * 0.10, h * 0.65), strapPaint);
    canvas.drawLine(Offset(w * 0.78, h * 0.25), Offset(w * 0.90, h * 0.65), strapPaint);

    // Eyes
    final eyeWhite = Paint()..color = Colors.white;
    final eyePupil = Paint()..color = const Color(0xFF263238);
    final eyeShine = Paint()..color = Colors.white;

    // Left Eye
    canvas.drawOval(Rect.fromCenter(center: Offset(w * 0.40, h * 0.32), width: w * 0.14, height: h * 0.18), eyeWhite);
    canvas.drawOval(Rect.fromCenter(center: Offset(w * 0.41, h * 0.33), width: w * 0.08, height: h * 0.11), eyePupil);
    canvas.drawCircle(Offset(w * 0.39, h * 0.29), w * 0.025, eyeShine);

    // Right Eye
    canvas.drawOval(Rect.fromCenter(center: Offset(w * 0.60, h * 0.32), width: w * 0.14, height: h * 0.18), eyeWhite);
    canvas.drawOval(Rect.fromCenter(center: Offset(w * 0.59, h * 0.33), width: w * 0.08, height: h * 0.11), eyePupil);
    canvas.drawCircle(Offset(w * 0.58, h * 0.29), w * 0.025, eyeShine);

    // Cheerful smiling mouth
    final mouthPaint = Paint()
      ..color = const Color(0xFF311B92)
      ..style = PaintingStyle.fill;
    final mouthPath = Path();
    mouthPath.moveTo(w * 0.38, h * 0.54);
    mouthPath.quadraticBezierTo(w * 0.5, h * 0.70, w * 0.62, h * 0.54);
    mouthPath.close();
    canvas.drawPath(mouthPath, mouthPaint);

    // Little pink tongue
    final tonguePaint = Paint()..color = const Color(0xFFFF4081);
    final tonguePath = Path();
    tonguePath.moveTo(w * 0.44, h * 0.62);
    tonguePath.quadraticBezierTo(w * 0.5, h * 0.68, w * 0.56, h * 0.62);
    canvas.drawPath(tonguePath, tonguePaint);

    // Gold Star Zipper Pull on pocket
    _drawStar(canvas, Offset(w * 0.5, h * 0.76), w * 0.09, const Color(0xFFFFCA28));
  }

  void _drawStar(Canvas canvas, Offset center, double radius, Color color) {
    final paint = Paint()..color = color;
    final path = Path();
    final innerRadius = radius * 0.45;
    for (int i = 0; i < 10; i++) {
      final r = i.isEven ? radius : innerRadius;
      final angle = (i * 36 - 90) * math.pi / 180;
      final x = center.dx + r * math.cos(angle);
      final y = center.dy + r * math.sin(angle);
      if (i == 0) {
        path.moveTo(x, y);
      } else {
        path.lineTo(x, y);
      }
    }
    path.close();
    canvas.drawPath(path, paint);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}

/// Boots the Monkey thinking illustration for search/speaking state.
class BootsThinkingWidget extends StatelessWidget {
  final double size;
  const BootsThinkingWidget({super.key, this.size = 120});

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: size,
      height: size,
      child: CustomPaint(
        painter: _BootsThinkingPainter(),
      ),
    );
  }
}

class _BootsThinkingPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final w = size.width;
    final h = size.height;

    // Body/Fur (Light Periwinkle / Sky Blue Monkey fur)
    final furPaint = Paint()..color = const Color(0xFF90CAF9);
    final faceSkin = Paint()..color = const Color(0xFFFFE082);

    // Head
    canvas.drawCircle(Offset(w * 0.5, h * 0.45), w * 0.35, furPaint);

    // Ears
    canvas.drawCircle(Offset(w * 0.18, h * 0.40), w * 0.14, furPaint);
    canvas.drawCircle(Offset(w * 0.18, h * 0.40), w * 0.08, faceSkin);
    canvas.drawCircle(Offset(w * 0.82, h * 0.40), w * 0.14, furPaint);
    canvas.drawCircle(Offset(w * 0.82, h * 0.40), w * 0.08, faceSkin);

    // Face Mask (Peach/Yellow)
    final maskRRect = RRect.fromRectAndRadius(
      Rect.fromLTWH(w * 0.28, h * 0.30, w * 0.44, h * 0.38),
      const Radius.circular(24),
    );
    canvas.drawRRect(maskRRect, faceSkin);

    // Hair Tuft
    final tuftPath = Path();
    tuftPath.moveTo(w * 0.44, h * 0.16);
    tuftPath.quadraticBezierTo(w * 0.5, h * 0.06, w * 0.56, h * 0.16);
    canvas.drawPath(tuftPath, furPaint);

    // Eyes
    final eyePaint = Paint()..color = Colors.black;
    canvas.drawCircle(Offset(w * 0.40, h * 0.42), w * 0.045, eyePaint);
    canvas.drawCircle(Offset(w * 0.60, h * 0.42), w * 0.045, eyePaint);

    // Curious mouth
    final mouthPaint = Paint()
      ..color = const Color(0xFFC2185B)
      ..style = PaintingStyle.stroke
      ..strokeWidth = w * 0.04
      ..strokeCap = StrokeCap.round;
    canvas.drawArc(
      Rect.fromCenter(center: Offset(w * 0.5, h * 0.54), width: w * 0.18, height: h * 0.12),
      0.2,
      math.pi - 0.4,
      false,
      mouthPaint,
    );

    // Boots' red boots icon in corner
    final bootPaint = Paint()..color = const Color(0xFFE53935);
    canvas.drawRRect(
      RRect.fromRectAndRadius(
        Rect.fromLTWH(w * 0.35, h * 0.78, w * 0.14, h * 0.18),
        const Radius.circular(6),
      ),
      bootPaint,
    );
    canvas.drawRRect(
      RRect.fromRectAndRadius(
        Rect.fromLTWH(w * 0.51, h * 0.78, w * 0.14, h * 0.18),
        const Radius.circular(6),
      ),
      bootPaint,
    );
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}

/// Universal item icon renderer providing crisp kid-friendly vector graphics.
class AdventureItemIconWidget extends StatelessWidget {
  final String iconKey;
  final double size;

  const AdventureItemIconWidget({
    super.key,
    required this.iconKey,
    this.size = 56,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        color: _getBgColor(iconKey),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: Colors.white,
          width: 2,
        ),
        boxShadow: [
          BoxShadow(
            color: _getBgColor(iconKey).withValues(alpha: 0.35),
            blurRadius: 8,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      child: Center(
        child: CustomPaint(
          size: Size(size * 0.75, size * 0.75),
          painter: _AdventureItemPainter(iconKey),
        ),
      ),
    );
  }

  Color _getBgColor(String key) {
    switch (key) {
      case 'map':
        return const Color(0xFFFFF9C4);
      case 'boots':
        return const Color(0xFFFFCDD2);
      case 'raft':
        return const Color(0xFFFFE082);
      case 'life_jacket':
        return const Color(0xFFFFCC80);
      case 'rope':
        return const Color(0xFFD7CCC8);
      case 'water_bottle':
        return const Color(0xFFB3E5FC);
      case 'flashlight':
        return const Color(0xFFFFF59D);
      case 'lantern':
        return const Color(0xFFFFE0B2);
      case 'glow_stick':
        return const Color(0xFFE1BEE7);
      case 'warm_clothes':
        return const Color(0xFFBBDEFB);
      case 'gloves':
        return const Color(0xFFF8BBD0);
      case 'blanket':
        return const Color(0xFFD1C4E9);
      case 'snacks':
        return const Color(0xFFC8E6C9);
      case 'first_aid':
        return const Color(0xFFFFCDD2);
      case 'swiper_bell':
        return const Color(0xFFFFCCBC);
      default:
        return const Color(0xFFE1BEE7);
    }
  }
}

class _AdventureItemPainter extends CustomPainter {
  final String iconKey;
  _AdventureItemPainter(this.iconKey);

  @override
  void paint(Canvas canvas, Size size) {
    final w = size.width;
    final h = size.height;

    switch (iconKey) {
      case 'map':
        // Rolled antique parchment map
        final mapPaint = Paint()..color = const Color(0xFFFFE082);
        canvas.drawRRect(RRect.fromRectAndRadius(Rect.fromLTWH(w * 0.15, h * 0.2, w * 0.7, h * 0.6), const Radius.circular(6)), mapPaint);
        final linePaint = Paint()
          ..color = const Color(0xFFE65100)
          ..style = PaintingStyle.stroke
          ..strokeWidth = 2.5
          ..strokeCap = StrokeCap.round;
        final p = Path();
        p.moveTo(w * 0.25, h * 0.4);
        p.lineTo(w * 0.45, h * 0.6);
        p.lineTo(w * 0.7, h * 0.35);
        canvas.drawPath(p, linePaint);
        // Red X destination
        final xPaint = Paint()
          ..color = const Color(0xFFD50000)
          ..style = PaintingStyle.stroke
          ..strokeWidth = 3;
        canvas.drawLine(Offset(w * 0.65, h * 0.3), Offset(w * 0.75, h * 0.4), xPaint);
        canvas.drawLine(Offset(w * 0.75, h * 0.3), Offset(w * 0.65, h * 0.4), xPaint);
        break;

      case 'boots':
        // Red boots
        final bootPaint = Paint()..color = const Color(0xFFE53935);
        canvas.drawRRect(RRect.fromRectAndRadius(Rect.fromLTWH(w * 0.15, h * 0.2, w * 0.3, h * 0.6), const Radius.circular(8)), bootPaint);
        canvas.drawRRect(RRect.fromRectAndRadius(Rect.fromLTWH(w * 0.55, h * 0.2, w * 0.3, h * 0.6), const Radius.circular(8)), bootPaint);
        break;

      case 'raft':
        // Wooden / Inflatable log raft
        final logPaint = Paint()..color = const Color(0xFF8D6E63);
        final strapPaint = Paint()..color = const Color(0xFFFFB300);
        for (int i = 0; i < 4; i++) {
          canvas.drawRRect(
            RRect.fromRectAndRadius(Rect.fromLTWH(w * 0.1, h * (0.18 + i * 0.18), w * 0.8, h * 0.14), const Radius.circular(6)),
            logPaint,
          );
        }
        canvas.drawRect(Rect.fromLTWH(w * 0.25, h * 0.15, w * 0.08, h * 0.70), strapPaint);
        canvas.drawRect(Rect.fromLTWH(w * 0.67, h * 0.15, w * 0.08, h * 0.70), strapPaint);
        break;

      case 'life_jacket':
        // Bright orange safety vest
        final vestPaint = Paint()..color = const Color(0xFFFF6D00);
        final bucklePaint = Paint()..color = Colors.black87;
        canvas.drawRRect(RRect.fromRectAndRadius(Rect.fromLTWH(w * 0.15, h * 0.15, w * 0.3, h * 0.7), const Radius.circular(8)), vestPaint);
        canvas.drawRRect(RRect.fromRectAndRadius(Rect.fromLTWH(w * 0.55, h * 0.15, w * 0.3, h * 0.7), const Radius.circular(8)), vestPaint);
        canvas.drawRect(Rect.fromLTWH(w * 0.45, h * 0.35, w * 0.1, h * 0.08), bucklePaint);
        canvas.drawRect(Rect.fromLTWH(w * 0.45, h * 0.55, w * 0.1, h * 0.08), bucklePaint);
        break;

      case 'rope':
        // Coiled golden brown lasso/rope
        final ropePaint = Paint()
          ..color = const Color(0xFFA1887F)
          ..style = PaintingStyle.stroke
          ..strokeWidth = 4;
        canvas.drawCircle(Offset(w * 0.5, h * 0.5), w * 0.28, ropePaint);
        canvas.drawCircle(Offset(w * 0.5, h * 0.5), w * 0.18, ropePaint);
        break;

      case 'water_bottle':
        // Blue sports water bottle
        final bottlePaint = Paint()..color = const Color(0xFF03A9F4);
        final capPaint = Paint()..color = const Color(0xFF0288D1);
        canvas.drawRRect(RRect.fromRectAndRadius(Rect.fromLTWH(w * 0.32, h * 0.28, w * 0.36, h * 0.58), const Radius.circular(10)), bottlePaint);
        canvas.drawRRect(RRect.fromRectAndRadius(Rect.fromLTWH(w * 0.40, h * 0.16, w * 0.20, h * 0.14), const Radius.circular(4)), capPaint);
        break;

      case 'flashlight':
        // Yellow torch
        final torchPaint = Paint()..color = const Color(0xFFFFB300);
        final lightPaint = Paint()..color = const Color(0xFFFFF59D);
        canvas.drawRRect(RRect.fromRectAndRadius(Rect.fromLTWH(w * 0.35, h * 0.35, w * 0.30, h * 0.50), const Radius.circular(6)), torchPaint);
        canvas.drawRRect(RRect.fromRectAndRadius(Rect.fromLTWH(w * 0.28, h * 0.20, w * 0.44, h * 0.16), const Radius.circular(8)), lightPaint);
        break;

      case 'swiper_bell':
        // Golden warning bell
        final bellPaint = Paint()..color = const Color(0xFFFFD600);
        final clapperPaint = Paint()..color = const Color(0xFFFF6D00);
        final bp = Path();
        bp.moveTo(w * 0.5, h * 0.18);
        bp.quadraticBezierTo(w * 0.2, h * 0.55, w * 0.15, h * 0.70);
        bp.lineTo(w * 0.85, h * 0.70);
        bp.quadraticBezierTo(w * 0.8, h * 0.55, w * 0.5, h * 0.18);
        canvas.drawPath(bp, bellPaint);
        canvas.drawCircle(Offset(w * 0.5, h * 0.76), w * 0.08, clapperPaint);
        break;

      default:
        // Star token for generic/special
        final starPaint = Paint()..color = const Color(0xFFAB47BC);
        canvas.drawCircle(Offset(w * 0.5, h * 0.5), w * 0.30, starPaint);
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
