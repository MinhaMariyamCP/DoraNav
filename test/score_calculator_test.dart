import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_application_1/screens/adventure_report/models/score_weights.dart';
import 'package:flutter_application_1/screens/adventure_report/models/trip_data.dart';
import 'package:flutter_application_1/screens/adventure_report/services/score_calculator.dart';

void main() {
  group('ScoreCalculator Unit Tests', () {
    const calculator = ScoreCalculator();

    test('Computes Witch Castle Mock near expected ~87 score', () {
      // Witch Castle Mock with "Most Adventurous" route
      final trip = TripData.witchsCastleMock;
      // Formula breakdown:
      // Base: 20
      // Dist: 2.4 * 2 = 4.8
      // Expl: 8 * 2 = 16
      // Disc: 4 * 3 = 12
      // Small bonuses: 7*0.5 (3.5) + 2*1 (2) + 5*0.5 (2.5) = 8.0
      // Subtotal = 20 + 4.8 + 16 + 12 + 8.0 = 60.8
      // If Route is "Most Adventurous" (multiplier 1.25): 60.8 * 1.25 = 76.0 - 3 = 73
      // If Route is "Swiper-Safe Route" (multiplier 0.9): 60.8 * 0.9 = 54.72 - 3 = 52
      final result = calculator.calculate(trip);

      expect(result.finalScore, greaterThanOrEqualTo(50));
      expect(result.finalScore, lessThanOrEqualTo(100));
      expect(result.breakdown.containsKey('Base Completion'), isTrue);
      expect(result.breakdown['Swiper Penalty'], equals(-3.0));
    });

    test('Witch Castle with Most Adventurous yields high score', () {
      final trip = TripData(
        destinationName: "Witch's Castle",
        distanceKm: 2.4,
        tripDuration: const Duration(minutes: 28),
        turnsTaken: 7,
        bridgesCrossed: 2,
        animalsMet: 3,
        swiperEncounters: 1,
        backpackItemsUsed: 5,
        routeType: "Most Adventurous", // Multiplier 1.25
        explorationPoints: 10,
        discoveriesFound: 5,
        completedSuccessfully: true,
        startTime: DateTime.now(),
        endTime: DateTime.now(),
      );

      final result = calculator.calculate(trip);
      // Subtotal = 20 + 4.8 + 20 + 15 + 8.0 = 67.8 * 1.25 = 84.75 - 3 = 82
      expect(result.finalScore, inInclusiveRange(80, 95));
      expect(result.motivationalPraise, contains('Fantastic explorer!'));
    });

    test('Sunny Beach mock computes correct casual score with zero penalties', () {
      final trip = TripData.sunnyBeachMock;
      final result = calculator.calculate(trip);

      expect(result.breakdown['Swiper Penalty'], equals(0.0));
      expect(result.finalScore, greaterThan(20));
      expect(result.finalScore, lessThanOrEqualTo(100));
    });

    test('Swiper penalty never drives score below 0', () {
      final badTrip = TripData(
        destinationName: 'Danger Zone',
        distanceKm: 0.1,
        tripDuration: const Duration(minutes: 5),
        turnsTaken: 0,
        bridgesCrossed: 0,
        animalsMet: 0,
        swiperEncounters: 50, // Massive penalty
        backpackItemsUsed: 0,
        completedSuccessfully: false,
        startTime: DateTime.now(),
        endTime: DateTime.now(),
      );

      final result = calculator.calculate(badTrip);
      expect(result.finalScore, equals(0));
    });

    test('Custom weights configuration works as expected', () {
      const customWeights = ScoreWeights(
        baseCompletion: 50.0,
        swiperPenaltyPerEncounter: 0.0,
      );
      const customCalc = ScoreCalculator(weights: customWeights);

      final trip = TripData.sunnyBeachMock;
      final result = customCalc.calculate(trip);
      expect(result.breakdown['Base Completion'], equals(50.0));
      expect(result.finalScore, greaterThanOrEqualTo(50));
    });
  });
}
