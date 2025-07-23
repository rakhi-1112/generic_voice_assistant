import 'package:flutter/material.dart';
import 'package:frontend_flutter/config/translated_text.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'dart:io';
import 'package:flutter_sound/flutter_sound.dart';
import 'package:record/record.dart';
import 'package:path_provider/path_provider.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:firebase_auth/firebase_auth.dart';

// Import your screens
import 'register_screen.dart';
import 'home_screen.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final _formKey = GlobalKey<FormState>();

  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();

  final AudioRecorder _recorder = AudioRecorder();
  bool _isRecording = false;
  String? _audioPath;

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    _recorder.dispose();
    super.dispose();
  }

  Future<String?> getServerIp() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString('server_ip') ?? 'http://192.168.1.3:5000';
  }

  Future<void> speak(String text) async {
    final serverIp = await getServerIp();
    final response = await http.post(
      Uri.parse('$serverIp/api/tts/speak'),
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode({'language': 'en', 'text': text}),
    );

    if (response.statusCode == 200) {
      final tempDir = await getTemporaryDirectory();
      final file = File('${tempDir.path}/tts_response.mp3');
      await file.writeAsBytes(response.bodyBytes);

      final player = FlutterSoundPlayer();
      await player.openPlayer();
      await player.startPlayer(fromURI: file.path);
    }
  }

  Future<void> startRecording() async {
    if (!await _recorder.hasPermission()) {
      await Permission.microphone.request();
    }

    final dir = await getTemporaryDirectory();
    final path = '${dir.path}/login_voice_input.m4a';

    await _recorder.start(
      const RecordConfig(encoder: AudioEncoder.aacLc),
      path: path,
    );

    setState(() {
      _isRecording = true;
      _audioPath = path;
    });
  }

  Future<String?> stopRecordingAndTranscribe() async {
    final path = await _recorder.stop();
    setState(() => _isRecording = false);

    if (path != null) _audioPath = path;
    if (_audioPath == null) return null;

    final serverIp = await getServerIp();
    final uri = Uri.parse('$serverIp/api/stt/transcribe');
    final request = http.MultipartRequest('POST', uri)
      ..fields['is_numeric'] = 'false'
      ..files.add(await http.MultipartFile.fromPath('audio', _audioPath!));

    final response = await request.send();
    final responseBody = await response.stream.bytesToString();
    final result = jsonDecode(responseBody);

    return result["transcript"];
  }

  Widget buildFieldWithSpeech({
    required String label,
    required TextEditingController controller,
    required String? Function(String?) validator,
    required IconData icon,
    bool isPassword = false,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.only(bottom: 6.0),
          child: TranslatedText(label, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
        ),
        Row(
          children: [
            Expanded(
              child: TextFormField(
                controller: controller,
                obscureText: isPassword,
                validator: validator,
                decoration: InputDecoration(
                  isDense: true,
                  contentPadding: const EdgeInsets.symmetric(vertical: 12, horizontal: 12),
                  prefixIcon: Icon(icon, color: Colors.black),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(8),
                    borderSide: const BorderSide(color: Colors.black),
                  ),
                  enabledBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(8),
                    borderSide: const BorderSide(color: Colors.black),
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(8),
                    borderSide: const BorderSide(color: Colors.black, width: 2),
                  ),
                  fillColor: Colors.transparent,
                  filled: true,
                ),
                style: const TextStyle(color: Colors.black),
              ),
            ),
            IconButton(icon: const Icon(Icons.volume_up, color: Colors.black), onPressed: () => speak(label)),
            IconButton(
              icon: Icon(_isRecording ? Icons.mic_off : Icons.mic, color: Colors.black),
              onPressed: () async {
                if (!_isRecording) {
                  await startRecording();
                } else {
                  final transcript = await stopRecordingAndTranscribe();
                  if (transcript != null) controller.text = transcript;
                }
              },
            ),
          ],
        ),
        const SizedBox(height: 16),
      ],
    );
  }

  void _submit() async {
  if (_formKey.currentState?.validate() ?? false) {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text("Logging in...")),
    );

    try {
      UserCredential userCredential = await FirebaseAuth.instance.signInWithEmailAndPassword(
        email: _emailController.text.trim(),
        password: _passwordController.text,
      );

      User? user = userCredential.user;

      // if (user != null && !user.emailVerified) {
      //   // User not verified
      //   ScaffoldMessenger.of(context).showSnackBar(
      //     SnackBar(
      //       content: const Text("Email not verified. Please check your inbox."),
      //       action: SnackBarAction(
      //         label: "Resend",
      //         onPressed: () async {
      //           await user.sendEmailVerification();
      //           ScaffoldMessenger.of(context).showSnackBar(
      //             const SnackBar(content: Text("Verification email sent.")),
      //           );
      //         },
      //       ),
      //     ),
      //   );

      //   // Optional: Sign out user to prevent unverified access
      //   await FirebaseAuth.instance.signOut();
      //   return;
      // }

      // Email verified, proceed to HomeScreen
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Login successful!")),
      );

      Future.delayed(const Duration(seconds: 1), () {
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (context) => const HomeScreen()),
        );
      });
    } on FirebaseAuthException catch (e) {
      String message = "Login failed.";
      if (e.code == 'user-not-found') {
        message = "No user found for this email.";
      } else if (e.code == 'wrong-password') {
        message = "Incorrect password.";
      } else if (e.code == 'invalid-email') {
        message = "Invalid email address.";
      }

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(message)),
      );
    }
  }
}


  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const TranslatedText("Login")),
      body: Padding(
        padding: const EdgeInsets.all(20),
        child: Form(
          key: _formKey,
          child: ListView(
            children: [
              buildFieldWithSpeech(
                label: "Email",
                controller: _emailController,
                icon: Icons.email,
                validator: (v) {
                  if (v == null || v.trim().isEmpty) return "Please enter email";
                  final emailRegex = RegExp(r"^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$");
                  if (!emailRegex.hasMatch(v)) return "Enter a valid email";
                  return null;
                },
              ),
              buildFieldWithSpeech(
                label: "Password",
                controller: _passwordController,
                icon: Icons.lock,
                isPassword: true,
                validator: (v) => (v == null || v.isEmpty) ? "Please enter password" : null,
              ),
              const SizedBox(height: 24),
              ElevatedButton(
                onPressed: _submit,
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.indigo,
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
                ),
                child: const TranslatedText(
                  "Login",
                  style: TextStyle(color: Colors.white, fontSize: 16),
                ),
              ),
              const SizedBox(height: 16),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const TranslatedText("Don't have an account?", style: TextStyle(color: Colors.black)),
                  TextButton(
                    onPressed: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(builder: (_) => const RegisterScreen()),
                      );
                    },
                    child: const TranslatedText("Register here", style: TextStyle(color: Colors.indigo)),
                  ),
                ],
              )
            ],
          ),
        ),
      ),
    );
  }
}
