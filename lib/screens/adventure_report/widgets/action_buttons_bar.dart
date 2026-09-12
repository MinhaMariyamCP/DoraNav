import 'package:flutter/material.dart';

/// Bottom sticky action bar with 3 colorful buttons + encouraging Boots quote
class ActionButtonsBar extends StatelessWidget {
  final VoidCallback? onViewRoute;
  final VoidCallback? onBackToMap;
  final VoidCallback? onStartNewAdventure;

  const ActionButtonsBar({
    super.key,
    this.onViewRoute,
    this.onBackToMap,
    this.onStartNewAdventure,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.fromLTRB(14, 12, 14, 14),
      decoration: BoxDecoration(
        color: const Color(0xFF4A148C).withValues(alpha: 0.95), // Deep Dora purple bar
        borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.2),
            blurRadius: 12,
            offset: const Offset(0, -4),
          ),
        ],
      ),
      child: SafeArea(
        top: false,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // Row of 3 action buttons
            Row(
              children: [
                // 1. View Route Button (Blue)
                Expanded(
                  child: _buildActionButton(
                    label: 'View Route',
                    iconEmoji: '🗺️',
                    bgColor: const Color(0xFF1E88E5),
                    onPressed: onViewRoute,
                  ),
                ),
                const SizedBox(width: 8),

                // 2. Back to Map Button (Purple)
                Expanded(
                  child: _buildActionButton(
                    label: 'Back to Map',
                    iconEmoji: '📍',
                    bgColor: const Color(0xFF7B1FA2),
                    onPressed: onBackToMap,
                  ),
                ),
                const SizedBox(width: 8),

                // 3. Start New Adventure Button (Green)
                Expanded(
                  child: _buildActionButton(
                    label: 'Start New Adventure',
                    iconEmoji: '🧭',
                    bgColor: const Color(0xFF43A047),
                    onPressed: onStartNewAdventure,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 10),

            // Encouraging Footer Quote with Boots: "Every adventure makes you braver!"
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 6),
              decoration: BoxDecoration(
                color: Colors.white.withValues(alpha: 0.15),
                borderRadius: BorderRadius.circular(16),
              ),
              child: const Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text('⭐', style: TextStyle(fontSize: 13)),
                  SizedBox(width: 6),
                  Text(
                    'Every adventure makes you braver!',
                    style: TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.w800,
                      color: Color(0xFFFFEB3B),
                    ),
                  ),
                  SizedBox(width: 6),
                  Text('🐒', style: TextStyle(fontSize: 14)),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildActionButton({
    required String label,
    required String iconEmoji,
    required Color bgColor,
    required VoidCallback? onPressed,
  }) {
    return SizedBox(
      height: 48,
      child: ElevatedButton(
        onPressed: onPressed,
        style: ElevatedButton.styleFrom(
          backgroundColor: bgColor,
          foregroundColor: Colors.white,
          elevation: 3,
          padding: const EdgeInsets.symmetric(horizontal: 6),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
            side: const BorderSide(color: Colors.white, width: 1.2),
          ),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(iconEmoji, style: const TextStyle(fontSize: 15)),
            const SizedBox(width: 4),
            Flexible(
              child: Text(
                label,
                maxLines: 2,
                textAlign: TextAlign.center,
                style: const TextStyle(
                  fontSize: 11,
                  fontWeight: FontWeight.w900,
                  height: 1.1,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
