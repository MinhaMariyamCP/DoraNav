/// Represents a special moment or achievement during an adventure
class TripHighlight {
  final String title;
  final String iconEmoji;
  final String? assetPath;

  const TripHighlight({
    required this.title,
    required this.iconEmoji,
    this.assetPath,
  });

  Map<String, dynamic> toJson() => {
        'title': title,
        'iconEmoji': iconEmoji,
        if (assetPath != null) 'assetPath': assetPath,
      };

  factory TripHighlight.fromJson(Map<String, dynamic> json) => TripHighlight(
        title: json['title'] as String,
        iconEmoji: json['iconEmoji'] as String? ?? '⭐',
        assetPath: json['assetPath'] as String?,
      );
}

/// Comprehensive model holding all trip and navigation telemetry for DoraNav
class TripData {
  final String destinationName;
  final String destinationDescription;
  final String? destinationImageUrl;
  final double distanceKm;
  final Duration tripDuration;
  final int turnsTaken;
  final int bridgesCrossed;
  final int animalsMet;
  final int swiperEncounters;
  final int backpackItemsUsed;
  final String routeType; // "Normal" | "Swiper-Safe" | "Boots" | "Most Adventurous"
  final String mood; // "Happy", "Excited", "Calm", "Curious"
  final String adventureLevel; // "Easy", "Medium", "Adventurous", "Epic"
  final int explorationPoints;
  final int discoveriesFound;
  final List<TripHighlight> highlights;
  final bool completedSuccessfully;
  final DateTime startTime;
  final DateTime endTime;
  final Map<String, dynamic> metadata;

  const TripData({
    required this.destinationName,
    this.destinationDescription = 'Great job, explorer! You did it! The destination is safe and the adventure was a big success!',
    this.destinationImageUrl,
    required this.distanceKm,
    required this.tripDuration,
    required this.turnsTaken,
    required this.bridgesCrossed,
    required this.animalsMet,
    required this.swiperEncounters,
    required this.backpackItemsUsed,
    this.routeType = 'Normal',
    this.mood = 'Happy',
    this.adventureLevel = 'Adventurous',
    this.explorationPoints = 0,
    this.discoveriesFound = 0,
    this.highlights = const [],
    this.completedSuccessfully = true,
    required this.startTime,
    required this.endTime,
    this.metadata = const {},
  });

  /// Human-readable duration string formatted as HH:MM:SS or MM:SS
  String get formattedDuration {
    final hours = tripDuration.inHours.toString().padLeft(2, '0');
    final minutes = (tripDuration.inMinutes % 60).toString().padLeft(2, '0');
    final seconds = (tripDuration.inSeconds % 60).toString().padLeft(2, '0');
    return '$hours:$minutes:$seconds';
  }

  Map<String, dynamic> toJson() => {
        'destinationName': destinationName,
        'destinationDescription': destinationDescription,
        'destinationImageUrl': destinationImageUrl,
        'distanceKm': distanceKm,
        'tripDurationSeconds': tripDuration.inSeconds,
        'turnsTaken': turnsTaken,
        'bridgesCrossed': bridgesCrossed,
        'animalsMet': animalsMet,
        'swiperEncounters': swiperEncounters,
        'backpackItemsUsed': backpackItemsUsed,
        'routeType': routeType,
        'mood': mood,
        'adventureLevel': adventureLevel,
        'explorationPoints': explorationPoints,
        'discoveriesFound': discoveriesFound,
        'highlights': highlights.map((h) => h.toJson()).toList(),
        'completedSuccessfully': completedSuccessfully,
        'startTime': startTime.toIso8601String(),
        'endTime': endTime.toIso8601String(),
        'metadata': metadata,
      };

  factory TripData.fromJson(Map<String, dynamic> json) => TripData(
        destinationName: json['destinationName'] as String,
        destinationDescription: json['destinationDescription'] as String? ?? '',
        destinationImageUrl: json['destinationImageUrl'] as String?,
        distanceKm: (json['distanceKm'] as num).toDouble(),
        tripDuration: Duration(seconds: json['tripDurationSeconds'] as int? ?? 0),
        turnsTaken: json['turnsTaken'] as int? ?? 0,
        bridgesCrossed: json['bridgesCrossed'] as int? ?? 0,
        animalsMet: json['animalsMet'] as int? ?? 0,
        swiperEncounters: json['swiperEncounters'] as int? ?? 0,
        backpackItemsUsed: json['backpackItemsUsed'] as int? ?? 0,
        routeType: json['routeType'] as String? ?? 'Normal',
        mood: json['mood'] as String? ?? 'Happy',
        adventureLevel: json['adventureLevel'] as String? ?? 'Adventurous',
        explorationPoints: json['explorationPoints'] as int? ?? 0,
        discoveriesFound: json['discoveriesFound'] as int? ?? 0,
        highlights: (json['highlights'] as List<dynamic>?)
                ?.map((e) => TripHighlight.fromJson(e as Map<String, dynamic>))
                .toList() ??
            [],
        completedSuccessfully: json['completedSuccessfully'] as bool? ?? true,
        startTime: DateTime.tryParse(json['startTime'] as String? ?? '') ?? DateTime.now(),
        endTime: DateTime.tryParse(json['endTime'] as String? ?? '') ?? DateTime.now(),
        metadata: json['metadata'] as Map<String, dynamic>? ?? {},
      );

