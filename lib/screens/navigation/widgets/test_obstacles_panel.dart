import 'package:flutter/material.dart';
import '../../map/models/map_models.dart';
import '../../map/services/dynamic_obstacle_manager.dart';

/// Developer floating panel for manual testing of runtime dynamic obstacles:
/// - Spawn Swiper
/// - Spawn Crocodile
/// - Spawn Fallen Tree
/// - Spawn Rockslide
/// - Clear Obstacles
/// - Force Reroute
/// - Toggle Deterministic Demo Schedule
class TestObstaclesPanel extends StatefulWidget {
  final DynamicObstacleManager obstacleManager;
  final VoidCallback onForceReroute;
  final List<LocationNode> availableNodes;
  final List<RoadEdge> availableRoads;
  final List<LocationNode> Function()? getActiveRouteNodes;
  final List<RoadEdge> Function()? getActiveRoads;

  const TestObstaclesPanel({
    super.key,
    required this.obstacleManager,
    required this.onForceReroute,
    this.availableNodes = const [],
    this.availableRoads = const [],
    this.getActiveRouteNodes,
    this.getActiveRoads,
  });

  @override
  State<TestObstaclesPanel> createState() => _TestObstaclesPanelState();
}

class _TestObstaclesPanelState extends State<TestObstaclesPanel> {
  bool _isExpanded = false;
  bool _isDemoRunning = false;

  @override
  Widget build(BuildContext context) {
    return Positioned(
      top: 90,
      right: 12,
      child: Material(
        color: Colors.transparent,
        child: Container(
          decoration: BoxDecoration(
            color: const Color(0xFF1E1B2E).withValues(alpha: 0.94),
            borderRadius: BorderRadius.circular(18),
            border: Border.all(color: const Color(0xFFFFD54F), width: 1.4),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: 0.4),
                blurRadius: 10,
                offset: const Offset(0, 4),
              ),
            ],
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              // Header Toggle
              InkWell(
                onTap: () => setState(() => _isExpanded = !_isExpanded),
                borderRadius: BorderRadius.circular(18),
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      const Text('🛠️', style: TextStyle(fontSize: 14)),
                      const SizedBox(width: 4),
                      const Text(
                        'TEST OBSTACLES',
                        style: TextStyle(
                          color: Color(0xFFFFD54F),
                          fontSize: 10.5,
                          fontWeight: FontWeight.w900,
                          letterSpacing: 0.5,
                        ),
                      ),
                      const SizedBox(width: 4),
                      Icon(
                        _isExpanded ? Icons.keyboard_arrow_up_rounded : Icons.keyboard_arrow_down_rounded,
                        color: const Color(0xFFFFD54F),
                        size: 16,
                      ),
                    ],
                  ),
                ),
              ),

              // Expanded Action Panel
              if (_isExpanded)
                Padding(
                  padding: const EdgeInsets.fromLTRB(10, 0, 10, 10),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      const Divider(color: Colors.white24, height: 8),

                      // 1. Swiper (Only obstacle)
                      _buildBtn(
                        label: '🦊 Spawn Swiper',
                        color: const Color(0xFFE53935),
                        onTap: () {
                          final remaining = widget.getActiveRouteNodes?.call() ?? [];
                          final targetNode = remaining.length > 2
                              ? remaining[1]
                              : (remaining.isNotEmpty ? remaining.first : (widget.availableNodes.length > 3 ? widget.availableNodes[2] : null));
                          widget.obstacleManager.spawnObstacle(
                            DynamicObstacleType.swiper,
                            id: 'swiper_${DateTime.now().millisecondsSinceEpoch}',
                            nodeId: targetNode?.id,
                            x: targetNode?.x ?? 85.0,
                            y: targetNode?.y ?? 155.0,
                          );
                        },
                      ),
                      const SizedBox(height: 6),

                      // 5. Deterministic Demo Schedule Toggle
                      _buildBtn(
                        label: _isDemoRunning ? '⏹️ Stop Demo Mode' : '⏱️ Run Demo Schedule',
                        color: _isDemoRunning ? const Color(0xFFC2185B) : const Color(0xFF00897B),
                        onTap: () {
                          setState(() => _isDemoRunning = !_isDemoRunning);
                          if (_isDemoRunning) {
                            widget.obstacleManager.startDemoMode(
                              availableNodes: widget.availableNodes,
                              availableRoads: widget.availableRoads,
                              getActiveRemainingNodes: widget.getActiveRouteNodes,
                              getActiveRoads: widget.getActiveRoads,
                            );
                          } else {
                            widget.obstacleManager.stopDemoMode();
                          }
                        },
                      ),
                      const SizedBox(height: 6),

                      // 6. Force Reroute & Clear
                      Row(
                        children: [
                          Expanded(
                            child: _buildBtn(
                              label: '🔄 Reroute',
                              color: const Color(0xFF7E57C2),
                              onTap: widget.onForceReroute,
                            ),
                          ),
                          const SizedBox(width: 4),
                          Expanded(
                            child: _buildBtn(
                              label: '🧹 Clear All',
                              color: const Color(0xFF424242),
                              onTap: () {
                                widget.obstacleManager.clearAll();
                                setState(() => _isDemoRunning = false);
                              },
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildBtn({
    required String label,
    required Color color,
    required VoidCallback onTap,
  }) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(8),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 5),
        decoration: BoxDecoration(
          color: color,
          borderRadius: BorderRadius.circular(8),
        ),
        child: Center(
          child: Text(
            label,
            style: const TextStyle(
              color: Colors.white,
              fontSize: 9.5,
              fontWeight: FontWeight.w800,
            ),
          ),
        ),
      ),
    );
  }
}
