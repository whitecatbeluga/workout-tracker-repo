import 'package:flutter/material.dart';
import 'package:workout_tracker_repo/theme/color.dart';

enum ButtonVariant { primary, secondary, danger, white, gray }

enum ButtonSize { small, medium, large }

class Button extends StatelessWidget {
  const Button({
    super.key,
    required this.label,
    this.onPressed,
    this.prefixIcon,
    this.suffixIcon,
    this.isLoading = false,
    this.variant = ButtonVariant.primary,
    this.size = ButtonSize.medium,
    this.fullWidth = false,
    // Custom overrides
    this.backgroundColor,
    this.textColor,
    this.borderColor,
    this.borderWidth,
    this.borderRadius,
    this.height,
    this.width,
    this.fontSize,
    this.fontWeight,
    this.padding,
    this.elevation,
    this.gradient,
    this.textStyle,
  });

  final String label;
  final void Function()? onPressed;
  final IconData? prefixIcon;
  final IconData? suffixIcon;
  final bool isLoading;
  final ButtonVariant variant;
  final ButtonSize size;
  final bool fullWidth;

  // Custom overrides
  final Color? backgroundColor;
  final Color? textColor;
  final Color? borderColor;
  final double? borderWidth;
  final double? borderRadius;
  final double? height;
  final double? width;
  final double? fontSize;
  final FontWeight? fontWeight;
  final EdgeInsetsGeometry? padding;
  final double? elevation;
  final Gradient? gradient;
  final TextStyle? textStyle;

  ButtonTheme get _theme => ButtonTheme(
    backgroundColor: backgroundColor ?? _variantBackgroundColor,
    textColor: textColor ?? _variantTextColor,
    borderColor: borderColor,
    borderWidth: borderWidth ?? 0,
    borderRadius: borderRadius ?? 8,
    height: height ?? _sizeHeight,
    width: fullWidth ? double.infinity : width,
    fontSize: fontSize ?? _sizeFontSize,
    fontWeight: fontWeight ?? FontWeight.bold,
    padding: padding ?? _sizePadding,
    elevation: elevation ?? 0,
    gradient: gradient,
    textStyle: textStyle,
  );

  Color get _variantBackgroundColor {
    switch (variant) {
      case ButtonVariant.primary:
        return const Color(CustomColor.defaultColor);
      case ButtonVariant.secondary:
        return const Color(CustomColor.secondary);
      case ButtonVariant.danger:
        return const Color(CustomColor.red);
      case ButtonVariant.white:
        return const Color(CustomColor.white);
      case ButtonVariant.gray:
        return const Color(CustomColor.gray);
    }
  }

  Color get _variantTextColor {
    return _variantBackgroundColor == const Color(CustomColor.white)
        ? const Color(0xFF323232)
        : Colors.white;
  }

  double get _sizeHeight {
    switch (size) {
      case ButtonSize.small:
        return 30;
      case ButtonSize.medium:
        return 40;
      case ButtonSize.large:
        return 50;
    }
  }

  double get _sizeFontSize {
    switch (size) {
      case ButtonSize.small:
        return 14;
      case ButtonSize.medium:
        return 16;
      case ButtonSize.large:
        return 18;
    }
  }

  EdgeInsetsGeometry get _sizePadding {
    switch (size) {
      case ButtonSize.small:
        return const EdgeInsets.symmetric(horizontal: 16, vertical: 8);
      case ButtonSize.medium:
        return const EdgeInsets.symmetric(horizontal: 20, vertical: 8);
      case ButtonSize.large:
        return const EdgeInsets.symmetric(horizontal: 24, vertical: 8);
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = _theme;

    Widget child = isLoading
        ? _LoadingIndicator(color: theme.textColor, size: theme.fontSize)
        : _ButtonContent(
            label: label,
            prefixIcon: prefixIcon,
            suffixIcon: suffixIcon,
            theme: theme,
          );

    if (theme.gradient != null) {
      return _GradientButton(
        theme: theme,
        child: child,
        onPressed: isLoading ? null : onPressed,
      );
    }

    return SizedBox(
      height: theme.height,
      width: theme.width,
      child: ElevatedButton(
        onPressed: isLoading ? null : onPressed,
        style: ElevatedButton.styleFrom(
          backgroundColor: theme.backgroundColor,
          elevation: theme.elevation,
          padding: theme.padding,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(theme.borderRadius),
            side: theme.borderWidth > 0
                ? BorderSide(
                    color: theme.borderColor!,
                    width: theme.borderWidth,
                  )
                : BorderSide.none,
          ),
        ),
        child: child,
      ),
    );
  }
}

