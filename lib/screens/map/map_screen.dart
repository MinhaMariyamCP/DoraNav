import 'package:flutter/material.dart';
import '../backpack/backpack_screen.dart';
import '../backpack/services/mock_recommendation_service.dart';
import '../route_selection/choose_your_route_screen.dart';
import '../../themes/app_theme.dart';
import 'models/map_models.dart';
import 'services/pathfinder_service.dart';
import 'widgets/locations_explorer_sheet.dart';
import 'widgets/map_canvas_view.dart';
import 'widgets/map_top_bar.dart';
import 'widgets/navigation_cards.dart';
import 'widgets/quick_actions_bar.dart';
import 'widgets/graph_inspector_modal.dart';
import '../navigation/widgets/roadblock_detected_modal.dart';
import '../navigation/widgets/swiper_detected_modal.dart';
import '../../services/dora_voice_service.dart';
import '../../services/audio_service.dart';
import '../../widgets/shared/dora_speech_banner.dart';
import '../../widgets/fiesta_trio/fiesta_trio_celebration.dart';
import '../adventure_report/models/trip_data.dart';
import '../adventure_report/widgets/adventure_report_screen.dart';

/// Main DoraNav World Map & Navigation Screen.
/// Faithfully reproduces the layout, cards, map canvas, and legend from the reference design.
class MapScreen extends StatefulWidget {
  final String initialDestinationName;

  const MapScreen({
    super.key,
    this.initialDestinationName = 'King’s Castle',
  });

  @override
  State<MapScreen> createState() => _MapScreenState();
}

class _MapScreenState extends State<MapScreen> {
  final PathfinderService _pathfinder = PathfinderService();

  final DoraVoiceService _voiceService = DoraVoiceService();
  bool _isLoading = true;
  LocationNode? _currentLocation;
  LocationNode? _selectedDestination;
  NavigationRoute? _activeRoute;
  NavigationRoute? _alternativeRoute;

  bool _isSwiperAlertActive = true;
  String _swiperRiskLevel = 'Low Risk';
  bool _isRoadBlockActive = false;
  String? _blockedNodeName;

  @override
  void initState() {
    super.initState();
    _initializeMapData();
    AudioService.instance.startBackgroundMusic();
  }

  Future<void> _initializeMapData() async {
    await _pathfinder.loadMapData();

    if (mounted) {
      setState(() {
        _currentLocation = _pathfinder.startNode;
        // Default destination is King's Castle / Royal Castle (matching reference poster)
        _selectedDestination = _pathfinder.allLocations.firstWhere(
          (l) => l.name.contains('Castle') || l.id == 'L012',
          orElse: () => _pathfinder.selectableDestinations.first,
        );

        _calculateRoutes();
        _isLoading = false;
      });
    }
  }

  void _calculateRoutes() {
    if (_currentLocation == null || _selectedDestination == null) return;

    // 1. Calculate optimal path using A*
    _activeRoute = _pathfinder.findRoute(
      startId: _currentLocation!.id,
      goalId: _selectedDestination!.id,
    );

    // 2. Calculate alternative path avoiding Swiper's hazard & roadblocks
    final customBlocked = {'L045', 'L044', ..._pathfinder.blockedNodeIds};
    _alternativeRoute = _pathfinder.findRoute(
      startId: _currentLocation!.id,
      goalId: _selectedDestination!.id,
      customBlockedNodes: customBlocked,
      isAlternative: true,
    );
  }

