import 'package:flutter/material.dart';
import '../settings/settings_screen.dart';
import '../voice_chat/voice_chat_screen.dart';
import '../investment_options/investment_options_screen.dart';
import '../text_chat/text_chat_screen.dart';
import '../financial_toolkit/financial_toolkit_menu.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

 @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Home"),
      ),
      drawer: const AppSidebar(),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Text("Welcome to Home", style: TextStyle(fontSize: 20)),
            const SizedBox(height: 30),
            ElevatedButton.icon(
              icon: const Icon(Icons.mic),
              label: const Text(
                "VoiceChat",
                style: TextStyle(fontSize: 18),
              ),
              style: ElevatedButton.styleFrom(
                padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
                backgroundColor: Colors.blue,
              ),
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => const VoiceChatScreen()),
                );
              },
            ),
            const SizedBox(height: 20),
            ElevatedButton.icon(
              icon: const Icon(Icons.chat),
              label: const Text(
                "TextChat",
                style: TextStyle(fontSize: 18),
              ),
              style: ElevatedButton.styleFrom(
                padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
                backgroundColor: Colors.green,
              ),
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => const TextChatScreen()),
                );
              },
            ),
          ],
        ),
      ),
    );
  }
}

class AppSidebar extends StatelessWidget {
  const AppSidebar({super.key});

  @override
  Widget build(BuildContext context) {
    return Drawer(
      child: ListView(
        padding: EdgeInsets.zero,
        children: [
          const DrawerHeader(
            decoration: BoxDecoration(color: Colors.blue),
            child: Text("Sidebar Menu", style: TextStyle(color: Colors.white)),
          ),
          ListTile(
            leading: const Icon(Icons.home),
            title: const Text("Home"),
            onTap: () {
              Navigator.of(context).pop(); // Close drawer
            },
          ),
          ListTile(
            leading: const Icon(Icons.settings),
            title: const Text("Settings"),
            onTap: () {
              Navigator.of(context).push(MaterialPageRoute(
                builder: (context) => const SettingsScreen(),
              ));
            },
          ),
          ListTile(
            leading: const Icon(Icons.attach_money),
            title: const Text("Investment Options"),
            onTap: () {
              Navigator.of(context).push(MaterialPageRoute(
                builder: (context) => const InvestmentOptionsScreen(),
              ));
            },
          ),
          ListTile(
            leading: const Icon(Icons.build), // You can change icon
            title: const Text("Financial Toolkit"),
            onTap: () {
              Navigator.of(context).push(MaterialPageRoute(
                builder: (context) => const FinancialToolkitMenu(),
              ));
            },
          ),
        ],
      ),
    );
  }
}