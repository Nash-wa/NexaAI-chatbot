import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:nexa_ai/core/theme/app_theme.dart';
import 'package:nexa_ai/features/chatbot/presentation/providers/chat_provider.dart';
import 'package:nexa_ai/features/chatbot/presentation/widgets/chat_bubble.dart';
import 'package:nexa_ai/features/chatbot/presentation/widgets/chat_empty_state.dart';
import 'package:nexa_ai/features/chatbot/presentation/widgets/chat_input_bar.dart';
import 'package:nexa_ai/features/chatbot/presentation/widgets/typing_indicator.dart';

class ChatScreen extends ConsumerStatefulWidget {
  const ChatScreen({super.key});

  static const routeName = '/';

  @override
  ConsumerState<ChatScreen> createState() => _ChatScreenState();
}

class _ChatScreenState extends ConsumerState<ChatScreen> {
  final TextEditingController controller = TextEditingController();
  final ScrollController _scrollController = ScrollController();

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

  void _submitMessage() {
    final text = controller.text.trim();
    if (text.isEmpty) return;

    ref.read(chatControllerProvider.notifier).sendMessage(text);
    controller.clear();
    // Scroll to bottom immediately on send
    Future.delayed(const Duration(milliseconds: 50), _scrollToBottom);
  }

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(chatControllerProvider);
    final messages = state.messages;
    final showTyping = state.isSending;
    final itemCount = messages.length + (showTyping ? 1 : 0);

    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'NexaAI',
          style: TextStyle(fontWeight: FontWeight.bold, letterSpacing: 0.5),
        ),
        centerTitle: false,
        elevation: 0,
        actions: [
          // Sleek connectivity/simulation mode badge
          Padding(
            padding: const EdgeInsets.symmetric(vertical: 12),
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
              decoration: BoxDecoration(
                color: state.isSimulationMode 
                    ? AppColors.primary.withAlpha((0.15 * 255).round())
                    : AppColors.secondary.withAlpha((0.15 * 255).round()),
                borderRadius: BorderRadius.circular(12),
                border: Border.all(
                  color: state.isSimulationMode ? AppColors.primary : AppColors.secondary,
                  width: 1,
                ),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Container(
                    width: 6,
                    height: 6,
                    decoration: BoxDecoration(
                      color: state.isSimulationMode ? AppColors.primary : AppColors.secondary,
                      shape: BoxShape.circle,
                    ),
                  ),
                  const SizedBox(width: 6),
                  Text(
                    state.isSimulationMode ? 'Demo Simulator' : 'Live API',
                    style: const TextStyle(
                      fontSize: 10.5,
                      fontWeight: FontWeight.bold,
                      letterSpacing: 0.2,
                    ),
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(width: 4),
          // Sleek interactive switch
          IconButton(
            icon: Icon(
              state.isSimulationMode ? Icons.toggle_on_rounded : Icons.toggle_off_rounded,
              color: state.isSimulationMode ? AppColors.primary : Colors.white60,
              size: 30,
            ),
            onPressed: () {
              ref.read(chatControllerProvider.notifier).toggleSimulationMode(!state.isSimulationMode);
            },
            tooltip: 'Toggle Demo Simulation Mode',
          ),
          // Sweep clear button
          IconButton(
            icon: const Icon(Icons.cleaning_services_outlined, color: Colors.white70),
            onPressed: () {
              ref.read(chatControllerProvider.notifier).clearConversation();
            },
            tooltip: 'Clear Conversation',
          ),
          const SizedBox(width: 8),
        ],
      ),
      body: Column(
          children: [
            Expanded(
              child: messages.isEmpty
                  ? const ChatEmptyState()
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
            // Sleek contextual error banner with auto demo switch trigger
            if (state.errorMessage != null)
              Container(
                margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: Colors.redAccent.withAlpha((0.1 * 255).round()),
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(
                    color: Colors.redAccent.withAlpha((0.25 * 255).round()),
                  ),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    Row(
                      children: [
                        const Icon(Icons.error_outline_rounded, color: Colors.redAccent, size: 20),
                        const SizedBox(width: 10),
                        Expanded(
                          child: Text(
                            state.errorMessage!,
                            style: Theme.of(context)
                                .textTheme
                                .bodyMedium
                                ?.copyWith(color: Colors.redAccent, fontWeight: FontWeight.w500),
                          ),
                        ),
                      ],
                    ),
                    if (state.errorMessage!.contains('leaked') || 
                        state.errorMessage!.contains('Forbidden') || 
                        state.errorMessage!.contains('403') ||
                        state.errorMessage!.contains('quota'))
                      Padding(
                        padding: const EdgeInsets.only(top: 10.0),
                        child: OutlinedButton.icon(
                          onPressed: () {
                            ref.read(chatControllerProvider.notifier).toggleSimulationMode(true);
                          },
                          style: OutlinedButton.styleFrom(
                            side: const BorderSide(color: Colors.redAccent, width: 1.2),
                            foregroundColor: Colors.redAccent,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(10),
                            ),
                            padding: const EdgeInsets.symmetric(vertical: 8),
                          ),
                          icon: const Icon(Icons.play_circle_outline_rounded, size: 18),
                          label: const Text(
                            'Switch to Demo Simulation Mode',
                            style: TextStyle(fontWeight: FontWeight.bold, fontSize: 13),
                          ),
                        ),
                      ),
                  ],
                ),
              ),
            ChatInputBar(
              controller: controller,
              onSend: _submitMessage,
              isBusy: state.isSending,
            ),
          ],
        ),
    );
  }
}