  void _onDestinationSelected(LocationNode destination) {
    setState(() {
      _selectedDestination = destination;
      _calculateRoutes();
    });

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('Destination set to ${destination.name}! Calculating route...'),
        backgroundColor: const Color(0xFF7E57C2),
        duration: const Duration(seconds: 2),
      ),
    );
  }

  void _onSwitchToAlternativeRoute() {
    if (_alternativeRoute == null) return;

    setState(() {
      _activeRoute = _alternativeRoute;
      _isSwiperAlertActive = false;
      _swiperRiskLevel = 'Bypassed';
    });

    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text("Swiper, no swiping! Taking the safe alternative bypass route!"),
        backgroundColor: Color(0xFF00C853),
        duration: Duration(seconds: 3),
      ),
    );
  }

  void _toggleSwiperAlert() {
    setState(() {
      if (_swiperRiskLevel == 'Low Risk' || !_isSwiperAlertActive) {
        _swiperRiskLevel = 'High Risk';
        _isSwiperAlertActive = true;

        // Find a node along the active route to place Swiper on
        LocationNode? swiperNode;
        if (_activeRoute != null && _activeRoute!.nodes.length > 2) {
          swiperNode = _activeRoute!.nodes[1];
        } else {
          swiperNode = _pathfinder.allLocations.firstWhere(
            (l) => l.id == 'L045' || l.name.contains('Bridge'),
            orElse: () => _pathfinder.allLocations[1],
          );
        }

        // 1. Block Swiper location in graph
        _pathfinder.setSwiperLocation(swiperNode.id);

        // 2. Reroute using A* around Swiper
        final prevRoute = _activeRoute;
        final rerouted = _pathfinder.rerouteAroundSwiper(
          currentLocationId: _currentLocation?.id ?? _pathfinder.startNode!.id,
          destinationId: _selectedDestination?.id ?? _pathfinder.selectableDestinations.first.id,
        );

        if (rerouted != null) {
          _activeRoute = rerouted;
        }
        _calculateRoutes();

        // 3. Show SwiperDetectedModal with real route diff
        SwiperDetectedModal.show(
          context: context,
          distanceText: '180m ahead',
          currentRouteName: 'Direct Path',
          newRouteName: 'Dynamic A* Bypass',
          swiperLocationName: swiperNode.name,
          routeStatus: rerouted != null ? NavigationRouteStatus.rerouted : NavigationRouteStatus.noAlternativeRoute,
          originalRoute: prevRoute,
          reroutedRoute: rerouted,
          onViewNewRoute: () {
            setState(() {
              _isSwiperAlertActive = false;
              _swiperRiskLevel = 'Bypassed';
            });
          },
          onContinueOriginalRoute: () {
            _pathfinder.clearSwiper();
            _calculateRoutes();
            setState(() {
              _isSwiperAlertActive = false;
              _swiperRiskLevel = 'Low Risk';
            });
          },
        );
      } else {
        _swiperRiskLevel = 'Low Risk';
        _isSwiperAlertActive = false;
        _pathfinder.clearSwiper();
        _calculateRoutes();
      }
    });
  }

  void _toggleRoadBlock() {
    setState(() {
      if (_isRoadBlockActive) {
        _pathfinder.clearAllBlocks();
        _isRoadBlockActive = false;
        _blockedNodeName = null;
        _calculateRoutes();
        _voiceService.speak(const DoraVoiceLine(
          speaker: 'Dora',
          text: 'Road cleared! Path is open for our adventure!',
          spanishText: '¡Camino despejado!',
          emoji: '🌟',
        ));
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Road block cleared! Path is open to explore! 🌟'),
            backgroundColor: Color(0xFF00C853),
          ),
        );
      } else {
        // Pick midpoint node on active route
        LocationNode? targetNode;
        if (_activeRoute != null && _activeRoute!.nodes.length > 2) {
          targetNode = _activeRoute!.nodes[_activeRoute!.nodes.length ~/ 2];
        } else {
          targetNode = _pathfinder.allLocations.firstWhere(
            (l) => l.id == 'L045' || l.name.contains('Bridge'),
            orElse: () => _pathfinder.allLocations[1],
          );
        }

        _pathfinder.setNodeBlocked(targetNode.id, true);
        _isRoadBlockActive = true;
        _blockedNodeName = targetNode.name;
        _calculateRoutes();

        _voiceService.playRoadBlockWarning(obstacle: 'Rockslide at ${targetNode.name}');

        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Road blocked at $_blockedNodeName! Recalculating route...'),
            backgroundColor: const Color(0xFFE65100),
          ),
        );

        RoadBlockDetectedModal.show(
          context: context,
          obstacleTitle: 'Rockslide at ${targetNode.name}!',
          obstacleDescription: 'Boulders have fallen and blocked the road ahead!',
          detourRouteName: 'Scenic A* Detour Bypass',
          onTakeDetour: _onSwitchToAlternativeRoute,
          onUseBackpackTool: _showBackpackModal,
        );
      }
    });
  }

  void _openGraphInspector() {
    GraphInspectorModal.show(context, _pathfinder);
  }

  void _showBackpackModal() {
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (_) => const BackpackScreen(
          initialScenario: BackpackScenario.riverCrossing,
        ),
      ),
    );
  }



  void _showSearchDialog() {
    showSearch(
      context: context,
      delegate: _LocationSearchDelegate(
        locations: _pathfinder.selectableDestinations,
        onSelected: _onDestinationSelected,
      ),
    );
  }

  void _startNavigationFlow([LocationNode? destination]) {
    final target = destination ?? _selectedDestination ?? _pathfinder.selectableDestinations.first;
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (_) => ChooseYourRouteScreen(
          startLocation: _currentLocation ?? _pathfinder.startNode!,
          destination: target,
          pathfinder: _pathfinder,
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return const Scaffold(
        backgroundColor: AppColors.twilightDark,
        body: Center(
          child: CircularProgressIndicator(color: AppColors.starYellow),
        ),
      );
    }

    final dest = _selectedDestination ?? _pathfinder.allLocations.first;

    return Scaffold(
      backgroundColor: const Color(0xFFF3E5F5),
      body: SafeArea(
        child: Column(
          children: [
            // 1. Top App Bar & Search
            MapTopBar(
              swiperRiskLevel: _swiperRiskLevel,
              onSearchTap: _showSearchDialog,
              onSwiperAlertTap: _toggleSwiperAlert,
              onMenuPressed: () {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('DoraNav Menu opened')),
                );
              },
            ),

            // 1b. Floating Dora Voice Speech Bubble Banner
            DoraSpeechBanner(voiceService: _voiceService),

            // 2. Interactive Map Canvas (Expanded)
            Expanded(
              child: Stack(
                children: [
                  MapCanvasView(
                    locations: _pathfinder.allLocations,
                    allRoads: _pathfinder.roads,
                    activeRoute: _activeRoute,
                    alternativeRoute: _alternativeRoute,
                    selectedDestination: _selectedDestination,
                    currentLocation: _currentLocation,
                    cameraMode: _selectedDestination != null
                        ? MapCameraMode.routePreview
                        : MapCameraMode.worldOverview,
                    onLocationSelected: _onDestinationSelected,
                    showSwiperOnRoute: _isSwiperAlertActive,
                    swiperState: _pathfinder.swiperState,
                    onSwiperTap: _onSwitchToAlternativeRoute,
                    showRoadBlockOnRoute: _isRoadBlockActive,
                    onRoadBlockTap: _toggleRoadBlock,
                    blockedRoadIds: _pathfinder.blockedRoadIds,
                    blockedNodeIds: _pathfinder.blockedNodeIds,
                    dynamicObstacles: _pathfinder.dynamicObstacleManager.activeObstacles,
                  ),

                  // Floating Navigation Turn & Destination Cards Overlay
                  Positioned(
                    left: 0,
                    right: 0,
                    bottom: 6,
                    child: NavigationCardsRow(
                      route: _activeRoute,
                      destination: dest,
                      isSwiperAhead: _isSwiperAlertActive,
                      onNavigatePressed: () => _startNavigationFlow(dest),
                      onViewAlternativePressed: _onSwitchToAlternativeRoute,
                    ),
                  ),
                ],
              ),
            ),

            // 3. Quick Action Row
            MapQuickActionsBar(
              onBackpackPressed: _showBackpackModal,
              onLostModePressed: () {
                _voiceService.speak(const DoraVoiceLine(
                  speaker: 'The Map',
                  text: "Who do you ask when you don't know which way to go? THE MAP! 🗺️",
                  spanishText: "¡Pregúntale al Mapa!",
                  emoji: '🗺️',
                ));
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('Lost Mode activated! Who do we ask for help? The Map! 🗺️')),
                );
              },
              onAchievementsPressed: () {
                _voiceService.speak(const DoraVoiceLine(
                  speaker: 'Dora',
                  text: "Great exploring! You've collected 5 Explorer Stars so far! ⭐",
                  spanishText: "¡Excelente trabajo, explorador!",
                  emoji: '⭐',
                ));
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('Achievements: 5 Dora Stars collected! ⭐')),
                );
              },
              onVoiceGuidePressed: () {
                _voiceService.playMapSong();
              },
              onRoadBlockPressed: _toggleRoadBlock,
              isRoadBlockActive: _isRoadBlockActive,
              onGraphInspectorPressed: _openGraphInspector,
              onTestFiestaPressed: _testFiestaTrioCelebration,
              onEndTripPressed: () {
                setState(() {
                  _activeRoute = null;
                  _alternativeRoute = null;
                });
                _voiceService.speak(const DoraVoiceLine(
                  speaker: 'Dora',
                  text: 'Adventure paused. Tap any destination to start exploring again!',
                  emoji: '🎒',
                ));
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('Trip ended. Returning to exploration mode.')),
                );
              },
            ),

            // 4. Bottom Expandable Explorer Sheet (Destinations, All Locations, Legend)
            LocationsExplorerSheet(
              destinations: _pathfinder.selectableDestinations,
              allLocations: _pathfinder.allLocations,
              selectedLocation: _selectedDestination,
              onSelectDestination: _onDestinationSelected,
              onStartNavigation: (loc) => _startNavigationFlow(loc),
            ),
          ],
        ),
      ),
    );
  }

  void _testFiestaTrioCelebration() {
    final destName = _selectedDestination?.name ?? "King's Castle";
    final now = DateTime.now();
    final trip = TripData(
      destinationName: destName,
      destinationDescription:
          'Great job, explorer! You and Dora reached $destName safely!',
      distanceKm: 4.8,
      tripDuration: const Duration(minutes: 15),
      turnsTaken: 6,
      bridgesCrossed: 1,
      animalsMet: 2,
      swiperEncounters: 1,
      backpackItemsUsed: 2,
      routeType: 'Fastest Trail',
      mood: 'Joyful & Adventurous',
      adventureLevel: 'Explorer',
      explorationPoints: 6,
      discoveriesFound: 3,
      highlights: const [
        TripHighlight(
          title: 'Crossed Rainbow Bridge with Fiesta fanfare',
          iconEmoji: '🌈',
        ),
        TripHighlight(
          title: 'Outsmarted Swiper at Blueberry Hill',
          iconEmoji: '🦊',
        ),
        TripHighlight(
          title: 'Discovered 3 Golden Explorer Stars',
          iconEmoji: '⭐',
        ),
      ],
      startTime: now.subtract(const Duration(minutes: 15)),
      endTime: now,
    );

    FiestaTrioCelebration.show(
      context,
      destinationName: destName,
      tripData: trip,
      onComplete: () {
        if (!mounted) return;
        Navigator.of(context).push(
          MaterialPageRoute(
            builder: (_) => AdventureReportScreen(
              tripData: trip,
              onBackToMap: () => Navigator.of(context).pop(),
              onStartNewAdventure: () => Navigator.of(context).pop(),
            ),
          ),
        );
      },
    );
  }
}

