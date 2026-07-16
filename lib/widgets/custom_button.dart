import 'package:flutter/material.dart';

enum CustomButtonType { primary, secondary, danger }

class CustomButton extends StatelessWidget {
  final String text;
  final VoidCallback? onPressed;
  final bool isLoading;
  final CustomButtonType type;
  final IconData? icon;

  const CustomButton({
    super.key,
    required this.text,
    this.onPressed,
    this.isLoading = false,
    this.type = CustomButtonType.primary,
    this.icon,
  });

  @override
  Widget build(BuildContext context) {
    Color backgroundColor;
    Color textColor;
    BorderSide borderSide = BorderSide.none;

    switch (type) {
      case CustomButtonType.primary:
        backgroundColor = const Color(0xFF2E5B94);
        textColor = Colors.white;
        break;
      case CustomButtonType.secondary:
        backgroundColor = Colors.transparent;
        textColor = const Color(0xFF2E5B94);
        borderSide = const BorderSide(color: Color(0xFF2E5B94), width: 1.5);
        break;
      case CustomButtonType.danger:
        backgroundColor = Colors.red[600]!;
        textColor = Colors.white;
        break;
    }

    // Se estiver desativado
    final bool isEnabled = onPressed != null && !isLoading;
    if (!isEnabled && type != CustomButtonType.secondary) {
      backgroundColor = Colors.grey[300]!;
      textColor = Colors.grey[600]!;
    } else if (!isEnabled && type == CustomButtonType.secondary) {
      borderSide = BorderSide(color: Colors.grey[300]!, width: 1.5);
      textColor = Colors.grey[400]!;
    }

    return SizedBox(
      width: double.infinity,
      height: 50,
      child: ElevatedButton(
        style: ElevatedButton.styleFrom(
          backgroundColor: backgroundColor,
          foregroundColor: textColor,
          elevation: type == CustomButtonType.primary && isEnabled ? 2 : 0,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
            side: borderSide,
          ),
          shadowColor: const Color(0xFF2E5B94).withOpacity(0.3),
        ),
        onPressed: isEnabled ? onPressed : null,
        child: isLoading
            ? SizedBox(
                height: 20,
                width: 20,
                child: CircularProgressIndicator(
                  strokeWidth: 2.5,
                  valueColor: AlwaysStoppedAnimation<Color>(
                    type == CustomButtonType.secondary ? const Color(0xFF2E5B94) : Colors.white,
                  ),
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
                    text,
                    style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      letterSpacing: 0.5,
                    ),
                  ),
                ],
              ),
      ),
    );
  }
}
