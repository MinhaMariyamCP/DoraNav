import 'package:flutter/material.dart';
import '../map/models/map_models.dart';
import '../map/services/pathfinder_service.dart';
import '../navigation/active_navigation_screen.dart';
import 'models/route_selection_models.dart';
import 'services/route_recommendation_engine.dart';

/// Interactive "Choose Your Route" Screen matching the approved design.
/// Lets kids select Dora's Mood & Adventure Level, dynamically computes 4 tailored routes,
/// highlights the recommended one, and transitions directly into active navigation.
class ChooseYourRouteScreen extends StatefulWidget {
  final LocationNode startLocation;
  final LocationNode destination;
  final PathfinderService pathfinder;
  final DoraMood initialMood;
  final AdventureLevel initialLevel;
  final bool isModal;

  const ChooseYourRouteScreen({
    super.key,
    required this.startLocation,
    required this.destination,
    required this.pathfinder,
    this.initialMood = DoraMood.happy,
    this.initialLevel = AdventureLevel.adventurous,
    this.isModal = false,
  });

  @override
  State<ChooseYourRouteScreen> createState() => _ChooseYourRouteScreenState();
}

class _ChooseYourRouteScreenState extends State<ChooseYourRouteScreen> {
  late RouteRecommendationEngine _engine;
  late DoraMood _selectedMood;
  late AdventureLevel _selectedLevel;
  late List<RouteOption> _routes;
  late RouteOption _selectedRoute;

  @override
  void initState() {
    super.initState();
    _engine = RouteRecommendationEngine(widget.pathfinder);
    _selectedMood = widget.initialMood;
    _selectedLevel = widget.initialLevel;
    _refreshRoutes();
  }

  void _refreshRoutes() {
    _routes = _engine.generateOptions(
      start: widget.startLocation,
      destination: widget.destination,
      mood: _selectedMood,
      adventureLevel: _selectedLevel,
    );
    // Default selection is the top recommended route
    _selectedRoute = _routes.first;
  }

  void _onMoodSelected(DoraMood mood) {
    setState(() {
      _selectedMood = mood;
      _refreshRoutes();
    });
  }

  void _onLevelSelected(AdventureLevel level) {
    setState(() {
      _selectedLevel = level;
      _refreshRoutes();
    });
  }

