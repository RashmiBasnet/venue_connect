import 'package:flutter/material.dart';

class MyTextFormField extends StatefulWidget {
  final String label;
  final String hint;
  final String errorMessage;
  final TextEditingController controller;
  final IconData icon;
  final bool isPassword;

  const MyTextFormField({
    super.key,
    required this.label,
    required this.hint,
    required this.errorMessage,
    required this.controller,
    required this.icon,
    this.isPassword = false,
  });

  @override
  State<MyTextFormField> createState() => _MyTextFormFieldState();
}

class _MyTextFormFieldState extends State<MyTextFormField> {
  bool _obscureText = true;

  @override
  Widget build(BuildContext context) {
    return TextFormField(
      controller: widget.controller,
      obscureText: widget.isPassword ? _obscureText : false,
      style: const TextStyle(
        fontFamily: "Poppins",
        fontSize: 15,
      ),
      decoration: InputDecoration(
        filled: true,
        fillColor: Colors.white,

        // Border Style
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(16),
          borderSide: BorderSide(
            color: Colors.grey.shade300,
            width: 1,
          ),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(16),
          borderSide: BorderSide(
            color: Colors.grey.shade400,
            width: 1.2,
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
          widget.icon,
          color: Colors.grey.shade500,
        ),

        // Label + Hint
        labelText: widget.label,
        labelStyle: const TextStyle(
          fontFamily: "Poppins",
          fontSize: 15,
          fontWeight: FontWeight.w600,
          color: Colors.black87,
        ),
        hintText: widget.hint,
        hintStyle: TextStyle(
          fontFamily: "Poppins",
          fontSize: 14,
          color: Colors.grey.shade400,
        ),

        // password (eye icon)
        suffixIcon: widget.isPassword
            ? IconButton(
                icon: Icon(
                  _obscureText ? Icons.visibility_off : Icons.visibility,
                  color: Colors.grey.shade500,
                ),
                onPressed: () {
                  setState(() {
                    _obscureText = !_obscureText;
                  });
                },
              )
            : null,
      ),
      validator: (value) {
        if (value == null || value.trim().isEmpty) {
          return widget.errorMessage;
        }
        return null;
      },
    );
  }
}
