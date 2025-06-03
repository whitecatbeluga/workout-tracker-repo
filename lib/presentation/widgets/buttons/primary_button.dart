import 'package:flutter/material.dart';

enum ButtonVariant { primary, secondary, danger, white }

class Button extends StatelessWidget {
  const Button({
    super.key,
    required this.label,
    this.onPressed,
    this.prefixIcon,
    this.isLoading = false,
    this.variant = ButtonVariant.primary,
  });

  final String label;
  final void Function()? onPressed;
  final IconData? prefixIcon;
  final bool isLoading;
  final ButtonVariant variant;

  Color _getBackgroundColor() {
    switch (variant) {
      case ButtonVariant.secondary:
        return const Color(0xFF64748B); // slate gray
      case ButtonVariant.danger:
        return const Color(0xFFDC2626); // red
      case ButtonVariant.white:
        return const Color(0xFFFFFFFF); // white
      case ButtonVariant.primary:
      default:
        return const Color(0xFF006A71); // teal
    }
  }

  @override
  Widget build(BuildContext context) {
    final backgroundColor = _getBackgroundColor();

    return SizedBox(
      width: double.infinity,
      height: 50,
      child: ElevatedButton(
        onPressed: isLoading ? null : onPressed,
        style: ElevatedButton.styleFrom(
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
          backgroundColor: backgroundColor,
          elevation: 0,
          textStyle: TextStyle(
            fontWeight: FontWeight.bold,
            fontSize: 16,
            color: backgroundColor == const Color(0xFFFFFFFF)
                ? Colors.black
                : Colors.white,
          ),
        ),
        child: isLoading
            ? const SizedBox(
                width: 24,
                height: 24,
                child: CircularProgressIndicator(
                  color: Colors.white,
                  strokeWidth: 3,
                ),
              )
            : Row(
                mainAxisAlignment: MainAxisAlignment.center,
                mainAxisSize: MainAxisSize.min,
                children: [
                  if (prefixIcon != null) ...[
                    Icon(prefixIcon, color: Colors.white),
                    const SizedBox(width: 8),
                  ],
                  Text(
                    label,
                    style: TextStyle(
                      color: backgroundColor == const Color(0xFFFFFFFF)
                          ? Color(0xFF323232)
                          : Colors.white,
                    ),
                  ),
                ],
              ),
      ),
    );
  }
}
