import 'dart:math' as math;
import 'package:flutter/material.dart';
import '../../services/dora_voice_service.dart';

/// Floating Dora Voice Speech Bubble Banner with animated audio soundwaves
class DoraSpeechBanner extends StatefulWidget {
  final DoraVoiceService voiceService;

  const DoraSpeechBanner({
    super.key,
    required this.voiceService,
  });

  @override
  State<DoraSpeechBanner> createState() => _DoraSpeechBannerState();
}

class _DoraSpeechBannerState extends State<DoraSpeechBanner>
    with SingleTickerProviderStateMixin {
  late AnimationController _waveController;

  @override
  void initState() {
    super.initState();
    _waveController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 600),
    )..repeat(reverse: true);
  }

  @override
  void dispose() {
    _waveController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return ListenableBuilder(
      listenable: widget.voiceService,
      builder: (context, _) {
        final isSpeaking = widget.voiceService.isSpeaking;
        final currentLine = widget.voiceService.currentLine;

        if (!isSpeaking || currentLine == null) {
          return const SizedBox.shrink();
        }

        return AnimatedContainer(
          duration: const Duration(milliseconds: 300),
          curve: Curves.easeOutBack,
          margin: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
          padding: const EdgeInsets.fromLTRB(14, 10, 10, 10),
          decoration: BoxDecoration(
            color: const Color(0xFF4A148C),
            borderRadius: BorderRadius.circular(20),
            border: Border.all(color: const Color(0xFFFFD54F), width: 2),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: 0.3),
                blurRadius: 12,
                offset: const Offset(0, 4),
              ),
            ],
          ),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              // 1. Speaker Avatar
              Container(
                width: 44,
                height: 44,
                decoration: const BoxDecoration(
                  shape: BoxShape.circle,
                  color: Color(0xFFFFF9C4),
                ),
                child: Center(
                  child: Text(currentLine.emoji, style: const TextStyle(fontSize: 24)),
                ),
              ),
              const SizedBox(width: 10),

              // 2. Speech content
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Row(
                      children: [
                        Text(
                          currentLine.speaker,
                          style: const TextStyle(
                            color: Color(0xFFFFD54F),
                            fontWeight: FontWeight.w900,
                            fontSize: 12,
                            letterSpacing: 0.5,
                          ),
                        ),
                        const SizedBox(width: 8),
                        // Sound waves
                        _buildSoundwaves(),
                      ],
                    ),
                    const SizedBox(height: 2),
                    Text(
                      currentLine.text,
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 12,
                        fontWeight: FontWeight.w700,
                        height: 1.2,
                      ),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                    if (currentLine.spanishText.isNotEmpty) ...[
                      const SizedBox(height: 2),
                      Text(
                        currentLine.spanishText,
                        style: const TextStyle(
                          color: Color(0xFFCE93D8),
                          fontSize: 10.5,
                          fontStyle: FontStyle.italic,
                          fontWeight: FontWeight.w500,
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ],
                  ],
                ),
              ),
              const SizedBox(width: 6),

              // 3. Close / Mute Button
              IconButton(
                icon: const Icon(Icons.close_rounded, color: Colors.white70, size: 18),
                onPressed: () => widget.voiceService.stopSpeaking(),
                padding: EdgeInsets.zero,
                constraints: const BoxConstraints(),
                tooltip: 'Stop Voice',
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildSoundwaves() {
    return AnimatedBuilder(
      animation: _waveController,
      builder: (context, _) {
        return Row(
          mainAxisSize: MainAxisSize.min,
          children: List.generate(4, (index) {
            final phase = (index * 0.25);
            final height = 4.0 + (math.sin((_waveController.value + phase) * math.pi) * 8.0);
            return Container(
              margin: const EdgeInsets.symmetric(horizontal: 1.5),
              width: 3,
              height: height.clamp(4.0, 14.0),
              decoration: BoxDecoration(
                color: const Color(0xFF69F0AE),
                borderRadius: BorderRadius.circular(2),
              ),
            );
          }),
        );
      },
    );
  }
}
