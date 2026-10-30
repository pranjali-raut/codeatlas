import 'package:flutter/foundation.dart';
import '../models/chat_message.dart';
import 'chatbot_service.dart';

class ChatbotController extends ChangeNotifier {
  final ChatbotService _service = ChatbotService();

  final List<ChatMessage> _messages = [];

  bool _isLoading = false;
  String? _error;

  List<ChatMessage> get messages => List.unmodifiable(_messages);
  bool get isLoading => _isLoading;
  String? get error => _error;

  Future<void> sendMessage(
    String message, {
    String codeContext = '',
  }) async {
    if (message.trim().isEmpty || _isLoading) return;

    final previousHistory = List<ChatMessage>.from(_messages);

    _messages.add(ChatMessage(
      text: message.trim(),
      role: 'user',
    ));

    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      final reply = await _service.sendMessage(
        message: message.trim(),
        history: previousHistory,
        codeContext: codeContext,
      );

      _messages.add(ChatMessage(
        text: reply,
        role: 'model',
      ));
    } catch (e) {
      _error = e.toString().replaceFirst('Exception: ', '');
      _messages.add(ChatMessage(
        text: 'Sorry, I could not get a response. $_error',
        role: 'model',
      ));
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  void clearChat() {
    _messages.clear();
    _error = null;
    notifyListeners();
  }
}