import 'dart:math' as math;
import 'package:flutter/material.dart';

/// Celebratory visual effects for the Fiesta Trio musical performance:
/// - Background twinkling sparkles (golden & pastel starbursts)
/// - Upward floating musical notes (♪, ♫, ♬)
/// - Festive floating confetti flakes
class FiestaTrioEffects extends StatelessWidget {
  final double animationProgress; // 0.0 to 1.0 looping progress
  final bool enableMotion;

  const FiestaTrioEffects({
    super.key,
    required this.animationProgress,
    this.enableMotion = true,
  });

  @override
  Widget build(BuildContext context) {
    return IgnorePointer(
      child: Stack(
        fit: StackFit.expand,
        children: [
          // 1. Background Twinkling Sparkles Field
          CustomPaint(
            painter: _SparklesPainter(
              progress: enableMotion ? animationProgress : 0.5,
            ),
          ),

          // 2. Rising Musical Notes
          CustomPaint(
            painter: _MusicNotesPainter(
              progress: enableMotion ? animationProgress : 0.5,
            ),
          ),

          // 3. Floating Festive Confetti
          CustomPaint(
            painter: _ConfettiPainter(
              progress: enableMotion ? animationProgress : 0.5,
            ),
          ),
        ],
      ),
    );
  }
}

/// Custom painter for background magical sparkles
class _SparklesPainter extends CustomPainter {
  final double progress;

  _SparklesPainter({required this.progress});

  // Deterministic sparkle layout across normalized coordinates
  static const List<_SparklePoint> _sparkles = [
    _SparklePoint(0.15, 0.15, 14, 0.0, Color(0xFFFFD54F)),
    _SparklePoint(0.85, 0.18, 18, 0.25, Color(0xFFFF80AB)),
    _SparklePoint(0.20, 0.35, 12, 0.50, Color(0xFF80D8FF)),
    _SparklePoint(0.80, 0.38, 16, 0.75, Color(0xFFB9F6CA)),
    _SparklePoint(0.08, 0.60, 15, 0.10, Color(0xFFFFD180)),
    _SparklePoint(0.92, 0.62, 13, 0.35, Color(0xFFEA80FC)),
    _SparklePoint(0.25, 0.75, 16, 0.60, Color(0xFFFFFF8D)),
    _SparklePoint(0.75, 0.78, 14, 0.85, Color(0xFFCCFF90)),
    _SparklePoint(0.48, 0.10, 20, 0.40, Color(0xFFFF8A80)),
    _SparklePoint(0.52, 0.88, 16, 0.65, Color(0xFF82B1FF)),
    _SparklePoint(0.35, 0.22, 10, 0.15, Color(0xFFFFE57F)),
    _SparklePoint(0.65, 0.25, 11, 0.70, Color(0xFFA7FFEB)),
  ];

  @override
  void paint(Canvas canvas, Size size) {
    for (final s in _sparkles) {
      final cx = s.relX * size.width;
      final cy = s.relY * size.height;

      // Pulse size and alpha with phase offset
      final localProgress = (progress + s.phase) % 1.0;
      final scale = 0.5 + 0.5 * math.sin(localProgress * 2 * math.pi);
      final alpha = (0.3 + 0.7 * math.sin(localProgress * 2 * math.pi)).clamp(0.0, 1.0);

      final paint = Paint()
        ..color = s.color.withValues(alpha: alpha)
        ..style = PaintingStyle.fill;

      // Draw diamond sparkle
      final radius = s.baseSize * scale;
      final path = Path();
      path.moveTo(cx, cy - radius);
      path.quadraticBezierTo(cx, cy, cx + radius * 0.3, cy);
      path.quadraticBezierTo(cx, cy, cx, cy + radius);
      path.quadraticBezierTo(cx, cy, cx - radius * 0.3, cy);
      path.close();

      final crossPath = Path();
      crossPath.moveTo(cx - radius, cy);
      crossPath.quadraticBezierTo(cx, cy, cx, cy + radius * 0.3);
      crossPath.quadraticBezierTo(cx, cy, cx + radius, cy);
      crossPath.quadraticBezierTo(cx, cy, cx, cy - radius * 0.3);
      crossPath.close();

      canvas.drawPath(path, paint);
      canvas.drawPath(crossPath, paint);

      // Central glowing core
      final corePaint = Paint()
        ..color = Colors.white.withValues(alpha: alpha)
        ..style = PaintingStyle.fill;
      canvas.drawCircle(Offset(cx, cy), radius * 0.25, corePaint);
    }
  }

  @override
  bool shouldRepaint(covariant _SparklesPainter oldDelegate) =>
      oldDelegate.progress != progress;
}

class _SparklePoint {
  final double relX;
  final double relY;
  final double baseSize;
  final double phase;
  final Color color;

