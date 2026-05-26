import 'package:nexa_ai/core/services/gemini_service.dart';

import 'chat_repository.dart';

class GeminiChatRepository implements ChatRepository {
  GeminiChatRepository(this._service);

  final GeminiService _service;

  @override
  Future<String> sendMessage(String prompt, {String? systemPrompt}) {
    return _service.sendMessage(prompt, systemPrompt: systemPrompt);
  }
}
