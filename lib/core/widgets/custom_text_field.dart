// Custom Text Field Widget
// 
// A reusable text field component with variants:
// - Standard text input
// - Email input
// - Password input (with visibility toggle)
// - Phone input
// - Search input (with clear button)
// - Numeric input
// 
// Features:
// - Built-in validation
// - Error state styling
// - Prefix/suffix icons
// - Character counter
// 
// TODO: Customize styles in AppTheme

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../theme/app_theme.dart';

enum TextFieldVariant { standard, email, password, phone, search, numeric }

class CustomTextField extends StatefulWidget {
  final TextEditingController? controller;
  final String? label;
  final String? hint;
  final String? helperText;
  final String? errorText;
  final TextFieldVariant variant;
  final bool enabled;
  final bool readOnly;
  final bool autofocus;
  final int? maxLines;
  final int? minLines;
  final int? maxLength;
  final TextInputAction? textInputAction;
  final ValueChanged<String>? onChanged;
  final ValueChanged<String>? onSubmitted;
  final VoidCallback? onTap;
  final String? Function(String?)? validator;
  final Widget? prefixIcon;
  final Widget? suffixIcon;
  final FocusNode? focusNode;
  final EdgeInsetsGeometry? contentPadding;
  final bool showCounter;
  
  const CustomTextField({
    super.key,
    this.controller,
    this.label,
    this.hint,
    this.helperText,
    this.errorText,
    this.variant = TextFieldVariant.standard,
    this.enabled = true,
    this.readOnly = false,
    this.autofocus = false,
    this.maxLines = 1,
    this.minLines,
    this.maxLength,
    this.textInputAction,
    this.onChanged,
    this.onSubmitted,
    this.onTap,
    this.validator,
    this.prefixIcon,
    this.suffixIcon,
    this.focusNode,
    this.contentPadding,
    this.showCounter = false,
  });
  
  /// Email variant factory constructor
  factory CustomTextField.email({
    Key? key,
    TextEditingController? controller,
    String? label,
    String? hint,
    String? errorText,
    bool enabled = true,
    ValueChanged<String>? onChanged,
    ValueChanged<String>? onSubmitted,
    String? Function(String?)? validator,
  }) {
    return CustomTextField(
      key: key,
      controller: controller,
      label: label ?? 'Email',
      hint: hint ?? 'Enter your email',
      errorText: errorText,
      variant: TextFieldVariant.email,
      enabled: enabled,
      onChanged: onChanged,
      onSubmitted: onSubmitted,
      validator: validator,
    );
  }
  
  /// Phone variant factory constructor
  factory CustomTextField.phone({
    Key? key,
    TextEditingController? controller,
    String? label,
    String? hint,
    String? errorText,
    bool enabled = true,
    ValueChanged<String>? onChanged,
    ValueChanged<String>? onSubmitted,
    String? Function(String?)? validator,
  }) {
    return CustomTextField(
      key: key,
      controller: controller,
      label: label ?? 'Phone',
      hint: hint ?? 'Enter your phone number',
      errorText: errorText,
      variant: TextFieldVariant.phone,
      enabled: enabled,
      onChanged: onChanged,
      onSubmitted: onSubmitted,
      validator: validator,
    );
  }
  
  /// Password variant factory constructor
  factory CustomTextField.password({
    Key? key,
    TextEditingController? controller,
    String? label,
    String? hint,
    String? errorText,
    bool enabled = true,
    ValueChanged<String>? onChanged,
    ValueChanged<String>? onSubmitted,
    String? Function(String?)? validator,
  }) {
    return CustomTextField(
      key: key,
      controller: controller,
      label: label ?? 'Password',
      hint: hint ?? 'Enter your password',
      errorText: errorText,
      variant: TextFieldVariant.password,
      enabled: enabled,
      onChanged: onChanged,
      onSubmitted: onSubmitted,
      validator: validator,
    );
  }
  
  /// Search variant factory constructor
  factory CustomTextField.search({
    Key? key,
    TextEditingController? controller,
    String? hint,
    bool enabled = true,
    ValueChanged<String>? onChanged,
    ValueChanged<String>? onSubmitted,
    bool autofocus = false,
  }) {
    return CustomTextField(
      key: key,
      controller: controller,
      hint: hint ?? 'Search...',
      variant: TextFieldVariant.search,
      enabled: enabled,
      onChanged: onChanged,
      onSubmitted: onSubmitted,
      autofocus: autofocus,
    );
  }
  
  @override
  State<CustomTextField> createState() => _CustomTextFieldState();
}

class _CustomTextFieldState extends State<CustomTextField> {
  bool _obscureText = true;
  late TextEditingController _controller;
  
  @override
  void initState() {
    super.initState();
    _controller = widget.controller ?? TextEditingController();
  }
  
  @override
  void dispose() {
    if (widget.controller == null) {
      _controller.dispose();
    }
    super.dispose();
  }
  
