// lib/services/device_service.dart

import 'dart:convert';
import 'package:http/http.dart' as http;
import '../config/app_config.dart';

class DeviceService {
  // Returns true if the backend successfully toggled the light, false otherwise.
  static Future<bool> toggleLed(bool isOn) async {
    final url = Uri.parse('${AppConfig.baseUrl}/control/led');

    try {
      final response = await http.post(
        url,
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({
          // Translate true/false to "on"/"off" for the Flask backend
          'state': isOn ? 'on' : 'off', 
        }),
      );

      // Check if Flask returned the 200 OK status
      if (response.statusCode == 200) {
        return true;
      } else {
        print('Backend rejected LED toggle: ${response.statusCode}');
        return false;
      }
    } catch (e) {
      print('Network error toggling LED: $e');
      return false;
    }
  }

  static Future<bool> changeLedColor(String hexColor) async {
    final url = Uri.parse('${AppConfig.baseUrl}/control/color');

    try {
      final response = await http.post(
        url,
        headers: {'Content-Type': 'application/json'},
        // Send the hex string (e.g., "#FF0000")
        body: jsonEncode({'color': hexColor}), 
      );

      if (response.statusCode == 200) {
        return true;
      } else {
        print('Backend rejected color change: ${response.statusCode}');
        return false;
      }
    } catch (e) {
      print('Network error changing color: $e');
      return false;
    }
  }

  static Future<bool> toggleFan(bool isOn) async {
    final url = Uri.parse('${AppConfig.baseUrl}/control/fan');

    try {
      final response = await http.post(
        url,
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({
          // Map true to "100" (max speed) and false to "0" (off)
          'speed': isOn ? '100' : '0', 
        }),
      );

      if (response.statusCode == 200) {
        return true;
      } else {
        print('Backend rejected Fan toggle: ${response.statusCode}');
        return false;
      }
    } catch (e) {
      print('Network error toggling Fan: $e');
      return false;
    }
  }
}