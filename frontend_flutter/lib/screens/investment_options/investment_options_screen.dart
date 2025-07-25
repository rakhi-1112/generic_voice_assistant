import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:frontend_flutter/config/translated_text.dart';
import 'package:glassmorphism/glassmorphism.dart';
import 'package:google_fonts/google_fonts.dart';
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

// todo: remove region controller

  String _investmentFrequency = 'Recurring';
  String _username = '';
  bool _formSaved = false;
  String? _selectedState;
  final List<String> _indianStates = [
    'Andhra Pradesh',
    'Arunachal Pradesh',
    'Assam',
    'Bihar',
    'Chhattisgarh',
    'Goa',
    'Gujarat',
    'Haryana',
    'Himachal Pradesh',
    'Jharkhand',
    'Karnataka',
    'Kerala',
    'Madhya Pradesh',
    'Maharashtra',
    'Manipur',
    'Meghalaya',
    'Mizoram',
    'Nagaland',
    'Odisha',
    'Punjab',
    'Rajasthan',
    'Sikkim',
    'Tamil Nadu',
    'Telangana',
    'Tripura',
    'Uttar Pradesh',
    'Uttarakhand',
    'West Bengal',
    'Delhi',
    'Jammu and Kashmir',
    'Ladakh',
    'Andaman and Nicobar Islands',
    'Chandigarh',
    'Dadra and Nagar Haveli and Daman and Diu',
    'Lakshadweep',
    'Puducherry'
];


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
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: TranslatedText(message)));
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

  double _riskValue = 50; // Add this in your state

