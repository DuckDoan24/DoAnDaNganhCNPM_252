// auth_widgets.dart

import 'package:flutter/material.dart';

class AuthLogoSection extends StatelessWidget {
  // Pass the actual asset path to the logo image
  final String logoAssetPath;
  final String descriptionText;

  const AuthLogoSection({
    super.key,
    required this.logoAssetPath,
    required this.descriptionText,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        // The logo and title/tagline image
        Image.asset(
          logoAssetPath,
          height: 150, // Estimate from screenshot
          fit: BoxFit.contain,
        ),
        const SizedBox(height: 20),
        // The gray description text
        Text(
          descriptionText,
          textAlign: TextAlign.center,
          style: TextStyle(
            color: Colors.grey[600], // Extracted grey
            fontSize: 16,
          ),
        ),
      ],
    );
  }
}

class AuthTextField extends StatelessWidget {
  final String label; 
  final String hint; 
  final TextEditingController controller;
  final bool isObscure; // For password masking
  final String? Function(String?)? validator;

  final bool readOnly; 
  final VoidCallback? onTap;

  const AuthTextField({
    super.key,
    required this.label,
    this.hint = '',
    required this.controller,
    this.isObscure = false,
    this.validator,

    this.readOnly = false, 
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    // A clean light grey color for the field fill
    const Color inputFillColor = Color(0xFFF0F0F0); // Extracted grey
    const double borderRadius = 10.0; // Estimate rounded corner radius

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Field Label (Black Text)
        Text(
          label,
          style: const TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.normal,
            color: Colors.black,
          ),
        ),
        const SizedBox(height: 8),
        // The filled input field
        Container(
          // Constrain width relative to the screen layout
          width: double.infinity,
          decoration: BoxDecoration(
            color: inputFillColor,
            borderRadius: BorderRadius.circular(borderRadius),
          ),
          child: TextFormField(
            controller: controller,
            obscureText: isObscure,
            validator: validator,
            decoration: InputDecoration(
              hintText: hint,
              hintStyle: const TextStyle(color: Colors.grey),
              // No borders, the background container handles the shape
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(borderRadius),
                borderSide: BorderSide.none,
              ),
              contentPadding: const EdgeInsets.symmetric(
                horizontal: 20,
                vertical: 18,
              ), // Extra padding for a tall field
            ),
          ),
        ),
      ],
    );
  }
}

class AuthTextLink extends StatefulWidget {
  final String text; // Vietnamese text (e.g., 'Quên mật khẩu?')
  final Alignment alignment; // Control positioning
  final VoidCallback onPressed;

  const AuthTextLink({
    super.key,
    required this.text,
    required this.alignment,
    required this.onPressed,
  });

  @override
  State<AuthTextLink> createState() => _AuthTextLinkState();
}

class _AuthTextLinkState extends State<AuthTextLink> {
  // Variable to track if the mouse is currently hovering
  bool _isHovering = false;

  @override
  Widget build(BuildContext context) {
    return Align(
      alignment: widget.alignment,
      child: MouseRegion(
        // Changes the mouse pointer to a pointing hand
        cursor: SystemMouseCursors.click, 
        
        // Triggers when the mouse enters the text area
        onEnter: (_) => setState(() => _isHovering = true),
        
        // Triggers when the mouse leaves the text area
        onExit: (_) => setState(() => _isHovering = false),
        
        child: GestureDetector(
          onTap: widget.onPressed,
          
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 200),
            padding: const EdgeInsets.only(bottom: 2), // Space for underline
            decoration: BoxDecoration(
              // Adds a bottom border (underline) ONLY when hovering
              border: Border(
                bottom: BorderSide(
                  color: _isHovering ? const Color(0xFF39CB4E) : Colors.transparent,
                  width: 1.5,
                ),
              ),
            ),
            child: Text(
              widget.text,
              style: TextStyle(
                // Change the color slightly when hovering (makes it a darker green)
                color: _isHovering ? Colors.green.shade700 : const Color(0xFF39CB4E),
                fontSize: 14,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class AuthButton extends StatelessWidget {
  final String text;
  final VoidCallback onPressed;

  const AuthButton({
    super.key,
    required this.text,
    required this.onPressed,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      decoration: BoxDecoration(
        color: const Color(0xFF39CB4E),
        borderRadius: BorderRadius.circular(10.0),
      ),
      child: InkWell(
        onTap: onPressed,
        borderRadius: BorderRadius.circular(10.0),
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: 18),
          child: Center(
            child: Text(
              text,
              style: const TextStyle(
                color: Colors.white,
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
        ),
      ),
    );
  }
}