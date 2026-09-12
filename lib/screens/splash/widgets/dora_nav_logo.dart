import 'package:flutter/material.dart';
import '../../../themes/app_theme.dart';

/// Standalone 3D-styled DoraNav Logo and Header component.
/// Matches the visual hierarchy from the reference image:
/// - 3D Map Pin icon with red/purple gradient and inner portal
/// - Bold 3D "DoraNav" typography with orange gradient & white gradient
/// - Two-line subtitle and adventure tagline
class DoraNavLogo extends StatelessWidget {
  final double scale;
  final bool showPin;
  final bool showSubtitles;
  final String titleDora;
  final String titleNav;
  final String subtitle;
  final String tagline;

  const DoraNavLogo({
    super.key,
    this.scale = 1.0,
    this.showPin = true,
    this.showSubtitles = true,
    this.titleDora = 'Dora',
    this.titleNav = 'Nav',
    this.subtitle = "Navigation for Dora's World",
    this.tagline = 'Explore. Navigate. Adventure!',
  });

  @override
  Widget build(BuildContext context) {
    return Transform.scale(
      scale: scale,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          if (showPin) ...[
            const _MapPin3DWidget(),
            const SizedBox(height: 8.0),
          ],
          _build3DTitle(),
          if (showSubtitles) ...[
            const SizedBox(height: 10.0),
            Text(
              subtitle,
              textAlign: TextAlign.center,
              style: AppTypography.subtitle.copyWith(
                fontSize: 17.0 * scale,
              ),
            ),
            const SizedBox(height: 4.0),
            Text(
              tagline,
              textAlign: TextAlign.center,
              style: AppTypography.tagLine.copyWith(
                fontSize: 14.0 * scale,
              ),
            ),
          ],
        ],
      ),
    );
  }

  Widget _build3DTitle() {
    return FittedBox(
      fit: BoxFit.scaleDown,
      child: Row(
        mainAxisSize: MainAxisSize.min,
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          // "Dora" in 3D orange gradient with bevel
          _buildStyledWord(
            word: titleDora,
            gradient: AppColors.doraTitleGradient,
            outlineColor: const Color(0xFF7A2500),
            shadowColor: const Color(0xAA451200),
          ),
          // "Nav" in 3D white/silver gradient with orange/dark stroke
          _buildStyledWord(
            word: titleNav,
            gradient: AppColors.navTitleGradient,
            outlineColor: const Color(0xFF8B2500),
            shadowColor: const Color(0xAA3B0900),
          ),
        ],
      ),
    );
  }

  Widget _buildStyledWord({
    required String word,
    required Gradient gradient,
    required Color outlineColor,
    required Color shadowColor,
  }) {
    const fontSize = 54.0;

    return Stack(
      children: [
        // 1. Deep 3D Drop Shadow
        Text(
          word,
          style: TextStyle(
            fontSize: fontSize,
            fontWeight: FontWeight.w900,
            letterSpacing: -0.5,
            foreground: Paint()
              ..style = PaintingStyle.stroke
              ..strokeWidth = 14
              ..color = shadowColor,
          ),
        ),
        // 2. Thick Outer Border / Stroke
        Text(
          word,
          style: TextStyle(
            fontSize: fontSize,
            fontWeight: FontWeight.w900,
            letterSpacing: -0.5,
            foreground: Paint()
              ..style = PaintingStyle.stroke
              ..strokeWidth = 9
              ..color = outlineColor,
          ),
        ),
        // 3. Inner White Bevel Highlight
        Text(
          word,
          style: TextStyle(
            fontSize: fontSize,
            fontWeight: FontWeight.w900,
            letterSpacing: -0.5,
            foreground: Paint()
              ..style = PaintingStyle.stroke
              ..strokeWidth = 3
              ..color = Colors.white.withValues(alpha: 0.85),
          ),
        ),
        // 4. Vibrant Front Gradient Fill
        ShaderMask(
          blendMode: BlendMode.srcIn,
          shaderCallback: (bounds) => gradient.createShader(bounds),
          child: Text(
            word,
            style: const TextStyle(
              fontSize: fontSize,
              fontWeight: FontWeight.w900,
              letterSpacing: -0.5,
              color: Colors.white,
            ),
          ),
        ),
      ],
    );
  }
}

