import 'package:flutter/material.dart';
import '../theme/app_colors.dart';

class AppInput extends StatelessWidget {
  final String label;
  final String placeholder;
  final TextEditingController? controller;
  final IconData? prefixIcon;
  final bool obscureText;
  final TextInputType keyboardType;
  final String? Function(String?)? validator;
  final int? maxLength;
  final bool showPrefixIcon;

  const AppInput({
    super.key,
    required this.label,
    required this.placeholder,
    this.controller,
    this.prefixIcon,
    this.obscureText = false,
    this.keyboardType = TextInputType.text,
    this.validator,
    this.maxLength,
    this.showPrefixIcon = true,
  });

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.only(left: 4, bottom: 8),
          child: Text(
            label.toUpperCase(),
            style: TextStyle(
              fontSize: 11,
              fontWeight: FontWeight.bold,
              color: isDark ? AppColors.slate400 : AppColors.navy,
              letterSpacing: 1.2,
            ),
          ),
        ),
        TextFormField(
          controller: controller,
          obscureText: obscureText,
          keyboardType: keyboardType,
          validator: validator,
          maxLength: maxLength,
          style: TextStyle(
            color: isDark ? Colors.white : AppColors.navy,
            fontWeight: FontWeight.w500,
          ),
          decoration: InputDecoration(
            hintText: placeholder,
            hintStyle: TextStyle(color: AppColors.slate400, fontWeight: FontWeight.normal),
            prefixIcon: showPrefixIcon && prefixIcon != null
                ? Icon(prefixIcon, color: AppColors.slate400, size: 20)
                : null,
            counterText: "",
            filled: true,
            fillColor: isDark ? AppColors.slate800 : Colors.white,
            contentPadding: EdgeInsets.symmetric(
              horizontal: showPrefixIcon && prefixIcon != null ? 12 : 16,
              vertical: 16
            ),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(16),
              borderSide: BorderSide(color: isDark ? AppColors.slate700 : AppColors.slate200),
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(16),
              borderSide: BorderSide(color: isDark ? AppColors.slate700 : AppColors.slate200),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(16),
              borderSide: const BorderSide(color: AppColors.purpleBlue, width: 2),
            ),
          ),
        ),
      ],
    );
  }
}
