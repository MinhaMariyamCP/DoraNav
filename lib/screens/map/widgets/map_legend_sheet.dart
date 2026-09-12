import 'package:flutter/material.dart';
import '../models/map_models.dart';
import 'destination_visual_modal.dart';

/// Modal bottom sheet presenting the DoraNav World Map Legend and 25 Main Destinations directory.
class MapLegendSheet extends StatelessWidget {
  final List<LocationNode> locations;
  final ValueChanged<LocationNode>? onDestinationSelected;

  const MapLegendSheet({
    super.key,
    required this.locations,
    this.onDestinationSelected,
  });

  static void show(BuildContext context, {
    required List<LocationNode> locations,
    ValueChanged<LocationNode>? onDestinationSelected,
  }) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (ctx) => MapLegendSheet(
        locations: locations,
        onDestinationSelected: (loc) {
          Navigator.of(ctx).pop();
          onDestinationSelected?.call(loc);
        },
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    // Extract main 25 destinations
    final mainDestinations = locations.where((l) {
      final numId = int.tryParse(l.id.replaceAll(RegExp(r'[^0-9]'), ''));
      return numId != null && numId >= 1 && numId <= 25;
    }).toList()
      ..sort((a, b) {
        final na = int.tryParse(a.id.replaceAll(RegExp(r'[^0-9]'), '')) ?? 999;
        final nb = int.tryParse(b.id.replaceAll(RegExp(r'[^0-9]'), '')) ?? 999;
        return na.compareTo(nb);
      });

    return Container(
      constraints: BoxConstraints(
        maxHeight: MediaQuery.of(context).size.height * 0.85,
      ),
      decoration: const BoxDecoration(
        color: Color(0xFFFAF3E0), // Warm parchment
        borderRadius: BorderRadius.vertical(top: Radius.circular(28)),
        boxShadow: [
          BoxShadow(
            color: Colors.black45,
            blurRadius: 18,
            offset: Offset(0, -4),
          ),
        ],
      ),
      child: Column(
        children: [
          // Drag handle
          Container(
            margin: const EdgeInsets.only(top: 10, bottom: 6),
            width: 44,
            height: 4.5,
            decoration: BoxDecoration(
              color: const Color(0xFF8D6E63),
              borderRadius: BorderRadius.circular(3),
            ),
          ),

          // Header
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 8),
            child: Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: const Color(0xFF5D4037),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: const Text('🧭', style: TextStyle(fontSize: 20)),
                ),
                const SizedBox(width: 12),
                const Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'DoraNav World Map Legend',
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.w900,
                          color: Color(0xFF3E2723),
                        ),
                      ),
                      Text(
                        '70 Locations • 25 Adventures • Infinite Fun!',
                        style: TextStyle(
                          fontSize: 11,
                          fontWeight: FontWeight.w700,
                          color: Color(0xFF8D6E63),
                        ),
                      ),
                    ],
                  ),
                ),
                IconButton(
                  icon: const Icon(Icons.close_rounded, color: Color(0xFF5D4037)),
                  onPressed: () => Navigator.of(context).pop(),
                ),
              ],
            ),
          ),
          const Divider(color: Color(0xFFD7CCC8), height: 1),

          // Scrollable Content
          Expanded(
            child: ListView(
              padding: const EdgeInsets.all(18),
              children: [
                // 1. Biome Regions & Route Colors
                _buildCardSection(
                  title: 'BIOMES & ROUTE STYLES',
                  child: Column(
                    children: [
                      _buildRegionRow(
                        color: const Color(0xFF4CAF50),
                        region: 'Forest / Jungle',
                        routeStyle: 'Emerald Trail',
                        description: 'Dora’s House, Rainforest canopy & treehouses',
                      ),
                      _buildRegionRow(
                        color: const Color(0xFF3F51B5),
                        region: 'Hills / Mountains',
                        routeStyle: 'Alpine Pass',
                        description: 'Blueberry Hill, Snowy peaks & mountain passes',
                      ),
                      _buildRegionRow(
                        color: const Color(0xFF00BCD4),
                        region: 'Water Areas',
                        routeStyle: 'Azure River',
                        description: 'Giant River, Rainbow Bridge & Sparkling Lake',
                      ),
                      _buildRegionRow(
                        color: const Color(0xFFFF9800),
                        region: 'Desert / Volcano',
                        routeStyle: 'Canyon Path',
                        description: 'Cactus Valley, Sandy Dunes & Lava Tunnel',
                      ),
                      _buildRegionRow(
                        color: const Color(0xFF9C27B0),
                        region: 'Fantasy / Castle',
                        routeStyle: 'Royal Trail',
                        description: 'King’s Castle, Cloud Castle & Dragon’s Cave',
                      ),
                      _buildRegionRow(
                        color: const Color(0xFFFFC107),
                        region: 'Town / Buildings',
                        routeStyle: 'Village Road',
                        description: 'Benny’s Barn, Station & School',
                      ),
                      _buildRegionRow(
                        color: const Color(0xFF009688),
                        region: 'Ocean / Islands',
                        routeStyle: 'Island Seaway',
                        description: 'Treasure Island, Mermaid Kingdom & Harbor',
                      ),
                      _buildRegionRow(
                        color: const Color(0xFFE91E63),
                        region: 'Special Locations',
                        routeStyle: 'Secret Path',
                        description: 'Lost City, Ancient Temple & Hidden Caves',
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 16),

                // 2. Map Symbols
                _buildCardSection(
                  title: 'MAP SYMBOLS',
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceAround,
                    children: [
                      _buildSymbolItem(
                        badge: '01',
                        label: 'Destination',
                        badgeColor: const Color(0xFFB71C1C),
                      ),
                      _buildSymbolItem(
                        badge: '•',
                        label: 'Waypoint',
                        badgeColor: const Color(0xFF0288D1),
                      ),
                      _buildSymbolItem(
                        badge: '══',
                        label: 'Active Route',
                        badgeColor: const Color(0xFF00E5FF),
                      ),
                      _buildSymbolItem(
                        badge: '🚧',
                        label: 'Blocked',
                        badgeColor: const Color(0xFFFF8F00),
                      ),
                      _buildSymbolItem(
                        badge: '👧',
                        label: 'Dora',
                        badgeColor: const Color(0xFFFF4081),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 16),

                // 3. 25 Main Destinations Directory
                _buildCardSection(
                  title: '25 MAIN DESTINATIONS (TAP TO VISIT)',
                  child: Wrap(
                    spacing: 8,
                    runSpacing: 8,
                    children: mainDestinations.map((dest) {
                      final numStr = dest.id.replaceAll(RegExp(r'[^0-9]'), '');
                      return InkWell(
                        onTap: () {
                          onDestinationSelected?.call(dest);
                          DestinationVisualModal.show(
                            context,
                            location: dest,
                          );
                        },
                        borderRadius: BorderRadius.circular(12),
                        child: Container(
                          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                          decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(12),
                            border: Border.all(color: const Color(0xFFD7CCC8)),
                            boxShadow: [
                              BoxShadow(
                                color: Colors.black.withValues(alpha: 0.04),
                                blurRadius: 4,
                                offset: const Offset(0, 2),
                              ),
                            ],
                          ),
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Container(
                                width: 22,
                                height: 22,
                                decoration: const BoxDecoration(
                                  color: Color(0xFF880E4F),
                                  shape: BoxShape.circle,
                                ),
                                child: Center(
                                  child: Text(
                                    numStr.padLeft(2, '0'),
                                    style: const TextStyle(
                                      color: Colors.white,
                                      fontSize: 10,
                                      fontWeight: FontWeight.w900,
                                    ),
                                  ),
                                ),
                              ),
                              const SizedBox(width: 8),
                              Text(
                                dest.name,
                                style: const TextStyle(
                                  fontSize: 12,
                                  fontWeight: FontWeight.w800,
                                  color: Color(0xFF3E2723),
                                ),
                              ),
                              const SizedBox(width: 4),
                              const Icon(Icons.photo_camera_rounded, size: 12, color: Color(0xFF8D6E63)),
                            ],
                          ),
                        ),
                      );
                    }).toList(),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCardSection({required String title, required Widget child}) {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: const Color(0xFFFFFDF9),
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: const Color(0xFFEFEBE9), width: 1.5),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.03),
            blurRadius: 6,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: const TextStyle(
              fontSize: 11,
              fontWeight: FontWeight.w900,
              letterSpacing: 0.8,
              color: Color(0xFF6D4C41),
            ),
          ),
          const SizedBox(height: 10),
          child,
        ],
      ),
    );
  }

  Widget _buildRegionRow({
    required Color color,
    required String region,
    required String routeStyle,
    required String description,
  }) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        children: [
          Container(
            width: 14,
            height: 14,
            decoration: BoxDecoration(
              color: color,
              shape: BoxShape.circle,
              boxShadow: [
                BoxShadow(
                  color: color.withValues(alpha: 0.4),
                  blurRadius: 4,
                  spreadRadius: 1,
                ),
              ],
            ),
          ),
          const SizedBox(width: 10),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Text(
                      region,
                      style: const TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.w800,
                        color: Color(0xFF2E1B10),
                      ),
                    ),
                    const SizedBox(width: 6),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 5, vertical: 1.5),
                      decoration: BoxDecoration(
                        color: color.withValues(alpha: 0.15),
                        borderRadius: BorderRadius.circular(6),
                      ),
                      child: Text(
                        routeStyle,
                        style: TextStyle(
                          fontSize: 9.5,
                          fontWeight: FontWeight.w700,
                          color: color,
                        ),
                      ),
                    ),
                  ],
                ),
                Text(
                  description,
                  style: const TextStyle(
                    fontSize: 10,
                    color: Color(0xFF8D6E63),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSymbolItem({
    required String badge,
    required String label,
    required Color badgeColor,
  }) {
    return Column(
      children: [
        Container(
          width: 32,
          height: 32,
          decoration: BoxDecoration(
            color: badgeColor,
            shape: BoxShape.circle,
            boxShadow: [
              BoxShadow(
                color: badgeColor.withValues(alpha: 0.35),
                blurRadius: 4,
                offset: const Offset(0, 2),
              ),
            ],
          ),
          child: Center(
            child: Text(
              badge,
              style: const TextStyle(
                color: Colors.white,
                fontSize: 12,
                fontWeight: FontWeight.w900,
              ),
            ),
          ),
        ),
        const SizedBox(height: 4),
        Text(
          label,
          style: const TextStyle(
            fontSize: 10,
            fontWeight: FontWeight.w700,
            color: Color(0xFF4E342E),
          ),
        ),
      ],
    );
  }
}
