import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:flutter_animate/flutter_animate.dart';

class ActionPlanScreen extends StatelessWidget {
  final String goal;
  final Map<String, String> plan;

  const ActionPlanScreen({required this.goal, required this.plan, Key? key}) : super(key: key);

  List<PieChartSectionData> _buildPieChartSections() {
    return plan.entries.map((entry) {
      final value = double.tryParse(entry.value.replaceAll('%', '')) ?? 0;
      final color = _getColorFor(entry.key);
      return PieChartSectionData(
        color: color,
        value: value,
        title: '${entry.value}',
        titleStyle: GoogleFonts.poppins(fontSize: 13, color: Colors.white, fontWeight: FontWeight.w600),
        radius: 50,
      );
    }).toList();
  }

  Color _getColorFor(String category) {
    switch (category) {
      case "Mutual Funds":
        return Colors.indigo;
      case "Fixed Deposits":
        return Colors.blue;
      case "SIPs":
        return Colors.lightBlue;
      case "Savings Account":
        return Colors.teal;
      case "Liquid Mutual Funds":
        return Colors.cyan;
      case "Recurring Deposits":
        return Colors.deepPurpleAccent;
      case "PPF":
      case "Public Provident Fund (PPF)":
        return Colors.blueGrey;
      case "Index Funds":
        return Colors.deepPurple;
      case "Crypto":
      case "Crypto (ETH/Layer 2)":
      case "Crypto (Stablecoins)":
        return Colors.orangeAccent;
      case "REITs":
        return Colors.pink.shade300;
      case "Green Bonds":
        return Colors.green.shade400;
      case "Gold ETFs":
        return Colors.amber;
      case "Stocks":
        return Colors.deepOrange;
      default:
        return Colors.indigoAccent;
    }
  }

  String _getEmojiForGoal(String goal) {
    switch (goal.toLowerCase()) {
      case "retirement":
        return "🧓";
      case "vacation":
        return "🏖️";
      case "emergency fund":
        return "🚨";
      case "buy a house":
        return "🏠";
      case "education":
        return "🎓";
      default:
        return "📈";
    }
  }

  @override
  Widget build(BuildContext context) {
    final emoji = _getEmojiForGoal(goal);

    return Scaffold(
      extendBodyBehindAppBar: true,
      backgroundColor: const Color(0xFFe0f7fa),
      appBar: AppBar(
        title: Text("Action Plan", style: GoogleFonts.poppins(color: Colors.white)),
        backgroundColor: Colors.indigo.withOpacity(0.9),
        elevation: 0,
      ),
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            colors: [Color(0xFFe0f7fa), Color(0xFFb2ebf2)],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
        ),
        child: SingleChildScrollView(
          padding: const EdgeInsets.fromLTRB(20, 100, 20, 40),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              // 🎯 Goal Card
              Container(
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  color: Colors.white.withOpacity(0.95),
                  borderRadius: BorderRadius.circular(20),
                  boxShadow: [BoxShadow(color: Colors.black12, blurRadius: 8)],
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(emoji, style: const TextStyle(fontSize: 36)),
                    const SizedBox(width: 12),
                    Flexible(
                      child: Text(
                        "Your goal: $goal",
                        style: GoogleFonts.poppins(
                          fontSize: 20,
                          fontWeight: FontWeight.w600,
                          color: Colors.indigo,
                        ),
                      ),
                    ),
                  ],
                ),
              ).animate().fadeIn().slideY(begin: 0.2),

              const SizedBox(height: 20),

              Text(
                "Based on your goal, here's a smart mix of investments 🧠",
                textAlign: TextAlign.center,
                style: GoogleFonts.poppins(fontSize: 15.5, color: Colors.indigo.shade700),
              ).animate().fadeIn().slideY(begin: 0.2),

              const SizedBox(height: 20),

              // 📊 Pie Chart
              Container(
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  color: Colors.white.withOpacity(0.9),
                  borderRadius: BorderRadius.circular(20),
                  boxShadow: [BoxShadow(color: Colors.black12, blurRadius: 8)],
                ),
                child: Column(
                  children: [
                    Text(
                      "Allocation Breakdown",
                      style: GoogleFonts.poppins(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: Colors.indigo,
                      ),
                    ),
                    const SizedBox(height: 16),
                    SizedBox(
                      height: 200,
                      child: PieChart(
                        PieChartData(
                          sections: _buildPieChartSections(),
                          centerSpaceRadius: 30,
                        ),
                      ),
                    ),
                  ],
                ),
              ).animate().fadeIn().slideY(begin: 0.3),

              const SizedBox(height: 30),

              // 🧾 Detailed Breakdown List
              Column(
                children: plan.entries.map((entry) {
                  return Container(
                    margin: const EdgeInsets.only(bottom: 12),
                    decoration: BoxDecoration(
                      color: Colors.white.withOpacity(0.85),
                      borderRadius: BorderRadius.circular(16),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withOpacity(0.05),
                          blurRadius: 10,
                          offset: const Offset(0, 4),
                        ),
                      ],
                    ),
                    child: ListTile(
                      leading: Icon(Icons.account_balance_wallet, color: _getColorFor(entry.key)),
                      title: Text(
                        entry.key,
                        style: GoogleFonts.poppins(fontSize: 16, color: Colors.black87),
                      ),
                      trailing: Text(
                        entry.value,
                        style: GoogleFonts.poppins(
                          fontWeight: FontWeight.bold,
                          color: Colors.indigo,
                          fontSize: 16,
                        ),
                      ),
                    ),
                  ).animate().fadeIn().slideX(begin: -0.2);
                }).toList(),
              ),

              const SizedBox(height: 30),

              // Final tip
              Text(
                "⚡ Diversify smartly. Start small, stay consistent!",
                textAlign: TextAlign.center,
                style: GoogleFonts.poppins(fontSize: 14, color: Colors.indigo.shade600),
              ).animate().fadeIn().slideY(begin: 0.1),
            ],
          ),
        ),
      ),
    );
  }
}
