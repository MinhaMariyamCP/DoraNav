import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_application_1/services/audio_service.dart';
import 'package:flutter_application_1/controllers/celebration_controller.dart';
import 'package:flutter_application_1/widgets/fiesta_trio/fiesta_character_one.dart';
import 'package:flutter_application_1/widgets/fiesta_trio/fiesta_character_two.dart';
import 'package:flutter_application_1/widgets/fiesta_trio/fiesta_character_three.dart';
import 'package:flutter_application_1/widgets/fiesta_trio/fiesta_trio_character.dart';
import 'package:flutter_application_1/widgets/fiesta_trio/fiesta_trio_effects.dart';
import 'package:flutter_application_1/widgets/fiesta_trio/fiesta_trio_celebration.dart';
import 'package:flutter_application_1/screens/adventure_report/models/trip_data.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  setUpAll(() {
    TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
        .setMockMethodCallHandler(
      const MethodChannel('xyz.luan/audioplayers.global'),
      (methodCall) async => 1,
    );
    TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
        .setMockMethodCallHandler(
      const MethodChannel('xyz.luan/audioplayers'),
      (methodCall) async => 1,
    );
  });

  group('AudioService Graceful Fallback Tests', () {
    test('Handles audio playback controls safely without crashing', () async {
      final audio = AudioService.instance;

      // None of these should throw unhandled exceptions
      await audio.playBackgroundMusic();
      await audio.pauseBackgroundMusic();
      await audio.resumeBackgroundMusic();
      await audio.playAdventureCompleteMusic();
      await audio.stopAllMusic();
    });

    test('Ducking and restoring background music behavior', () async {
      final audio = AudioService.instance;

      // When background music is not playing, ducking silently no-ops
      await audio.duckBackgroundMusic();
      expect(audio.isDucking, isFalse);

      await audio.setVolume(0.8);
      expect(audio.backgroundVolume, 0.8);

      // Test speakWithDucking helper
      bool spoke = false;
      await audio.speakWithDucking(() async {
        spoke = true;
      });
      expect(spoke, isTrue);
      expect(audio.isDucking, isFalse);
    });
  });

  group('FiestaTrioCharacter Component Tests', () {
    testWidgets('Renders Character 1 (Grasshopper / Accordion)', (tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: Center(child: FiestaTrioCharacter.one()),
          ),
        ),
      );

      expect(find.text('Accordion'), findsOneWidget);
      expect(find.text('🪗'), findsOneWidget);
    });

    testWidgets('Renders Character 2 (Snail / Snare Drum)', (tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: Center(child: FiestaTrioCharacter.two()),
          ),
        ),
      );

      expect(find.text('Snare Drum'), findsOneWidget);
      expect(find.text('🥁'), findsOneWidget);
    });

    testWidgets('Renders Character 3 (Frog / Trumpet)', (tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: Center(child: FiestaTrioCharacter.three()),
          ),
        ),
      );

      expect(find.text('Trumpet'), findsOneWidget);
      expect(find.text('🎺'), findsOneWidget);
    });

    testWidgets('Renders Native FiestaCharacterOne (Frog Drummer)', (tester) async {
      final anim = AlwaysStoppedAnimation(Offset.zero);
      final doubleAnim = AlwaysStoppedAnimation(1.0);

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: Center(
              child: FiestaCharacterOne(
                entranceSlide: anim,
                bodyBounce: doubleAnim,
                performanceLoop: doubleAnim,
              ),
            ),
          ),
        ),
      );

      expect(find.byType(FiestaCharacterOne), findsOneWidget);
    });

    testWidgets('Renders Native FiestaCharacterTwo (Grasshopper Accordion)', (tester) async {
      final anim = AlwaysStoppedAnimation(Offset.zero);
      final doubleAnim = AlwaysStoppedAnimation(1.0);

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: Center(
              child: FiestaCharacterTwo(
                entranceSlide: anim,
                entranceScale: doubleAnim,
                entranceFade: doubleAnim,
                bodyBounce: doubleAnim,
                performanceLoop: doubleAnim,
              ),
            ),
          ),
        ),
      );

      expect(find.byType(FiestaCharacterTwo), findsOneWidget);
    });

    testWidgets('Renders Native FiestaCharacterThree (Snail Cymbals)', (tester) async {
      final anim = AlwaysStoppedAnimation(Offset.zero);
      final doubleAnim = AlwaysStoppedAnimation(1.0);

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: Center(
              child: FiestaCharacterThree(
                entranceSlide: anim,
                bodyBounce: doubleAnim,
                performanceLoop: doubleAnim,
              ),
            ),
          ),
        ),
      );

      expect(find.byType(FiestaCharacterThree), findsOneWidget);
    });

    testWidgets('Renders Authentic Trio with Active Instrument Playing Animations', (tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: Row(
              children: [
                FiestaTrioCharacter.frog(playProgress: 0.5),
                FiestaTrioCharacter.snail(playProgress: 0.5),
                FiestaTrioCharacter.grasshopper(playProgress: 0.5),
              ],
            ),
          ),
        ),
      );

      // Verify that instrument names render in fallback & layout
      expect(find.text('Trumpet'), findsOneWidget);
      expect(find.text('Snare Drum'), findsOneWidget);
      expect(find.text('Triangle'), findsOneWidget);
    });
  });

  group('FiestaTrioEffects Tests', () {
    testWidgets('Paints sparkles, notes, and confetti without exception', (tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(
            body: SizedBox(
              width: 400,
              height: 600,
              child: FiestaTrioEffects(animationProgress: 0.5),
            ),
          ),
        ),
      );

      expect(find.byType(FiestaTrioEffects), findsOneWidget);
      expect(find.byType(CustomPaint), findsWidgets);
    });
  });

  group('CelebrationController Timeline Tests', () {
    test('Manages lifecycle phases and skip action', () {
      final controller = CelebrationController();

      controller.startCelebration(
        toastDuration: const Duration(milliseconds: 50),
        entranceDuration: const Duration(milliseconds: 50),
        performanceDuration: const Duration(milliseconds: 100),
      );

      expect(controller.isToast, isTrue);

      controller.skipCelebration();
      expect(controller.isCompleted, isTrue);

      controller.dispose();
    });

    test('Respects reduce motion and skips straight to performance', () {
      final controller = CelebrationController();

      controller.startCelebration(
        reduceMotion: true,
        performanceDuration: const Duration(milliseconds: 100),
      );

      expect(controller.isPerforming, isTrue);
      controller.dispose();
    });
  });

  group('FiestaTrioCelebration Widget Tests', () {
    testWidgets('Renders celebration toast, characters, and triggers onComplete on skip',
        (tester) async {
      bool completed = false;
      final trip = TripData.witchsCastleMock;

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: FiestaTrioCelebration(
              destinationName: "King's Castle",
              tripData: trip,
              onComplete: () => completed = true,
            ),
          ),
        ),
      );

      await tester.pump();

      // Verify header & destination title
      expect(find.text('ADVENTURE COMPLETE!'), findsOneWidget);
      expect(find.text("You reached King's Castle!"), findsOneWidget);

      // Verify Skip button exists
      final skipBtn = find.text('Skip');
      expect(skipBtn, findsOneWidget);

      // Tap skip to advance directly
      await tester.tap(skipBtn);
      await tester.pump(const Duration(milliseconds: 50));

      expect(completed, isTrue);
    });
  });
}
