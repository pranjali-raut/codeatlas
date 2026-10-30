import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:flutter_markdown/flutter_markdown.dart';
import 'package:google_fonts/google_fonts.dart';

class ChatbotScreen extends StatefulWidget {
  const ChatbotScreen({super.key});

  @override
  State<ChatbotScreen> createState() => _ChatbotScreenState();
}

class _ChatbotScreenState extends State<ChatbotScreen> {
  final TextEditingController messageController =
      TextEditingController();

  final ScrollController scrollController =
      ScrollController();

  final List<Map<String, String>> messages = [
    {
      "role": "bot",
      "text":
          "Hello! I am CodeAtlas AI Assistant.\n\n"
          "I can help you with:\n"
          "1. Resolving coding errors\n"
          "2. Understanding Flutter and Dart\n"
          "3. Explaining CodeAtlas features\n"
          "4. Understanding project architecture\n\n"
          "How can I help you today?"
    }
  ];

  bool isLoading = false;

  // Android emulator backend URL
final String apiUrl = "http://127.0.0.1:3000/api/chat";

  Future<void> sendMessage() async {
    final question = messageController.text.trim();

    if (question.isEmpty || isLoading) return;

    setState(() {
      messages.add({
        "role": "user",
        "text": question
      });

      isLoading = true;
      messageController.clear();
    });

    scrollToBottom();

    try {
      final response = await http
          .post(
            Uri.parse(apiUrl),
            headers: {
              "Content-Type": "application/json"
            },
            body: jsonEncode({
              "message": question
            }),
          )
          .timeout(const Duration(seconds: 45));

      final data = jsonDecode(response.body);

      if (response.statusCode == 200) {
        setState(() {
          messages.add({
            "role": "bot",
            "text": data["reply"] ??
                "No response received."
          });
        });
      } else {
        setState(() {
          messages.add({
            "role": "bot",
            "text": "Server Error: ${data["error"] ?? response.body}"
          });
        });
      }
    } catch (e) {
      setState(() {
        messages.add({
          "role": "bot",
          "text":
              "Unable to connect to CodeAtlas AI.\n\n"
              "Error: $e\n\n"
              "Check that your backend is running on port 3000."
        });
      });
    } finally {
      if (mounted) {
        setState(() {
          isLoading = false;
        });
        scrollToBottom();
      }
    }
  }

  void scrollToBottom() {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (scrollController.hasClients) {
        scrollController.animateTo(
          scrollController.position.maxScrollExtent,
          duration: const Duration(milliseconds: 300),
          curve: Curves.easeOut,
        );
      }
    });
  }

  Widget buildMessage(Map<String, String> message) {
    final isUser = message["role"] == "user";

    return Align(
      alignment: isUser
          ? Alignment.centerRight
          : Alignment.centerLeft,
      child: Container(
        constraints: const BoxConstraints(
          maxWidth: 310,
        ),
        margin: const EdgeInsets.symmetric(
          vertical: 7,
          horizontal: 12,
        ),
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
          color: isUser
              ? const Color(0xFF6C63FF)
              : const Color(0xFFF0EDFF),
          borderRadius: BorderRadius.circular(16),
        ),
        child: MarkdownBody(
  data: message["text"] ?? "",
  selectable: true,
  styleSheet: MarkdownStyleSheet(
    p: GoogleFonts.inter(
      fontSize: 14,
      color: isUser ? Colors.white : const Color(0xFF292743),
      height: 1.6,
    ),
    h1: GoogleFonts.inter(
      fontSize: 21,
      fontWeight: FontWeight.bold,
    ),
    h2: GoogleFonts.inter(
      fontSize: 18,
      fontWeight: FontWeight.bold,
    ),
    h3: GoogleFonts.inter(
      fontSize: 16,
      fontWeight: FontWeight.w600,
    ),
    code: GoogleFonts.robotoMono(
      fontSize: 13,
      color: const Color(0xFF6C63FF),
    ),
    codeblockDecoration: BoxDecoration(
      color: const Color(0xFF242436),
      borderRadius: BorderRadius.circular(10),
    ),
    blockquoteDecoration: BoxDecoration(
      color: const Color(0xFFECE8FF),
      borderRadius: BorderRadius.circular(8),
    ),
  ),
)
      ),
    );
  }

  @override
  void dispose() {
    messageController.dispose();
    scrollController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFFCFAFF),

      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 1,
        title: const Row(
          children: [
            Icon(
              Icons.smart_toy,
              color: Color(0xFF6C63FF),
            ),
            SizedBox(width: 10),
            Text(
              "CodeAtlas AI",
              style: TextStyle(
                color: Color(0xFF292743),
                fontWeight: FontWeight.bold,
              ),
            ),
          ],
        ),
      ),

      body: Column(
        children: [
          Expanded(
            child: ListView.builder(
              controller: scrollController,
              padding: const EdgeInsets.symmetric(
                vertical: 12,
              ),
              itemCount: messages.length,
              itemBuilder: (context, index) {
                return buildMessage(messages[index]);
              },
            ),
          ),

          if (isLoading)
            const Padding(
              padding: EdgeInsets.all(12),
              child: Row(
                children: [
                  SizedBox(
                    height: 18,
                    width: 18,
                    child: CircularProgressIndicator(
                      strokeWidth: 2,
                    ),
                  ),
                  SizedBox(width: 12),
                  Text("CodeAtlas AI is thinking..."),
                ],
              ),
            ),

          Container(
            padding: const EdgeInsets.all(12),
            color: Colors.white,
            child: SafeArea(
              child: Row(
                children: [
                  Expanded(
                    child: TextField(
                      controller: messageController,
                      minLines: 1,
                      maxLines: 4,
                      textInputAction: TextInputAction.send,
                      onSubmitted: (_) => sendMessage(),
                      decoration: InputDecoration(
                        hintText:
                            "Ask about code or CodeAtlas...",
                        filled: true,
                        fillColor: const Color(0xFFF5F3FA),
                        border: OutlineInputBorder(
                          borderRadius:
                              BorderRadius.circular(25),
                          borderSide: BorderSide.none,
                        ),
                        contentPadding:
                            const EdgeInsets.symmetric(
                          horizontal: 18,
                          vertical: 12,
                        ),
                      ),
                    ),
                  ),

                  const SizedBox(width: 8),

                  IconButton(
                    onPressed:
                        isLoading ? null : sendMessage,
                    icon: const Icon(
                      Icons.send,
                      color: Color(0xFF6C63FF),
                      size: 28,
                    ),
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