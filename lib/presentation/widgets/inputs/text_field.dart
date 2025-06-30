import 'package:flutter/material.dart';

enum InputVariant { outline, subtle, flushed }

class InputField extends StatefulWidget {
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
    this.enableLiveValidation = false,
    this.autoValidateMode,
    this.onChanged,
    this.disabled = false,
  });
  final bool disabled;
  final String label;
  final IconData? prefixIcon;
  final IconData? suffixIcon;
  final VoidCallback? onSuffixIconPressed;
  final String? Function(String?)? validator;
  final TextInputType? keyboardType;
  final TextEditingController? controller;
  final bool obscureText;
  final InputVariant variant;
  final bool enableLiveValidation;
  final AutovalidateMode? autoValidateMode;
  final Function(String)? onChanged;

  @override
  State<InputField> createState() => _InputFieldState();
}

class _InputFieldState extends State<InputField> {
  String? _errorMessage;
  bool _hasInteracted = false;

  @override
  void initState() {
    super.initState();
    if (widget.enableLiveValidation && widget.controller != null) {
      widget.controller!.addListener(_onTextChanged);
    }
  }

  @override
  void dispose() {
    if (widget.enableLiveValidation && widget.controller != null) {
      widget.controller!.removeListener(_onTextChanged);
    }
    super.dispose();
  }

  void _onTextChanged() {
    if (!_hasInteracted) {
      setState(() {
        _hasInteracted = true;
      });
    }

    if (_hasInteracted && widget.validator != null) {
      final error = widget.validator!(widget.controller!.text);
      if (_errorMessage != error) {
        setState(() {
          _errorMessage = error;
        });
      }
    }
  }

  void _handleOnChanged(String value) {
    if (widget.enableLiveValidation && !_hasInteracted) {
      setState(() {
        _hasInteracted = true;
      });
    }

    if (widget.onChanged != null) {
      widget.onChanged!(value);
    }
  }

  InputBorder? _getEnabledBorder() {
    final hasError = widget.enableLiveValidation
        ? (_errorMessage != null && _hasInteracted)
        : false;

    switch (widget.variant) {
      case InputVariant.outline:
        return OutlineInputBorder(
          borderSide: BorderSide(
            color: hasError ? Colors.red.shade600 : Color(0xFFCBD5E1),
            width: 1.2,
          ),
          borderRadius: BorderRadius.all(Radius.circular(8)),
        );
      case InputVariant.subtle:
        return OutlineInputBorder(
          borderSide: hasError
              ? BorderSide(color: Colors.red.shade600, width: 1.2)
              : BorderSide.none,
          borderRadius: BorderRadius.circular(8),
        );
      case InputVariant.flushed:
        return UnderlineInputBorder(
          borderSide: BorderSide(
            color: hasError ? Colors.red.shade600 : Color(0xFFCBD5E1),
            width: 1.2,
          ),
        );
    }
  }

  InputBorder? _getFocusedBorder() {
    final hasError = widget.enableLiveValidation
        ? (_errorMessage != null && _hasInteracted)
        : false;

    switch (widget.variant) {
      case InputVariant.outline:
        return OutlineInputBorder(
          borderSide: BorderSide(
            color: hasError ? Colors.red.shade600 : Color(0xFF006A71),
            width: 1.2,
          ),
          borderRadius: BorderRadius.all(Radius.circular(8)),
        );
      case InputVariant.subtle:
        return OutlineInputBorder(
          borderSide: hasError
              ? BorderSide(color: Colors.red.shade600, width: 1.2)
              : BorderSide.none,
          borderRadius: BorderRadius.circular(8),
        );
      case InputVariant.flushed:
        return UnderlineInputBorder(
          borderSide: BorderSide(
            color: hasError ? Colors.red.shade600 : Color(0xFF006A71),
            width: 1.2,
          ),
        );
    }
  }

  InputBorder? _getErrorBorder() {
    switch (widget.variant) {
      case InputVariant.outline:
        return OutlineInputBorder(
          borderSide: BorderSide(color: Colors.red.shade600, width: 1.2),
          borderRadius: BorderRadius.all(Radius.circular(8)),
        );
      case InputVariant.subtle:
        return OutlineInputBorder(
          borderSide: BorderSide(color: Colors.red.shade600, width: 1.2),
          borderRadius: BorderRadius.circular(8),
        );
      case InputVariant.flushed:
        return UnderlineInputBorder(
          borderSide: BorderSide(color: Colors.red.shade600, width: 1.2),
        );
    }
  }

  InputBorder? _getFocusedErrorBorder() {
    switch (widget.variant) {
      case InputVariant.outline:
        return OutlineInputBorder(
          borderSide: BorderSide(color: Colors.red.shade700, width: 1.5),
          borderRadius: BorderRadius.all(Radius.circular(8)),
        );
      case InputVariant.subtle:
        return OutlineInputBorder(
          borderSide: BorderSide(color: Colors.red.shade700, width: 1.5),
          borderRadius: BorderRadius.circular(8),
        );
      case InputVariant.flushed:
        return UnderlineInputBorder(
          borderSide: BorderSide(color: Colors.red.shade700, width: 1.5),
        );
    }
  }

  Color? _getFillColor() {
    if (widget.variant == InputVariant.subtle) {
      return const Color(0xFFF1F5F9); // light gray background
    }
    return null;
  }

  bool get _isFilled => widget.variant == InputVariant.subtle;

