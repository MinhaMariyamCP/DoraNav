import 'dart:async';
import 'package:flutter/material.dart';
import '../backpack/backpack_screen.dart';
import '../backpack/services/mock_recommendation_service.dart';
import '../map/models/map_models.dart';
import '../map/services/pathfinder_service.dart';
import '../map/widgets/map_canvas_view.dart';
import '../route_selection/choose_your_route_screen.dart';
import '../route_selection/models/route_selection_models.dart';
import '../adventure_report/models/trip_data.dart';
import '../adventure_report/widgets/adventure_report_screen.dart';
import 'widgets/swiper_detected_modal.dart';
import 'widgets/roadblock_detected_modal.dart';
import '../../services/dora_voice_service.dart';
import '../../services/navigation_simulation_service.dart';
import '../../widgets/fiesta_trio/fiesta_trio_celebration.dart';
import 'widgets/test_obstacles_panel.dart';
import 'widgets/obstacle_alert_popup.dart';

/// Refactored, real-time simulated Active Navigation Screen.
///
/// Key Architectural Features:
/// - Continuous, route-driven Dora movement powered by [NavigationSimulationService]
/// - Real-time journey stopwatch and dynamic distance/ETA countdown
/// - No "Next Place" manual progression — intermediate nodes are visited automatically
/// - Soft camera follow tracking Dora's live continuous coordinate
/// - Single compact bottom navigation panel keeping the map prominent
/// - A* engine remains single source of truth for all routing and dynamic obstacle detours
class ActiveNavigationScreen extends StatefulWidget {
  final LocationNode startLocation;
  final LocationNode destination;
  final RouteOption routeOption;
  final NavigationRoute navigationRoute;
  final DoraMood mood;
  final AdventureLevel adventureLevel;
  final PathfinderService pathfinder;

  const ActiveNavigationScreen({
    super.key,
    required this.startLocation,
    required this.destination,
    required this.routeOption,
    required this.navigationRoute,
    required this.mood,
    required this.adventureLevel,
    required this.pathfinder,
  });

  @override
  State<ActiveNavigationScreen> createState() => _ActiveNavigationScreenState();
}

