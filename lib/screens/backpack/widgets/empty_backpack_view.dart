import 'package:flutter/material.dart';
import '../theme/backpack_theme.dart';
import 'backpack_illustrations.dart';

/// State 1: Empty / Default Backpack UI.
/// Displays cheerful Backpack character, welcoming copy, and primary prompt CTA.
class EmptyBackpackView extends StatelessWidget {
  final VoidCallback onAskDoraPressed;

  const EmptyBackpackView({
    super.key,
    required this.onAskDoraPressed,
  });

  @override
  Widget build(BuildContext context) {
    return Center(
      child: SingleChildScrollView(
        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 20),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            // Cheerful Backpack Character illustration
            const BackpackCharacterWidget(
              width: 170,
              height: 180,
            ),
            const SizedBox(height: 20),

            const Text(
              'Your backpack is empty!',
              style: TextStyle(
                fontSize: 22,
                fontWeight: FontWeight.w900,
                color: BackpackColors.textDark,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 8),

            const Text(
              'Ask Dora what we need\nand I\'ll find the right things!',
              style: TextStyle(
                fontSize: 15,
                fontWeight: FontWeight.w600,
                color: BackpackColors.textSecondary,
                height: 1.35,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 24),

            // Friendly Dora Speech Bubble Callout
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 12),
              decoration: BoxDecoration(
                color: BackpackColors.lightPurple,
                borderRadius: BorderRadius.circular(20),
                border: Border.all(color: BackpackColors.softPurple, width: 1.5),
              ),
              child: const Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  DoraAvatarWidget(size: 34),
                  SizedBox(width: 10),
                  Flexible(
                    child: Text(
                      '¡Vamos! Let\'s get ready\nfor our adventure!',
                      style: TextStyle(
                        fontSize: 13,
                        fontWeight: FontWeight.w800,
                        color: BackpackColors.primaryPurpleDark,
                      ),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 24),

            // Primary CTA: "What do we need?"
            ElevatedButton.icon(
              onPressed: onAskDoraPressed,
              style: ElevatedButton.styleFrom(
                backgroundColor: BackpackColors.primaryPurple,
                foregroundColor: Colors.white,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(30)),
                padding: const EdgeInsets.symmetric(horizontal: 28, vertical: 14),
                elevation: 4,
                shadowColor: BackpackColors.primaryPurple.withValues(alpha: 0.4),
              ),
              icon: const Icon(Icons.mic_rounded, size: 22),
              label: const Text(
                'What do we need?',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w800,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
