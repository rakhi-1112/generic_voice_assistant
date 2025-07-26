import 'package:flutter/material.dart';
import 'package:frontend_flutter/config/translated_text.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:lottie/lottie.dart';
import 'package:glassmorphism/glassmorphism.dart';

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
    child: Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: GlassmorphicContainer(
        width: MediaQuery.of(context).size.width * 0.9,
        height: 380,
        borderRadius: 20,
        blur: 15,
        border: 1,
        linearGradient: LinearGradient(
          colors: [Colors.white.withOpacity(0.2), Colors.blue.withOpacity(0.1)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderGradient: LinearGradient(
          colors: [Colors.white.withOpacity(0.3), Colors.blue.withOpacity(0.2)],
        ),
        child: Center( // 👈 This centers the content vertically AND horizontally inside the container
          child: Padding(
            padding: const EdgeInsets.all(24),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Lottie.asset(animationAsset, width: 160, repeat: false),
                const SizedBox(height: 16),
                TranslatedText(
                  message,
                  style: GoogleFonts.poppins(
                    fontSize: 22,
                    fontWeight: FontWeight.bold,
                    color: Colors.black87,
                  ),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 10),
                TranslatedText(
                  "Your Financial IQ Score: $_score",
                  style: GoogleFonts.poppins(fontSize: 16, color: Colors.black87),
                ),
                const SizedBox(height: 20),
                ElevatedButton.icon(
                  onPressed: _restartGame,
                  icon: const Icon(Icons.restart_alt),
                  label: const TranslatedText("Restart"),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF0A3D91),
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
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
            color: Colors.blue.shade800,
            backgroundColor: Colors.blue.shade100,
          ),
          const SizedBox(height: 20),
          TranslatedText(
            scenario['question'],
            style: GoogleFonts.poppins(fontSize: 20, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 20),
          ...scenario['options'].map<Widget>((option) {
            return Card(
              elevation: 6,
              color: Colors.white,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
              child: ListTile(
                title: TranslatedText(option['text'],
                    style: GoogleFonts.poppins(fontSize: 15, color: Colors.black87)),
                trailing: const Icon(Icons.arrow_forward_ios, color: Color(0xFF0A3D91)),
                onTap: () => _selectOption(option['score']),
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
    final bool gameFinished = _currentScenarioIndex >= _scenarios.length;

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        title: TranslatedText("🎯 Money Quest",
            style: GoogleFonts.poppins(fontWeight: FontWeight.w600, color: Colors.black87)),
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
              height: MediaQuery.of(context).size.height * 0.88,
              borderRadius: 20,
              blur: 20,
              border: 1,
              linearGradient: LinearGradient(
                colors: [Colors.white.withOpacity(0.2), Colors.blue.withOpacity(0.1)],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
              borderGradient: LinearGradient(
                colors: [Colors.white.withOpacity(0.3), Colors.blue.withOpacity(0.2)],
              ),
              child: Padding(
                padding: const EdgeInsets.all(20),
                child: AnimatedSwitcher(
                  duration: const Duration(milliseconds: 100),
                  transitionBuilder: (child, animation) =>
                      FadeTransition(opacity: animation, child: child),
                  child: gameFinished
                      ? _buildResult()
                      : _buildQuestion(),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}