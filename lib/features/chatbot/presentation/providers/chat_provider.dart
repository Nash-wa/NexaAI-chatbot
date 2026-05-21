import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../data/models/chat_message_model.dart';
import '../../../../core/services/gemini_service.dart';

final chatProvider =
    StateNotifierProvider<ChatNotifier, List<ChatMessage>>(
  (ref) => ChatNotifier(),
);

class ChatNotifier extends StateNotifier<List<ChatMessage>> {
  ChatNotifier() : super([]);

  final GeminiService _service = GeminiService();

  Future<void> sendMessage(String message) async {
    state = [
      ...state,
      ChatMessage(text: message, isUser: true),
    ];

    final response = await _service.sendMessage(message);

    state = [
      ...state,
      ChatMessage(text: response, isUser: false),
    ];
  }
}
