import 'package:flutter/material.dart';

/// Bottom action bar matching the reference image:
/// - Backpack (🎒)
/// - Lost Mode (🏰)
/// - Achievements (🏆)
/// - Voice Guide (🎙️)
/// - End Trip (❌ Red pill)
class MapQuickActionsBar extends StatelessWidget {
  final VoidCallback? onBackpackPressed;
  final VoidCallback? onLostModePressed;
  final VoidCallback? onAchievementsPressed;
  final VoidCallback? onVoiceGuidePressed;
  final VoidCallback? onEndTripPressed;
  final VoidCallback? onRoadBlockPressed;
  final bool isRoadBlockActive;
  final VoidCallback? onGraphInspectorPressed;
  final VoidCallback? onTestFiestaPressed;

  const MapQuickActionsBar({
    super.key,
    this.onBackpackPressed,
    this.onLostModePressed,
    this.onAchievementsPressed,
    this.onVoiceGuidePressed,
    this.onEndTripPressed,
    this.onRoadBlockPressed,
    this.isRoadBlockActive = false,
    this.onGraphInspectorPressed,
    this.onTestFiestaPressed,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12.0, vertical: 8.0),
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.95),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.08),
            blurRadius: 4,
            offset: const Offset(0, -2),
          ),
        ],
      ),
      child: SingleChildScrollView(
        scrollDirection: Axis.horizontal,
        child: Row(
          children: [
            _buildActionButton(
              icon: Icons.backpack_rounded,
              label: 'Backpack',
              color: const Color(0xFF00897B),
              onTap: onBackpackPressed,
            ),
            const SizedBox(width: 8),
            _buildActionButton(
              icon: Icons.castle_rounded,
              label: 'Lost Mode',
              color: const Color(0xFF5E35B1),
              onTap: onLostModePressed,
            ),
            const SizedBox(width: 8),
            _buildActionButton(
              icon: Icons.emoji_events_rounded,
              label: 'Achievements',
              color: const Color(0xFFF57C00),
              onTap: onAchievementsPressed,
            ),
            const SizedBox(width: 8),
            _buildActionButton(
              icon: Icons.record_voice_over_rounded,
              label: 'Voice Guide',
              color: const Color(0xFF3949AB),
              onTap: onVoiceGuidePressed,
            ),
            const SizedBox(width: 8),
            _buildActionButton(
              icon: Icons.construction_rounded,
              label: isRoadBlockActive ? 'Clear Block' : 'Road Block',
              color: isRoadBlockActive ? const Color(0xFFD32F2F) : const Color(0xFFFF8F00),
              onTap: onRoadBlockPressed,
            ),
            const SizedBox(width: 8),
            _buildActionButton(
              icon: Icons.hub_rounded,
              label: 'Graph Engine',
              color: const Color(0xFF6A1B9A),
              onTap: onGraphInspectorPressed,
            ),
            const SizedBox(width: 8),
            _buildActionButton(
              icon: Icons.celebration_rounded,
              label: '🎉 Test Fiesta',
              color: const Color(0xFFE91E63),
              onTap: onTestFiestaPressed,
            ),
            const SizedBox(width: 12),
            // End Trip Red Button
            ElevatedButton.icon(
              onPressed: onEndTripPressed,
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFFE53935),
                foregroundColor: Colors.white,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
                padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
                elevation: 2,
              ),
              icon: const Icon(Icons.close_rounded, size: 16),
              label: const Text(
                'End Trip',
                style: TextStyle(fontWeight: FontWeight.w800, fontSize: 12),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildActionButton({
    required IconData icon,
    required String label,
    required Color color,
    VoidCallback? onTap,
  }) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(20),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
        decoration: BoxDecoration(
          color: color.withValues(alpha: 0.12),
          borderRadius: BorderRadius.circular(20),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(icon, color: color, size: 18),
            const SizedBox(width: 5),
            Text(
              label,
              style: TextStyle(
                color: color,
                fontSize: 12,
                fontWeight: FontWeight.w800,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
