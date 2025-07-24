import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:glassmorphism/glassmorphism.dart';

class InvestmentTrackerScreen extends StatefulWidget {
  const InvestmentTrackerScreen({super.key});

  @override
  State<InvestmentTrackerScreen> createState() => _InvestmentTrackerScreenState();
}

class _InvestmentTrackerScreenState extends State<InvestmentTrackerScreen> {
  String _selectedRange = 'Weekly';

  final List<BarChartGroupData> _weeklyBarData = [
    _buildBarGroup(0, 5000),
    _buildBarGroup(1, 8000),
    _buildBarGroup(2, 6000),
    _buildBarGroup(3, 7500),
  ];

  final List<BarChartGroupData> _monthlyBarData = [
    _buildBarGroup(0, 20000),
    _buildBarGroup(1, 18000),
    _buildBarGroup(2, 25000),
    _buildBarGroup(3, 22000),
  ];

  final List<BarChartGroupData> _allTimeBarData = [
    _buildBarGroup(0, 80000),
    _buildBarGroup(1, 95000),
    _buildBarGroup(2, 90000),
    _buildBarGroup(3, 100000),
  ];

  List<BarChartGroupData> get _currentBarData {
    switch (_selectedRange) {
      case 'Monthly':
        return _monthlyBarData;
      case 'All Time':
        return _allTimeBarData;
      case 'Weekly':
      default:
        return _weeklyBarData;
    }
  }

  final Map<String, double> _investmentDistribution = {
    'Stocks 📈': 40,
    'Mutual Funds 💰': 30,
    'Savings 🏦': 20,
    'Gold 🪙': 10,
  };

  static BarChartGroupData _buildBarGroup(int x, double y) {
    return BarChartGroupData(
      x: x,
      barRods: [
        BarChartRodData(toY: y, color: Colors.teal, width: 24),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF1F5FF),
      appBar: AppBar(
        title: Text(
          "📊 Investment Tracker",
          style: GoogleFonts.poppins(color: Colors.black87, fontWeight: FontWeight.w600),
        ),
        backgroundColor: Colors.white,
        elevation: 1,
        centerTitle: true,
        foregroundColor: Colors.black87,
      ),
      body: Stack(
        children: [
          Positioned.fill(
            child: Container(
              decoration: const BoxDecoration(
                gradient: LinearGradient(
                  colors: [Colors.white, Color(0xFFE3F2FD)],
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                ),
              ),
            ),
          ),
          Center(
            child: GlassmorphicContainer(
              width: MediaQuery.of(context).size.width * 0.92,
              height: MediaQuery.of(context).size.height * 0.90,
              borderRadius: 20,
              blur: 20,
              border: 1,
              alignment: Alignment.center,
              linearGradient: LinearGradient(
                colors: [
                  Colors.white.withOpacity(0.25),
                  Colors.blue.withOpacity(0.1),
                ],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
              borderGradient: LinearGradient(
                colors: [
                  Colors.white.withOpacity(0.5),
                  Colors.blue.withOpacity(0.3),
                ],
              ),
              child: Padding(
                padding: const EdgeInsets.all(20),
                child: Column(
                  children: [
                    Row(
                      children: [
                        const Icon(Icons.filter_alt, color: Colors.deepPurple),
                        const SizedBox(width: 10),
                        Text("Select Range:", style: GoogleFonts.poppins(fontSize: 14)),
                        const SizedBox(width: 10),
                        DropdownButton<String>(
                          value: _selectedRange,
                          style: GoogleFonts.poppins(color: Colors.blue.shade900),
                          dropdownColor: Colors.white,
                          items: ['Weekly', 'Monthly', 'All Time'].map((range) {
                            return DropdownMenuItem(
                              value: range,
                              child: Text(range, style: GoogleFonts.poppins()),
                            );
                          }).toList(),
                          onChanged: (value) {
                            setState(() {
                              _selectedRange = value!;
                            });
                          },
                        ),
                      ],
                    ),
                    const SizedBox(height: 20),
                    Text(
                      _selectedRange == 'Weekly'
                          ? "📆 Weekly Investment Overview"
                          : _selectedRange == 'Monthly'
                              ? "📅 Monthly Investment Overview"
                              : "📊 All-Time Investment Overview",
                      style: GoogleFonts.poppins(fontSize: 18, fontWeight: FontWeight.bold),
                    ),
                    const SizedBox(height: 10),
                    SizedBox(
                      height: 220,
                      child: BarChart(
                        BarChartData(
                          barGroups: _currentBarData,
                          borderData: FlBorderData(show: false),
                          titlesData: FlTitlesData(
                            leftTitles: AxisTitles(
                              sideTitles: SideTitles(
                                showTitles: true,
                                reservedSize: 42,
                                getTitlesWidget: (value, _) =>
                                    Text('₹${value.toInt()}', style: const TextStyle(fontSize: 10)),
                              ),
                            ),
                            bottomTitles: AxisTitles(
                              sideTitles: SideTitles(
                                showTitles: true,
                                getTitlesWidget: (value, _) =>
                                    Text("Q${value.toInt() + 1}", style: const TextStyle(fontSize: 12)),
                              ),
                            ),
                            topTitles: AxisTitles(sideTitles: SideTitles(showTitles: false)),
                            rightTitles: AxisTitles(sideTitles: SideTitles(showTitles: false)),
                          ),
                          gridData: FlGridData(show: true),
                        ),
                      ),
                    ),
                    const SizedBox(height: 30),
                    Text(
                      "🏦 Investment Areas",
                      style: GoogleFonts.poppins(fontSize: 18, fontWeight: FontWeight.bold),
                    ),
                    const SizedBox(height: 10),
                    Expanded(
                      child: PieChart(
                        PieChartData(
                          sections: _investmentDistribution.entries.map((entry) {
                            final color = _getColor(entry.key);
                            return PieChartSectionData(
                              value: entry.value,
                              color: color,
                              title: "${entry.key.split(" ").first}\n${entry.value.toInt()}%",
                              radius: 70,
                              titleStyle: const TextStyle(
                                  fontSize: 12, fontWeight: FontWeight.bold, color: Colors.white),
                            );
                          }).toList(),
                          sectionsSpace: 4,
                          centerSpaceRadius: 30,
                        ),
                      ),
                    ),
                    const SizedBox(height: 10),
                    Wrap(
                      alignment: WrapAlignment.center,
                      spacing: 10,
                      children: _investmentDistribution.keys.map((category) {
                        return Chip(
                          label: Text(category, style: const TextStyle(color: Colors.white)),
                          backgroundColor: _getColor(category),
                        );
                      }).toList(),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Color _getColor(String key) {
    switch (key) {
      case 'Stocks 📈':
        return Colors.green.shade600;
      case 'Mutual Funds 💰':
        return Colors.blue.shade600;
      case 'Savings 🏦':
        return Colors.orange.shade600;
      case 'Gold 🪙':
        return Colors.amber.shade700;
      default:
        return Colors.grey.shade500;
    }
  }
}
