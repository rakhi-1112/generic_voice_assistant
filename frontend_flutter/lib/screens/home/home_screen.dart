import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../settings/settings_screen.dart';
import '../voice_chat/voice_chat_screen.dart';
import '../investment_options/investment_options_screen.dart';
import '../text_chat/text_chat_screen.dart';
import '../financial_toolkit/financial_toolkit_menu.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final cardStyle = BoxDecoration(
      color: Colors.white,
      borderRadius: BorderRadius.circular(24),
      boxShadow: [
        BoxShadow(
          color: Colors.grey.withOpacity(0.15),
          blurRadius: 12,
          offset: const Offset(0, 4),
        ),
      ],
    );

    final textStyle = GoogleFonts.poppins(
      fontSize: 18,
      fontWeight: FontWeight.w600,
      color: Colors.black87,
    );

    return Scaffold(
      backgroundColor: const Color(0xFFF5F7FA),
      appBar: AppBar(
        title: const Text("Home"),
        backgroundColor: Colors.white,
        elevation: 1,
        foregroundColor: Colors.black,
      ),
      drawer: const AppSidebar(),
      body: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text("Welcome 👋", style: GoogleFonts.poppins(fontSize: 28, fontWeight: FontWeight.bold)),
            const SizedBox(height: 20),
            Expanded(
              child: Wrap(
                spacing: 20,
                runSpacing: 20,
                children: [
                  HomeCard(
                    title: "📈 Investment Options",
                    description: "Explore smart plans",
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(builder: (_) => const InvestmentOptionsScreen()),
                      );
                    },
                    style: cardStyle,
                    textStyle: textStyle,
                  ),
                  HomeCard(
                    title: "🧰 SME Toolkit",
                    description: "Manage and grow your business",
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(builder: (_) => const FinancialToolkitMenu()),
                      );
                    },
                    style: cardStyle,
                    textStyle: textStyle,
                  ),
                  HomeCard(
                    title: "🎙️ Voice Assistant",
                    description: "Ask your AI advisor",
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(builder: (_) => const VoiceChatScreen()),
                      );
                    },
                    style: cardStyle,
                    textStyle: textStyle,
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class HomeCard extends StatelessWidget {
  final String title;
  final String description;
  final VoidCallback onTap;
  final BoxDecoration style;
  final TextStyle textStyle;

  const HomeCard({
    super.key,
    required this.title,
    required this.description,
    required this.onTap,
    required this.style,
    required this.textStyle,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: 260,
        height: 160,
        padding: const EdgeInsets.all(20),
        decoration: style,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(title, style: textStyle),
            const Spacer(),
            Text(description, style: textStyle.copyWith(fontSize: 14, fontWeight: FontWeight.normal, color: Colors.grey[700])),
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
            onTap: () => Navigator.of(context).pop(),
          ),
          ListTile(
            leading: const Icon(Icons.settings),
            title: const Text("Settings"),
            onTap: () => Navigator.of(context).push(MaterialPageRoute(builder: (_) => const SettingsScreen())),
          ),
          ListTile(
            leading: const Icon(Icons.attach_money),
            title: const Text("Investment Options"),
            onTap: () => Navigator.of(context).push(MaterialPageRoute(builder: (_) => const InvestmentOptionsScreen())),
          ),
          ListTile(
            leading: const Icon(Icons.build),
            title: const Text("Financial Toolkit"),
            onTap: () => Navigator.of(context).push(MaterialPageRoute(builder: (_) => const FinancialToolkitMenu())),
          ),
        ],
      ),
    );
  }
}