  @override
  Widget build(BuildContext context) {
    return TextFormField(
      controller: _controller,
      focusNode: widget.focusNode,
      enabled: widget.enabled,
      readOnly: widget.readOnly,
      autofocus: widget.autofocus,
      maxLines: widget.variant == TextFieldVariant.password ? 1 : widget.maxLines,
      minLines: widget.minLines,
      maxLength: widget.maxLength,
      obscureText: widget.variant == TextFieldVariant.password && _obscureText,
      keyboardType: _getKeyboardType(),
      textInputAction: widget.textInputAction,
      inputFormatters: _getInputFormatters(),
      decoration: InputDecoration(
        labelText: widget.label,
        hintText: widget.hint ?? _getDefaultHint(),
        helperText: widget.helperText,
        errorText: widget.errorText,
        prefixIcon: widget.prefixIcon ?? _getDefaultPrefixIcon(),
        suffixIcon: _getSuffixIcon(),
        contentPadding: widget.contentPadding ?? 
            const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
        counterText: widget.showCounter ? null : '',
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(AppTheme.radiusMd),
          borderSide: const BorderSide(color: AppTheme.borderColor),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(AppTheme.radiusMd),
          borderSide: const BorderSide(color: AppTheme.borderColor),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(AppTheme.radiusMd),
          borderSide: BorderSide(color: AppTheme.primaryColor, width: 2),
        ),
        errorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(AppTheme.radiusMd),
          borderSide: const BorderSide(color: AppTheme.errorColor),
        ),
        focusedErrorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(AppTheme.radiusMd),
          borderSide: const BorderSide(color: AppTheme.errorColor, width: 2),
        ),
        disabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(AppTheme.radiusMd),
          borderSide: BorderSide(color: AppTheme.borderColor.withValues(alpha: 0.5)),
        ),
        filled: true,
        fillColor: widget.enabled ? Colors.white : Colors.grey[100],
      ),
      onChanged: widget.onChanged,
      onFieldSubmitted: widget.onSubmitted,
      onTap: widget.onTap,
      validator: widget.validator,
    );
  }
  
  TextInputType _getKeyboardType() {
    switch (widget.variant) {
      case TextFieldVariant.email:
        return TextInputType.emailAddress;
      case TextFieldVariant.password:
        return TextInputType.visiblePassword;
      case TextFieldVariant.phone:
        return TextInputType.phone;
      case TextFieldVariant.numeric:
        return TextInputType.number;
      case TextFieldVariant.search:
      case TextFieldVariant.standard:
        return TextInputType.text;
    }
  }
  
  List<TextInputFormatter>? _getInputFormatters() {
    switch (widget.variant) {
      case TextFieldVariant.phone:
        return [FilteringTextInputFormatter.allow(RegExp(r'[\d\s\-\+\(\)]'))];
      case TextFieldVariant.numeric:
        return [FilteringTextInputFormatter.allow(RegExp(r'[\d\.]'))];
      default:
        return null;
    }
  }
  
  String? _getDefaultHint() {
    switch (widget.variant) {
      case TextFieldVariant.email:
        return 'Enter your email';
      case TextFieldVariant.password:
        return 'Enter your password';
      case TextFieldVariant.phone:
        return 'Enter your phone number';
      case TextFieldVariant.search:
        return 'Search...';
      case TextFieldVariant.numeric:
        return 'Enter a number';
      case TextFieldVariant.standard:
        return null;
    }
  }
  
  Widget? _getDefaultPrefixIcon() {
    switch (widget.variant) {
      case TextFieldVariant.email:
        return const Icon(Icons.email_outlined);
      case TextFieldVariant.password:
        return const Icon(Icons.lock_outlined);
      case TextFieldVariant.phone:
        return const Icon(Icons.phone_outlined);
      case TextFieldVariant.search:
        return const Icon(Icons.search);
      case TextFieldVariant.numeric:
        return const Icon(Icons.numbers);
      case TextFieldVariant.standard:
        return null;
    }
  }
  
  Widget? _getSuffixIcon() {
    if (widget.suffixIcon != null) return widget.suffixIcon;
    
    switch (widget.variant) {
      case TextFieldVariant.password:
        return IconButton(
          icon: Icon(
            _obscureText ? Icons.visibility_outlined : Icons.visibility_off_outlined,
          ),
          onPressed: () {
            setState(() {
              _obscureText = !_obscureText;
            });
          },
          tooltip: _obscureText ? 'Show password' : 'Hide password',
        );
      case TextFieldVariant.search:
        return _controller.text.isNotEmpty
            ? IconButton(
                icon: const Icon(Icons.clear),
                onPressed: () {
                  _controller.clear();
                  widget.onChanged?.call('');
                },
                tooltip: 'Clear',
              )
            : null;
      default:
        return null;
    }
  }
}

/// Convenience constructors for common field types
class EmailTextField extends StatelessWidget {
  final TextEditingController? controller;
  final FocusNode? focusNode;
  final String? label;
  final String? Function(String?)? validator;
  final ValueChanged<String>? onChanged;
  final TextInputAction? textInputAction;
  
