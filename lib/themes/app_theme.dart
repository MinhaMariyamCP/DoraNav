import 'package:flutter/material.dart';

/// Design tokens and theme definitions for the DoraNav application.
/// Colors and styling are inspired by Dora the Explorer's vibrant adventure palette.
class AppColors {
  AppColors._();

  // Twilight sky & background palette
  static const Color twilightDark = Color(0xFF0F0523);
  static const Color twilightPurple = Color(0xFF1E0A3C);
  static const Color deepPurple = Color(0xFF2E1054);
  static const Color nightSkyGlow = Color(0xFF4C1878);
  static const Color cardDark = Color(0xFF1F1138);

  // Star & Accent Yellows
  static const Color starYellow = Color(0xFFFFD54F);
  static const Color starGold = Color(0xFFFFB300);
  static const Color starBright = Color(0xFFFFF176);

  // Location Pin Colors
  static const Color pinRed = Color(0xFFFF2A4E);
  static const Color pinRedDark = Color(0xFFC70830);
  static const Color pinRedLight = Color(0xFFFF6584);
  static const Color pinInnerPurple = Color(0xFF4A186F);

  // Dora Signature Orange & Accents
  static const Color doraOrange = Color(0xFFFF7A00);
  static const Color doraOrangeDark = Color(0xFFD64D00);
  static const Color doraOrangeLight = Color(0xFFFFAB40);
  static const Color doraPink = Color(0xFFFF4081);

  // Typography & UI Whites
  static const Color navWhite = Color(0xFFFFFFFF);
  static const Color textLight = Color(0xFFF3E5F5);
  static const Color textMuted = Color(0xFFB39DDB);

  // Boots & Companion Accents
  static const Color bootsPurple = Color(0xFF9353C4);
  static const Color bootsYellow = Color(0xFFFCE66D);
  static const Color bootsRed = Color(0xFFE53935);

  // Jungle & Adventure Greens
  static const Color jungleGreen = Color(0xFF2E7D32);
  static const Color jungleGreenLight = Color(0xFF4CAF50);

  // Gradients
  static const LinearGradient skyGradient = LinearGradient(
    begin: Alignment.topCenter,
    end: Alignment.bottomCenter,
    colors: [twilightDark, twilightPurple, deepPurple],
  );

  static const LinearGradient doraTitleGradient = LinearGradient(
    begin: Alignment.topCenter,
    end: Alignment.bottomCenter,
    colors: [starBright, doraOrange, doraOrangeDark],
  );

  static const LinearGradient navTitleGradient = LinearGradient(
    begin: Alignment.topCenter,
    end: Alignment.bottomCenter,
    colors: [navWhite, Color(0xFFE0E0E0), Color(0xFFBDBDBD)],
  );

  static const LinearGradient progressBarGradient = LinearGradient(
    colors: [doraOrange, starYellow, jungleGreenLight],
  );
}

class AppSpacing {
  AppSpacing._();

  static const double xs = 4.0;
  static const double sm = 8.0;
  static const double md = 16.0;
  static const double lg = 24.0;
  static const double xl = 32.0;
  static const double xxl = 48.0;
}

class AppTypography {
  AppTypography._();

  static const TextStyle title3D = TextStyle(
    fontSize: 48.0,
    fontWeight: FontWeight.w900,
    letterSpacing: -1.0,
    color: AppColors.navWhite,
  );

  static const TextStyle subtitle = TextStyle(
    fontSize: 18.0,
    fontWeight: FontWeight.w800,
    color: AppColors.navWhite,
    letterSpacing: 0.2,
    shadows: [
      Shadow(
        offset: Offset(0, 2),
        blurRadius: 4,
        color: Color(0x99000000),
      ),
    ],
  );

  static const TextStyle tagLine = TextStyle(
    fontSize: 14.0,
    fontWeight: FontWeight.w600,
    color: AppColors.textLight,
    letterSpacing: 0.5,
    shadows: [
      Shadow(
        offset: Offset(0, 1.5),
        blurRadius: 3,
        color: Color(0x88000000),
      ),
    ],
  );

  static const TextStyle button = TextStyle(
    fontSize: 16.0,
    fontWeight: FontWeight.bold,
    letterSpacing: 0.5,
    color: Colors.white,
  );
}

class DoraNavTheme {
  DoraNavTheme._();

  static ThemeData get theme {
    return ThemeData(
      useMaterial3: true,
      brightness: Brightness.dark,
      scaffoldBackgroundColor: AppColors.twilightDark,
      colorScheme: const ColorScheme.dark(
        primary: AppColors.doraOrange,
        secondary: AppColors.starYellow,
        surface: AppColors.cardDark,
      ),
    );
  }
}
