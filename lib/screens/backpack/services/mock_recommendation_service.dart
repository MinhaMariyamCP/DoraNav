import '../models/backpack_context.dart';
import '../models/suggestion_item.dart';
import 'recommendation_service.dart';

/// Pre-configured test scenarios for developer & tester evaluation.
enum BackpackScenario {
  riverCrossing(
    title: 'River Crossing',
    description: 'Dora is going to cross a river to reach the King’s Castle.',
    situation: 'River Ahead • Long Path • Swiper Spotted',
  ),
  nightCave(
    title: 'Dark Crystal Cave',
    description: 'Exploring the deep Dragon Mountain Cave at nightfall.',
    situation: 'Pitch Dark • Steep Rocks • Mysterious Sounds',
  ),
  snowyMountain(
    title: 'Snowy Mountain Climb',
    description: 'Heading up to the North Pole and Tallest Mountain.',
    situation: 'Freezing Blizzard • Slippery Ice • High Altitude',
  ),
  longJourney(
    title: 'Lost City Trek',
    description: '15km trek across the Sandy Dunes and Ancient Temple.',
    situation: 'Long Distance (15km) • Extreme Heat • Distant Landmarks',
  ),
  swiperSpotted(
    title: 'Swiper on the Prowl',
    description: 'Watch out! Swiper is hiding near Castle Bridge.',
    situation: 'High Swiper Hazard • Map at Risk • Traps Ahead',
  );

  final String title;
  final String description;
  final String situation;

  const BackpackScenario({
    required this.title,
    required this.description,
    required this.situation,
  });
}

/// Production-ready mock implementation implementing the recommendation rule engine.
class MockRecommendationService implements RecommendationService {
  // Always-present essentials
  static const SuggestionItem _mapItem = SuggestionItem(
    id: 'map_01',
    name: 'Map',
    category: ItemCategory.travel,
    iconKey: 'map',
    shortDescription: 'Shows the route and landmarks',
    reason: 'Always useful to navigate through Dora World',
    priority: 100,
    essential: true,
    bestFor: 'Never getting lost',
    usedIn: 'All Paths, Mountains & Forests',
  );

  static const SuggestionItem _bootsItem = SuggestionItem(
    id: 'boots_01',
    name: 'Boots',
    category: ItemCategory.travel,
    iconKey: 'boots',
    shortDescription: 'Your cheerful monkey best friend!',
    reason: 'Good for rough terrain and friendly advice',
    priority: 95,
    essential: true,
    bestFor: 'Companionship & High Jumps',
    usedIn: 'Every Dora Adventure',
  );