/// Custom painted 3D Location Pin with glossy red/coral body
/// and deep purple center aperture.
class _MapPin3DWidget extends StatelessWidget {
  const _MapPin3DWidget();

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: 76,
      height: 96,
      child: CustomPaint(
        painter: _MapPinPainter(),
      ),
    );
  }
}

class _MapPinPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final w = size.width;
    final h = size.height;

    // Pin Head center & radius
    final center = Offset(w / 2, w / 2);
    final radius = w / 2 - 4;

    // Pin outer teardrop path
    final pinPath = Path();
    pinPath.moveTo(w / 2, h - 2); // Bottom tip
    // Left curve up to head
    pinPath.cubicTo(
      w * 0.12, h * 0.65,
      center.dx - radius, center.dy + radius * 0.5,
      center.dx - radius, center.dy,
    );
    // Top circle arc
    pinPath.arcTo(
      Rect.fromCircle(center: center, radius: radius),
      3.14159,
      3.14159,
      false,
    );
    // Right curve down to tip
    pinPath.cubicTo(
      center.dx + radius, center.dy + radius * 0.5,
      w * 0.88, h * 0.65,
      w / 2, h - 2,
    );
    pinPath.close();

    // 1. Shadow underneath
    final shadowPaint = Paint()
      ..color = Colors.black.withValues(alpha: 0.4)
      ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 8);
    canvas.drawPath(pinPath.shift(const Offset(0, 4)), shadowPaint);

    // 2. Thick Outer Rim (crimson 3D edge)
    final rimPaint = Paint()
      ..color = AppColors.pinRedDark
      ..style = PaintingStyle.fill;
    canvas.drawPath(pinPath, rimPaint);

    // 3. Inner Glossy Gradient
    final innerRect = Rect.fromLTWH(2, 2, w - 4, h - 4);
    final bodyPaint = Paint()
      ..shader = const LinearGradient(
        begin: Alignment.topLeft,
        end: Alignment.bottomRight,
        colors: [
          Color(0xFFFF6584),
          AppColors.pinRed,
          AppColors.pinRedDark,
        ],
      ).createShader(innerRect)
      ..style = PaintingStyle.fill;

    canvas.save();
    canvas.scale(0.94, 0.94);
    canvas.translate(w * 0.03, h * 0.02);
    canvas.drawPath(pinPath, bodyPaint);
    canvas.restore();

    // 4. Center Hole (Deep Purple with 3D inner inset)
    final holeRadius = radius * 0.44;
    final holeCenter = Offset(w / 2, center.dy + 2);

    // Hole bevel
    final holeBevelPaint = Paint()
      ..color = const Color(0xFF2C0B47)
      ..style = PaintingStyle.fill;
    canvas.drawCircle(holeCenter, holeRadius + 2.5, holeBevelPaint);

    // Hole inner purple
    final holePaint = Paint()
      ..shader = const RadialGradient(
        colors: [
          Color(0xFF8B4FD6),
          AppColors.pinInnerPurple,
          Color(0xFF1E0736),
        ],
      ).createShader(Rect.fromCircle(center: holeCenter, radius: holeRadius))
      ..style = PaintingStyle.fill;
    canvas.drawCircle(holeCenter, holeRadius, holePaint);

    // 5. Top Gloss Highlight
    final highlightPaint = Paint()
      ..color = Colors.white.withValues(alpha: 0.4)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 3.5;
    final highlightArc = Path()
      ..addArc(
        Rect.fromCircle(center: center, radius: radius - 3),
        3.6,
        1.6,
      );
    canvas.drawPath(highlightArc, highlightPaint);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
