import 'package:flutter/material.dart';
import 'fiesta_trio_instruments.dart';

/// Interactive character component for the Fiesta Trio musical celebration.
///
/// Supports:
/// 1. True character illustrated artwork from reference (ssets/images/fiesta/).
/// 2. Active instrument playing animations:
///    - Frog (Trumpet): puffing cheeks, trumpet angle oscillation, golden sound blast rings.
///    - Snail (Drum): alternating drumstick strikes with vibration ripple rings.
///    - Grasshopper (Triangle): rhythmic striker wand strikes with chime sparkles.
/// 3. Stylized fallback placeholder with instrument badges if no asset is available.
class FiestaTrioCharacter extends StatelessWidget {
  final int characterIndex;
  final String name;
  final String instrumentEmoji;
  final String instrumentName;
  final Color primaryColor;
  final Color secondaryColor;
  final String? assetPath;
  final double width;
  final double height;
  final double swayAngle;
  final double scalePulse;
  final double verticalBounce;
  final double playProgress; // 0.0 to 1.0 for continuous instrument motion

  const FiestaTrioCharacter({
    super.key,
    required this.characterIndex,
    required this.name,
    required this.instrumentEmoji,
    required this.instrumentName,
    required this.primaryColor,
    required this.secondaryColor,
    this.assetPath,
    this.width = 110.0,
    this.height = 150.0,
    this.swayAngle = 0.0,
    this.scalePulse = 1.0,
    this.verticalBounce = 0.0,
    this.playProgress = 0.0,
  });

  /// Character 1: Frog blowing the Trumpet (Left in authentic trio)
  factory FiestaTrioCharacter.frog({
    Key? key,
    String? assetPath = 'assets/images/fiesta/frog_trumpet.png',
    double swayAngle = 0.0,
    double scalePulse = 1.0,
    double verticalBounce = 0.0,
    double playProgress = 0.0,
  }) {
    return FiestaTrioCharacter(
      key: key,
      characterIndex: 1,
      name: 'Frog',
      instrumentEmoji: '🎺',
      instrumentName: 'Trumpet',
      primaryColor: const Color(0xFF29B6F6), // Vibrant Sky Blue
      secondaryColor: const Color(0xFFFFD54F), // Gold Bell
      assetPath: assetPath,
      width: 115.0,
      height: 155.0,
      swayAngle: swayAngle,
      scalePulse: scalePulse,
      verticalBounce: verticalBounce,
      playProgress: playProgress,
    );
  }

  /// Character 2: Snail drumming on the Snare Drum (Center in authentic trio)
  factory FiestaTrioCharacter.snail({
    Key? key,
    String? assetPath = 'assets/images/fiesta/snail_drum.png',
    double swayAngle = 0.0,
    double scalePulse = 1.0,
    double verticalBounce = 0.0,
    double playProgress = 0.0,
  }) {
    return FiestaTrioCharacter(
      key: key,
      characterIndex: 2,
      name: 'Snail',
      instrumentEmoji: '🥁',
      instrumentName: 'Snare Drum',
      primaryColor: const Color(0xFFFF7043), // Fiesta Coral
      secondaryColor: const Color(0xFFFFF176), // Bright Yellow
      assetPath: assetPath,
      width: 110.0,
      height: 160.0,
      swayAngle: swayAngle,
      scalePulse: scalePulse,
      verticalBounce: verticalBounce,
      playProgress: playProgress,
    );
  }

  /// Character 3: Grasshopper striking the Triangle (Right in authentic trio)
  factory FiestaTrioCharacter.grasshopper({
    Key? key,
    String? assetPath = 'assets/images/fiesta/grasshopper_triangle.png',
    double swayAngle = 0.0,
    double scalePulse = 1.0,
    double verticalBounce = 0.0,
    double playProgress = 0.0,
  }) {
    return FiestaTrioCharacter(
      key: key,
      characterIndex: 3,
      name: 'Grasshopper',
      instrumentEmoji: '✨',
      instrumentName: 'Triangle',
      primaryColor: const Color(0xFF4CAF50), // Meadow Green
      secondaryColor: const Color(0xFFFFD54F), // Golden Triangle
      assetPath: assetPath,
      width: 115.0,
      height: 155.0,
      swayAngle: swayAngle,
      scalePulse: scalePulse,
      verticalBounce: verticalBounce,
      playProgress: playProgress,
    );
  }

  /// Backward-compatible factory for slot 1 (Left character)
  factory FiestaTrioCharacter.one({
    Key? key,
    String? assetPath,
    double swayAngle = 0.0,
    double scalePulse = 1.0,
    double verticalBounce = 0.0,
    double playProgress = 0.0,
  }) {
    return FiestaTrioCharacter(
      key: key,
      characterIndex: 1,
      name: 'Grasshopper',
      instrumentEmoji: '🪗',
      instrumentName: 'Accordion',
      primaryColor: const Color(0xFF4CAF50),
      secondaryColor: const Color(0xFFFFD54F),
      assetPath: assetPath,
      swayAngle: swayAngle,
      scalePulse: scalePulse,
      verticalBounce: verticalBounce,
      playProgress: playProgress,
    );
  }

