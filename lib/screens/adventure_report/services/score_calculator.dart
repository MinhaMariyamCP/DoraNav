import 'dart:math' as math;
import '../models/score_weights.dart';
import '../models/trip_data.dart';

/// Result container for computed score, detailed point breakdown, and friendly summary
class ScoreResult {
  final int finalScore; // Clamped 0 - 100
  final Map<String, double> breakdown;
  final String verbalSummary;
  final String motivationalPraise;

  const ScoreResult({
    required this.finalScore,
    required this.breakdown,
    required this.verbalSummary,
    required this.motivationalPraise,
  });
}

/// Pure calculation service converting raw TripData into kid-friendly Adventure Scores
class ScoreCalculator {
  final ScoreWeights weights;

  const ScoreCalculator({this.weights = ScoreWeights.standard});

  /// Computes Adventure Score dynamically based on trip telemetry
  ScoreResult calculate(TripData trip) {
    // 1. Base completion
    final double base = trip.completedSuccessfully ? weights.baseCompletion : 0.0;

    // 2. Distance contribution: min(maxDistance, distanceKm * 2)
    final double distancePoints =
        math.min(weights.maxDistancePoints, trip.distanceKm * weights.distanceMultiplier);

    // 3. Exploration contribution: min(maxExploration, explorationPoints * 2)
    final double explorationPoints = math.min(
        weights.maxExplorationPoints, trip.explorationPoints * weights.explorationMultiplier);

    // 4. Discoveries contribution: min(maxDiscoveries, discoveriesFound * 3)
    final double discoveriesPoints = math.min(
        weights.maxDiscoveriesPoints, trip.discoveriesFound * weights.discoveriesMultiplier);

    // 5. Small bonuses (turns, bridges, backpack items) capped at 10
    final double rawBonuses = (trip.turnsTaken * weights.turnsMultiplier) +
        (trip.bridgesCrossed * weights.bridgesMultiplier) +
        (trip.backpackItemsUsed * weights.backpackMultiplier);
    final double smallBonuses = math.min(weights.maxSmallBonuses, rawBonuses);

    // 6. Route difficulty multiplier
    final double multiplier = weights.routeMultipliers[trip.routeType] ?? 1.0;

    // 7. Swiper penalty
    final double swiperPenalty = trip.swiperEncounters * weights.swiperPenaltyPerEncounter;

    // 8. Total raw score before clamp
    final double subtotal = base + distancePoints + explorationPoints + discoveriesPoints + smallBonuses;
    final double weightedSubtotal = subtotal * multiplier;
    final double scoreBeforeClamp = weightedSubtotal - swiperPenalty;

    final int finalScore = scoreBeforeClamp.round().clamp(0, 100);

    final breakdown = <String, double>{
      'Base Completion': base,
      'Distance Traveled': double.parse(distancePoints.toStringAsFixed(1)),
      'Exploration POIs': double.parse(explorationPoints.toStringAsFixed(1)),
      'Special Discoveries': double.parse(discoveriesPoints.toStringAsFixed(1)),
      'Turns & Bridges Bonus': double.parse(smallBonuses.toStringAsFixed(1)),
      'Route Multiplier': multiplier,
      'Swiper Penalty': -swiperPenalty,
    };

    final verbalSummary = _generateVerbalSummary(trip, discoveriesPoints.round(), finalScore);
    final motivationalPraise = _generatePraise(finalScore);

    return ScoreResult(
      finalScore: finalScore,
      breakdown: breakdown,
      verbalSummary: verbalSummary,
      motivationalPraise: motivationalPraise,
    );
  }

  String _generateVerbalSummary(TripData trip, int discPts, int score) {
    if (trip.swiperEncounters > 0) {
      return 'You braved ${trip.swiperEncounters} Swiper encounter${trip.swiperEncounters > 1 ? "s" : ""} and explored ${trip.distanceKm} km like a true champion!';
    } else if (trip.discoveriesFound > 0) {
      return 'Great exploring! You gained +$discPts points from discoveries and had a safe trip!';
    } else {
      return 'You explored ${trip.distanceKm} km across ${trip.destinationName} with flying colors!';
    }
  }

  String _generatePraise(int score) {
    if (score >= 90) {
      return '¡Increíble! You are a Legendary Explorer! Star Power 100%!';
    } else if (score >= 80) {
      return 'Fantastic explorer!\nYou made smart choices, stayed safe and had so much fun!';
    } else if (score >= 65) {
      return 'Awesome job! You navigated with courage and reached your goal!';
    } else {
      return 'Great effort! Every adventure makes you braver and wiser!';
    }
  }
}
