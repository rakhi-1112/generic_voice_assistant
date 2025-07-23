import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:glassmorphism/glassmorphism.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'dart:io';
import 'package:path_provider/path_provider.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:flutter_sound/flutter_sound.dart';
import 'package:record/record.dart';
import 'investment_strategy_screen.dart';

class InvestmentOptionsScreen extends StatefulWidget {
  const InvestmentOptionsScreen({super.key});

  @override
  State<InvestmentOptionsScreen> createState() => _InvestmentOptionsScreenState();
}

class _InvestmentOptionsScreenState extends State<InvestmentOptionsScreen> {
  final _formKey = GlobalKey<FormState>();

  final TextEditingController _ageGroupController = TextEditingController();
  final TextEditingController _investmentGoalController = TextEditingController();
  final TextEditingController _investmentRiskController = TextEditingController();
  final TextEditingController _investmentAmountController = TextEditingController();
  final TextEditingController _regionController = TextEditingController();



  String _investmentFrequency = 'Recurring';
  String _username = '';
  bool _formSaved = false;

  final AudioRecorder _recorder = AudioRecorder();
  bool _isRecording = false;
  String? _audioPath;

  @override
  void initState() {
    super.initState();
    _loadUsername();
  }

  Future<void> _loadUsername() async {
    final prefs = await SharedPreferences.getInstance();
    setState(() {
      _username = prefs.getString('username') ?? '';
    });
  }

