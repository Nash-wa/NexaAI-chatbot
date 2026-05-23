import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:nexa_ai/core/services/gemini_service.dart';
import 'package:nexa_ai/features/chatbot/data/models/chat_message_model.dart';
import 'package:nexa_ai/features/chatbot/data/repositories/chat_repository.dart';
import 'package:nexa_ai/features/chatbot/data/repositories/gemini_chat_repository.dart';

final geminiServiceProvider = Provider<GeminiService>((ref) {
  return GeminiService();
});

final chatRepositoryProvider = Provider<ChatRepository>((ref) {
  return GeminiChatRepository(ref.watch(geminiServiceProvider));
});

final chatControllerProvider = StateNotifierProvider<ChatController, ChatState>(
  (ref) => ChatController(ref.watch(chatRepositoryProvider)),
);

enum ChatStatus { idle, sending, failure }

class ChatState {
  const ChatState({
    this.messages = const [],
    this.status = ChatStatus.idle,
    this.errorMessage,
    this.isSimulationMode = false,
  });

  final List<ChatMessage> messages;
  final ChatStatus status;
  final String? errorMessage;
  final bool isSimulationMode;

  bool get isSending => status == ChatStatus.sending;

  ChatState copyWith({
    List<ChatMessage>? messages,
    ChatStatus? status,
    String? errorMessage,
    bool? isSimulationMode,
  }) {
    return ChatState(
      messages: messages ?? this.messages,
      status: status ?? this.status,
      errorMessage: errorMessage,
      isSimulationMode: isSimulationMode ?? this.isSimulationMode,
    );
  }
}

class ChatController extends StateNotifier<ChatState> {
  ChatController(this._repository) : super(const ChatState());

  final ChatRepository _repository;

  void toggleSimulationMode(bool value) {
    state = state.copyWith(isSimulationMode: value, errorMessage: null);
  }

  void clearConversation() {
    state = state.copyWith(messages: const [], errorMessage: null);
  }

  Future<void> sendMessage(String prompt) async {
    final trimmedPrompt = prompt.trim();
    if (trimmedPrompt.isEmpty || state.isSending) {
      return;
    }

    final conversation = [
      ...state.messages,
      ChatMessage(text: trimmedPrompt, role: ChatRole.user),
    ];

    state = state.copyWith(
      messages: conversation,
      status: ChatStatus.sending,
      errorMessage: null,
    );

    // If in simulation mode, generate a quick simulated response locally
    if (state.isSimulationMode) {
      await Future.delayed(const Duration(milliseconds: 1200)); // Simulate typing latency
      final response = _generateSimulatedResponse(trimmedPrompt);
      state = state.copyWith(
        messages: [
          ...conversation,
          ChatMessage(text: response, role: ChatRole.assistant),
        ],
        status: ChatStatus.idle,
      );
      return;
    }

    try {
      final response = await _repository.sendMessage(trimmedPrompt);
      state = state.copyWith(
        messages: [
          ...conversation,
          ChatMessage(text: response, role: ChatRole.assistant),
        ],
        status: ChatStatus.idle,
      );
    } catch (error) {
      String userMessage = 'Unable to fetch a response. Please try again.';
      if (error is StateError) {
        userMessage = error.message;
      } else if (error is Exception) {
        final str = error.toString();
        userMessage = str.startsWith('Exception: ') ? str.substring(11) : str;
      } else {
        userMessage = error.toString();
      }

      state = state.copyWith(
        status: ChatStatus.failure,
        errorMessage: userMessage,
      );
    }
  }

  String _generateSimulatedResponse(String message) {
    final lower = message.toLowerCase().trim();
    if (lower.contains('hi') || lower.contains('hello') || lower.contains('hey')) {
      return "Hello! I am **NexaAI**, your premium, clean-architecture coding assistant. 🚀\n\nI am currently running in **Simulation Mode** because your API key is either deactivated, offline, or leaked. You can chat with me, ask about my architecture, or check out how connectivity is handled in this sandbox!";
    }
    if (lower.contains('help') || lower.contains('what can you do')) {
      return "I can help you explore this Flutter application! Try asking me about:\n- **Architecture**: Learn how clean architecture works in this project.\n- **Connectivity**: See how I dynamically handle offline and online modes.\n- **Features**: A walkthrough of the premium UI and location capabilities.";
    }
    if (lower.contains('architecture') || lower.contains('clean')) {
      return "This app is built using strict **Clean Architecture** principles decoupled into standard layers:\n\n1. **Core Layer**: Houses Dio client, connectivity service, location manager, and color theme tokens.\n2. **Data Layer**: Manages models, JSON serialization, and remote API repositories.\n3. **Domain Layer**: Holds repositories interfaces representing pure business contracts.\n4. **Presentation Layer**: Implements state management using **Riverpod StateNotifiers** and gorgeous dark-neon styled responsive layouts.\n\nThis keeps the codebase incredibly modular and testable! 🏗️";
    }
    if (lower.contains('connectivity') || lower.contains('offline') || lower.contains('internet')) {
      return "Connectivity is managed reactively! Using `connectivity_plus`, we watch the device adapters. If your internet drops or the API becomes unavailable, the UI automatically transitions to a **Demo Simulation Mode** without throwing unhandled exceptions. This guarantees the user has a 100% crash-safe experience! 📶";
    }
    if (lower.contains('features') || lower.contains('ui') || lower.contains('ux')) {
      return "Here are the top-tier **UI/UX features** of NexaAI:\n\n- 💜 **Bouncing Dots Typing Indicator**: Sequential fluid animations that mimic real-time human typing.\n- 📱 **Adaptive Slate-Dark Neon Theme**: Curated harmonious HSL layout styling with gorgeous responsive padding.\n- 📡 **Offline Telemetry Map Screen**: A crash-safe location screen that queries GPS coordinates and showcases a stunning live radar pulse!\n- 🔐 **Intelligent Key Leak Diagnostic**: Automatically intercepts 403 API key leak errors and guides you to switch to Simulation Mode with one click.";
    }
    if (lower.contains('clear')) {
      return "To clear the chat list, simply press the sweep icon on the top right bar!";
    }
    
    return "Thank you for asking! I've received your query: *\"$message\"*\n\nSince we are in **Demo Simulation Mode**, I am synthesizing this response locally on your device. To test my live capabilities, please ensure a valid, active Gemini API key is configured in your `.env` file.\n\nIs there anything else about my architecture or location features you'd like to check? 🚀";
  }
}
