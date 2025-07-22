import 'package:flutter/material.dart';
import '../../api/toolkit_api.dart';

class BudgetScreen extends StatefulWidget {
  const BudgetScreen({super.key});

  @override
  State<BudgetScreen> createState() => _BudgetScreenState();
}

class _BudgetScreenState extends State<BudgetScreen> {
  final TextEditingController incomeController = TextEditingController();
  List<Map<String, TextEditingController>> expenseControllers = [
    {
    'name': TextEditingController(),
    'amount': TextEditingController(),
    }
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
      if (name.isNotEmpty) {
        expenses[name] = amount;
      }
    }

    var request = {
      'income': income,
      'expense': expenses,
    };

    final res = await ToolkitAPI.getBudgetSuggestions(request);
    print(res);

    setState(() {
      result = res['suggestions'] ?? 'No suggestion available';
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("📊 Budget Assistant")),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            TextField(
              controller: incomeController,
              decoration: const InputDecoration(labelText: "Monthly Income"),
              keyboardType: TextInputType.number,
            ),
            const SizedBox(height: 16),
            const Text("Expenses", style: TextStyle(fontWeight: FontWeight.bold)),
            ...expenseControllers.asMap().entries.map((entry) {
              int index = entry.key;
              final nameController = entry.value['name']!;
              final amountController = entry.value['amount']!;
              return Padding(
                padding: const EdgeInsets.only(bottom: 8),
                child: Row(
                  children: [
                    Expanded(
                      flex: 3,
                      child: DropdownButtonFormField<String>(
                        value: nameController.text.isNotEmpty ? nameController.text : null,
                        decoration: const InputDecoration(labelText: "Category"),
                        isExpanded: true, // Prevent intrinsic width overflow
                        items: categories
                            .map((cat) => DropdownMenuItem(
                                  value: cat,
                                  child: Text(cat),
                                ))
                            .toList(),
                        onChanged: (val) {
                          setState(() {
                            nameController.text = val ?? '';
                          });
                        },
                      ),
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      flex: 2,
                      child: TextField(
                        controller: amountController,
                        decoration: const InputDecoration(labelText: "Amount"),
                        keyboardType: TextInputType.number,
                      ),
                    ),
                    const SizedBox(width: 8),
                    IconButton(
                      icon: const Icon(Icons.remove_circle_outline),
                      onPressed: () {
                        setState(() {
                          if (expenseControllers.length > 1) {
                            expenseControllers.removeAt(index);
                          }
                        });
                      },
                    ),
                  ],
                ),
              );
            }),
            TextButton.icon(
              icon: const Icon(Icons.add),
              label: const Text("Add Expense"),
              onPressed: () {
                setState(() {
                expenseControllers.add({
                  'name': TextEditingController(),
                  'amount': TextEditingController(),
                  });
                });
              },
            ),
            const SizedBox(height: 16),
            ElevatedButton(
              onPressed: _getSuggestions,
              child: const Text("Get AI Budget Suggestion"),
            ),
            const SizedBox(height: 16),
            ...result.map((item) => Row(
              children: [
                const Text("• ", style: TextStyle(fontSize: 16)),
                Expanded(child: Text(item.toString())),
              ],
            )).toList(),
          ],
        ),
      ),
    );
  }
}
