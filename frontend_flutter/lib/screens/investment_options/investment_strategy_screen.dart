import 'package:flutter/material.dart';
import 'package:flutter_markdown/flutter_markdown.dart';
import 'package:flutter_sound/flutter_sound.dart';
import 'package:frontend_flutter/config/translated_text.dart';
import 'package:http/http.dart' as http;
import 'dart:io';
import 'dart:convert';
import 'package:path_provider/path_provider.dart';
import 'package:shared_preferences/shared_preferences.dart';

class InvestmentStrategyScreen extends StatefulWidget {
  final String strategyText;

  const InvestmentStrategyScreen({super.key, required this.strategyText});

  @override
  State<InvestmentStrategyScreen> createState() => _InvestmentStrategyScreenState();
}

class _InvestmentStrategyScreenState extends State<InvestmentStrategyScreen> {
  final FlutterSoundPlayer _player = FlutterSoundPlayer();
  bool _isPlaying = false;
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    _player.openPlayer();
  }

  @override
  void dispose() {
    _player.closePlayer();
    super.dispose();
  }

  Future<String?> _getServerIp() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString('server_ip') ?? 'http://192.168.1.39:5050';
  }

  Future<void> _speak() async {
    setState(() => _isLoading = true);

    final serverIp = await _getServerIp();
    final url = Uri.parse('$serverIp/api/tts/speak');

    try {
      final response = await http.post(
        url,
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({'language': 'en', 'text': widget.strategyText}),
      );

      if (response.statusCode == 200) {
        final tempDir = await getTemporaryDirectory();
        final file = File('${tempDir.path}/strategy_tts.mp3');
        await file.writeAsBytes(response.bodyBytes);

        setState(() => _isPlaying = true);
        setState(() => _isLoading = false);
        await _player.startPlayer(
          fromURI: file.path,
          codec: Codec.mp3,
          whenFinished: () => setState(() => _isPlaying = false),
        );
      } else {
        _showError(TranslatedText('TTS failed').text);
      }
    } catch (e) {
      _showError(TranslatedText('Error: $e').text);
    }
  }

  void _showError(String message) {
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: TranslatedText(message)));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const TranslatedText("Your Investment Strategy")),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            Expanded(
              child: Markdown(
                data: widget.strategyText,
                styleSheet: MarkdownStyleSheet.fromTheme(Theme.of(context)).copyWith(
                  p: const TextStyle(fontSize: 16),
                ),
              ),
            ),
            const SizedBox(height: 20),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                ElevatedButton.icon(
                  onPressed: (_isLoading || _isPlaying) ? null : _speak,
                  icon: const Icon(Icons.volume_up),
                  label: const TranslatedText("Read Aloud"),
                  style: ElevatedButton.styleFrom(
                    padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 14),
                    textStyle: const TextStyle(fontSize: 16),
                  ),
                ),
                const SizedBox(width: 12),
                if (_isLoading) // Only show spinner while loading (not while playing)
                  const SizedBox(
                    height: 20,
                    width: 20,
                    child: CircularProgressIndicator(strokeWidth: 2),
                  ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
