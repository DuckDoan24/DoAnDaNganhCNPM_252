// main.dart

import 'package:flutter/material.dart';

// --- Web Imports ---
import 'screens/web_login_screen.dart';

// --- Mobile Imports ---
// Update this path if your mobile screens folder is named differently
import 'mobile_screens/mobile_login_screen.dart';

void main() {
  runApp(const SmartHomeAuthApp());
}

class SmartHomeAuthApp extends StatelessWidget {
  const SmartHomeAuthApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Smart Home Authentication',
      debugShowCheckedModeBanner:
          false, // Removes the red debug banner at the top right
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: const Color(0xFF39CB4E)),
        useMaterial3: true,
      ),
      // Run the responsive router as the entry point instead of a hardcoded screen
      home: const ResponsiveLoginRouter(),
    );
  }
}

/// A wrapper widget that decides which screen to show based on window size
class ResponsiveLoginRouter extends StatelessWidget {
  const ResponsiveLoginRouter({super.key});

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        // 800 pixels is a standard breakpoint.
        // Anything wider gets the Web UI, anything narrower gets the Mobile UI.
        if (constraints.maxWidth > 800) {
          return const WebLoginScreen();
        } else {
          return const MobileLoginScreen();
        }
      },
    );
  }
}
