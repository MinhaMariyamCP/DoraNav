import 'package:flutter/material.dart';
import '../models/suggestion_item.dart';
import '../theme/backpack_theme.dart';
import 'backpack_illustrations.dart';

/// State 5: Item detail full/bottom modal view.
/// Shows large item icon, full "Why Dora needs it?", metadata tags,
/// quantity controls (+/-), and Add / Remove action.
class ItemDetailModal extends StatefulWidget {
  final SuggestionItem item;
  final ValueChanged<int> onQuantityChanged;
  final ValueChanged<bool> onToggleAdd;

  const ItemDetailModal({
    super.key,
    required this.item,
    required this.onQuantityChanged,
    required this.onToggleAdd,
  });

  static Future<void> show(
    BuildContext context, {
    required SuggestionItem item,
    required ValueChanged<int> onQuantityChanged,
    required ValueChanged<bool> onToggleAdd,
  }) {
    return showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) => ItemDetailModal(
        item: item,
        onQuantityChanged: onQuantityChanged,
        onToggleAdd: onToggleAdd,
      ),
    );
  }

  @override
  State<ItemDetailModal> createState() => _ItemDetailModalState();
}

class _ItemDetailModalState extends State<ItemDetailModal> {
  late int _quantity;
  late bool _isAdded;

  @override
  void initState() {
    super.initState();
    _quantity = widget.item.quantity > 0 ? widget.item.quantity : 1;
    _isAdded = widget.item.isAdded;
  }

  @override
  Widget build(BuildContext context) {
    final item = widget.item;

    return Container(
      padding: const EdgeInsets.fromLTRB(20, 14, 20, 24),
      decoration: const BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.vertical(top: Radius.circular(32)),
      ),
      child: SafeArea(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // Top pull bar
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
            const SizedBox(height: 12),

            // Top Header: Title & Close
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text(
                  'Item Details',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.w900,
                    color: BackpackColors.textDark,
                  ),
                ),
                IconButton(
                  onPressed: () => Navigator.of(context).pop(),
                  icon: const Icon(Icons.close_rounded, color: BackpackColors.textSecondary),
                ),
              ],
            ),
            const SizedBox(height: 12),

            // Big Item Graphic
            Center(
              child: AdventureItemIconWidget(
                iconKey: item.iconKey,
                size: 96,
              ),
            ),
            const SizedBox(height: 16),

            // Name & Essential Tag
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(
                  item.name,
                  style: const TextStyle(
                    fontSize: 22,
                    fontWeight: FontWeight.w900,
                    color: BackpackColors.textDark,
                  ),
                ),
                if (item.essential) ...[
                  const SizedBox(width: 8),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                    decoration: BoxDecoration(
                      color: BackpackColors.essentialBg,
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: const Text(
                      'Essential',
                      style: TextStyle(
                        fontSize: 11,
                        fontWeight: FontWeight.w800,
                        color: BackpackColors.essentialText,
                      ),
                    ),
                  ),
                ],
              ],
            ),
            const SizedBox(height: 4),

            // Short Description
            Text(
              item.shortDescription,
              style: BackpackTypography.cardDescription,
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 16),

            // "Why Dora needs it?" Callout Box
            Container(
              padding: const EdgeInsets.all(14),
              decoration: BoxDecoration(
                color: BackpackColors.lightPurple,
                borderRadius: BorderRadius.circular(18),
                border: Border.all(color: BackpackColors.softPurple, width: 1.2),
              ),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const DoraAvatarWidget(size: 38),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text(
                          'Why Dora needs it?',
                          style: TextStyle(
                            fontSize: 13,
                            fontWeight: FontWeight.w900,
                            color: BackpackColors.primaryPurpleDark,
                          ),
                        ),
                        const SizedBox(height: 3),
                        Text(
                          item.reason,
                          style: const TextStyle(
                            fontSize: 12,
                            fontWeight: FontWeight.w600,
                            color: BackpackColors.textDark,
                            height: 1.3,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 16),

            // Metadata: Best for & Category
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
              decoration: BoxDecoration(
                color: BackpackColors.background,
                borderRadius: BorderRadius.circular(16),
              ),
              child: Column(
                children: [
                  _buildMetaRow('Best for', item.bestFor),
                  const Divider(height: 16, color: BackpackColors.borderLight),
                  _buildMetaRow('Category', item.category.label),
                  const Divider(height: 16, color: BackpackColors.borderLight),
                  _buildMetaRow('Used in', item.usedIn),
                ],
              ),
            ),
            const SizedBox(height: 16),

            // Quantity selector (+/-)
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Text(
                  'Quantity:',
                  style: TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w800,
                    color: BackpackColors.textDark,
                  ),
                ),
                const SizedBox(width: 14),
                IconButton(
                  onPressed: _quantity > 1
                      ? () {
                          setState(() => _quantity--);
                          widget.onQuantityChanged(_quantity);
                        }
                      : null,
                  icon: const Icon(Icons.remove_circle_outline_rounded, color: BackpackColors.primaryPurple),
                ),
                Text(
                  '$_quantity',
                  style: const TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.w900,
                    color: BackpackColors.textDark,
                  ),
                ),
                IconButton(
                  onPressed: () {
                    setState(() => _quantity++);
                    widget.onQuantityChanged(_quantity);
                  },
                  icon: const Icon(Icons.add_circle_outline_rounded, color: BackpackColors.primaryPurple),
                ),
              ],
            ),
            const SizedBox(height: 12),

            // Add / Remove action button
            ElevatedButton(
              onPressed: () {
                final newStatus = !_isAdded;
                setState(() => _isAdded = newStatus);
                widget.onToggleAdd(newStatus);
                Navigator.of(context).pop();
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: _isAdded ? BackpackColors.swiperRed : BackpackColors.primaryPurple,
                foregroundColor: Colors.white,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(25)),
                padding: const EdgeInsets.symmetric(vertical: 14),
                elevation: 4,
              ),
              child: Text(
                _isAdded ? 'Remove from Backpack' : 'Add to Backpack',
                style: BackpackTypography.buttonLabel,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildMetaRow(String label, String value) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          label,
          style: const TextStyle(
            fontSize: 13,
            fontWeight: FontWeight.w600,
            color: BackpackColors.textSecondary,
          ),
        ),
        Text(
          value,
          style: const TextStyle(
            fontSize: 13,
            fontWeight: FontWeight.w800,
            color: BackpackColors.textDark,
          ),
        ),
      ],
    );
  }
}
