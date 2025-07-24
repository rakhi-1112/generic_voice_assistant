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

// Replace with your actual LoginScreen import
import 'login_screen.dart';

class RegisterScreen extends StatefulWidget {
  const RegisterScreen({super.key});

  @override
  State<RegisterScreen> createState() => _RegisterScreenState();
}

class _RegisterScreenState extends State<RegisterScreen> {
  final _formKey = GlobalKey<FormState>();

  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _ageController = TextEditingController();
  final TextEditingController _phoneController = TextEditingController();
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  final TextEditingController _confirmPasswordController = TextEditingController();

  final AudioRecorder _recorder = AudioRecorder();
  bool _isRecording = false;
  String? _audioPath;

  String? _selectedGender;

  @override
  void dispose() {
    _nameController.dispose();
    _ageController.dispose();
    _phoneController.dispose();
    _emailController.dispose();
    _passwordController.dispose();
    _confirmPasswordController.dispose();
    _recorder.dispose();
    super.dispose();
  }

  Future<String?> getServerIp() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString('server_ip') ?? 'http://192.168.1.39:5050';
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
    final path = '${dir.path}/register_voice_input.m4a';

    await _recorder.start(
      const RecordConfig(encoder: AudioEncoder.aacLc),
      path: path,
    );

    setState(() {
      _isRecording = true;
      _audioPath = path;
    });
  }

  Future<String?> stopRecordingAndTranscribe({required bool isNumeric}) async {
    final path = await _recorder.stop();
    setState(() => _isRecording = false);

    if (path != null) _audioPath = path;
    if (_audioPath == null) return null;

    final serverIp = await getServerIp();
    final uri = Uri.parse('$serverIp/api/stt/transcribe');
    final request = http.MultipartRequest('POST', uri)
      ..fields['is_numeric'] = isNumeric.toString()
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
    bool isNumeric = false,
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
                keyboardType: isNumeric ? TextInputType.number : TextInputType.text,
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
                  final transcript = await stopRecordingAndTranscribe(isNumeric: isNumeric);
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

  Widget buildGenderDropdown() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const TranslatedText("Gender", style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
        const SizedBox(height: 6),
        Row(
          children: [
            SizedBox(
              width: 250, // Adjust width to match other fields visually
              height: 48,
              child: DropdownButtonFormField<String>(
                value: _selectedGender,
                decoration: InputDecoration(
                  contentPadding: const EdgeInsets.symmetric(vertical: 12, horizontal: 12),
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
                  prefixIcon: const Icon(Icons.transgender, color: Colors.black),
                  filled: true,
                  fillColor: Colors.transparent,
                  isDense: true,
                ),
                isExpanded: true,
                items: const [
                  DropdownMenuItem(value: "Male", child: TranslatedText("Male")),
                  DropdownMenuItem(value: "Female", child: TranslatedText("Female")),
                  DropdownMenuItem(value: "Other", child: TranslatedText("Other")),
                ],
                onChanged: (value) {
                  setState(() {
                    _selectedGender = value;
                  });
                },
                validator: (value) => value == null ? "Please select gender" : null,
              ),
            ),
          ],
        ),
        const SizedBox(height: 16),
      ],
    );
  }

  void _submit() async {
    if (_formKey.currentState?.validate() ?? false) {
      if (_passwordController.text != _confirmPasswordController.text) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: TranslatedText("Passwords do not match")),
        );
        return;
      }

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: TranslatedText("Registering...")),
      );

      try {
        final UserCredential userCredential = await FirebaseAuth.instance
            .createUserWithEmailAndPassword(
          email: _emailController.text.trim(),
          password: _passwordController.text,
        );

        await userCredential.user?.updateDisplayName(_nameController.text.trim());

        // Send email verification correctly
        await userCredential.user?.sendEmailVerification();

        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: TranslatedText("Registration successful! Please verify your email before logging in."),
          ),
        );

        // Navigate to login after 2 seconds
        Future.delayed(const Duration(seconds: 2), () {
          Navigator.pushReplacement(
            context,
            MaterialPageRoute(builder: (context) => const LoginScreen()),
          );
        });
      } on FirebaseAuthException catch (e) {
        String errorMessage;
        switch (e.code) {
          case 'email-already-in-use':
            errorMessage = 'This email is already in use.';
            break;
          case 'invalid-email':
            errorMessage = 'Invalid email address.';
            break;
          case 'weak-password':
            errorMessage = 'Password is too weak.';
            break;
          default:
            errorMessage = 'Registration failed. Please try again.';
        }

        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(errorMessage)),
        );
      } catch (e) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('An unexpected error occurred.')),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const TranslatedText("Register")),
      body: Padding(
        padding: const EdgeInsets.all(20),
        child: Form(
          key: _formKey,
          child: ListView(
            children: [
              buildFieldWithSpeech(
                label: "Name",
                controller: _nameController,
                icon: Icons.person,
                validator: (v) => (v == null || v.trim().isEmpty) ? "Please enter name" : null,
              ),
              buildFieldWithSpeech(
                label: "Age",
                controller: _ageController,
                icon: Icons.cake,
                isNumeric: true,
                validator: (v) {
                  final age = int.tryParse(v ?? '');
                  if (age == null || age < 0 || age > 150) return "Enter a valid age (0–150)";
                  return null;
                },
              ),
              buildGenderDropdown(),
              buildFieldWithSpeech(
                label: "Mobile Number",
                controller: _phoneController,
                icon: Icons.phone,
                isNumeric: true,
                validator: (v) {
                  final phone = v?.trim() ?? '';
                  final phoneRegex = RegExp(r'^\d{10}$'); // exactly 10 digits, no country code
                  if (!phoneRegex.hasMatch(phone)) {
                    return ('Enter valid 10-digit mobile number (without country code)');
                  }
                  return null;
                },
              ),
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
                validator: (v) => (v == null || v.length < 6) ? "Password must be at least 6 characters" : null,
              ),
              buildFieldWithSpeech(
                label: "Confirm Password",
                controller: _confirmPasswordController,
                icon: Icons.lock_outline,
                isPassword: true,
                validator: (v) => (v == null || v.length < 6) ? "Confirm password must be at least 6 characters" : null,
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
                  "Register",
                  style: TextStyle(color: Colors.white, fontSize: 16),
                ),
              ),
              const SizedBox(height: 16),
              // Link to Login Screen
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const TranslatedText("Already have an account? "),
                  TextButton(
                    onPressed: () {
                      Navigator.pushReplacement(
                        context,
                        MaterialPageRoute(builder: (context) => const LoginScreen()),
                      );
                    },
                    child: const TranslatedText("Login"),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
