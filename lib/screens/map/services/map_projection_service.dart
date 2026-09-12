import 'dart:ui';
import '../models/map_models.dart';

/// Calibrated projection service aligning graph locations with the high-resolution
/// illustrated DoraNav World Map (1024 x 682 reference resolution).
class MapProjectionService {
  static const double refWidth = 1024.0;
  static const double refHeight = 682.0;

  /// Normalized coordinates (0.0 .. 1.0) on the reference artwork for all 70 locations.
  static const Map<String, Offset> _normalizedOffsets = {
    // 25 Main Destinations (01 to 25)
    'L001': Offset(88.0 / refWidth, 240.0 / refHeight),   // 01 Dora's House
    'L002': Offset(108.0 / refWidth, 290.0 / refHeight),  // 02 Benny's Barn
    'L003': Offset(475.0 / refWidth, 140.0 / refHeight),  // 03 Blueberry Hill
    'L004': Offset(548.0 / refWidth, 140.0 / refHeight),  // 04 Snowy Mountain
    'L005': Offset(215.0 / refWidth, 485.0 / refHeight),  // 05 Beach
    'L006': Offset(440.0 / refWidth, 255.0 / refHeight),  // 06 Chocolate Tree
    'L007': Offset(45.0 / refWidth, 335.0 / refHeight),   // 07 Big Yellow Station
    'L008': Offset(390.0 / refWidth, 395.0 / refHeight),  // 08 Flowery Garden
    'L009': Offset(120.0 / refWidth, 390.0 / refHeight),  // 09 Animal Rescue Center
    'L010': Offset(155.0 / refWidth, 330.0 / refHeight),  // 10 School
    'L011': Offset(715.0 / refWidth, 205.0 / refHeight),  // 11 Music Box
    'L012': Offset(810.0 / refWidth, 195.0 / refHeight),  // 12 King's Castle
    'L013': Offset(710.0 / refWidth, 145.0 / refHeight),  // 13 Wizard's Castle
    'L014': Offset(915.0 / refWidth, 345.0 / refHeight),  // 14 Dragon's Cave
    'L015': Offset(610.0 / refWidth, 280.0 / refHeight),  // 15 Volcano
    'L016': Offset(540.0 / refWidth, 535.0 / refHeight),  // 16 Treasure Island
    'L017': Offset(695.0 / refWidth, 520.0 / refHeight),  // 17 Mermaid Kingdom
    'L018': Offset(805.0 / refWidth, 65.0 / refHeight),   // 18 Cloud Castle
    'L019': Offset(45.0 / refWidth, 410.0 / refHeight),   // 19 Amusement Park
    'L020': Offset(645.0 / refWidth, 455.0 / refHeight),  // 20 Waterfall
    'L021': Offset(575.0 / refWidth, 75.0 / refHeight),   // 21 North Pole
    'L022': Offset(850.0 / refWidth, 310.0 / refHeight),  // 22 Crystal Kingdom
    'L023': Offset(420.0 / refWidth, 525.0 / refHeight),  // 23 Pirate Island
    'L024': Offset(915.0 / refWidth, 370.0 / refHeight),  // 24 Butterfly Festival
    'L025': Offset(745.0 / refWidth, 445.0 / refHeight),  // 25 Lost City

    // Intermediate & Trail Locations
    'L026': Offset(202.0 / refWidth, 228.0 / refHeight),  // Jungle Entrance
    'L027': Offset(172.0 / refWidth, 210.0 / refHeight),  // Jungle Camp
    'L028': Offset(195.0 / refWidth, 140.0 / refHeight),  // Flower Field
    'L029': Offset(85.0 / refWidth, 142.0 / refHeight),   // Nutty Forest
    'L030': Offset(385.0 / refWidth, 140.0 / refHeight),  // Big Hill
    'L031': Offset(218.0 / refWidth, 145.0 / refHeight),  // Adventure Forest
    'L032': Offset(555.0 / refWidth, 140.0 / refHeight),  // Big Mountain
    'L033': Offset(605.0 / refWidth, 185.0 / refHeight),  // Highest Hill
    'L034': Offset(575.0 / refWidth, 165.0 / refHeight),  // Tallest Mountain
    'L035': Offset(295.0 / refWidth, 255.0 / refHeight),  // Small Stream
    'L036': Offset(305.0 / refWidth, 330.0 / refHeight),  // Giant River
    'L037': Offset(425.0 / refWidth, 385.0 / refHeight),  // Rainbow Bridge
    'L038': Offset(415.0 / refWidth, 245.0 / refHeight),  // Desert Oasis
    'L039': Offset(370.0 / refWidth, 180.0 / refHeight),  // Big Tree
    'L040': Offset(135.0 / refWidth, 165.0 / refHeight),  // Forest Garden
    'L041': Offset(182.0 / refWidth, 122.0 / refHeight),  // Butterfly Garden
    'L042': Offset(232.0 / refWidth, 65.0 / refHeight),   // Treehouse
    'L043': Offset(690.0 / refWidth, 120.0 / refHeight),  // High Tower
    'L044': Offset(505.0 / refWidth, 385.0 / refHeight),  // Troll Bridge
    'L045': Offset(615.0 / refWidth, 380.0 / refHeight),  // Castle Bridge
    'L046': Offset(680.0 / refWidth, 175.0 / refHeight),  // Castle Gate
    'L047': Offset(475.0 / refWidth, 195.0 / refHeight),  // Moonbeam Mountain
    'L048': Offset(755.0 / refWidth, 145.0 / refHeight),  // Cloud Path
    'L049': Offset(935.0 / refWidth, 220.0 / refHeight),  // Dragon Mountain
    'L050': Offset(875.0 / refWidth, 165.0 / refHeight),  // Dragon's Forest
    'L051': Offset(452.0 / refWidth, 275.0 / refHeight),  // Cactus Valley
    'L052': Offset(585.0 / refWidth, 235.0 / refHeight),  // Volcano Path
    'L053': Offset(325.0 / refWidth, 515.0 / refHeight),  // Pirate Harbor
    'L054': Offset(305.0 / refWidth, 385.0 / refHeight),  // Sparkling Lake
    'L055': Offset(620.0 / refWidth, 420.0 / refHeight),  // Crystal Lake
    'L056': Offset(760.0 / refWidth, 290.0 / refHeight),  // Crystal Cave
    'L057': Offset(420.0 / refWidth, 315.0 / refHeight),  // Sandy Dunes
    'L058': Offset(805.0 / refWidth, 395.0 / refHeight),  // Ancient Temple
    'L059': Offset(860.0 / refWidth, 445.0 / refHeight),  // Hidden Tunnel
    'L060': Offset(255.0 / refWidth, 105.0 / refHeight),  // Boots' Tree
    'L061': Offset(145.0 / refWidth, 265.0 / refHeight),  // Picnic Place
    'L062': Offset(550.0 / refWidth, 245.0 / refHeight),  // Rock Path
    'L063': Offset(525.0 / refWidth, 205.0 / refHeight),  // Ice Cave
    'L064': Offset(640.0 / refWidth, 320.0 / refHeight),  // Magic Pond
    'L065': Offset(100.0 / refWidth, 360.0 / refHeight),  // Farm
    'L066': Offset(145.0 / refWidth, 365.0 / refHeight),  // Windmill
    'L067': Offset(360.0 / refWidth, 530.0 / refHeight),  // Pirate Ship
    'L068': Offset(475.0 / refWidth, 345.0 / refHeight),  // Golden Sands
    'L069': Offset(505.0 / refWidth, 330.0 / refHeight),  // Hidden Cave
    'L070': Offset(770.0 / refWidth, 260.0 / refHeight),  // Fairy Forest
  };

