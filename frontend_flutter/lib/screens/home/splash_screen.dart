import 'package:flutter/material.dart';
import 'package:frontend_flutter/screens/home/home_screen.dart';
import 'package:shared_preferences/shared_preferences.dart';

class SplashScreen extends StatefulWidget {
  @override
  _SplashScreenState createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  String _selectedLanguage = 'English';
  final List<String> _languages = ['English', 'हिंदी'];

  @override
  void initState() {
    super.initState();
    _loadSavedLanguage();
  }

  void _loadSavedLanguage() async {
    final prefs = await SharedPreferences.getInstance();
    final savedLang = prefs.getString('language');
    if (savedLang != null && _languages.contains(savedLang)) {
      setState(() {
        _selectedLanguage = savedLang;
      });
    }
  }

  void _saveLanguage(String lang) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('language', lang);
  }

  @override
Widget build(BuildContext context) {
  return Scaffold(
    backgroundColor: Colors.white,
    body: SafeArea(
      child: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // 🌐 Language dropdown aligned to right
              Align(
                alignment: Alignment.centerRight,
                child: DropdownButton<String>(
                  value: _selectedLanguage,
                  icon: Icon(Icons.language),
                  underline: SizedBox(),
                  onChanged: (String? newLang) {
                    if (newLang != null) {
                      setState(() {
                        _selectedLanguage = newLang;
                        _saveLanguage(newLang);
                      });
                    }
                  },
                  items: _languages.map((lang) {
                    return DropdownMenuItem<String>(
                      value: lang,
                      child: Text(lang),
                    );
                  }).toList(),
                ),
              ),

              SizedBox(height: 16),

              // 🖼 Image
              Image.asset(
                '../assets/niveshak_intro.jpg',
                fit: BoxFit.contain,
                width: double.infinity,
              ),

              SizedBox(height: 20),         

              Text(
                'Niveshak',
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 32,
                  fontWeight: FontWeight.bold,
                  color: Colors.indigo[800],
                ),
              ),

              SizedBox(height: 12),

              Text(
                'Analyse your investment plans in a few mins',
                textAlign: TextAlign.center,
                style: TextStyle(fontSize: 18, color: Colors.grey[800]),
              ),

              SizedBox(height: 40),

              ElevatedButton(
                onPressed: () {
                  Navigator.of(context).pushReplacementNamed('/home');
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.indigo,
                  foregroundColor: Colors.white,
                  minimumSize: Size(double.infinity, 48),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(30),
                  ),
                ),
                child: Text('Continue as Guest'),
              ),

              SizedBox(height: 12),

              OutlinedButton(
                onPressed: () {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(content: Text('Login tapped')),
                  );
                },
                style: OutlinedButton.styleFrom(
                  foregroundColor: Colors.indigo,
                  minimumSize: Size(double.infinity, 48),
                  side: BorderSide(color: Colors.indigo),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(30),
                  ),
                ),
                child: Text('Login'),
              ),

              SizedBox(height: 12),

              TextButton(
                onPressed: () {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(content: Text('Register tapped')),
                  );
                },
                child: Text(
                  'Register',
                  style: TextStyle(
                    fontSize: 16,
                    color: Colors.indigo,
                    decoration: TextDecoration.underline,
                  ),
                ),
              ),

              SizedBox(height: 30),
            ],
          ),
        ),
      ),
    ),
  );
  } 
}
