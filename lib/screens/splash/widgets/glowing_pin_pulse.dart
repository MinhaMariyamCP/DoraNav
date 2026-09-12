import 'package:flutter/material.dart';
import '../../../themes/app_theme.dart';

/// Animated pulsing beacon effect radiating from behind the location pin,
/// accentuating the 3D glowing location pin seen in the reference poster.
class GlowingPinPulse extends StatefulWidget {
  final double size;

  const GlowingPinPulse({
    super.key,
    this.size = 130.0,
  });

  @override
  State<GlowingPinPulse> createState() => _GlowingPinPulseState();
}

class _GlowingPinPulseState extends State<GlowingPinPulse>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 2200),
    )..repeat();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _controller,
      builder: (context, child) {
        final progress = _controller.value;
        final scale = 0.8 + (progress * 0.7);
        final opacity = (1.0 - progress).clamp(0.0, 1.0) * 0.6;

        return SizedBox(
          width: widget.size,
          height: widget.size,
          child: Stack(
            alignment: Alignment.center,
            children: [
              // Secondary inner pulse
              Transform.scale(
                scale: 0.6 + (progress * 0.4),
                child: Container(
                  width: widget.size,
                  height: widget.size,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    boxShadow: [
                      BoxShadow(
                        color: AppColors.pinRed.withValues(alpha: opacity * 0.7),
                        blurRadius: 30,
                        spreadRadius: 8,
                      ),
                    ],
                  ),
                ),
              ),
              // Main outer expanding ripple
              Transform.scale(
                scale: scale,
                child: Container(
                  width: widget.size,
                  height: widget.size,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    border: Border.all(
                      color: AppColors.pinRedLight.withValues(alpha: opacity * 0.8),
                      width: 2.0,
                    ),
                    gradient: RadialGradient(
                      colors: [
                        AppColors.pinRedLight.withValues(alpha: opacity * 0.35),
                        AppColors.pinInnerPurple.withValues(alpha: 0.0),
                      ],
                    ),
                  ),
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}
