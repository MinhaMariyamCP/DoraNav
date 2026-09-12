import 'package:flutter/material.dart';
import '../theme/backpack_theme.dart';

/// Animated Search & Voice Input row where Dora asks: "What do we need?".
/// Features voice pulse ripple animation when active.
class SearchVoiceRow extends StatefulWidget {
  final TextEditingController controller;
  final ValueChanged<String> onSearchChanged;
  final VoidCallback onVoicePressed;
  final bool isListening;
  final VoidCallback onClear;

  const SearchVoiceRow({
    super.key,
    required this.controller,
    required this.onSearchChanged,
    required this.onVoicePressed,
    this.isListening = false,
    required this.onClear,
  });

  @override
  State<SearchVoiceRow> createState() => _SearchVoiceRowState();
}

class _SearchVoiceRowState extends State<SearchVoiceRow> with SingleTickerProviderStateMixin {
  late AnimationController _rippleController;

  @override
  void initState() {
    super.initState();
    _rippleController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1200),
    );

    if (widget.isListening) {
      _rippleController.repeat();
    }
  }

  @override
  void didUpdateWidget(covariant SearchVoiceRow oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.isListening && !_rippleController.isAnimating) {
      _rippleController.repeat();
    } else if (!widget.isListening && _rippleController.isAnimating) {
      _rippleController.stop();
      _rippleController.reset();
    }
  }

  @override
  void dispose() {
    _rippleController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 4),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(30),
        border: Border.all(
          color: widget.isListening ? BackpackColors.primaryPurple : BackpackColors.borderLight,
          width: 1.5,
        ),
        boxShadow: [
          BoxShadow(
            color: widget.isListening
                ? BackpackColors.primaryPurple.withValues(alpha: 0.20)
                : const Color(0xFF5E35B1).withValues(alpha: 0.06),
            blurRadius: 12,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      child: Row(
        children: [
          const Icon(Icons.search_rounded, color: BackpackColors.primaryPurple, size: 22),
          const SizedBox(width: 8),
          Expanded(
            child: TextField(
              controller: widget.controller,
              onChanged: widget.onSearchChanged,
              style: const TextStyle(
                fontSize: 15,
                fontWeight: FontWeight.w700,
                color: BackpackColors.textDark,
              ),
              decoration: const InputDecoration(
                hintText: 'What do we need?',
                hintStyle: TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                  color: BackpackColors.textMuted,
                ),
                border: InputBorder.none,
                isDense: true,
                contentPadding: EdgeInsets.symmetric(vertical: 10),
              ),
            ),
          ),
          if (widget.controller.text.isNotEmpty)
            IconButton(
              icon: const Icon(Icons.close_rounded, size: 18, color: BackpackColors.textSecondary),
              onPressed: widget.onClear,
              padding: EdgeInsets.zero,
              constraints: const BoxConstraints(minWidth: 32, minHeight: 32),
            ),

          // Microphone Button with Voice Ripple
          GestureDetector(
            onTap: widget.onVoicePressed,
            child: AnimatedBuilder(
              animation: _rippleController,
              builder: (context, child) {
                return Stack(
                  alignment: Alignment.center,
                  children: [
                    if (widget.isListening) ...[
                      // Outer ripple wave
                      Container(
                        width: 40 + (_rippleController.value * 14),
                        height: 40 + (_rippleController.value * 14),
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          color: BackpackColors.primaryPurple.withValues(
                            alpha: (1.0 - _rippleController.value) * 0.4,
                          ),
                        ),
                      ),
                      // Inner ripple wave
                      Container(
                        width: 36 + (_rippleController.value * 8),
                        height: 36 + (_rippleController.value * 8),
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          color: BackpackColors.primaryPurple.withValues(
                            alpha: (1.0 - _rippleController.value) * 0.6,
                          ),
                        ),
                      ),
                    ],
                    Container(
                      width: 38,
                      height: 38,
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          colors: widget.isListening
                              ? [BackpackColors.accentPink, BackpackColors.swiperRed]
                              : [BackpackColors.primaryPurple, BackpackColors.softPurple],
                          begin: Alignment.topLeft,
                          end: Alignment.bottomRight,
                        ),
                        shape: BoxShape.circle,
                        boxShadow: [
                          BoxShadow(
                            color: (widget.isListening ? BackpackColors.accentPink : BackpackColors.primaryPurple)
                                .withValues(alpha: 0.35),
                            blurRadius: 8,
                            offset: const Offset(0, 2),
                          ),
                        ],
                      ),
                      child: Icon(
                        widget.isListening ? Icons.graphic_eq_rounded : Icons.mic_rounded,
                        color: Colors.white,
                        size: 20,
                      ),
                    ),
                  ],
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}
