// lib/screens/mobile_profile_screen.dart

import 'package:flutter/material.dart';
// Note: Update these imports to point to your actual mobile files and services
import '../services/auth_service.dart';
import 'mobile_login_screen.dart'; 

class MobileProfileScreen extends StatefulWidget {
  const MobileProfileScreen({super.key});

  @override
  State<MobileProfileScreen> createState() => _MobileProfileScreenState();
}

class _MobileProfileScreenState extends State<MobileProfileScreen> {
  // Controllers
  final _nameController = TextEditingController();
  final _emailController = TextEditingController();
  final _dobController = TextEditingController();
  final _phoneController = TextEditingController();

  bool _isLoading = true;
  bool _isEditing = false;

  // Colors matching the mobile UI
  static const Color _fieldBackground = Color(0xFFF5F5F5);
  static const Color _primaryGreen = Color(0xFF2E7D32); // Adjust to match exact Figma green
  static const Color _textDark = Color(0xFF1A1A1A);

  @override
  void initState() {
    super.initState();
    _fetchUserData();
  }

  // ==========================================
  // EXACT LOGIC FROM WEB_PROFILE_SCREEN
  // ==========================================

  Future<void> _fetchUserData() async {
    final userData = await AuthService.getUserProfile();

    if (userData != null && mounted) {
      setState(() {
        _emailController.text = userData['email'] ?? '';
        _nameController.text = userData['fullname'] ?? '';
        _dobController.text = userData['dob'] ?? '';
        _phoneController.text = userData['phonenum'] ?? '';
        
        _isLoading = false; 
      });
    } else {
      print("Failed to load profile data");
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
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
          _isEditing = false; // Turn off editing mode after saving
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

  void _handleDeleteAccount() {
    showDialog(
      context: context,
      builder: (BuildContext dialogContext) {
        return AlertDialog(
          title: const Text('Xác nhận xoá tài khoản', style: TextStyle(color: Colors.red)),
          content: const Text('Hành động này không thể hoàn tác. Bạn có chắc chắn muốn xoá tài khoản này không?'),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(dialogContext), 
              child: const Text('Huỷ', style: TextStyle(color: Colors.grey)),
            ),
            TextButton(
              onPressed: () async {
                Navigator.pop(dialogContext); 
                
                final error = await AuthService.deleteUser();
                
                if (mounted) {
                  if (error == null) {
                    Navigator.pushAndRemoveUntil(
                      context,
                      // Navigate to MobileLoginScreen instead of WebLoginScreen
                      MaterialPageRoute(builder: (context) => const MobileLoginScreen()),
                      (route) => false, 
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
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: DateTime(2005, 1, 1), 
      firstDate: DateTime(1900), 
      lastDate: DateTime.now(), 
      builder: (context, child) {
        return Theme(
          data: Theme.of(context).copyWith(
            colorScheme: const ColorScheme.light(
              primary: _primaryGreen, 
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

  // ==========================================
  // MOBILE UI BUILDER
  // ==========================================

  Widget _buildInputField({
    required String label,
    required TextEditingController controller,
    bool readOnly = false,
    VoidCallback? onTap,
  }) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 20.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            label,
            style: const TextStyle(
              fontSize: 15,
              color: _textDark,
              fontWeight: FontWeight.w400,
            ),
          ),
          const SizedBox(height: 8),
          TextFormField(
            controller: controller,
            readOnly: readOnly,
            onTap: onTap,
            style: TextStyle(
              color: readOnly && !_isEditing ? Colors.grey.shade700 : Colors.black, // Visual cue for locked fields
            ),
            decoration: InputDecoration(
              filled: true,
              fillColor: _fieldBackground,
              contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(10), // Matched to the slightly rounded corners in your design
                borderSide: BorderSide.none,
              ),
            ),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        iconTheme: const IconThemeData(color: Colors.black),
      ),
      body: SafeArea(
        child: _isLoading 
        ? const Center(
            child: CircularProgressIndicator(color: _primaryGreen),
          )
        : SingleChildScrollView(
            padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 10.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // 1. Logo & Title
                Center(
                  child: Column(
                    children: [
                      Image.asset(
                        'images/logo.png', // Ensure this asset is in your pubspec.yaml
                        height: 90,
                        errorBuilder: (context, error, stackTrace) => const Icon(
                          Icons.home_work,
                          size: 90,
                          color: Colors.blue,
                        ),
                      ),
                      const SizedBox(height: 16),
                      const Text(
                        'Thông tin chủ nhà',
                        style: TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                          color: _textDark,
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 32),

                // 2. Profile Fields
                _buildInputField(
                  label: 'Họ và tên',
                  controller: _nameController,
                  readOnly: !_isEditing,
                ),
                _buildInputField(
                  label: 'Email',
                  controller: _emailController,
                  readOnly: true, // Email is always read-only
                ),
                _buildInputField(
                  label: 'Ngày sinh',
                  controller: _dobController,
                  readOnly: true, // Prevent keyboard from opening
                  onTap: _isEditing ? () => _selectDate(context) : null, // Only open picker if editing
                ),
                _buildInputField(
                  label: 'Số điện thoại',
                  controller: _phoneController,
                  readOnly: !_isEditing, // Fixed from web version to lock when not editing
                ),

                // 3. Edit Action
                Align(
                  alignment: Alignment.centerRight,
                  child: GestureDetector(
                    onTap: () {
                      setState(() {
                        _isEditing = !_isEditing;
                      });
                    },
                    child: Padding(
                      padding: const EdgeInsets.only(bottom: 12.0),
                      child: Text(
                        _isEditing ? 'Hủy' : 'Chỉnh sửa',
                        style: const TextStyle(
                          color: _primaryGreen,
                          fontSize: 14,
                        ),
                      ),
                    ),
                  ),
                ),

                // 4. Save Button (Visible when editing)
                if (_isEditing)
                  ElevatedButton(
                    onPressed: _handleSaveChanges,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: _primaryGreen,
                      foregroundColor: Colors.white,
                      elevation: 0,
                      minimumSize: const Size(double.infinity, 50),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8), // Matching the button shape in the image
                      ),
                    ),
                    child: const Text(
                      'Lưu những thay đổi',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                
                const SizedBox(height: 12),

                // 5. Delete Account Action
                Align(
                  alignment: Alignment.centerLeft,
                  child: GestureDetector(
                    onTap: _handleDeleteAccount,
                    child: const Text(
                      'Xoá tài khoản',
                      style: TextStyle(
                        color: _primaryGreen, // Styled green to match your mobile mockup
                        fontSize: 14,
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: 40),
              ],
            ),
          ),
      ),
    );
  }
}