import 'package:flutter/material.dart';
import 'screens/backpack/backpack_screen.dart';
import 'screens/map/map_screen.dart';
import 'screens/splash/models/splash_config.dart';
import 'screens/splash/splash_screen.dart';
import 'services/audio_service.dart';
import 'themes/app_theme.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await AudioService.instance.initialize();
  runApp(const DoraNavApp());
}

class DoraNavApp extends StatelessWidget {
  const DoraNavApp({super.key});

  @override
  Widget build(BuildContext context) {
    final navigatorKey = GlobalKey<NavigatorState>();

    return MaterialApp(
      title: 'DoraNav',
      debugShowCheckedModeBanner: false,
      navigatorKey: navigatorKey,
      theme: DoraNavTheme.theme,
      initialRoute: '/',
      routes: {
        '/': (_) => SplashScreen(
              config: const SplashConfig(
                duration: Duration(milliseconds: 1500),
                autoNavigate: true,
              ),
              onAdventureReady: () {
                navigatorKey.currentState?.pushReplacementNamed('/map');
              },
            ),
        '/map': (_) => const MapScreen(),
        '/backpack': (_) => const BackpackScreen(),
      },
    );
  }
}
