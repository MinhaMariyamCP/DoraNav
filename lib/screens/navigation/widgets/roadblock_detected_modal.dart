import 'package:flutter/material.dart';

/// Interactive Kid-Friendly "Road Block Detected!" Modal Dialog Widget
///
/// Features:
/// - Amber / Orange construction warning header (#FF8F00 / #FF6F00) with 🚧 icon
/// - Dynamic obstacle description (Rockslide, Broken Bridge, Fallen Tree)
/// - Animated A* recalculation status indicator
/// - Mini map preview diagram illustrating blocked segment vs A* detour
/// - Primary "Take Safe Detour" (#7B61FF) and Secondary "Use Backpack Tool" (#FF9100) actions
class RoadBlockDetectedModal extends StatefulWidget {
  final String obstacleTitle;
  final String obstacleDescription;
  final String distanceText;
  final String detourRouteName;
  final VoidCallback? onTakeDetour;
  final VoidCallback? onUseBackpackTool;
  final VoidCallback? onClose;

  const RoadBlockDetectedModal({
    super.key,
    this.obstacleTitle = 'Rockslide Ahead!',
    this.obstacleDescription = 'A pile of boulders is blocking the path!',
    this.distanceText = '150m',
    this.detourRouteName = 'Scenic Forest Bypass',
    this.onTakeDetour,
    this.onUseBackpackTool,
    this.onClose,
  });

  /// Static helper to display modal dialog easily
  static Future<T?> show<T>({
    required BuildContext context,
    String obstacleTitle = 'Rockslide Ahead!',
    String obstacleDescription = 'A pile of boulders is blocking the path!',
    String distanceText = '150m',
    String detourRouteName = 'Scenic Forest Bypass',
    VoidCallback? onTakeDetour,
    VoidCallback? onUseBackpackTool,
  }) {
    return showDialog<T>(
      context: context,
      barrierDismissible: true,
      barrierColor: Colors.black.withValues(alpha: 0.45),
      builder: (ctx) => RoadBlockDetectedModal(
        obstacleTitle: obstacleTitle,
        obstacleDescription: obstacleDescription,
        distanceText: distanceText,
        detourRouteName: detourRouteName,
        onTakeDetour: () {
          Navigator.of(ctx).pop();
          onTakeDetour?.call();
        },
        onUseBackpackTool: () {
          Navigator.of(ctx).pop();
          onUseBackpackTool?.call();
        },
        onClose: () => Navigator.of(ctx).pop(),
      ),
    );
  }

  @override
  State<RoadBlockDetectedModal> createState() => _RoadBlockDetectedModalState();
}

