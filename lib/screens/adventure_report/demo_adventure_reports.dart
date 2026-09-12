import 'package:flutter/material.dart';
import 'models/trip_data.dart';
import 'widgets/adventure_report_screen.dart';

/// Interactive Demo Page allowing switching between 3 distinct mock Adventure Reports:
/// 1. Witch's Castle (Matches reference mockup)
/// 2. Sunny Beach (Casual sunny stroll)
/// 3. Crystal Rainforest (High obstacle Swiper challenge)
class DemoAdventureReportsScreen extends StatefulWidget {
  const DemoAdventureReportsScreen({super.key});

  @override
  State<DemoAdventureReportsScreen> createState() => _DemoAdventureReportsScreenState();
}

class _DemoAdventureReportsScreenState extends State<DemoAdventureReportsScreen> {
  int _selectedTripIndex = 0;

  final List<TripData> _trips = [
    TripData.witchsCastleMock,
    TripData.sunnyBeachMock,
    TripData.swiperTroubleMock,
  ];

  @override
  Widget build(BuildContext context) {
    final currentTrip = _trips[_selectedTripIndex];

    return Scaffold(
      appBar: AppBar(
        backgroundColor: const Color(0xFF311B92),
        foregroundColor: Colors.white,
        title: const Text(
          'DoraNav Travel Reports Demo',
          style: TextStyle(fontSize: 16, fontWeight: FontWeight.w900),
        ),
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(48),
          child: Container(
            color: const Color(0xFF4527A0),
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                _buildTabButton(0, "🏰 Witch's Castle"),
                _buildTabButton(1, "🏖️ Sunny Beach"),
                _buildTabButton(2, "🦊 Swiper Trouble"),
              ],
            ),
          ),
        ),
      ),
      body: AdventureReportScreen(
        key: ValueKey(currentTrip.destinationName),
        tripData: currentTrip,
        onViewRoute: () {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('Showing route for ${currentTrip.destinationName}! 🗺️'),
              backgroundColor: const Color(0xFF1E88E5),
            ),
          );
        },
        onBackToMap: () => Navigator.of(context).pop(),
        onStartNewAdventure: () {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Starting brand new explorer quest! 🌟'),
              backgroundColor: Color(0xFF43A047),
            ),
          );
        },
      ),
    );
  }

  Widget _buildTabButton(int index, String label) {
    final isSelected = _selectedTripIndex == index;
    return InkWell(
      onTap: () => setState(() => _selectedTripIndex = index),
      borderRadius: BorderRadius.circular(16),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
        decoration: BoxDecoration(
          color: isSelected ? const Color(0xFFFFD54F) : Colors.white.withValues(alpha: 0.15),
          borderRadius: BorderRadius.circular(16),
        ),
        child: Text(
          label,
          style: TextStyle(
            fontSize: 11.5,
            fontWeight: FontWeight.w900,
            color: isSelected ? const Color(0xFF311B92) : Colors.white,
          ),
        ),
      ),
    );
  }
}
