import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:flutter_animate/flutter_animate.dart';
import '../../api/toolkit_api.dart';
import 'package:frontend_flutter/config/translated_text.dart';

class BudgetScreen extends StatefulWidget {
  const BudgetScreen({super.key});

  @override
  State<BudgetScreen> createState() => _BudgetScreenState();
}

class _BudgetScreenState extends State<BudgetScreen> {
  final TextEditingController incomeController = TextEditingController();
  List<Map<String, TextEditingController>> expenseControllers = [
    {'name': TextEditingController(), 'amount': TextEditingController()}
  ];
  List<dynamic> result = [];

  final List<String> categories = [
    'Rent',
    'Salaries',
    'Marketing',
    'Utilities',
    'Maintenance Overhead',
    'Transportation',
    'Office Supplies',
    'Insurance',
    'Legal & Accounting',
    'Others',
  ];

  void _getSuggestions() async {
    final income = double.tryParse(incomeController.text) ?? 0;
    Map<String, double> expenses = {};

    for (var controllers in expenseControllers) {
      final name = controllers['name']!.text.trim();
      final amount = double.tryParse(controllers['amount']!.text.trim()) ?? 0;
      if (name.isNotEmpty) expenses[name] = amount;
    }

    var request = {'income': income, 'expense': expenses};
    final res = await ToolkitAPI.getBudgetSuggestions(request);

    setState(() {
      result = res['suggestions'] ?? ['No suggestion available'];
    });
  }

  @override
  Widget build(BuildContext context) {
    final primaryColor = Colors.blue.shade800;

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: primaryColor,
        title: Text(
          "📊 Budget Assistant",
          style: GoogleFonts.poppins(
            fontSize: 20,
            fontWeight: FontWeight.w600,
            color: Colors.white,
          ),
        ),
        centerTitle: true,
        elevation: 1,
      ),
      body: Padding(
        padding: const EdgeInsets.all(20),
        child: ListView(
          children: [
            Text(
              "Monthly Income",
              style: GoogleFonts.poppins(fontWeight: FontWeight.w600),
            ),
            const SizedBox(height: 6),
            TextField(
              controller: incomeController,
              keyboardType: TextInputType.number,
              decoration: InputDecoration(
                hintText: "Enter income amount",
                border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                hintStyle: GoogleFonts.poppins(),
              ),
              style: GoogleFonts.poppins(),
            ),

            const SizedBox(height: 20),
            TranslatedText("Expenses", style: GoogleFonts.poppins(fontWeight: FontWeight.w700, fontSize: 16, color: primaryColor)),

            const SizedBox(height: 12),
            ...expenseControllers.asMap().entries.map((entry) {
              int index = entry.key;
              final nameController = entry.value['name']!;
              final amountController = entry.value['amount']!;

              return Row(
                children: [
                  Expanded(
                    flex: 3,
                    child: DropdownButtonFormField<String>(
                    value: nameController.text.isNotEmpty ? nameController.text : null,
                    isExpanded: true,
                    decoration: InputDecoration(
                      labelText: "Category",
                      labelStyle: GoogleFonts.poppins(fontSize: 14, color: Colors.blue.shade900),
                      border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                      filled: true,
                      fillColor: Colors.white,
                    ),
                    dropdownColor: Colors.white,
                    icon: const Icon(Icons.arrow_drop_down, color: Colors.blue),
                    style: GoogleFonts.poppins(fontSize: 14, color: Colors.black87),
                    items: categories.map((cat) {
                      return DropdownMenuItem(
                        value: cat,
                        child: Text(
                          cat,
                          style: GoogleFonts.poppins(
                            fontSize: 14,
                            color: Colors.black87,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      );
                    }).toList(),
                    onChanged: (val) {
                      setState(() => nameController.text = val ?? '');
                    },
                  ),
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    flex: 2,
                    child: TextField(
                      controller: amountController,
                      keyboardType: TextInputType.number,
                      decoration: InputDecoration(
                        labelText: "Amount",
                        labelStyle: GoogleFonts.poppins(fontSize: 14),
                        border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                      ),
                      style: GoogleFonts.poppins(fontSize: 14),
                    ),
                  ),
                  const SizedBox(width: 8),
                  IconButton(
                    icon: const Icon(Icons.remove_circle_outline, color: Colors.redAccent),
                    onPressed: () {
                      setState(() {
                        if (expenseControllers.length > 1) {
                          expenseControllers.removeAt(index);
                        }
                      });
                    },
                  ),
                ],
              );
            }),

            const SizedBox(height: 10),
            TextButton.icon(
            icon: const Icon(Icons.add, color: Colors.blueAccent),
            label: Text(
              "Add Expense",
              style: GoogleFonts.poppins(
                color: Colors.blueAccent,
                fontSize: 16,
                fontWeight: FontWeight.w600,
              ),
            ),
            style: TextButton.styleFrom(
              backgroundColor: Colors.blue.shade50,
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(10),
              ),
              foregroundColor: Colors.blueAccent,
            ),
            onPressed: () {
              setState(() {
                expenseControllers.add({
                  'name': TextEditingController(),
                  'amount': TextEditingController(),
                });
              });
            },
          ),


            const SizedBox(height: 20),
            ElevatedButton.icon(
              onPressed: _getSuggestions,
              icon: const Icon(Icons.auto_fix_high_rounded),
              label: TranslatedText("Get AI Budget Suggestion", style: GoogleFonts.poppins(fontWeight: FontWeight.w600)),
              style: ElevatedButton.styleFrom(
                backgroundColor: primaryColor,
                foregroundColor: Colors.white,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                padding: const EdgeInsets.symmetric(vertical: 14),
              ),
            ).animate().fadeIn(duration: 400.ms),

            const SizedBox(height: 20),
            if (result.isNotEmpty)
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: result.map((item) {
                  return Padding(
                    padding: const EdgeInsets.only(bottom: 6),
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const TranslatedText("• ", style: TextStyle(fontSize: 16)),
                        Expanded(
                          child: Text(
                            item.toString(),
                            style: GoogleFonts.poppins(fontSize: 14, color: Colors.black87),
                          ),
                        ),
                      ],
                    ),
                  );
                }).toList(),
              ),
          ],
        ),
      ),
    );
  }
}
