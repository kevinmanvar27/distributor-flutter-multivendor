// Dynamic Button Widget
// 
// A reusable button component that supports multiple variants:
// - Filled (primary, secondary, success, danger)
// - Outlined
// - Text
// 
// Features:
// - Loading state with spinner
// - Icon support (leading/trailing)
// - Customizable size, color, radius
// 
// TODO: Add more button variants as needed

import 'package:flutter/material.dart';
import '../theme/app_theme.dart';

enum ButtonVariant { filled, outlined, text }
enum ButtonSize { small, medium, large }
enum ButtonColor { primary, secondary, success, danger, warning }

class DynamicButton extends StatelessWidget {
  final String text;
  final VoidCallback? onPressed;
  final ButtonVariant variant;
  final ButtonSize size;
  final ButtonColor color;
  final bool isLoading;
  final bool isDisabled;
  final bool isFullWidth;
  final IconData? leadingIcon;
  final IconData? trailingIcon;
  final double? borderRadius;
  final EdgeInsetsGeometry? padding;
  final TextStyle? textStyle;
  
  const DynamicButton({
    super.key,
    required this.text,
    this.onPressed,
    this.variant = ButtonVariant.filled,
    this.size = ButtonSize.medium,
    this.color = ButtonColor.primary,
    this.isLoading = false,
    this.isDisabled = false,
    this.isFullWidth = false,
    this.leadingIcon,
    this.trailingIcon,
    this.borderRadius,
    this.padding,
    this.textStyle,
  });
  
  @override
  Widget build(BuildContext context) {
    final buttonColor = _getColor();
    final buttonPadding = padding ?? _getPadding();
    final radius = borderRadius ?? AppTheme.radiusMd;
    final isEnabled = !isDisabled && !isLoading && onPressed != null;
    
    Widget buttonChild = Row(
      mainAxisSize: isFullWidth ? MainAxisSize.max : MainAxisSize.min,
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        if (isLoading) ...[
          SizedBox(
            width: _getIconSize(),
            height: _getIconSize(),
            child: CircularProgressIndicator(
              strokeWidth: 2,
              valueColor: AlwaysStoppedAnimation<Color>(
                variant == ButtonVariant.filled 
                    ? Colors.white 
                    : buttonColor,
              ),
            ),
          ),
          const SizedBox(width: 8),
        ] else if (leadingIcon != null) ...[
          Icon(leadingIcon, size: _getIconSize()),
          const SizedBox(width: 8),
        ],
        Text(
          text,
          style: textStyle ?? _getTextStyle(),
        ),
        if (trailingIcon != null && !isLoading) ...[
          const SizedBox(width: 8),
          Icon(trailingIcon, size: _getIconSize()),
        ],
      ],
    );
    
    switch (variant) {
      case ButtonVariant.filled:
        return SizedBox(
          width: isFullWidth ? double.infinity : null,
          child: ElevatedButton(
            onPressed: isEnabled ? onPressed : null,
            style: ElevatedButton.styleFrom(
              backgroundColor: buttonColor,
              foregroundColor: Colors.white,
              padding: buttonPadding,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(radius),
              ),
              elevation: isEnabled ? 2 : 0,
              disabledBackgroundColor: buttonColor.withValues(alpha: 0.5),
              disabledForegroundColor: Colors.white70,
            ),
            child: buttonChild,
          ),
        );
        
      case ButtonVariant.outlined:
        return SizedBox(
          width: isFullWidth ? double.infinity : null,
          child: OutlinedButton(
            onPressed: isEnabled ? onPressed : null,
            style: OutlinedButton.styleFrom(
              foregroundColor: buttonColor,
              padding: buttonPadding,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(radius),
              ),
              side: BorderSide(
                color: isEnabled ? buttonColor : buttonColor.withValues(alpha: 0.5),
                width: 1.5,
              ),
            ),
            child: buttonChild,
          ),
        );
        
      case ButtonVariant.text:
        return SizedBox(
          width: isFullWidth ? double.infinity : null,
          child: TextButton(
            onPressed: isEnabled ? onPressed : null,
            style: TextButton.styleFrom(
              foregroundColor: buttonColor,
              padding: buttonPadding,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(radius),
              ),
            ),
            child: buttonChild,
          ),
        );
    }
  }
  
  Color _getColor() {
    switch (color) {
      case ButtonColor.primary:
        return AppTheme.primaryColor;
      case ButtonColor.secondary:
        return AppTheme.secondaryColor;
      case ButtonColor.success:
        return AppTheme.successColor;
      case ButtonColor.danger:
        return AppTheme.errorColor;
      case ButtonColor.warning:
        return AppTheme.warningColor;
    }
  }
  
  EdgeInsetsGeometry _getPadding() {
    switch (size) {
      case ButtonSize.small:
        return const EdgeInsets.symmetric(horizontal: 12, vertical: 8);
      case ButtonSize.medium:
        return const EdgeInsets.symmetric(horizontal: 16, vertical: 12);
      case ButtonSize.large:
        return const EdgeInsets.symmetric(horizontal: 24, vertical: 16);
    }
  }
  
  double _getIconSize() {
    switch (size) {
      case ButtonSize.small:
        return 16;
      case ButtonSize.medium:
        return 20;
      case ButtonSize.large:
        return 24;
    }
  }
  
  TextStyle _getTextStyle() {
    switch (size) {
      case ButtonSize.small:
        return const TextStyle(fontSize: 12, fontWeight: FontWeight.w600);
      case ButtonSize.medium:
        return const TextStyle(fontSize: 14, fontWeight: FontWeight.w600);
      case ButtonSize.large:
        return const TextStyle(fontSize: 16, fontWeight: FontWeight.w600);
    }
  }
}

/// Icon-only button variant
class DynamicIconButton extends StatelessWidget {
  final IconData icon;
  final VoidCallback? onPressed;
  final ButtonColor color;
  final double size;
  final bool isLoading;
  final String? tooltip;
  final Color? backgroundColor;
  
  const DynamicIconButton({
    super.key,
    required this.icon,
    this.onPressed,
    this.color = ButtonColor.primary,
    this.size = 48,
    this.isLoading = false,
    this.tooltip,
    this.backgroundColor,
  });
  
  @override
  Widget build(BuildContext context) {
    final buttonColor = _getColor();
    
    Widget button = Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        color: backgroundColor ?? buttonColor.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(size / 2),
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: isLoading ? null : onPressed,
          borderRadius: BorderRadius.circular(size / 2),
          child: Center(
            child: isLoading
                ? SizedBox(
                    width: size * 0.5,
                    height: size * 0.5,
                    child: CircularProgressIndicator(
                      strokeWidth: 2,
                      valueColor: AlwaysStoppedAnimation<Color>(buttonColor),
                    ),
                  )
                : Icon(
                    icon,
                    color: buttonColor,
                    size: size * 0.5,
                  ),
          ),
        ),
      ),
    );
    
    if (tooltip != null) {
      return Tooltip(
        message: tooltip!,
        child: button,
      );
    }
    
    return button;
  }
  
  Color _getColor() {
    switch (color) {
      case ButtonColor.primary:
        return AppTheme.primaryColor;
      case ButtonColor.secondary:
        return AppTheme.secondaryColor;
      case ButtonColor.success:
        return AppTheme.successColor;
      case ButtonColor.danger:
        return AppTheme.errorColor;
      case ButtonColor.warning:
        return AppTheme.warningColor;
    }
  }
}
