# Active Navigation Real-Time Simulation

This document describes the real-time continuous navigation simulation architecture in **DoraNav**, including movement interpolation, speed configuration, camera follow, and rerouting behavior.

---

## Architecture Overview

The Active Navigation system decouples pathfinding from real-time movement and presentation:

```
┌────────────────────────────────────────────────────────┐
│              A* Graph Navigation Engine                │
│    (Calculates optimal route nodes & edge sequences)   │
└──────────────────────────┬─────────────────────────────┘
                           │ NavigationRoute
                           ▼
┌────────────────────────────────────────────────────────┐
│             NavigationSimulationService                │
│  - Continuous coordinate interpolation (60 Hz)         │
│  - Real-time journey Stopwatch (elapsed time)          │
│  - Live continuous distance & dynamic ETA              │
│  - Seamless dynamic rerouting from current position    │
└──────────────┬──────────────────────────┬──────────────┘
               │ currentPosition          │ State updates
               ▼                          ▼
┌──────────────────────────────┐ ┌───────────────────────┐
│     MapCanvasView            │ │ ActiveNavigationScreen│
│  - Dora avatar at continuous │ │  - Compact bottom bar │
│    pixel coordinates         │ │  - Minimal top header │
│  - Camera follow with soft   │ │  - Speed toggles      │
│    damping (no jitter)       │ │  - Event fanfare      │
└──────────────────────────────┘ └───────────────────────┘
```

1. **A\* Engine & Graph (`NavigationEngine`, `GraphEngine`)**: Remains the single source of truth for routing decisions and obstacle avoidance.
2. **`NavigationSimulationService` (`lib/services/navigation_simulation_service.dart`)**: Consumes the active `NavigationRoute` and smoothly moves Dora along edges using simulated continuous time ticks without teleportation.
3. **`MapCanvasView` (`lib/screens/map/widgets/map_canvas_view.dart`)**: Renders Dora at exact continuous coordinates (`simulatedDoraPosition`) and applies soft camera tracking centered in the lower-middle viewport.
4. **`ActiveNavigationScreen` (`lib/screens/navigation/active_navigation_screen.dart`)**: Presents a map-dominant experience with a single compact bottom navigation panel and small top header. The legacy manual "Next Place" button is completely eliminated in favor of continuous automated waypoint progression.

---

## Key Parameters & Configuration

| Parameter | Location | Default Value | Description |
|---|---|---|---|
| `defaultSimulatedSpeed` | `NavigationSimulationService` | `45.0` m/s | Base simulated movement speed (~160 km/h in scaled world units for snappy demo traversal). |
| `metersPerMapUnit` | `NavigationSimulationService` | `50.0` m/unit | Scale conversion factor between graph coordinates and physical meters. |
| `_tickInterval` | `NavigationSimulationService` | `16` ms | Simulation update rate (~60 updates per second) for smooth frame interpolation. |
| `speedMultiplier` | `NavigationSimulationService` | `1.0` (toggleable `1x`, `2x`, `5x`) | Multiplier applied to `baseSpeed` for quick testing and fast-forwarding journeys. |
| Camera Damping Factor `t` | `MapCanvasView` | `0.18` | Exponential smoothing factor for camera follow interpolation to eliminate abrupt snap movements. |

---

## Dynamic Rerouting Behavior

When obstacles appear (e.g., Swiper or a Roadblock):
1. Obstacle avoidance logic generates a new `NavigationRoute` avoiding the blocked edge or node.
2. `NavigationSimulationService.updateRoute(newRoute)` is invoked.
3. The service prepends a virtual waypoint at Dora's **exact live continuous coordinate** (`_currentPosition`), seamlessly connecting to the nearest valid node on the new route.
4. **The elapsed journey stopwatch is preserved**; it does not reset or jump back to the starting point.

---

## Running and Testing

### Unit Tests
Run simulation service tests directly:
```bash
flutter test test/navigation_simulation_service_test.dart
```

### Full Test Suite
Run the complete suite of tests:
```bash
flutter test
```

### Analyze Code
Verify static analysis passes cleanly:
```bash
flutter analyze
```