  // Master repository of available adventure items
  static const Map<String, SuggestionItem> _catalog = {
    'raft': SuggestionItem(
      id: 'raft_01',
      name: 'Inflatable Raft',
      category: ItemCategory.special,
      iconKey: 'raft',
      shortDescription: 'Helps us float and cross the river safely.',
      reason: "There's a river ahead! Helps cross water without getting wet.",
      priority: 90,
      bestFor: 'River Crossing',
      usedIn: 'Giant River, Sparkling Lake, Mermaid Kingdom',
    ),
    'life_jacket': SuggestionItem(
      id: 'life_jacket_01',
      name: 'Life Jacket',
      category: ItemCategory.safety,
      iconKey: 'life_jacket',
      shortDescription: 'Keeps us safe if the water is deep.',
      reason: 'Safety first! Ensures everyone stays buoyant in currents.',
      priority: 88,
      bestFor: 'Water Safety',
      usedIn: 'Rivers, Waterfalls, Seashell Cove',
    ),
    'rope': SuggestionItem(
      id: 'rope_01',
      name: 'Sturdy Rope',
      category: ItemCategory.tools,
      iconKey: 'rope',
      shortDescription: 'Useful if the current is strong or for climbing.',
      reason: 'Ties the raft securely and helps scale rocky cliffs.',
      priority: 82,
      bestFor: 'Climbing & Securing',
      usedIn: 'Mountain Paths, River Crossings',
    ),
    'water_bottle': SuggestionItem(
      id: 'water_01',
      name: 'Water Bottle',
      category: ItemCategory.food,
      iconKey: 'water_bottle',
      shortDescription: 'Stay hydrated during the journey.',
      reason: 'Walking in the sun makes us thirsty! Essential hydration.',
      priority: 85,
      bestFor: 'Thirst Quenching',
      usedIn: 'Desert Dunes, Jungle Trails',
    ),
    'flashlight': SuggestionItem(
      id: 'flashlight_01',
      name: 'Bright Flashlight',
      category: ItemCategory.tools,
      iconKey: 'flashlight',
      shortDescription: 'Cuts through pitch dark caves and shadows.',
      reason: 'It is dark inside the cave! Lights up glowing gems.',
      priority: 92,
      bestFor: 'Dark Caverns',
      usedIn: 'Crystal Cave, Hidden Tunnel, Night Travel',
    ),
    'lantern': SuggestionItem(
      id: 'lantern_01',
      name: 'Adventure Lantern',
      category: ItemCategory.tools,
      iconKey: 'lantern',
      shortDescription: 'Steady warm glow for group exploration.',
      reason: 'Keeps everyone together when walking in twilight.',
      priority: 80,
      bestFor: 'Camp Lighting',
      usedIn: 'Jungle Camp, Mountain Junction',
    ),
    'glow_stick': SuggestionItem(
      id: 'glow_01',
      name: 'Star Glow Sticks',
      category: ItemCategory.special,
      iconKey: 'glow_stick',
      shortDescription: 'Fun neon glow that never runs out of battery.',
      reason: 'Marks trails in dark tunnels so we can find our way back.',
      priority: 75,
      bestFor: 'Trail Marking',
      usedIn: 'Cave Labyrinths, Night Walks',
    ),
    'warm_clothes': SuggestionItem(
      id: 'clothes_01',
      name: 'Warm Parka Jacket',
      category: ItemCategory.safety,
      iconKey: 'warm_clothes',
      shortDescription: 'Thick cozy jacket to shield from blizzard winds.',
      reason: 'Freezing temperatures on Snowy Mountain! Stay warm.',
      priority: 95,
      bestFor: 'Sub-Zero Cold',
      usedIn: 'Snowy Mountain, North Pole, Tallest Mountain',
    ),
    'gloves': SuggestionItem(
      id: 'gloves_01',
      name: 'Thermal Mittens',
      category: ItemCategory.safety,
      iconKey: 'gloves',
      shortDescription: 'Soft wool mittens to protect little hands.',
      reason: 'Keeps hands warm while holding walking sticks and map.',
      priority: 85,
      bestFor: 'Snowball Play & Grip',
      usedIn: 'Polar Camp, Snowy Peaks',
    ),
    'blanket': SuggestionItem(
      id: 'blanket_01',
      name: 'Cozy Fleece Blanket',
      category: ItemCategory.special,
      iconKey: 'blanket',
      shortDescription: 'Extra warm blanket for rest stops.',
      reason: 'Resting on frozen ground is cold — wraps up tight and cozy.',
      priority: 78,
      bestFor: 'Rest Breaks',
      usedIn: 'High Altitudes, Mountain Junction',
    ),
    'snacks': SuggestionItem(
      id: 'snacks_01',
      name: 'Super Snack Pack',
      category: ItemCategory.food,
      iconKey: 'snacks',
      shortDescription: 'Delicious fruits, trail mix, and juice boxes.',
      reason: 'Long journeys burn lots of energy! Recharges stamina.',
      priority: 88,
      bestFor: 'Energy Boost',
      usedIn: 'Long Treks (>10km), All-day Hikes',
    ),
    'first_aid': SuggestionItem(
      id: 'first_aid_01',
      name: 'Star First Aid Kit',
      category: ItemCategory.safety,
      iconKey: 'first_aid',
      shortDescription: 'Colorful bandages and soothing ointment.',
      reason: 'Just in case of scrapes or tired toes along the rocky path.',
      priority: 86,
      bestFor: 'Cuts & Bumps',
      usedIn: 'Wilderness, Rocky Trails',
    ),
    'swiper_bell': SuggestionItem(
      id: 'swiper_01',
      name: 'Swiper Alert Bell',
      category: ItemCategory.safety,
      iconKey: 'swiper_bell',
      shortDescription: 'Rings loudly whenever Swiper the Fox sneaks near!',
      reason: 'Swiper detected ahead! Say "Swiper no swiping!" 3 times!',
      priority: 98,
      bestFor: 'Fox Deterrence',
      usedIn: 'Castle Bridge, Hidden Bushes',
    ),
    'magnifying_glass': SuggestionItem(
      id: 'glass_01',
      name: 'Magnifying Glass',
      category: ItemCategory.tools,
      iconKey: 'magnifying_glass',
      shortDescription: 'Examines animal tracks and mysterious clues.',
      reason: 'Helps spot hidden footsteps and puzzle markings.',
      priority: 70,
      bestFor: 'Detective Work',
      usedIn: 'Forest Garden, Ancient Temple',
    ),
    'umbrella': SuggestionItem(
      id: 'umbrella_01',
      name: 'Rainbow Umbrella',
      category: ItemCategory.tools,
      iconKey: 'umbrella',
      shortDescription: 'Bright colorful umbrella for surprise rain showers.',
      reason: 'Rain clouds roll in quickly over Rainbow Bridge.',
      priority: 72,
      bestFor: 'Rain Showers',
      usedIn: 'Flower Field, Jungle Camp',
    ),
  };

