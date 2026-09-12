/// Configuration weights for dynamic Adventure Score calculation
class ScoreWeights {
  final double baseCompletion;
  final double distanceMultiplier;
  final double maxDistancePoints;
  final double explorationMultiplier;
  final double maxExplorationPoints;
  final double discoveriesMultiplier;
  final double maxDiscoveriesPoints;
  final double turnsMultiplier;
  final double bridgesMultiplier;
  final double backpackMultiplier;
  final double maxSmallBonuses;
  final double swiperPenaltyPerEncounter;
  final Map<String, double> routeMultipliers;

  const ScoreWeights({
    this.baseCompletion = 20.0,
    this.distanceMultiplier = 2.0,
    this.maxDistancePoints = 20.0,
    this.explorationMultiplier = 2.0,
    this.maxExplorationPoints = 20.0,
    this.discoveriesMultiplier = 3.0,
    this.maxDiscoveriesPoints = 15.0,
    this.turnsMultiplier = 0.5,
    this.bridgesMultiplier = 1.0,
    this.backpackMultiplier = 0.5,
    this.maxSmallBonuses = 10.0,
    this.swiperPenaltyPerEncounter = 3.0,
    this.routeMultipliers = const {
      'Normal': 1.0,
      'Swiper-Safe': 0.9,
      'Swiper-Safe Route': 0.9,
      'Boots': 1.1,
      'Most Adventurous': 1.25,
    },
  });

  /// Default configuration matching DoraNav guidelines
  static const ScoreWeights standard = ScoreWeights();
}
