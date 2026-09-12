import 'package:flutter/material.dart';
import '../../map/models/map_models.dart';

/// Interactive Kid-Friendly "Swiper Detected!" Modal Dialog Widget
///
/// Matches the high-fidelity UI design spec:
/// - Rounded card (24px radius), soft shadows
/// - Coral warning header (#FF4D6D) with ⚠️ icon and circular close button
/// - Fox warning illustration / avatar with dynamic distance text
/// - Animated sequential loading dots ("Recalculating a safer path...")
/// - Mini map preview with red blocked route vs solid purple recalculated detour
/// - Primary "View New Route" (#7B61FF) and Secondary "Continue" action buttons
class SwiperDetectedModal extends StatefulWidget {
  final String distanceText;
  final String currentRouteName;
  final String newRouteName;
  final String swiperLocationName;
  final NavigationRoute? originalRoute;
  final NavigationRoute? reroutedRoute;
  final NavigationRouteStatus routeStatus;
  final VoidCallback? onViewNewRoute;
  final VoidCallback? onContinueOriginalRoute;
  final VoidCallback? onClose;

  const SwiperDetectedModal({
    super.key,
    this.distanceText = '200m',
    this.currentRouteName = 'Current Route',
    this.newRouteName = 'Swiper-Safe Detour',
    this.swiperLocationName = 'Upcoming Waypoint',
    this.originalRoute,
    this.reroutedRoute,
    this.routeStatus = NavigationRouteStatus.rerouted,
    this.onViewNewRoute,
    this.onContinueOriginalRoute,
    this.onClose,
  });

  /// Static helper to display modal dialog easily
  static Future<T?> show<T>({
    required BuildContext context,
    String distanceText = '200m',
    String currentRouteName = 'Rainbow Bridge',
    String newRouteName = 'Safe A* Detour',
    String swiperLocationName = 'Bridge',
    NavigationRoute? originalRoute,
    NavigationRoute? reroutedRoute,
    NavigationRouteStatus routeStatus = NavigationRouteStatus.rerouted,
    VoidCallback? onViewNewRoute,
    VoidCallback? onContinueOriginalRoute,
  }) {
    return showDialog<T>(
      context: context,
      barrierDismissible: true,
      barrierColor: Colors.black.withValues(alpha: 0.45),
      builder: (ctx) => SwiperDetectedModal(
        distanceText: distanceText,
        currentRouteName: currentRouteName,
        newRouteName: newRouteName,
        swiperLocationName: swiperLocationName,
        originalRoute: originalRoute,
        reroutedRoute: reroutedRoute,
        routeStatus: routeStatus,
        onViewNewRoute: () {
          Navigator.of(ctx).pop();
          onViewNewRoute?.call();
        },
        onContinueOriginalRoute: () {
          Navigator.of(ctx).pop();
          onContinueOriginalRoute?.call();
        },
        onClose: () => Navigator.of(ctx).pop(),
      ),
    );
  }

  @override
  State<SwiperDetectedModal> createState() => _SwiperDetectedModalState();
}