  @override
  void dispose() {
    _recorder.stop();
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
    } else {
      _showError("TTS failed");
    }
  }

  Future<void> startRecording() async {
    try {
      if (!await _recorder.hasPermission()) {
        await Permission.microphone.request();
        if (!await _recorder.hasPermission()) {
          _showError('Microphone permission denied');
          return;
        }
      }

      final dir = await getTemporaryDirectory();
      final path = '${dir.path}/voice_input.m4a';

      await _recorder.start(
        const RecordConfig(encoder: AudioEncoder.aacLc),
        path: path,
      );

      setState(() {
        _isRecording = true;
        _audioPath = path;
      });
    } catch (e) {
      _showError('Recording failed: $e');
    }
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

    if (response.statusCode == 200 && result["transcript"] != null) {
      return result["transcript"];
    } else {
      _showError(result["error"] ?? "STT failed");
      return null;
    }
  }

  void _showError(String message) {
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(message)));
  }

  Future<void> _saveSystemPrompt() async {
    final prompt = 
    '''
      You are a financial advisor for individuals and small businesses, who have little financial literacy or ideas about budgeting. 
      Your current client has the following details :
      - Username: $_username
      - Age Group: ${_ageGroupController.text}
      - Investment Frequency: $_investmentFrequency
      - Investment Goal: ${_investmentGoalController.text}
      - Investment Risk: ${_investmentRiskController.text}
      - Investment Amount: ${_investmentAmountController.text}
      - Region: ${_regionController.text}
      
      Please refuse to answer questions that are not relevant to your role.
      Please answer any questions keeping these factors in mind.
    ''';

    final serverIp = await getServerIp();
    await http.post(
      Uri.parse('$serverIp/api/voicechat/add_system_prompt'),
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode({'prompt': prompt}),
    );
  }

  Future<void> _generateStrategy() async {
    final prompt = 
    '''
      Given the following user details:
      - Username: $_username
      - Age Group: ${_ageGroupController.text}
      - Investment Frequency: $_investmentFrequency
      - Investment Goal: ${_investmentGoalController.text}
      - Investment Risk: ${_investmentRiskController.text}
      - Investment Amount: ${_investmentAmountController.text}
      - Region: ${_regionController.text}
      Instructions:
        1. Analyze the user's profile to generate a personalized investment recommendation.
        2. Tailor suggestions to region-specific schemes or financial products.
        3. Ensure the advice is understandable, unbiased, and secure (no sensitive data stored or reused).
        4. Make the response accessible to users with possible impairments (clear language, structured format).
        5. Create a table with your breakdown of the investment options, for example, equity: 20%, government bonds: 30%, etc.
      
        Now, take the inputs and respond accordingly.
    ''';

    try {
      _showLoadingDialog(); // <-- Show loading

      final ip = await getServerIp();
      final uri = Uri.parse('$ip/api/textchat/generate_response');
      final response = await http.post(
        uri,
        headers: {"Content-Type": "application/json"},
        body: jsonEncode({"prompt": prompt}),
      );

      final result = jsonDecode(response.body);

      Navigator.of(context).pop(); // <-- Dismiss loading

      if (response.statusCode == 200 && result['response'] != null) {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => InvestmentStrategyScreen(strategyText: result['response']),
          ),
        );
      } else {
        _showError(result['error'] ?? "Failed to generate strategy");
      }
    } catch (e) {
      Navigator.of(context).pop(); // <-- Dismiss loading on error
      _showError("Error: $e");
    }
  }


  Future<void> _submitForm() async {
    FocusScope.of(context).unfocus();

    if (!_formKey.currentState!.validate()) return;

    final Map<String, dynamic> payload = {
      "username": _username,
      "age_group": int.parse(_ageGroupController.text),
      "inv_frequency": _investmentFrequency,
      "inv_goal": double.parse(_investmentGoalController.text),
      "inv_risk": double.parse(_investmentRiskController.text),
      "inv_amount": double.parse(_investmentAmountController.text),
      "reg": _regionController.text,
    };

    try {
      await _saveSystemPrompt();

      final ip = await getServerIp();
      final uri = Uri.parse('$ip/api/investment_adv/submit_investment');

      final response = await http.post(
        uri,
        headers: {"Content-Type": "application/json"},
        body: jsonEncode(payload),
      );

      final result = jsonDecode(response.body);

      if (response.statusCode == 200) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text("Investment submitted successfully!")),
        );
        setState(() {
          _formSaved = true;
        });
      } else {
        _showError(result["error"] ?? "Submission failed");
      }
    } catch (e) {
      _showError("Error: $e");
    }
  }

  Widget _buildFieldWithSpeech({
    required String label,
    required TextEditingController controller,
    required String? Function(String?) validator,
    bool isNumber = false,
  }) {
    return Column(
      children: [
        Row(
          children: [
            Expanded(child: Text(label, style: const TextStyle(fontWeight: FontWeight.bold))),
            IconButton(icon: const Icon(Icons.volume_up), onPressed: () => speak(label)),
            IconButton(
              icon: Icon(_isRecording ? Icons.mic_off : Icons.mic),
              onPressed: () async {
                if (!_isRecording) {
                  await startRecording();
                } else {
                  final transcript = await stopRecordingAndTranscribe(isNumeric: isNumber);
                  if (transcript != null) controller.text = transcript;
                }
              },
            )
          ],
        ),
        TextFormField(
          controller: controller,
          keyboardType: isNumber ? TextInputType.number : TextInputType.text,
          validator: validator,
        ),
        const SizedBox(height: 16),
      ],
    );
  }

  void _showLoadingDialog() {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (_) => const Center(
        child: CircularProgressIndicator(),
      ),
    );
  }

  // @override
  // Widget build(BuildContext context) {
  //   return Scaffold(
  //     appBar: AppBar(title: const Text("Investment Options")),
  //     body: Padding(
  //       padding: const EdgeInsets.all(20),
  //       child: Form(
  //         key: _formKey,
  //         child: ListView(
  //           children: [
  //             if (_username.isNotEmpty)
  //               Padding(
  //                 padding: const EdgeInsets.only(bottom: 16),
  //                 child: Text("Hello, $_username", style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
  //               ),
  //             _buildFieldWithSpeech(
  //               label: "Age Group (0 to 150)",
  //               controller: _ageGroupController,
  //               isNumber: true,
  //               validator: (v) {
  //                 final val = int.tryParse(v ?? "");
  //                 return (val == null || val < 0 || val > 150) ? "Enter a valid age (0–150)" : null;
  //               },
  //             ),
  //             DropdownButtonFormField<String>(
  //               value: _investmentFrequency,
  //               decoration: const InputDecoration(labelText: "Investment Frequency"),
  //               items: const [
  //                 DropdownMenuItem(value: "Recurring", child: Text("Recurring")),
  //                 DropdownMenuItem(value: "Lumpsum", child: Text("Lumpsum")),
  //               ],
  //               onChanged: (val) => setState(() => _investmentFrequency = val!),
  //             ),
  //             const SizedBox(height: 16),
  //             _buildFieldWithSpeech(
  //               label: "Investment Goal",
  //               controller: _investmentGoalController,
  //               isNumber: true,
  //               validator: (v) => double.tryParse(v ?? "") == null ? "Enter a number" : null,
  //             ),
  //             _buildFieldWithSpeech(
  //               label: "Investment Risk (0–100)",
  //               controller: _investmentRiskController,
  //               isNumber: true,
  //               validator: (v) {
  //                 final val = double.tryParse(v ?? "");
  //                 return (val == null || val < 0 || val > 100) ? "Risk must be 0 to 100" : null;
  //               },
  //             ),
  //             _buildFieldWithSpeech(
  //               label: "Investment Amount",
  //               controller: _investmentAmountController,
  //               isNumber: true,
  //               validator: (v) => double.tryParse(v ?? "") == null ? "Enter a number" : null,
  //             ),
  //               _buildFieldWithSpeech(
  //               label: "Region",
  //               controller: _regionController,
  //               validator: (v) => (v == null || v.isEmpty) ? "Enter Region" : null,
  //             ),
  //             const SizedBox(height: 30),
  //             ElevatedButton(onPressed: _submitForm, child: const Text("Save")),
  //             if (_formSaved)
  //             Padding(
  //               padding: const EdgeInsets.only(top: 16),
  //               child: ElevatedButton(
  //                 onPressed: _generateStrategy,
  //                 child: const Text("Generate Investment Strategy"),
  //               ),
  //             ),
  //           ],
  //         ),
  //       ),
  //     ),
  //   );
  // }




  @override
