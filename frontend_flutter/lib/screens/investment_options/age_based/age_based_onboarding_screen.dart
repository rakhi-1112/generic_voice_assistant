import 'dart:math';
import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:frontend_flutter/screens/investment_options/age_based/utils/age_group_engine.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:frontend_flutter/config/translated_text.dart';

class AgeBasedOnboardingScreen extends StatefulWidget {
  final Function(Map<String, dynamic>) onComplete;

  const AgeBasedOnboardingScreen({super.key, required this.onComplete});

  @override
  State<AgeBasedOnboardingScreen> createState() => _AgeBasedOnboardingScreenState();
}

class _AgeBasedOnboardingScreenState extends State<AgeBasedOnboardingScreen> with SingleTickerProviderStateMixin {
  int currentStep = 0;
  AgeGroup? ageGroup;
  Map<String, dynamic> onboardingData = {};
  late AnimationController _blobController;

  @override
  void initState() {
    super.initState();
    _blobController = AnimationController(vsync: this, duration: const Duration(seconds: 10))..repeat();
  }

  @override
  void dispose() {
    _blobController.dispose();
    super.dispose();
  }

  void handleAgeSelect(int age) {
    ageGroup = assignAgeGroup(age) as AgeGroup?;
    onboardingData['age'] = age;
    onboardingData['ageGroup'] = ageGroup;
    setState(() => currentStep++);
  }

  void updateData(String key, dynamic value) {
    onboardingData[key] = value;
    setState(() {});
  }

