import 'package:flutter/material.dart';

class MoneyQuestGameScreen extends StatefulWidget {
  const MoneyQuestGameScreen({super.key});

  @override
  State<MoneyQuestGameScreen> createState() => _MoneyQuestGameScreenState();
}

class _MoneyQuestGameScreenState extends State<MoneyQuestGameScreen> {
  int _score = 0;
  int _currentScenarioIndex = 0;

  final List<Map<String, dynamic>> _scenarios = [
    {
      'question': 'You got your monthly allowance 💸. What will you do?',
      'options': [
        {'text': 'Buy expensive sneakers 👟', 'score': -10},
        {'text': 'Invest in mutual funds 📈', 'score': 20},
      ],
    },
    {
      'question': 'You saw a trending gadget 📱 on sale.',
      'options': [
        {'text': 'Buy it impulsively 🛍️', 'score': -5},
        {'text': 'Compare and wait for a better deal ⏳', 'score': 15},
      ],
    },
    {
      'question': 'You earned extra cash 💼 from freelancing.',
      'options': [
        {'text': 'Spend it all at once 🍕🕹️', 'score': -10},
        {'text': 'Split into savings and fun 🎯', 'score': 20},
      ],
    },
  ];

  void _selectOption(int score) {
    setState(() {
      _score += score;
      _currentScenarioIndex++;
    });
  }

  void _restartGame() {
    setState(() {
      _score = 0;
      _currentScenarioIndex = 0;
    });
  }

  @override
  Widget build(BuildContext context) {
    bool gameFinished = _currentScenarioIndex >= _scenarios.length;

    return Scaffold(
      appBar: AppBar(
        title: const Text("🎯 Money Quest"),
        backgroundColor: Colors.deepPurple,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: gameFinished
            ? Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text("Your Financial IQ Score: $_score",
                        style: const TextStyle(
                            fontSize: 24, fontWeight: FontWeight.bold)),
                    const SizedBox(height: 20),
                    ElevatedButton(
                      onPressed: _restartGame,
                      child: const Text("🔁 Restart"),
                    ),
                  ],
                ),
              )
            : Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  LinearProgressIndicator(
                    value: (_currentScenarioIndex + 1) / _scenarios.length,
                    color: Colors.green,
                  ),
                  const SizedBox(height: 20),
                  Text(
                    _scenarios[_currentScenarioIndex]['question'],
                    style: const TextStyle(
                        fontSize: 20, fontWeight: FontWeight.w600),
                  ),
                  const SizedBox(height: 20),
                  ..._scenarios[_currentScenarioIndex]['options']
                      .map<Widget>((option) {
                    return Card(
                      margin: const EdgeInsets.symmetric(vertical: 8),
                      child: ListTile(
                        title: Text(option['text']),
                        onTap: () => _selectOption(option['score']),
                        trailing: const Icon(Icons.arrow_forward_ios),
                      ),
                    );
                  }).toList(),
                ],
              ),
      ),
    );
  }
}
