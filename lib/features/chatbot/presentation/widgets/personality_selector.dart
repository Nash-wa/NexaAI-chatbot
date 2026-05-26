import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:nexa_ai/features/chatbot/presentation/providers/personality_provider.dart';
import 'package:nexa_ai/features/chatbot/presentation/widgets/glass_card.dart';

class PersonalitySelector extends ConsumerWidget {
  const PersonalitySelector({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final activePersonality = ref.watch(activePersonalityProvider);
    final allPersonalities = ref.watch(personalitiesProvider);

    return SizedBox(
      height: 125,
      child: ListView.builder(
        padding: const EdgeInsets.symmetric(horizontal: 16),
        scrollDirection: Axis.horizontal,
        itemCount: PersonalityType.values.length,
        itemBuilder: (context, index) {
          final type = PersonalityType.values[index];
          final config = allPersonalities[type]!;
          final isSelected = activePersonality.type == type;
          final accentColor = config.accentColor;

          return GestureDetector(
            onTap: () {
              ref.read(activePersonalityProvider.notifier).selectPersonality(type);
            },
            child: AnimatedScale(
              scale: isSelected ? 1.0 : 0.93,
              duration: const Duration(milliseconds: 250),
              curve: Curves.easeOutBack,
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 250),
                width: 175,
                margin: const EdgeInsets.only(right: 12),
                child: GlassCard(
                  padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
                  borderRadius: 16,
                  borderWidth: isSelected ? 1.8 : 0.6,
                  borderColor: isSelected ? accentColor : Colors.white.withOpacity(0.12),
                  opacity: isSelected ? 0.14 : 0.05,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Row(
                        children: [
                          Container(
                            padding: const EdgeInsets.all(6),
                            decoration: BoxDecoration(
                              color: accentColor.withOpacity(0.15),
                              shape: BoxShape.circle,
                            ),
                            child: Text(
                              config.avatarEmoji,
                              style: const TextStyle(fontSize: 20),
                            ),
                          ),
                          const SizedBox(width: 8),
                          Expanded(
                            child: Text(
                              config.name,
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                              style: TextStyle(
                                fontSize: 13.5,
                                fontWeight: FontWeight.bold,
                                color: isSelected ? Colors.white : Colors.white70,
                                letterSpacing: 0.2,
                              ),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 10),
                      Text(
                        config.description,
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                        style: TextStyle(
                          fontSize: 10.5,
                          color: isSelected ? Colors.white60 : Colors.white38,
                          height: 1.25,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          );
        },
      ),
    );
  }
}
