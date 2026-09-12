import 'package:flutter/material.dart';
import '../../controllers/celebration_controller.dart';
import '../../services/audio_service.dart';
import 'fiesta_character_one.dart';
import 'fiesta_character_two.dart';
import 'fiesta_character_three.dart';
import 'fiesta_trio_effects.dart';

/// Interactive Fiesta Trio Celebration overlay widget.
///
/// Plays native Flutter animations inspired by the authentic reference video:
/// 1. "ADVENTURE COMPLETE! You reached [DESTINATION]!" banner
/// 2. Staggered animated entrance of the Fiesta Trio (left, bottom, right)
/// 3. Looping musical performance with instrument swaying, body bouncing,
///    background sparkles, floating musical notes, and festive confetti
///
/// Tapping anywhere or clicking "Skip" bypasses celebration directly to the travel report.
class FiestaTrioCelebration extends StatefulWidget {
  final String destinationName;
  final dynamic tripData;
  final VoidCallback onComplete;
  final String? character1Asset;
  final String? character2Asset;
  final String? character3Asset;
  final bool autoShowTravelReport;

  const FiestaTrioCelebration({
    super.key,
    required this.destinationName,
    required this.tripData,
    required this.onComplete,
    this.character1Asset = 'assets/images/fiesta/fiesta_character_one.png',
    this.character2Asset = 'assets/images/fiesta/fiesta_character_two.png',
    this.character3Asset = 'assets/images/fiesta/fiesta_character_three.png',
    this.autoShowTravelReport = true,
  });

  String get char1Asset =>
      (character1Asset != null && character1Asset!.isNotEmpty)
          ? character1Asset!
          : 'assets/images/fiesta/fiesta_character_one.png';

  String get char2Asset =>
      (character2Asset != null && character2Asset!.isNotEmpty)
          ? character2Asset!
          : 'assets/images/fiesta/fiesta_character_two.png';

  String get char3Asset =>
      (character3Asset != null && character3Asset!.isNotEmpty)
          ? character3Asset!
          : 'assets/images/fiesta/fiesta_character_three.png';

  /// Presents the celebration as a full-screen interactive modal dialog
  static Future<void> show(
    BuildContext context, {
    required String destinationName,
    required dynamic tripData,
    required VoidCallback onComplete,
    String? character1Asset,
    String? character2Asset,
    String? character3Asset,
    bool autoShowTravelReport = true,
  }) async {
    await showGeneralDialog(
      context: context,
      barrierDismissible: false,
      barrierLabel: 'FiestaTrioCelebration',
      barrierColor: Colors.black.withValues(alpha: 0.65),
      transitionDuration: const Duration(milliseconds: 350),
      pageBuilder: (dialogCtx, animation, secondaryAnimation) {
        return FiestaTrioCelebration(
          destinationName: destinationName,
          tripData: tripData,
          character1Asset: character1Asset ?? 'assets/images/fiesta/fiesta_character_one.png',
          character2Asset: character2Asset ?? 'assets/images/fiesta/fiesta_character_two.png',
          character3Asset: character3Asset ?? 'assets/images/fiesta/fiesta_character_three.png',
          autoShowTravelReport: autoShowTravelReport,
          onComplete: () {
            Navigator.of(dialogCtx).pop();
            onComplete();
          },
        );
      },
    );
  }

  @override
  State<FiestaTrioCelebration> createState() => _FiestaTrioCelebrationState();
}

