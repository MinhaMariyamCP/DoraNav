import 'package:flutter/material.dart';
import '../models/trip_data.dart';

/// 2x3 Grid rendering core adventure statistics:
/// 1. Distance Traveled (km)
/// 2. Turns Taken
/// 3. Bridges Crossed
/// 4. Animals Met
/// 5. Swiper Encounters (highlighted if >0)
/// 6. Backpack Items Used
class StatsGridCard extends StatelessWidget {
  final TripData trip;

  const StatsGridCard({super.key, required this.trip});

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 14),
      padding: const EdgeInsets.fromLTRB(16, 14, 16, 16),
      decoration: BoxDecoration(
        color: const Color(0xFFF7F2FA), // Lavender tint card
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: const Color(0xFFEADDFF), width: 1.5),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.08),
            blurRadius: 10,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          // Section Title
          const Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text('✦', style: TextStyle(color: Color(0xFF7E57C2), fontSize: 12)),
              SizedBox(width: 6),
              Text(
                'Your Adventure Report',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w900,
                  color: Color(0xFF4A148C),
                  letterSpacing: -0.2,
                ),
              ),
              SizedBox(width: 6),
              Text('✦', style: TextStyle(color: Color(0xFF7E57C2), fontSize: 12)),
            ],
          ),
          const SizedBox(height: 12),

          // Row 1: Distance, Turns, Bridges
          Row(
            children: [
              Expanded(
                child: _buildStatItem(
                  iconEmoji: '📍',
                  iconBg: const Color(0xFFE3F2FD),
                  label: 'Distance Traveled',
                  value: '${trip.distanceKm} km',
                  valueColor: const Color(0xFF1565C0),
                ),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: _buildStatItem(
                  iconEmoji: '↪️',
                  iconBg: const Color(0xFFE8F5E9),
                  label: 'Turns Taken',
                  value: '${trip.turnsTaken}',
                  valueColor: const Color(0xFF2E7D32),
                ),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: _buildStatItem(
                  iconEmoji: '🌉',
                  iconBg: const Color(0xFFE0F7FA),
                  label: 'Bridges Crossed',
                  value: '${trip.bridgesCrossed}',
                  valueColor: const Color(0xFF00838F),
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),

          // Row 2: Animals Met, Swiper Encounters, Backpack Items Used
          Row(
            children: [
              Expanded(
                child: _buildStatItem(
                  iconEmoji: '🐾',
                  iconBg: const Color(0xFFFFF3E0),
                  label: 'Animals Met',
                  value: '${trip.animalsMet}',
                  valueColor: const Color(0xFFE65100),
                ),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: _buildStatItem(
                  iconEmoji: '🦊',
                  iconBg: trip.swiperEncounters > 0
                      ? const Color(0xFFFFEBEE)
                      : const Color(0xFFF5F5F5),
                  label: 'Swiper Encounters',
                  value: '${trip.swiperEncounters}',
                  valueColor: trip.swiperEncounters > 0
                      ? const Color(0xFFC62828)
                      : const Color(0xFF757575),
                  isAlert: trip.swiperEncounters > 0,
                ),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: _buildStatItem(
                  iconEmoji: '🎒',
                  iconBg: const Color(0xFFEDE7F6),
                  label: 'Backpack Items Used',
                  value: '${trip.backpackItemsUsed} times',
                  valueColor: const Color(0xFF5E35B1),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildStatItem({
    required String iconEmoji,
    required Color iconBg,
    required String label,
    required String value,
    required Color valueColor,
    bool isAlert = false,
  }) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 10),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: isAlert ? const Color(0xFFFFCDD2) : const Color(0xFFE2E8F0),
          width: isAlert ? 1.5 : 1.0,
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.04),
            blurRadius: 4,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                width: 32,
                height: 32,
                decoration: BoxDecoration(
                  color: iconBg,
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Center(
                  child: Text(iconEmoji, style: const TextStyle(fontSize: 18)),
                ),
              ),
              const SizedBox(width: 6),
              Expanded(
                child: Text(
                  label,
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(
                    fontSize: 9.5,
                    fontWeight: FontWeight.w600,
                    color: Colors.grey.shade700,
                    height: 1.15,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Padding(
            padding: const EdgeInsets.only(left: 4),
            child: Text(
              value,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: TextStyle(
                fontSize: 15,
                fontWeight: FontWeight.w900,
                color: valueColor,
                letterSpacing: -0.2,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