  // --------------------------------------------------------------------------
  // Pre-configured Mock Datasets
  // --------------------------------------------------------------------------

  /// Sample 1: Witch's Castle (Matches reference mockup - target score ~87)
  static TripData get witchsCastleMock => TripData(
        destinationName: "Witch's Castle",
        destinationDescription:
            "Great job, explorer! You did it! The castle is safe and the adventure was a big success!",
        distanceKm: 2.4,
        tripDuration: const Duration(minutes: 28, seconds: 45),
        turnsTaken: 7,
        bridgesCrossed: 2,
        animalsMet: 3,
        swiperEncounters: 1,
        backpackItemsUsed: 5,
        routeType: "Swiper-Safe Route",
        mood: "Happy",
        adventureLevel: "Adventurous",
        explorationPoints: 8,
        discoveriesFound: 4,
        highlights: const [
          TripHighlight(title: "Crossed the Troll Bridge", iconEmoji: "🌉"),
          TripHighlight(title: "Met Boots' cousin Tico!", iconEmoji: "🐒"),
          TripHighlight(title: "Found a hidden treasure map!", iconEmoji: "🗺️"),
          TripHighlight(title: "Avoided Swiper and stayed safe!", iconEmoji: "🦊"),
        ],
        completedSuccessfully: true,
        startTime: DateTime.now().subtract(const Duration(minutes: 28, seconds: 45)),
        endTime: DateTime.now(),
      );

  /// Sample 2: Sunny Beach (Normal leisurely stroll)
  static TripData get sunnyBeachMock => TripData(
        destinationName: "Sunny Beach",
        destinationDescription:
            "Splash! You made it across the sunny sands without any trouble!",
        distanceKm: 1.1,
        tripDuration: const Duration(minutes: 12, seconds: 10),
        turnsTaken: 3,
        bridgesCrossed: 0,
        animalsMet: 1,
        swiperEncounters: 0,
        backpackItemsUsed: 1,
        routeType: "Normal",
        mood: "Calm",
        adventureLevel: "Easy",
        explorationPoints: 2,
        discoveriesFound: 1,
        highlights: const [
          TripHighlight(title: "Found a shiny seashell", iconEmoji: "🐚"),
          TripHighlight(title: "Watched dolphins jump", iconEmoji: "🐬"),
        ],
        completedSuccessfully: true,
        startTime: DateTime.now().subtract(const Duration(minutes: 12, seconds: 10)),
        endTime: DateTime.now(),
      );

  /// Sample 3: Swiper Trouble (High obstacle challenge)
  static TripData get swiperTroubleMock => TripData(
        destinationName: "Crystal Rainforest",
        destinationDescription:
            "Phew! Swiper tried to swipe our items multiple times, but your quick wits saved the day!",
        distanceKm: 3.7,
        tripDuration: const Duration(minutes: 41, seconds: 20),
        turnsTaken: 12,
        bridgesCrossed: 4,
        animalsMet: 6,
        swiperEncounters: 4,
        backpackItemsUsed: 7,
        routeType: "Swiper-Safe",
        mood: "Excited",
        adventureLevel: "Epic",
        explorationPoints: 12,
        discoveriesFound: 5,
        highlights: const [
          TripHighlight(title: "Rung the Swiper Bell in time!", iconEmoji: "🔔"),
          TripHighlight(title: "Discovered rare crystal cave", iconEmoji: "💎"),
          TripHighlight(title: "Swung over crocodile river", iconEmoji: "🐊"),
          TripHighlight(title: "Fed baby parrot sweet berries", iconEmoji: "🦜"),
        ],
        completedSuccessfully: true,
        startTime: DateTime.now().subtract(const Duration(minutes: 41, seconds: 20)),
        endTime: DateTime.now(),
      );
}
