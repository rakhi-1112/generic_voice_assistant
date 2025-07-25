import 'dart:io';
import 'package:flutter/material.dart';
import 'package:frontend_flutter/config/translated_text.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:http/http.dart' as http;
import 'package:path_provider/path_provider.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:record/record.dart';
import 'package:just_audio/just_audio.dart';
import 'package:audioplayers/audioplayers.dart' as audioplayers2;
import 'package:shared_preferences/shared_preferences.dart';

class VoiceChatScreen extends StatefulWidget {
  const VoiceChatScreen({super.key});

  @override
  State<VoiceChatScreen> createState() => _VoiceChatScreenState();
}

class _VoiceChatScreenState extends State<VoiceChatScreen> {
  final AudioRecorder _record = AudioRecorder();
  final audioplayers2.AudioPlayer _player = audioplayers2.AudioPlayer(); // Just Audio player
  bool _isRecording = false;
  bool _isProcessing = false;
  bool _isPlaying = false;
  String? _filePath;
  String? _apiResponsePath;

  @override
  void initState() {
    super.initState();
  }

  Future<void> _startRecording() async {
    try {
      if (_isProcessing || _isPlaying) return;
      
      // Check and request permission
      if (!await _record.hasPermission()) {
        await Permission.microphone.request();
        if (!await _record.hasPermission()) {
          _showError('Microphone permission denied');
          return;
        }
      }

      // Get temporary directory for recording
      final dir = await getTemporaryDirectory();
      final path = '${dir.path}/voice_input.m4a';

      // Start recording
      await _record.start(
        const RecordConfig(encoder: AudioEncoder.aacLc),
        path: path,
      );

      setState(() {
        _isRecording = true;
        _filePath = path;
      });
    } catch (e) {
      _showError('Recording failed: $e');
    }
  }

  Future<void> _stopAndSend() async {
    try {
      // Stop recording
      final path = await _record.stop();
      if (path == null || path.isEmpty) {
        throw Exception('No file path returned');
      }
      
      setState(() {
        _isRecording = false;
        _isProcessing = true;
      });

      // Send to API
      await _sendToApi(path);
    } catch (e) {
      _showError('Failed to process recording: $e');
      setState(() => _isProcessing = false);
    }
  }

  Future<String?> getServerIp() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString('server_ip') ?? 'http://192.168.1.3:5000';
  }

  Future<void> _sendToApi(String audioPath) async {
    try {
      // Create API request
      final ip = await getServerIp();
      final uri = Uri.parse('$ip/api/voicechat/generate_response');
      var request = http.MultipartRequest('POST', uri);
      
      // Add audio file
      request.files.add(
        await http.MultipartFile.fromPath('audio', audioPath),
      );

      // Send request
      final response = await request.send();
      
      if (response.statusCode != 200) {
        throw Exception('API request failed with status ${response.statusCode}');
      }

      // Save response to file
      final bytes = await response.stream.toBytes();
      final downloadsDir = await getApplicationDocumentsDirectory();
      final outputPath = '${downloadsDir.path}/api_response_temp.mp3';
      await File(outputPath).writeAsBytes(bytes);
      
      setState(() => _apiResponsePath = outputPath);
      
      // Play response
      await _playResponse(outputPath);
      
    } catch (e) {
      _showError('API request failed: $e');
    } finally {
      setState(() => _isProcessing = false);
    }
  }

  Future<void> _playResponse(String path) async {
    try {
      final downloadsDir = await getApplicationDocumentsDirectory();
      final outputPath = '${downloadsDir.path}/api_response_temp.mp3';
      await _player.play(audioplayers2.DeviceFileSource(outputPath));
      
      setState(() => _isPlaying = true);
      
    } catch (e) {
      setState(() => _isPlaying = false);
      _showError('Playback failed: $e');
    }
  }

  void _showError(String message) {
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: TranslatedText(message), backgroundColor: Colors.red),
    );
  }

  @override
  void dispose() {
    _record.dispose();
    _player.dispose(); // Dispose Just Audio player
    super.dispose();
  }

  @override
Widget build(BuildContext context) {
  return Scaffold(
    extendBodyBehindAppBar: true,
    backgroundColor: Colors.white,
    appBar: AppBar(
      backgroundColor: Colors.white,
      elevation: 0,
      centerTitle: true,
      title: Text(
        'Voice Chat Assistant',
        style: GoogleFonts.poppins(
          color: const Color(0xFF0A3D91),
          fontSize: 20,
          fontWeight: FontWeight.bold,
        ),
      ),
    ),
    body: Stack(
      children: [
        // Gradient background
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
        // Main content
        Center(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                if (_isProcessing) ...[
                  const CircularProgressIndicator(),
                  const SizedBox(height: 20),
                  TranslatedText(
                    'Processing...',
                    style: GoogleFonts.poppins(fontSize: 18, fontWeight: FontWeight.w500),
                  ),
                ],
                if (!_isProcessing && !_isPlaying) ...[
                  Icon(
                    _isRecording ? Icons.mic : Icons.mic_none,
                    size: 72,
                    color: _isRecording ? Colors.red : const Color(0xFF0A3D91),
                  ),
                  const SizedBox(height: 24),
                  ElevatedButton(
                    onPressed: _isRecording ? _stopAndSend : _startRecording,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: _isRecording ? Colors.red : const Color(0xFF0A3D91),
                      padding: const EdgeInsets.symmetric(horizontal: 40, vertical: 18),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                    ),
                    child: TranslatedText(
                      _isRecording ? 'STOP & SEND' : 'START RECORDING',
                      style: GoogleFonts.poppins(fontSize: 16, color: Colors.white),
                    ),
                  ),
                ],
                if (_isPlaying) ...[
                  const Icon(Icons.volume_up, size: 64, color: Colors.green),
                  const SizedBox(height: 20),
                  TranslatedText(
                    'Playing response...',
                    style: GoogleFonts.poppins(fontSize: 18),
                  ),
                  const SizedBox(height: 30),
                  ElevatedButton(
                    onPressed: () async {
                      await _player.stop();
                      setState(() => _isPlaying = false);
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.red,
                      padding: const EdgeInsets.symmetric(horizontal: 40, vertical: 20),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                    ),
                    child: TranslatedText(
                      'STOP PLAYBACK',
                      style: GoogleFonts.poppins(fontSize: 16, color: Colors.white),
                    ),
                  ),
                ],
                if (_apiResponsePath != null && !_isProcessing && !_isPlaying) ...[
                  const SizedBox(height: 40),
                  TranslatedText(
                    'Response Ready:',
                    style: GoogleFonts.poppins(fontSize: 18, fontWeight: FontWeight.w500),
                  ),
                  const SizedBox(height: 20),
                  ElevatedButton.icon(
                    icon: const Icon(Icons.play_arrow, size: 26),
                    label: TranslatedText(
                      'PLAY RESPONSE',
                      style: GoogleFonts.poppins(fontSize: 16),
                    ),
                    onPressed: () => _playResponse(_apiResponsePath!),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFF1565C0),
                      padding: const EdgeInsets.symmetric(horizontal: 30, vertical: 15),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                    ),
                  ),
                ],
              ],
            ),
          ),
        ),
      ],
    ),
  );
}

}