import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:nexa_ai/core/theme/app_theme.dart';
import 'package:nexa_ai/features/chatbot/data/models/chat_message_model.dart';
import 'package:nexa_ai/features/chatbot/presentation/providers/personality_provider.dart';
import 'package:nexa_ai/features/chatbot/presentation/widgets/glass_card.dart';

class ChatBubble extends ConsumerWidget {
  const ChatBubble({required this.message, super.key});

  final ChatMessage message;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final activePersonality = ref.watch(activePersonalityProvider);
    final isUser = message.role == ChatRole.user;
    
    final alignment = isUser ? Alignment.centerRight : Alignment.centerLeft;
    final accentColor = isUser ? AppColors.primary : activePersonality.accentColor;
    final titleName = isUser ? 'YOU // DECK_OPERATOR' : activePersonality.name.toUpperCase();

    return Align(
      alignment: alignment,
      child: ConstrainedBox(
        constraints: const BoxConstraints(maxWidth: 600),
        child: Container(
          margin: const EdgeInsets.symmetric(vertical: 6, horizontal: 16),
          child: GlassCard(
            padding: const EdgeInsets.symmetric(vertical: 14, horizontal: 18),
            borderRadius: isUser ? 18 : 18,
            borderColor: accentColor.withOpacity(isUser ? 0.4 : 0.25),
            opacity: isUser ? 0.12 : 0.06,
            child: Column(
              crossAxisAlignment:
                  isUser ? CrossAxisAlignment.end : CrossAxisAlignment.start,
              children: [
                Text(
                  message.text,
                  style: Theme.of(context)
                      .textTheme
                      .bodyLarge
                      ?.copyWith(
                        color: Colors.white, 
                        height: 1.45,
                        fontSize: 14.5,
                      ),
                ),
                const SizedBox(height: 8),
                Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    if (!isUser) ...[
                      Text(
                        activePersonality.avatarEmoji,
                        style: const TextStyle(fontSize: 11),
                      ),
                      const SizedBox(width: 6),
                    ],
                    Text(
                      titleName,
                      style: Theme.of(context)
                          .textTheme
                          .bodySmall
                          ?.copyWith(
                            color: accentColor.withOpacity(0.85),
                            fontWeight: FontWeight.w900,
                            fontSize: 9.5,
                            letterSpacing: 1.0,
                          ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
