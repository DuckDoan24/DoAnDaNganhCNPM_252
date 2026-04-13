// lib/screens/web_profile_screen.dart

import 'package:flutter/material.dart';
import 'package:frontend/screens/web_login_screen.dart';
import '../widgets/auth_widgets.dart';
import '../services/auth_service.dart';

class WebProfileScreen extends StatefulWidget {
  const WebProfileScreen({super.key});

  @override
  State<WebProfileScreen> createState() => _WebProfileScreenState();
}

class _WebProfileScreenState extends State<WebProfileScreen> {
  // Controllers
  final _nameController = TextEditingController();
  final _emailController = TextEditingController();
  final _dobController = TextEditingController();
  final _phoneController = TextEditingController();

  static const double _contentConstraintWidth = 800.0;
  bool _isLoading = true;
  bool _isEditing = false;

  @override
  void initState() {
    super.initState();
    // Pre-filling the data from your Figma design
    _fetchUserData();
  }

  Future<void> _fetchUserData() async {
    final userData = await AuthService.getUserProfile();

    if (userData != null && mounted) {
      setState(() {
        // Populate the controllers with the exact keys from your Flask API
        _emailController.text = userData['email'] ?? '';
        _nameController.text = userData['fullname'] ?? '';
        _dobController.text = userData['dob'] ?? '';
        _phoneController.text = userData['phonenum'] ?? '';
        
        // Turn off the loading spinner
        _isLoading = false; 
      });
    } else {
      // If it fails (e.g., token expired), you might want to log them out
      print("Failed to load profile data");
      setState(() {
        _isLoading = false;
      });
    }
  }

  @override
  void dispose() {
    _nameController.dispose();
    _emailController.dispose();
    _dobController.dispose();
    _phoneController.dispose();
    super.dispose();
  }

  void _handleSaveChanges() async {
    final fullname = _nameController.text.trim();
    final dob = _dobController.text.trim();
    final phonenum = _phoneController.text.trim();

    if (fullname.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Họ tên không được để trống'), backgroundColor: Colors.orange),
      );
      return;
    }

    final error = await AuthService.updateUserProfile(
      fullname: fullname,
      dob: dob,
      phonenum: phonenum,
    );

    if (mounted) {
      if (error == null) {
        setState(() {
          _isEditing = !_isEditing;
        });
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Cập nhật thông tin thành công!'), backgroundColor: Colors.green),
        );
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(error), backgroundColor: Colors.red),
        );
      }
    }
  }

  // Make sure to import the Login screen at the top of your file!
  // import 'web_login_screen.dart';

  void _handleDeleteAccount() {
    showDialog(
      context: context,
      builder: (BuildContext dialogContext) {
        return AlertDialog(
          title: const Text('Xác nhận xoá tài khoản', style: TextStyle(color: Colors.red)),
          content: const Text('Hành động này không thể hoàn tác. Bạn có chắc chắn muốn xoá tài khoản này không?'),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(dialogContext), // Cancel
              child: const Text('Huỷ', style: TextStyle(color: Colors.grey)),
            ),
            TextButton(
              onPressed: () async {
                Navigator.pop(dialogContext); // Close the dialog first
                
                final error = await AuthService.deleteUser();
                
                if (mounted) {
                  if (error == null) {
                    // Success! Kick them back to the Login Screen and clear the navigation stack
                    Navigator.pushAndRemoveUntil(
                      context,
                      MaterialPageRoute(builder: (context) => const WebLoginScreen()),
                      (route) => false, // Destroy all previous routes
                    );
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(content: Text('Đã xoá tài khoản'), backgroundColor: Colors.black),
                    );
                  } else {
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(content: Text(error), backgroundColor: Colors.red),
                    );
                  }
                }
              },
              child: const Text('Xoá vĩnh viễn', style: TextStyle(color: Colors.red)),
            ),
          ],
        );
      },
    );
  }

  Future<void> _selectDate(BuildContext context) async {
    // 1. Show the built-in Flutter calendar popup
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: DateTime(2005, 1, 1), // Default starting date
      firstDate: DateTime(1900), // Oldest selectable date
      lastDate: DateTime.now(), // Cannot pick a future date
      // 2. Custom theme to make the calendar match your green brand color
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

    // 3. If the user picked a date (and didn't hit cancel)
    if (picked != null) {
      // Format it to DD/MM/YYYY so it matches your Figma design perfectly
      final formattedDate = "${picked.day.toString().padLeft(2, '0')}/${picked.month.toString().padLeft(2, '0')}/${picked.year}";
      
      // 4. Update the text controller, which automatically updates the UI
      setState(() {
        _dobController.text = formattedDate;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: _isLoading ? const Center(
        child: CircularProgressIndicator(
          color: Color (0xFF39CB4E),
        ),
      )
      : LayoutBuilder(
        builder: (context, constraints) {
          return SingleChildScrollView(
            child: ConstrainedBox(
              constraints: BoxConstraints(minHeight: constraints.maxHeight),
              child: IntrinsicHeight(
                child: Padding(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 40,
                    vertical: 60,
                  ),
                  child: Center(
                    child: ConstrainedBox(
                      constraints: const BoxConstraints(
                        maxWidth: _contentConstraintWidth,
                      ),
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          // 1. Logo Section (Reusing AuthLogoSection, leaving description blank)
                          const Center(
                            child: AuthLogoSection(
                              logoAssetPath: 'images/logo.png',
                              descriptionText: '', 
                            ),
                          ),
                          
                          // 2. Screen Title
                          const Center(
                            child: Text(
                              'Thông tin tài khoản',
                              style: TextStyle(
                                fontSize: 24,
                                fontWeight: FontWeight.bold,
                                color: Colors.black,
                              ),
                            ),
                          ),
                          const SizedBox(height: 40),

                          // 3. Profile Fields
                          AuthTextField(
                            label: 'Họ và tên',
                            controller: _nameController,
                            readOnly: !_isEditing
                          ),
                          const SizedBox(height: 20),

                          AuthTextField(
                            label: 'Email',
                            controller: _emailController,
                            readOnly: true,
                          ),
                          const SizedBox(height: 20),

                          AuthTextField(
                            label: 'Ngày sinh',
                            controller: _dobController,
                            readOnly: true,
                            onTap: _isEditing ? () => _selectDate(context) : null,
                          ),
                          const SizedBox(height: 20),

                          AuthTextField(
                            label: 'Số điện thoại',
                            controller: _phoneController,
                          ),
                          const SizedBox(height: 20),

                          // 4. Secondary Actions Row (More natural layout)
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              // Custom Red Link for Deletion
                              GestureDetector(
                                onTap: _handleDeleteAccount,
                                child: const Text(
                                  'Xoá tài khoản',
                                  style: TextStyle(
                                    color: Colors.red, // Destructive action
                                    fontSize: 14,
                                  ),
                                ),
                              ),
                              // Reusing your Green link for Edit
                              AuthTextLink(
                                text: _isEditing ? 'Hủy' : 'Chỉnh sửa',
                                alignment: Alignment.centerRight,
                                onPressed: () {
                                  setState(() {
                                    _isEditing = !_isEditing;
                                  });
                                },
                              ),
                            ],
                          ),
                          const SizedBox(height: 30),

                          // 5. Primary Save Button
                          if (_isEditing)
                            AuthButton(
                              text: 'Lưu những thay đổi',
                              onPressed: _handleSaveChanges,
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