Widget build(BuildContext context) {
  return Scaffold(
    extendBodyBehindAppBar: true,
    appBar: AppBar(
      title: const Text("Investment Options"),
      backgroundColor: Colors.transparent,
      elevation: 0,
    ),
    body: Stack(
      children: [
        // 🎨 Gradient + Blob Background
        Container(
          decoration: const BoxDecoration(
            gradient: LinearGradient(
              colors: [Color(0xFFFDEBFF), Color(0xFFE8ECFF)],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
          ),
        ),
        Positioned(
          top: 100,
          left: -50,
          child: AnimatedContainer(
            duration: const Duration(seconds: 7),
            curve: Curves.easeInOut,
            width: 250,
            height: 250,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: Colors.purple.withOpacity(0.2),
            ),
          ).animate(onPlay: (c) => c.repeat(reverse: true)).moveX(begin: 0, end: 30),
        ),
        Positioned(
          bottom: 80,
          right: -30,
          child: AnimatedContainer(
            duration: const Duration(seconds: 6),
            curve: Curves.easeInOut,
            width: 200,
            height: 200,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: Colors.pinkAccent.withOpacity(0.15),
            ),
          ).animate(onPlay: (c) => c.repeat(reverse: true)).moveX(begin: 0, end: -20),
        ),

        // 💡 Frosted Glass Form
        SafeArea(
          child: Center(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(20),
              child: GlassmorphicContainer(
                width: double.infinity,
                borderRadius: 30,
                blur: 20,
                alignment: Alignment.center,
                border: 2,
                linearGradient: LinearGradient(
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                  colors: [
                    Colors.white.withOpacity(0.2),
                    Colors.white38.withOpacity(0.2),
                  ],
                ),
                borderGradient: LinearGradient(
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                  colors: [
                    Colors.white.withOpacity(0.2),
                    Colors.white54.withOpacity(0.2),
                  ],
                ),
                height: MediaQuery.of(context).size.height * 0.8,
                child: Padding(
                  padding: const EdgeInsets.all(24.0),
                  child: Form(
                    key: _formKey,
                    child: Column(
                      children: [
                        Text(
                          "Hello, $_username 👋",
                          style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                                fontWeight: FontWeight.bold,
                                color: Colors.deepPurple,
                              ),
                        ).animate().fadeIn().slideY(),

                        const SizedBox(height: 24),
                        // Add all your _buildFieldWithSpeech here as is
                        _buildFieldWithSpeech(
                          label: "Age Group (0 to 150)",
                          controller: _ageGroupController,
                          isNumber: true,
                          validator: (v) {
                            final val = int.tryParse(v ?? "");
                            return (val == null || val < 0 || val > 150) ? "Enter a valid age (0–150)" : null;
                          },
                        ),
                        // ... more fields

                        const SizedBox(height: 30),
                        ElevatedButton(
                          onPressed: _submitForm,
                          style: ElevatedButton.styleFrom(
                            padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 16),
                            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
                            backgroundColor: const Color(0xFF7F00FF),
                          ),
                          child: const Text("💾 Save", style: TextStyle(fontSize: 18)),
                        ).animate().scale(delay: 400.ms),

                        if (_formSaved)
                          Padding(
                            padding: const EdgeInsets.only(top: 16),
                            child: ElevatedButton(
                              onPressed: _generateStrategy,
                              style: ElevatedButton.styleFrom(
                                padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 16),
                                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
                                backgroundColor: const Color(0xFF00B4D8),
                              ),
                              child: const Text("🚀 Generate Strategy", style: TextStyle(fontSize: 18)),
                            ).animate().scale(delay: 600.ms),
                          ),
                      ],
                    ),
                  ),
                ),
              ),
            ),
          ),
        ),
      ],
    ),
  );
}

}
