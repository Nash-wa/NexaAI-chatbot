abstract class ChatRepository {
  Future<String> sendMessage(String prompt, {String? systemPrompt});
}
