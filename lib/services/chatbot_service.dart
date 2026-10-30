import 'dart:convert';
import 'package:http/http.dart' as http;
import '../models/chat_message.dart';

class ChatbotService {
  // Android emulator:
  static const String baseUrl = 'http://10.0.2.2:3000';

  // For Chrome on the same computer, use:
  // static const String baseUrl = 'http://localhost:3000';

  Future<String> sendMessage({
    required String message,
    required List<ChatMessage> history,
    String codeContext = '',
  }) async {
    final uri = Uri.parse('$baseUrl/api/chat');

    final response = await http
        .post(
          uri,
          headers: {'Content-Type': 'application/json'},
          body: jsonEncode({
            'message': message,
            'history': history.map((item) => item.toJson()).toList(),
            'codeContext': codeContext,
          }),
        )
        .timeout(const Duration(seconds: 60));

    final Map<String, dynamic> data =
        jsonDecode(response.body) as Map<String, dynamic>;

    if (response.statusCode != 200) {
      throw Exception(
        data['error']?.toString() ?? 'Request failed: ${response.statusCode}',
      );
    }

    final reply = data['reply']?.toString();

    if (reply == null || reply.isEmpty) {
      throw Exception('The chatbot returned no answer.');
    }

    return reply;
  }
}