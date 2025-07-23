import 'package:flutter/material.dart';
import 'package:frontend_flutter/config/translated_text.dart';

class MainPage extends StatelessWidget {
  final bool isGuest = true; // 👈 Change to false later when login is implemented

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: TranslatedText('Hello'),
        leading: IconButton(
          icon: Icon(Icons.menu),
          onPressed: () {
            // You can add drawer toggle or menu later
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(content: TranslatedText('Menu tapped')),
            );
          },
        ),
        actions: [
          Padding(
            padding: const EdgeInsets.only(right: 12.0),
            child: isGuest
                ? CircleAvatar(
                    backgroundColor: Colors.grey[300],
                    child: Icon(Icons.person_outline, color: Colors.black),
                  )
                : GestureDetector(
                    onTap: () {
                      // Show profile or account page later
                    },
                    child: CircleAvatar(
                      backgroundImage: AssetImage('assets/user_profile.png'), // optional
                    ),
                  ),
          ),
        ],
      ),
      body: Center(
        child: TranslatedText(
          isGuest ? 'Welcome, Guest!' : 'Welcome back!',
          style: TextStyle(fontSize: 24),
        ),
      ),
    );
  }
}
