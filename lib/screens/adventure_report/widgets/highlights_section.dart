import 'package:flutter/material.dart';
import '../models/trip_data.dart';

/// Highlights section showcasing special achievements and moments encountered
class HighlightsSection extends StatelessWidget {
  final List<TripHighlight> highlights;

  const HighlightsSection({super.key, required this.highlights});

  @override
  Widget build(BuildContext context) {
    if (highlights.isEmpty) return const SizedBox.shrink();

    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 14),
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
      decoration: BoxDecoration(
        color: const Color(0xFFFFFDE7), // Soft sunny yellow
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: const Color(0xFFFFE082), width: 1.5),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.05),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        children: [
          // Section Title
          const Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text('✦', style: TextStyle(color: Color(0xFFFFA000), fontSize: 12)),
              SizedBox(width: 6),
              Text(
                'Highlights',
                style: TextStyle(
                  fontSize: 15,
                  fontWeight: FontWeight.w900,
                  color: Color(0xFFE65100),
                  letterSpacing: -0.2,
                ),
              ),
              SizedBox(width: 6),
              Text('✦', style: TextStyle(color: Color(0xFFFFA000), fontSize: 12)),
            ],
          ),
          const SizedBox(height: 10),

          // Horizontal scrollable or wrapped chips
          Wrap(
            spacing: 8,
            runSpacing: 8,
            alignment: WrapAlignment.center,
            children: highlights.map((h) => _buildHighlightChip(h)).toList(),
          ),
        ],
      ),
    );
  }

  Widget _buildHighlightChip(TripHighlight highlight) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: const Color(0xFFFFD54F), width: 1.2),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.04),
            blurRadius: 4,
            offset: const Offset(0, 1),
          ),
        ],
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(highlight.iconEmoji, style: const TextStyle(fontSize: 18)),
          const SizedBox(width: 6),
          Flexible(
            child: Text(
              highlight.title,
              style: const TextStyle(
                fontSize: 11.5,
                fontWeight: FontWeight.w800,
                color: Color(0xFF37474F),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
