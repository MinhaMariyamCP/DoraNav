import 'package:flutter/material.dart';
import '../../map/models/map_models.dart';
import '../../map/services/pathfinder_service.dart';
import '../models/route_selection_models.dart';

/// Dynamic route calculator service connecting mood, adventure level, and A* navigation routes.
class RouteRecommendationEngine {
  final PathfinderService pathfinder;

  RouteRecommendationEngine(this.pathfinder);

  List<RouteOption> generateOptions({
    required LocationNode start,
    required LocationNode destination,
    required DoraMood mood,
    required AdventureLevel adventureLevel,
  }) {
    // 1. Calculate the base normal route
    final normalRoute = pathfinder.findRoute(
      startId: start.id,
      goalId: destination.id,
    );

    final baseDist = normalRoute?.totalDistance ?? 2.4;
    final baseEta = normalRoute?.etaMinutes ?? 8;

    // 2. Determine which route type is recommended based on mood & adventure level
    final RouteOptionType recommendedType = _getRecommendedType(mood, adventureLevel);

    // 3. Construct all 4 routes with calculated metrics & tailored reasons
    final options = <RouteOption>[
      // 1. Normal Route
      RouteOption(
        type: RouteOptionType.normal,
        title: 'Normal Route',
        subtitle: 'The fastest and most balanced route to your destination.',
        distanceKm: double.parse(baseDist.toStringAsFixed(1)),
        etaMinutes: baseEta,
        swiperRisk: 'Low',
        riskColor: const Color(0xFF4CAF50),
        adventureBadge: 'Normal',
        whyThisRoute: 'Quick, safe and smooth — reach your destination in no time!',
        isRecommended: recommendedType == RouteOptionType.normal,
        iconData: Icons.map_rounded,
        iconColor: const Color(0xFF4CAF50),
      ),

      // 2. Swiper-Safe Route (diverts around potential ambush spots)
      RouteOption(
        type: RouteOptionType.swiperSafe,
        title: 'Swiper-Safe Route',
        subtitle: 'The safest path that avoids Swiper and tricky places.',
        distanceKm: double.parse((baseDist * 1.25).toStringAsFixed(1)),
        etaMinutes: (baseEta * 1.3).round(),
        swiperRisk: 'None',
        riskColor: const Color(0xFF2E7D32),
        adventureBadge: 'Calm',
        whyThisRoute: 'We avoid Swiper and risky spots so you can travel worry-free!',
        isRecommended: recommendedType == RouteOptionType.swiperSafe,
        iconData: Icons.shield_rounded,
        iconColor: const Color(0xFFE53935),
        blockedNodes: {'L044', 'L045'}, // avoids Castle Bridge / Troll Bridge
      ),

      // 3. Boots Route (playful discovery stops)
      RouteOption(
        type: RouteOptionType.bootsRoute,
        title: 'Boots Route',
        subtitle: 'A fun and easy route that Boots thinks you\'ll love!',
        distanceKm: double.parse((baseDist * 1.15).toStringAsFixed(1)),
        etaMinutes: (baseEta * 1.15).round(),
        swiperRisk: 'Low',
        riskColor: const Color(0xFF4CAF50),
        adventureBadge: 'Normal',
        whyThisRoute: 'Great for adventures with lots of fun stops and friendly places!',
        isRecommended: recommendedType == RouteOptionType.bootsRoute,
        iconData: Icons.pets_rounded,
        iconColor: const Color(0xFF1E88E5),
      ),

      // 4. Most Adventurous Route (scenic peaks, bridges & surprises)
      RouteOption(
        type: RouteOptionType.mostAdventurous,
        title: 'Most Adventurous Route',
        subtitle: 'The most exciting path with lots of surprises along the way!',
        distanceKm: double.parse((baseDist * 1.6).toStringAsFixed(1)),
        etaMinutes: (baseEta * 1.8).round(),
        swiperRisk: 'Medium',
        riskColor: const Color(0xFFFF9800),
        adventureBadge: 'Extreme',
        whyThisRoute: 'Explore hidden places, cross magical bridges and discover amazing surprises!',
        isRecommended: recommendedType == RouteOptionType.mostAdventurous,
        iconData: Icons.star_rounded,
        iconColor: const Color(0xFFFFB300),
      ),
    ];

    // Reorder so recommended card appears at the very top!
    options.sort((a, b) {
      if (a.isRecommended) return -1;
      if (b.isRecommended) return 1;
      return 0;
    });

    return options;
  }

  RouteOptionType _getRecommendedType(DoraMood mood, AdventureLevel level) {
    // 1. Worried mood ALWAYS prioritizes safety and avoiding Swiper
    if (mood == DoraMood.worried) {
      return RouteOptionType.swiperSafe;
    }

    // 2. Tired mood always prefers the quickest, gentlest normal route
    if (mood == DoraMood.tired) {
      return RouteOptionType.normal;
    }

    // 3. Brave mood always seeks the most adventurous thrills
    if (mood == DoraMood.brave) {
      return RouteOptionType.mostAdventurous;
    }

    // 4. Curious mood loves discovery with Boots
    if (mood == DoraMood.curious) {
      if (level == AdventureLevel.extreme) {
        return RouteOptionType.mostAdventurous;
      }
      return RouteOptionType.bootsRoute;
    }

    // 5. Happy mood dynamically matches the selected adventure level
    if (mood == DoraMood.happy) {
      switch (level) {
        case AdventureLevel.calm:
          return RouteOptionType.normal;
        case AdventureLevel.normal:
          return RouteOptionType.bootsRoute;
        case AdventureLevel.adventurous:
        case AdventureLevel.extreme:
          return RouteOptionType.mostAdventurous;
      }
    }

    // Fallback based on adventure level
    if (level == AdventureLevel.extreme || level == AdventureLevel.adventurous) {
      return RouteOptionType.mostAdventurous;
    } else if (level == AdventureLevel.calm) {
      return RouteOptionType.normal;
    }

    return RouteOptionType.bootsRoute;
  }
}
