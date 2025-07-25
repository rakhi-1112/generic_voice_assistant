import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:frontend_flutter/config/translated_text.dart';
import 'package:frontend_flutter/config/translation_provider.dart';
import 'package:frontend_flutter/config/app_routes.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({Key? key}) : super(key: key);

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  final Map<String, String> languageMap = {
    'en': 'English',
    'hi': 'हिंदी',
  };

  @override
  Widget build(BuildContext context) {
    final tp = Provider.of<TranslationProvider>(context);
    String currentLangCode = tp.currentLanguageCode;

    if (!languageMap.containsKey(currentLangCode)) {
      currentLangCode = 'en';
    }

    return Scaffold(
      appBar: AppBar(),
      backgroundColor: Colors.white,
      body: SafeArea(
        child: SingleChildScrollView(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Align(
                  alignment: Alignment.centerRight,
                  child: DropdownButton<String>(
                    value: currentLangCode,
                    icon: const Icon(Icons.language),
                    underline: const SizedBox(),
                    onChanged: (String? newLangCode) {
                      if (newLangCode != null) {
                        tp.changeLanguage(newLangCode);
                      }
                    },
                    items: languageMap.entries.map((entry) {
                      return DropdownMenuItem<String>(
                        value: entry.key,
                        child: Text(entry.value),
                      );
                    }).toList(),
                    selectedItemBuilder: (_) {
                      return languageMap.entries.map((entry) {
                        return Text(entry.value);
                      }).toList();
                    },
                  ),
                ),

                const SizedBox(height: 16),
                Image.asset(
                  'assets/niveshak_intro.jpg',
                  fit: BoxFit.contain,
                  width: double.infinity,
                ),
                const SizedBox(height: 20),

                TranslatedText(
                  'Niveshak',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontSize: 32,
                    fontWeight: FontWeight.bold,
                    color: Colors.indigo[800],
                  ),
                ),

                const SizedBox(height: 12),
                TranslatedText(
                  'Analyse your investment plans in a few mins',
                  textAlign: TextAlign.center,
                  style: TextStyle(fontSize: 18, color: Colors.grey[800]),
                ),

                const SizedBox(height: 40),
                ElevatedButton(
                  onPressed: () {
                    Navigator.pushReplacementNamed(context, '/home');
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.indigo,
                    foregroundColor: Colors.white,
                    minimumSize: const Size(double.infinity, 48),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(30),
                    ),
                  ),
                  child: const TranslatedText('Continue as Guest'),
                ),

                const SizedBox(height: 12),
                OutlinedButton(
                  onPressed: () {
                    Navigator.pushNamed(context, '/login');
                  },
                  style: OutlinedButton.styleFrom(
                    foregroundColor: Colors.indigo,
                    minimumSize: const Size(double.infinity, 48),
                    side: const BorderSide(color: Colors.indigo),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(30),
                    ),
                  ),
                  child: const TranslatedText('Login'),
                ),

                const SizedBox(height: 12),
                TextButton(
                  onPressed: () {
                    Navigator.pushNamed(context, '/register');
                  },
                  child: const TranslatedText(
                    'Register',
                    style: TextStyle(
                      fontSize: 16,
                      color: Colors.indigo,
                      decoration: TextDecoration.underline,
                    ),
                  ),
                ),

                const SizedBox(height: 30),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
