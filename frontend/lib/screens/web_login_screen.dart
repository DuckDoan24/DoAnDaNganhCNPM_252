// web_login_screen.dart

import 'package:flutter/material.dart';
import 'package:frontend/screens/web_register_screen.dart';
import '../widgets/auth_widgets.dart'; // Import reusable widgets
import 'web_dashboard_screen.dart';
import '../services/auth_service.dart';

class WebLoginScreen extends StatefulWidget {
  const WebLoginScreen({super.key});

  @override
  State<WebLoginScreen> createState() => _WebLoginScreenState();
}

class _WebLoginScreenState extends State<WebLoginScreen> {
  // Setup controllers for your fields
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();

  // Define a constant for content constraint width
  static const double _contentConstraintWidth = 800.0;

  @override
  void dispose() {
    // Dispose controllers when the screen is removed
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
      // SUCCESS: The backend returned 200 and we saved the token.
      // Use pushReplacement so the user can't hit the "Back" arrow to go back to the login screen.
      if (mounted) {
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (context) => const WebDashboardScreen()),
        );
      }
    } else {
      // FAILURE: The backend returned 404 (or crashed). Show the exact error.
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(errorMessage), // e.g., "Wrong email or password"
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    // Use LayoutBuilder to handle the overall screen geometry
    return Scaffold(
      backgroundColor: Colors.white, // Standard clean background
      body: LayoutBuilder(
        builder: (context, constraints) {
          // Wrap everything in a single scroll view to allow for scaling
          return SingleChildScrollView(
            child: ConstrainedBox(
              // Allow content to grow, but force a minimum full height
              constraints: BoxConstraints(minHeight: constraints.maxHeight),
              child: IntrinsicHeight(
                // IntrinsicHeight ensures Column matches exact size
                child: Padding(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 40,
                    vertical: 80,
                  ), // General central area padding
                  child: Center(
                    // Center the constrained form on the page
                    child: ConstrainedBox(
                      // Constrain width on wide web screens
                      constraints: const BoxConstraints(
                        maxWidth: _contentConstraintWidth,
                      ),
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Center(
                            child: AuthLogoSection(
                              logoAssetPath: 'images/logo.png',
                              descriptionText:
                                  'Đăng nhập để quản lí ngôi nhà thông minh của bạn',
                            ),
                          ),
                          const SizedBox(height: 60), // Substantial top spacing

                          AuthTextField(
                            label: 'Email',
                            hint: 'Nhập email của bạn',
                            controller: _emailController,
                            // Add validation logic if needed
                          ),
                          const SizedBox(height: 25), // Field spacing

                          AuthTextField(
                            label: 'Mật khẩu',
                            hint: 'Nhập mật khẩu của bạn',
                            controller: _passwordController,
                            isObscure: true, // Mask password
                          ),
                          const SizedBox(height: 15), // Small link spacing

                          AuthTextLink(
                            text: 'Quên mật khẩu?',
                            alignment: Alignment.centerRight,
                            onPressed: () {
                              //TODO: Implement forgot password navigation
                              print('Forgot Password pressed');
                            },
                          ),
                          const SizedBox(height: 40), // Spacing before main button

                          AuthButton(
                            text: 'Đăng nhập',
                            onPressed: _handleLogin,
                          ),
                          const SizedBox(height: 20), // Button-Link spacing

                          AuthTextLink(
                            text: 'Chưa có tài khoản? Đăng ký?',
                            alignment: Alignment.centerLeft,
                            onPressed: () {
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (context) => const WebRegisterScreen(),
                                ),
                              );
                            },
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ),
            ),
          );
        },
      ),
    );
  }
}