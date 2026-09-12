import 'dart:async';
import 'package:audioplayers/audioplayers.dart';
import 'package:flutter/foundation.dart';

/// Centralized audio service for DoraNav using audioplayers.
///
/// Features:
/// 1. Background exploration music (loops continuously at ~28% volume).
/// 2. Fiesta Trio fanfare (plays once when arriving at destination).
/// 3. Smooth fading out of background music before celebration starts.
/// 4. Dynamic ducking to 12% during Dora voice lines with smooth restoration.
/// 5. Safe exception handling so audio playback failures never crash the app.
class AudioService {
  AudioService._();

  static final AudioService instance = AudioService._();
  factory AudioService() => instance;

  AudioPlayer? _bgPlayerInstance;
  AudioPlayer? _fiestaPlayerInstance;

  AudioPlayer _createPlayerSafely() {
    try {
      return AudioPlayer();
    } catch (e) {
      if (kDebugMode) {
        print('[AUDIO] AudioPlayer creation fallback: ');
      }
      return _MockAudioPlayer();
    }
  }

  AudioPlayer get _backgroundPlayer => _bgPlayerInstance ??= _createPlayerSafely();
  AudioPlayer get _fiestaPlayer => _fiestaPlayerInstance ??= _createPlayerSafely();

  // In audioplayers, AssetSource takes relative path inside assets/
  static const String _backgroundMusicAsset = 'audio/background_music.mp3';
  static const String _fiestaMusicAsset = 'audio/fiesta_trio.mp3';

  static const double _defaultBackgroundVolume = 0.28;
  static const double _defaultFiestaVolume = 0.85;

  bool _backgroundPlaying = false;
  bool _fiestaPlaying = false;
  double _currentBgVolume = _defaultBackgroundVolume;

  // ---------------------------------------------------------------
  // DUCKING STATE
  // ---------------------------------------------------------------
  bool _isDucking = false;
  double _preDuckVolume = _defaultBackgroundVolume;
  static const double duckedVolume = 0.12;
  static const Duration duckFadeDuration = Duration(milliseconds: 250);

  bool get isBackgroundMusicPlaying => _backgroundPlaying;
  bool get isAdventureMusicPlaying => _fiestaPlaying;
  bool get isDucking => _isDucking;
  double get backgroundVolume => _currentBgVolume;
  double get currentVolume => _currentBgVolume;

  /// Initializes player release modes and volume levels
  Future<void> initialize() async {
    try {
      await _backgroundPlayer.setReleaseMode(ReleaseMode.loop);
      await _fiestaPlayer.setReleaseMode(ReleaseMode.stop);

      await _backgroundPlayer.setVolume(_defaultBackgroundVolume);
      await _fiestaPlayer.setVolume(_defaultFiestaVolume);

      if (kDebugMode) {
        print('[AUDIO] AudioService initialized successfully');
      }
    } catch (e) {
      if (kDebugMode) {
        print('[AUDIO ERROR] Initialize failed: ');
      }
    }
  }

  /// Sets background volume (clamped between 0.0 and 1.0)
  Future<void> setVolume(double volume) async {
    _currentBgVolume = volume.clamp(0.0, 1.0);
    try {
      await _backgroundPlayer.setVolume(_currentBgVolume);
    } catch (_) {}
  }

  // ==============================
  // BACKGROUND MUSIC
  // ==============================

  /// Starts or restarts the continuous background exploration music
  Future<void> startBackgroundMusic() async {
    try {
      if (_backgroundPlaying) return;

      // Do not start background music if Fiesta Trio is actively playing
      if (_fiestaPlaying) return;

      _currentBgVolume = _defaultBackgroundVolume;
      await _backgroundPlayer.setReleaseMode(ReleaseMode.loop);
      await _backgroundPlayer.setVolume(_defaultBackgroundVolume);
      await _backgroundPlayer.play(AssetSource(_backgroundMusicAsset));

      _backgroundPlaying = true;

      if (kDebugMode) {
        print('🎵 Background music started');
      }
    } catch (e) {
      if (kDebugMode) {
        print('❌ Background music error: ');
      }
    }
  }

  /// Alias for backward compatibility
  Future<void> playBackgroundMusic({double volume = _defaultBackgroundVolume}) async {
    await startBackgroundMusic();
  }

  Future<void> pauseBackgroundMusic() async {
    try {
      await _backgroundPlayer.pause();
      _backgroundPlaying = false;

      if (kDebugMode) {
        print('⏸️ Background music paused');
      }
    } catch (e) {
      if (kDebugMode) {
        print('❌ Pause error: ');
      }
    }
  }

  Future<void> resumeBackgroundMusic() async {
    try {
      if (_fiestaPlaying) return;

      await _backgroundPlayer.resume();
      _backgroundPlaying = true;

      if (kDebugMode) {
        print('▶️ Background music resumed');
      }
    } catch (e) {
      if (kDebugMode) {
        print('❌ Resume error: ');
      }
    }
  }

  Future<void> stopBackgroundMusic() async {
    try {
      await _backgroundPlayer.stop();
      _backgroundPlaying = false;

      if (kDebugMode) {
        print('⏹️ Background music stopped');
      }
    } catch (e) {
      if (kDebugMode) {
        print('❌ Stop background error: ');
      }
    }
  }

  // ==============================
  // FADE OUT BACKGROUND MUSIC
  // ==============================