class _SwiperDetectedModalState extends State<SwiperDetectedModal>
    with SingleTickerProviderStateMixin {
  late AnimationController _dotController;

  @override
  void initState() {
    super.initState();
    _dotController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 900),
    )..repeat();
  }

  @override
  void dispose() {
    _dotController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Dialog(
      backgroundColor: Colors.transparent,
      insetPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 24),
      child: Container(
        constraints: const BoxConstraints(maxWidth: 380),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(24),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.18),
              blurRadius: 20,
              offset: const Offset(0, 10),
            ),
          ],
        ),
        clipBehavior: Clip.antiAlias,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // 1. Header Bar (#FF4D6D Coral Pink)
            _buildHeader(context),

            // 2. Body Content
            Padding(
              padding: const EdgeInsets.fromLTRB(20, 18, 20, 20),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  // Row: Fox Avatar & Warning description
                  _buildWarningRow(),

                  const SizedBox(height: 16),

                  // Mini Map Canvas Preview (Blocked Path vs Recalculated Detour)
                  _buildMiniMapPreview(),

                  const SizedBox(height: 20),

                  // Primary Button: "View New Route"
                  _buildPrimaryButton(context),

                  const SizedBox(height: 10),

                  // Secondary Button: "Continue" (Outlined)
                  _buildSecondaryButton(context),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildHeader(BuildContext context) {
    return Container(
      color: const Color(0xFFFF4D6D),
      padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 14),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          const Row(
            children: [
              Text('⚠️', style: TextStyle(fontSize: 22)),
              SizedBox(width: 8),
              Text(
                'Swiper Detected!',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 19,
                  fontWeight: FontWeight.w900,
                  letterSpacing: 0.2,
                ),
              ),
            ],
          ),
          // Circular Close 'X' Button
          InkWell(
            onTap: widget.onClose ?? () => Navigator.of(context).pop(),
            borderRadius: BorderRadius.circular(16),
            child: Container(
              width: 32,
              height: 32,
              decoration: BoxDecoration(
                color: Colors.white.withValues(alpha: 0.25),
                shape: BoxShape.circle,
              ),
              child: const Icon(
                Icons.close_rounded,
                color: Colors.white,
                size: 20,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildWarningRow() {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Fox Character Illustration Card
        Container(
          width: 68,
          height: 68,
          decoration: BoxDecoration(
            color: const Color(0xFFFFF3E0),
            borderRadius: BorderRadius.circular(18),
            border: Border.all(color: const Color(0xFFFFB74D), width: 1.5),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: 0.05),
                blurRadius: 6,
                offset: const Offset(0, 2),
              ),
            ],
          ),
          child: const Center(
            child: Text(
              '🦊',
              style: TextStyle(fontSize: 38),
            ),
          ),
        ),
        const SizedBox(width: 14),
        // Warning & recalculating text
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              if (widget.routeStatus == NavigationRouteStatus.noAlternativeRoute ||
                  widget.reroutedRoute == null) ...[
                const Text(
                  'Swiper has blocked every route!',
                  style: TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w900,
                    color: Color(0xFFC62828),
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  'No alternative path to destination exists without passing through ${widget.swiperLocationName}.',
                  style: const TextStyle(fontSize: 11, color: Color(0xFF555555)),
                ),
              ] else ...[
                RichText(
                  text: TextSpan(
                    style: const TextStyle(
                      fontSize: 13,
                      color: Color(0xFF2E2E3A),
                      fontWeight: FontWeight.w600,
                      height: 1.3,
                    ),
                    children: [
                      const TextSpan(text: 'Swiper is blocking '),
                      TextSpan(
                        text: widget.swiperLocationName,
                        style: const TextStyle(
                          fontWeight: FontWeight.w900,
                          color: Color(0xFFFF4D6D),
                        ),
                      ),
                      TextSpan(text: ' (${widget.distanceText} ahead)!'),
                    ],
                  ),
                ),
                const SizedBox(height: 6),
                if (widget.routeStatus == NavigationRouteStatus.rerouting)
                  Row(
                    children: [
                      const Text(
                        'A* recalculating a safer path',
                        style: TextStyle(
                          fontSize: 11.5,
                          fontWeight: FontWeight.w700,
                          color: Color(0xFF7B61FF),
                        ),
                      ),
                      const SizedBox(width: 4),
                      AnimatedBuilder(
                        animation: _dotController,
                        builder: (context, _) {
                          final val = (_dotController.value * 3).floor() % 3;
                          final dots = '.' * (val + 1);
                          return Text(
                            dots,
                            style: const TextStyle(
                              fontSize: 14,
                              fontWeight: FontWeight.w900,
                              color: Color(0xFF7B61FF),
                            ),
                          );
                        },
                      ),
                    ],
                  )
                else ...[
                  Text(
                    'A* Found Safe Detour! ✨ (${widget.reroutedRoute!.totalDistance} km • ${widget.reroutedRoute!.etaMinutes} min)',
                    style: const TextStyle(
                      fontSize: 11.5,
                      fontWeight: FontWeight.w800,
                      color: Color(0xFF2E7D32),
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    'Detour: ${widget.reroutedRoute!.nodes.map((n) => n.name).join(" ➔ ")}',
                    style: const TextStyle(fontSize: 10.5, color: Color(0xFF5E35B1), fontWeight: FontWeight.w600),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                ],
              ],
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildMiniMapPreview() {
    return Container(
      height: 130,
      decoration: BoxDecoration(
        color: const Color(0xFFF0F4F8),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: const Color(0xFFE2E8F0), width: 1.5),
      ),
      clipBehavior: Clip.antiAlias,
      child: Stack(
        children: [
          // Background soft pasture/map grid
          CustomPaint(
            size: const Size(double.infinity, 130),
            painter: _MiniMapPainter(),
          ),

          // Start & End markers & Swiper danger badge
          Positioned(
            left: 14,
            bottom: 16,
            child: _buildMapPin('You', const Color(0xFF7B61FF), Icons.person_pin_circle),
          ),
          Positioned(
            right: 14,
            top: 14,
            child: _buildMapPin('Goal', const Color(0xFFFFD54F), Icons.star_rounded),
          ),
          Positioned(
            left: 120,
            top: 36,
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
              decoration: BoxDecoration(
                color: const Color(0xFFFFEBEE),
                borderRadius: BorderRadius.circular(8),
                border: Border.all(color: const Color(0xFFFF4D6D)),
              ),
              child: const Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text('🦊', style: TextStyle(fontSize: 11)),
                  SizedBox(width: 3),
                  Text(
                    'Blocked',
                    style: TextStyle(
                      fontSize: 9,
                      fontWeight: FontWeight.w900,
                      color: Color(0xFFFF4D6D),
                    ),
                  ),
                ],
              ),
            ),
          ),
          Positioned(
            right: 16,
            bottom: 12,
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
              decoration: BoxDecoration(
                color: const Color(0xFFEDE7F6),
                borderRadius: BorderRadius.circular(10),
                border: Border.all(color: const Color(0xFF7B61FF)),
              ),
              child: const Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(Icons.directions_rounded, size: 12, color: Color(0xFF7B61FF)),
                  SizedBox(width: 4),
                  Text(
                    'Safe Detour ✨',
                    style: TextStyle(
                      fontSize: 10,
                      fontWeight: FontWeight.w800,
                      color: Color(0xFF7B61FF),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildMapPin(String label, Color color, IconData icon) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(icon, color: color, size: 24),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(8),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: 0.1),
                blurRadius: 4,
              ),
            ],
          ),
          child: Text(
            label,
            style: TextStyle(
              fontSize: 9,
              fontWeight: FontWeight.w900,
              color: color == const Color(0xFFFFD54F) ? const Color(0xFFE65100) : color,
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildPrimaryButton(BuildContext context) {
    final hasNoAlternative = widget.routeStatus == NavigationRouteStatus.noAlternativeRoute ||
        widget.reroutedRoute == null;

    return SizedBox(
      height: 50,
      child: ElevatedButton(
        onPressed: hasNoAlternative ? null : (widget.onViewNewRoute ?? () => Navigator.of(context).pop()),
        style: ElevatedButton.styleFrom(
          backgroundColor: const Color(0xFF7B61FF),
          foregroundColor: Colors.white,
          elevation: 2,
          shadowColor: const Color(0xFF7B61FF).withValues(alpha: 0.4),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(
              hasNoAlternative ? 'No Alternative Route' : 'Take New A* Route ✨',
              style: const TextStyle(
                fontSize: 15,
                fontWeight: FontWeight.w800,
                letterSpacing: 0.2,
              ),
            ),
            const SizedBox(width: 8),
            const Icon(Icons.arrow_forward_rounded, size: 18),
          ],
        ),
      ),
    );
  }

  Widget _buildSecondaryButton(BuildContext context) {
    return SizedBox(
      height: 48,
      child: OutlinedButton(
        onPressed: widget.onContinueOriginalRoute ?? () => Navigator.of(context).pop(),
        style: OutlinedButton.styleFrom(
          foregroundColor: const Color(0xFF7B61FF),
          side: const BorderSide(color: Color(0xFF7B61FF), width: 1.5),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
        ),
        child: const Text(
          'Continue',
          style: TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.w800,
          ),
        ),
      ),
    );
  }
}

/// Custom painter rendering the blocked vs recalculated route path in mini preview
class _MiniMapPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    // 1. Blocked path (Red dashed arc towards top center)
    final blockedPaint = Paint()
      ..color = const Color(0xFFFF4D6D).withValues(alpha: 0.7)
      ..strokeWidth = 3.5
      ..style = PaintingStyle.stroke;

    final blockedPath = Path()
      ..moveTo(size.width * 0.15, size.height * 0.7)
      ..quadraticBezierTo(
        size.width * 0.35,
        size.height * 0.3,
        size.width * 0.55,
        size.height * 0.35,
      );

    // Draw dashed path for blocked line
    _drawDashedPath(canvas, blockedPath, blockedPaint, [6, 4]);

    // 2. Safe recalculated detour (Vibrant solid purple smooth arc)
    final safePaint = Paint()
      ..color = const Color(0xFF7B61FF)
      ..strokeWidth = 4.0
      ..strokeCap = StrokeCap.round
      ..style = PaintingStyle.stroke;

    final safePath = Path()
      ..moveTo(size.width * 0.15, size.height * 0.7)
      ..cubicTo(
        size.width * 0.25,
        size.height * 0.9,
        size.width * 0.65,
        size.height * 0.85,
        size.width * 0.88,
        size.height * 0.25,
      );

    canvas.drawPath(safePath, safePaint);
  }

  void _drawDashedPath(Canvas canvas, Path path, Paint paint, List<double> dashPattern) {
    final metrics = path.computeMetrics();
    for (final metric in metrics) {
      double distance = 0.0;
      int index = 0;
      while (distance < metric.length) {
        final length = dashPattern[index % dashPattern.length];
        if (index % 2 == 0) {
          final extractPath = metric.extractPath(distance, distance + length);
          canvas.drawPath(extractPath, paint);
        }
        distance += length;
        index++;
      }
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
