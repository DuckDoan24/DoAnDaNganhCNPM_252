import 'package:flutter/material.dart';
import '../services/auth_service.dart';
// Note: Update these imports to point to your mobile screens
import 'mobile_dashboard_screen.dart';
import 'mobile_register_screen.dart';

class MobileLoginScreen extends StatefulWidget {
  const MobileLoginScreen({super.key});

  @override
  State<MobileLoginScreen> createState() => _MobileLoginScreenState();
}

class _MobileLoginScreenState extends State<MobileLoginScreen> {
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();

  // Color palette matching the Figma design
  static const Color _primaryGreen = Color(0xFF3CD154);
  static const Color _fieldBackground = Color(0xFFF0F0F0);
  static const Color _textDark = Color(0xFF1A1A1A);

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  void _handleLogin() async {
    final email = _emailController.text.trim();
    final password = _passwordController.text.trim();

    if (email.isEmpty || password.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Vui lòng nhập email và mật khẩu'),
          backgroundColor: Colors.orange,
        ),
      );
      return;
    }

    final errorMessage = await AuthService.login(email, password);

    if (errorMessage == null) {
      if (mounted) {
        // Navigate to the Mobile Dashboard
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(
            builder: (context) => const MobileDashboardScreen(),
          ),
        );
        print('Login Success - Navigate to Dashboard');
      }
    } else {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(errorMessage), backgroundColor: Colors.red),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: SingleChildScrollView(
          child: Padding(
            padding: const EdgeInsets.symmetric(
              horizontal: 24.0,
              vertical: 40.0,
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // 1. Logo and Tagline Section
                Center(
                  child: Column(
                    children: [
                      // Replace with your actual asset path
                      Image.asset(
                        'images/logo.png',
                        height: 100,
                        errorBuilder: (context, error, stackTrace) =>
                            const Icon(
                              Icons.home_work,
                              size: 100,
                              color: Colors.blue,
                            ), // Fallback if image isn't loaded yet
                      ),
                      const SizedBox(height: 16),
                      const Text(
                        'Đăng nhập để quản lí ngôi nhà thông minh của bạn',
                        textAlign: TextAlign.center,
                        style: TextStyle(fontSize: 16, color: _textDark),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 40),

                // 2. Email Input
                const Text(
                  'Email',
                  style: TextStyle(
                    fontSize: 15,
                    color: _textDark,
                    fontWeight: FontWeight.w500,
                  ),
                ),
                const SizedBox(height: 8),
                TextField(
                  controller: _emailController,
                  keyboardType: TextInputType.emailAddress,
                  decoration: InputDecoration(
                    filled: true,
                    fillColor: _fieldBackground,
                    contentPadding: const EdgeInsets.symmetric(
                      horizontal: 20,
                      vertical: 14,
                    ),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(30),
                      borderSide: BorderSide.none,
                    ),
                  ),
                ),
                const SizedBox(height: 20),

                // 3. Password Input
                const Text(
                  'Mật khẩu',
                  style: TextStyle(
                    fontSize: 15,
                    color: _textDark,
                    fontWeight: FontWeight.w500,
                  ),
                ),
                const SizedBox(height: 8),
                TextField(
                  controller: _passwordController,
                  obscureText: true,
                  decoration: InputDecoration(
                    filled: true,
                    fillColor: _fieldBackground,
                    contentPadding: const EdgeInsets.symmetric(
                      horizontal: 20,
                      vertical: 14,
                    ),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(30),
                      borderSide: BorderSide.none,
                    ),
                  ),
                ),
                const SizedBox(height: 12),

                // 4. Forgot Password Link
                Align(
                  alignment: Alignment.centerRight,
                  child: GestureDetector(
                    onTap: () {
                      // TODO: Implement forgot password
                    },
                    child: const Text(
                      'Quên mật khẩu?',
                      style: TextStyle(color: _primaryGreen, fontSize: 14),
                    ),
                  ),
                ),
                const SizedBox(height: 30),

                // 5. Login Button
                ElevatedButton(
                  onPressed: _handleLogin,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: _primaryGreen,
                    foregroundColor:
                        _textDark, // Matches the dark text on the button
                    elevation: 0,
                    minimumSize: const Size(double.infinity, 50),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(30),
                    ),
                  ),
                  child: const Text(
                    'Đăng nhập',
                    style: TextStyle(fontSize: 16, fontWeight: FontWeight.w500),
                  ),
                ),
                const SizedBox(height: 24),

                // 6. Register Link
                Align(
                  alignment: Alignment.centerLeft,
                  child: GestureDetector(
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => const MobileRegisterScreen(),
                        ),
                      );
                    },
                    child: const Text(
                      'Chưa có tài khoản? Đăng ký?',
                      style: TextStyle(color: _primaryGreen, fontSize: 14),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
