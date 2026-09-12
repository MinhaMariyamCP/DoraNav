import 'package:flutter/material.dart';
import '../../../themes/app_theme.dart';

/// Top App Bar matching the reference UI:
/// - Hamburger menu icon
/// - "DORA NAV" bilingual title
/// - Search input bar ("Where do you want to go?")
/// - "Swiper Alert" status indicator badge
class MapTopBar extends StatelessWidget {
  final VoidCallback? onMenuPressed;
  final ValueChanged<String>? onSearchChanged;
  final VoidCallback? onSearchTap;
  final VoidCallback? onSwiperAlertTap;
  final String swiperRiskLevel; // 'Low Risk', 'High Risk'

  const MapTopBar({
    super.key,
    this.onMenuPressed,
    this.onSearchChanged,
    this.onSearchTap,
    this.onSwiperAlertTap,
    this.swiperRiskLevel = 'Low Risk',
  });

  @override
  Widget build(BuildContext context) {
    final isHighRisk = swiperRiskLevel.toLowerCase().contains('high');

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10.0, vertical: 6.0),
      decoration: BoxDecoration(
        color: const Color(0xFF4A156D).withValues(alpha: 0.95), // Deep purple banner
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.35),
            blurRadius: 8,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      child: SafeArea(
        bottom: false,
        child: Row(
          children: [
            // 1. Hamburger menu button
            IconButton(
              icon: const Icon(Icons.menu_rounded, color: Colors.white, size: 26),
              onPressed: onMenuPressed,
              tooltip: 'Open Menu',
              padding: EdgeInsets.zero,
              constraints: const BoxConstraints(),
            ),
            const SizedBox(width: 8),

            // 2. Bilingual App Branding
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: const [
                Text(
                  'DORA NAV',
                  style: TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.w900,
                    fontSize: 16,
                    letterSpacing: 0.5,
                  ),
                ),
                Text(
                  'ഡോറയുടെ വഴികാട്ടി',
                  style: TextStyle(
                    color: Color(0xFFE1BEE7),
                    fontSize: 10,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ],
            ),
            const SizedBox(width: 10),

            // 3. Search Bar ("Where do you want to go?")
            Expanded(
              child: GestureDetector(
                onTap: onSearchTap,
                child: Container(
                  height: 38,
                  padding: const EdgeInsets.symmetric(horizontal: 10),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(20),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withValues(alpha: 0.15),
                        blurRadius: 4,
                        offset: const Offset(0, 1),
                      ),
                    ],
                  ),
                  child: Row(
                    children: [
                      const Icon(Icons.search_rounded, color: Color(0xFF757575), size: 20),
                      const SizedBox(width: 6),
                      const Expanded(
                        child: Text(
                          'Where do you want to go?',
                          style: TextStyle(
                            color: Color(0xFF757575),
                            fontSize: 12,
                            fontWeight: FontWeight.w500,
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                      Icon(
                        Icons.mic_rounded,
                        color: AppColors.deepPurple,
                        size: 18,
                      ),
                    ],
                  ),
                ),
              ),
            ),
            const SizedBox(width: 8),

            // 4. Swiper Alert Pill
            InkWell(
              onTap: onSwiperAlertTap,
              borderRadius: BorderRadius.circular(20),
              child: Container(
                padding: const EdgeInsets.only(left: 8, right: 2, top: 3, bottom: 3),
                decoration: BoxDecoration(
                  color: const Color(0xFF381358),
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(
                    color: isHighRisk ? Colors.redAccent : const Color(0xFF8E24AA),
                    width: 1.2,
                  ),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.end,
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        const Text(
                          'Swiper Alert',
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 9,
                            fontWeight: FontWeight.w800,
                          ),
                        ),
                        Text(
                          swiperRiskLevel,
                          style: TextStyle(
                            color: isHighRisk ? const Color(0xFFFF5252) : const Color(0xFF81C784),
                            fontSize: 8,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(width: 4),
                    // Swiper Avatar Circle
                    Container(
                      width: 30,
                      height: 30,
                      decoration: const BoxDecoration(
                        shape: BoxShape.circle,
                        color: Color(0xFFFFCC80),
                      ),
                      clipBehavior: Clip.antiAlias,
                      child: Image.asset(
                        'assets/images/swiper_badge.png',
                        fit: BoxFit.cover,
                        errorBuilder: (context, error, stackTrace) => const Icon(
                          Icons.warning_amber_rounded,
                          color: AppColors.doraOrange,
                          size: 18,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