  Future<void> fadeOutBackgroundMusic({Duration duration = const Duration(milliseconds: 800)}) async {
    try {
      const int steps = 16;
      final stepDelay = Duration(milliseconds: duration.inMilliseconds ~/ steps);

      for (int i = steps; i >= 0; i--) {
        final double volume = _currentBgVolume * (i / steps);
        await setVolume(volume);
        await Future.delayed(stepDelay);
      }

      await _backgroundPlayer.stop();
      await setVolume(_defaultBackgroundVolume);
      _backgroundPlaying = false;

      if (kDebugMode) {
        print('🔉 Background music faded out');
      }
    } catch (e) {
      if (kDebugMode) {
        print('❌ Fade error: ');
      }
    }
  }

  // ==============================
  // FIESTA TRIO MUSIC
  // ==============================

  Future<void> playFiestaTrio() async {
    try {
      if (kDebugMode) {
        print('🎉 FIESTA TRIO ARRIVING!');
      }

      // Stop/fade background music first
      if (_backgroundPlaying) {
        await fadeOutBackgroundMusic();
      }

      // Prevent previous Fiesta music from continuing/overlapping
      await _fiestaPlayer.stop();
      await _fiestaPlayer.setReleaseMode(ReleaseMode.stop);
      await _fiestaPlayer.setVolume(_defaultFiestaVolume);
      await _fiestaPlayer.play(AssetSource(_fiestaMusicAsset));

      _fiestaPlaying = true;

      if (kDebugMode) {
        print('🎺🥁🎵 Fiesta Trio music started');
      }
    } catch (e) {
      if (kDebugMode) {
        print('❌ Fiesta Trio music error: ');
      }
    }
  }

  /// Alias for backward compatibility
  Future<void> playAdventureCompleteMusic({double volume = _defaultFiestaVolume}) async {
    await playFiestaTrio();
  }

  Future<void> stopFiestaTrio() async {
    try {
      await _fiestaPlayer.stop();
      _fiestaPlaying = false;

      if (kDebugMode) {
        print('⏹️ Fiesta Trio music stopped');
      }
    } catch (e) {
      if (kDebugMode) {
        print('❌ Stop Fiesta error: ');
      }
    }
  }

  // ==============================
  // STOP EVERYTHING
  // ==============================

  Future<void> stopAllMusic() async {
    try {
      await _backgroundPlayer.stop();
      await _fiestaPlayer.stop();

      _backgroundPlaying = false;
      _fiestaPlaying = false;

      if (kDebugMode) {
        print('🔇 All music stopped');
      }
    } catch (e) {
      if (kDebugMode) {
        print('❌ Stop all error: ');
      }
    }
  }

  // ==============================
  // RETURN TO ADVENTURE
  // ==============================

  Future<void> returnToAdventureMusic() async {
    await stopFiestaTrio();
    await startBackgroundMusic();
  }

  // ==============================
  // DUCKING METHODS
  // ==============================

  Future<void> duckBackgroundMusic() async {
    try {
      if (!_backgroundPlaying || _fiestaPlaying) return;
      if (_isDucking) return;

      _isDucking = true;
      _preDuckVolume = _currentBgVolume;

      const steps = 8;
      final stepDelay = Duration(milliseconds: duckFadeDuration.inMilliseconds ~/ steps);

      for (int i = 0; i <= steps; i++) {
        final t = i / steps;
        final volume = _preDuckVolume - ((_preDuckVolume - duckedVolume) * t);
        await setVolume(volume);
        await Future.delayed(stepDelay);
      }

      await setVolume(duckedVolume);

      if (kDebugMode) {
        print('[AUDIO] Ducked for Dora voice 🔉');
      }
    } catch (e) {
      if (kDebugMode) {
        print('[AUDIO ERROR] Duck background: ');
      }
    }
  }

  Future<void> restoreBackgroundMusic() async {
    try {
      if (!_isDucking) return;

      if (!_backgroundPlaying || _fiestaPlaying) {
        _isDucking = false;
        return;
      }

      const steps = 8;
      final stepDelay = Duration(milliseconds: duckFadeDuration.inMilliseconds ~/ steps);

      for (int i = 0; i <= steps; i++) {
        final t = i / steps;
        final volume = duckedVolume + ((_preDuckVolume - duckedVolume) * t);
        await setVolume(volume);
        await Future.delayed(stepDelay);
      }

      await setVolume(_preDuckVolume);
      _isDucking = false;

      if (kDebugMode) {
        print('[AUDIO] Restored background volume 🔊');
      }
    } catch (e) {
      if (kDebugMode) {
        print('[AUDIO ERROR] Restore background: ');
      }
    }
  }

  Future<void> speakWithDucking(Future<void> Function() speakAction) async {
    await duckBackgroundMusic();
    try {
      await speakAction();
    } finally {
      await restoreBackgroundMusic();
    }
  }

  // ==============================
  // DISPOSE
  // ==============================

  Future<void> dispose() async {
    try {
      await _bgPlayerInstance?.dispose();
      await _fiestaPlayerInstance?.dispose();
    } catch (_) {}
  }
}

/// Fallback mock player for environments without platform channel implementation
class _MockAudioPlayer implements AudioPlayer {
  @override
  dynamic noSuchMethod(Invocation invocation) => Future.value();
}
