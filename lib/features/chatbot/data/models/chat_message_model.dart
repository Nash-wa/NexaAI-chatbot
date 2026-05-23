enum ChatRole { user, assistant }

class ChatMessage {
  ChatMessage({
    required this.text,
    required this.role,
    DateTime? timestamp,
  }) : timestamp = timestamp ?? DateTime.now();

  final String text;
  final ChatRole role;
  final DateTime timestamp;

  bool get isUser => role == ChatRole.user;
}
