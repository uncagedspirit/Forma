import 'package:flutter/material.dart';
import 'package:forma/core/constants/app_border_radius.dart';
import 'package:forma/core/constants/app_colors.dart';
import 'package:forma/core/constants/app_spacing.dart';
import 'package:forma/core/constants/app_text_styles.dart';

/// A styled text input field for the Forma design system.
///
/// Supports normal and error states with consistent theming.
/// All colors, spacing, and radii are drawn from the design system constants.
class FormaTextField extends StatelessWidget {
  const FormaTextField({
    super.key,
    this.controller,
    this.placeholder,
    this.error,
    this.onChanged,
    this.onSubmitted,
    this.keyboardType,
    this.textInputAction,
    this.autofocus = false,
    this.focusNode,
  });

  final TextEditingController? controller;
  final String? placeholder;
  final String? error;
  final ValueChanged<String>? onChanged;
  final ValueChanged<String>? onSubmitted;
  final TextInputType? keyboardType;
  final TextInputAction? textInputAction;
  final bool autofocus;
  final FocusNode? focusNode;

  @override
  Widget build(BuildContext context) {
    final bool hasError = error != null && error!.isNotEmpty;
    final Color borderColor = hasError ? AppColors.terra : AppColors.line2;

    final OutlineInputBorder border = OutlineInputBorder(
      borderRadius: AppBorderRadius.small,
      borderSide: BorderSide(color: borderColor, width: 1),
    );

    final OutlineInputBorder errorBorder = OutlineInputBorder(
      borderRadius: AppBorderRadius.small,
      borderSide: const BorderSide(color: AppColors.terra, width: 1),
    );

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisSize: MainAxisSize.min,
      children: [
        TextField(
          controller: controller,
          focusNode: focusNode,
          onChanged: onChanged,
          onSubmitted: onSubmitted,
          keyboardType: keyboardType,
          textInputAction: textInputAction,
          autofocus: autofocus,
          style: AppTextStyles.bodyLarge.copyWith(color: AppColors.ink),
          decoration: InputDecoration(
            filled: true,
            fillColor: AppColors.paper,
            hintText: placeholder,
            hintStyle: AppTextStyles.bodyLarge.copyWith(color: AppColors.ink3),
            contentPadding: const EdgeInsets.all(AppSpacing.md),
            border: border,
            enabledBorder: border,
            focusedBorder: border,
            errorBorder: errorBorder,
            focusedErrorBorder: errorBorder,
          ),
        ),
        if (hasError)
          Padding(
            padding: const EdgeInsets.only(top: AppSpacing.sm),
            child: Text(
              error!,
              style: AppTextStyles.bodyMedium.copyWith(
                color: AppColors.terra,
              ),
            ),
          ),
      ],
    );
  }
}
