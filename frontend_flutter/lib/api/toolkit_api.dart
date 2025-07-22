
// lib/api/toolkit_api.dart

import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';

class ToolkitAPI {
  static Future<String> _getBaseUrl() async {
    final prefs = await SharedPreferences.getInstance();
    final ip = prefs.getString('server_ip') ?? '10.0.2.2';
    return ip;  // You can adjust port if needed
  }

  static Future<Map<String, dynamic>> getBudgetSuggestions(Map<String, dynamic> input) async {
    final baseUrl = await _getBaseUrl();
    final res = await http.post(Uri.parse('$baseUrl/api/ai_ml/predict_budget'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode(input));
    return jsonDecode(res.body);
  }

  static Future<Map<String, dynamic>> getFundingMatches(Map<String, dynamic> input) async {
    final baseUrl = await _getBaseUrl();
    final res = await http.post(Uri.parse('$baseUrl/api/ai_ml/match_funding'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode(input));
    return jsonDecode(res.body);
  }

  static Future<Map<String, dynamic>> getForecast(Map<String, dynamic> input) async {
    final baseUrl = await _getBaseUrl();
    final uri = Uri.parse('$baseUrl/api/ai_ml/forecast_growth');
    final response = await http.post(
      uri,
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode({'history': input['history']}),
    );

    // decode into a Map so you can check for "error" or "forecast"
    return jsonDecode(response.body) as Map<String, dynamic>;
  }

 
}
