import 'package:flutter/material.dart';
import 'package:frontend_flutter/config/translated_text.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:flutter_animate/flutter_animate.dart';

import 'budget_screen.dart';
import 'funding_screen.dart';
import 'planner_screen.dart';

class FinancialToolkitMenu extends StatelessWidget {
  const FinancialToolkitMenu({super.key});

  @override
  Widget build(BuildContext context) {
    final Color primaryBlue = Colors.blue.shade800;
    final Color lightCard = Colors.blue.shade50;

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: primaryBlue,
        title: Text(
          "🧰 Financial Toolkit",
          style: GoogleFonts.poppins(
            color: Colors.white,
            fontWeight: FontWeight.w600,
            fontSize: 20,
          ),
        ),
        centerTitle: true,
        elevation: 0,
      ),
      body: Padding(
        padding: const EdgeInsets.all(20.0),
        child: ListView(
          children: [
            TranslatedText(
              "Empowering Small Businesses",
              style: GoogleFonts.poppins(
                fontSize: 18,
                fontWeight: FontWeight.w600,
                color: primaryBlue,
              ),
            ).animate().fadeIn(duration: 500.ms).slideY(begin: 0.2),

            const SizedBox(height: 20),

            // Budgeting Tool
            _buildCard(
              context,
              title: "📊 Smart Budgeting Tool",
              subtitle: "Track, analyze and get AI tips on your expenses.",
              icon: Icons.pie_chart,
              onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const BudgetScreen())),
              color: lightCard,
            ),

            const SizedBox(height: 10),

            // Funding Explorer
            _buildCard(
              context,
              title: "💰 Funding Explorer",
              subtitle: "Get matched with local SME schemes and loans.",
              icon: Icons.account_balance_wallet_outlined,
              onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const FundingScreen())),
              color: lightCard,
            ),

            const SizedBox(height: 10),

            // Growth Planner
            _buildCard(
              context,
              title: "📅 Growth Planner",
              subtitle: "Set goals and use forecasting for better decisions.",
              icon: Icons.bar_chart,
              onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const PlannerScreen())),
              color: lightCard,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildCard(
    BuildContext context, {
    required String title,
    required String subtitle,
    required IconData icon,
    required VoidCallback onTap,
    required Color color,
  }) {
    return Card(
      color: color,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      elevation: 3,
      child: ListTile(
        leading: Icon(icon, size: 28, color: Colors.blue.shade700),
        title: TranslatedText(
          title,
          style: GoogleFonts.poppins(fontSize: 16, fontWeight: FontWeight.w600, color: Colors.black87),
        ),
        subtitle: TranslatedText(
          subtitle,
          style: GoogleFonts.poppins(fontSize: 13.5, color: Colors.black54),
        ),
        onTap: onTap,
      ),
    ).animate().fadeIn(duration: 300.ms).slideX(begin: -0.1);
  }
}
