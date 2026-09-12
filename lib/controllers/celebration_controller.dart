import 'dart:async';
import 'package:flutter/foundation.dart';
import '../services/audio_service.dart';

/// Celebration lifecycle phases
enum CelebrationPhase {
  toast, // Phase 1: "🎉 We Made It!" toast
  entrances, // Phase 2: Staggered Fiesta Trio entrances
  performance, // Phase 3: Looping musical concert & visual effects
  completed, // Handoff to Adventure Complete / Travel Report
}

/// Controller orchestrating the celebration sequence, phase timing,
/// audio synchronization, and skip actions.
class CelebrationController extends ChangeNotifier {
  CelebrationPhase _phase = CelebrationPhase.toast;
  bool _isDisposed = false;
  Timer? _phaseTimer;
  Timer? _performanceTimer;

  CelebrationPhase get phase => _phase;
  bool get isToast => _phase == CelebrationPhase.toast;
  bool get isEntrances => _phase == CelebrationPhase.entrances;
  bool get isPerforming => _phase == CelebrationPhase.performance;
  bool get isCompleted => _phase == CelebrationPhase.completed;

  /// Starts the automated celebration timeline
  void startCelebration({
    Duration toastDuration = const Duration(milliseconds: 900),
    Duration entranceDuration = const Duration(milliseconds: 1400),
    Duration performanceDuration = const Duration(milliseconds: 4500),
    bool reduceMotion = false,
  }) {
    if (_isDisposed) return;

    // Fade out background music and start Fiesta Trio fanfare
    AudioService.instance.playFiestaTrio();

    if (reduceMotion) {
      // With reduced motion, transition directly to steady celebration
      _phase = CelebrationPhase.performance;
      notifyListeners();
      _performanceTimer = Timer(performanceDuration, finishCelebration);
      return;
    }

    _phase = CelebrationPhase.toast;
    notifyListeners();

    // Transition from Phase 1 (Toast) to Phase 2 (Entrances)
    _phaseTimer = Timer(toastDuration, () {
      if (_isDisposed) return;
      _phase = CelebrationPhase.entrances;
      notifyListeners();

      // Transition from Phase 2 (Entrances) to Phase 3 (Performance)
      _phaseTimer = Timer(entranceDuration, () {
        if (_isDisposed) return;
        _phase = CelebrationPhase.performance;
        notifyListeners();

        // Auto-complete after performance duration
        _performanceTimer = Timer(performanceDuration, finishCelebration);
      });
    });
  }

  /// Skips directly to completion
  void skipCelebration() {
    finishCelebration();
  }

  /// Completes celebration, stops fanfare audio, and notifies listeners
  void finishCelebration() {
    if (_isDisposed || _phase == CelebrationPhase.completed) return;

    _phaseTimer?.cancel();
    _performanceTimer?.cancel();
    _phase = CelebrationPhase.completed;

    AudioService.instance.stopAllMusic();
    AudioService.instance.resumeBackgroundMusic();

    notifyListeners();
  }

  @override
  void dispose() {
    _isDisposed = true;
    _phaseTimer?.cancel();
    _performanceTimer?.cancel();
    AudioService.instance.stopAllMusic();
    super.dispose();
  }
}
