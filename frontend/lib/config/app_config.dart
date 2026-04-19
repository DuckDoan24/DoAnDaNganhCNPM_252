import 'package:flutter/foundation.dart'; // Required for kIsWeb

class AppConfig {
  // If the app is running on the Web (Chrome), use standard localhost.
  // If it's running on the Android Emulator, use the special 10.0.2.2 tunnel.
  
  static const String baseUrl = kIsWeb 
      ? 'http://127.0.0.1:5000' 
      : 'http://10.0.2.2:5000';
}