class ButtonTheme {
  const ButtonTheme({
    required this.backgroundColor,
    required this.textColor,
    required this.borderRadius,
    required this.height,
    required this.fontSize,
    required this.fontWeight,
    required this.padding,
    required this.elevation,
    required this.borderWidth,
    this.borderColor,
    this.width,
    this.gradient,
    this.textStyle,
  });

  final Color backgroundColor;
  final Color textColor;
  final Color? borderColor;
  final double borderWidth;
  final double borderRadius;
  final double height;
  final double? width;
  final double fontSize;
  final FontWeight fontWeight;
  final EdgeInsetsGeometry padding;
  final double elevation;
  final Gradient? gradient;
  final TextStyle? textStyle;
}

class _ButtonContent extends StatelessWidget {
  const _ButtonContent({
    required this.label,
    required this.theme,
    this.prefixIcon,
    this.suffixIcon,
  });

  final String label;
  final IconData? prefixIcon;
  final IconData? suffixIcon;
  final ButtonTheme theme;

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      mainAxisSize: MainAxisSize.min,
      children: [
        if (prefixIcon != null) ...[
          Icon(prefixIcon, color: theme.textColor, size: theme.fontSize + 2),
          const SizedBox(width: 8),
        ],
        Text(
          label,
          style:
              theme.textStyle?.copyWith(color: theme.textColor) ??
              TextStyle(
                color: theme.textColor,
                fontSize: theme.fontSize,
                fontWeight: theme.fontWeight,
              ),
        ),
        if (suffixIcon != null) ...[
          const SizedBox(width: 8),
          Icon(suffixIcon, color: theme.textColor, size: theme.fontSize + 2),
        ],
      ],
    );
  }
}

class _LoadingIndicator extends StatelessWidget {
  const _LoadingIndicator({required this.color, required this.size});

  final Color color;
  final double size;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: size,
      height: size,
      child: CircularProgressIndicator(color: color, strokeWidth: 2.5),
    );
  }
}

class _GradientButton extends StatelessWidget {
  const _GradientButton({
    required this.theme,
    required this.child,
    required this.onPressed,
  });

  final ButtonTheme theme;
  final Widget child;
  final VoidCallback? onPressed;

  @override
  Widget build(BuildContext context) {
    return Container(
      height: theme.height,
      width: theme.width,
      decoration: BoxDecoration(
        gradient: theme.gradient,
        borderRadius: BorderRadius.circular(theme.borderRadius),
        border: theme.borderWidth > 0
            ? Border.all(color: theme.borderColor!, width: theme.borderWidth)
            : null,
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: onPressed,
          borderRadius: BorderRadius.circular(theme.borderRadius),
          child: Container(padding: theme.padding, child: child),
        ),
      ),
    );
  }
}

// Convenience constructors
extension ButtonStyles on Button {
  static Button outlined({
    required String label,
    VoidCallback? onPressed,
    IconData? prefixIcon,
    IconData? suffixIcon,
    bool isLoading = false,
    ButtonSize size = ButtonSize.medium,
    bool fullWidth = false,
    Color borderColor = Colors.blue,
    Color textColor = Colors.blue,
  }) {
    return Button(
      label: label,
      onPressed: onPressed,
      prefixIcon: prefixIcon,
      suffixIcon: suffixIcon,
      isLoading: isLoading,
      size: size,
      fullWidth: fullWidth,
      backgroundColor: Colors.transparent,
      textColor: textColor,
      borderColor: borderColor,
      borderWidth: 1.5,
    );
  }

  static Button gradient({
    required String label,
    required Gradient gradient,
    VoidCallback? onPressed,
    IconData? prefixIcon,
    IconData? suffixIcon,
    bool isLoading = false,
    ButtonSize size = ButtonSize.medium,
    bool fullWidth = false,
  }) {
    return Button(
      label: label,
      onPressed: onPressed,
      prefixIcon: prefixIcon,
      suffixIcon: suffixIcon,
      isLoading: isLoading,
      size: size,
      fullWidth: fullWidth,
      gradient: gradient,
    );
  }
}
