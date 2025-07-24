import 'dart:io';
import 'package:flutter/material.dart';
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
    return prefs.getString('server_ip') ?? 'http://192.168.1.39:5050';
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
      SnackBar(content: Text(message), backgroundColor: Colors.red),
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
      appBar: AppBar(title: const Text('Voice Chat Assistant')),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            // Status indicators
            if (_isProcessing) ...[
              const CircularProgressIndicator(),
              const SizedBox(height: 20),
              const Text('Processing...', style: TextStyle(fontSize: 18)),
              const SizedBox(height: 40),
            ],
            
            // Main recording UI
            if (!_isProcessing && !_isPlaying) ...[
              Icon(
                _isRecording ? Icons.mic : Icons.mic_none,
                size: 64,
                color: _isRecording ? Colors.red : Colors.blue,
              ),
              const SizedBox(height: 30),
              ElevatedButton(
                onPressed: _isRecording ? _stopAndSend : _startRecording,
                style: ElevatedButton.styleFrom(
                  padding: const EdgeInsets.symmetric(horizontal: 40, vertical: 20),
                  backgroundColor: _isRecording ? Colors.red : Colors.blue,
                ),
                child: Text(
                  _isRecording ? 'STOP & SEND' : 'START RECORDING',
                  style: const TextStyle(fontSize: 18, color: Colors.white),
                ),
              ),
            ],
            
            // Playback UI
            if (_isPlaying) ...[
              const Icon(Icons.volume_up, size: 64, color: Colors.green),
              const SizedBox(height: 20),
              const Text('Playing response...', style: TextStyle(fontSize: 18)),
              const SizedBox(height: 30),
              ElevatedButton(
                onPressed: () async {
                  await _player.stop();
                  setState(() => _isPlaying = false);
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.red,
                  padding: const EdgeInsets.symmetric(horizontal: 40, vertical: 20),
                ),
                child: const Text(
                  'STOP PLAYBACK',
                  style: TextStyle(fontSize: 18, color: Colors.white),
                ),
              ),
            ],
            
            // Response playback control
            if (_apiResponsePath != null && !_isProcessing && !_isPlaying) ...[
              const SizedBox(height: 40),
              const Text('Response Ready:', style: TextStyle(fontSize: 18)),
              const SizedBox(height: 20),
              ElevatedButton.icon(
                icon: const Icon(Icons.play_arrow, size: 30),
                label: const Text('PLAY RESPONSE', style: TextStyle(fontSize: 18)),
                onPressed: () => _playResponse(_apiResponsePath!),
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color.fromARGB(255, 76, 155, 175),
                  padding: const EdgeInsets.symmetric(horizontal: 30, vertical: 15),
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }
}