class _FiestaTrioCelebrationState extends State<FiestaTrioCelebration>
    with TickerProviderStateMixin {
  late final CelebrationController _controller;

  late AnimationController _entranceController;
  late AnimationController _bodyBounceController;
  late AnimationController _performanceController;
  late AnimationController _effectsController;

  // Staggered entrance animations
  late Animation<Offset> _char1Slide;
  late Animation<double> _char2Scale;
  late Animation<double> _char2Fade;
  late Animation<Offset> _char2Slide;
  late Animation<Offset> _char3Slide;

  bool _completedFired = false;

  @override
  void initState() {
    super.initState();
    _controller = CelebrationController();
    _controller.addListener(_onControllerStateChanged);

    // 1. Entrances Controller (850ms - staggered 0 to 800ms)
    _entranceController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 850),
    );

    // Character 1: Slides from left with bounce (0.0 to 0.70)
    _char1Slide = Tween<Offset>(
      begin: const Offset(-2.2, 0.0),
      end: Offset.zero,
    ).animate(CurvedAnimation(
      parent: _entranceController,
      curve: const Interval(0.0, 0.70, curve: Curves.easeOutBack),
    ));

    // Character 2: Pops upward from bottom with elastic bounce and fade (0.20 to 0.90)
    _char2Slide = Tween<Offset>(
      begin: const Offset(0.0, 1.8),
      end: Offset.zero,
    ).animate(CurvedAnimation(
      parent: _entranceController,
      curve: const Interval(0.20, 0.90, curve: Curves.easeOutBack),
    ));

    _char2Scale = Tween<double>(begin: 0.1, end: 1.0).animate(CurvedAnimation(
      parent: _entranceController,
      curve: const Interval(0.20, 0.90, curve: Curves.elasticOut),
    ));

    _char2Fade = Tween<double>(begin: 0.0, end: 1.0).animate(CurvedAnimation(
      parent: _entranceController,
      curve: const Interval(0.20, 0.60, curve: Curves.easeIn),
    ));

    // Character 3: Slides from right with bounce (0.35 to 1.0)
    _char3Slide = Tween<Offset>(
      begin: const Offset(2.2, 0.0),
      end: Offset.zero,
    ).animate(CurvedAnimation(
      parent: _entranceController,
      curve: const Interval(0.35, 1.0, curve: Curves.easeOutBack),
    ));

    // 2. Body Bounce Controller
    _bodyBounceController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 600),
      value: 1.0,
    );

    // 3. Performance Looping Controller (~950ms)
    _performanceController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 950),
    );

    // 4. Effects Looping Controller (~2400ms)
    _effectsController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 2600),
    );

    // Start celebration timeline
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final reduceMotion = MediaQuery.maybeOf(context)?.disableAnimations ?? false;
      _controller.startCelebration(reduceMotion: reduceMotion);
      _effectsController.repeat();
    });
  }

  void _onControllerStateChanged() {
    if (!mounted) return;

    if (_controller.isEntrances && !_entranceController.isAnimating && !_entranceController.isCompleted) {
      _entranceController.forward().then((_) {
        if (mounted) {
          _bodyBounceController.forward();
          if (_controller.isPerforming) {
            _performanceController.repeat();
          }
        }
      });
    } else if (_controller.isPerforming && !_performanceController.isAnimating) {
      _bodyBounceController.forward();
      _performanceController.repeat();
    } else if (_controller.isCompleted) {
      _finish();
    }
  }

  void _finish() {
    if (_completedFired) return;
    _completedFired = true;
    widget.onComplete();
  }

  @override
  void dispose() {
    _controller.removeListener(_onControllerStateChanged);
    _controller.dispose();
    _entranceController.dispose();
    _bodyBounceController.dispose();
    _performanceController.dispose();
    _effectsController.dispose();
    AudioService.instance.stopAllMusic();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final reduceMotion = MediaQuery.maybeOf(context)?.disableAnimations ?? false;

    return Scaffold(
      backgroundColor: Colors.transparent,
      body: GestureDetector(
        behavior: HitTestBehavior.opaque,
        onTap: () => _controller.skipCelebration(),
        child: Stack(
          children: [
            // Backdrop with subtle celebratory gradient
            Container(
              decoration: BoxDecoration(
                gradient: RadialGradient(
                  center: const Alignment(0.0, -0.1),
                  radius: 1.1,
                  colors: [
                    const Color(0xFF6A1B9A).withValues(alpha: 0.85),
                    const Color(0xFF280645).withValues(alpha: 0.95),
                  ],
                ),
              ),
            ),

            // Layer 1: Celebratory Visual Effects (Background Sparkles, Rising Notes, Confetti)
            AnimatedBuilder(
              animation: _effectsController,
              builder: (context, child) {
                return FiestaTrioEffects(
                  animationProgress: _effectsController.value,
                  enableMotion: !reduceMotion,
                );
              },
            ),

            // Layer 2: Main Interactive Content
            SafeArea(
              child: Column(
                children: [
                  // Top Navigation Bar with Skip Button
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 12),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        // Soundwave badge
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                          decoration: BoxDecoration(
                            color: Colors.white.withValues(alpha: 0.2),
                            borderRadius: BorderRadius.circular(20),
                            border: Border.all(color: Colors.white.withValues(alpha: 0.3)),
                          ),
                          child: const Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Text('🎶', style: TextStyle(fontSize: 16)),
                              SizedBox(width: 6),
                              Text(
                                'Fiesta Trio Concert',
                                style: TextStyle(
                                  color: Colors.white,
                                  fontWeight: FontWeight.w800,
                                  fontSize: 12,
                                ),
                              ),
                            ],
                          ),
                        ),

                        // Skip Button
                        TextButton.icon(
                          onPressed: () => _controller.skipCelebration(),
                          icon: const Text('⏩', style: TextStyle(fontSize: 14)),
                          label: const Text(
                            'Skip',
                            style: TextStyle(
                              color: Colors.white,
                              fontWeight: FontWeight.w900,
                              fontSize: 14,
                            ),
                          ),
                          style: TextButton.styleFrom(
                            backgroundColor: Colors.white.withValues(alpha: 0.25),
                            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
                            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(18)),
                          ),
                        ),
                      ],
                    ),
                  ),

                  const Spacer(flex: 1),

                  // Phase 1: Celebratory Toast ("🎉 We Made It!")
                  _buildCelebratoryHeader(),

                  const SizedBox(height: 24),

                  // Phase 2 & 3: Fiesta Trio Characters with Entrances and Musical Performance
                  _buildFiestaTrioRow(reduceMotion),

                  const Spacer(flex: 2),

                  // Bottom Prompt
                  Padding(
                    padding: const EdgeInsets.only(bottom: 24),
                    child: AnimatedOpacity(
                      opacity: _controller.isPerforming ? 1.0 : 0.0,
                      duration: const Duration(milliseconds: 400),
                      child: Container(
                        padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 10),
                        decoration: BoxDecoration(
                          color: const Color(0xFFFFD54F),
                          borderRadius: BorderRadius.circular(24),
                          boxShadow: [
                            BoxShadow(
                              color: const Color(0xFFFFD54F).withValues(alpha: 0.5),
                              blurRadius: 16,
                              spreadRadius: 2,
                            ),
                          ],
                        ),
                        child: const Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Text('⭐', style: TextStyle(fontSize: 18)),
                            SizedBox(width: 8),
                            Text(
                              'Tap anywhere to view Travel Report',
                              style: TextStyle(
                                color: Color(0xFF3E2723),
                                fontWeight: FontWeight.w900,
                                fontSize: 13,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  /// Celebratory Header Banner
  Widget _buildCelebratoryHeader() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 24),
      child: Column(
        children: [
          // "ADVENTURE COMPLETE!"
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 22, vertical: 12),
            decoration: BoxDecoration(
              gradient: const LinearGradient(
                colors: [Color(0xFFFF5722), Color(0xFFFFB300)],
              ),
              borderRadius: BorderRadius.circular(24),
              border: Border.all(color: Colors.white, width: 2.5),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withValues(alpha: 0.35),
                  blurRadius: 18,
                  offset: const Offset(0, 5),
                ),
              ],
            ),
            child: const Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text('🎉', style: TextStyle(fontSize: 24)),
                SizedBox(width: 10),
                Text(
                  'ADVENTURE COMPLETE!',
                  style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.w900,
                    color: Colors.white,
                    letterSpacing: 0.8,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 12),

          // Dynamic Destination Subtitle: "You reached [DESTINATION]!"
          Text(
            'You reached ${widget.destinationName}!',
            textAlign: TextAlign.center,
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.w800,
              color: Colors.white.withValues(alpha: 0.95),
              shadows: const [
                Shadow(color: Colors.black54, blurRadius: 8, offset: Offset(0, 2)),
              ],
            ),
          ),
        ],
      ),
    );
  }

  /// Row of 3 choreographed characters (Character 1: Frog, Character 2: Grasshopper, Character 3: Snail)
  Widget _buildFiestaTrioRow(bool reduceMotion) {
    return LayoutBuilder(
      builder: (context, constraints) {
        // Dynamic responsive sizing for mobile displays
        final screenWidth = MediaQuery.of(context).size.width;
        final charWidth = (screenWidth / 3.4).clamp(95.0, 130.0);
        final charHeight = charWidth * 1.25;

        return Row(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.end,
          children: [
            // Character 1: Blue Frog with Drum (Left)
            FiestaCharacterOne(
              entranceSlide: _char1Slide,
              bodyBounce: _bodyBounceController,
              performanceLoop: _performanceController,
              width: charWidth,
              height: charHeight,
              assetPath: widget.char1Asset,
            ),

            const SizedBox(width: 8),

            // Character 2: Orange Grasshopper with Accordion (Center)
            FiestaCharacterTwo(
              entranceScale: _char2Scale,
              entranceFade: _char2Fade,
              entranceSlide: _char2Slide,
              bodyBounce: _bodyBounceController,
              performanceLoop: _performanceController,
              width: charWidth * 1.08,
              height: charHeight * 1.08,
              assetPath: widget.char2Asset,
            ),

            const SizedBox(width: 8),

            // Character 3: Pink Snail with Cymbals (Right)
            FiestaCharacterThree(
              entranceSlide: _char3Slide,
              bodyBounce: _bodyBounceController,
              performanceLoop: _performanceController,
              width: charWidth,
              height: charHeight,
              assetPath: widget.char3Asset,
            ),
          ],
        );
      },
    );
  }
}