Widget _buildRiskSlider() {
  String getRiskCategory(double value) {
    if (value <= 33) return "Low";
    if (value <= 66) return "Medium";
    return "High";
  }

  return Column(
    crossAxisAlignment: CrossAxisAlignment.start,
    children: [
      TranslatedText(
        "How Much Risk % Can You Take? (0-100)",
        style: GoogleFonts.poppins(
          fontSize: 16,
          fontWeight: FontWeight.w600,
          color: Colors.blue.shade900,
        ),
      ),
      const SizedBox(height: 8),
      Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          TranslatedText("Low", style: GoogleFonts.poppins(fontSize: 13, color: Colors.grey.shade600)),
          TranslatedText("Medium", style: GoogleFonts.poppins(fontSize: 13, color: Colors.grey.shade600)),
          TranslatedText("High", style: GoogleFonts.poppins(fontSize: 13, color: Colors.grey.shade600)),
        ],
      ),
      Slider(
        value: _riskValue,
        min: 0,
        max: 100,
        divisions: 100,
        label: "${_riskValue.round()}%",
        activeColor: Colors.blue.shade700,
        inactiveColor: Colors.blue.shade100,
        onChanged: (value) {
          setState(() => _riskValue = value);
          _investmentRiskController.text = _riskValue.toStringAsFixed(0); // sync to controller
        },
      ),
      Align(
        alignment: Alignment.centerRight,
        child: TranslatedText(
          "Selected: ${_riskValue.round()}% (${getRiskCategory(_riskValue)})",
          style: GoogleFonts.poppins(
            fontSize: 14,
            color: Colors.black87,
            fontWeight: FontWeight.w500,
          ),
        ),
      ),
      const SizedBox(height: 16),
    ],
  );
}


  Future<void> _submitForm() async {
    FocusScope.of(context).unfocus();

    if (!_formKey.currentState!.validate()) return;

    final ageRaw = _ageGroupController.text.trim();
    final goalRaw = _investmentGoalController.text.trim();
    // final riskRaw = _investmentRiskController.text.trim();
    final amountRaw = _investmentAmountController.text.trim();

    final age = int.tryParse(ageRaw);
    final goal = int.tryParse(goalRaw);
    final risk = _riskValue.round();
    final amount = int.tryParse(amountRaw);

    final Map<String, dynamic> payload = {
      "username": _username,
      "age_group": age,
      "inv_frequency": _investmentFrequency,
      "inv_goal": goal,
      "inv_risk": risk,
      "inv_amount": amount,
      "reg": _selectedState ?? "Unknown", // fallback if not selected
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
          const SnackBar(content: TranslatedText("Your preferences have been saved!")),
        );
        setState(() {
          _formSaved = true;
          print("set formsaved");
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
  bool isAgeField = false,
}) {
  return Column(
    crossAxisAlignment: CrossAxisAlignment.start,
    children: [
      Row(
        children: [
          Expanded(
            child: TranslatedText(
              label,
              style: GoogleFonts.poppins(
                fontSize: 16,
                fontWeight: FontWeight.w600,
                color: Colors.blue.shade900,
              ),
            ),
          ),
          IconButton(
            icon: const Icon(Icons.volume_up),
            onPressed: () => speak(label),
          ),
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
        autovalidateMode:
          isAgeField ? AutovalidateMode.onUserInteraction : AutovalidateMode.disabled,
        controller: controller,
        keyboardType: isNumber ? TextInputType.number : TextInputType.text,
        inputFormatters: isNumber
            ? [FilteringTextInputFormatter.digitsOnly]
            : [],
        validator: validator,
        onChanged: isAgeField
          ? (value) {
              final age = int.tryParse(value);
              if (age == null || age < 0 || age > 99) {
                controller.text = value.replaceAll(RegExp(r'[^0-9]'), '');
                controller.selection = TextSelection.fromPosition(
                  TextPosition(offset: controller.text.length),
                );
              }
            }
          : null,

        style: GoogleFonts.poppins(
          fontSize: 15,
          color: Colors.black87,
        ),
        decoration: InputDecoration(
          contentPadding: const EdgeInsets.symmetric(vertical: 12, horizontal: 12),
          border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
          filled: true,
          fillColor: Colors.white,
        ),
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

@override
Widget build(BuildContext context) {
  return Scaffold(
    backgroundColor: Colors.white,
    appBar: AppBar(
      backgroundColor: Colors.white,
      elevation: 0,
      title: TranslatedText(
        'Investment Options',
        style: GoogleFonts.poppins(
        fontSize: 20,
        fontWeight: FontWeight.bold,
      ),
      ),
      centerTitle: true,
    ),
    body: Stack(
      children: [
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
        Center(
          child: GlassmorphicContainer(
            width: MediaQuery.of(context).size.width * 0.9,
            height: MediaQuery.of(context).size.height * 0.88,
            borderRadius: 20,
            blur: 20,
            alignment: Alignment.center,
            border: 1,
            linearGradient: LinearGradient(
              colors: [
                Colors.white.withOpacity(0.2),
                Colors.blue.withOpacity(0.1),
              ],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
            borderGradient: LinearGradient(
              colors: [
                Colors.white.withOpacity(0.4),
                Colors.blue.withOpacity(0.4),
              ],
            ),
            child: Padding(
              padding: const EdgeInsets.all(20),
              child: Form(
                key: _formKey,
                child: ListView(
                  children: [
                    if (_username.isNotEmpty)
                      TranslatedText(
                        "Welcome, $_username!",
                        style: const TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                          color: Color(0xFF0A3D91),
                        ),
                      ).animate().fade(duration: 400.ms).slideY(),
                    const SizedBox(height: 20),
                    _buildFieldWithSpeech(
                      label: "Your Age",
                      isAgeField: true,
                      controller: _ageGroupController,
                      isNumber: true,
                      validator: (v) {
                        if (v == null || v.isEmpty) return "Age is required";
                        final age = int.tryParse(v);
                        if (age == null || age < 0 || age > 99) {
                          return "Enter a valid age (0–99)";
                        }
                        return null;
                      },
                    ),
                   Theme(
                    data: Theme.of(context).copyWith(
                      canvasColor: Colors.white,
                      shadowColor: Colors.grey.shade300,
                    ),
                    child: DropdownButtonFormField<String>(
                      value: _investmentFrequency,
                      decoration: InputDecoration(
                         label: TranslatedText("How Often Do You Want to Invest?"),
                        labelStyle: GoogleFonts.poppins(
                          fontSize: 16,
                          fontWeight: FontWeight.w600,
                          color: Colors.blue.shade900,
                        ),
                        contentPadding: const EdgeInsets.symmetric(vertical: 12, horizontal: 12),
                        filled: true,
                        fillColor: Colors.white,
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                          borderSide: const BorderSide(color: Colors.blueGrey),
                        ),
                        enabledBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                          borderSide: const BorderSide(color: Colors.blueGrey),
                        ),
                        focusedBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                          borderSide: BorderSide(color: Colors.blue.shade700, width: 2),
                        ),
                      ),
                      items: [
                        DropdownMenuItem(
                          value: "Recurring",
                          child: TranslatedText("Recurring", style: GoogleFonts.poppins(fontSize: 16, fontWeight: FontWeight.w500, color: Colors.blue.shade800)),
                        ),
                        DropdownMenuItem(
                          value: "Lumpsum",
                          child: TranslatedText("Lumpsum", style: GoogleFonts.poppins(fontSize: 16, fontWeight: FontWeight.w500, color: Colors.blue.shade800)),
                        ),
                      ],
                      onChanged: (val) => setState(() => _investmentFrequency = val!),
                    ),
                ),

                   
                   const SizedBox(height: 16),
                    _buildFieldWithSpeech(
                      label: "What Is Your Financial Goal? (₹)",
                      controller: _investmentGoalController,
                      isNumber: true,
                      validator: (v) => double.tryParse(v ?? "") == null ? "Enter a number" : null,
                    ),
                    _buildRiskSlider(),
                    _buildFieldWithSpeech(
                      label: "How Much Do You Want to Invest? (₹)",
                      controller: _investmentAmountController,
                      isNumber: true,
                      validator: (v) => double.tryParse(v ?? "") == null ? "Enter a number" : null,
                    ),
                    Theme(
                    data: Theme.of(context).copyWith(
                      canvasColor: Colors.white,
                      shadowColor: Colors.grey.shade300,
                    ),
                    child: DropdownButtonFormField<String>(
  value: _selectedState,
  decoration: InputDecoration(
     label: TranslatedText(
    "Select Your State"),
    labelStyle: GoogleFonts.poppins(
      fontSize: 16,
      fontWeight: FontWeight.w600,
      color: Colors.blue.shade900,
    ),
    contentPadding: const EdgeInsets.symmetric(vertical: 12, horizontal: 12),
    filled: true,
    fillColor: Colors.white,
    border: OutlineInputBorder(
      borderRadius: BorderRadius.circular(12),
      borderSide: const BorderSide(color: Colors.blueGrey),
    ),
    enabledBorder: OutlineInputBorder(
      borderRadius: BorderRadius.circular(12),
      borderSide: const BorderSide(color: Colors.blueGrey),
    ),
    focusedBorder: OutlineInputBorder(
      borderRadius: BorderRadius.circular(12),
      borderSide: BorderSide(color: Colors.blue.shade700, width: 2),
    ),
  ),
  items: _indianStates.map((state) {
    return DropdownMenuItem<String>(
      value: state,
      child: TranslatedText(state, style: GoogleFonts.poppins(fontSize: 16, fontWeight: FontWeight.w500, color: Colors.blue.shade800)),
    );
  }).toList(),
  onChanged: (val) => setState(() => _selectedState = val!),
),

                ),

                    const SizedBox(height: 24),
                    ElevatedButton(
                      onPressed: _submitForm,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFF0A3D91),
                        padding: const EdgeInsets.symmetric(vertical: 14),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                        textStyle: GoogleFonts.poppins(fontSize: 16, fontWeight: FontWeight.w600),
                      ),
                      child: const TranslatedText("Save My Preferences", style: TextStyle(fontSize: 16, color: Colors.white)),
                    ).animate().fade(duration: 600.ms).slideY(),
                    if (_formSaved)
                      Padding(
                        padding: const EdgeInsets.only(top: 16),
                        child: ElevatedButton(
                          onPressed: _generateStrategy,
                          style: ElevatedButton.styleFrom(
                            backgroundColor: const Color(0xFF1565C0),
                            padding: const EdgeInsets.symmetric(vertical: 14),
                            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                          ),
                          child: const TranslatedText("Get My Investment Plan", style: TextStyle(color: Colors.white)),
                        ).animate().fadeIn().slideY(begin: 0.3),
                      ),
                  ],
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
