import 'package:flutter/material.dart';
import '../models/trip_data.dart';

/// Hero Card rendering destination image, name, congratulatory message, and telemetry pills
class DestinationHeroCard extends StatelessWidget {
  final TripData trip;

  const DestinationHeroCard({super.key, required this.trip});

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 14),
      decoration: BoxDecoration(
        color: const Color(0xFFFFFDE7), // Soft sunny butter cream
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: const Color(0xFFFFE082), width: 1.5),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.1),
            blurRadius: 12,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      clipBehavior: Clip.antiAlias,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          // Row: Landmark Illustration + Destination Title & Speech
          Padding(
            padding: const EdgeInsets.all(16),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Castle / Landmark Illustration
                Container(
                  width: 120,
                  height: 105,
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(18),
                    gradient: const LinearGradient(
                      begin: Alignment.topCenter,
                      end: Alignment.bottomCenter,
                      colors: [Color(0xFF81D4FA), Color(0xFFA5D6A7)],
                    ),
                    border: Border.all(color: Colors.white, width: 2),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withValues(alpha: 0.08),
                        blurRadius: 6,
                        offset: const Offset(0, 2),
                      ),
                    ],
                  ),
                  child: const Center(
                    child: Text('🏰', style: TextStyle(fontSize: 54)),
                  ),
                ),
                const SizedBox(width: 14),

                // Destination Congratulations
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          const Text('🚩', style: TextStyle(fontSize: 16)),
                          const SizedBox(width: 4),
                          Text(
                            'You reached',
                            style: TextStyle(
                              fontSize: 13,
                              fontWeight: FontWeight.w700,
                              color: Colors.purple.shade900,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 2),
                      Text(
                        '${trip.destinationName}!',
                        style: const TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.w900,
                          color: Color(0xFF4A148C),
                          letterSpacing: -0.3,
                        ),
                      ),
                      const SizedBox(height: 6),
                      Text(
                        trip.destinationDescription,
                        style: TextStyle(
                          fontSize: 11.5,
                          fontWeight: FontWeight.w600,
                          color: Colors.purple.shade800,
                          height: 1.3,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),

          // Divider Line
          Container(height: 1, color: const Color(0xFFFFECB3)),

          // 4 Metadata Pills (Trip Duration, Route Type, Mood, Adventure Level)
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 10),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                _buildPill(
                  icon: Icons.access_time_filled_rounded,
                  iconColor: const Color(0xFF5E35B1),
                  label: 'Trip Duration',
                  value: trip.formattedDuration,
                ),
                _buildPill(
                  icon: Icons.alt_route_rounded,
                  iconColor: const Color(0xFF1E88E5),
                  label: 'Route Type',
                  value: trip.routeType,
                ),
                _buildPill(
                  icon: Icons.sentiment_very_satisfied_rounded,
                  iconColor: const Color(0xFFFB8C00),
                  label: 'Mood',
                  value: trip.mood,
                ),
                _buildPill(
                  icon: Icons.landscape_rounded,
                  iconColor: const Color(0xFF00897B),
                  label: 'Adventure Level',
                  value: trip.adventureLevel,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildPill({
    required IconData icon,
    required Color iconColor,
    required String label,
    required String value,
  }) {
    return Expanded(
      child: Container(
        margin: const EdgeInsets.symmetric(horizontal: 3),
        padding: const EdgeInsets.symmetric(vertical: 6, horizontal: 4),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(14),
          border: Border.all(color: const Color(0xFFE0E0E0), width: 0.8),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(icon, color: iconColor, size: 14),
                const SizedBox(width: 3),
                Flexible(
                  child: Text(
                    label,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: TextStyle(
                      fontSize: 8.5,
                      fontWeight: FontWeight.w600,
                      color: Colors.grey.shade600,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 3),
            Text(
              value,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: const TextStyle(
                fontSize: 10.5,
                fontWeight: FontWeight.w900,
                color: Color(0xFF2E2E3A),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
