import 'package:flutter/material.dart';
import '../settings/settings_screen.dart';
import '../voice_chat/voice_chat_screen.dart';
import '../investment_options/investment_options_screen.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Home"),
        actions: [
          IconButton(
            icon: const Icon(Icons.mic),
            tooltip: "Voice Chat",
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => const VoiceChatScreen()),
              );
            },
          )
        ],
      ),
      drawer: const AppSidebar(),
      body: const Center(child: Text("Welcome to Home")),
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
        ],
      ),
    );
  }
}