  void _onConfirmAdventure() {
    final calculatedRoute = widget.pathfinder.findRoute(
      startId: widget.startLocation.id,
      goalId: widget.destination.id,
      customBlockedNodes: _selectedRoute.blockedNodes,
      isAlternative: _selectedRoute.type == RouteOptionType.swiperSafe,
    );

    if (widget.isModal) {
      Navigator.of(context).pop({
        'selectedOption': _selectedRoute,
        'navigationRoute': calculatedRoute,
        'mood': _selectedMood,
        'adventureLevel': _selectedLevel,
      });
    } else {
      final navRoute = calculatedRoute ??
          NavigationRoute(
            nodes: [widget.startLocation, widget.destination],
            totalDistance: _selectedRoute.distanceKm,
            etaMinutes: _selectedRoute.etaMinutes,
            nextInstruction: 'Follow trail to ${widget.destination.name}',
            nextDistanceMeters: 250,
          );

      Navigator.of(context).pushReplacement(
        MaterialPageRoute(
          builder: (_) => ActiveNavigationScreen(
            startLocation: widget.startLocation,
            destination: widget.destination,
            routeOption: _selectedRoute,
            navigationRoute: navRoute,
            mood: _selectedMood,
            adventureLevel: _selectedLevel,
            pathfinder: widget.pathfinder,
          ),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF6F4FF),
      body: SafeArea(
        child: Column(
          children: [
            // 1. Top Header Bar with wave & back button
            _buildHeader(),

            // 2. Scrollable Body: Selectors & Route Cards
            Expanded(
              child: ListView(
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                children: [
                  // Mood Selector & Adventure Level
                  _buildMoodSelector(),
                  const SizedBox(height: 12),
                  _buildAdventureLevelSelector(),
                  const SizedBox(height: 14),

                  // Dynamic Banner
                  _buildRecommendationBanner(),
                  const SizedBox(height: 14),

                  // Route Cards
                  ..._routes.map((route) => _buildRouteCard(route)),
                  const SizedBox(height: 12),

                  // Info footnote
                  _buildFootnote(),
                  const SizedBox(height: 16),
                ],
              ),
            ),

            // 3. Primary CTA: Start Adventure!
            _buildStartAdventureButton(),
          ],
        ),
      ),
    );
  }

  Widget _buildHeader() {
    return Container(
      padding: const EdgeInsets.fromLTRB(12, 8, 16, 12),
      decoration: const BoxDecoration(
        color: Color(0xFF8A6CF6),
        borderRadius: BorderRadius.vertical(bottom: Radius.circular(24)),
      ),
      child: Row(
        children: [
          IconButton(
            icon: const Icon(Icons.arrow_back_ios_new_rounded, color: Colors.white, size: 20),
            onPressed: () => Navigator.of(context).pop(),
          ),
          const SizedBox(width: 4),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                const Text(
                  'Choose Your Route',
                  style: TextStyle(
                    fontSize: 22,
                    fontWeight: FontWeight.w900,
                    color: Colors.white,
                  ),
                ),
                Text(
                  'Dora\'s adventure suggestions for ${widget.destination.name} ✨',
                  style: TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.w600,
                    color: Colors.white.withValues(alpha: 0.9),
                  ),
                ),
              ],
            ),
          ),
          // Cheerful Dora Face Token
          Container(
            padding: const EdgeInsets.all(3),
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: Colors.white,
              border: Border.all(color: const Color(0xFFFFD54F), width: 2),
            ),
            child: const CircleAvatar(
              radius: 18,
              backgroundColor: Color(0xFFFFCC80),
              child: Text('👧', style: TextStyle(fontSize: 18)),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildMoodSelector() {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: const Color(0xFFE5DEFC)),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFF5E35B1).withValues(alpha: 0.05),
            blurRadius: 10,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Row(
            children: [
              Text('Dora\'s Mood Today', style: TextStyle(fontSize: 13, fontWeight: FontWeight.w900, color: Color(0xFF2A1D40))),
              SizedBox(width: 4),
              Icon(Icons.help_outline_rounded, size: 14, color: Color(0xFF8A6CF6)),
            ],
          ),
          const SizedBox(height: 8),
          SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            child: Row(
              children: DoraMood.values.map((mood) {
                final isSelected = mood == _selectedMood;
                return Padding(
                  padding: const EdgeInsets.only(right: 8),
                  child: InkWell(
                    onTap: () => _onMoodSelected(mood),
                    borderRadius: BorderRadius.circular(20),
                    child: AnimatedContainer(
                      duration: const Duration(milliseconds: 200),
                      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                      decoration: BoxDecoration(
                        color: isSelected ? const Color(0xFF8A6CF6) : const Color(0xFFF6F4FF),
                        borderRadius: BorderRadius.circular(20),
                        border: Border.all(
                          color: isSelected ? const Color(0xFF8A6CF6) : const Color(0xFFE5DEFC),
                          width: 1.5,
                        ),
                      ),
                      child: Row(
                        children: [
                          Text(mood.emoji, style: const TextStyle(fontSize: 15)),
                          const SizedBox(width: 5),
                          Text(
                            mood.label,
                            style: TextStyle(
                              fontSize: 12,
                              fontWeight: isSelected ? FontWeight.w900 : FontWeight.w700,
                              color: isSelected ? Colors.white : const Color(0xFF2A1D40),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                );
              }).toList(),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildAdventureLevelSelector() {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: const Color(0xFFE5DEFC)),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFF5E35B1).withValues(alpha: 0.05),
            blurRadius: 10,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Row(
            children: [
              Text('Adventure Level', style: TextStyle(fontSize: 13, fontWeight: FontWeight.w900, color: Color(0xFF2A1D40))),
              SizedBox(width: 4),
              Icon(Icons.help_outline_rounded, size: 14, color: Color(0xFF8A6CF6)),
            ],
          ),
          const SizedBox(height: 8),
          Row(
            children: AdventureLevel.values.map((lvl) {
              final isSelected = lvl == _selectedLevel;
              return Expanded(
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 3),
                  child: InkWell(
                    onTap: () => _onLevelSelected(lvl),
                    borderRadius: BorderRadius.circular(16),
                    child: AnimatedContainer(
                      duration: const Duration(milliseconds: 200),
                      padding: const EdgeInsets.symmetric(vertical: 8),
                      decoration: BoxDecoration(
                        color: isSelected ? const Color(0xFF8A6CF6) : const Color(0xFFF6F4FF),
                        borderRadius: BorderRadius.circular(16),
                        border: Border.all(
                          color: isSelected ? const Color(0xFF8A6CF6) : const Color(0xFFE5DEFC),
                          width: 1.5,
                        ),
                      ),
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Text(lvl.emoji, style: const TextStyle(fontSize: 14)),
                          const SizedBox(height: 2),
                          Text(
                            lvl.label,
                            style: TextStyle(
                              fontSize: 11,
                              fontWeight: isSelected ? FontWeight.w900 : FontWeight.w700,
                              color: isSelected ? Colors.white : const Color(0xFF2A1D40),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              );
            }).toList(),
          ),
        ],
      ),
    );
  }

  Widget _buildRecommendationBanner() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
      decoration: BoxDecoration(
        color: const Color(0xFFEDE7FF),
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: const Color(0xFFBDA8FF), width: 1.2),
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(6),
            decoration: const BoxDecoration(
              color: Color(0xFFFFD54F),
              shape: BoxShape.circle,
            ),
            child: const Icon(Icons.star_rounded, color: Colors.white, size: 18),
          ),
          const SizedBox(width: 10),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Recommended for you!',
                  style: TextStyle(fontSize: 12, fontWeight: FontWeight.w900, color: Color(0xFF5E35B1)),
                ),
                Text(
                  'You\'re feeling ${_selectedMood.label} and ${_selectedLevel.label}! Let\'s pick a fun route!',
                  style: const TextStyle(fontSize: 11, fontWeight: FontWeight.w600, color: Color(0xFF2A1D40)),
                ),
              ],
            ),
          ),
          const Text('🎒', style: TextStyle(fontSize: 22)),
        ],
      ),
    );
  }

  Widget _buildRouteCard(RouteOption route) {
    final isSelected = _selectedRoute.type == route.type;
    final isRecommended = route.isRecommended;

    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(22),
        border: Border.all(
          color: isRecommended
              ? const Color(0xFFFFCA28)
              : isSelected
                  ? const Color(0xFF8A6CF6)
                  : const Color(0xFFE5DEFC),
          width: isRecommended ? 2.5 : isSelected ? 2.0 : 1.0,
        ),
        boxShadow: [
          BoxShadow(
            color: isRecommended
                ? const Color(0xFFFFCA28).withValues(alpha: 0.3)
                : const Color(0xFF5E35B1).withValues(alpha: 0.06),
            blurRadius: isRecommended ? 16 : 8,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Stack(
        clipBehavior: Clip.none,
        children: [
          // "BEST FOR YOU" Ribbon
          if (isRecommended)
            Positioned(
              top: -10,
              right: 20,
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 3),
                decoration: BoxDecoration(
                  gradient: const LinearGradient(
                    colors: [Color(0xFFFFD54F), Color(0xFFFF9800)],
                  ),
                  borderRadius: BorderRadius.circular(12),
                  boxShadow: [
                    BoxShadow(
                      color: const Color(0xFFFF9800).withValues(alpha: 0.4),
                      blurRadius: 6,
                      offset: const Offset(0, 2),
                    ),
                  ],
                ),
                child: const Row(
                  children: [
                    Icon(Icons.star_rounded, color: Colors.white, size: 12),
                    SizedBox(width: 4),
                    Text(
                      'BEST FOR YOU',
                      style: TextStyle(
                        fontSize: 9,
                        fontWeight: FontWeight.w900,
                        color: Colors.white,
                        letterSpacing: 0.5,
                      ),
                    ),
                  ],
                ),
              ),
            ),

          InkWell(
            onTap: () {
              setState(() => _selectedRoute = route);
            },
            borderRadius: BorderRadius.circular(22),
            child: Padding(
              padding: const EdgeInsets.all(14),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      // Route Type Icon
                      Container(
                        width: 48,
                        height: 48,
                        decoration: BoxDecoration(
                          color: route.iconColor.withValues(alpha: 0.15),
                          shape: BoxShape.circle,
                        ),
                        child: Center(
                          child: Icon(route.iconData, color: route.iconColor, size: 26),
                        ),
                      ),
                      const SizedBox(width: 12),

                      // Title & Subtitle
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              route.title,
                              style: const TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.w900,
                                color: Color(0xFF2A1D40),
                              ),
                            ),
                            const SizedBox(height: 2),
                            Text(
                              route.subtitle,
                              style: const TextStyle(
                                fontSize: 11,
                                fontWeight: FontWeight.w500,
                                color: Color(0xFF6E5D87),
                              ),
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                            ),
                          ],
                        ),
                      ),

                      // Selection Checkmark Circle
                      Container(
                        width: 28,
                        height: 28,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          color: isSelected ? const Color(0xFF8A6CF6) : Colors.transparent,
                          border: Border.all(
                            color: isSelected ? const Color(0xFF8A6CF6) : const Color(0xFFBDBDBD),
                            width: 2,
                          ),
                        ),
                        child: isSelected
                            ? const Icon(Icons.check_rounded, color: Colors.white, size: 18)
                            : null,
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),

                  // Distance, Time, Swiper Risk, Adventure Level Pills
                  Row(
                    children: [
                      _buildMetricItem(Icons.place_rounded, '${route.distanceKm} km', 'Distance'),
                      const SizedBox(width: 12),
                      _buildMetricItem(Icons.access_time_rounded, '${route.etaMinutes} min', 'Est. Time'),
                      const SizedBox(width: 12),
                      _buildRiskPill(route.swiperRisk, route.riskColor),
                      const SizedBox(width: 8),
                      _buildAdventureBadge(route.adventureBadge),
                    ],
                  ),
                  const SizedBox(height: 10),

                  // "Why this route?" callout
                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
                    decoration: BoxDecoration(
                      color: const Color(0xFFF6F4FF),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text(
                          'Why this route?',
                          style: TextStyle(
                            fontSize: 10,
                            fontWeight: FontWeight.w900,
                            color: Color(0xFF8A6CF6),
                          ),
                        ),
                        const SizedBox(height: 2),
                        Text(
                          route.whyThisRoute,
                          style: const TextStyle(
                            fontSize: 11,
                            fontWeight: FontWeight.w600,
                            color: Color(0xFF2A1D40),
                          ),
                        ),
                      ],
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

  Widget _buildMetricItem(IconData icon, String value, String label) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Icon(icon, size: 13, color: const Color(0xFF8A6CF6)),
            const SizedBox(width: 3),
            Text(value, style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w800, color: Color(0xFF2A1D40))),
          ],
        ),
        Text(label, style: const TextStyle(fontSize: 9, color: Color(0xFF6E5D87))),
      ],
    );
  }

  Widget _buildRiskPill(String risk, Color color) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 3),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.15),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Text(
        '$risk Risk',
        style: TextStyle(fontSize: 10, fontWeight: FontWeight.w800, color: color),
      ),
    );
  }

  Widget _buildAdventureBadge(String badge) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 3),
      decoration: BoxDecoration(
        color: const Color(0xFFEDE7FF),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Text(
        badge,
        style: const TextStyle(fontSize: 10, fontWeight: FontWeight.w800, color: Color(0xFF5E35B1)),
      ),
    );
  }

  Widget _buildFootnote() {
    return Container(
      padding: const EdgeInsets.all(10),
      decoration: BoxDecoration(
        color: const Color(0xFFEDE7FF).withValues(alpha: 0.5),
        borderRadius: BorderRadius.circular(12),
      ),
      child: const Row(
        children: [
          Icon(Icons.lightbulb_outline_rounded, size: 16, color: Color(0xFF8A6CF6)),
          SizedBox(width: 8),
          Expanded(
            child: Text(
              'Route recommendations update instantly when you switch your mood or adventure level!',
              style: TextStyle(fontSize: 11, color: Color(0xFF5E35B1), fontWeight: FontWeight.w600),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStartAdventureButton() {
    return Container(
      padding: const EdgeInsets.fromLTRB(16, 10, 16, 12),
      decoration: const BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
        boxShadow: [
          BoxShadow(
            color: Color(0x1E5E35B1),
            blurRadius: 12,
            offset: Offset(0, -3),
          ),
        ],
      ),
      child: ElevatedButton(
        onPressed: _onConfirmAdventure,
        style: ElevatedButton.styleFrom(
          backgroundColor: const Color(0xFF7E57C2),
          foregroundColor: Colors.white,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(28)),
          padding: const EdgeInsets.symmetric(vertical: 14),
          elevation: 4,
          shadowColor: const Color(0xFF7E57C2).withValues(alpha: 0.4),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.star_rounded, color: Color(0xFFFFCA28), size: 22),
            const SizedBox(width: 8),
            Text(
              'Start Adventure (${_selectedRoute.title})!',
              style: const TextStyle(fontSize: 15, fontWeight: FontWeight.w900),
            ),
            const SizedBox(width: 8),
            const Icon(Icons.arrow_forward_rounded, size: 20),
          ],
        ),
      ),
    );
  }
}
