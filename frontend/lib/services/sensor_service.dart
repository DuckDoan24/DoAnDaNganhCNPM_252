// lib/services/sensor_service.dart

import 'dart:convert';
import 'package:http/http.dart' as http;
import '../config/app_config.dart';

class SensorService {
  static Future<Map<String, dynamic>?> getTemperature() async {
    final url = Uri.parse('${AppConfig.baseUrl}/sensor/temperature');

    try {
      final response = await http.get(
        url,
        headers: {'Content-Type': 'application/json'},
      );

      if (response.statusCode == 200) {
        return jsonDecode(response.body);
      } else {
        print('Backend error fetching temperature: ${response.statusCode}');
        return null;
      }
    } catch (e) {
      print('Network error fetching temperature: $e');
      return null;
    }
  }

  static Future<Map<String, dynamic>?> getHumidity() async{
    final url = Uri.parse('${AppConfig.baseUrl}/sensor/humidity');

    try {
      final response = await http.get(
        url,
        headers: {'Content-Type': 'application/json'},
      );

      if (response.statusCode == 200) {
        return jsonDecode(response.body);
      } else {
        print('Backend error fetching humidity: ${response.statusCode}');
        return null;
      }
    } catch (e) {
      print('Network error fetching humidity: $e');
      return null;
    }
  }

  static Future<Map<String, dynamic>?> getBrightness() async {
    final url = Uri.parse('${AppConfig.baseUrl}/sensor/brightness');

    try {
      final response = await http.get(
        url,
        headers: {'Content-Type': 'application/json'},
      );

      if (response.statusCode == 200) {
        return jsonDecode(response.body);
      } else {
        print('Backend error fetching brightness: ${response.statusCode}');
        return null;
      }
    } catch (e) {
      print('Network error fetching brightness: $e');
      return null;
    }
  }

  static Future<List<dynamic>?> getTemperatureHistory({int limit = 15}) async {
    final url = Uri.parse('${AppConfig.baseUrl}/sensor/temperature/history?limit=$limit');

    try {
      final response = await http.get(
        url,
        headers: {'Content-Type': 'application/json'},
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        return data['history']; // Returns the array of past temperatures
      } else {
        print('Backend error fetching history: ${response.statusCode}');
        return null;
      }
    } catch (e) {
      print('Network error fetching history: $e');
      return null;
    }
  }
}