class _ActiveNavigationScreenState extends State<ActiveNavigationScreen>
    with SingleTickerProviderStateMixin {
  late DoraMood _currentMood;
  late AdventureLevel _currentLevel;
  late RouteOption _currentRouteOption;
  late NavigationRoute _currentNavRoute;

  late final NavigationSimulationService _simulationService;
  final DoraVoiceService _voiceService = DoraVoiceService();

  bool _isSpeaking = false;
  bool _isSwiperHazardBypassed = false;
  bool _isRoadBlockActive = false;
  bool _hasCompletedAdventure = false;
  late AnimationController _pulseController;

  NavigationRouteStatus _routeStatus = NavigationRouteStatus.normal;
  MapCameraMode _cameraMode = MapCameraMode.routePreview;
  int _routeVersion = 1;
  SwiperState? _swiperState;
  LocationNode? _swiperLocationNode;
  NavigationRoute? _originalRouteBeforeSwiper;

  ObstaclePopupData? _currentObstaclePopup;
  bool _isRerouting = false;
  final Set<String> _alertedObstacleIds = {};

  @override
  void initState() {
    super.initState();
    _currentMood = widget.mood;
    _currentLevel = widget.adventureLevel;
    _currentRouteOption = widget.routeOption;
    _currentNavRoute = widget.navigationRoute;

    _pulseController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1400),
    )..repeat(reverse: true);

    // Initialize continuous simulation service
    _simulationService = NavigationSimulationService(
      initialRoute: _currentNavRoute,
      initialSpeed: NavigationSimulationService.defaultSimulatedSpeed,
      onDestinationReached: () {
        if (!mounted) return;
        _showArrivalDialog();
      },
      onNodeReached: (node) {
        if (!mounted) return;
        debugPrint('[NavSim] Node reached: ${node.name}');
        final upcoming = _simulationService.nextNode ?? widget.destination;
        _voiceService.playTurnGuidance(upcoming.name);
      },
      onInstructionChanged: (instr) {
        if (mounted) setState(() {});
      },
    );

    _simulationService.addListener(_onSimulationUpdate);

    // Subscribe to dynamic obstacle events for event-driven A* reroute
    _dynamicObstacleSub = widget.pathfinder.dynamicObstacleManager.onObstacleStateChanged.listen((obs) {
      if (!mounted) return;
      _onDynamicObstacleTriggered(obs);
    });

    // Initial camera transition from route overview to live active navigation follow
    Future.delayed(const Duration(milliseconds: 650), () {
      if (mounted) {
        setState(() {
          _cameraMode = MapCameraMode.activeNavigation;
        });
        _simulationService.start();
        widget.pathfinder.dynamicObstacleManager.startAutoEncounters(
          getActiveRemainingNodes: () => _simulationService.activeRoute.nodes
              .sublist(_simulationService.currentSegmentIndex),
          getActiveRoads: () => widget.pathfinder.roads,
          initialDelay: const Duration(seconds: 6),
        );
      }
    });
  }

  StreamSubscription? _dynamicObstacleSub;

  void _onSimulationUpdate() {
    if (!mounted) return;
    setState(() {});
  }

  @override
  void dispose() {
    widget.pathfinder.dynamicObstacleManager.stopAutoEncounters();
    _dynamicObstacleSub?.cancel();
    _simulationService.removeListener(_onSimulationUpdate);
    _simulationService.dispose();
    _pulseController.dispose();
    super.dispose();
  }

  void _onSpeakInstruction() {
    setState(() => _isSpeaking = true);
    final target = _simulationService.nextNode ?? widget.destination;
    _voiceService.playTurnGuidance(target.name);
    Future.delayed(const Duration(milliseconds: 1800), () {
      if (mounted) setState(() => _isSpeaking = false);
    });
  }

  void _showArrivalDialog() {
    if (_hasCompletedAdventure) return;
    _hasCompletedAdventure = true;
    widget.pathfinder.dynamicObstacleManager.stopAutoEncounters();

    setState(() {
      _cameraMode = MapCameraMode.arrived;
    });
    _voiceService.playArrivalCelebration(widget.destination.name);

    final trip = _buildTripData();

    // Trigger interactive Fiesta Trio Celebration sequence!
    FiestaTrioCelebration.show(
      context,
      destinationName: widget.destination.name,
      tripData: trip,
      onComplete: () {
        if (!mounted) return;
        _showArrivalSummaryDialog(trip);
      },
    );
  }

  TripData _buildTripData() {
    final now = DateTime.now();
    return TripData(
      destinationName: widget.destination.name,
      destinationDescription:
          'Great job, explorer! You and Dora reached ${widget.destination.name} safely!',
      distanceKm: _currentNavRoute.totalDistance,
      tripDuration: _simulationService.elapsedTime,
      turnsTaken: _simulationService.activeRoute.nodes.length,
      bridgesCrossed: 1,
      animalsMet: 2,
      swiperEncounters: _isSwiperHazardBypassed ? 1 : 0,
      backpackItemsUsed: 3,
      routeType: _currentRouteOption.title,
      mood: _currentMood.label,
      adventureLevel: _currentLevel.label,
      explorationPoints: 6,
      discoveriesFound: 3,
      highlights: [
        TripHighlight(
          title: 'Navigated to ${widget.destination.name}',
          iconEmoji: '🗺️',
        ),
        if (_isSwiperHazardBypassed)
          const TripHighlight(
            title: 'Outsmarted Swiper with safe detour!',
            iconEmoji: '🦊',
          ),
        const TripHighlight(
          title: 'Earned 3 Explorer Stars!',
          iconEmoji: '⭐',
        ),
      ],
      startTime: now.subtract(_simulationService.elapsedTime),
      endTime: now,
    );
  }

  void _showArrivalSummaryDialog(TripData trip) {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (ctx) => Dialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(28)),
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              // Cheerful Star Crown
              Container(
                width: 72,
                height: 72,
                decoration: const BoxDecoration(
                  shape: BoxShape.circle,
                  color: Color(0xFFFFF9C4),
                ),
                child: const Center(
                  child: Text('🌟', style: TextStyle(fontSize: 40)),
                ),
              ),
              const SizedBox(height: 16),
              const Text(
                '¡Lo Hicimos! We Did It!',
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 22,
                  fontWeight: FontWeight.w900,
                  color: Color(0xFF4A148C),
                ),
              ),
              const SizedBox(height: 8),
              Text(
                'You and Dora arrived safely at ${widget.destination.name} in ${_simulationService.formattedElapsedTime}!',
                textAlign: TextAlign.center,
                style: const TextStyle(
                  fontSize: 13,
                  fontWeight: FontWeight.w600,
                  color: Color(0xFF5E35B1),
                ),
              ),
              const SizedBox(height: 14),
              // Stars & Mood earned
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
                decoration: BoxDecoration(
                  color: const Color(0xFFEDE7F6),
                  borderRadius: BorderRadius.circular(16),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(_currentMood.emoji, style: const TextStyle(fontSize: 18)),
                    const SizedBox(width: 6),
                    Text(
                      ' ${_currentLevel.label} ⭐⭐⭐',
                      style: const TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.w800,
                        color: Color(0xFF4A148C),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 20),

              // 1. View Adventure Report Primary CTA
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: () {
                    Navigator.of(ctx).pop();
                    Navigator.of(context).push(
                      MaterialPageRoute(
                        builder: (_) => AdventureReportScreen(
                          tripData: trip,
                          onBackToMap: () {
                            Navigator.of(context).pop();
                            Navigator.of(context).pop();
                          },
                          onStartNewAdventure: () {
                            Navigator.of(context).popUntil((route) => route.isFirst);
                          },
                        ),
                      ),
                    );
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF7E57C2),
                    foregroundColor: Colors.white,
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
                    padding: const EdgeInsets.symmetric(vertical: 14),
                  ),
                  child: const Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text('🏆', style: TextStyle(fontSize: 18)),
                      SizedBox(width: 8),
                      Text(
                        'View Adventure Report',
                        style: TextStyle(fontSize: 15, fontWeight: FontWeight.w900),
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 10),

              // 2. Return to Map Secondary CTA
              SizedBox(
                width: double.infinity,
                child: OutlinedButton(
                  onPressed: () {
                    Navigator.of(ctx).pop();
                    Navigator.of(context).pop();
                  },
                  style: OutlinedButton.styleFrom(
                    foregroundColor: const Color(0xFF7E57C2),
                    side: const BorderSide(color: Color(0xFF7E57C2), width: 1.5),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
                    padding: const EdgeInsets.symmetric(vertical: 12),
                  ),
                  child: const Text(
                    'Return to World Map 🗺️',
                    style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _openBackpack() {
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (_) => const BackpackScreen(
          initialScenario: BackpackScenario.riverCrossing,
        ),
      ),
    );
  }

  Future<void> _onChangeMoodOrRoute() async {
    _simulationService.pause();
    final result = await Navigator.of(context).push<Map<String, dynamic>>(
      MaterialPageRoute(
        builder: (_) => ChooseYourRouteScreen(
          startLocation: _simulationService.currentNode,
          destination: widget.destination,
          pathfinder: widget.pathfinder,
          initialMood: _currentMood,
          initialLevel: _currentLevel,
        ),
      ),
    );

    if (result != null && mounted) {
      setState(() {
        _currentRouteOption = result['selectedOption'] as RouteOption;
        _currentMood = result['mood'] as DoraMood;
        _currentLevel = result['adventureLevel'] as AdventureLevel;
        final navRoute = result['navigationRoute'] as NavigationRoute?;
        if (navRoute != null && navRoute.path.isNotEmpty) {
          _currentNavRoute = navRoute;
          _simulationService.updateRoute(navRoute);
          _routeVersion++;
        }
      });
      _simulationService.resume();
    } else {
      _simulationService.resume();
    }
  }

  void _triggerSwiperReroute([LocationNode? targetSwiperNode]) {
    // 1. Identify where Swiper appears: next waypoint along the current route if possible
    LocationNode swiperNode;
    if (targetSwiperNode != null) {
      swiperNode = targetSwiperNode;
    } else if (_simulationService.nextNode != null) {
      swiperNode = _simulationService.nextNode!;
    } else {
      swiperNode = widget.pathfinder.allLocations.firstWhere(
        (l) => l.id != _simulationService.currentNode.id && l.id != widget.destination.id,
        orElse: () => widget.destination,
      );
    }

    final currentPosNode = _simulationService.currentNode;
    _originalRouteBeforeSwiper ??= _currentNavRoute;

    debugPrint('[Swiper] Detected at: ${swiperNode.name} (${swiperNode.id})');
    debugPrint('[Navigation] Initial route: ${_currentNavRoute.nodeNames.join(' -> ')}');
    debugPrint('[Navigation] Current route compromised.');

    setState(() {
      _routeStatus = NavigationRouteStatus.swiperDetected;
      _cameraMode = MapCameraMode.rerouting;
      _swiperLocationNode = swiperNode;
    });

    _voiceService.playSwiperWarning();
    widget.pathfinder.setSwiperLocation(swiperNode.id);

    setState(() {
      _routeStatus = NavigationRouteStatus.rerouting;
      _swiperState = widget.pathfinder.swiperState;
    });

    // 2. Trigger A* recalculated route starting from Dora's CURRENT location
    final reroutedPartial = widget.pathfinder.rerouteAroundSwiper(
      currentLocationId: currentPosNode.id,
      destinationId: widget.destination.id,
      preference: _currentRouteOption.type == RouteOptionType.swiperSafe
          ? RouteOptionType.swiperSafe
          : RouteOptionType.normal,
    );

    if (reroutedPartial != null && reroutedPartial.path.isNotEmpty) {
      setState(() {
        _currentNavRoute = reroutedPartial;
        _routeStatus = NavigationRouteStatus.rerouted;
        _cameraMode = MapCameraMode.activeNavigation;
        _routeVersion++;
      });

      // Update continuous simulation seamlessly from current position
      _simulationService.updateRoute(reroutedPartial);
      debugPrint('[Navigation] Rerouting successful.');

      SwiperDetectedModal.show(
        context: context,
        distanceText: '150m ahead',
        currentRouteName: _currentRouteOption.title,
        newRouteName: 'Dynamic A* Swiper Bypass',
        swiperLocationName: swiperNode.name,
        routeStatus: NavigationRouteStatus.rerouted,
        originalRoute: _originalRouteBeforeSwiper,
        reroutedRoute: reroutedPartial,
        onViewNewRoute: () {
          setState(() => _isSwiperHazardBypassed = true);
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('Switched to dynamic detour bypassing ${swiperNode.name}! 🌟'),
              backgroundColor: const Color(0xFF7B61FF),
            ),
          );
        },
        onContinueOriginalRoute: () {
          _clearSwiper();
        },
      );
    } else {
      setState(() {
        _routeStatus = NavigationRouteStatus.noAlternativeRoute;
      });
      debugPrint('[Navigation] No alternative route found.');

      SwiperDetectedModal.show(
        context: context,
        distanceText: '150m ahead',
        currentRouteName: _currentRouteOption.title,
        newRouteName: 'Blocked',
        swiperLocationName: swiperNode.name,
        routeStatus: NavigationRouteStatus.noAlternativeRoute,
        originalRoute: _originalRouteBeforeSwiper,
        reroutedRoute: null,
        onViewNewRoute: () {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('No alternative route available. Please clear Swiper or wait!'),
              backgroundColor: Colors.redAccent,
            ),
          );
        },
        onContinueOriginalRoute: () {
          _clearSwiper();
        },
      );
    }
  }

  void _onDynamicObstacleTriggered(DynamicObstacle obs) {
    _handleObstacleDetected(obs);
  }

  Future<void> _handleObstacleDetected(DynamicObstacle obstacle) async {
    if (!mounted) return;

    // Handle obstacle removal
    if (!obstacle.active) {
      _alertedObstacleIds.remove(obstacle.id);
      // If we were blocked with no safe route, re-run A* now that an obstacle was removed!
      if (_routeStatus == NavigationRouteStatus.noAlternativeRoute) {
        final restoredRoute = _calculateRouteFromCurrentPosition();
        if (restoredRoute != null && restoredRoute.nodes.isNotEmpty) {
          setState(() {
            _currentNavRoute = restoredRoute;
            _routeStatus = NavigationRouteStatus.normal;
            _routeVersion++;
            _currentObstaclePopup = ObstaclePopupData.routeAvailable(type: obstacle.type);
          });
          _simulationService.updateRoute(restoredRoute);
          _voiceService.speak(const DoraVoiceLine(
            speaker: 'Dora',
            text: 'Yay! The path is open again! Let\'s go!',
            emoji: '🌟',
          ));
          await Future.delayed(const Duration(milliseconds: 1400));
          if (mounted) {
            setState(() {
              _currentObstaclePopup = null;
            });
            _simulationService.resume();
          }
        }
      } else {
        setState(() {});
      }
      return;
    }

    // 1. Detect if obstacle affects the remaining active route
    final remainingNodes = _simulationService.activeRoute.nodes
        .sublist(_simulationService.currentSegmentIndex);

    final affectsRoute = obstacle.affectsActiveRoute(
      remainingNodes: remainingNodes,
      roads: widget.pathfinder.roads,
    );

    if (!affectsRoute) {
      // Off-route obstacle: update map without recalculating active route
      setState(() {});
      return;
    }

    // 2. Prevent duplicate alerts for the same obstacle encounter
    if (_alertedObstacleIds.contains(obstacle.id)) {
      return;
    }
    _alertedObstacleIds.add(obstacle.id);

    if (_isRerouting) return;
    _isRerouting = true;

    // 3. Pause Dora safely while rerouting popup is active
    _simulationService.pause();

    // 4. Show dedicated obstacle popup with "Finding a safer route..."
    setState(() {
      _routeStatus = NavigationRouteStatus.rerouting;
      _currentObstaclePopup = ObstaclePopupData.forObstacle(obstacle, rerouting: true);
      _cameraMode = MapCameraMode.rerouting;
      if (obstacle.type == DynamicObstacleType.swiper) {
        _swiperLocationNode = obstacle.nodeId != null
            ? widget.pathfinder.allLocations.firstWhere(
                (l) => l.id == obstacle.nodeId,
                orElse: () => _simulationService.currentNode,
              )
            : null;
        _swiperState = SwiperState(
          currentLocationId: obstacle.nodeId,
          active: true,
          riskLevel: 'High Risk',
        );
      }
    });

    // Speak obstacle alert
    _playVoiceForObstacle(obstacle);

    // Brief animation delay so user clearly sees "Finding a safer route..."
    await Future.delayed(const Duration(milliseconds: 750));

    // 5. Calculate NEXT BEST PATH using A* starting from Dora's live position
    final newRoute = _calculateRouteFromCurrentPosition();

    if (newRoute != null && newRoute.nodes.isNotEmpty) {
      // 6. Update route, preserving elapsed time and continuous position
      _currentNavRoute = newRoute;
      _simulationService.updateRoute(newRoute);
      _routeStatus = NavigationRouteStatus.rerouted;
      _routeVersion++;

      // 7. Update popup to "New route found!"
      if (mounted) {
        setState(() {
          _currentObstaclePopup = _currentObstaclePopup?.copyWith(
            rerouting: false,
            newRouteFound: true,
          );
          _cameraMode = MapCameraMode.activeNavigation;
        });
      }

      // 8. Wait 1200ms with "New route found!" visible
      await Future.delayed(const Duration(milliseconds: 1200));

      // 9. Popup disappears automatically & Dora continues moving
      if (mounted) {
        setState(() {
          _currentObstaclePopup = null;
        });
        _simulationService.resume();
      }
    } else {
      // 10. No alternative route available
      debugPrint('[Navigation] No alternative route found. Every path is blocked!');
      if (mounted) {
        setState(() {
          _routeStatus = NavigationRouteStatus.noAlternativeRoute;
          _currentObstaclePopup = ObstaclePopupData.noRoute(type: obstacle.type);
        });
      }
      _voiceService.speak(const DoraVoiceLine(
        speaker: 'Dora',
        text: 'Too many obstacles are blocking the way. Let\'s wait for a path to open!',
        emoji: '😟',
      ));
      // Dora remains paused safely without crashing or walking through obstacles
    }

    _isRerouting = false;
  }

  void _playVoiceForObstacle(DynamicObstacle obstacle) {
    switch (obstacle.type) {
      case DynamicObstacleType.swiper:
        _voiceService.speak(const DoraVoiceLine(
          speaker: 'Dora',
          text: 'Oh no! Swiper is blocking our route! Finding a safer way!',
          emoji: '🦊',
        ));
        break;
      case DynamicObstacleType.crocodile:
        _voiceService.speak(const DoraVoiceLine(
          speaker: 'Dora',
          text: 'Watch out! A crocodile is blocking the crossing ahead! Finding another way!',
          emoji: '🐊',
        ));
        break;
      case DynamicObstacleType.fallenTree:
        _voiceService.speak(const DoraVoiceLine(
          speaker: 'Dora',
          text: 'Look out! A fallen tree is blocking the path! Finding another route!',
          emoji: '🌳',
        ));
        break;
      case DynamicObstacleType.rockslide:
        _voiceService.speak(const DoraVoiceLine(
          speaker: 'Dora',
          text: 'Cuidado! A rockslide is blocking the mountain road! Finding another way!',
          emoji: '🪨',
        ));
        break;
    }
  }

  NavigationRoute? _calculateRouteFromCurrentPosition() {
    final cur = _simulationService.currentNode;
    final next = _simulationService.nextNode;

    final roadToNext = next != null ? widget.pathfinder.findRoadBetween(cur.id, next.id) : null;
    final isRoadToNextBlocked = roadToNext != null &&
        (roadToNext.blocked ||
            widget.pathfinder.dynamicObstacleManager.runtimeRoadBlocked[roadToNext.id] == true);
    final isNextNodeBlocked = next != null &&
        widget.pathfinder.dynamicObstacleManager.runtimeNodeBlocked[next.id] == true;

    // Apply route preference penalties
    final Map<String, double> roadPenalties = {};
    if (_currentRouteOption.type == RouteOptionType.swiperSafe) {
      for (final obs in widget.pathfinder.dynamicObstacleManager.activeObstacles) {
        if (obs.type == DynamicObstacleType.swiper && obs.nodeId != null) {
          final nearRoad = widget.pathfinder.findRoadBetween(cur.id, obs.nodeId!);
          if (nearRoad != null) {
            roadPenalties[nearRoad.id] = 50.0;
          }
        }
      }
    }

    // Try routing forward from next if accessible
    if (next != null && !isNextNodeBlocked && !isRoadToNextBlocked) {
      final routeFromNext = widget.pathfinder.findRoute(
        startId: next.id,
        goalId: widget.destination.id,
        roadPenalties: roadPenalties,
        isAlternative: true,
      );
      if (routeFromNext != null && routeFromNext.nodes.isNotEmpty) {
        return routeFromNext;
      }
    }

    // Otherwise route from cur
    return widget.pathfinder.findRoute(
      startId: cur.id,
      goalId: widget.destination.id,
      roadPenalties: roadPenalties,
      isAlternative: true,
    );
  }

  void _forceRerouteFromCurrentPosition() {
    final newRoute = _calculateRouteFromCurrentPosition();

    if (newRoute != null && newRoute.nodes.isNotEmpty) {
      setState(() {
        _currentNavRoute = newRoute;
        _routeStatus = NavigationRouteStatus.rerouted;
        _routeVersion++;
      });
      _simulationService.updateRoute(newRoute);
      debugPrint('[Navigation] Manual reroute successful: ${newRoute.nodeNames.join(" -> ")}');
    }
  }

  void _clearSwiper() {
    widget.pathfinder.clearSwiper();
    widget.pathfinder.dynamicObstacleManager.removeObstacle('demo_swiper');
    setState(() {
      _swiperState = null;
      _swiperLocationNode = null;
      _isSwiperHazardBypassed = true;
      _routeStatus = NavigationRouteStatus.normal;
      _routeVersion++;
    });
  }

  void _showRoadBlockDetectedModal() {
    final nextNode = _simulationService.nextNode ?? widget.destination;

    _voiceService.playRoadBlockWarning(obstacle: 'Rockslide near ${nextNode.name}');

    RoadBlockDetectedModal.show(
      context: context,
      obstacleTitle: 'Rockslide near ${nextNode.name}!',
      obstacleDescription: 'Fallen rocks are blocking the pathway!',
      distanceText: '120m',
      detourRouteName: 'Scenic Forest Bypass',
      onTakeDetour: () {
        final safeRoute = widget.pathfinder.findRoute(
          startId: _simulationService.currentNode.id,
          goalId: widget.destination.id,
          customBlockedNodes: {nextNode.id},
          isAlternative: true,
        );
        setState(() {
          _isRoadBlockActive = true;
          if (safeRoute != null && safeRoute.path.isNotEmpty) {
            _currentNavRoute = safeRoute;
            _simulationService.updateRoute(safeRoute);
            _routeVersion++;
          }
        });
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Switched to safe A* detour around roadblock! 🌟'),
            backgroundColor: Color(0xFF7E57C2),
          ),
        );
      },
      onUseBackpackTool: _openBackpack,
    );
  }

  void _onConfirmEndTrip() {
    _simulationService.pause();
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(22)),
        title: const Row(
          children: [
            Text('🛑', style: TextStyle(fontSize: 24)),
            SizedBox(width: 8),
            Text('End Adventure?', style: TextStyle(fontWeight: FontWeight.w900, fontSize: 18)),
          ],
        ),
        content: const Text(
          'Are you sure you want to exit navigation and return to the map?',
          style: TextStyle(fontSize: 14),
        ),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.of(ctx).pop();
              _simulationService.resume();
            },
            child: const Text('Keep Exploring', style: TextStyle(fontWeight: FontWeight.bold)),
          ),
          ElevatedButton(
            onPressed: () {
              _simulationService.stop();
              Navigator.of(ctx).pop();
              Navigator.of(context).pop();
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFFE53935),
              foregroundColor: Colors.white,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
            ),
            child: const Text('End Trip'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF1E0A3C),
      body: Stack(
        children: [
          // 1. Dominant Map Canvas (Takes entire screen)
          Positioned.fill(
            child: MapCanvasView(
              key: ValueKey('active_canvas_v$_routeVersion'),
              locations: widget.pathfinder.allLocations,
              allRoads: widget.pathfinder.roads,
              activeRoute: _simulationService.activeRoute,
              selectedDestination: widget.destination,
              currentLocation: _simulationService.currentNode,
              nextLocation: _simulationService.nextNode,
              simulatedDoraPosition: _simulationService.currentPosition,
              cameraMode: _cameraMode,
              showSwiperOnRoute: (_currentRouteOption.type != RouteOptionType.swiperSafe || _swiperState != null) &&
                  !_isSwiperHazardBypassed,
              swiperLocation: _swiperLocationNode,
              swiperState: _swiperState,
              onSwiperTap: () => _triggerSwiperReroute(),
              showRoadBlockOnRoute: _isRoadBlockActive,
              onRoadBlockTap: _showRoadBlockDetectedModal,
              blockedRoadIds: widget.pathfinder.blockedRoadIds,
              blockedNodeIds: widget.pathfinder.blockedNodeIds,
              dynamicObstacles: widget.pathfinder.dynamicObstacleManager.activeObstacles,
              onDynamicObstacleTap: _onDynamicObstacleTriggered,
            ),
          ),

          // 2. Small Translucent Top Header
          Positioned(
            top: 0,
            left: 0,
            right: 0,
            child: SafeArea(
              child: _buildSmallTopHeader(),
            ),
          ),

          // 3. Floating TEST OBSTACLES Developer UI
          TestObstaclesPanel(
            obstacleManager: widget.pathfinder.dynamicObstacleManager,
            onForceReroute: _forceRerouteFromCurrentPosition,
            availableNodes: widget.pathfinder.allLocations,
            availableRoads: widget.pathfinder.roads,
            getActiveRouteNodes: () => _simulationService.activeRoute.nodes
                .sublist(_simulationService.currentSegmentIndex),
            getActiveRoads: () => widget.pathfinder.roads,
          ),

          // 4. Dedicated Obstacle Alert Popup (Top-Center, compact animated overlay)
          if (_currentObstaclePopup != null)
            Positioned(
              top: 80,
              left: 16,
              right: 16,
              child: Center(
                child: ObstacleAlertPopup(
                  obstacleType: _currentObstaclePopup!.obstacleType,
                  title: _currentObstaclePopup!.title,
                  description: _currentObstaclePopup!.description,
                  icon: _currentObstaclePopup!.icon,
                  rerouting: _currentObstaclePopup!.rerouting,
                  newRouteFound: _currentObstaclePopup!.newRouteFound,
                  noRouteAvailable: _currentObstaclePopup!.noRouteAvailable,
                  routeAvailable: _currentObstaclePopup!.routeAvailable,
                ),
              ),
            ),

          // 5. Swiper Alert Pill if Swiper is detected (fallback banner if modal not active)
          if ((_currentRouteOption.type != RouteOptionType.swiperSafe || _swiperState != null) &&
              !_isSwiperHazardBypassed &&
              _swiperState != null &&
              _currentObstaclePopup == null)
            Positioned(
              top: 75,
              left: 16,
              right: 16,
              child: _buildSwiperAlertCard(),
            ),

          // 5. Single Compact Bottom Navigation Panel
          Positioned(
            bottom: 0,
            left: 0,
            right: 0,
            child: _buildCompactBottomNavPanel(),
          ),
        ],
      ),
    );
  }

  /// Small Translucent Top Header
  Widget _buildSmallTopHeader() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
        decoration: BoxDecoration(
          color: const Color(0xFF280645).withValues(alpha: 0.82),
          borderRadius: BorderRadius.circular(24),
          border: Border.all(color: Colors.white.withValues(alpha: 0.2), width: 1.2),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.35),
              blurRadius: 10,
              offset: const Offset(0, 3),
            ),
          ],
        ),
        child: Row(
          children: [
            // Small Close / End Trip Button
            InkWell(
              onTap: _onConfirmEndTrip,
              borderRadius: BorderRadius.circular(16),
              child: Container(
                padding: const EdgeInsets.all(6),
                decoration: BoxDecoration(
                  color: Colors.white.withValues(alpha: 0.2),
                  shape: BoxShape.circle,
                ),
                child: const Icon(Icons.close_rounded, color: Colors.white, size: 16),
              ),
            ),
            const SizedBox(width: 10),

            // Destination Name
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    'Navigating to',
                    style: TextStyle(
                      color: Colors.white.withValues(alpha: 0.7),
                      fontSize: 10,
                      fontWeight: FontWeight.w700,
                      letterSpacing: 0.5,
                    ),
                  ),
                  Text(
                    widget.destination.name,
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 14,
                      fontWeight: FontWeight.w900,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                ],
              ),
            ),

            // Detour badge if rerouted
            if (_routeStatus == NavigationRouteStatus.rerouted) ...[
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 3),
                decoration: BoxDecoration(
                  color: const Color(0xFFFF9800),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: const Text(
                  'DETOUR',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 9,
                    fontWeight: FontWeight.w900,
                  ),
                ),
              ),
              const SizedBox(width: 8),
            ],

            // Dora Mood & Level Pill
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
              decoration: BoxDecoration(
                color: Colors.white.withValues(alpha: 0.2),
                borderRadius: BorderRadius.circular(14),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(_currentMood.emoji, style: const TextStyle(fontSize: 13)),
                  const SizedBox(width: 4),
                  Text(
                    _currentLevel.label,
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 11,
                      fontWeight: FontWeight.w800,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  /// Compact Bottom Navigation Panel (Map-Dominant Design)
  Widget _buildCompactBottomNavPanel() {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.96),
        borderRadius: const BorderRadius.vertical(top: Radius.circular(26)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.22),
            blurRadius: 18,
            offset: const Offset(0, -4),
          ),
        ],
      ),
      child: SafeArea(
        top: false,
        child: Padding(
          padding: const EdgeInsets.fromLTRB(16, 12, 16, 10),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              // 1. Direction Icon + Live Turn Instruction + Distance to Turn
              Row(
                children: [
                  // Direction Arrow Circle
                  Container(
                    width: 42,
                    height: 42,
                    decoration: BoxDecoration(
                      color: const Color(0xFF00E676),
                      shape: BoxShape.circle,
                      boxShadow: [
                        BoxShadow(
                          color: const Color(0xFF00E676).withValues(alpha: 0.4),
                          blurRadius: 8,
                        ),
                      ],
                    ),
                    child: const Center(
                      child: Icon(
                        Icons.navigation_rounded,
                        color: Color(0xFF1B5E20),
                        size: 24,
                      ),
                    ),
                  ),
                  const SizedBox(width: 12),

                  // Current Instruction & Turn Distance
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          _simulationService.currentInstruction,
                          style: const TextStyle(
                            fontSize: 14,
                            fontWeight: FontWeight.w900,
                            color: Color(0xFF2E1065),
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                        const SizedBox(height: 2),
                        Text(
                          'In ${_simulationService.formattedDistanceToNextNode}',
                          style: const TextStyle(
                            fontSize: 12,
                            fontWeight: FontWeight.w800,
                            color: Color(0xFFE65100),
                          ),
                        ),
                      ],
                    ),
                  ),

                  // Dora Voice Guide Button
                  InkWell(
                    onTap: _onSpeakInstruction,
                    borderRadius: BorderRadius.circular(18),
                    child: Container(
                      width: 38,
                      height: 38,
                      decoration: BoxDecoration(
                        color: _isSpeaking
                            ? const Color(0xFFFFCA28)
                            : const Color(0xFFEDE7F6),
                        shape: BoxShape.circle,
                        border: Border.all(
                          color: const Color(0xFF7E57C2).withValues(alpha: 0.3),
                        ),
                      ),
                      child: Icon(
                        _isSpeaking ? Icons.volume_up_rounded : Icons.record_voice_over_rounded,
                        color: const Color(0xFF4A148C),
                        size: 20,
                      ),
                    ),
                  ),
                ],
              ),

              const Padding(
                padding: EdgeInsets.symmetric(vertical: 8),
                child: Divider(height: 1, color: Color(0xFFEEEEEE)),
              ),

              // 2. Real-Time Telemetry Bar (Elapsed Timer, Remaining Distance & ETA, Speed Pill)
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  // Real Elapsed Stopwatch Timer
                  Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      const Icon(Icons.timer_rounded, size: 16, color: Color(0xFF7E57C2)),
                      const SizedBox(width: 4),
                      Text(
                        _simulationService.formattedElapsedTime,
                        style: const TextStyle(
                          fontSize: 13,
                          fontWeight: FontWeight.w900,
                          color: Color(0xFF4A148C),
                        ),
                      ),
                    ],
                  ),

                  // Remaining Distance & Live ETA
                  Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(
                        _simulationService.formattedRemainingDistance,
                        style: const TextStyle(
                          fontSize: 13,
                          fontWeight: FontWeight.w800,
                          color: Color(0xFF212121),
                        ),
                      ),
                      const Text(' · ', style: TextStyle(color: Colors.grey, fontWeight: FontWeight.bold)),
                      Text(
                        'ETA ${_simulationService.formattedEta}',
                        style: const TextStyle(
                          fontSize: 13,
                          fontWeight: FontWeight.w800,
                          color: Color(0xFF1E88E5),
                        ),
                      ),
                    ],
                  ),

                  // Speed Multiplier Chips for Testing (1x / 2x / 5x)
                  Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [1.0, 2.0, 5.0].map((speed) {
                      final isSelected = _simulationService.speedMultiplier == speed;
                      return Padding(
                        padding: const EdgeInsets.only(left: 3),
                        child: InkWell(
                          onTap: () => _simulationService.setSpeedMultiplier(speed),
                          borderRadius: BorderRadius.circular(10),
                          child: Container(
                            padding: const EdgeInsets.symmetric(horizontal: 5, vertical: 2),
                            decoration: BoxDecoration(
                              color: isSelected ? const Color(0xFF7E57C2) : const Color(0xFFF3E5F5),
                              borderRadius: BorderRadius.circular(10),
                            ),
                            child: Text(
                              '${speed.toInt()}x',
                              style: TextStyle(
                                fontSize: 10,
                                fontWeight: FontWeight.w900,
                                color: isSelected ? Colors.white : const Color(0xFF5E35B1),
                              ),
                            ),
                          ),
                        ),
                      );
                    }).toList(),
                  ),
                ],
              ),

              const SizedBox(height: 8),

              // 3. Compact Tools Strip (Backpack, Swiper Trigger, Roadblock, Mood Selector)
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  _buildCompactToolButton(
                    icon: '🎒',
                    label: 'Backpack',
                    onTap: _openBackpack,
                    color: const Color(0xFFE0F2F1),
                  ),
                  _buildCompactToolButton(
                    icon: _swiperState != null ? '🦊❌' : '🦊',
                    label: _swiperState != null ? 'Clear Swiper' : 'Swiper',
                    onTap: () {
                      if (_swiperState != null) {
                        _clearSwiper();
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(
                            content: Text('Swiper cleared! Restored normal path. 🌟'),
                            backgroundColor: Color(0xFF43A047),
                          ),
                        );
                      } else {
                        _triggerSwiperReroute();
                      }
                    },
                    color: _swiperState != null ? const Color(0xFFFFEBEE) : const Color(0xFFFFF3E0),
                  ),
                  _buildCompactToolButton(
                    icon: '🚧',
                    label: 'Roadblock',
                    onTap: _showRoadBlockDetectedModal,
                    color: const Color(0xFFFFF8E1),
                  ),
                  _buildCompactToolButton(
                    icon: '🎨',
                    label: 'Route Mode',
                    onTap: _onChangeMoodOrRoute,
                    color: const Color(0xFFEDE7F6),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildCompactToolButton({
    required String icon,
    required String label,
    required VoidCallback onTap,
    required Color color,
  }) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(12),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
        decoration: BoxDecoration(
          color: color,
          borderRadius: BorderRadius.circular(12),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(icon, style: const TextStyle(fontSize: 14)),
            const SizedBox(width: 4),
            Text(
              label,
              style: const TextStyle(
                fontSize: 11,
                fontWeight: FontWeight.w800,
                color: Color(0xFF37474F),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSwiperAlertCard() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      decoration: BoxDecoration(
        color: const Color(0xFFFFEBEE),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: const Color(0xFFEF5350), width: 1.5),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.15),
            blurRadius: 8,
          ),
        ],
      ),
      child: Row(
        children: [
          const Text('🦊', style: TextStyle(fontSize: 20)),
          const SizedBox(width: 8),
          Expanded(
            child: Text(
              _swiperLocationNode != null
                  ? 'Swiper Sighted near ${_swiperLocationNode!.name}! Dynamic detour active.'
                  : 'Swiper Alert Ahead! Detour active.',
              style: const TextStyle(
                fontSize: 11,
                fontWeight: FontWeight.w900,
                color: Color(0xFFC62828),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
