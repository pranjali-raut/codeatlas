
import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;

class ChatbotScreen extends StatefulWidget {
  const ChatbotScreen({super.key});

  @override
  State<ChatbotScreen> createState() => _ChatbotScreenState();
}

class _ChatbotScreenState extends State<ChatbotScreen> {
  final TextEditingController _controller = TextEditingController();
  final ScrollController _scrollController = ScrollController();

  final List<Map<String, String>> _messages = [];

  bool _isLoading = false;

  // Flutter Web running in Chrome.
  static const String _apiUrl = 'http://localhost:3000/api/chat';

  Future<void> _sendMessage() async {
    final message = _controller.text.trim();

    if (message.isEmpty || _isLoading) return;

    setState(() {
      _messages.add({'role': 'user', 'text': message});
      _isLoading = true;
    });

    _controller.clear();
    _scrollToBottom();

    try {
      final response = await http
          .post(
            Uri.parse(_apiUrl),
            headers: {'Content-Type': 'application/json'},
            body: jsonEncode({'message': message}),
          )
         .timeout(const Duration(seconds: 120));

      final dynamic result = jsonDecode(response.body);

      if (response.statusCode != 200) {
        throw Exception(
          result is Map
              ? result['error'] ?? 'HTTP ${response.statusCode}'
              : 'HTTP ${response.statusCode}',
        );
      }

      if (result is! Map) {
        throw Exception('Invalid response from the backend.');
      }

      final answer = result['reply'] ?? result['answer'];

      if (answer == null || answer.toString().trim().isEmpty) {
        throw Exception('No answer was returned by the AI.');
      }

      if (!mounted) return;

      setState(() {
        _messages.add({
          'role': 'ai',
          'text': answer.toString(),
        });
      });
    } catch (e) {
      if (!mounted) return;

      setState(() {
        _messages.add({
          'role': 'ai',
          'text': 'Unable to connect to CodeAtlas AI.\n\n$e',
        });
      });
    } finally {
      if (mounted) {
        setState(() => _isLoading = false);
        _scrollToBottom();
      }
    }
  }

