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
          'state': isOn ? '1' : '0', 
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

  static Future<bool> changeLedColor(int colorIndex) async {
    final url = Uri.parse('${AppConfig.baseUrl}/control/color');

    try {
      final response = await http.post(
        url,
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({'color': colorIndex}),
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


  static Future<bool> setFanSpeed(int speed) async {
    final url = Uri.parse('${AppConfig.baseUrl}/control/fan');

    try {
      final response = await http.post(
        url,
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({
          'speed': speed.toString(),
        }),
      );

      if (response.statusCode == 200) {
        return true;
      } else {
        print('Backend rejected fan speed change: ${response.statusCode}');
        return false;
      }
    } catch (e) {
      print('Network error changing fan speed: $e');
      return false;
    }
  }
}