  @override
  Future<BackpackResponse> getRecommendations(BackpackContext context) async {
    // Simulate brief thinking delay for realistic UX transitions
    await Future.delayed(const Duration(milliseconds: 350));

    final items = <SuggestionItem>[];

    // Essentials always included
    items.add(_mapItem);
    items.add(_bootsItem);

    // Rule 1: Water crossing / River
    final isWater = context.routeFeatures.contains('water_crossing') ||
        context.destination.toLowerCase().contains('river') ||
        context.destination.toLowerCase().contains('beach') ||
        context.destination.toLowerCase().contains('lake');

    if (isWater) {
      items.add(_catalog['raft']!);
      items.add(_catalog['life_jacket']!);
      items.add(_catalog['rope']!);
      items.add(_catalog['water_bottle']!);
    }

    // Rule 2: Night or Cave
    final isDark = context.timeOfDay == 'night' ||
        context.routeFeatures.contains('cave') ||
        context.destination.toLowerCase().contains('cave');

    if (isDark) {
      items.add(_catalog['flashlight']!);
      items.add(_catalog['lantern']!);
      items.add(_catalog['glow_stick']!);
      if (!items.any((i) => i.id == 'rope_01')) {
        items.add(_catalog['rope']!);
      }
    }

    // Rule 3: Cold / Snow
    final isCold = context.weather == 'snow' ||
        context.weather == 'cold' ||
        context.destination.toLowerCase().contains('mountain') ||
        context.destination.toLowerCase().contains('pole');

    if (isCold) {
      items.add(_catalog['warm_clothes']!);
      items.add(_catalog['gloves']!);
      items.add(_catalog['blanket']!);
    }

    // Rule 4: Long journey / traversal
    final isLong = context.distanceKm > 5 ||
        context.routeFeatures.contains('long_traversal') ||
        context.destination.toLowerCase().contains('lost city');

    if (isLong) {
      items.add(_catalog['snacks']!);
      if (!items.any((i) => i.id == 'water_01')) {
        items.add(_catalog['water_bottle']!);
      }
      items.add(_catalog['first_aid']!);
    }

    // Rule 5: Swiper Alert
    if (context.swiperDetected) {
      items.add(_catalog['swiper_bell']!);
    }

    // Default general items if list is still small
    if (items.length <= 4) {
      items.add(_catalog['magnifying_glass']!);
      items.add(_catalog['umbrella']!);
    }

    // De-duplicate by id & sort by priority descending
    final uniqueItems = <String, SuggestionItem>{};
    for (final item in items) {
      uniqueItems[item.id] = item;
    }

    final sortedList = uniqueItems.values.toList()
      ..sort((a, b) => b.priority.compareTo(a.priority));

    String title = 'Here are some things that can help!';
    String subtitle = 'Pick the ones you want to pack for ${context.destination}.';

    if (isWater) {
      title = "There's a river ahead!";
      subtitle = 'These items will help us cross safely and have fun!';
    } else if (isDark) {
      title = "It's getting dark in the cave!";
      subtitle = 'Let us bring bright lights so we can see the path!';
    } else if (isCold) {
      title = 'Brrr! It is icy cold!';
      subtitle = 'Warm up with snuggly clothes and gear for the snowy peak!';
    } else if (context.swiperDetected) {
      title = 'Watch out for Swiper!';
      subtitle = 'Keep our Map safe and ring the bell if you spot a fox tail!';
    }

    return BackpackResponse(
      context: context,
      suggestions: sortedList,
      alwaysAvailable: ['map_01', 'boots_01'],
      situationTitle: title,
      situationSubtitle: subtitle,
    );
  }