  /// Converts a [LocationNode] into screen canvas pixel coordinates.
  static Offset nodeToPixel(LocationNode node, double canvasWidth, double canvasHeight) {
    final norm = _normalizedOffsets[node.id];
    if (norm != null) {
      return Offset(norm.dx * canvasWidth, norm.dy * canvasHeight);
    }
    // Fallback using virtual coordinates (0..200)
    return Offset(
      (node.x / 200.0) * canvasWidth,
      ((200.0 - node.y) / 200.0) * canvasHeight,
    );
  }

  /// Converts an arbitrary virtual (x, y) into screen pixel coordinates.
  static Offset coordsToPixel(double x, double y, double canvasWidth, double canvasHeight) {
    return Offset(
      (x / 200.0) * canvasWidth,
      ((200.0 - y) / 200.0) * canvasHeight,
    );
  }

  /// Interpolates Dora's continuous screen position between [from] and [to] based on [progress] (0.0..1.0).
  static Offset interpolatePosition(
    LocationNode from,
    LocationNode to,
    double progress,
    double canvasWidth,
    double canvasHeight,
  ) {
    final fromPx = nodeToPixel(from, canvasWidth, canvasHeight);
    final toPx = nodeToPixel(to, canvasWidth, canvasHeight);
    return Offset(
      fromPx.dx + (toPx.dx - fromPx.dx) * progress.clamp(0.0, 1.0),
      fromPx.dy + (toPx.dy - fromPx.dy) * progress.clamp(0.0, 1.0),
    );
  }
}
