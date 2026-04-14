// lib/screens/web_register_screen.dart

import 'package:flutter/material.dart';
import '../widgets/auth_widgets.dart'; 
import '../services/auth_service.dart';

class WebRegisterScreen extends StatefulWidget {
  const WebRegisterScreen({super.key});

  @override
  State<WebRegisterScreen> createState() => _WebRegisterScreenState();
}

class _WebRegisterScreenState extends State<WebRegisterScreen> {
  // Controllers for all the fields
  final _emailController = TextEditingController();
  final _nameController = TextEditingController();
  final _dobController = TextEditingController();
  final _phoneController = TextEditingController();
  final _passwordController = TextEditingController();
  final _confirmPasswordController = TextEditingController();

  final _formKey = GlobalKey<FormState>();

  static const double _contentConstraintWidth = 800.0;

  @override
  void dispose() {
    _emailController.dispose();
    _nameController.dispose();
    _dobController.dispose();
    _phoneController.dispose();
    _passwordController.dispose();
    _confirmPasswordController.dispose();
    super.dispose();
  }
  
  void _handleRegister() async {
    if (!_formKey.currentState!.validate()){
      return;
    }

    // 1. Grab all the text from the controllers
    final email = _emailController.text.trim();
    final fullname = _nameController.text.trim();
    final dob = _dobController.text.trim();
    final phonenum = _phoneController.text.trim();
    final password = _passwordController.text.trim();
    final confirmPassword = _confirmPasswordController.text.trim();

    if (email.isEmpty || fullname.isEmpty || password.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Vui lòng điền đầy đủ thông tin bắt buộc'),
          backgroundColor: Colors.orange,
        ),
      );
      return;
    }

    if (password != confirmPassword) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Mật khẩu xác nhận không khớp!'),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }

    final errorMessage = await AuthService.register(
      email: email,
      fullname: fullname,
      dob: dob,
      phonenum: phonenum,
      password: password,
    );

    if (errorMessage == null) {
      // SUCCESS: Show a green success message
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Đăng ký thành công! Vui lòng đăng nhập.'),
            backgroundColor: Colors.green,
          ),
        );
        // Automatically pop the screen to return the user to the Login Screen
        Navigator.pop(context);
      }
    } else {
      // FAILURE: Show the error returned from Flask (e.g., email already exists)
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(errorMessage),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }


  Future<void> _selectDate(BuildContext context) async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: DateTime(2005, 1, 1), // Default starting date
      firstDate: DateTime(1900), // Oldest selectable date
      lastDate: DateTime.now(), // Cannot pick a future date
      builder: (context, child) {
        return Theme(
          data: Theme.of(context).copyWith(
            colorScheme: const ColorScheme.light(
              primary: Color(0xFF39CB4E), // The green from your UI
              onPrimary: Colors.white,
              onSurface: Colors.black,
            ),
          ),
          child: child!,
        );
      },
    );

    if (picked != null) {
      final formattedDate = "${picked.day.toString().padLeft(2, '0')}/${picked.month.toString().padLeft(2, '0')}/${picked.year}";
      
      setState(() {
        _dobController.text = formattedDate;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: LayoutBuilder(
        builder: (context, constraints) {
          return SingleChildScrollView(
            child: ConstrainedBox(
              constraints: BoxConstraints(minHeight: constraints.maxHeight),
              child: IntrinsicHeight(
                child: Padding(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 40,
                    vertical: 60, // Slightly reduced vertical padding for taller form
                  ),
                  child: Center(
                    child: ConstrainedBox(
                      constraints: const BoxConstraints(
                        maxWidth: _contentConstraintWidth,
                      ),
                      child: Form( 
                        key: _formKey,
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            // 1. Logo Section
                            const Center(
                              child: AuthLogoSection(
                                logoAssetPath: 'images/logo.png', // Replace with your logo
                                descriptionText: 'Chào mừng bạn đến với nhà thông minh',
                              ),
                            ),
                            const SizedBox(height: 40),

                            // 2. Email
                            AuthTextField(
                              label: 'Email',
                              controller: _emailController,
                              validator: (value) {
                                if (value == null || value.isEmpty) {
                                  return 'Vui lòng nhập email';
                                }
                                final emailRegex = RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$');
                                if (!emailRegex.hasMatch(value)){
                                  return 'Email không hợp lệ';
                                }
                                return null;
                              },
                            ),
                            const SizedBox(height: 20),

                            // 3. Full Name
                            AuthTextField(
                              label: 'Họ và tên',
                              controller: _nameController,

                              validator: (value) {
                                if (value == null || value.isEmpty){
                                  return 'Vui lòng nhập họ và tên';
                                }
                                return null;
                              }
                            ),
                            const SizedBox(height: 20),

                            // 4. Date of Birth & Phone Number (Side-by-side)
                            Row(
                              children: [
                                Expanded(
                                  child: GestureDetector(
                                    onTap: () => _selectDate(context),
                                    child: AbsorbPointer(
                                      child: AuthTextField(
                                        label: 'Ngày sinh', 
                                        controller: _dobController,
                                        validator: (value){
                                          if (value == null || value.isEmpty){
                                            return 'Vui lòng điền ngày sinh';
                                          }
                                          return null;
                                        },
                                      )
                                    )
                                  ),
                                ),
                                const SizedBox(width: 20), // Spacing between the two fields
                                Expanded(
                                  child: AuthTextField(
                                    label: 'Số điện thoại',
                                    controller: _phoneController,
                                    validator: (value) {
                                      if (value == null || value.isEmpty) {
                                        return 'Vui lòng nhập số điện thoại';
                                      }
                                      
                                      final phoneRegex = RegExp(r'^0[0-9]{9}$');
                                      
                                      if (!phoneRegex.hasMatch(value)) {
                                        return 'Số điện thoại không hợp lệ (gồm 10 chữ số, bắt đầu bằng 0)';
                                      }
                                      
                                      return null; // Passed validation!
                                    },
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(height: 20),

                            // 5. Password
                            AuthTextField(
                              label: 'Mật khẩu',
                              controller: _passwordController,
                              isObscure: true,
                              validator: (value) {
                                if (value == null || value.isEmpty){
                                  return 'Vui lòng nhập mật khẩu';
                                }
                                return null;
                              }
                            ),
                            const SizedBox(height: 20),

                            // 6. Confirm Password
                            AuthTextField(
                              label: 'Xác nhận mật khẩu',
                              controller: _confirmPasswordController,
                              isObscure: true,
                              validator: (value) {
                                if (value == null || value.isEmpty){
                                  return 'Vui lòng nhập mật khẩu';
                                }

                                if (value != _passwordController.value.text){
                                  return 'Mật khẩu không giống nhau. Vui lòng nhập lại';
                                }
                                return null;
                              }
                            ),
                            const SizedBox(height: 40),

                            // 7. Register Button
                            AuthButton(
                              text: 'Đăng kí',
                              onPressed: _handleRegister,
                            ),
                            const SizedBox(height: 20),

                            // 8. Back to Login Link
                            Row(
                              mainAxisAlignment: MainAxisAlignment.start,
                              children: [
                                const Text(
                                  'Bạn đã là thành viên? ',
                                  style: TextStyle(fontSize: 14, color: Colors.black),
                                ),
                                GestureDetector(
                                  onTap: () {
                                    // Navigate back to Login Screen
                                    Navigator.pop(context);
                                  },
                                  child: const Text(
                                    'Đăng nhập',
                                    style: TextStyle(
                                      color: Color(0xFF39CB4E),
                                      fontSize: 14,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ),
                      )
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