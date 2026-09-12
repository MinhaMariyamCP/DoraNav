import 'dart:async';
import 'package:flutter/material.dart';
import '../../themes/app_theme.dart';
import '../../widgets/shared/adventure_button.dart';
import 'models/splash_config.dart';
import 'widgets/dora_nav_logo.dart';
import 'widgets/glowing_pin_pulse.dart';
import 'widgets/splash_loading_progress.dart';
import 'widgets/twinkling_stars_layer.dart';

/// Main Splash Screen for DoraNav.
/// Faithfully reproduces the visual hierarchy and whimsical adventure atmosphere
/// from the 3D reference poster featuring Dora, Boots, and the glowing DoraNav beacon.
class SplashScreen extends StatefulWidget {
  final SplashConfig config;
  final VoidCallback? onAdventureReady;

  const SplashScreen({
    super.key,
    this.config = const SplashConfig(),
    this.onAdventureReady,
  });

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen>
    with SingleTickerProviderStateMixin {
  late AnimationController _entranceController;
  late Animation<double> _fadeAnimation;
  late Animation<Offset> _slideAnimation;

  Timer? _progressTimer;
  double _currentProgress = 0.0;
  int _currentStepIndex = 0;
  bool _isReady = false;

  @override
  void initState() {
    super.initState();

    // Entrance animation for overlays
    _entranceController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1000),
    );

    _fadeAnimation = CurvedAnimation(
      parent: _entranceController,
      curve: Curves.easeOut,
    );

    _slideAnimation = Tween<Offset>(
      begin: const Offset(0.0, 0.08),
      end: Offset.zero,
    ).animate(CurvedAnimation(
      parent: _entranceController,
      curve: Curves.easeOutCubic,
    ));

