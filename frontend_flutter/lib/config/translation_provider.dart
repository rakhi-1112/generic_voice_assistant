import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import 'manual_translations.dart';

class TranslationProvider extends ChangeNotifier {
  String _languageCode = 'en'; // default to English code
  final Map<String, String> _translations = {};

  String get currentLanguageCode => _languageCode;

  /// Load saved language code from SharedPreferences
  Future<void> loadLanguageFromPrefs() async {
    final prefs = await SharedPreferences.getInstance();
    final saved = prefs.getString('languageCode');
    if (saved != null && (saved == 'en' || saved == 'hi')) {
      _languageCode = saved;
      notifyListeners();
    }
  }

  /// Change language and notify listeners
  Future<void> changeLanguage(String newCode) async {
    if (_languageCode != newCode && (newCode == 'en' || newCode == 'hi')) {
      _languageCode = newCode;
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString('languageCode', newCode);
      notifyListeners();
    }
  }

  /// Translate a given text using fallback map or LibreTranslate
  Future<String> translate(String text) async {
    if (_languageCode == 'en') return text;

    final code = _languageCode;
    if (fallbackMap.containsKey(text)) {
      final manual = fallbackMap[text]![code];
      if (manual != null && manual.trim().isNotEmpty) return manual;
    }

    if (_translations.containsKey(text)) return _translations[text]!;

    final translated = await _fetchFromLibreTranslate(text);
    _translations[text] = translated;
    return translated;
  }

  /// Helper to call REST API for translation
  Future<String> _fetchFromLibreTranslate(String text) async {
    try {
      final response = await http.post(
        Uri.parse('http://localhost:5050/translate'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({
          'q': text,
          'source': 'en',
          'target': _languageCode,
          'format': 'text',
        }),
      );

      if (response.statusCode == 200) {
        final jsonBody = jsonDecode(response.body);
        return jsonBody['translatedText'] ?? text;
      }
    } catch (e) {
      debugPrint('Translation error: $e');
    }
    return text;
  }
}
