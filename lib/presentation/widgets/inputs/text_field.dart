import 'package:flutter/material.dart';

enum InputVariant { outline, subtle, flushed }

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
    this.variant = InputVariant.outline,
  });

  final String label;
  final IconData? prefixIcon;
  final IconData? suffixIcon;
  final VoidCallback? onSuffixIconPressed;
  final String? Function(String?)? validator;
  final TextInputType? keyboardType;
  final TextEditingController? controller;
  final bool obscureText;
  final InputVariant variant;

  InputBorder? _getEnabledBorder() {
    switch (variant) {
      case InputVariant.outline:
        return const OutlineInputBorder(
          borderSide: BorderSide(color: Color(0xFFCBD5E1), width: 1.2),
          borderRadius: BorderRadius.all(Radius.circular(8)),
        );
      case InputVariant.subtle:
        return OutlineInputBorder(
          borderSide: BorderSide.none,
          borderRadius: BorderRadius.circular(8),
        );
      case InputVariant.flushed:
        return const UnderlineInputBorder(
          borderSide: BorderSide(color: Color(0xFFCBD5E1), width: 1.2),
        );
    }
  }

  InputBorder? _getFocusedBorder() {
    switch (variant) {
      case InputVariant.outline:
        return const OutlineInputBorder(
          borderSide: BorderSide(color: Color(0xFF006A71), width: 1.2),
          borderRadius: BorderRadius.all(Radius.circular(8)),
        );
      case InputVariant.subtle:
        return OutlineInputBorder(
          borderSide: BorderSide.none,
          borderRadius: BorderRadius.circular(8),
        );
      case InputVariant.flushed:
        return const UnderlineInputBorder(
          borderSide: BorderSide(color: Color(0xFF006A71), width: 1.2),
        );
    }
  }

  Color? _getFillColor() {
    if (variant == InputVariant.subtle) {
      return const Color(0xFFF1F5F9); // light gray background
    }
    return null;
  }

  bool get _isFilled => variant == InputVariant.subtle;

  @override
  Widget build(BuildContext context) {
    return TextFormField(
      obscureText: obscureText,
      controller: controller,
      keyboardType: keyboardType,
      validator: validator,
      decoration: InputDecoration(
        floatingLabelBehavior: variant == InputVariant.subtle
            ? FloatingLabelBehavior.never
            : FloatingLabelBehavior.auto,
        filled: _isFilled,
        fillColor: _getFillColor(),
        contentPadding: const EdgeInsets.symmetric(
          vertical: 12,
          horizontal: 12,
        ),
        labelText: label,
        labelStyle: const TextStyle(color: Color(0xFF6F7A88)),
        enabledBorder: _getEnabledBorder(),
        focusedBorder: _getFocusedBorder(),
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
    );
  }
}