  void _scrollToBottom() {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (_scrollController.hasClients) {
        _scrollController.animateTo(
          _scrollController.position.maxScrollExtent,
          duration: const Duration(milliseconds: 250),
          curve: Curves.easeOut,
        );
      }
    });
  }

  void _askSuggestion(String text) {
    _controller.text = text;
    _sendMessage();
  }

  @override
  void dispose() {
    _controller.dispose();
    _scrollController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    // IMPORTANT: No Scaffold here because the dashboard already
    // provides its own page header and layout.
    return Container(
      color: const Color(0xFFF8F7FC),
      child: Column(
        children: [
          // Chatbot introduction.
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(22),
            color: Colors.white,
            child: const Row(
              children: [
                CircleAvatar(
                  radius: 25,
                  backgroundColor: Color(0xFFE7C6FF),
                  child: Icon(
                    Icons.smart_toy_outlined,
                    color: Color(0xFF292743),
                    size: 27,
                  ),
                ),
                SizedBox(width: 14),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'CodeAtlas AI Assistant',
                        style: TextStyle(
                          fontSize: 19,
                          fontWeight: FontWeight.bold,
                          color: Color(0xFF292743),
                        ),
                      ),
                      SizedBox(height: 5),
                      Text(
                        'Ask about your project, Flutter, or code errors.',
                        style: TextStyle(
                          color: Color(0xFF85849A),
                          fontSize: 13,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),

          // Conversation area.
          Expanded(
            child: _messages.isEmpty
                ? Center(
                    child: SingleChildScrollView(
                      padding: const EdgeInsets.all(24),
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          const Icon(
                            Icons.forum_outlined,
                            size: 62,
                            color: Color(0xFFB8C0FF),
                          ),
                          const SizedBox(height: 18),
                          const Text(
                            'How can I help you today?',
                            textAlign: TextAlign.center,
                            style: TextStyle(
                              fontSize: 23,
                              fontWeight: FontWeight.bold,
                              color: Color(0xFF292743),
                            ),
                          ),
                          const SizedBox(height: 10),
                          const Text(
                            'Ask a question or select a suggestion below.',
                            textAlign: TextAlign.center,
                            style: TextStyle(
                              color: Color(0xFF85849A),
                            ),
                          ),
                          const SizedBox(height: 22),
                          Wrap(
                            alignment: WrapAlignment.center,
                            spacing: 10,
                            runSpacing: 10,
                            children: [
                              ActionChip(
                                avatar: const Icon(
                                  Icons.info_outline,
                                  size: 18,
                                ),
                                label: const Text('What is CodeAtlas?'),
                                onPressed: _isLoading
                                    ? null
                                    : () => _askSuggestion(
                                          'What is CodeAtlas?',
                                        ),
                              ),
                              ActionChip(
                                avatar: const Icon(
                                  Icons.bug_report_outlined,
                                  size: 18,
                                ),
                                label: const Text('Fix a Flutter error'),
                                onPressed: _isLoading
                                    ? null
                                    : () => _askSuggestion(
                                          'How do I debug a Flutter error?',
                                        ),
                              ),
                              ActionChip(
                                avatar: const Icon(
                                  Icons.account_tree_outlined,
                                  size: 18,
                                ),
                                label: const Text('Explain architecture'),
                                onPressed: _isLoading
                                    ? null
                                    : () => _askSuggestion(
                                          'Explain CodeAtlas architecture.',
                                        ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                  )
                : ListView.builder(
                    controller: _scrollController,
                    padding: const EdgeInsets.all(22),
                    itemCount: _messages.length + (_isLoading ? 1 : 0),
                    itemBuilder: (context, index) {
                      if (_isLoading && index == _messages.length) {
                        return const Align(
                          alignment: Alignment.centerLeft,
                          child: Padding(
                            padding: EdgeInsets.all(12),
                            child: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                SizedBox(
                                  width: 18,
                                  height: 18,
                                  child: CircularProgressIndicator(
                                    strokeWidth: 2,
                                  ),
                                ),
                                SizedBox(width: 10),
                                Text('AI is thinking...'),
                              ],
                            ),
                          ),
                        );
                      }

                      final item = _messages[index];
                      final isUser = item['role'] == 'user';

                      return Align(
                        alignment: isUser
                            ? Alignment.centerRight
                            : Alignment.centerLeft,
                        child: Container(
                          constraints: BoxConstraints(
                            maxWidth:
                                MediaQuery.of(context).size.width * 0.65,
                          ),
                          margin: const EdgeInsets.only(bottom: 14),
                          padding: const EdgeInsets.all(15),
                          decoration: BoxDecoration(
                            color: isUser
                                ? const Color(0xFFDCDFFF)
                                : Colors.white,
                            border: Border.all(
                              color: const Color(0xFFEAE7F2),
                            ),
                            borderRadius: BorderRadius.circular(16),
                          ),
                          child: SelectableText(
                            item['text'] ?? '',
                            style: const TextStyle(
                              fontSize: 14,
                              height: 1.5,
                              color: Color(0xFF292743),
                            ),
                          ),
                        ),
                      );
                    },
                  ),
          ),

          // Input area.
          Container(
            padding: const EdgeInsets.all(16),
            decoration: const BoxDecoration(
              color: Colors.white,
              border: Border(
                top: BorderSide(color: Color(0xFFEAE7F2)),
              ),
            ),
            child: SafeArea(
              top: false,
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  Expanded(
                    child: TextField(
                      controller: _controller,
                      enabled: !_isLoading,
                      minLines: 1,
                      maxLines: 4,
                      onSubmitted: (_) => _sendMessage(),
                      decoration: InputDecoration(
                        hintText: 'Ask CodeAtlas AI...',
                        filled: true,
                        fillColor: const Color(0xFFF8F7FC),
                        contentPadding: const EdgeInsets.symmetric(
                          horizontal: 18,
                          vertical: 14,
                        ),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(18),
                          borderSide: const BorderSide(
                            color: Color(0xFFEAE7F2),
                          ),
                        ),
                        enabledBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(18),
                          borderSide: const BorderSide(
                            color: Color(0xFFEAE7F2),
                          ),
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: 10),
                  IconButton.filled(
                    onPressed: _isLoading ? null : _sendMessage,
                    icon: const Icon(Icons.send_rounded),
                    style: IconButton.styleFrom(
                      backgroundColor: const Color(0xFFB8C0FF),
                      foregroundColor: const Color(0xFF292743),
                    ),
                  ),
                  const SizedBox(width: 6),
                  IconButton(
                    tooltip: 'Clear conversation',
                    onPressed: _isLoading
                        ? null
                        : () => setState(() => _messages.clear()),
                    icon: const Icon(Icons.delete_outline),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
