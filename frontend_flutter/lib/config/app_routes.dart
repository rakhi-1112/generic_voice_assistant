import 'package:flutter/material.dart';
import 'package:frontend_flutter/screens/chat_screen/chat_screen.dart';
import 'package:frontend_flutter/screens/financial_toolkit/financial_toolkit_menu.dart';
import 'package:frontend_flutter/screens/home/home_screen.dart';
import 'package:frontend_flutter/screens/home/splash_screen.dart';
import 'package:frontend_flutter/screens/investment_options/investment_options_screen.dart';
import 'package:frontend_flutter/screens/text_chat/text_chat_screen.dart';
import 'package:frontend_flutter/screens/voice_chat/voice_chat_screen.dart';
import '../screens/settings/settings_screen.dart';
import 'package:frontend_flutter/screens/home/login_screen.dart';
import 'package:frontend_flutter/screens/home/register_screen.dart';
import 'package:frontend_flutter/screens/home/verify_phoneScreen.dart';

class AppRoutes {
  static Map<String, WidgetBuilder> routes = {
    '/': (context) => SplashScreen(),
    '/home': (context) => const HomeScreen(),
    '/chat': (context) => const ChatScreen(),
    '/voice_chat': (context) => const VoiceChatScreen(),
    '/text_chat': (context) => const TextChatScreen(),
    '/investment_options': (context) => const InvestmentOptionsScreen(),
    '/financial_toolkit': (context) => const FinancialToolkitMenu(),
    '/settings': (context) => const SettingsScreen(), 
    '/login': (context) => const LoginScreen(),
    '/register': (context) => const RegisterScreen(),
    '/verify-phone': (context) => const VerifyPhoneScreen(),
  };
}