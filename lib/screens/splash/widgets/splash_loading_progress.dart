import 'package:flutter/material.dart';
import '../../../themes/app_theme.dart';

/// Loading indicator and adventure step status bar for the Splash Screen.
/// Provides visual feedback during asset pre-caching or initial navigation sync.
class SplashLoadingProgress extends StatelessWidget {
  final double progress; // 0.0 to 1.0
  final String statusMessage;
  final VoidCallback? onSkipPressed;

  const SplashLoadingProgress({
    super.key,
    required this.progress,
    required this.statusMessage,
    this.onSkipPressed,
  });

  @override
  Widget build(BuildContext context) {
    final percent = (progress * 100).toInt().clamp(0, 100);

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 20.0, vertical: 14.0),
      margin: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 16.0),
      decoration: BoxDecoration(
        color: AppColors.twilightDark.withValues(alpha: 0.72),
        borderRadius: BorderRadius.circular(24.0),
        border: Border.all(
          color: AppColors.starYellow.withValues(alpha: 0.35),
          width: 1.5,
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.4),
            blurRadius: 18,
            offset: const Offset(0, 8),
          ),
          BoxShadow(
            color: AppColors.deepPurple.withValues(alpha: 0.5),
            blurRadius: 12,
            spreadRadius: 2,
          ),
        ],
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          // Dynamic status message with playful icon
          Row(
            children: [
              const Icon(
                Icons.explore_rounded,
                color: AppColors.starYellow,
                size: 20,
              ),
              const SizedBox(width: 8),
              Expanded(
                child: AnimatedSwitcher(
                  duration: const Duration(milliseconds: 300),
                  transitionBuilder: (child, animation) {
                    return FadeTransition(
                      opacity: animation,
                      child: SlideTransition(
                        position: Tween<Offset>(
                          begin: const Offset(0.0, 0.3),
                          end: Offset.zero,
                        ).animate(animation),
                        child: child,
                      ),
                    );
                  },
                  child: Text(
                    statusMessage,
                    key: ValueKey<String>(statusMessage),
                    style: const TextStyle(
                      fontSize: 14.0,
                      fontWeight: FontWeight.w700,
                      color: AppColors.textLight,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
              ),
              Text(
                '$percent%',
                style: const TextStyle(
                  fontSize: 14.0,
                  fontWeight: FontWeight.w900,
                  color: AppColors.starBright,
                ),
              ),
            ],
          ),
          const SizedBox(height: 10),
          // Custom Gradient Adventure Progress Bar
          LayoutBuilder(
            builder: (context, constraints) {
              final barWidth = constraints.maxWidth;
              final filledWidth = barWidth * progress.clamp(0.0, 1.0);

              return Stack(
                clipBehavior: Clip.none,
                children: [
                  // Track background
                  Container(
                    height: 12.0,
                    width: barWidth,
                    decoration: BoxDecoration(
                      color: Colors.black.withValues(alpha: 0.45),
                      borderRadius: BorderRadius.circular(8.0),
                      border: Border.all(
                        color: Colors.white.withValues(alpha: 0.12),
                        width: 1.0,
                      ),
                    ),
                  ),
                  // Animated gradient fill
                  AnimatedContainer(
                    duration: const Duration(milliseconds: 250),
                    curve: Curves.easeOutCubic,
                    height: 12.0,
                    width: filledWidth,
                    decoration: BoxDecoration(
                      gradient: AppColors.progressBarGradient,
                      borderRadius: BorderRadius.circular(8.0),
                      boxShadow: [
                        BoxShadow(
                          color: AppColors.doraOrange.withValues(alpha: 0.6),
                          blurRadius: 8,
                          spreadRadius: 1,
                        ),
                      ],
                    ),
                  ),
                  // Glowing map pin tip indicator
                  if (filledWidth > 12)
                    Positioned(
                      left: filledWidth - 10,
                      top: -4,
                      child: Container(
                        width: 20,
                        height: 20,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          color: AppColors.starBright,
                          boxShadow: [
                            BoxShadow(
                              color: AppColors.starGold.withValues(alpha: 0.8),
                              blurRadius: 6,
                              spreadRadius: 2,
                            ),
                          ],
                        ),
                        child: const Center(
                          child: Icon(
                            Icons.star_rounded,
                            size: 14,
                            color: AppColors.doraOrangeDark,
                          ),
                        ),
                      ),
                    ),
                ],
              );
            },
          ),
        ],
      ),
    );
  }
}
