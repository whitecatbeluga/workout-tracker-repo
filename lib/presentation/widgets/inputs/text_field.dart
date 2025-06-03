import 'package:flutter/material.dart';

class InputField extends StatelessWidget {
  const InputField({
    super.key,
    required this.label,
    this.prefixIcon,
    this.suffixIcon,
    this.onSuffixIconPressed,
    this.validator,
    this.keyboardType,
    this.controller,
    this.obscureText = false,
  });

  final String label;
  final IconData? prefixIcon;
  final IconData? suffixIcon;
  final VoidCallback? onSuffixIconPressed;
  final String? Function(String?)? validator;
  final TextInputType? keyboardType;
  final TextEditingController? controller;
  final bool obscureText;

  @override
  Widget build(BuildContext context) {
    return TextFormField(
      obscureText: obscureText,
      decoration: InputDecoration(
        contentPadding: const EdgeInsets.symmetric(vertical: 12),
        border: const OutlineInputBorder(
          borderSide: BorderSide(color: Color(0xFFCBD5E1), width: 1.2),
          borderRadius: BorderRadius.all(Radius.circular(8)),
        ),
        focusedBorder: const OutlineInputBorder(
          borderSide: BorderSide(color: Color(0xFF006A71), width: 1.2),
          borderRadius: BorderRadius.all(Radius.circular(8)),
        ),
        enabledBorder: const OutlineInputBorder(
          borderSide: BorderSide(color: Color(0xFFCBD5E1), width: 1.2),
          borderRadius: BorderRadius.all(Radius.circular(8)),
        ),
        labelText: label,
        labelStyle: const TextStyle(color: Color(0xFF6F7A88)),
        prefixIcon: prefixIcon != null
            ? Icon(prefixIcon, color: Color(0xFF6F7A88))
            : null,
        suffixIcon: suffixIcon != null
            ? IconButton(
                icon: Icon(suffixIcon, color: Color(0xFF6F7A88)),
                onPressed: onSuffixIconPressed,
              )
            : null,
      ),
      validator: validator,
      keyboardType: keyboardType,
      controller: controller,
    );
  }
}
