import 'package:flutter/material.dart';
import '../models/trip_data.dart';
import '../services/score_calculator.dart';
import 'action_buttons_bar.dart';
import 'adventure_score_badge.dart';
import 'celebration_header.dart';
import 'destination_hero_card.dart';
import 'highlights_section.dart';
import 'stats_grid_card.dart';

/// Full-screen, responsive kid-friendly Adventure Report / Travel Report Screen
/// Driven entirely by the provided [TripData] model.
class AdventureReportScreen extends StatefulWidget {
  final TripData tripData;
  final ScoreCalculator scoreCalculator;
  final VoidCallback? onViewRoute;
  final VoidCallback? onBackToMap;
  final VoidCallback? onStartNewAdventure;

  const AdventureReportScreen({
    super.key,
    required this.tripData,
    this.scoreCalculator = const ScoreCalculator(),
    this.onViewRoute,
    this.onBackToMap,
    this.onStartNewAdventure,
  });

  @override
  State<AdventureReportScreen> createState() => _AdventureReportScreenState();
}

class _AdventureReportScreenState extends State<AdventureReportScreen> {
  late ScoreResult _scoreResult;

  @override
  void initState() {
    super.initState();
    _scoreResult = widget.scoreCalculator.calculate(widget.tripData);
  }

  @override
  void didUpdateWidget(covariant AdventureReportScreen oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.tripData != widget.tripData) {
      _scoreResult = widget.scoreCalculator.calculate(widget.tripData);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF4A148C), // Vibrant Dora purple canvas
      body: SafeArea(
        child: Column(
          children: [
            // 1. Top Celebration Banner & Dora/Boots Header
            const CelebrationHeader(),

            // 2. Scrollable Report Content Area
            Expanded(
              child: SingleChildScrollView(
                physics: const BouncingScrollPhysics(),
                child: Column(
                  children: [
                    // Destination Hero Card
                    DestinationHeroCard(trip: widget.tripData),

                    const SizedBox(height: 12),

                    // 2x3 Statistics Grid
                    StatsGridCard(trip: widget.tripData),

                    const SizedBox(height: 12),

                    // Adventure Score Badge & Expandable Point Breakdown
                    AdventureScoreBadge(scoreResult: _scoreResult),

                    const SizedBox(height: 12),

                    // Highlights Section
                    HighlightsSection(highlights: widget.tripData.highlights),

                    const SizedBox(height: 20),
                  ],
                ),
              ),
            ),

            // 3. Bottom Sticky Action Buttons Bar
            ActionButtonsBar(
              onViewRoute: widget.onViewRoute ??
                  () {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                        content: Text('Viewing adventure route on map! 🗺️'),
                        backgroundColor: Color(0xFF1E88E5),
                      ),
                    );
                  },
              onBackToMap: widget.onBackToMap ??
                  () {
                    Navigator.of(context).pop();
                  },
              onStartNewAdventure: widget.onStartNewAdventure ??
                  () {
                    Navigator.of(context).popUntil((route) => route.isFirst);
                  },
            ),
          ],
        ),
      ),
    );
  }
}