  const _SparklePoint(this.relX, this.relY, this.baseSize, this.phase, this.color);
}

/// Custom painter for upward floating musical notes
class _MusicNotesPainter extends CustomPainter {
  final double progress;

  _MusicNotesPainter({required this.progress});

  static const List<_NoteSource> _notes = [
    _NoteSource('♪', 0.28, 0.65, -25, Color(0xFF64B5F6), 0.0),
    _NoteSource('♫', 0.36, 0.60, 30, Color(0xFF81C784), 0.2),
    _NoteSource('♬', 0.50, 0.58, -15, Color(0xFFFFB74D), 0.4),
    _NoteSource('♩', 0.64, 0.62, 20, Color(0xFFBA68C8), 0.6),
    _NoteSource('♪', 0.72, 0.65, -30, Color(0xFFFF8A80), 0.8),
  ];

  @override
  void paint(Canvas canvas, Size size) {
    for (final note in _notes) {
      final localProg = (progress + note.phase) % 1.0;

      // Note rises upward from instrument height
      final startY = size.height * note.startY;
      final currentY = startY - (localProg * size.height * 0.35);
      final currentX = size.width * note.startX +
          math.sin(localProg * 4 * math.pi) * note.driftX;

      // Fade in then out
      final opacity = math.sin(localProg * math.pi).clamp(0.0, 1.0);

      final textPainter = TextPainter(
        text: TextSpan(
          text: note.glyph,
          style: TextStyle(
            fontSize: 26 + (localProg * 6),
            fontWeight: FontWeight.bold,
            color: note.color.withValues(alpha: opacity),
            shadows: [
              Shadow(
                color: Colors.white.withValues(alpha: opacity * 0.8),
                blurRadius: 8,
              ),
            ],
          ),
        ),
        textDirection: TextDirection.ltr,
      );

      textPainter.layout();
      textPainter.paint(
        canvas,
        Offset(currentX - textPainter.width / 2, currentY - textPainter.height / 2),
      );
    }
  }

  @override
  bool shouldRepaint(covariant _MusicNotesPainter oldDelegate) =>
      oldDelegate.progress != progress;
}

class _NoteSource {
  final String glyph;
  final double startX;
  final double startY;
  final double driftX;
  final Color color;
  final double phase;

  const _NoteSource(this.glyph, this.startX, this.startY, this.driftX, this.color, this.phase);
}

/// Custom painter for lightweight floating celebratory confetti flakes
class _ConfettiPainter extends CustomPainter {
  final double progress;

  _ConfettiPainter({required this.progress});

  static const List<_ConfettiBit> _confetti = [
    _ConfettiBit(0.12, 0.05, 0.85, 8, 5, Color(0xFFFF5252), 0.0),
    _ConfettiBit(0.24, -0.05, 0.90, 7, 7, Color(0xFFFFD740), 0.2),
    _ConfettiBit(0.38, 0.00, 0.95, 9, 4, Color(0xFF69F0AE), 0.4),
    _ConfettiBit(0.55, -0.10, 0.88, 6, 6, Color(0xFF40C4FF), 0.6),
    _ConfettiBit(0.68, 0.02, 0.92, 8, 5, Color(0xFFFF4081), 0.8),
    _ConfettiBit(0.82, -0.08, 0.86, 7, 4, Color(0xFFE040FB), 0.1),
    _ConfettiBit(0.92, 0.06, 0.90, 8, 6, Color(0xFFEEFF41), 0.5),
  ];

  @override
  void paint(Canvas canvas, Size size) {
    for (final bit in _confetti) {
      final localProg = (progress + bit.phase) % 1.0;
      final y = localProg * size.height * bit.fallSpeed;
      final x = (bit.relX * size.width) + math.sin(localProg * 3 * math.pi) * 20.0;

      final paint = Paint()
        ..color = bit.color.withValues(alpha: (1.0 - (localProg * 0.3)).clamp(0.0, 1.0))
        ..style = PaintingStyle.fill;

      canvas.save();
      canvas.translate(x, y);
      canvas.rotate(localProg * 4 * math.pi);
      canvas.drawRRect(
        RRect.fromRectAndRadius(
          Rect.fromCenter(center: Offset.zero, width: bit.w, height: bit.h),
          const Radius.circular(2),
        ),
        paint,
      );
      canvas.restore();
    }
  }

  @override
  bool shouldRepaint(covariant _ConfettiPainter oldDelegate) =>
      oldDelegate.progress != progress;
}

class _ConfettiBit {
  final double relX;
  final double startY;
  final double fallSpeed;
  final double w;
  final double h;
  final Color color;
  final double phase;

  const _ConfettiBit(this.relX, this.startY, this.fallSpeed, this.w, this.h, this.color, this.phase);
}
