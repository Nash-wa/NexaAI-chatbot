import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:nexa_ai/core/theme/app_theme.dart';
import 'package:nexa_ai/features/chatbot/presentation/providers/chat_provider.dart';
import 'package:nexa_ai/features/chatbot/presentation/providers/personality_provider.dart';
import 'package:nexa_ai/features/chatbot/presentation/widgets/chat_bubble.dart';
import 'package:nexa_ai/features/chatbot/presentation/widgets/chat_input_bar.dart';
import 'package:nexa_ai/features/chatbot/presentation/widgets/cosmic_background.dart';
import 'package:nexa_ai/features/chatbot/presentation/widgets/floating_avatar.dart';
import 'package:nexa_ai/features/chatbot/presentation/widgets/glass_card.dart';
import 'package:nexa_ai/features/chatbot/presentation/widgets/personality_selector.dart';
import 'package:nexa_ai/features/chatbot/presentation/widgets/typing_indicator.dart';

class ChatScreen extends ConsumerStatefulWidget {
  const ChatScreen({super.key});

  static const routeName = '/chat';

  @override
  ConsumerState<ChatScreen> createState() => _ChatScreenState();
}

class _ChatScreenState extends ConsumerState<ChatScreen> {
  final TextEditingController controller = TextEditingController();
  final ScrollController _scrollController = ScrollController();

  // Floating suggestion prompt chips
  final List<String> _quickPrompts = [
    'System core architecture?',
    'Scan current local coordinates',
    'Explain simulation mode',
    'Give a futuristic greeting',
  ];

  @override
  void dispose() {
    controller.dispose();
    _scrollController.dispose();
    super.dispose();
  }

  void _scrollToBottom() {
    if (_scrollController.hasClients) {
      _scrollController.animateTo(
        0.0, // Since reverse is true, 0.0 is the bottom (latest message)
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeOut,
      );
    }
  }

  void _submitMessage([String? customText]) {
    final text = customText ?? controller.text.trim();
    if (text.isEmpty) return;

    final activeConfig = ref.read(activePersonalityProvider);
    ref.read(chatControllerProvider.notifier).sendMessage(
          text,
          systemPrompt: activeConfig.systemPrompt,
        );
    
    if (customText == null) {
      controller.clear();
    }
    // Scroll to bottom immediately on send
    Future.delayed(const Duration(milliseconds: 50), _scrollToBottom);
  }

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(chatControllerProvider);
    final activePersonality = ref.watch(activePersonalityProvider);
    final accentColor = activePersonality.accentColor;
    
    final messages = state.messages;
    final showTyping = state.isSending;
    final itemCount = messages.length + (showTyping ? 1 : 0);

