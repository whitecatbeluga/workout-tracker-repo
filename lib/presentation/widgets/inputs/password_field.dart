import 'package:flutter/material.dart';
import 'package:workout_tracker_repo/presentation/widgets/inputs/text_field.dart';

class PasswordField extends StatefulWidget {
  const PasswordField({
    super.key,
    required this.label,
    this.validator,
    this.controller,
    this.variant = InputVariant.outline,
  });

  final String label;
  final String? Function(String?)? validator;
  final TextEditingController? controller;
  final InputVariant variant;

  @override
  State<PasswordField> createState() => _PasswordFieldState();
}

class _PasswordFieldState extends State<PasswordField> {
  bool _obscureText = true;

  void _toggleVisibility() {
    setState(() => _obscureText = !_obscureText);
  }

  @override
  Widget build(BuildContext context) {
    return InputField(
      label: widget.label,
      prefixIcon: Icons.lock,
      suffixIcon: _obscureText ? Icons.visibility_off : Icons.visibility,
      onSuffixIconPressed: _toggleVisibility,
      validator: widget.validator,
      controller: widget.controller,
      obscureText: _obscureText,
      keyboardType: TextInputType.visiblePassword,
      variant: widget.variant,
    );
  }
}
