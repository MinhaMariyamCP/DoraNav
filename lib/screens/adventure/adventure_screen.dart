import 'package:flutter/material.dart';
import '../../themes/app_theme.dart';

class AdventureScreen extends StatelessWidget {
  const AdventureScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.twilightDark,
      appBar: AppBar(
        title: const Text('DoraNav Adventure Map'),
        backgroundColor: AppColors.deepPurple,
        foregroundColor: AppColors.textLight,
      ),
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(
                Icons.explore_rounded,
                size: 96,
                color: AppColors.starBright,
              ),
              const SizedBox(height: 24),
              Text(
                'Your adventure starts here!',
                textAlign: TextAlign.center,
                style: AppTypography.subtitle.copyWith(
                  fontSize: 28,
                  color: AppColors.textLight,
                ),
              ),
              const SizedBox(height: 12),
              const Text(
                'Choose a destination and discover Dora\'s world.',
                textAlign: TextAlign.center,
                style: TextStyle(
                  color: AppColors.textLight,
                  fontSize: 16,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
