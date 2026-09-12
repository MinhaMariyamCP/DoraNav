import 'package:flutter/material.dart';
import '../theme/backpack_theme.dart';
import 'backpack_illustrations.dart';

/// State 2: Dora / Boots searching & thinking state.
/// Shows Boots thinking with bouncy animated dots.
class SearchingSpeakingView extends StatefulWidget {
  final String query;
  const SearchingSpeakingView({super.key, this.query = 'Thinking...'});

  @override
  State<SearchingSpeakingView> createState() => _SearchingSpeakingViewState();
}

class _SearchingSpeakingViewState extends State<SearchingSpeakingView>
    with SingleTickerProviderStateMixin {
  late AnimationController _dotsController;

  @override
  void initState() {
    super.initState();
    _dotsController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1000),
    )..repeat();
  }

  @override
  void dispose() {
    _dotsController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Center(
      child: SingleChildScrollView(
        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 30),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            // Boots thinking avatar
            const BootsThinkingWidget(size: 130),
            const SizedBox(height: 20),

            const Text(
              'Thinking... finding the best\nthings for our adventure!',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w800,
                color: BackpackColors.textDark,
                height: 1.35,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 20),

            // Animated 3 bouncy dots
            AnimatedBuilder(
              animation: _dotsController,
              builder: (context, child) {
                return Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: List.generate(3, (index) {
                    final delay = index * 0.2;
                    final progress = (_dotsController.value - delay).clamp(0.0, 1.0);
                    final bounce = (progress * 2 - 1).abs(); // 0 -> 1 -> 0
                    final offset = -8.0 * (1.0 - bounce);

                    return Transform.translate(
                      offset: Offset(0, offset),
                      child: Container(
                        margin: const EdgeInsets.symmetric(horizontal: 5),
                        width: 12,
                        height: 12,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          color: index == 1
                              ? BackpackColors.primaryPurple
                              : BackpackColors.softPurple,
                        ),
                      ),
                    );
                  }),
                );
              },
            ),
          ],
        ),
      ),
    );
  }
}
