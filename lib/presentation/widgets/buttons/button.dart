import 'package:flutter/material.dart';
import 'package:workout_tracker_repo/theme/color.dart';

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
    this.fullWidth = false,
  });

  final String label;
  final void Function()? onPressed;
  final IconData? prefixIcon;
  final bool isLoading;
  final ButtonVariant variant;
  final ButtonSize size;
  final bool fullWidth;

  Color _getBackgroundColor() {
    switch (variant) {
      case ButtonVariant.secondary:
        return const Color(CustomColor.secondary); // secondary
      case ButtonVariant.danger:
        return const Color(CustomColor.red); // danger
      case ButtonVariant.white:
        return const Color(CustomColor.white); // white
      case ButtonVariant.primary:
      default:
        return const Color(CustomColor.defaultColor);
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
      width: fullWidth ? double.infinity : null,
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
                    Icon(
                      prefixIcon,
                      color: backgroundColor == Colors.white
                          ? const Color(0xFF323232)
                          : Colors.white,
                    ),
                    const SizedBox(width: 8),
                  ],
                  Text(
                    label,
                    style: TextStyle(
                      color: backgroundColor == Colors.white
                          ? const Color(0xFF323232)
                          : Colors.white,
                    ),
                  ),
                ],
              ),
      ),
    );
  }
}
