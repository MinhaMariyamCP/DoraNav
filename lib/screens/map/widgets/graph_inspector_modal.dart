import 'package:flutter/material.dart';
import '../models/map_models.dart';
import '../services/pathfinder_service.dart';

/// Interactive Graph Inspector Modal
/// Allows exploring the Dora World Graph (70 locations, 25 destinations),
/// inspecting A* calculations, viewing step-by-step waypoints, and testing roadblocks.
class GraphInspectorModal extends StatefulWidget {
  final PathfinderService pathfinder;

  const GraphInspectorModal({
    super.key,
    required this.pathfinder,
  });

  static Future<void> show(BuildContext context, PathfinderService pathfinder) {
    return showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) => GraphInspectorModal(pathfinder: pathfinder),
    );
  }

  @override
  State<GraphInspectorModal> createState() => _GraphInspectorModalState();
}

class _GraphInspectorModalState extends State<GraphInspectorModal>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;
  late LocationNode _selectedStart;
  late LocationNode _selectedGoal;
  NavigationRoute? _inspectedRoute;
  bool _simulateBlockMidpoint = false;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);

    final allLocs = widget.pathfinder.allLocations;
    final destinations = widget.pathfinder.selectableDestinations;

    _selectedStart = widget.pathfinder.startNode ?? allLocs.first;
    _selectedGoal = destinations.isNotEmpty ? destinations.first : allLocs.last;

    _recomputeRoute();
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  void _recomputeRoute() {
    Set<String> customBlocked = {};
    if (_simulateBlockMidpoint) {
      // Find a middle node to block
      final normal = widget.pathfinder.findRoute(
        startId: _selectedStart.id,
        goalId: _selectedGoal.id,
      );
      if (normal != null && normal.nodes.length > 2) {
        customBlocked.add(normal.nodes[normal.nodes.length ~/ 2].id);
      }
    }

    setState(() {
      _inspectedRoute = widget.pathfinder.findRoute(
        startId: _selectedStart.id,
        goalId: _selectedGoal.id,
        customBlockedNodes: customBlocked,
        isAlternative: _simulateBlockMidpoint,
      );
    });
  }

  @override
  Widget build(BuildContext context) {
    final allLocs = widget.pathfinder.allLocations;
    final destinations = widget.pathfinder.selectableDestinations;

    // Group locations by region
    final regionsMap = <String, List<LocationNode>>{};
    for (final loc in allLocs) {
      regionsMap.putIfAbsent(loc.region, () => []).add(loc);
    }

    return Container(
      height: MediaQuery.of(context).size.height * 0.85,
      decoration: const BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.vertical(top: Radius.circular(28)),
        boxShadow: [
          BoxShadow(
            color: Colors.black26,
            blurRadius: 16,
            offset: Offset(0, -4),
          ),
        ],
      ),
      child: Column(
        children: [
          // Drag handle
          Container(
            margin: const EdgeInsets.only(top: 12, bottom: 8),
            width: 44,
            height: 5,
            decoration: BoxDecoration(
              color: Colors.grey.shade300,
              borderRadius: BorderRadius.circular(3),
            ),
          ),

          // Header
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 6),
            child: Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: const Color(0xFFEDE7F6),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: const Icon(Icons.hub_rounded, color: Color(0xFF7E57C2), size: 24),
                ),
                const SizedBox(width: 12),
                const Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Dora World Graph Inspector',
                        style: TextStyle(fontSize: 17, fontWeight: FontWeight.w900, color: Color(0xFF311B92)),
                      ),
                      Text(
                        '70 Locations • 25 Destinations • A* Engine',
                        style: TextStyle(fontSize: 11, color: Color(0xFF7E57C2), fontWeight: FontWeight.w600),
                      ),
                    ],
                  ),
                ),
                IconButton(
                  icon: const Icon(Icons.close_rounded, color: Colors.grey),
                  onPressed: () => Navigator.of(context).pop(),
                ),
              ],
            ),
          ),

          // Tabs
          TabBar(
            controller: _tabController,
            labelColor: const Color(0xFF7E57C2),
            unselectedLabelColor: Colors.grey,
            indicatorColor: const Color(0xFF7E57C2),
            indicatorWeight: 3,
            tabs: const [
              Tab(icon: Icon(Icons.alt_route_rounded), text: 'Path Query'),
              Tab(icon: Icon(Icons.category_rounded), text: 'Biomes & Nodes (70)'),
            ],
          ),

          // Tab views
          Expanded(
            child: TabBarView(
              controller: _tabController,
              children: [
                // Tab 1: Path Query
                _buildPathQueryTab(allLocs, destinations),

                // Tab 2: Biomes & Nodes
                _buildBiomesTab(regionsMap),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildPathQueryTab(List<LocationNode> allLocs, List<LocationNode> destinations) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(18),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Select Start and Goal
          Row(
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text('Start Location (70)', style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: Colors.grey)),
                    const SizedBox(height: 4),
                    DropdownButtonFormField<LocationNode>(
                      isExpanded: true,
                      initialValue: _selectedStart,
                      decoration: InputDecoration(
                        contentPadding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
                        border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                      ),
                      items: allLocs.map((loc) {
                        return DropdownMenuItem(
                          value: loc,
                          child: Text(loc.name, overflow: TextOverflow.ellipsis, style: const TextStyle(fontSize: 12)),
                        );
                      }).toList(),
                      onChanged: (val) {
                        if (val != null) {
                          _selectedStart = val;
                          _recomputeRoute();
                        }
                      },
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text('Goal Destination (25)', style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: Colors.grey)),
                    const SizedBox(height: 4),
                    DropdownButtonFormField<LocationNode>(
                      isExpanded: true,
                      initialValue: _selectedGoal,
                      decoration: InputDecoration(
                        contentPadding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
                        border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                      ),
                      items: destinations.map((loc) {
                        return DropdownMenuItem(
                          value: loc,
                          child: Text(loc.name, overflow: TextOverflow.ellipsis, style: const TextStyle(fontSize: 12)),
                        );
                      }).toList(),
                      onChanged: (val) {
                        if (val != null) {
                          _selectedGoal = val;
                          _recomputeRoute();
                        }
                      },
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 14),

          // Obstacle Simulation Switch
          SwitchListTile(
            title: const Text('Simulate Road Block on Midpoint', style: TextStyle(fontSize: 13, fontWeight: FontWeight.w700)),
            subtitle: const Text('Forces A* Engine to calculate dynamic detour', style: TextStyle(fontSize: 11)),
            value: _simulateBlockMidpoint,
            activeThumbColor: const Color(0xFFFF8F00),
            contentPadding: EdgeInsets.zero,
            onChanged: (val) {
              _simulateBlockMidpoint = val;
              _recomputeRoute();
            },
          ),
          const SizedBox(height: 10),

          // Route Result Card
          if (_inspectedRoute != null) ...[
            Container(
              padding: const EdgeInsets.all(14),
              decoration: BoxDecoration(
                color: _simulateBlockMidpoint ? const Color(0xFFFFF3E0) : const Color(0xFFEDE7F6),
                borderRadius: BorderRadius.circular(18),
                border: Border.all(
                  color: _simulateBlockMidpoint ? const Color(0xFFFFB74D) : const Color(0xFFD1C4E9),
                  width: 1.5,
                ),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        _simulateBlockMidpoint ? '🚧 Detour Route Active' : '⭐ Optimal A* Route',
                        style: TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.w900,
                          color: _simulateBlockMidpoint ? const Color(0xFFE65100) : const Color(0xFF4A148C),
                        ),
                      ),
                      Text(
                        '${_inspectedRoute!.totalDistance} km • ${_inspectedRoute!.etaMinutes} min',
                        style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 13),
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'Waypoints (${_inspectedRoute!.nodes.length} stops):',
                    style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w800),
                  ),
                  const SizedBox(height: 6),
                  Wrap(
                    spacing: 6,
                    runSpacing: 6,
                    children: _inspectedRoute!.nodes.map((node) {
                      final isStart = node.id == _selectedStart.id;
                      final isGoal = node.id == _selectedGoal.id;
                      return Chip(
                        labelPadding: const EdgeInsets.symmetric(horizontal: 4),
                        materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
                        backgroundColor: isStart
                            ? const Color(0xFFC8E6C9)
                            : (isGoal ? const Color(0xFFFFE0B2) : Colors.white),
                        label: Text(
                          node.name,
                          style: TextStyle(
                            fontSize: 11,
                            fontWeight: FontWeight.w700,
                            color: isStart
                                ? const Color(0xFF2E7D32)
                                : (isGoal ? const Color(0xFFE65100) : Colors.black87),
                          ),
                        ),
                      );
                    }).toList(),
                  ),
                ],
              ),
            ),
          ] else ...[
            const Center(
              child: Padding(
                padding: EdgeInsets.all(24.0),
                child: Text('No path reachable between selected locations with active roadblocks.',
                    style: TextStyle(color: Colors.red, fontWeight: FontWeight.bold)),
              ),
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildBiomesTab(Map<String, List<LocationNode>> regionsMap) {
    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: regionsMap.keys.length,
      itemBuilder: (context, index) {
        final region = regionsMap.keys.elementAt(index);
        final locs = regionsMap[region]!;

        return Card(
          margin: const EdgeInsets.only(bottom: 12),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
          elevation: 1.5,
          child: ExpansionTile(
            leading: Text(_getRegionEmoji(region), style: const TextStyle(fontSize: 22)),
            title: Text(
              '$region Biome',
              style: const TextStyle(fontWeight: FontWeight.w800, fontSize: 14),
            ),
            subtitle: Text('${locs.length} Locations', style: const TextStyle(fontSize: 11, color: Colors.grey)),
            children: locs.map((loc) {
              return ListTile(
                dense: true,
                leading: Container(
                  width: 28,
                  height: 28,
                  alignment: Alignment.center,
                  decoration: BoxDecoration(
                    color: loc.selectable ? const Color(0xFFFF9100) : const Color(0xFF7E57C2),
                    shape: BoxShape.circle,
                  ),
                  child: Text(
                    loc.id.replaceAll('L0', '').replaceAll('L', ''),
                    style: const TextStyle(color: Colors.white, fontSize: 10, fontWeight: FontWeight.bold),
                  ),
                ),
                title: Text(loc.name, style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w700)),
                subtitle: Text('(${loc.x.toInt()}, ${loc.y.toInt()}) • ${loc.description}', style: const TextStyle(fontSize: 11)),
                trailing: loc.selectable
                    ? const Chip(
                        label: Text('Destination', style: TextStyle(fontSize: 9, color: Colors.white)),
                        backgroundColor: Color(0xFFFF9100),
                        padding: EdgeInsets.zero,
                        materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
                      )
                    : null,
              );
            }).toList(),
          ),
        );
      },
    );
  }

  String _getRegionEmoji(String region) {
    switch (region.toLowerCase()) {
      case 'jungle':
        return '🌴';
      case 'forest':
        return '🌲';
      case 'mountain':
        return '⛰️';
      case 'water':
      case 'river':
        return '🌊';
      case 'beach':
      case 'coast':
        return '🏖️';
      case 'desert':
        return '🏜️';
      case 'castle':
      case 'kingdom':
        return '🏰';
      case 'polar':
      case 'arctic':
        return '❄️';
      default:
        return '🗺️';
    }
  }
}