    return Scaffold(
      backgroundColor: AppColors.background,
      body: CosmicBackground(
        child: SafeArea(
          bottom: false,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // 1. Futuristic Glassmorphic Header
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
                child: GlassCard(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                  borderRadius: 20,
                  borderColor: accentColor.withOpacity(0.2),
                  opacity: 0.05,
                  child: Row(
                    children: [
                      IconButton(
                        icon: const Icon(Icons.arrow_back_ios_new_rounded, color: Colors.white70),
                        onPressed: () => context.pop(),
                      ),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            const Text(
                              'CORE MISSION COMMS',
                              style: TextStyle(
                                color: Colors.white38,
                                fontSize: 9.5,
                                fontWeight: FontWeight.bold,
                                letterSpacing: 0.8,
                              ),
                            ),
                            Text(
                              activePersonality.name.toUpperCase(),
                              style: TextStyle(
                                color: accentColor,
                                fontSize: 15,
                                fontWeight: FontWeight.w900,
                                letterSpacing: 0.5,
                              ),
                            ),
                          ],
                        ),
                      ),
                      // Connectivity Status Badge
                      GestureDetector(
                        onTap: () {
                          ref.read(chatControllerProvider.notifier).toggleSimulationMode(!state.isSimulationMode);
                        },
                        child: Container(
                          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                          decoration: BoxDecoration(
                            color: state.isSimulationMode 
                                ? AppColors.accent.withOpacity(0.08)
                                : AppColors.secondary.withOpacity(0.08),
                            borderRadius: BorderRadius.circular(12),
                            border: Border.all(
                              color: state.isSimulationMode ? AppColors.accent : AppColors.secondary,
                              width: 0.8,
                            ),
                          ),
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Container(
                                width: 5.5,
                                height: 5.5,
                                decoration: BoxDecoration(
                                  color: state.isSimulationMode ? AppColors.accent : AppColors.secondary,
                                  shape: BoxShape.circle,
                                ),
                              ),
                              const SizedBox(width: 6),
                              Text(
                                state.isSimulationMode ? 'SIMULATOR' : 'LIVE API',
                                style: TextStyle(
                                  color: state.isSimulationMode ? AppColors.accent : AppColors.secondary,
                                  fontSize: 9.5,
                                  fontWeight: FontWeight.bold,
                                  letterSpacing: 0.2,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                      IconButton(
                        icon: const Icon(Icons.cleaning_services_outlined, color: Colors.white70, size: 20),
                        onPressed: () {
                          ref.read(chatControllerProvider.notifier).clearConversation();
                        },
                        tooltip: 'Wipe Core Memory',
                      ),
                    ],
                  ),
                ),
              ),

              // 2. Personality Selection deck
              const SizedBox(height: 6),
              const PersonalitySelector(),

              // 3. Floating Interactive Avatar Companion (Breathing floating scale)
              Center(
                child: FloatingAvatar(isBusy: showTyping),
              ),

              // 4. Conversational Bubble ListView
              Expanded(
                child: messages.isEmpty
                    ? _buildWelcomeState(activePersonality)
                    : ListView.separated(
                        controller: _scrollController,
                        padding: const EdgeInsets.symmetric(vertical: 16),
                        reverse: true,
                        itemCount: itemCount,
                        separatorBuilder: (_, __) => const SizedBox(height: 2),
                        itemBuilder: (context, index) {
                          if (showTyping && index == 0) {
                            return const TypingIndicator();
                          }
                          final messageIndex = showTyping ? index - 1 : index;
                          final reversedIndex = messages.length - 1 - messageIndex;
                          final message = messages[reversedIndex];
                          return ChatBubble(message: message);
                        },
                      ),
              ),

              // 5. Diagnostic context error alert trigger
              if (state.errorMessage != null)
                Container(
                  margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: Colors.redAccent.withOpacity(0.08),
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(
                      color: Colors.redAccent.withOpacity(0.2),
                    ),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      Row(
                        children: [
                          const Icon(Icons.error_outline_rounded, color: Colors.redAccent, size: 18),
                          const SizedBox(width: 8),
                          Expanded(
                            child: Text(
                              state.errorMessage!,
                              style: const TextStyle(
                                color: Colors.redAccent,
                                fontSize: 12,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                        ],
                      ),
                      if (state.errorMessage!.contains('key') || 
                          state.errorMessage!.contains('quota') ||
                          state.errorMessage!.contains('403') ||
                          state.errorMessage!.contains('Forbidden'))
                        Padding(
                          padding: const EdgeInsets.only(top: 8.0),
                          child: OutlinedButton(
                            onPressed: () {
                              ref.read(chatControllerProvider.notifier).toggleSimulationMode(true);
                            },
                            style: OutlinedButton.styleFrom(
                              side: const BorderSide(color: Colors.redAccent, width: 1.0),
                              foregroundColor: Colors.redAccent,
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(10),
                              ),
                            ),
                            child: const Text(
                              'Switch to Offline Simulator Mode',
                              style: TextStyle(fontWeight: FontWeight.bold, fontSize: 11.5),
                            ),
                          ),
                        ),
                    ],
                  ),
                ),

              // 6. Floating Holographic Quick Prompt chips
              if (messages.isEmpty)
                SizedBox(
                  height: 38,
                  child: ListView.builder(
                    scrollDirection: Axis.horizontal,
                    padding: const EdgeInsets.symmetric(horizontal: 16),
                    itemCount: _quickPrompts.length,
                    itemBuilder: (context, index) {
                      return GestureDetector(
                        onTap: () => _submitMessage(_quickPrompts[index]),
                        child: Container(
                          margin: const EdgeInsets.only(right: 8),
                          child: GlassCard(
                            padding: const EdgeInsets.symmetric(horizontal: 14),
                            borderRadius: 14,
                            borderWidth: 0.6,
                            borderColor: accentColor.withOpacity(0.25),
                            opacity: 0.08,
                            child: Center(
                              child: Text(
                                _quickPrompts[index],
                                style: TextStyle(
                                  color: accentColor.withOpacity(0.9),
                                  fontSize: 11.5,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ),
                          ),
                        ),
                      );
                    },
                  ),
                ),
              const SizedBox(height: 8),

              // 7. Interactive Comms Input Bar
              ChatInputBar(
                controller: controller,
                onSend: () => _submitMessage(),
                isBusy: state.isSending,
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildWelcomeState(PersonalityConfig config) {
    return Center(
      child: SingleChildScrollView(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            GlassCard(
              padding: const EdgeInsets.all(24),
              borderRadius: 24,
              borderColor: config.accentColor.withOpacity(0.2),
              opacity: 0.06,
              child: Column(
                children: [
                  Text(
                    'SYSTEM CALIBRATED',
                    style: TextStyle(
                      color: config.accentColor,
                      fontSize: 10,
                      fontWeight: FontWeight.w900,
                      letterSpacing: 1.5,
                    ),
                  ),
                  const SizedBox(height: 12),
                  Text(
                    config.name.toUpperCase(),
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 20,
                      fontWeight: FontWeight.w900,
                      letterSpacing: 0.5,
                    ),
                  ),
                  const SizedBox(height: 16),
                  Text(
                    config.greeting,
                    textAlign: TextAlign.center,
                    style: const TextStyle(
                      color: Colors.white70,
                      fontSize: 13.5,
                      height: 1.55,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
