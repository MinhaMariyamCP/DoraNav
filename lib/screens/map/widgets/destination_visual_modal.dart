import 'package:flutter/material.dart';
import '../models/map_models.dart';

/// Ultra-High Definition Visual Card/Modal shown when opening or inspecting any of
/// the 25 primary destinations and 70 locations on phone.
class DestinationVisualModal extends StatelessWidget {
  final LocationNode location;
  final VoidCallback? onStartRoute;

  const DestinationVisualModal({
    super.key,
    required this.location,
    this.onStartRoute,
  });

  static void show(
    BuildContext context, {
    required LocationNode location,
    VoidCallback? onStartRoute,
  }) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (ctx) => DestinationVisualModal(
        location: location,
        onStartRoute: () {
          Navigator.of(ctx).pop();
          onStartRoute?.call();
        },
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final numStr = location.id.replaceAll(RegExp(r'[^0-9]'), '');
    final numInt = int.tryParse(numStr);
    final isMain = numInt != null && numInt >= 1 && numInt <= 25;
    final biome = _getBiomeDetails(location.region);

    return Container(
      margin: const EdgeInsets.all(12),
      constraints: BoxConstraints(
        maxHeight: MediaQuery.of(context).size.height * 0.78,
      ),
      decoration: BoxDecoration(
        color: const Color(0xFFFAF3E0), // Warm storybook parchment
        borderRadius: BorderRadius.circular(28),
        border: Border.all(color: const Color(0xFFFFD54F), width: 2.0),
        boxShadow: const [
          BoxShadow(
            color: Colors.black54,
            blurRadius: 24,
            offset: Offset(0, 8),
          ),
        ],
      ),
      clipBehavior: Clip.antiAlias,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          // 1. Ultra-High Resolution Visual Hero Header with Dynamic Biome Art
          Stack(
            children: [
              Container(
                height: 180,
                width: double.infinity,
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                    colors: biome.gradientColors,
                  ),
                ),
                child: Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Container(
                        width: 72,
                        height: 72,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          color: Colors.white.withValues(alpha: 0.2),
                          border: Border.all(color: Colors.white, width: 2.5),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black.withValues(alpha: 0.2),
                              blurRadius: 12,
                            ),
                          ],
                        ),
                        child: Center(
                          child: Text(
                            biome.emoji,
                            style: const TextStyle(fontSize: 38),
                          ),
                        ),
                      ),
                      const SizedBox(height: 8),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 3),
                        decoration: BoxDecoration(
                          color: Colors.black.withValues(alpha: 0.35),
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(color: Colors.white38),
                        ),
                        child: Text(
                          '${biome.name.toUpperCase()} BIOME',
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 10,
                            fontWeight: FontWeight.w900,
                            letterSpacing: 1.0,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),

              // Close button
              Positioned(
                top: 12,
                right: 12,
                child: GestureDetector(
                  onTap: () => Navigator.of(context).pop(),
                  child: Container(
                    padding: const EdgeInsets.all(6),
                    decoration: const BoxDecoration(
                      color: Colors.black45,
                      shape: BoxShape.circle,
                    ),
                    child: const Icon(Icons.close_rounded, color: Colors.white, size: 20),
                  ),
                ),
              ),

              // Number Badge (if main destination 01-25)
              if (isMain)
                Positioned(
                  top: 12,
                  left: 12,
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                    decoration: BoxDecoration(
                      color: const Color(0xFFB71C1C),
                      borderRadius: BorderRadius.circular(14),
                      border: Border.all(color: const Color(0xFFFFD54F), width: 1.5),
                      boxShadow: const [
                        BoxShadow(color: Colors.black38, blurRadius: 6),
                      ],
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        const Icon(Icons.star_rounded, color: Color(0xFFFFD54F), size: 14),
                        const SizedBox(width: 4),
                        Text(
                          '#${numStr.padLeft(2, '0')}',
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 12,
                            fontWeight: FontWeight.w900,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
            ],
          ),

          // 2. Destination Details & Quest Trivia Body
          Padding(
            padding: const EdgeInsets.all(18),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Expanded(
                      child: Text(
                        location.name,
                        style: const TextStyle(
                          fontSize: 22,
                          fontWeight: FontWeight.w900,
                          color: Color(0xFF3E2723),
                        ),
                      ),
                    ),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                      decoration: BoxDecoration(
                        color: const Color(0xFFEDE7F6),
                        borderRadius: BorderRadius.circular(8),
                        border: Border.all(color: const Color(0xFF7E57C2)),
                      ),
                      child: Text(
                        'Node ${location.id}',
                        style: const TextStyle(
                          fontSize: 10,
                          fontWeight: FontWeight.w800,
                          color: Color(0xFF5E35B1),
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 8),

                // Description
                Text(
                  location.description.isNotEmpty
                      ? location.description
                      : "A wonder of Dora's World waiting to be discovered!",
                  style: const TextStyle(
                    fontSize: 13.5,
                    color: Color(0xFF5D4037),
                    height: 1.4,
                  ),
                ),
                const SizedBox(height: 14),

                // Specs / Attributes row
                Row(
                  children: [
                    _buildAttrChip('📍 Map Coords', '(${location.x.toInt()}, ${location.y.toInt()})'),
                    const SizedBox(width: 8),
                    _buildAttrChip('🗺️ Explorer Status', location.start ? 'Starting Home' : 'Adventure Spot'),
                  ],
                ),
                const SizedBox(height: 18),

                // Action buttons: Navigate & Back
                Row(
                  children: [
                    Expanded(
                      child: ElevatedButton.icon(
                        onPressed: onStartRoute,
                        icon: const Icon(Icons.navigation_rounded, color: Colors.white),
                        label: const Text(
                          'EXPLORE & NAVIGATE',
                          style: TextStyle(
                            fontSize: 13,
                            fontWeight: FontWeight.w900,
                            letterSpacing: 0.5,
                            color: Colors.white,
                          ),
                        ),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: const Color(0xFF7E57C2),
                          elevation: 3,
                          padding: const EdgeInsets.symmetric(vertical: 12),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(16),
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildAttrChip(String label, String value) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 7),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: const Color(0xFFD7CCC8)),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              label,
              style: const TextStyle(fontSize: 9.5, color: Color(0xFF8D6E63), fontWeight: FontWeight.w700),
            ),
            const SizedBox(height: 2),
            Text(
              value,
              style: const TextStyle(fontSize: 11.5, color: Color(0xFF3E2723), fontWeight: FontWeight.w900),
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
          ],
        ),
      ),
    );
  }

  static _BiomeMeta _getBiomeDetails(String region) {
    final r = region.toLowerCase();
    if (r.contains('mountain')) {
      return _BiomeMeta(
        name: 'Alpine Mountain',
        emoji: '🏔️',
        gradientColors: const [Color(0xFF1A237E), Color(0xFF3949AB), Color(0xFF00BCD4)],
      );
    } else if (r.contains('coast') || r.contains('water')) {
      return _BiomeMeta(
        name: 'Coastal Water',
        emoji: '🌊',
        gradientColors: const [Color(0xFF006064), Color(0xFF0097A7), Color(0xFF4DD0E1)],
      );
    } else if (r.contains('desert')) {
      return _BiomeMeta(
        name: 'Golden Desert',
        emoji: '🏜️',
        gradientColors: const [Color(0xFFBF360C), Color(0xFFE64A19), Color(0xFFFFB74D)],
      );
    } else if (r.contains('valley') || r.contains('castle')) {
      return _BiomeMeta(
        name: 'Royal Kingdom',
        emoji: '🏰',
        gradientColors: const [Color(0xFF4A148C), Color(0xFF7B1FA2), Color(0xFFBA68C8)],
      );
    } else {
      return _BiomeMeta(
        name: 'Rainforest Jungle',
        emoji: '🌴',
        gradientColors: const [Color(0xFF1B5E20), Color(0xFF2E7D32), Color(0xFF66BB6A)],
      );
    }
  }
}

class _BiomeMeta {
  final String name;
  final String emoji;
  final List<Color> gradientColors;

  _BiomeMeta({
    required this.name,
    required this.emoji,
    required this.gradientColors,
  });
}