  const EmailTextField({
    super.key,
    this.controller,
    this.focusNode,
    this.label = 'Email',
    this.validator,
    this.onChanged,
    this.textInputAction,
  });
  
  @override
  Widget build(BuildContext context) {
    return CustomTextField(
      controller: controller,
      focusNode: focusNode,
      label: label,
      variant: TextFieldVariant.email,
      validator: validator,
      onChanged: onChanged,
      textInputAction: textInputAction ?? TextInputAction.next,
    );
  }
}

class PasswordTextField extends StatelessWidget {
  final TextEditingController? controller;
  final FocusNode? focusNode;
  final String? label;
  final String? Function(String?)? validator;
  final ValueChanged<String>? onChanged;
  final TextInputAction? textInputAction;
  
  const PasswordTextField({
    super.key,
    this.controller,
    this.focusNode,
    this.label = 'Password',
    this.validator,
    this.onChanged,
    this.textInputAction,
  });
  
  @override
  Widget build(BuildContext context) {
    return CustomTextField(
      controller: controller,
      focusNode: focusNode,
      label: label,
      variant: TextFieldVariant.password,
      validator: validator,
      onChanged: onChanged,
      textInputAction: textInputAction ?? TextInputAction.done,
    );
  }
}

/// Search TextField optimized for AppBar usage
/// Has proper height, padding, and contrast for visibility
/// Supports custom colors for use on dark/colored backgrounds
class SearchTextField extends StatelessWidget {
  final TextEditingController? controller;
  final String? hint;
  final ValueChanged<String>? onChanged;
  final ValueChanged<String>? onSubmitted;
  final bool autofocus;
  final Color? fillColor;
  final Color? textColor;
  final Color? hintColor;
  final Color? iconColor;
  
  const SearchTextField({
    super.key,
    this.controller,
    this.hint,
    this.onChanged,
    this.onSubmitted,
    this.autofocus = false,
    this.fillColor,
    this.textColor,
    this.hintColor,
    this.iconColor, required IconButton suffixIcon,
  });
  
  @override
  Widget build(BuildContext context) {
    final effectiveTextColor = textColor ?? AppTheme.textPrimary;
    final effectiveHintColor = hintColor ?? AppTheme.textTertiary;
    final effectiveIconColor = iconColor ?? AppTheme.textSecondary;
    final effectiveFillColor = fillColor ?? Colors.white;
    
    // Use a Container to ensure minimum height and proper sizing in AppBar
    return Container(
      height: 48,
      constraints: const BoxConstraints(minHeight: 48),
      child: TextField(
        controller: controller,
        autofocus: autofocus,
        textInputAction: TextInputAction.search,
        onChanged: onChanged,
        onSubmitted: onSubmitted,
        style: TextStyle(
          fontSize: 16,
          color: effectiveTextColor,
        ),
        decoration: InputDecoration(
          hintText: hint ?? 'Search...',
          hintStyle: TextStyle(
            color: effectiveHintColor,
            fontSize: 16,
          ),
          prefixIcon: Icon(
            Icons.search,
            color: effectiveIconColor,
          ),
          suffixIcon: controller != null && controller!.text.isNotEmpty
              ? IconButton(
                  icon: Icon(Icons.clear, color: effectiveIconColor),
                  onPressed: () {
                    controller?.clear();
                    onChanged?.call('');
                  },
                )
              : null,
          filled: true,
          fillColor: effectiveFillColor,
          contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(AppTheme.radiusMd),
            borderSide: BorderSide.none,
          ),
          enabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(AppTheme.radiusMd),
            borderSide: BorderSide.none,
          ),
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(AppTheme.radiusMd),
            borderSide: BorderSide(color: effectiveTextColor, width: 2),
          ),
        ),
      ),
    );
  }
}

class PhoneTextField extends StatelessWidget {
  final TextEditingController? controller;
  final String? label;
  final String? Function(String?)? validator;
  final ValueChanged<String>? onChanged;
  
  const PhoneTextField({
    super.key,
    this.controller,
    this.label = 'Phone Number',
    this.validator,
    this.onChanged,
  });
  
  @override
  Widget build(BuildContext context) {
    return CustomTextField(
      controller: controller,
      label: label,
      variant: TextFieldVariant.phone,
      validator: validator,
      onChanged: onChanged,
      textInputAction: TextInputAction.next,
    );
  }
}

class NumericTextField extends StatelessWidget {
  final TextEditingController? controller;
  final String? label;
  final String? Function(String?)? validator;
  final ValueChanged<String>? onChanged;
  
  const NumericTextField({
    super.key,
    this.controller,
    this.label,
    this.validator,
    this.onChanged,
  });
  
  @override
  Widget build(BuildContext context) {
    return CustomTextField(
      controller: controller,
      label: label,
      variant: TextFieldVariant.numeric,
      validator: validator,
      onChanged: onChanged,
    );
  }
}
