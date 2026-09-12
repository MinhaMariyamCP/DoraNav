import 'package:flutter/material.dart';
import '../services/mock_recommendation_service.dart';
import '../theme/backpack_theme.dart';

/// Scenario Selector Bar allowing testers and developers to easily switch
/// between the 5 mock contexts (River, Cave/Night, Snow, Long Journey, Swiper)
/// or toggle the Empty State.
class ScenarioSelectorBar extends StatelessWidget {
  final BackpackScenario? activeScenario;
  final bool isEmptyState;
  final ValueChanged<BackpackScenario> onScenarioSelected;
  final VoidCallback onToggleEmptyState;

  const ScenarioSelectorBar({
    super.key,
    required this.activeScenario,
    required this.isEmptyState,
    required this.onScenarioSelected,
    required this.onToggleEmptyState,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
      padding: const EdgeInsets.all(10),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: BackpackColors.borderLight),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.03),
            blurRadius: 6,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Row(
                children: [
                  Icon(Icons.science_rounded, size: 16, color: BackpackColors.primaryPurple),
                  SizedBox(width: 6),
                  Text(
                    'TEST SCENARIOS (MOCK PROVIDER)',
                    style: TextStyle(
                      fontSize: 11,
                      fontWeight: FontWeight.w900,
                      color: BackpackColors.primaryPurple,
                      letterSpacing: 0.5,
                    ),
                  ),
                ],
              ),

              // Empty State Toggle Chip
              InkWell(
                onTap: onToggleEmptyState,
                borderRadius: BorderRadius.circular(12),
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                  decoration: BoxDecoration(
                    color: isEmptyState ? BackpackColors.swiperRed : BackpackColors.lightPurple,
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Text(
                    isEmptyState ? 'State 1: Empty (ON)' : 'State 1: Empty',
                    style: TextStyle(
                      fontSize: 10,
                      fontWeight: FontWeight.w800,
                      color: isEmptyState ? Colors.white : BackpackColors.primaryPurpleDark,
                    ),
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),

          // Scrollable scenario pills
          SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            child: Row(
              children: BackpackScenario.values.map((scenario) {
                final isSelected = !isEmptyState && activeScenario == scenario;

                return Padding(
                  padding: const EdgeInsets.only(right: 6),
                  child: ChoiceChip(
                    label: Text(
                      scenario.title,
                      style: TextStyle(
                        fontSize: 11,
                        fontWeight: isSelected ? FontWeight.w800 : FontWeight.w600,
                        color: isSelected ? Colors.white : BackpackColors.textDark,
                      ),
                    ),
                    selected: isSelected,
                    selectedColor: BackpackColors.primaryPurple,
                    backgroundColor: BackpackColors.background,
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                    showCheckmark: false,
                    onSelected: (_) => onScenarioSelected(scenario),
                  ),
                );
              }).toList(),
            ),
          ),
        ],
      ),
    );
  }
}
