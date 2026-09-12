import 'package:flutter/material.dart';
import '../models/suggestion_item.dart';
import '../theme/backpack_theme.dart';
import 'backpack_illustrations.dart';

/// Kid-friendly card displaying item icon, name, reason, and interactive Add button.
class SuggestionCard extends StatefulWidget {
  final SuggestionItem item;
  final VoidCallback onToggleAdd;
  final VoidCallback onTapDetail;

  const SuggestionCard({
    super.key,
    required this.item,
    required this.onToggleAdd,
    required this.onTapDetail,
  });

  @override
  State<SuggestionCard> createState() => _SuggestionCardState();
}

class _SuggestionCardState extends State<SuggestionCard> with SingleTickerProviderStateMixin {
  late AnimationController _pulseController;
  late Animation<double> _scaleAnimation;

  @override
  void initState() {
    super.initState();
    _pulseController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 250),
    );
    _scaleAnimation = Tween<double>(begin: 1.0, end: 0.95).animate(
      CurvedAnimation(parent: _pulseController, curve: Curves.easeInOut),
    );
  }

  @override
  void dispose() {
    _pulseController.dispose();
    super.dispose();
  }

  void _handleTapAdd() {
    _pulseController.forward().then((_) => _pulseController.reverse());
    widget.onToggleAdd();
  }

  @override
  Widget build(BuildContext context) {
    final item = widget.item;

    return ScaleTransition(
      scale: _scaleAnimation,
      child: Container(
        margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
        decoration: BackpackDecorations.cardDecoration(isSelected: item.isAdded),
        child: InkWell(
          onTap: widget.onTapDetail,
          borderRadius: BorderRadius.circular(20),
          child: Padding(
            padding: const EdgeInsets.all(12),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                // Item Icon with shadow
                AdventureItemIconWidget(
                  iconKey: item.iconKey,
                  size: 58,
                ),
                const SizedBox(width: 14),

                // Name & Descriptions
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Row(
                        children: [
                          Flexible(
                            child: Text(
                              item.name,
                              style: BackpackTypography.cardTitle,
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                          if (item.essential) ...[
                            const SizedBox(width: 6),
                            Container(
                              padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                              decoration: BoxDecoration(
                                color: BackpackColors.essentialBg,
                                borderRadius: BorderRadius.circular(6),
                              ),
                              child: const Text(
                                'Essential',
                                style: TextStyle(
                                  fontSize: 10,
                                  fontWeight: FontWeight.w800,
                                  color: BackpackColors.essentialText,
                                ),
                              ),
                            ),
                          ],
                        ],
                      ),
                      const SizedBox(height: 3),
                      Text(
                        item.shortDescription,
                        style: BackpackTypography.cardDescription,
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                      ),
                      const SizedBox(height: 4),
                      // Dora Reason
                      Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text('✨ ', style: TextStyle(fontSize: 10)),
                          Expanded(
                            child: Text(
                              item.reason,
                              style: const TextStyle(
                                fontSize: 11,
                                fontWeight: FontWeight.w600,
                                color: BackpackColors.primaryPurpleDark,
                                fontStyle: FontStyle.italic,
                              ),
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
                const SizedBox(width: 10),

                // Interactive Add Pill Button
                InkWell(
                  onTap: _handleTapAdd,
                  borderRadius: BorderRadius.circular(20),
                  child: AnimatedContainer(
                    duration: const Duration(milliseconds: 250),
                    padding: EdgeInsets.symmetric(
                      horizontal: item.isAdded ? 10 : 16,
                      vertical: 8,
                    ),
                    decoration: BoxDecoration(
                      color: item.isAdded ? BackpackColors.accentGreen : BackpackColors.primaryPurple,
                      borderRadius: BorderRadius.circular(20),
                      boxShadow: [
                        BoxShadow(
                          color: (item.isAdded ? BackpackColors.accentGreen : BackpackColors.primaryPurple)
                              .withValues(alpha: 0.35),
                          blurRadius: 8,
                          offset: const Offset(0, 3),
                        ),
                      ],
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        if (item.isAdded) ...[
                          const Icon(Icons.check_rounded, color: Colors.white, size: 16),
                          const SizedBox(width: 4),
                          Text(
                            item.quantity > 1 ? 'x${item.quantity}' : 'Added',
                            style: const TextStyle(
                              color: Colors.white,
                              fontSize: 12,
                              fontWeight: FontWeight.w800,
                            ),
                          ),
                        ] else ...[
                          const Text(
                            'Add',
                            style: TextStyle(
                              color: Colors.white,
                              fontSize: 13,
                              fontWeight: FontWeight.w800,
                            ),
                          ),
                        ],
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
