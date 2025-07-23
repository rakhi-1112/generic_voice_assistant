import 'package:flutter/material.dart';
import 'package:lottie/lottie.dart';

class MoneyQuestGameScreen extends StatefulWidget {
  const MoneyQuestGameScreen({super.key});

  @override
  State<MoneyQuestGameScreen> createState() => _MoneyQuestGameScreenState();
}

class _MoneyQuestGameScreenState extends State<MoneyQuestGameScreen>
    with TickerProviderStateMixin {
  int _score = 0;
  int _currentScenarioIndex = 0;

  final List<Map<String, dynamic>> _scenarios = [
    {
      'question': 'You got ₹1,000 as a gift 🎁. What will you do?',
      'options': [
        {'text': 'Buy snacks and mobile accessories 🍟📱', 'score': -10},
        {'text': 'Put half into savings, half for fun 💡🎉', 'score': 15},
        {'text': 'Invest in a micro-SIP or digital gold 📈', 'score': 20},
        {'text': 'Give it to a friend who asked for money 🤝', 'score': -5},
        {'text': 'Deposit in a recurring deposit scheme 🏦', 'score': 10},
      ],
    },
    {
      'question': 'You want to start investing 📊. What should you consider?',
      'options': [
        {'text': 'Check your risk appetite and goal 🎯', 'score': 15},
        {'text': 'Invest where your friend invests 🤷‍♀', 'score': -10},
        {'text': 'Diversify across mutual funds and stocks 🌐', 'score': 20},
        {'text': 'Look at past 1-month returns only 📉', 'score': -5},
        {'text': 'Understand fees, lock-in periods, and tax rules 📑', 'score': 15},
      ],
    },
    {
      'question': 'A new gadget is on sale for 40% off ⚡. What’s your move?',
      'options': [
        {'text': 'Buy now before the sale ends 🛒', 'score': -5},
        {'text': 'Check if you really need it 📋', 'score': 15},
      ],
    },
    {
      'question': 'You want to save tax this year 📑. Choose your tools:',
      'options': [
        {'text': 'Public Provident Fund (PPF) 🏦', 'score': 15},
        {'text': 'Equity Linked Savings Scheme (ELSS) 📘', 'score': 20},
        {'text': 'Fixed Deposit for 6 months 🕒', 'score': 5},
      ],
    },
    {
      'question': 'You get ₹5,000 from a freelance gig 💼. Best use?',
      'options': [
        {'text': 'Invest a portion and keep some liquid 💹💧', 'score': 20},
        {'text': 'Order food and upgrade your headphones 🍔🎧', 'score': -10},
      ],
    },
  ];

  late final AnimationController _controller;
  late final Animation<double> _fadeAnimation;

  @override
  void initState() {
    super.initState();
    _controller =
        AnimationController(vsync: this, duration: const Duration(milliseconds: 300));
    _fadeAnimation = CurvedAnimation(parent: _controller, curve: Curves.easeInOut);
    _controller.forward();
  }

  void _selectOption(int score) {
    _controller.reverse().then((_) {
      setState(() {
        _score += score;
        _currentScenarioIndex++;
        _controller.forward();
      });
    });
  }

  void _restartGame() {
    setState(() {
      _score = 0;
      _currentScenarioIndex = 0;
    });
    _controller.forward(from: 0);
  }

  Widget _buildResult() {
    String message;
    String animationAsset;

    if (_score > 20) {
      message = "You're a Financial Pro! 🏆";
      animationAsset = 'assets/animations/trophy.json';
    } else if (_score >= 0) {
      message = "You're getting there! 💡";
      animationAsset = 'assets/animations/average.json';
    } else {
      message = "Oops! Try again next time 💥";
      animationAsset = 'assets/animations/lose.json';
    }

    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Lottie.asset(animationAsset, width: 200, repeat: false),
          const SizedBox(height: 20),
          Text(
            message,
            style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 10),
          Text("Your Financial IQ Score: $_score",
              style: const TextStyle(fontSize: 18)),
          const SizedBox(height: 20),
          ElevatedButton.icon(
            onPressed: _restartGame,
            icon: const Icon(Icons.restart_alt, color: Colors.white),
            label: const Text("Restart"),
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.deepPurple,
              foregroundColor: Colors.white, // sets text and icon color
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildQuestion() {
    final scenario = _scenarios[_currentScenarioIndex];

    return FadeTransition(
      opacity: _fadeAnimation,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          LinearProgressIndicator(
            value: (_currentScenarioIndex + 1) / _scenarios.length,
            color: Colors.green,
            backgroundColor: Colors.grey[300],
          ),
          const SizedBox(height: 20),
          Text(
            scenario['question'],
            style: const TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 20),
          ...scenario['options'].map<Widget>((option) {
            return AnimatedScale(
              scale: 1.0,
              duration: const Duration(milliseconds: 300),
              child: Card(
                elevation: 4,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                child: ListTile(
                  title: Text(option['text'], style: const TextStyle(fontSize: 16)),
                  onTap: () => _selectOption(option['score']),
                  trailing: const Icon(Icons.arrow_forward_ios, color: Colors.deepPurple),
                ),
              ),
            );
          }).toList(),
        ],
      ),
    );
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    bool gameFinished = _currentScenarioIndex >= _scenarios.length;

    return Scaffold(
      appBar: AppBar(
        title: const Text("🎯 Money Quest"),
        backgroundColor: Colors.deepPurple,
      ),
      body: AnimatedSwitcher(
        duration: const Duration(milliseconds: 100),
        transitionBuilder: (child, animation) =>
            FadeTransition(opacity: animation, child: child),
        child: Padding(
          key: ValueKey(_currentScenarioIndex),
          padding: const EdgeInsets.all(16.0),
          child: gameFinished ? _buildResult() : _buildQuestion(),
        ),
      ),
    );
  }
}