  Widget? _buildSuffixIcon() {
    final hasError = widget.enableLiveValidation && _errorMessage != null;
    final isValid =
        widget.enableLiveValidation &&
        _hasInteracted &&
        widget.controller != null &&
        widget.controller!.text.isNotEmpty &&
        _errorMessage == null;

    // Show validation icon if live validation is enabled and field has been interacted with
    if (widget.enableLiveValidation &&
        _hasInteracted &&
        widget.controller != null &&
        widget.controller!.text.isNotEmpty) {
      return Icon(
        isValid ? Icons.check_circle : Icons.error,
        color: isValid ? Colors.green : Colors.red,
      );
    }

    // Show custom suffix icon if provided
    if (widget.suffixIcon != null) {
      return GestureDetector(
        onTap: widget.onSuffixIconPressed,
        child: Icon(widget.suffixIcon, color: Color(0xFF6F7A88)),
      );
    }

    return null;
  }

  @override
  Widget build(BuildContext context) {
    final hasError = widget.enableLiveValidation
        ? _errorMessage != null
        : false;

    return TextFormField(
      style: TextStyle(
        color: widget.disabled ? Color(0xFF6F7A88) : Colors.black,
      ),
      readOnly: widget.disabled,
      obscureText: widget.obscureText,
      controller: widget.controller,
      keyboardType: widget.keyboardType,
      validator: widget.validator,
      autovalidateMode:
          widget.autoValidateMode ??
          (widget.enableLiveValidation
              ? AutovalidateMode.onUserInteraction
              : AutovalidateMode.disabled),
      onChanged: _handleOnChanged,
      decoration: InputDecoration(
        floatingLabelStyle: TextStyle(
          color: _errorMessage != null ? Colors.red : Color(0xFF6F7A88),
        ),
        floatingLabelBehavior: widget.variant == InputVariant.subtle
            ? FloatingLabelBehavior.never
            : FloatingLabelBehavior.auto,
        filled: _isFilled,
        fillColor: _getFillColor(),
        contentPadding: const EdgeInsets.symmetric(
          vertical: 12,
          horizontal: 12,
        ),
        labelText: widget.label,
        labelStyle: TextStyle(
          color: _errorMessage != null ? Colors.red : Color(0xFF6F7A88),
        ),
        errorText: widget.enableLiveValidation && _hasInteracted
            ? _errorMessage
            : null,
        enabledBorder: _getEnabledBorder(),
        focusedBorder: _getFocusedBorder(),
        errorBorder: _getErrorBorder(),
        focusedErrorBorder: _getFocusedErrorBorder(),
        prefixIcon: widget.prefixIcon != null
            ? Icon(widget.prefixIcon, color: Color(0xFF6F7A88))
            : null,
        suffixIcon: _buildSuffixIcon(),
      ),
    );
  }
}

// Example usage
class InputFieldDemo extends StatefulWidget {
  @override
  _InputFieldDemoState createState() => _InputFieldDemoState();
}

class _InputFieldDemoState extends State<InputFieldDemo> {
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _usernameController = TextEditingController();

  String? _validateEmail(String? value) {
    if (value == null || value.isEmpty) {
      return 'Please enter your email';
    }
    if (!RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$').hasMatch(value)) {
      return 'Please enter a valid email';
    }
    return null;
  }

  String? _validatePassword(String? value) {
    if (value == null || value.isEmpty) {
      return 'Please enter your password';
    }
    if (value.length < 8) {
      return 'Password must be at least 8 characters';
    }
    return null;
  }

  String? _validateUsername(String? value) {
    if (value == null || value.isEmpty) {
      return 'Username cannot be empty';
    }
    if (value.length < 3) {
      return 'Username must be at least 3 characters';
    }
    if (!RegExp(r'^[a-zA-Z0-9_]+$').hasMatch(value)) {
      return 'Username can only contain letters, numbers, and underscores';
    }
    return null;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Custom InputField with Live Validation')),
      body: Padding(
        padding: EdgeInsets.all(16.0),
        child: Column(
          children: [
            // Outline variant with live validation
            InputField(
              label: 'Email',
              prefixIcon: Icons.email,
              controller: _emailController,
              validator: _validateEmail,
              enableLiveValidation: true,
              keyboardType: TextInputType.emailAddress,
              variant: InputVariant.outline,
            ),

            SizedBox(height: 16),

            // Subtle variant with live validation
            InputField(
              label: 'Username',
              prefixIcon: Icons.person,
              controller: _usernameController,
              validator: _validateUsername,
              enableLiveValidation: true,
              variant: InputVariant.subtle,
            ),

            SizedBox(height: 16),

            // Flushed variant with live validation
            InputField(
              label: 'Password',
              prefixIcon: Icons.lock,
              controller: _passwordController,
              validator: _validatePassword,
              enableLiveValidation: true,
              obscureText: true,
              variant: InputVariant.flushed,
            ),

            SizedBox(height: 24),

            ElevatedButton(
              onPressed: () {
                // You can still validate manually if needed
                final emailError = _validateEmail(_emailController.text);
                final usernameError = _validateUsername(
                  _usernameController.text,
                );
                final passwordError = _validatePassword(
                  _passwordController.text,
                );

                if (emailError == null &&
                    usernameError == null &&
                    passwordError == null) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(content: Text('All fields are valid!')),
                  );
                } else {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(content: Text('Please fix the errors above')),
                  );
                }
              },
              child: Text('Submit'),
            ),
          ],
        ),
      ),
    );
  }

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    _usernameController.dispose();
    super.dispose();
  }
}
