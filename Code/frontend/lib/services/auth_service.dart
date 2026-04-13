// lib/services/auth_service.dart

import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import 'package:jwt_decoder/jwt_decoder.dart';
import '../config/app_config.dart';


class AuthService {
  // Returns null if login is successful, or an error message string if it fails.
  static Future<String?> login(String email, String password) async {
    // 1. Pointing to your exact Flask route
    final url = Uri.parse('${AppConfig.baseUrl}/user/login');

    try {
      // 2. Send the POST request
      final response = await http.post(
        url,
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({
          'email': email,
          'password': password, // Matches your Flask payload requirements
        }),
      );

      // 3. Handle the 200 Success Response
      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        
        // Grab the token using the exact key from your Flask return jsonify(...)
        final token = data['access-token']; 

        // Save the token securely to local storage
        final prefs = await SharedPreferences.getInstance();
        await prefs.setString('jwt_token', token);

        return null; // Return null to indicate no errors
      } 
      // 4. Handle the 404 Error Response
      else if (response.statusCode == 404) {
        final data = jsonDecode(response.body);
        // Return the exact error message from Flask ("Wrong email or password")
        return data['error']; 
      } 
      // Handle other unexpected server errors
      else {
        return 'Lỗi hệ thống: ${response.statusCode}'; 
      }
    } catch (e) {
      print('Network error: $e');
      return 'Không thể kết nối đến máy chủ. Vui lòng kiểm tra mạng.';
    }
  }

  static Future<String?> register({
    required String email,
    required String fullname,
    required String dob,
    required String phonenum,
    required String password,
  }) async {
    final url = Uri.parse('${AppConfig.baseUrl}/user/register');

    try {
      final response = await http.post(
        url,
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({
          'email': email,
          'fullname': fullname,
          'dob': dob,
          'phonenum': phonenum,
          'password': password,
        }),
      );

      // Handle 201 Created (Success)
      if (response.statusCode == 201) {
        return null; // Return null to indicate no errors
      } 
      // Handle 400 Bad Request or other errors
      else {
        final data = jsonDecode(response.body);
        return data['error'] ?? 'Lỗi đăng ký: ${response.statusCode}';
      }
    } catch (e) {
      print('Network error: $e');
      return 'Không thể kết nối đến máy chủ. Vui lòng kiểm tra mạng.';
    }
  }

  static Future<Map<String, dynamic>?> getUserProfile() async {
    // 1. Get the token from storage
    final prefs = await SharedPreferences.getInstance();
    final token = prefs.getString('jwt_token');

    if (token == null) {
      print('No token found. User needs to log in.');
      return null;
    }

    // 2. Decode the token to get the User ID
    // Flask JWT Extended puts the 'identity' into a field called 'sub' (subject)
    Map<String, dynamic> decodedToken = JwtDecoder.decode(token);
    final userId = decodedToken['sub'];

    // 3. Build the URL with the dynamic ID
    final url = Uri.parse('${AppConfig.baseUrl}/user/$userId');

    try {
      // 4. Send the GET request
      final response = await http.get(
        url,
        headers: {
          'Content-Type': 'application/json',
          // It's good practice to send the token back to the server just in case
          'Authorization': 'Bearer $token', 
        },
      );

      if (response.statusCode == 200) {
        // Return the JSON dictionary (email, fullname, dob, phonenum)
        return jsonDecode(response.body);
      } else {
        print('Backend error: ${response.statusCode}');
        return null;
      }
    } catch (e) {
      print('Network error: $e');
      return null;
    }
  }

  static Future<String?> updateUserProfile({
    required String fullname,
    required String dob,
    required String phonenum,
  }) async {
    final prefs = await SharedPreferences.getInstance();
    final token = prefs.getString('jwt_token');
    if (token == null) return 'Lỗi phiên đăng nhập';

    Map<String, dynamic> decodedToken = JwtDecoder.decode(token);
    final userId = decodedToken['sub'];

    final url = Uri.parse('${AppConfig.baseUrl}/user/update/$userId');

    try {
      // Note: Your backend uses POST for updates
      final response = await http.post(
        url,
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $token',
        },
        body: jsonEncode({
          'fullname': fullname,
          'dob': dob,
          'phonenum': phonenum,
        }),
      );

      if (response.statusCode == 201) return null; // Success
      return jsonDecode(response.body)['error'] ?? 'Lỗi cập nhật';
    } catch (e) {
      return 'Lỗi mạng: $e';
    }
  }

  static Future<String?> deleteUser() async {
    final prefs = await SharedPreferences.getInstance();
    final token = prefs.getString('jwt_token');
    if (token == null) return 'Lỗi phiên đăng nhập';

    Map<String, dynamic> decodedToken = JwtDecoder.decode(token);
    final userId = decodedToken['sub'];

    final url = Uri.parse('${AppConfig.baseUrl}/user/delete/$userId');

    try {
      final response = await http.post(
        url,
        headers: {'Authorization': 'Bearer $token'},
      );

      if (response.statusCode == 201) {
        // If deletion is successful, we MUST wipe the token from the phone!
        await prefs.remove('jwt_token'); 
        return null; 
      }
      return jsonDecode(response.body)['error'] ?? 'Lỗi xoá tài khoản';
    } catch (e) {
      return 'Lỗi mạng: $e';
    }
  }
}