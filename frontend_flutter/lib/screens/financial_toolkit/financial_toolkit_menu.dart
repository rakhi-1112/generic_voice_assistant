import 'package:flutter/material.dart';
import 'budget_screen.dart';
import 'funding_screen.dart';
import 'planner_screen.dart';


class FinancialToolkitMenu extends StatelessWidget {
  const FinancialToolkitMenu({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("🧰 SME Financial Toolkit"),
        backgroundColor: Colors.blue,
      ),
      body: Padding(
        padding: const EdgeInsets.all(20.0),
        child: ListView(
          children: [
            const Text(
              "Empowering Small Businesses",
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 20),

            // Budgeting Tool
            Card(
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
              elevation: 4,
              child: ListTile(
                leading: const Icon(Icons.pie_chart, color: Colors.indigo),
                title: const Text("📊 Smart Budgeting Tool"),
                subtitle: const Text("Track, analyze and get AI tips on your expenses."),
                onTap: () {
                  Navigator.push(context, MaterialPageRoute(builder: (_) => const BudgetScreen()));
                },
              ),
            ),
            const SizedBox(height: 10),

            // Funding Explorer
            Card(
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
              elevation: 4,
              child: ListTile(
                leading: const Icon(Icons.account_balance_wallet_outlined, color: Colors.indigo),
                title: const Text("💰 Funding Explorer"),
                subtitle: const Text("Get matched with local SME schemes and loans."),
                onTap: () {
                  Navigator.push(context, MaterialPageRoute(builder: (_) => const FundingScreen()));
                },
              ),
            ),
            const SizedBox(height: 10),

            // Growth Planner
            Card(
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
              elevation: 4,
              child: ListTile(
                leading: const Icon(Icons.bar_chart, color: Colors.indigo),
                title: const Text("📅 Growth Planner"),
                subtitle: const Text("Set goals and use forecasting for better decisions."),
                onTap: () {
                  Navigator.push(context, MaterialPageRoute(builder: (_) => const PlannerScreen()));
                },
              ),
            ),
            
          ],
        ),
      ),
    );
  }
}
