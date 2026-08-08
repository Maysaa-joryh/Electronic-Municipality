// PATH: lib/features/home/presentation/widgets/home_search_bar.dart
import 'package:flutter/material.dart';

import '../../../../app/theme/app_colors.dart';
import '../../../../core/constants/app_sizes.dart';
import '../../../../core/constants/app_typography.dart';

class HomeSearchBar extends StatelessWidget {
  const HomeSearchBar({
    super.key,
    required this.controller,
    required this.validator,
    required this.hintText,
    required this.onSubmitted,
  });

  final TextEditingController controller;
  final FormFieldValidator<String> validator;
  final String hintText;
  final ValueChanged<String> onSubmitted;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: AppSizes.searchBarHeight,
      child: TextFormField(
        controller: controller,
        validator: validator,
        onFieldSubmitted: onSubmitted,
        textAlign: TextAlign.right,
        textDirection: TextDirection.rtl,
        style: AppTypography.bodyMedium14().copyWith(color: AppColors.text),
        decoration: InputDecoration(
          filled: true,
          fillColor: AppColors.surface,
          contentPadding: const EdgeInsets.symmetric(
            horizontal: AppSizes.screenPadding,
            vertical: 0,
          ),
          hintText: hintText,
          hintStyle: AppTypography.bodyRegular13(),
          prefixIcon: const Icon(
            Icons.search_rounded,
            color: AppColors.muted,
            size: AppSizes.iconSizeMedium,
          ),
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(AppSizes.searchBarRadius),
            borderSide: const BorderSide(color: AppColors.border),
          ),
          enabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(AppSizes.searchBarRadius),
            borderSide: const BorderSide(color: AppColors.border),
          ),
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(AppSizes.searchBarRadius),
            borderSide: const BorderSide(color: AppColors.primary, width: 1.2),
          ),
        ),
      ),
    );
  }
}