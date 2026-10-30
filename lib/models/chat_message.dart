class ChatMessage {
  final String text;
  final String role;

  const ChatMessage({
    required this.text,
    required this.role,
  });

  factory ChatMessage.fromJson(Map<String, dynamic> json) {
    return ChatMessage(
      text: json['text'] as String? ?? '',
      role: json['role'] as String? ?? 'user',
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'text': text,
      'role': role,
    };
  }
}