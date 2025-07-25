import 'package:flutter/material.dart';
import 'package:frontend_flutter/config/translated_text.dart';
import '../text_chat/text_chat_screen.dart'; // Replace with correct import path
import '../voice_chat/voice_chat_screen.dart'; // Replace with correct import path

class ChatScreen extends StatelessWidget {
  const ChatScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const TranslatedText("Choose Chat Mode")),
      body: Padding(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            ElevatedButton.icon(
              icon: const Icon(Icons.text_fields, size: 32),
              label: const TranslatedText("Text Chat", style: TextStyle(fontSize: 22)),
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.deepPurple,
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(vertical: 20, horizontal: 40),
                minimumSize: const Size(double.infinity, 80),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
              ),
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (_) => const TextChatScreen()),
                );
              },
            ),
            const SizedBox(height: 40),
            ElevatedButton.icon(
              icon: const Icon(Icons.mic, size: 32),
              label: const TranslatedText("Voice Chat", style: TextStyle(fontSize: 22)),
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.teal,
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(vertical: 20, horizontal: 40),
                minimumSize: const Size(double.infinity, 80),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
              ),
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (_) => const VoiceChatScreen()),
                );
              },
            ),
          ],
        ),
      ),
    );
  }
}
