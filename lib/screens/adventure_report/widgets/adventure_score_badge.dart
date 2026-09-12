import 'package:flutter/material.dart';
import '../services/score_calculator.dart';

/// Prominent Adventure Score Medal Badge with expandable breakdown
class AdventureScoreBadge extends StatefulWidget {
  final ScoreResult scoreResult;

  const AdventureScoreBadge({super.key, required this.scoreResult});

  @override
  State<AdventureScoreBadge> createState() => _AdventureScoreBadgeState();
}

class _AdventureScoreBadgeState extends State<AdventureScoreBadge> {
  bool _isExpanded = false;

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 14),
      decoration: BoxDecoration(
        color: const Color(0xFFF3E5F5), // Soft purple gradient background
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: const Color(0xFFCE93D8), width: 1.5),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.08),
            blurRadius: 10,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      clipBehavior: Clip.antiAlias,
      child: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(16),
            child: Row(
              children: [
                // Left Column: Adventure Score title & numeric / 100
                Expanded(
                  flex: 5,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          const Text('✨', style: TextStyle(fontSize: 14)),
                          const SizedBox(width: 4),
                          Text(
                            'Adventure Score',
                            style: TextStyle(
                              fontSize: 13,
                              fontWeight: FontWeight.w800,
                              color: Colors.purple.shade900,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 4),
                      RichText(
                        text: TextSpan(
                          children: [
                            TextSpan(
                              text: '${widget.scoreResult.finalScore} ',
                              style: const TextStyle(
                                fontSize: 32,
                                fontWeight: FontWeight.w900,
                                color: Color(0xFF4A148C),
                                letterSpacing: -1,
                              ),
                            ),
                            TextSpan(
                              text: '/ 100',
                              style: TextStyle(
                                fontSize: 18,
                                fontWeight: FontWeight.w800,
                                color: Colors.purple.shade400,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),

                // Center: Big Shiny Gold Medal Icon
                _buildMedalGraphic(),

                const SizedBox(width: 14),

                // Right Column: Encouraging Praise
                Expanded(
                  flex: 6,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        widget.scoreResult.motivationalPraise,
                        style: TextStyle(
                          fontSize: 11,
                          fontWeight: FontWeight.w700,
                          color: Colors.purple.shade900,
                          height: 1.3,
                        ),
                      ),
                      const SizedBox(height: 6),
                      InkWell(
                        onTap: () => setState(() => _isExpanded = !_isExpanded),
                        borderRadius: BorderRadius.circular(8),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Text(
                              _isExpanded ? 'Hide Details' : 'View Point Breakdown',
                              style: const TextStyle(
                                fontSize: 10.5,
                                fontWeight: FontWeight.w800,
                                color: Color(0xFF7B1FA2),
                                decoration: TextDecoration.underline,
                              ),
                            ),
                            Icon(
                              _isExpanded
                                  ? Icons.keyboard_arrow_up_rounded
                                  : Icons.keyboard_arrow_down_rounded,
                              size: 16,
                              color: const Color(0xFF7B1FA2),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),

          // Expandable Detailed Breakdown Section
          if (_isExpanded) ...[
            Container(height: 1, color: const Color(0xFFE1BEE7)),
            Container(
              color: Colors.white.withValues(alpha: 0.6),
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    widget.scoreResult.verbalSummary,
                    style: const TextStyle(
                      fontSize: 11.5,
                      fontWeight: FontWeight.w700,
                      color: Color(0xFF4A148C),
                    ),
                  ),
                  const SizedBox(height: 8),
                  ...widget.scoreResult.breakdown.entries.map((entry) {
                    final isNegative = entry.value < 0;
                    return Padding(
                      padding: const EdgeInsets.symmetric(vertical: 2.5),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            entry.key,
                            style: TextStyle(
                              fontSize: 11,
                              fontWeight: FontWeight.w600,
                              color: Colors.grey.shade800,
                            ),
                          ),
                          Text(
                            entry.key == 'Route Multiplier'
                                ? 'x${entry.value}'
                                : '${isNegative ? "" : "+"}${entry.value} pts',
                            style: TextStyle(
                              fontSize: 11,
                              fontWeight: FontWeight.w900,
                              color: isNegative
                                  ? const Color(0xFFD32F2F)
                                  : const Color(0xFF2E7D32),
                            ),
                          ),
                        ],
                      ),
                    );
                  }),
                ],
              ),
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildMedalGraphic() {
    return Container(
      width: 66,
      height: 66,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        gradient: const RadialGradient(
          colors: [Color(0xFFFFF9C4), Color(0xFFFFD54F), Color(0xFFFFA000)],
          stops: [0.2, 0.7, 1.0],
        ),
        border: Border.all(color: const Color(0xFFFFB300), width: 2.5),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFFFFB300).withValues(alpha: 0.4),
            blurRadius: 10,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      child: const Center(
        child: Text('🎖️', style: TextStyle(fontSize: 34)),
      ),
    );
  }
}
