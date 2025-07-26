import 'package:flutter/material.dart';
import 'package:frontend_flutter/config/translated_text.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../api/toolkit_api.dart';

class FundingScreen extends StatefulWidget {
  const FundingScreen({super.key});

  @override
  State<FundingScreen> createState() => _FundingScreenState();
}

class _FundingScreenState extends State<FundingScreen> {
  final TextEditingController otherSectorController = TextEditingController();
  final TextEditingController amountController = TextEditingController();

  String? selectedSector;
  List<dynamic> fundingInfo = [];

  final List<String> sectors = [
    'Agriculture',
    'Healthcare',
    'Education',
    'Technology',
    'Manufacturing',
    'Retail',
    'Renewable Energy',
    'Tourism',
    'Transport',
    'Handicrafts',
    'Women Empowerment',
    'Green Energy',
    'Small Businesses',
    'Other',
  ];

  void _matchFunding() async {
    final sector = selectedSector == 'Other'
        ? otherSectorController.text
        : selectedSector ?? '';

    final amount = double.tryParse(amountController.text) ?? 0;

    final res = await ToolkitAPI.getFundingMatches({
      'sector': sector,
      'amount_needed': amount,
    });

    setState(() {
      fundingInfo = res['matches'] ?? [];
    });
  }

  @override
  Widget build(BuildContext context) {
    final primaryColor = Colors.blue.shade800;

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: primaryColor,
        title: TranslatedText(
          "💰 Funding Opportunities",
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
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            TranslatedText("Select Business Sector", style: GoogleFonts.poppins(fontWeight: FontWeight.w600)),
            const SizedBox(height: 8),
            DropdownButtonFormField<String>(
              value: selectedSector,
              isExpanded: true,
              icon: const Icon(Icons.keyboard_arrow_down_rounded, color: Colors.blue),
              decoration: InputDecoration(
                labelText: "Choose a sector",
                labelStyle: GoogleFonts.poppins(
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                  color: Colors.blue.shade900,
                ),
                border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                filled: true,
                fillColor: Colors.white,
              ),
              style: GoogleFonts.poppins(fontSize: 14, color: Colors.black87),
              dropdownColor: Colors.white,
              items: sectors.map((String value) {
                return DropdownMenuItem<String>(
                  value: value,
                  child: TranslatedText(
                    value,
                    style: GoogleFonts.poppins(fontSize: 14, fontWeight: FontWeight.w500),
                  ),
                );
              }).toList(),
              onChanged: (value) {
                setState(() {
                  selectedSector = value;
                });
              },
            ),

            if (selectedSector == 'Other') ...[
              const SizedBox(height: 12),
              TextField(
                controller: otherSectorController,
                style: GoogleFonts.poppins(fontSize: 14),
                decoration: InputDecoration(
                  labelText: "Enter your custom sector",
                  labelStyle: GoogleFonts.poppins(fontWeight: FontWeight.w600),
                  border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                ),
              ),
            ],

            const SizedBox(height: 16),
            TextField(
              controller: amountController,
              style: GoogleFonts.poppins(fontSize: 14),
              keyboardType: TextInputType.number,
              decoration: InputDecoration(
                labelText: "Funding Amount Needed",
                labelStyle: GoogleFonts.poppins(fontWeight: FontWeight.w600),
                border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
              ),
            ),

            const SizedBox(height: 20),
            ElevatedButton.icon(
              icon: const Icon(Icons.search),
              onPressed: _matchFunding,
              style: ElevatedButton.styleFrom(
                backgroundColor: primaryColor,
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 14),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
              ),
              label: TranslatedText(
                "Find Funding Options",
                style: GoogleFonts.poppins(fontWeight: FontWeight.w600, fontSize: 16),
              ),
            ),

            const SizedBox(height: 24),
            Expanded(
              child: fundingInfo.isEmpty
                  ? Center(
                      child: TranslatedText("No matches found", style: GoogleFonts.poppins()),
                    )
                  : ListView.builder(
                      itemCount: fundingInfo.length,
                      itemBuilder: (context, index) {
                        final item = fundingInfo[index];
                        return Card(
                          elevation: 3,
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                          margin: const EdgeInsets.symmetric(vertical: 8),
                          child: Padding(
                            padding: const EdgeInsets.all(16),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                TranslatedText(
                                  item['name'] ?? 'Untitled Program',
                                  style: GoogleFonts.poppins(
                                    fontSize: 17,
                                    fontWeight: FontWeight.bold,
                                    color: primaryColor,
                                  ),
                                ),
                                const SizedBox(height: 8),
                                TranslatedText(
                                  item['description'] ?? 'No description available.',
                                  style: GoogleFonts.poppins(fontSize: 14),
                                ),
                                const SizedBox(height: 12),
                                Row(
                                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                  children: [
                                    TranslatedText("Industry: ${item['industry'] ?? 'N/A'}",
                                        style: GoogleFonts.poppins(fontSize: 13)),
                                    TranslatedText("Region: ${item['region'] ?? 'N/A'}",
                                        style: GoogleFonts.poppins(fontSize: 13)),
                                  ],
                                ),
                                const SizedBox(height: 4),
                                Row(
                                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                  children: [
                                    TranslatedText("Eligibility: ${item['eligibility'] ?? 'N/A'}",
                                        style: GoogleFonts.poppins(fontSize: 13)),
                                    TranslatedText(
                                      "Funding: ₹${item['funding_min']} – ₹${item['funding_max']}",
                                      style: GoogleFonts.poppins(fontSize: 13),
                                    ),
                                  ],
                                ),
                              ],
                            ),
                          ),
                        );
                      },
                    ),
            ),
          ],
        ),
      ),
    );
  }
}