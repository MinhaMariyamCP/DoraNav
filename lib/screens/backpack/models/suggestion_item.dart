import 'backpack_context.dart';

/// Categories supported in the DoraNav Backpack.
enum ItemCategory {
  all('All'),
  tools('Tools'),
  travel('Travel'),
  food('Food'),
  safety('Safety'),
  special('Special');

  final String label;
  const ItemCategory(this.label);

  static ItemCategory fromString(String category) {
    return ItemCategory.values.firstWhere(
      (c) => c.label.toLowerCase() == category.toLowerCase(),
      orElse: () => ItemCategory.special,
    );
  }
}

/// An immutable item recommendation delivered by RecommendationService.
class SuggestionItem {
  final String id;
  final String name;
  final ItemCategory category;
  final String iconKey; // maps to vector painter or SVG
  final String shortDescription;
  final String reason;
  final int priority;
  final bool essential;
  final String bestFor;
  final String usedIn;
  final int quantity;
  final bool isAdded;

  const SuggestionItem({
    required this.id,
    required this.name,
    required this.category,
    required this.iconKey,
    required this.shortDescription,
    required this.reason,
    this.priority = 50,
    this.essential = false,
    this.bestFor = 'General Adventure',
    this.usedIn = 'Everywhere in Dora World',
    this.quantity = 1,
    this.isAdded = false,
  });

  SuggestionItem copyWith({
    String? id,
    String? name,
    ItemCategory? category,
    String? iconKey,
    String? shortDescription,
    String? reason,
    int? priority,
    bool? essential,
    String? bestFor,
    String? usedIn,
    int? quantity,
    bool? isAdded,
  }) {
    return SuggestionItem(
      id: id ?? this.id,
      name: name ?? this.name,
      category: category ?? this.category,
      iconKey: iconKey ?? this.iconKey,
      shortDescription: shortDescription ?? this.shortDescription,
      reason: reason ?? this.reason,
      priority: priority ?? this.priority,
      essential: essential ?? this.essential,
      bestFor: bestFor ?? this.bestFor,
      usedIn: usedIn ?? this.usedIn,
      quantity: quantity ?? this.quantity,
      isAdded: isAdded ?? this.isAdded,
    );
  }

  Map<String, dynamic> toJson() => {
        'id': id,
        'name': name,
        'category': category.label,
        'icon': '$iconKey.svg',
        'shortDescription': shortDescription,
        'reason': reason,
        'priority': priority,
        'essential': essential,
        'bestFor': bestFor,
        'usedIn': usedIn,
        'quantity': quantity,
        'isAdded': isAdded,
      };
}

/// Response payload from RecommendationService.
class BackpackResponse {
  final BackpackContext context;
  final List<SuggestionItem> suggestions;
  final List<String> alwaysAvailable; // ids of essentials: ['map_01', 'boots_01']
  final String situationTitle;
  final String situationSubtitle;

  const BackpackResponse({
    required this.context,
    required this.suggestions,
    required this.alwaysAvailable,
    this.situationTitle = 'Ready for Adventure!',
    this.situationSubtitle = 'Here are some helpful things for our journey.',
  });
}