class _RoadBlockDetectedModalState extends State<RoadBlockDetectedModal>
    with SingleTickerProviderStateMixin {
  late AnimationController _pulseController;

  @override
  void initState() {
    super.initState();
    _pulseController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1000),
    )..repeat(reverse: true);
  }

  @override
  void dispose() {
    _pulseController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Dialog(
      backgroundColor: Colors.transparent,
      insetPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 24),
      child: Container(
        constraints: const BoxConstraints(maxWidth: 380),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(24),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.18),
              blurRadius: 20,
              offset: const Offset(0, 10),
            ),
          ],
        ),
        clipBehavior: Clip.antiAlias,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // 1. Amber Warning Header
            _buildHeader(context),

            // 2. Obstacle Alert Banner & Avatar
            Padding(
              padding: const EdgeInsets.fromLTRB(20, 16, 20, 12),
              child: Column(
                children: [
                  _buildObstacleAvatar(),
                  const SizedBox(height: 12),
                  Text(
                    widget.obstacleTitle,
                    textAlign: TextAlign.center,
                    style: const TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.w900,
                      color: Color(0xFF263238),
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    '${widget.obstacleDescription} (${widget.distanceText} ahead)',
                    textAlign: TextAlign.center,
                    style: const TextStyle(
                      fontSize: 13,
                      fontWeight: FontWeight.w500,
                      color: Color(0xFF546E7A),
                    ),
                  ),
                  const SizedBox(height: 12),

                  // 3. A* Dynamic Recalculation Notice
                  _buildRecalculatingNotice(),
                  const SizedBox(height: 14),

                  // 4. Mini Map Preview
                  _buildMiniMapPreview(),
                  const SizedBox(height: 16),

                  // 5. Actions: Safe Detour & Backpack Tool
                  _buildActionButtons(),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildHeader(BuildContext context) {
    return Container(
      color: const Color(0xFFFF8F00),
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(6),
            decoration: BoxDecoration(
              color: Colors.white.withValues(alpha: 0.25),
              shape: BoxShape.circle,
            ),
            child: const Icon(
              Icons.warning_amber_rounded,
              color: Colors.white,
              size: 20,
            ),
          ),
          const SizedBox(width: 10),
          const Expanded(
            child: Text(
              'Road Block Ahead! 🚧',
              style: TextStyle(
                color: Colors.white,
                fontSize: 16,
                fontWeight: FontWeight.w900,
                letterSpacing: 0.3,
              ),
            ),
          ),
          InkWell(
            onTap: widget.onClose ?? () => Navigator.of(context).pop(),
            borderRadius: BorderRadius.circular(16),
            child: Container(
              padding: const EdgeInsets.all(4),
              decoration: BoxDecoration(
                color: Colors.white.withValues(alpha: 0.25),
                shape: BoxShape.circle,
              ),
              child: const Icon(Icons.close_rounded, color: Colors.white, size: 18),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildObstacleAvatar() {
    return AnimatedBuilder(
      animation: _pulseController,
      builder: (context, child) {
        final scale = 1.0 + (_pulseController.value * 0.06);
        return Transform.scale(
          scale: scale,
          child: Container(
            width: 72,
            height: 72,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: const Color(0xFFFFF3E0),
              border: Border.all(color: const Color(0xFFFFB74D), width: 3),
              boxShadow: [
                BoxShadow(
                  color: const Color(0xFFFF9800).withValues(alpha: 0.3),
                  blurRadius: 12,
                  spreadRadius: 2,
                ),
              ],
            ),
            child: const Center(
              child: Text('🚧', style: TextStyle(fontSize: 36)),
            ),
          ),
        );
      },
    );
  }

  Widget _buildRecalculatingNotice() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      decoration: BoxDecoration(
        color: const Color(0xFFEDE7F6),
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: const Color(0xFFD1C4E9)),
      ),
      child: Row(
        children: [
          const Icon(Icons.alt_route_rounded, color: Color(0xFF7E57C2), size: 20),
          const SizedBox(width: 8),
          Expanded(
            child: Text(
              'A* Engine calculated: ${widget.detourRouteName}',
              style: const TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.w800,
                color: Color(0xFF4A148C),
              ),
            ),
          ),
          const Text('🌟', style: TextStyle(fontSize: 16)),
        ],
      ),
    );
  }

  Widget _buildMiniMapPreview() {
    return Container(
      height: 90,
      width: double.infinity,
      decoration: BoxDecoration(
        color: const Color(0xFFE8F5E9),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: const Color(0xFFA5D6A7)),
      ),
      child: Stack(
        children: [
          Center(
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                _buildNodeDot('Current', const Color(0xFF00C853)),
                Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Container(
                      width: 70,
                      height: 4,
                      color: const Color(0xFFE53935),
                    ),
                    const SizedBox(height: 2),
                    const Text('BLOCKED ✕',
                        style: TextStyle(
                            fontSize: 9,
                            fontWeight: FontWeight.w900,
                            color: Color(0xFFC62828))),
                  ],
                ),
                const Text('🚧', style: TextStyle(fontSize: 22)),
                Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Container(
                      width: 70,
                      height: 4,
                      decoration: const BoxDecoration(
                        color: Color(0xFF7E57C2),
                      ),
                    ),
                    const SizedBox(height: 2),
                    const Text('A* DETOUR ➔',
                        style: TextStyle(
                            fontSize: 9,
                            fontWeight: FontWeight.w900,
                            color: Color(0xFF4A148C))),
                  ],
                ),
                _buildNodeDot('Goal', const Color(0xFFFF9100)),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildNodeDot(String label, Color color) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(
          width: 16,
          height: 16,
          decoration: BoxDecoration(
            color: color,
            shape: BoxShape.circle,
            border: Border.all(color: Colors.white, width: 2),
          ),
        ),
        const SizedBox(height: 2),
        Text(
          label,
          style: TextStyle(
            fontSize: 9,
            fontWeight: FontWeight.bold,
            color: color,
          ),
        ),
      ],
    );
  }

  Widget _buildActionButtons() {
    return Column(
      children: [
        SizedBox(
          width: double.infinity,
          height: 46,
          child: ElevatedButton(
            onPressed: widget.onTakeDetour,
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFF7E57C2),
              foregroundColor: Colors.white,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
              elevation: 2,
            ),
            child: const Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(Icons.directions_rounded, size: 20),
                SizedBox(width: 8),
                Text(
                  'Take Safe A* Detour',
                  style: TextStyle(fontSize: 14, fontWeight: FontWeight.w900),
                ),
              ],
            ),
          ),
        ),
        const SizedBox(height: 8),
        SizedBox(
          width: double.infinity,
          height: 42,
          child: OutlinedButton(
            onPressed: widget.onUseBackpackTool,
            style: OutlinedButton.styleFrom(
              foregroundColor: const Color(0xFFE65100),
              side: const BorderSide(color: Color(0xFFFFB74D), width: 1.5),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
            ),
            child: const Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text('🎒', style: TextStyle(fontSize: 18)),
                SizedBox(width: 8),
                Text(
                  'Check Backpack for Tools',
                  style: TextStyle(fontSize: 13, fontWeight: FontWeight.bold),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }
}