  @override
  Future<BackpackResponse> searchItems(String query, BackpackContext context) async {
    await Future.delayed(const Duration(milliseconds: 250));

    final cleanQuery = query.toLowerCase().trim();
    if (cleanQuery.isEmpty) {
      return getRecommendations(context);
    }

    final matched = <SuggestionItem>[_mapItem, _bootsItem];

    for (final item in _catalog.values) {
      final matchName = item.name.toLowerCase().contains(cleanQuery);
      final matchDesc = item.shortDescription.toLowerCase().contains(cleanQuery);
      final matchCategory = item.category.label.toLowerCase().contains(cleanQuery);
      final matchReason = item.reason.toLowerCase().contains(cleanQuery);

      if (matchName || matchDesc || matchCategory || matchReason) {
        if (!matched.any((m) => m.id == item.id)) {
          matched.add(item);
        }
      }
    }

    return BackpackResponse(
      context: context,
      suggestions: matched,
      alwaysAvailable: ['map_01', 'boots_01'],
      situationTitle: 'Results for "$query"',
      situationSubtitle: 'Found ${matched.length} helpful adventure items!',
    );
  }

  /// Helper factory to generate standard test contexts
  static BackpackContext getScenarioContext(BackpackScenario scenario) {
    switch (scenario) {
      case BackpackScenario.riverCrossing:
        return const BackpackContext(
          destination: 'King’s Castle',
          routeFeatures: ['water_crossing', 'forest_path'],
          timeOfDay: 'afternoon',
          weather: 'sunny',
          swiperDetected: true,
          distanceKm: 2.8,
          currentObstacle: 'Wide river with gentle rapids',
        );
      case BackpackScenario.nightCave:
        return const BackpackContext(
          destination: 'Crystal Cave',
          routeFeatures: ['cave', 'rocky_path'],
          timeOfDay: 'night',
          weather: 'clear',
          swiperDetected: false,
          distanceKm: 3.4,
          currentObstacle: 'Pitch dark tunnel with stalagmites',
        );
      case BackpackScenario.snowyMountain:
        return const BackpackContext(
          destination: 'Snowy Mountain',
          routeFeatures: ['mountain_climb', 'steep_rocks'],
          timeOfDay: 'morning',
          weather: 'snow',
          swiperDetected: false,
          distanceKm: 6.2,
          currentObstacle: 'Slippery snowy cliff and high wind',
        );
      case BackpackScenario.longJourney:
        return const BackpackContext(
          destination: 'Lost City',
          routeFeatures: ['long_traversal', 'desert_dunes'],
          timeOfDay: 'afternoon',
          weather: 'sunny',
          swiperDetected: false,
          distanceKm: 14.5,
          currentObstacle: 'Hot sandy dunes with no natural water',
        );
      case BackpackScenario.swiperSpotted:
        return const BackpackContext(
          destination: 'Castle Bridge',
          routeFeatures: ['bridge', 'bushes'],
          timeOfDay: 'afternoon',
          weather: 'sunny',
          swiperDetected: true,
          distanceKm: 1.2,
          currentObstacle: 'Swiper is hiding behind the trees!',
        );
    }
  }
}
