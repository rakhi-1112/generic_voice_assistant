import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';

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
      appBar: AppBar(
        title: const Text("📊 Investment Tracker"),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            Row(
              children: [
                const Icon(Icons.filter_alt, color: Colors.deepPurple),
                const SizedBox(width: 10),
                const Text("Select Range:"),
                const SizedBox(width: 10),
                DropdownButton<String>(
                  value: _selectedRange,
                  items: ['Weekly', 'Monthly', 'All Time'].map((range) {
                    return DropdownMenuItem(value: range, child: Text(range));
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
              style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 10),
            SizedBox(
              height: 240,
              child: BarChart(
                BarChartData(
                  barGroups: _currentBarData,
                  borderData: FlBorderData(show: false),
                  titlesData: FlTitlesData(
                    leftTitles: AxisTitles(
                      sideTitles: SideTitles(
                        showTitles: true,
                        reservedSize: 42,
                        getTitlesWidget: (value, meta) =>
                            Text('₹${value.toInt()}', style: const TextStyle(fontSize: 10)),
                      ),
                    ),
                    bottomTitles: AxisTitles(
                      sideTitles: SideTitles(
                        showTitles: true,
                        getTitlesWidget: (value, meta) {
                          return Text("Q${value.toInt() + 1}", style: const TextStyle(fontSize: 12));
                        },
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
            const Text(
              "🏦 Investment Areas",
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
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
    );
  }

  Color _getColor(String key) {
    switch (key) {
      case 'Stocks 📈':
        return Colors.green;
      case 'Mutual Funds 💰':
        return Colors.blue;
      case 'Savings 🏦':
        return Colors.orange;
      case 'Gold 🪙':
        return Colors.amber;
      default:
        return Colors.grey;
    }
  }
}
