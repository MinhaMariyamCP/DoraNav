/// Context supplied by navigation engine to drive recommendation logic.
class BackpackContext {
  final String destination;
  final List<String> routeFeatures;
  final String timeOfDay; // 'morning', 'afternoon', 'night'
  final String weather; // 'sunny', 'rainy', 'snow', 'cold'
  final bool swiperDetected;
  final double distanceKm;
  final String currentObstacle;

  const BackpackContext({
    required this.destination,
    this.routeFeatures = const [],
    this.timeOfDay = 'afternoon',
    this.weather = 'sunny',
    this.swiperDetected = false,
    this.distanceKm = 2.5,
    this.currentObstacle = '',
  });

  Map<String, dynamic> toJson() => {
        'destination': destination,
        'routeFeatures': routeFeatures,
        'timeOfDay': timeOfDay,
        'weather': weather,
        'swiperDetected': swiperDetected,
        'distanceKm': distanceKm,
        'currentObstacle': currentObstacle,
      };

  BackpackContext copyWith({
    String? destination,
    List<String>? routeFeatures,
    String? timeOfDay,
    String? weather,
    bool? swiperDetected,
    double? distanceKm,
    String? currentObstacle,
  }) {
    return BackpackContext(
      destination: destination ?? this.destination,
      routeFeatures: routeFeatures ?? this.routeFeatures,
      timeOfDay: timeOfDay ?? this.timeOfDay,
      weather: weather ?? this.weather,
      swiperDetected: swiperDetected ?? this.swiperDetected,
      distanceKm: distanceKm ?? this.distanceKm,
      currentObstacle: currentObstacle ?? this.currentObstacle,
    );
  }
}
