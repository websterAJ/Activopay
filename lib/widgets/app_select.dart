import 'package:flutter/material.dart';
import '../theme/app_colors.dart';

class AppSelect<T> extends StatelessWidget {
  final String label;
  final String? placeholder;
  final T? value;
  final List<DropdownMenuItem<T>> items;
  final ValueChanged<T?> onChanged;
  final String? Function(T?)? validator;
  final double? width;
  final bool isHeaderLabel;

  const AppSelect({
    super.key,
    required this.label,
    this.placeholder,
    required this.value,
    required this.items,
    required this.onChanged,
    this.validator,
    this.width,
    this.isHeaderLabel = true,
  });

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        if (isHeaderLabel)
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
        SizedBox(
          width: width,
          child: DropdownButtonFormField<T>(
            value: value,
            items: items,
            onChanged: onChanged,
            validator: validator,
            style: TextStyle(
              color: isDark ? Colors.white : AppColors.navy,
              fontWeight: FontWeight.w600,
            ),
            icon: const Icon(Icons.expand_more, color: AppColors.slate400),
            decoration: InputDecoration(
              hintText: placeholder,
              hintStyle: TextStyle(color: AppColors.slate400, fontWeight: FontWeight.normal),
              filled: true,
              fillColor: isDark ? AppColors.slate800 : Colors.white,
              contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
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
        ),
      ],
    );
  }
}
