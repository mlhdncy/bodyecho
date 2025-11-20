import 'package:flutter/material.dart';
import '../config/app_colors.dart';
import '../config/app_constants.dart';

enum ButtonStyleType { primary, secondary, outline }

class CustomButton extends StatelessWidget {
  final String title;
  final VoidCallback onPressed;
  final ButtonStyleType style;
  final bool isLoading;
  final bool isDisabled;
  final IconData? icon;

  const CustomButton({
    super.key,
    required this.title,
    required this.onPressed,
    this.style = ButtonStyleType.primary,
    this.isLoading = false,
    this.isDisabled = false,
    this.icon,
  });

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: double.infinity,
      height: AppConstants.buttonHeight,
      child: ElevatedButton(
        onPressed: (isDisabled || isLoading) ? null : onPressed,
        style: ElevatedButton.styleFrom(
          backgroundColor: _backgroundColor,
          foregroundColor: _textColor,
          disabledBackgroundColor: _backgroundColor.withValues(alpha: 0.6),
          elevation: style == ButtonStyleType.outline ? 0 : 0,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(AppConstants.cornerRadius),
            side: style == ButtonStyleType.outline
                ? const BorderSide(color: AppColors.buttonPrimary, width: 1.5)
                : BorderSide.none,
          ),
        ),
        child: isLoading
            ? SizedBox(
                height: 20,
                width: 20,
                child: CircularProgressIndicator(
                  strokeWidth: 2,
                  valueColor: AlwaysStoppedAnimation<Color>(_textColor),
                ),
              )
            : Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  if (icon != null) ...[
                    Icon(icon, size: 20),
                    const SizedBox(width: 8),
                  ],
                  Text(
                    title,
                    style: const TextStyle(
                      fontSize: 17,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ],
              ),
      ),
    );
  }

  Color get _backgroundColor {
    switch (style) {
      case ButtonStyleType.primary:
        return AppColors.buttonPrimary;
      case ButtonStyleType.secondary:
        return AppColors.secondaryTeal;
      case ButtonStyleType.outline:
        return Colors.transparent;
    }
  }

  Color get _textColor {
    switch (style) {
      case ButtonStyleType.primary:
        return Colors.white;
      case ButtonStyleType.secondary:
        return AppColors.textPrimary;
      case ButtonStyleType.outline:
        return AppColors.buttonPrimary;
    }
  }
}
