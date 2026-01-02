import 'package:flutter/material.dart';

class MyTextFormField extends StatelessWidget {
  final String label;
  final String hint;
  final String? errorMessage;
  final TextEditingController controller;
  final IconData icon;
  final bool isPassword;
  final Widget? suffixIcon;
  final String? Function(String?)? validator;

  const MyTextFormField({
    super.key,
    required this.label,
    required this.hint,
    this.errorMessage,
    required this.controller,
    required this.icon,
    this.isPassword = false,
    this.suffixIcon,
    this.validator,
  });

  @override
  Widget build(BuildContext context) {
    return TextFormField(
      controller: controller,
      obscureText: isPassword,
      style: const TextStyle(
        fontSize: 15,
      ),
      decoration: InputDecoration(
        filled: true,
        fillColor: Colors.white,

        // Border Style
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(16),
          borderSide: BorderSide(
            color: Colors.grey.shade300,
            width: 2,
          ),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(16),
          borderSide: BorderSide(
            color: Colors.grey.shade300,
            width: 2,
          ),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(16),
          borderSide: BorderSide(
            color: Colors.grey.shade400,
            width: 2,
          ),
        ),
        errorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(16),
          borderSide: const BorderSide(
            color: Colors.red,
            width: 1,
          ),
        ),

        // Icon(left)
        prefixIcon: Icon(
          icon,
          color: Colors.grey.shade500,
        ),

        // Label + Hint
        labelText: label,
        labelStyle: const TextStyle(
          fontFamily: "Poppins Regular",
          fontSize: 15,
          color: Colors.black87,
        ),
        hintText: hint,
        hintStyle: TextStyle(
          fontSize: 14,
          color: Colors.grey.shade400,
        ),

        // password (eye icon)
        suffixIcon: suffixIcon,
      ),
      validator: validator ?? (value) {
        if (value == null || value.trim().isEmpty) {
          return errorMessage;
        }
        return null;
      },
    );
  }
}