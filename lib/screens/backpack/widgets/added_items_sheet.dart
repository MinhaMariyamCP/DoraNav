import 'package:flutter/material.dart';
import '../models/suggestion_item.dart';
import '../theme/backpack_theme.dart';
import 'backpack_illustrations.dart';

/// State 4: Slide-up sheet / mini bar showing added selected items.
/// Contains quick remove button per item, celebratory Dora message,
/// and primary "Let's Go!" confirmation CTA.
class AddedItemsSheet extends StatelessWidget {
  final List<SuggestionItem> items;
  final ValueChanged<SuggestionItem> onRemoveItem;
  final VoidCallback onLetsGo;
  final VoidCallback onClose;

  const AddedItemsSheet({
    super.key,
    required this.items,
    required this.onRemoveItem,
    required this.onLetsGo,
    required this.onClose,
  });

  static Future<void> show(
    BuildContext context, {
    required List<SuggestionItem> items,
    required ValueChanged<SuggestionItem> onRemoveItem,
    required VoidCallback onLetsGo,
  }) {
    return showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) => AddedItemsSheet(
        items: items,
        onRemoveItem: onRemoveItem,
        onLetsGo: () {
          Navigator.of(context).pop();
          onLetsGo();
        },
        onClose: () => Navigator.of(context).pop(),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.fromLTRB(20, 12, 20, 24),
      decoration: const BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.vertical(top: Radius.circular(32)),
        boxShadow: [
          BoxShadow(
            color: Color(0x2A5E35B1),
            blurRadius: 20,
            offset: Offset(0, -6),
          ),
        ],
      ),
      child: SafeArea(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // Pull bar
            Center(
              child: Container(
                width: 44,
                height: 5,
                decoration: BoxDecoration(
                  color: BackpackColors.borderLight,
                  borderRadius: BorderRadius.circular(10),
                ),
              ),
            ),
            const SizedBox(height: 14),

            // Header: Title & Close
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Row(
                  children: [
                    const Icon(Icons.backpack_rounded, color: BackpackColors.primaryPurple, size: 24),
                    const SizedBox(width: 8),
                    Text(
                      'My Backpack (${items.length} items)',
                      style: const TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.w900,
                        color: BackpackColors.textDark,
                      ),
                    ),
                  ],
                ),
                IconButton(
                  onPressed: onClose,
                  icon: const Icon(Icons.close_rounded, color: BackpackColors.textSecondary),
                ),
              ],
            ),
            const SizedBox(height: 12),

            // Horizontal tray of selected items with delete badges
            if (items.isEmpty)
              const Padding(
                padding: EdgeInsets.symmetric(vertical: 24),
                child: Center(
                  child: Text(
                    'No items packed yet! Tap "Add" on any item above.',
                    style: TextStyle(
                      fontSize: 13,
                      fontWeight: FontWeight.w600,
                      color: BackpackColors.textSecondary,
                    ),
                  ),
                ),
              )
            else
              SizedBox(
                height: 96,
                child: ListView.separated(
                  scrollDirection: Axis.horizontal,
                  itemCount: items.length,
                  separatorBuilder: (_, _) => const SizedBox(width: 14),
                  itemBuilder: (context, index) {
                    final item = items[index];
                    return Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Stack(
                          clipBehavior: Clip.none,
                          children: [
                            AdventureItemIconWidget(
                              iconKey: item.iconKey,
                              size: 58,
                            ),
                            // Small remove X badge
                            Positioned(
                              top: -4,
                              right: -4,
                              child: GestureDetector(
                                onTap: () => onRemoveItem(item),
                                child: Container(
                                  width: 20,
                                  height: 20,
                                  decoration: const BoxDecoration(
                                    color: BackpackColors.primaryPurple,
                                    shape: BoxShape.circle,
                                  ),
                                  child: const Icon(Icons.close_rounded, color: Colors.white, size: 12),
                                ),
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 6),
                        SizedBox(
                          width: 64,
                          child: Text(
                            item.name,
                            style: const TextStyle(
                              fontSize: 11,
                              fontWeight: FontWeight.w700,
                              color: BackpackColors.textDark,
                            ),
                            textAlign: TextAlign.center,
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                      ],
                    );
                  },
                ),
              ),

            const SizedBox(height: 16),

            // Friendly encouraging Dora banner
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
              decoration: BoxDecoration(
                color: BackpackColors.lightPurple,
                borderRadius: BorderRadius.circular(16),
              ),
              child: const Row(
                children: [
                  DoraAvatarWidget(size: 34),
                  SizedBox(width: 10),
                  Expanded(
                    child: Text(
                      'Nice! You have everything you need.\nLet\'s keep exploring!',
                      style: TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.w700,
                        color: BackpackColors.primaryPurpleDark,
                      ),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 16),

            // Big CTA: "Let's Go!"
            ElevatedButton.icon(
              onPressed: onLetsGo,
              style: ElevatedButton.styleFrom(
                backgroundColor: BackpackColors.primaryPurple,
                foregroundColor: Colors.white,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(25)),
                padding: const EdgeInsets.symmetric(vertical: 14),
                elevation: 4,
                shadowColor: BackpackColors.primaryPurple.withValues(alpha: 0.4),
              ),
              icon: const Icon(Icons.arrow_forward_rounded, size: 20),
              label: const Text(
                'Let\'s Go!',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w900,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
