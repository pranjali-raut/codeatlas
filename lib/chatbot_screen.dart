
import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;


class ChatbotScreen extends StatefulWidget {
  const ChatbotScreen({super.key});

  @override
  State<ChatbotScreen> createState() => _ChatbotScreenState();
}

class _ChatbotScreenState extends State<ChatbotScreen> {
  final TextEditingController controller = TextEditingController();
  final ScrollController scrollController = ScrollController();

  final List<Map<String, String>> messages = [];

  bool isLoading = false;

  // Android Emulator
  final String apiUrl = "http://localhost:3000/api/chat";

  // For Flutter Windows/Desktop use:
  // http://localhost:3000/api/chat

  Future<void> sendMessage() async {
    String question = controller.text.trim();

    if (question.isEmpty || isLoading) return;

    setState(() {
      messages.add({
        "role": "user",
        "text": question
      });

      controller.clear();
      isLoading = true;
    });

    scrollToBottom();

    try {
      final response = await http.post(
        Uri.parse(apiUrl),
        headers: {
          "Content-Type": "application/json"
        },
        body: jsonEncode({
          "message": question
        }),
      ).timeout(const Duration(seconds: 90));

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);

        setState(() {
          messages.add({
            "role": "ai",
            "text": data["reply"] ?? "No response received."
          });
        });
      } else {
        final data = jsonDecode(response.body);

        setState(() {
          messages.add({
            "role": "ai",
            "text": "Error: ${data["error"] ?? response.body}"
          });
        });
      }
    } catch (e) {
      setState(() {
        messages.add({
          "role": "ai",
          "text": "Unable to connect to CodeAtlas AI.\n$e"
        });
      });
    } finally {
      setState(() {
        isLoading = false;
      });

      scrollToBottom();
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
    bool isUser = message["role"] == "user";

    return Align(
      alignment: isUser
          ? Alignment.centerRight
          : Alignment.centerLeft,
      child: Container(
        margin: const EdgeInsets.symmetric(
            vertical: 7, horizontal: 12),
        padding: const EdgeInsets.all(14),
        constraints: const BoxConstraints(maxWidth: 330),
        decoration: BoxDecoration(
          color: isUser
              ? const Color(0xFFB8C0FF)
              : const Color(0xFFF0EDFA),
          borderRadius: BorderRadius.circular(15),
        ),
        child: SelectableText(
          message["text"] ?? "",
          style: const TextStyle(
            fontSize: 14,
            color: Colors.black87,
            height: 1.5,
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFFCFAFF),
      appBar: AppBar(
        title: const Text(
          "CodeAtlas AI Assistant",
          style: TextStyle(
            fontWeight: FontWeight.bold,
          ),
        ),
        backgroundColor: const Color(0xFFB8C0FF),
        foregroundColor: Colors.black,
      ),

      body: Column(
        children: [

          // Welcome message
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(16),
            color: const Color(0xFFEDEBFF),
            child: const Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  "Hello Developer! 👋",
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                SizedBox(height: 6),
                Text(
                  "Ask me about CodeAtlas or paste your coding error to get a solution.",
                ),
              ],
            ),
          ),

          // Chat messages
          Expanded(
            child: ListView.builder(
              controller: scrollController,
              padding: const EdgeInsets.symmetric(vertical: 10),
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
                  SizedBox(width: 10),
                  Text("CodeAtlas AI is thinking..."),
                ],
              ),
            ),

          // Message input
          Container(
            padding: const EdgeInsets.all(12),
            decoration: const BoxDecoration(
              color: Colors.white,
            ),
            child: Row(
              children: [

                Expanded(
                  child: TextField(
                    controller: controller,
                    minLines: 1,
                    maxLines: 5,
                    decoration: InputDecoration(
                      hintText: "Ask or paste your coding error...",
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(15),
                      ),
                    ),
                    onSubmitted: (_) => sendMessage(),
                  ),
                ),

                const SizedBox(width: 8),

                IconButton(
                  onPressed: isLoading ? null : sendMessage,
                  icon: const Icon(
                    Icons.send,
                    color: Color(0xFF6D6883),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  @override
  void dispose() {
    controller.dispose();
    scrollController.dispose();
    super.dispose();
  }
}
