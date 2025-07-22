import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../../api/toolkit_api.dart';

class PlannerScreen extends StatefulWidget {
  const PlannerScreen({super.key});

  @override
  State<PlannerScreen> createState() => _PlannerScreenState();
}

class _PlannerScreenState extends State<PlannerScreen> {
  List<Map<String, dynamic>> history = [
    {"ds": DateTime.now(), "y": null}
  ];

  List<dynamic> forecast = [];
  String? errorMessage;

  void _addRow() {
    setState(() {
      history.add({"ds": DateTime.now(), "y": null});
    });
  }

  void _removeRow(int index) {
    setState(() {
      history.removeAt(index);
    });
  }

  Future<void> _selectDate(int index) async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: history[index]["ds"],
      firstDate: DateTime(2000),
      lastDate: DateTime(2100),
    );

    if (picked != null) {
      setState(() {
        history[index]["ds"] = picked;
      });
    }
  }

  void _getForecast() async {
    // Format data as required
    final formatted = history
        .where((e) => e["y"] != null)
        .map((e) => {
              "ds": DateFormat('yyyy-MM-dd').format(e["ds"]),
              "y": e["y"]
            })
        .toList();

    final res = await ToolkitAPI.getForecast({"history": formatted});

    setState(() {
      if (res.containsKey('error')) {
        errorMessage = res['error'];
        forecast = [];
      } else {
        errorMessage = null;
        forecast = res['forecast'] ?? [];
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("📈 Business Planner")),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text("Enter at least 6 months of historical data:"),
            const SizedBox(height: 12),

            ...history.asMap().entries.map((entry) {
              final index = entry.key;
              final item = entry.value;

              return Padding(
                padding: const EdgeInsets.only(bottom: 12),
                child: Row(
                  children: [
                    Expanded(
                      flex: 2,
                      child: InkWell(
                        onTap: () => _selectDate(index),
                        child: InputDecorator(
                          decoration: const InputDecoration(labelText: "Date"),
                          child: Text(DateFormat('yyyy-MM-dd').format(item["ds"])),
                        ),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      flex: 2,
                      child: TextField(
                        keyboardType: TextInputType.number,
                        decoration: const InputDecoration(labelText: "Amount"),
                        onChanged: (value) {
                          setState(() {
                            item["y"] = double.tryParse(value);
                          });
                        },
                      ),
                    ),
                    IconButton(
                      icon: const Icon(Icons.delete, color: Colors.red),
                      onPressed: () => _removeRow(index),
                    ),
                  ],
                ),
              );
            }).toList(),

            const SizedBox(height: 12),

            Align(
              alignment: Alignment.centerLeft,
              child: IconButton(
                icon: const Icon(Icons.add_circle, size: 32, color: Colors.green),
                onPressed: _addRow,
                tooltip: "Add Row",
              ),
            ),

            const SizedBox(height: 20),

            Center(
              child: ElevatedButton(
                onPressed: _getForecast,
                child: const Text("Generate Forecast"),
              ),
            ),

            const SizedBox(height: 24),

            if (errorMessage != null) ...[
              Text(errorMessage!, style: const TextStyle(color: Colors.red)),
            ] else if (forecast.isNotEmpty) ...[
              const Text(
                "📊 Forecast for next 3 months:",
                style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
              ),
              const SizedBox(height: 12),
              SingleChildScrollView(
                scrollDirection: Axis.horizontal,
                child: DataTable(
                  columns: const [
                    DataColumn(label: Text("Date")),
                    DataColumn(label: Text("Projected Amount")),
                  ],
                  rows: forecast.map((entry) {
                    return DataRow(cells: [
                      DataCell(Text(entry['ds'])),
                      DataCell(Text("₹${entry['yhat'].toStringAsFixed(2)}")),
                    ]);
                  }).toList(),
                ),
              ),
            ]
          ],
        ),
      ),
    );
  }
}
