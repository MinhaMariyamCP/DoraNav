import 'package:flutter/material.dart';
import '../../themes/app_theme.dart';

/// Reusable 3D tactile button styled for DoraNav adventures.
/// Features a beveled bottom shadow, vibrant orange/yellow gradient,
/// and responsive tap-down spring physics.
class AdventureButton extends StatefulWidget {
  final String label;
  final VoidCallback? onPressed;
  final IconData? icon;
  final double? width;
  final double height;
  final Color primaryColor;
  final Color shadowColor;

  const AdventureButton({
    super.key,
    required this.label,
    this.onPressed,
    this.icon,
    this.width,
    this.height = 54.0,
    this.primaryColor = AppColors.doraOrange,
    this.shadowColor = AppColors.doraOrangeDark,
  });

  @override
  State<AdventureButton> createState() => _AdventureButtonState();
}

class _AdventureButtonState extends State<AdventureButton> {
  bool _isPressed = false;

  @override
  Widget build(BuildContext context) {
    const depth = 5.0;

    return GestureDetector(
      onTapDown: (_) => setState(() => _isPressed = true),
      onTapUp: (_) {
        setState(() => _isPressed = false);
        widget.onPressed?.call();
      },
      onTapCancel: () => setState(() => _isPressed = false),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 100),
        width: widget.width,
        height: widget.height,
        margin: EdgeInsets.only(top: _isPressed ? depth : 0.0),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(28.0),
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [
              widget.primaryColor.withLightness(0.55),
              widget.primaryColor,
              widget.shadowColor,
            ],
          ),
          border: Border.all(
            color: Colors.white.withValues(alpha: 0.4),
            width: 2.0,
          ),
          boxShadow: _isPressed
              ? []
              : [
                  BoxShadow(
                    color: widget.shadowColor.withValues(alpha: 0.85),
                    offset: const Offset(0, depth),
                    blurRadius: 0,
                  ),
                  BoxShadow(
                    color: Colors.black.withValues(alpha: 0.3),
                    offset: const Offset(0, depth + 3),
                    blurRadius: 8,
                  ),
                ],
        ),
        child: Center(
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              if (widget.icon != null) ...[
                Icon(
                  widget.icon,
                  color: Colors.white,
                  size: 22,
                ),
                const SizedBox(width: 8),
              ],
              Text(
                widget.label,
                style: AppTypography.button.copyWith(
                  shadows: const [
                    Shadow(
                      offset: Offset(0, 1.5),
                      blurRadius: 2,
                      color: Color(0x66000000),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

extension _ColorLightness on Color {
  Color withLightness(double factor) {
    final hsl = HSLColor.fromColor(this);
    return hsl.withLightness((hsl.lightness + 0.1).clamp(0.0, 1.0)).toColor();
  }
}
