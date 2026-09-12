import 'dart:async';
import 'package:flutter/foundation.dart';
import 'audio_service.dart';

/// Spoken voice line model
class DoraVoiceLine {
  final String speaker; // 'Dora', 'The Map', 'Boots'
  final String text;
  final String spanishText;
  final String emoji;
  final Duration duration;

  const DoraVoiceLine({
    required this.speaker,
    required this.text,
    this.spanishText = '',
    required this.emoji,
    this.duration = const Duration(seconds: 4),
  });
}

/// Central audio and voice guide service for DoraNav.
/// Provides spoken cues, theme jingles, hazard alerts, and reactive stream for UI soundwaves.
class DoraVoiceService extends ChangeNotifier {
  static final DoraVoiceService _instance = DoraVoiceService._internal();
  factory DoraVoiceService() => _instance;
  DoraVoiceService._internal();

  DoraVoiceLine? _currentLine;
  bool _isSpeaking = false;
  Timer? _dismissTimer;

  DoraVoiceLine? get currentLine => _currentLine;
  bool get isSpeaking => _isSpeaking;

  /// Speaks a custom voice line, ducks background music, and restores volume upon completion
  void speak(DoraVoiceLine line) {
    _dismissTimer?.cancel();
    _currentLine = line;
    _isSpeaking = true;
    notifyListeners();

    // Duck background music while Dora / The Map speaks
    AudioService.instance.duckBackgroundMusic();

    _dismissTimer = Timer(line.duration, () {
      _isSpeaking = false;
      notifyListeners();
      // Restore background music once voice line completes
      AudioService.instance.restoreBackgroundMusic();
    });
  }

  /// Cancels any active speech and restores background music
  void stopSpeaking() {
    _dismissTimer?.cancel();
    _isSpeaking = false;
    _currentLine = null;
    notifyListeners();
    AudioService.instance.restoreBackgroundMusic();
  }

  /// Iconic "I'm the Map!" theme song melody & spoken line
  void playMapSong() {
    speak(const DoraVoiceLine(
      speaker: 'The Map',
      text: "I'm the Map, I'm the Map! If there's a place you gotta go, I'm the one you need to know!",
      spanishText: "¡Soy el Mapa! ¡Dime a dónde quieres ir!",
      emoji: '🗺️',
      duration: Duration(seconds: 5),
    ));
  }

  /// Swiper warning voice line
  void playSwiperWarning() {
    speak(const DoraVoiceLine(
      speaker: 'Dora & Boots',
      text: "Swiper, no swiping! Swiper, no swiping! Swiper, NO SWIPING!",
      spanishText: "¡Zorro, no te lo lleves!",
      emoji: '🦊',
      duration: Duration(seconds: 4),
    ));
  }

  /// Road block hazard warning voice line
  void playRoadBlockWarning({String obstacle = 'Rockslide'}) {
    speak(DoraVoiceLine(
      speaker: 'Dora',
      text: "¡Cuidado! There's a $obstacle blocking our path! Let's check the map for a safe detour!",
      spanishText: "¡Cuidado con el obstáculo! ¡Busquemos otra ruta!",
      emoji: '🚧',
      duration: const Duration(seconds: 5),
    ));
  }

  /// Turn-by-turn guidance voice line
  void playTurnGuidance(String instruction) {
    speak(DoraVoiceLine(
      speaker: 'The Map',
      text: "Next checkpoint: $instruction! Keep going, explorer!",
      spanishText: "¡Siguiente parada en el camino!",
      emoji: '🧭',
      duration: const Duration(seconds: 4),
    ));
  }

  /// Arrival celebration fanfare
  void playArrivalCelebration(String destinationName) {
    speak(DoraVoiceLine(
      speaker: 'Dora',
      text: "¡Lo hicimos! We did it! We safely arrived at $destinationName! ¡Hurra!",
      spanishText: "¡Lo hicimos! ¡Llegamos a nuestro destino!",
      emoji: '🌟',
      duration: const Duration(seconds: 5),
    ));
  }
}