    _entranceController.forward();
    _startLoadingSimulation();
  }

  void _startLoadingSimulation() {
    final totalDurationMs = widget.config.duration.inMilliseconds;
    const tickIntervalMs = 50;
    final totalTicks = totalDurationMs / tickIntervalMs;
    final increment = 1.0 / totalTicks;

    _progressTimer = Timer.periodic(
      const Duration(milliseconds: tickIntervalMs),
      (timer) {
        if (!mounted) {
          timer.cancel();
          return;
        }

        setState(() {
          _currentProgress += increment;

          // Update loading step message dynamically
          final stepsCount = widget.config.loadingSteps.length;
          if (stepsCount > 0) {
            final calculatedIndex = (_currentProgress * stepsCount).floor();
            _currentStepIndex = calculatedIndex.clamp(0, stepsCount - 1);
          }

          if (_currentProgress >= 1.0) {
            _currentProgress = 1.0;
            _isReady = true;
            timer.cancel();
            _onLoadingCompleted();
          }
        });
      },
    );
  }

  void _onLoadingCompleted() {
    if (widget.config.autoNavigate) {
      Future.delayed(const Duration(milliseconds: 400), () {
        if (mounted) {
          _proceedToAdventure();
        }
      });
    }
  }

  void _proceedToAdventure() {
    _progressTimer?.cancel();
    if (widget.onAdventureReady != null) {
      widget.onAdventureReady!();
    } else {
      // Default fallback navigation point
      // TODO: Replace with real navigation route (e.g. Navigator.pushReplacementNamed(context, '/home'))
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text("¡Vámonos! Entering Dora's Adventure World..."),
          backgroundColor: AppColors.doraOrange,
          duration: Duration(seconds: 2),
        ),
      );
    }
  }

  @override
  void dispose() {
    _progressTimer?.cancel();
    _entranceController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final padding = MediaQuery.of(context).padding;
    final stepMessage = widget.config.loadingSteps.isNotEmpty
        ? widget.config.loadingSteps[_currentStepIndex]
        : 'Loading DoraNav...';

    return Scaffold(
      backgroundColor: AppColors.twilightDark,
      body: GestureDetector(
        behavior: HitTestBehavior.opaque,
        onTap: _proceedToAdventure,
        child: LayoutBuilder(
          builder: (context, constraints) {
            return Stack(
              fit: StackFit.expand,
              children: [
              // 1. Primary Visual: 3D Art Background Poster
              _buildBackgroundPoster(constraints),

              // 2. Interactive Twinkling Stars in Twilight Sky
              Positioned(
                top: 0,
                left: 0,
                right: 0,
                height: constraints.maxHeight * 0.40,
                child: const TwinklingStarsLayer(
                  numberOfStars: 32,
                ),
              ),

              // 3. Glowing Map Pin Radar Pulse at Top Center
              // Aligned with the pin in the 3D reference poster
              Positioned(
                top: padding.top + (constraints.maxHeight * 0.04),
                left: (constraints.maxWidth - 130) / 2,
                child: const GlowingPinPulse(size: 130),
              ),

              // 4. Top Action Bar with Quick Skip Button
              Positioned(
                top: padding.top + 8,
                right: 16,
                child: _buildSkipButton(),
              ),

              // 5. Bottom Interactive Panel with Adventure Loading Progress
              Positioned(
                left: 0,
                right: 0,
                bottom: padding.bottom + 16,
                child: FadeTransition(
                  opacity: _fadeAnimation,
                  child: SlideTransition(
                    position: _slideAnimation,
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        if (!_isReady) ...[
                          SplashLoadingProgress(
                            progress: _currentProgress,
                            statusMessage: stepMessage,
                            onSkipPressed: _proceedToAdventure,
                          ),
                        ] else ...[
                          Padding(
                            padding: const EdgeInsets.symmetric(horizontal: 24.0),
                            child: AdventureButton(
                              label: "¡Vámonos! Let's Go!",
                              icon: Icons.rocket_launch_rounded,
                              onPressed: _proceedToAdventure,
                            ),
                          ),
                        ],
                      ],
                    ),
                  ),
                ),
              ),
            ],
          );
        },
      ),
    ),
  );
}

  /// Renders the reference 3D image asset with a robust fallback
  /// that matches the reference colors in case the asset is being cached.
  Widget _buildBackgroundPoster(BoxConstraints constraints) {
    return Image.asset(
      'assets/images/splash_poster.jpg',
      fit: BoxFit.cover,
      width: constraints.maxWidth,
      height: constraints.maxHeight,
      errorBuilder: (context, error, stackTrace) {
        // High-fidelity pure Flutter fallback if asset is missing
        return Container(
          decoration: const BoxDecoration(
            gradient: AppColors.skyGradient,
          ),
          child: SafeArea(
            child: Column(
              children: [
                const SizedBox(height: 32),
                const DoraNavLogo(scale: 1.0),
                const Spacer(),
                const Icon(
                  Icons.landscape_rounded,
                  size: 120,
                  color: AppColors.jungleGreen,
                ),
                const SizedBox(height: 16),
                Text(
                  "Dora's Jungle Adventure Path",
                  style: AppTypography.tagLine.copyWith(
                    color: AppColors.starYellow,
                  ),
                ),
                const Spacer(),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildSkipButton() {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: _proceedToAdventure,
        borderRadius: BorderRadius.circular(20),
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 6),
          decoration: BoxDecoration(
            color: AppColors.twilightDark.withValues(alpha: 0.6),
            borderRadius: BorderRadius.circular(20),
            border: Border.all(
              color: AppColors.starYellow.withValues(alpha: 0.4),
              width: 1.0,
            ),
          ),
          child: const Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                'Skip',
                style: TextStyle(
                  color: AppColors.starBright,
                  fontSize: 12,
                  fontWeight: FontWeight.w700,
                ),
              ),
              SizedBox(width: 4),
              Icon(
                Icons.skip_next_rounded,
                size: 16,
                color: AppColors.starBright,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