  /// Backward-compatible factory for slot 2 (Center character)
  factory FiestaTrioCharacter.two({
    Key? key,
    String? assetPath,
    double swayAngle = 0.0,
    double scalePulse = 1.0,
    double verticalBounce = 0.0,
    double playProgress = 0.0,
  }) {
    return FiestaTrioCharacter(
      key: key,
      characterIndex: 2,
      name: 'Snail',
      instrumentEmoji: '🥁',
      instrumentName: 'Snare Drum',
      primaryColor: const Color(0xFFFF7043),
      secondaryColor: const Color(0xFFFFF176),
      assetPath: assetPath,
      swayAngle: swayAngle,
      scalePulse: scalePulse,
      verticalBounce: verticalBounce,
      playProgress: playProgress,
    );
  }

  /// Backward-compatible factory for slot 3 (Right character)
  factory FiestaTrioCharacter.three({
    Key? key,
    String? assetPath,
    double swayAngle = 0.0,
    double scalePulse = 1.0,
    double verticalBounce = 0.0,
    double playProgress = 0.0,
  }) {
    return FiestaTrioCharacter(
      key: key,
      characterIndex: 3,
      name: 'Frog',
      instrumentEmoji: '🎺',
      instrumentName: 'Trumpet',
      primaryColor: const Color(0xFF29B6F6),
      secondaryColor: const Color(0xFFFF80AB),
      assetPath: assetPath,
      swayAngle: swayAngle,
      scalePulse: scalePulse,
      verticalBounce: verticalBounce,
      playProgress: playProgress,
    );
  }

  @override
  Widget build(BuildContext context) {
    Widget characterVisual;

    if (assetPath != null && assetPath!.isNotEmpty) {
      characterVisual = Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          SizedBox(
            width: width,
            height: height,
            child: Stack(
              clipBehavior: Clip.none,
              alignment: Alignment.center,
              children: [
                // Base character illustration from user asset
                Image.asset(
                  assetPath!,
                  width: width,
                  height: height,
                  fit: BoxFit.contain,
                  errorBuilder: (context, error, stackTrace) => _buildStylizedPlaceholder(),
                ),

                // Dynamic Instrument Playing Overlay
                if (playProgress > 0)
                  Positioned(
                    bottom: 0,
                    child: _buildInstrumentPlayingOverlay(),
                  ),
              ],
            ),
          ),
          const SizedBox(height: 4),
          _buildInstrumentLabel(),
        ],
      );
    } else {
      characterVisual = _buildStylizedPlaceholder();
    }

    return Transform.translate(
      offset: Offset(0, verticalBounce),
      child: Transform.rotate(
        angle: swayAngle,
        child: Transform.scale(
          scale: scalePulse,
          child: characterVisual,
        ),
      ),
    );
  }

  /// Active playing animation overlay corresponding to each character's instrument
  Widget _buildInstrumentPlayingOverlay() {
    switch (characterIndex) {
      case 1: // Frog / Horn
        return FrogTrumpetVisual(
          playProgress: playProgress,
          size: 70,
        );
      case 2: // Snail / Drum
        return SnailDrumVisual(
          playProgress: playProgress,
          size: 75,
        );
      case 3: // Grasshopper / Triangle
        return GrasshopperTriangleVisual(
          playProgress: playProgress,
          size: 65,
        );
      default:
        return const SizedBox.shrink();
    }
  }

  /// Instrument name badge
  Widget _buildInstrumentLabel() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
      decoration: BoxDecoration(
        color: secondaryColor,
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: Colors.white, width: 1),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.15),
            blurRadius: 4,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Text(
        instrumentName,
        style: const TextStyle(
          fontSize: 10,
          fontWeight: FontWeight.w900,
          color: Color(0xFF263238),
          letterSpacing: 0.2,
        ),
        maxLines: 1,
        overflow: TextOverflow.ellipsis,
      ),
    );
  }

  /// Kid-friendly stylized fallback placeholder with instrument badges
  Widget _buildStylizedPlaceholder() {
    return Container(
      width: width,
      height: height,
      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 8),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [primaryColor, primaryColor.withValues(alpha: 0.85)],
        ),
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: Colors.white, width: 3),
        boxShadow: [
          BoxShadow(
            color: primaryColor.withValues(alpha: 0.45),
            blurRadius: 16,
            spreadRadius: 2,
            offset: const Offset(0, 6),
          ),
        ],
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          // Festive Sombrero Hat emoji
          const Text('🎩', style: TextStyle(fontSize: 22)),
          const SizedBox(height: 2),

          // Main Instrument Visual / Playing Animation
          if (playProgress > 0)
            _buildInstrumentPlayingOverlay()
          else
            Container(
              width: 46,
              height: 46,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: Colors.white,
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withValues(alpha: 0.12),
                    blurRadius: 6,
                    offset: const Offset(0, 2),
                  ),
                ],
              ),
              child: Center(
                child: Text(
                  instrumentEmoji,
                  style: const TextStyle(fontSize: 26),
                ),
              ),
            ),
          const SizedBox(height: 6),

          _buildInstrumentLabel(),
        ],
      ),
    );
  }
}
