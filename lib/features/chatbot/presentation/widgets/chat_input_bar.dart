import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:nexa_ai/features/chatbot/presentation/providers/personality_provider.dart';
import 'package:nexa_ai/features/chatbot/presentation/widgets/glass_card.dart';

class ChatInputBar extends ConsumerWidget {
  const ChatInputBar({
    required this.controller,
    required this.onSend,
    required this.isBusy,
    super.key,
  });

  final TextEditingController controller;
  final VoidCallback onSend;
  final bool isBusy;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final activePersonality = ref.watch(activePersonalityProvider);
    final accentColor = activePersonality.accentColor;

    return SafeArea(
      top: false,
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        child: Row(
          children: [
            Expanded(
              child: GlassCard(
                padding: const EdgeInsets.symmetric(horizontal: 8),
                borderRadius: 24,
                borderWidth: 0.6,
                borderColor: accentColor.withOpacity(0.2),
                opacity: 0.08,
                child: TextField(
                  controller: controller,
                  textInputAction: TextInputAction.send,
                  onSubmitted: (_) => onSend(),
                  style: const TextStyle(color: Colors.white, fontSize: 14.5),
                  decoration: InputDecoration(
                    hintText: 'Enter command for ${activePersonality.name}...',
                    hintStyle: const TextStyle(color: Colors.white30),
                    prefixIcon: Icon(Icons.satellite_alt_rounded, color: accentColor, size: 20),
                    border: InputBorder.none,
                    focusedBorder: InputBorder.none,
                    enabledBorder: InputBorder.none,
                    errorBorder: InputBorder.none,
                    disabledBorder: InputBorder.none,
                    filled: false,
                    contentPadding: const EdgeInsets.symmetric(vertical: 14),
                  ),
                  minLines: 1,
                  maxLines: 5,
                  enabled: !isBusy,
                ),
              ),
            ),
            const SizedBox(width: 12),
            GestureDetector(
              onTap: isBusy ? null : onSend,
              child: AnimatedScale(
                scale: isBusy ? 0.9 : 1.0,
                duration: const Duration(milliseconds: 150),
                child: GlassCard(
                  padding: const EdgeInsets.all(13),
                  borderRadius: 18,
                  borderWidth: 1.0,
                  borderColor: accentColor.withOpacity(0.5),
                  opacity: 0.15,
                  child: isBusy
                      ? SizedBox(
                          width: 18,
                          height: 18,
                          child: CircularProgressIndicator(
                            strokeWidth: 2.2,
                            valueColor: AlwaysStoppedAnimation<Color>(accentColor),
                          ),
                        )
                      : Icon(Icons.arrow_upward_rounded, color: accentColor, size: 22),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
