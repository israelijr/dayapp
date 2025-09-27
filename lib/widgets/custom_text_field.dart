import 'package:flutter/material.dart';

class CustomTextField extends StatelessWidget {
  final String label;
  final TextEditingController controller;
  final bool obscureText;
  final TextInputType keyboardType;
  final Widget? suffixIcon;
  final bool enabled;

  const CustomTextField({
    super.key,
    required this.label,
    required this.controller,
    this.obscureText = false,
    this.keyboardType = TextInputType.text,
    this.suffixIcon,
    this.enabled = true,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: Theme(
        data: Theme.of(context).copyWith(brightness: Brightness.light),
        child: TextField(
          controller: controller,
          obscureText: obscureText,
          keyboardType: keyboardType,
          enabled: enabled,
          style: TextStyle(color: Colors.black),
          decoration: InputDecoration(
            labelText: label,
            labelStyle: TextStyle(color: Colors.black),
            border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
            suffixIcon: suffixIcon,
            filled: true,
            fillColor: Colors.grey[200],
          ),
        ),
      ),
    );
  }
}
