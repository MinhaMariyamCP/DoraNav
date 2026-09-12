import 'package:flutter/material.dart';

/// Design tokens for the DoraNav Backpack experience.
/// Playful Dora-themed palette with purple primary, warm kid-friendly colors,
/// soft rounded cards, and gentle shadows.
class BackpackColors {
  BackpackColors._();

  // Purple Primary Palette
  static const Color primaryPurple = Color(0xFF8A6CF6);
  static const Color primaryPurpleDark = Color(0xFF6C4DE6);
  static const Color softPurple = Color(0xFFBDA8FF);
  static const Color lightPurple = Color(0xFFEDE7FF);
  static const Color lavender = Color(0xFFF3EFFF);
  static const Color background = Color(0xFFF6F4FF);

  // Kid-Friendly Accents
  static const Color accentPink = Color(0xFFFF9AB3);
  static const Color accentPinkDark = Color(0xFFF06292);
  static const Color accentTeal = Color(0xFF4DD0E1);
  static const Color accentGreen = Color(0xFF66BB6A);
  static const Color accentYellow = Color(0xFFFFD54F);
  static const Color accentOrange = Color(0xFFFF9800);
  static const Color starGold = Color(0xFFFFCA28);

  // Swiper Alert
  static const Color swiperRed = Color(0xFFE53935);
  static const Color swiperRedSoft = Color(0xFFFFEBEE);

  // Text Colors
  static const Color textDark = Color(0xFF2A1D40);
  static const Color textSecondary = Color(0xFF6E5D87);
  static const Color textMuted = Color(0xFF9E8DB7);
  static const Color textWhite = Colors.white;

  // Surfaces & Borders
  static const Color cardWhite = Colors.white;
  static const Color borderLight = Color(0xFFE5DEFC);

  // Essential Tag
  static const Color essentialBg = Color(0xFFE8F5E9);
  static const Color essentialText = Color(0xFF2E7D32);
}

class BackpackTypography {
  BackpackTypography._();

  static const TextStyle screenTitle = TextStyle(
    fontSize: 22,
    fontWeight: FontWeight.w900,
    color: BackpackColors.textDark,
    letterSpacing: -0.2,
  );

  static const TextStyle cardTitle = TextStyle(
    fontSize: 16,
    fontWeight: FontWeight.w800,
    color: BackpackColors.textDark,
  );

  static const TextStyle cardDescription = TextStyle(
    fontSize: 13,
    fontWeight: FontWeight.w500,
    color: BackpackColors.textSecondary,
    height: 1.25,
  );

  static const TextStyle reasonText = TextStyle(
    fontSize: 12,
    fontWeight: FontWeight.w600,
    color: BackpackColors.primaryPurpleDark,
  );

  static const TextStyle badgeText = TextStyle(
    fontSize: 11,
    fontWeight: FontWeight.w800,
    color: Colors.white,
  );

  static const TextStyle buttonLabel = TextStyle(
    fontSize: 14,
    fontWeight: FontWeight.w800,
    color: Colors.white,
    letterSpacing: 0.2,
  );
}

class BackpackDecorations {
  BackpackDecorations._();

  static BoxDecoration cardDecoration({bool isSelected = false}) {
    return BoxDecoration(
      color: BackpackColors.cardWhite,
      borderRadius: BorderRadius.circular(20),
      border: Border.all(
        color: isSelected ? BackpackColors.primaryPurple : BackpackColors.borderLight,
        width: isSelected ? 2.0 : 1.0,
      ),
      boxShadow: [
        BoxShadow(
          color: isSelected
              ? BackpackColors.primaryPurple.withValues(alpha: 0.18)
              : const Color(0xFF5E35B1).withValues(alpha: 0.08),
          blurRadius: 14,
          offset: const Offset(0, 4),
          spreadRadius: isSelected ? 1 : 0,
        ),
      ],
    );
  }

  static BoxDecoration pillDecoration({
    required bool isSelected,
    Color activeColor = BackpackColors.primaryPurple,
  }) {
    return BoxDecoration(
      color: isSelected ? activeColor : BackpackColors.cardWhite,
      borderRadius: BorderRadius.circular(25),
      border: Border.all(
        color: isSelected ? activeColor : BackpackColors.borderLight,
        width: 1.2,
      ),
      boxShadow: [
        BoxShadow(
          color: isSelected
              ? activeColor.withValues(alpha: 0.25)
              : Colors.black.withValues(alpha: 0.03),
          blurRadius: 6,
          offset: const Offset(0, 2),
        ),
      ],
    );
  }
}
