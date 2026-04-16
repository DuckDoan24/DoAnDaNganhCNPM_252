// main.dart

import 'package:flutter/material.dart';
import 'screens/web_login_screen.dart';

void main() {
  runApp(const SmartHomeAuthApp());
}

class SmartHomeAuthApp extends StatelessWidget {
  const SmartHomeAuthApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Smart Home Authentication',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: const Color(0xFF39CB4E)),
        useMaterial3: true,
      ),
      // Run the web login screen as the entry point
      home: const WebLoginScreen(),
    );
  }
}