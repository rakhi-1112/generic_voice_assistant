import 'package:flutter/material.dart';
import 'package:frontend_flutter/config/translated_text.dart';
import 'package:google_fonts/google_fonts.dart';
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
    builder: (context, child) {
      return Theme(
        data: ThemeData(
          colorScheme: ColorScheme.light(
            primary: Colors.blue.shade800, // header & active date color
            onPrimary: Colors.white,       // text color on primary
            surface: Colors.white,         // calendar background
            onSurface: Colors.black87,     // default text
          ),
          dialogBackgroundColor: Colors.white,
          textTheme: GoogleFonts.poppinsTextTheme().copyWith(
            titleMedium: GoogleFonts.poppins(fontWeight: FontWeight.w600),
            bodyLarge: GoogleFonts.poppins(),
            bodyMedium: GoogleFonts.poppins(),
          ),
          dialogTheme: DialogThemeData(
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(16),
            ),
          ),
        ),
        child: child!,
      );
    },
  );

  if (picked != null) {
    setState(() {
      history[index]["ds"] = picked;
    });
  }
}


  void _getForecast() async {
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
    final primaryColor = Colors.blue.shade800;

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: primaryColor,
        title: Text(
          "📈 Business Planner",
          style: GoogleFonts.poppins(
            color: Colors.white,
            fontWeight: FontWeight.w600,
          ),
        ),
        centerTitle: true,
        elevation: 1,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            TranslatedText(
              "Enter at least 6 months of historical data:",
              style: GoogleFonts.poppins(fontWeight: FontWeight.w600),
            ),
            const SizedBox(height: 16),
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
                          decoration: InputDecoration(
                            labelText: "Date",
                            labelStyle: GoogleFonts.poppins(fontWeight: FontWeight.w500),
                            border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                          ),
                          child: TranslatedText(
                            DateFormat('yyyy-MM-dd').format(item["ds"]),
                            style: GoogleFonts.poppins(),
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      flex: 2,
                      child: TextField(
                        keyboardType: TextInputType.number,
                        decoration: InputDecoration(
                          labelText: "Amount",
                          labelStyle: GoogleFonts.poppins(fontWeight: FontWeight.w500),
                          border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                        ),
                        style: GoogleFonts.poppins(),
                        onChanged: (value) {
                          setState(() {
                            item["y"] = double.tryParse(value);
                          });
                        },
                      ),
                    ),
                    IconButton(
                      icon: const Icon(Icons.delete, color: Colors.redAccent),
                      onPressed: () => _removeRow(index),
                    ),
                  ],
                ),
              );
            }).toList(),

            const SizedBox(height: 8),
            TextButton.icon(
              onPressed: _addRow,
              icon: const Icon(Icons.add_circle, color: Colors.green),
              label: TranslatedText(
                "Add Row",
                style: GoogleFonts.poppins(
                  fontSize: 15,
                  color: Colors.green,
                  fontWeight: FontWeight.w600,
                ),
              ),
              style: TextButton.styleFrom(
                backgroundColor: Colors.green.shade50,
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(10),
                ),
              ),
            ),

            const SizedBox(height: 24),
            Center(
              child: ElevatedButton.icon(
                icon: const Icon(Icons.auto_graph),
                onPressed: _getForecast,
                label: Text(
                  "Generate Forecast",
                  style: GoogleFonts.poppins(fontWeight: FontWeight.w600, fontSize: 16),
                ),
                style: ElevatedButton.styleFrom(
                  backgroundColor: primaryColor,
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 14),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                ),
              ),
            ),

            const SizedBox(height: 24),
            if (errorMessage != null)
              Text(
                errorMessage!,
                style: GoogleFonts.poppins(color: Colors.red),
              )
            else if (forecast.isNotEmpty) ...[
              Text(
                "📊 Forecast for next 3 months:",
                style: GoogleFonts.poppins(
                  fontWeight: FontWeight.bold,
                  fontSize: 16,
                ),
              ),
              const SizedBox(height: 12),
              SingleChildScrollView(
                scrollDirection: Axis.horizontal,
                child: DataTable(
                  columns: [
                    DataColumn(
                      label: Text("Date", style: GoogleFonts.poppins(fontWeight: FontWeight.w600)),
                    ),
                    DataColumn(
                      label: Text("Projected Amount", style: GoogleFonts.poppins(fontWeight: FontWeight.w600)),
                    ),
                  ],
                  rows: forecast.map((entry) {
                    return DataRow(cells: [
                      DataCell(Text(entry['ds'], style: GoogleFonts.poppins())),
                      DataCell(Text("₹${entry['yhat'].toStringAsFixed(2)}", style: GoogleFonts.poppins())),
                    ]);
                  }).toList(),
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }
}
