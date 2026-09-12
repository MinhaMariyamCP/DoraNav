import 'package:flutter/material.dart';
import '../theme/backpack_theme.dart';
import 'backpack_illustrations.dart';

/// Top bar displaying Dora avatar, Screen title with speech helper,
/// settings shortcut, and added item counter badge.
class BackpackTopBar extends StatelessWidget {
  final String statusText;
  final int addedCount;
  final VoidCallback? onBackpackIconPressed;
  final VoidCallback? onSettingsPressed;
  final VoidCallback? onBackPressed;

  const BackpackTopBar({
    super.key,
    this.statusText = "I'm ready to help!",
    this.addedCount = 0,
    this.onBackpackIconPressed,
    this.onSettingsPressed,
    this.onBackPressed,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.fromLTRB(16, 12, 16, 14),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: const BorderRadius.vertical(bottom: Radius.circular(28)),
        boxShadow: [
          BoxShadow(
            color: BackpackColors.primaryPurple.withValues(alpha: 0.12),
            blurRadius: 16,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: SafeArea(
        bottom: false,
        child: Row(
          children: [
            if (onBackPressed != null) ...[
              IconButton(
                icon: const Icon(Icons.arrow_back_ios_new_rounded, color: BackpackColors.textDark, size: 20),
                onPressed: onBackPressed,
                tooltip: 'Back to Map',
              ),
              const SizedBox(width: 4),
            ],

            // Backpack Character Mini Avatar with bounce animation on count change
            GestureDetector(
              onTap: onBackpackIconPressed,
              child: Stack(
                clipBehavior: Clip.none,
                children: [
                  Container(
                    width: 46,
                    height: 46,
                    decoration: BoxDecoration(
                      color: BackpackColors.lightPurple,
                      shape: BoxShape.circle,
                      border: Border.all(color: BackpackColors.primaryPurple, width: 2),
                    ),
                    child: const Center(
                      child: Icon(Icons.backpack_rounded, color: BackpackColors.primaryPurple, size: 26),
                    ),
                  ),

                  // Added Items Badge
                  if (addedCount > 0)
                    Positioned(
                      top: -4,
                      right: -4,
                      child: AnimatedScale(
                        duration: const Duration(milliseconds: 300),
                        scale: 1.0,
                        curve: Curves.elasticOut,
                        child: Container(
                          padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                          decoration: BoxDecoration(
                            color: BackpackColors.accentPink,
                            borderRadius: BorderRadius.circular(12),
                            border: Border.all(color: Colors.white, width: 2),
                            boxShadow: [
                              BoxShadow(
                                color: BackpackColors.accentPink.withValues(alpha: 0.5),
                                blurRadius: 6,
                                offset: const Offset(0, 2),
                              ),
                            ],
                          ),
                          child: Text(
                            '$addedCount',
                            style: BackpackTypography.badgeText,
                          ),
                        ),
                      ),
                    ),
                ],
              ),
            ),
            const SizedBox(width: 12),

            // Title & Status
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Text(
                    'Backpack',
                    style: TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.w900,
                      color: BackpackColors.textDark,
                      height: 1.1,
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    statusText,
                    style: const TextStyle(
                      fontSize: 13,
                      fontWeight: FontWeight.w600,
                      color: BackpackColors.textSecondary,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                ],
              ),
            ),

            // Dora Avatar
            const DoraAvatarWidget(size: 40),
            const SizedBox(width: 8),

            // Settings gear
            IconButton(
              onPressed: onSettingsPressed,
              icon: const Icon(Icons.settings_rounded, color: BackpackColors.textSecondary, size: 22),
              tooltip: 'Settings',
            ),
          ],
        ),
      ),
    );
  }
}