class _LocationSearchDelegate extends SearchDelegate<LocationNode?> {
  final List<LocationNode> locations;
  final ValueChanged<LocationNode> onSelected;

  _LocationSearchDelegate({
    required this.locations,
    required this.onSelected,
  });

  @override
  List<Widget>? buildActions(BuildContext context) {
    return [
      if (query.isNotEmpty)
        IconButton(icon: const Icon(Icons.clear), onPressed: () => query = ''),
    ];
  }

  @override
  Widget? buildLeading(BuildContext context) {
    return IconButton(icon: const Icon(Icons.arrow_back), onPressed: () => close(context, null));
  }

  @override
  Widget buildResults(BuildContext context) => _buildList(context);

  @override
  Widget buildSuggestions(BuildContext context) => _buildList(context);

  Widget _buildList(BuildContext context) {
    final filtered = query.isEmpty
        ? locations
        : locations.where((l) => l.name.toLowerCase().contains(query.toLowerCase())).toList();

    return ListView.builder(
      itemCount: filtered.length,
      itemBuilder: (context, index) {
        final loc = filtered[index];
        return ListTile(
          leading: const Icon(Icons.place_rounded, color: Color(0xFF7E57C2)),
          title: Text(loc.name, style: const TextStyle(fontWeight: FontWeight.bold)),
          subtitle: Text(loc.description, maxLines: 1, overflow: TextOverflow.ellipsis),
          onTap: () {
            onSelected(loc);
            close(context, loc);
          },
        );
      },
    );
  }
}
