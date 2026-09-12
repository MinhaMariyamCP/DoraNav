/// Configuration model for the DoraNav Splash Screen.
/// Decouples data/runtime settings from the presentation widgets.
class SplashConfig {
  /// The main application name displayed in the 3D logo
  final String appName;

  /// Primary subtitle describing the application
  final String subtitle;

  /// Secondary adventure tagline
  final String tagline;

  /// Duration before auto-navigating to the next screen
  final Duration duration;

  /// Whether to automatically transition when loading reaches 100%
  final bool autoNavigate;

  /// Playful adventure messages cycled during loading
  final List<String> loadingSteps;

  const SplashConfig({
    this.appName = 'DoraNav',
    this.subtitle = "Navigation for Dora's World",
    this.tagline = 'Explore. Navigate. Adventure!',
    this.duration = const Duration(milliseconds: 1500),
    this.autoNavigate = true,
    this.loadingSteps = const [
      'Checking the map...',
      'Packing the purple backpack...',
      'Finding Boots the monkey...',
      'Keeping an eye out for Swiper...',
      'Ready for adventure!',
    ],
  });

  /// Factory for default production configuration
  factory SplashConfig.defaultConfig() => const SplashConfig();

  SplashConfig copyWith({
    String? appName,
    String? subtitle,
    String? tagline,
    Duration? duration,
    bool? autoNavigate,
    List<String>? loadingSteps,
  }) {
    return SplashConfig(
      appName: appName ?? this.appName,
      subtitle: subtitle ?? this.subtitle,
      tagline: tagline ?? this.tagline,
      duration: duration ?? this.duration,
      autoNavigate: autoNavigate ?? this.autoNavigate,
      loadingSteps: loadingSteps ?? this.loadingSteps,
    );
  }
}
