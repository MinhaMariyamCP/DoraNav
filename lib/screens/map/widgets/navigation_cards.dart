import 'package:flutter/material.dart';
import '../models/map_models.dart';
import 'destination_visual_modal.dart';

/// Navigation Information Cards matching the reference layout:
/// - Destination Card (thumbnail, name, description, Navigate button)
/// - Direction Instruction Card (arrow, "Continue straight towards...")
/// - Swiper Alert Card (warning message, "View Alternative" action)
/// - Trip Stats Box (ETA, Distance)
class NavigationCardsRow extends StatelessWidget {
  final NavigationRoute? route;
  final LocationNode destination;
  final bool isSwiperAhead;
  final VoidCallback? onNavigatePressed;
  final VoidCallback? onViewAlternativePressed;

  const NavigationCardsRow({
    super.key,
    required this.route,
    required this.destination,
    this.isSwiperAhead = true,
    this.onNavigatePressed,
    this.onViewAlternativePressed,
  });

  @override
  Widget build(BuildContext context) {
    final distKm = route?.totalDistance ?? 2.8;
    final etaMin = route?.etaMinutes ?? 12;

    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          // 1. Destination Overview Card
          _buildDestinationCard(context, distKm, etaMin),
          const SizedBox(width: 8),

          // 2. Turn-by-Turn Direction Card
          _buildTurnInstructionCard(),
          const SizedBox(width: 8),

          // 3. Swiper Alert Card (if hazard is on route)
          if (isSwiperAhead) ...[
            _buildSwiperAlertCard(),
            const SizedBox(width: 8),
          ],

          // 4. Quick ETA & Distance Stats Card
          _buildStatsCard(distKm, etaMin),
        ],
      ),
    );
  }

  Widget _buildDestinationCard(BuildContext context, double distKm, int etaMin) {
    return GestureDetector(
      onTap: () {
        DestinationVisualModal.show(
          context,
          location: destination,
          onStartRoute: onNavigatePressed,
        );
      },
      child: Container(
        width: 215,
        padding: const EdgeInsets.all(10),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.12),
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
              children: [
                // Destination Thumbnail (Tap to expand photo)
                Hero(
                  tag: 'dest_thumb_${destination.id}',
                  child: Container(
                    width: 44,
                    height: 44,
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(10),
                      color: const Color(0xFFEDE7F6),
                      border: Border.all(color: const Color(0xFFFFD54F), width: 1.2),
                    ),
                    clipBehavior: Clip.antiAlias,
                    child: Stack(
                      alignment: Alignment.center,
                      children: [
                        Image.asset(
                          'assets/images/castle_thumb.png',
                          fit: BoxFit.cover,
                          errorBuilder: (context, error, stackTrace) => const Icon(
                            Icons.landscape_rounded,
                            color: Color(0xFF7E57C2),
                            size: 26,
                          ),
                        ),
                        Positioned(
                          right: 2,
                          bottom: 2,
                          child: Container(
                            padding: const EdgeInsets.all(1.5),
                            decoration: const BoxDecoration(
                              color: Colors.black87,
                              shape: BoxShape.circle,
                            ),
                            child: const Icon(Icons.fullscreen_rounded, color: Colors.white, size: 10),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              const SizedBox(width: 8),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      destination.name,
                      style: const TextStyle(
                        fontWeight: FontWeight.w900,
                        fontSize: 13,
                        color: Color(0xFF212121),
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: 2),
                    Text(
                      destination.description.isNotEmpty
                          ? destination.description
                          : "A magical location in Dora's World!",
                      style: const TextStyle(
                        fontSize: 9.5,
                        color: Color(0xFF757575),
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 6),
          // Route Stats Chips Row
          Row(
            children: [
              const Icon(Icons.location_on, size: 11, color: Color(0xFF7E57C2)),
              const SizedBox(width: 2),
              Text(
                '$distKm km',
                style: const TextStyle(fontSize: 9.5, fontWeight: FontWeight.w700, color: Color(0xFF424242)),
              ),
              const SizedBox(width: 6),
              const Icon(Icons.timer_rounded, size: 11, color: Color(0xFF7E57C2)),
              const SizedBox(width: 2),
              Text(
                '$etaMin min',
                style: const TextStyle(fontSize: 9.5, fontWeight: FontWeight.w700, color: Color(0xFF424242)),
              ),
              const SizedBox(width: 6),
              const Icon(Icons.shield_rounded, size: 11, color: Color(0xFF4CAF50)),
              const SizedBox(width: 2),
              const Text(
                'Low Risk',
                style: TextStyle(fontSize: 9.5, fontWeight: FontWeight.w700, color: Color(0xFF4CAF50)),
              ),
            ],
          ),
          const SizedBox(height: 8),
          // Navigate Button
          SizedBox(
            width: double.infinity,
            height: 32,
            child: ElevatedButton(
              onPressed: onNavigatePressed,
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF7E57C2),
                foregroundColor: Colors.white,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                padding: EdgeInsets.zero,
                elevation: 2,
              ),
              child: const Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    'Navigate',
                    style: TextStyle(fontSize: 12, fontWeight: FontWeight.w800),
                  ),
                  SizedBox(width: 4),
                  Icon(Icons.play_arrow_rounded, size: 16),
                ],
              ),
            ),
          ),
        ],
      ),
    ),
  );
}

  Widget _buildTurnInstructionCard() {
    final instruction = route?.nextInstruction ?? 'Continue straight';
    final meters = route?.nextDistanceMeters.toInt() ?? 350;

    return Container(
      width: 175,
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.12),
            blurRadius: 6,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Row(
        children: [
          // Arrow Circle
          Container(
            width: 40,
            height: 40,
            decoration: const BoxDecoration(
              color: Color(0xFF7E57C2),
              shape: BoxShape.circle,
            ),
            child: const Icon(
              Icons.arrow_upward_rounded,
              color: Colors.white,
              size: 24,
            ),
          ),
          const SizedBox(width: 8),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                const Text(
                  'Continue straight',
                  style: TextStyle(
                    fontWeight: FontWeight.w900,
                    fontSize: 11.5,
                    color: Color(0xFF212121),
                  ),
                ),
                Text(
                  instruction.replaceFirst('Continue straight ', ''),
                  style: const TextStyle(
                    fontSize: 9.5,
                    color: Color(0xFF616161),
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
                const SizedBox(height: 4),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                  decoration: BoxDecoration(
                    color: const Color(0xFFEDE7F6),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Text(
                    '$meters m',
                    style: const TextStyle(
                      fontSize: 10,
                      fontWeight: FontWeight.w900,
                      color: Color(0xFF5E35B1),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSwiperAlertCard() {
    return Container(
      width: 165,
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: const Color(0xFFFF8A80), width: 1.2),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.12),
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
            children: [
              Container(
                width: 32,
                height: 32,
                clipBehavior: Clip.antiAlias,
                decoration: const BoxDecoration(shape: BoxShape.circle),
                child: Image.asset(
                  'assets/images/swiper_warning.png',
                  fit: BoxFit.cover,
                  errorBuilder: (context, error, stackTrace) => const Icon(
                    Icons.warning_rounded,
                    color: Colors.orange,
                    size: 24,
                  ),
                ),
              ),
              const SizedBox(width: 6),
              const Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Swiper is ahead!',
                      style: TextStyle(
                        fontWeight: FontWeight.w900,
                        fontSize: 10.5,
                        color: Color(0xFFD32F2F),
                      ),
                    ),
                    Text(
                      'He might block route.',
                      style: TextStyle(
                        fontSize: 8.5,
                        color: Color(0xFF757575),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 6),
          SizedBox(
            width: double.infinity,
            height: 26,
            child: OutlinedButton(
              onPressed: onViewAlternativePressed,
              style: OutlinedButton.styleFrom(
                side: const BorderSide(color: Color(0xFF7E57C2), width: 1.2),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                padding: EdgeInsets.zero,
              ),
              child: const Text(
                'View Alternative',
                style: TextStyle(
                  fontSize: 10,
                  fontWeight: FontWeight.w800,
                  color: Color(0xFF7E57C2),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStatsCard(double distKm, int etaMin) {
    return Container(
      width: 90,
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 10),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.12),
            blurRadius: 6,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          const Text(
            'ETA',
            style: TextStyle(fontSize: 9, color: Color(0xFF757575), fontWeight: FontWeight.w700),
          ),
          Text(
            '$etaMin min',
            style: const TextStyle(
              fontSize: 13,
              fontWeight: FontWeight.w900,
              color: Color(0xFF212121),
            ),
          ),
          const Divider(height: 8),
          const Text(
            'Distance',
            style: TextStyle(fontSize: 9, color: Color(0xFF757575), fontWeight: FontWeight.w700),
          ),
          Text(
            '$distKm km',
            style: const TextStyle(
              fontSize: 13,
              fontWeight: FontWeight.w900,
              color: Color(0xFF212121),
            ),
          ),
        ],
      ),
    );
  }
}
