import 'package:flutter/material.dart';

enum ButtonVariant { primary, secondary, danger, white }

enum ButtonSize { small, medium, large }

class Button extends StatelessWidget {
  const Button({
    super.key,
    required this.label,
    this.onPressed,
    this.prefixIcon,
    this.isLoading = false,
    this.variant = ButtonVariant.primary,
    this.size = ButtonSize.medium,
  });

  final String label;
  final void Function()? onPressed;
  final IconData? prefixIcon;
  final bool isLoading;
  final ButtonVariant variant;
  final ButtonSize size;

  Color _getBackgroundColor() {
    switch (variant) {
      case ButtonVariant.secondary:
        return const Color(0xFF48A6A7); // slate gray
      case ButtonVariant.danger:
        return const Color(0xFFDB141F); // red
      case ButtonVariant.white:
        return const Color(0xFFFFFFFF); // white
      case ButtonVariant.primary:
        return const Color(0xFF006A71); // teal
    }
  }

  double _getButtonHeight() {
    switch (size) {
      case ButtonSize.large:
        return 50;
      case ButtonSize.medium:
        return 40;
      case ButtonSize.small:
      default:
        return 30;
    }
  }

  @override
  Widget build(BuildContext context) {
    final backgroundColor = _getBackgroundColor();
    final buttonHeight = _getButtonHeight();

    return SizedBox(
      height: buttonHeight,
      child: ElevatedButton(
        onPressed: isLoading ? null : onPressed,
        style: ElevatedButton.styleFrom(
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
          backgroundColor: backgroundColor,
          elevation: 0,
          textStyle: TextStyle(
            fontWeight: FontWeight.bold,
            fontSize: buttonHeight == 50
                ? 18
                : buttonHeight == 40
                ? 16
                : 14,
            color: backgroundColor == const Color(0xFFFFFFFF)
                ? Colors.black
                : Colors.white,
          ),
        ),
        child: isLoading
            ? SizedBox(
                width: buttonHeight == 50
                    ? 18
                    : buttonHeight == 40
                    ? 16
                    : 14,
                height: buttonHeight == 50
                    ? 18
                    : buttonHeight == 40
                    ? 16
                    : 14,
                child: const CircularProgressIndicator(
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
