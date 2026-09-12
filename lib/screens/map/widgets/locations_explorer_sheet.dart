import 'package:flutter/material.dart';
import '../../../themes/app_theme.dart';
import '../models/map_models.dart';
import 'destination_visual_modal.dart';

/// Bottom Drawer / Explorer Panel matching the reference layout:
/// - 20 Destinations Tab / List
/// - 50 Locations List
/// - Map Legend (Icons, Lines, Zones, Swiper, and Waving Dora avatar)
class LocationsExplorerSheet extends StatefulWidget {
  final List<LocationNode> destinations;
  final List<LocationNode> allLocations;
  final LocationNode? selectedLocation;
  final ValueChanged<LocationNode>? onSelectDestination;
  final ValueChanged<LocationNode>? onStartNavigation;

  const LocationsExplorerSheet({
    super.key,
    required this.destinations,
    required this.allLocations,
    this.selectedLocation,
    this.onSelectDestination,
    this.onStartNavigation,
  });

  @override
  State<LocationsExplorerSheet> createState() => _LocationsExplorerSheetState();
}

class _LocationsExplorerSheetState extends State<LocationsExplorerSheet>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 240,
      decoration: BoxDecoration(
        color: const Color(0xFFF3E5F5), // Light purple pastel background
        borderRadius: const BorderRadius.vertical(top: Radius.circular(20)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.15),
            blurRadius: 10,
            offset: const Offset(0, -3),
          ),
        ],
      ),
      child: Column(
        children: [
          // Drag Handle
          Container(
            width: 36,
            height: 4,
            margin: const EdgeInsets.only(top: 8, bottom: 4),
            decoration: BoxDecoration(
              color: Colors.grey.withValues(alpha: 0.5),
              borderRadius: BorderRadius.circular(2),
            ),
          ),

          // Selected Destination Action Bar
          if (widget.selectedLocation != null && widget.selectedLocation!.selectable)
            Container(
              margin: const EdgeInsets.symmetric(horizontal: 14, vertical: 2),
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: const Color(0xFF7E57C2), width: 1.2),
                boxShadow: [
                  BoxShadow(
                    color: const Color(0xFF7E57C2).withValues(alpha: 0.12),
                    blurRadius: 4,
                  ),
                ],
              ),
              child: Row(
                children: [
                  const Icon(Icons.stars_rounded, color: Color(0xFFFFCA28), size: 16),
                  const SizedBox(width: 6),
                  Expanded(
                    child: Text(
                      'Ready for ${widget.selectedLocation!.name}?',
                      style: const TextStyle(fontWeight: FontWeight.w900, fontSize: 11, color: Color(0xFF4A148C)),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                  InkWell(
                    onTap: () => widget.onStartNavigation?.call(widget.selectedLocation!),
                    borderRadius: BorderRadius.circular(10),
                    child: Container(
                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                      decoration: BoxDecoration(
                        color: const Color(0xFF7E57C2),
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: const Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Text('Choose Route', style: TextStyle(color: Colors.white, fontSize: 10, fontWeight: FontWeight.w900)),
                          SizedBox(width: 3),
                          Icon(Icons.arrow_forward_rounded, color: Colors.white, size: 12),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),

          // Tab Bar with 3 sections
          TabBar(
            controller: _tabController,
            labelColor: const Color(0xFF4A148C),
            unselectedLabelColor: const Color(0xFF757575),
            indicatorColor: const Color(0xFF7E57C2),
            indicatorWeight: 3,
            labelStyle: const TextStyle(fontWeight: FontWeight.w900, fontSize: 11),
            tabs: [
              Tab(
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const Icon(Icons.stars_rounded, size: 14, color: Color(0xFF7E57C2)),
                    const SizedBox(width: 4),
                    Text('${widget.destinations.length} DESTINATIONS'),
                  ],
                ),
              ),
              Tab(
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const Icon(Icons.place_rounded, size: 14, color: Color(0xFF5E35B1)),
                    const SizedBox(width: 4),
                    Text('${widget.allLocations.length} LOCATIONS'),
                  ],
                ),
              ),
              const Tab(
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(Icons.info_outline_rounded, size: 14, color: Color(0xFF5E35B1)),
                    SizedBox(width: 4),
                    Text('LEGEND'),
                  ],
                ),
              ),
            ],
          ),

          // Tab Content
          Expanded(
            child: TabBarView(
              controller: _tabController,
              children: [
                // 1. Destinations List
                _buildLocationsGrid(widget.destinations, isSelectableOnly: true),

                // 2. All Locations List
                _buildLocationsGrid(widget.allLocations, isSelectableOnly: false),

                // 3. Legend Panel
                _buildLegendView(),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildLocationsGrid(List<LocationNode> list, {required bool isSelectableOnly}) {
    return ListView.builder(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
      itemCount: (list.length / 2).ceil(),
      itemBuilder: (context, rowIndex) {
        final idx1 = rowIndex * 2;
        final idx2 = idx1 + 1;
        final loc1 = list[idx1];
        final loc2 = idx2 < list.length ? list[idx2] : null;

        return Padding(
          padding: const EdgeInsets.only(bottom: 6.0),
          child: Row(
            children: [
              Expanded(child: _buildLocationItem(loc1)),
              const SizedBox(width: 8),
              Expanded(
                child: loc2 != null ? _buildLocationItem(loc2) : const SizedBox(),
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildLocationItem(LocationNode loc) {
    final isSelected = widget.selectedLocation?.id == loc.id;
    final numString = loc.id.replaceAll('L0', '').replaceAll('L', '');

    return InkWell(
      onTap: () {
        widget.onSelectDestination?.call(loc);
        DestinationVisualModal.show(
          context,
          location: loc,
          onStartRoute: () => widget.onStartNavigation?.call(loc),
        );
      },
      borderRadius: BorderRadius.circular(10),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 6),
        decoration: BoxDecoration(
          color: isSelected ? const Color(0xFFD1C4E9) : Colors.white,
          borderRadius: BorderRadius.circular(10),
          border: Border.all(
            color: isSelected ? const Color(0xFF7E57C2) : Colors.black.withValues(alpha: 0.08),
            width: isSelected ? 1.5 : 1.0,
          ),
        ),
        child: Row(
          children: [
            Container(
              width: 20,
              height: 20,
              decoration: BoxDecoration(
                color: loc.start ? const Color(0xFF00C853) : const Color(0xFF7E57C2),
                shape: BoxShape.circle,
              ),
              child: Center(
                child: Text(
                  numString,
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 9,
                    fontWeight: FontWeight.w900,
                  ),
                ),
              ),
            ),
            const SizedBox(width: 6),
            Expanded(
              child: Text(
                loc.name,
                style: TextStyle(
                  fontSize: 11,
                  fontWeight: isSelected ? FontWeight.w900 : FontWeight.w700,
                  color: const Color(0xFF212121),
                ),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
            ),
            const Icon(Icons.remove_red_eye_outlined, size: 13, color: Color(0xFF7E57C2)),
          ],
        ),
      ),
    );
  }

  Widget _buildLegendView() {
    return SingleChildScrollView(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Left Legend Column
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _buildLegendRow(
                  icon: const Icon(Icons.home_rounded, color: Color(0xFF00C853), size: 16),
                  label: 'Current Location',
                ),
                _buildLegendRow(
                  icon: const Icon(Icons.circle, color: Color(0xFF7E57C2), size: 14),
                  label: 'Destination',
                ),
                _buildLegendRow(
                  icon: const Icon(Icons.radio_button_unchecked, color: Color(0xFF7E57C2), size: 14),
                  label: 'Other Location',
                ),
                _buildLegendRow(
                  icon: Container(width: 16, height: 4, color: const Color(0xFF7E57C2)),
                  label: 'Route',
                ),
              ],
            ),
          ),
          // Middle Legend Column
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _buildLegendRow(
                  icon: const Text('- - -', style: TextStyle(color: Color(0xFFBA68C8), fontWeight: FontWeight.bold)),
                  label: 'Alternative Route',
                ),
                _buildLegendRow(
                  icon: const Icon(Icons.pets_rounded, color: Colors.orange, size: 14),
                  label: 'Swiper',
                ),
                _buildLegendRow(
                  icon: const Icon(Icons.radar_rounded, color: Colors.redAccent, size: 14),
                  label: 'High Risk Zone',
                ),
                _buildLegendRow(
                  icon: const Icon(Icons.shield_rounded, color: Color(0xFF00C853), size: 14),
                  label: 'Low Risk Zone',
                ),
              ],
            ),
          ),
          // Right Dora Mascot
          Column(
            children: [
              Container(
                width: 50,
                height: 50,
                decoration: const BoxDecoration(shape: BoxShape.circle),
                clipBehavior: Clip.antiAlias,
                child: Image.asset(
                  'assets/images/dora_avatar.png',
                  fit: BoxFit.cover,
                  errorBuilder: (context, error, stackTrace) => const Icon(Icons.face_rounded, size: 36, color: AppColors.doraPink),
                ),
              ),
              const SizedBox(height: 2),
              const Text(
                'Explore More,\nWorry Less! ❤️',
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 8.5,
                  fontWeight: FontWeight.w800,
                  color: Color(0xFF7E57C2),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildLegendRow({required Widget icon, required String label}) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 6.0),
      child: Row(
        children: [
          SizedBox(width: 18, child: Center(child: icon)),
          const SizedBox(width: 6),
          Expanded(
            child: Text(
              label,
              style: const TextStyle(fontSize: 10, fontWeight: FontWeight.w700, color: Color(0xFF424242)),
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
          ),
        ],
      ),
    );
  }
}
