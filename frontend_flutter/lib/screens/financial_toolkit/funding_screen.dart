import 'package:flutter/material.dart';
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
    return Scaffold(
      appBar: AppBar(title: const Text("💰 Funding Opportunities")),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text("Select Business Sector"),
            DropdownButton<String>(
              isExpanded: true,
              value: selectedSector,
              hint: const Text("Choose a sector"),
              items: sectors.map((String value) {
                return DropdownMenuItem<String>(
                  value: value,
                  child: Text(value),
                );
              }).toList(),
              onChanged: (value) {
                setState(() {
                  selectedSector = value;
                });
              },
            ),
            if (selectedSector == 'Other') ...[
              const SizedBox(height: 8),
              TextField(
                controller: otherSectorController,
                decoration: const InputDecoration(
                  labelText: "Enter your custom sector",
                ),
              ),
            ],
            const SizedBox(height: 16),
            TextField(
              controller: amountController,
              decoration: const InputDecoration(labelText: "Funding Amount Needed"),
              keyboardType: TextInputType.number,
            ),
            const SizedBox(height: 16),
            ElevatedButton(
              onPressed: _matchFunding,
              child: const Text("Find Funding Options"),
            ),
            const SizedBox(height: 16),
            Expanded(
              child: fundingInfo is String || (fundingInfo is List && fundingInfo.isEmpty)
                  ? const Center(child: Text("No matches found"))
                  : ListView.builder(
                      itemCount: fundingInfo.length,
                      itemBuilder: (context, index) {
                        final item = fundingInfo[index];
                        return Card(
                          elevation: 4,
                          margin: const EdgeInsets.symmetric(vertical: 8),
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                          child: Padding(
                            padding: const EdgeInsets.all(12),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(item['name'] ?? '',
                                    style: const TextStyle(
                                      fontSize: 18,
                                      fontWeight: FontWeight.bold,
                                    )),
                                const SizedBox(height: 6),
                                Text(item['description'] ?? '',
                                    style: const TextStyle(fontSize: 14)),
                                const SizedBox(height: 6),
                                Row(
                                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                  children: [
                                    Text("Industry: ${item['industry'] ?? 'N/A'}"),
                                    Text("Region: ${item['region'] ?? 'N/A'}"),
                                  ],
                                ),
                                const SizedBox(height: 4),
                                Row(
                                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                  children: [
                                    Text("Eligibility: ${item['eligibility'] ?? 'N/A'}"),
                                    Text("Funding: ₹${item['funding_min']} – ₹${item['funding_max']}"),
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