  void nextStep() {
    if (currentStep < 2) {
      setState(() => currentStep++);
    } else {
      widget.onComplete(onboardingData);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        title: TranslatedText(
          'onboarding.title',
          style: GoogleFonts.poppins(
            fontSize: 20,
            fontWeight: FontWeight.bold,
          ),
        ),
        centerTitle: true,
      ),
      body: Stack(
        children: [
          _buildAnimatedBlobBackground(),
          Center(
            child: AnimatedSwitcher(
              duration: const Duration(milliseconds: 600),
              transitionBuilder: (child, animation) => SlideTransition(
                position: Tween<Offset>(begin: const Offset(1, 0), end: Offset.zero).animate(animation),
                child: FadeTransition(opacity: animation, child: child),
              ),
              child: _buildStepContent(key: ValueKey(currentStep)),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildAnimatedBlobBackground() {
    return AnimatedBuilder(
      animation: _blobController,
      builder: (context, child) {
        return Stack(
          children: [
            _animatedBlob(Colors.purple.shade100, 80, 0),
            _animatedBlob(Colors.yellow.shade100, 200, 2),
            _animatedBlob(Colors.pink.shade100, 350, 4),
          ],
        );
      },
    );
  }

  Widget _animatedBlob(Color color, double offset, int delaySeconds) {
    final angle = _blobController.value * 2 * pi + delaySeconds;
    return Positioned(
      top: 200 + 50 * sin(angle),
      left: offset + 30 * cos(angle),
      child: Container(
        width: 200,
        height: 200,
        decoration: BoxDecoration(
          color: color.withOpacity(0.2),
          shape: BoxShape.circle,
        ),
      ),
    );
  }

  Widget _buildStepContent({required Key key}) {
    switch (currentStep) {
      case 0:
        return Column(
          key: key,
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const TranslatedText("onboarding.emoji", style: TextStyle(fontSize: 80))
                .animate()
                .fade(duration: 600.ms)
                .scale(duration: 800.ms)
                .then()
                .shake(hz: 1, curve: Curves.easeOut),
            const SizedBox(height: 20),
            const TranslatedText("onboarding.app_name", style: TextStyle(fontSize: 36, fontWeight: FontWeight.bold))
                .animate()
                .fadeIn(duration: 600.ms, delay: 400.ms),
            const Padding(
              padding: EdgeInsets.symmetric(vertical: 12, horizontal: 30),
              child: TranslatedText("onboarding.tagline", textAlign: TextAlign.center),
            ).animate().fadeIn(delay: 600.ms),
            const SizedBox(height: 30),
            Wrap(
              spacing: 16,
              runSpacing: 16,
              alignment: WrapAlignment.center,
              children: [
                _ageCard('onboarding.genz', '🎓', '18-27', 22),
                _ageCard('onboarding.millennial', '💼', '28-43', 35),
                _ageCard('onboarding.elderly', '🏡', '44+', 50),
              ].animate(interval: 300.ms),
            ),
          ],
        );
      case 1:
        return _buildFinancialSituationStep().animate().fadeIn().slideY(begin: 0.2);
      case 2:
        return _buildPrimaryGoalStep().animate().fadeIn().slideY(begin: 0.2);
      default:
        return const SizedBox();
    }
  }

  Widget _ageCard(String labelKey, String emoji, String range, int age) {
    return GestureDetector(
      onTap: () => handleAgeSelect(age),
      child: Container(
        width: 200,
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(24),
          gradient: const LinearGradient(colors: [Colors.purple, Colors.orange]),
          boxShadow: [
            BoxShadow(
              color: Colors.deepPurple.withOpacity(0.3),
              blurRadius: 10,
              offset: const Offset(0, 6),
            )
          ],
        ),
        child: Column(
          children: [
            Text(emoji, style: const TextStyle(fontSize: 40))
                .animate()
                .scaleXY(begin: 1, end: 1.2)
                .then(delay: 200.ms)
                .shake(hz: 2),
            const SizedBox(height: 10),
            TranslatedText(labelKey, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 20)),
            Text(range),
          ],
        ),
      ),
    );
  }

  Widget _buildFinancialSituationStep() {
    final profile = getAgeGroupProfile(ageGroup!);

    final options = [
      {
        'value': 'surplus',
        'emoji': '😊',
        'labelKey': 'onboarding.financial.surplus.${ageGroup!.name}',
      },
      {
        'value': 'breaking_even',
        'emoji': '😐',
        'labelKey': 'onboarding.financial.breaking_even.${ageGroup!.name}',
      },
      {
        'value': 'deficit',
        'emoji': '😓',
        'labelKey': 'onboarding.financial.deficit.${ageGroup!.name}',
      },
    ];

    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        TranslatedText(profile.displayName, style: const TextStyle(fontSize: 26, fontWeight: FontWeight.bold)),
        const SizedBox(height: 12),
        const TranslatedText("onboarding.question.financial_status"),
        const SizedBox(height: 24),
        ...options.map((opt) => GestureDetector(
              onTap: () => updateData('financialSituation', opt['value']),
              child: Container(
                margin: const EdgeInsets.symmetric(vertical: 8, horizontal: 30),
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(16),
                  color: onboardingData['financialSituation'] == opt['value']
                      ? Colors.greenAccent
                      : Colors.white,
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.start,
                  children: [
                    Text(opt['emoji']!, style: const TextStyle(fontSize: 32)),
                    const SizedBox(width: 16),
                    Expanded(
                      child: TranslatedText(opt['labelKey']!, style: const TextStyle(fontSize: 16)),
                    ),
                  ],
                ),
              ),
            )),
        if (onboardingData['financialSituation'] != null)
          Padding(
            padding: const EdgeInsets.only(top: 20.0),
            child: ElevatedButton(
              onPressed: nextStep,
              child: const TranslatedText("onboarding.button.continue"),
            ).animate().scale().fadeIn(),
          ),
      ],
    );
  }

  Widget _buildPrimaryGoalStep() {
    final profile = getAgeGroupProfile(ageGroup!);

    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        const TranslatedText("onboarding.question.primary_goal", style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold)),
        const SizedBox(height: 20),
        ...profile.commonGoals.map((goal) {
          final emoji = {
            'debt': '💳',
            'emergency_fund': '🚨',
            'house': '🏡',
            'retirement': '👴',
            'travel': '✈️',
            'education': '📚',
            'business': '🚀',
          }[goal]!;

          final labelKey = 'onboarding.goal.${goal}.${ageGroup!.name}';

          return GestureDetector(
            onTap: () => updateData('primaryGoal', goal),
            child: Container(
              margin: const EdgeInsets.symmetric(vertical: 8, horizontal: 30),
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(16),
                color: onboardingData['primaryGoal'] == goal ? Colors.indigoAccent : Colors.white,
              ),
              child: Row(
                children: [
                  Text(emoji, style: const TextStyle(fontSize: 32)),
                  const SizedBox(width: 16),
                  Expanded(child: TranslatedText(labelKey, style: const TextStyle(fontSize: 16))),
                ],
              ),
            ),
          ).animate().fadeIn();
        }).toList(),
        if (onboardingData['primaryGoal'] != null)
          Padding(
            padding: const EdgeInsets.only(top: 20.0),
            child: ElevatedButton(
              onPressed: nextStep,
              child: const TranslatedText("onboarding.button.create_plan"),
            ).animate().scale().fadeIn(),
          ),
      ],
    );
  }
}
