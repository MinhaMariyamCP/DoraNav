import 'package:flutter/material.dart';

/// Dora's current mood selection
enum DoraMood {
  happy('Happy', '😄', 'Feeling cheerful and energetic!'),
  curious('Curious', '🧐', 'Ready to discover hidden wonders!'),
  brave('Brave', '💪', 'Fearless and ready for big adventures!'),
  tired('Tired', '😴', 'Looking for an easy, gentle walk.'),
  worried('Worried', '😟', 'Prefers safe paths away from tricky spots.');

  final String label;
  final String emoji;
  final String description;

  const DoraMood(this.label, this.emoji, this.description);
}

/// Adventure level intensity
enum AdventureLevel {
  calm('Calm', '🍃', 'Smooth, peaceful walking paths with no steep climbs.'),
  normal('Normal', '🏞️', 'Balanced trail with standard sights and turns.'),
  adventurous('Adventurous', '⛰️', 'Exciting scenic route with bridges and climbs!'),
  extreme('Extreme', '🌋', 'Wild trails with river crossings, peaks and surprises!');

  final String label;
  final String emoji;
  final String description;

  const AdventureLevel(this.label, this.emoji, this.description);
}

/// Type of route option
enum RouteOptionType {
  normal('Normal Route', 'Fastest & most balanced route to destination.'),
  swiperSafe('Swiper-Safe Route', 'Avoids Swiper and tricky ambush places.'),
  bootsRoute('Boots Route', 'A fun route with discovery stops that Boots loves!'),
  mostAdventurous('Most Adventurous Route', 'The most exciting path with hidden surprises!');

  final String title;
  final String subtitle;

  const RouteOptionType(this.title, this.subtitle);
}

/// Dynamic calculated route option tailored to mood and adventure level
class RouteOption {
  final RouteOptionType type;
  final String title;
  final String subtitle;
  final double distanceKm;
  final int etaMinutes;
  final String swiperRisk; // 'None', 'Low', 'Medium', 'High'
  final Color riskColor;
  final String adventureBadge; // 'Calm', 'Normal', 'Adventurous', 'Extreme'
  final String whyThisRoute;
  final bool isRecommended;
  final IconData iconData;
  final Color iconColor;
  final Set<String> blockedNodes; // For A* routing

  const RouteOption({
    required this.type,
    required this.title,
    required this.subtitle,
    required this.distanceKm,
    required this.etaMinutes,
    required this.swiperRisk,
    required this.riskColor,
    required this.adventureBadge,
    required this.whyThisRoute,
    this.isRecommended = false,
    required this.iconData,
    required this.iconColor,
    this.blockedNodes = const {},
  });

  RouteOption copyWith({
    bool? isRecommended,
  }) {
    return RouteOption(
      type: type,
      title: title,
      subtitle: subtitle,
      distanceKm: distanceKm,
      etaMinutes: etaMinutes,
      swiperRisk: swiperRisk,
      riskColor: riskColor,
      adventureBadge: adventureBadge,
      whyThisRoute: whyThisRoute,
      isRecommended: isRecommended ?? this.isRecommended,
      iconData: iconData,
      iconColor: iconColor,
      blockedNodes: blockedNodes,
    );
  }
}
