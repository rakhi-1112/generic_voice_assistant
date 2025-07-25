import 'package:flutter/material.dart';
import 'package:frontend_flutter/screens/chat_screen/chat_screen.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:glassmorphism/glassmorphism.dart';
import 'package:google_fonts/google_fonts.dart';
import '../settings/settings_screen.dart';
import '../voice_chat/voice_chat_screen.dart';
import '../investment_options/investment_options_screen.dart';
import '../text_chat/text_chat_screen.dart';
import '../financial_toolkit/financial_toolkit_menu.dart';
import '../investment_tracker/investment_tracker_screen.dart';
import '../gamification/money_quest_game_screen.dart';
import 'package:frontend_flutter/screens/investment_options/age_based/age_based_onboarding_screen.dart';
import '../home/login_screen.dart'; // For reference if needed
import 'package:frontend_flutter/config/translated_text.dart';
import 'package:firebase_auth/firebase_auth.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final textStyle = GoogleFonts.poppins(
      fontSize: 18,
      fontWeight: FontWeight.w600,
      color: Colors.blue.shade900,
    );

    return Scaffold(
      drawer: const AppSidebar(),
      backgroundColor: Colors.transparent,
      appBar: PreferredSize(
        preferredSize: const Size.fromHeight(60),
        child: ClipRRect(
          borderRadius: const BorderRadius.vertical(
            bottom: Radius.circular(20),
          ),
          child: GlassmorphicContainer(
            width: double.infinity,
            height: 60,
            borderRadius: 0,
            blur: 20,
            alignment: Alignment.center,
            border: 0,
            linearGradient: LinearGradient(
              colors: [
                Colors.white.withOpacity(0.2),
                Colors.blue.withOpacity(0.1),
              ],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
            borderGradient: LinearGradient(
              colors: [
                Colors.white.withOpacity(0.3),
                Colors.blue.withOpacity(0.3),
              ],
            ),
            child: AppBar(
              backgroundColor: Colors.transparent,
              elevation: 0,
              centerTitle: true,
              title: Text(
                "Home",
                style: GoogleFonts.poppins(
                  fontSize: 22,
                  fontWeight: FontWeight.bold,
                  color: Colors.blue.shade900,
                ),
              ),
              foregroundColor: Colors.black,
              automaticallyImplyLeading: true,
            ),
          ),
        ),
      ),

      body: Stack(
        children: [
          Container(
            decoration: const BoxDecoration(
              gradient: LinearGradient(
                colors: [Colors.white, Color(0xFFE3F2FD)],
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
              ),
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  "Welcome 👋",
                  style: GoogleFonts.poppins(
                    fontSize: 32,
                    fontWeight: FontWeight.w700,
                    color: Colors.blue.shade900,
                    shadows: [
                      Shadow(
                        blurRadius: 4,
                        color: Colors.blue.shade100,
                        offset: const Offset(2, 2),
                      ),
                    ],
                  ),
                ).animate().fade(duration: 600.ms).slideY(begin: 0.3),
                const SizedBox(height: 20),
                Expanded(
                  child: Wrap(
                    spacing: 20,
                    runSpacing: 20,
                    children: [
                      _buildHomeCard(
                        context,
                        title: "📈 Your Investment Action Plan",
                        description: "Explore smart plans",
                        onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const InvestmentOptionsScreen())),
                        textStyle: textStyle,
                      ),
                      _buildHomeCard(
                        context,
                        title: "🧠 AI Powered Financial Coach",
                        description: "Smart agent tailored to your age",
                        onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => AgeBasedOnboardingScreen(onComplete: (_) {}))),
                        textStyle: textStyle,
                      ),
                      _buildHomeCard(
                        context,
                        title: "🧰 SME Toolkit",
                        description: "Manage and grow your business",
                        onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const FinancialToolkitMenu())),
                        textStyle: textStyle,
                      ),
                      _buildHomeCard(
                        context,
                        title: "🎙️ Chat with dolFin",
                        description: "Get instant money advice",
                        onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const VoiceChatScreen())),
                        textStyle: textStyle,
                      ),
                      _buildHomeCard(
                        context,
                        title: "🎮 Gamification",
                        description: "Financial literacy through fun",
                        onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => MoneyQuestGameScreen())),
                        textStyle: textStyle,
                      ),
                      _buildHomeCard(
                        context,
                        title: "📊 Tracker",
                        description: "Track your financial journey",
                        onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => InvestmentTrackerScreen())),
                        textStyle: textStyle,
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildHomeCard(
    BuildContext context, {
    required String title,
    required String description,
    required VoidCallback onTap,
    required TextStyle textStyle,
  }) {
    return GlassmorphicContainer(
      width: 260,
      height: 160,
      borderRadius: 24,
      blur: 20,
      alignment: Alignment.center,
      border: 1,
      linearGradient: LinearGradient(
        colors: [
          Colors.white.withOpacity(0.15),
          Colors.blue.withOpacity(0.05),
        ],
        begin: Alignment.topLeft,
        end: Alignment.bottomRight,
      ),
      borderGradient: LinearGradient(
        colors: [
          Colors.white.withOpacity(0.3),
          Colors.blue.withOpacity(0.3),
        ],
      ),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(24),
        child: Padding(
          padding: const EdgeInsets.all(20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(title, style: textStyle),
              const Spacer(),
              Text(
                description,
                style: textStyle.copyWith(fontSize: 14, fontWeight: FontWeight.normal, color: Colors.blue.shade700),
              ),
            ],
          ),
        ),
      ),
    ).animate().fade(duration: 500.ms).slideY(begin: 0.1);
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
            child: TranslatedText("Menu", style: TextStyle(color: Colors.white)),
          ),
          ListTile(
            leading: const Icon(Icons.home),
            title: const TranslatedText("Home"),
            onTap: () => Navigator.of(context).pop(),
          ),
          ListTile(
            leading: const Icon(Icons.settings),
            title: const TranslatedText("Settings"),
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
          ListTile(
            leading: const Icon(Icons.bar_chart),
            title: const Text("Investment Tracker"),
            onTap: () => Navigator.of(context).push(MaterialPageRoute(builder: (_) => const InvestmentTrackerScreen())),
          ),
         ListTile(
          leading: const Icon(Icons.videogame_asset),
          title: const Text("Money Quest Game"),
          onTap: () {
            Navigator.of(context).push(MaterialPageRoute(
              builder: (context) => const MoneyQuestGameScreen(),
            ));
          },
        ),
        const Divider(),
            ListTile(
              leading: const Icon(Icons.logout),
              title: const TranslatedText("Logout"),
              onTap: () async {
                Navigator.of(context).pop();

                await FirebaseAuth.instance.signOut();

                Navigator.of(context).pushNamedAndRemoveUntil(
                  '/login',
                  (route) => false,
                );
              },
            ),
        ],
      ),
    );
  }
}
