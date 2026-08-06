
import 'package:flutter/material.dart';

import '../../../../app/theme/app_colors.dart';
import '../../../../core/constants/app_sizes.dart';
import '../../../../core/constants/app_typography.dart';

class PlaceholderPage extends StatelessWidget {
  const PlaceholderPage({
    super.key,
    required this.title,
    required this.subtitle,
  });

  final String title;
  final String subtitle;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        child: Center(
          child: Padding(
            padding: const EdgeInsets.all(AppSizes.screenPaddingLarge),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: <Widget>[
                const Icon(
                  Icons.layers_outlined,
                  size: 48,
                  color: AppColors.primary,
                ),
                const SizedBox(height: AppSizes.sectionSpacing),
                Text(
                  title,
                  textAlign: TextAlign.center,
                  style: AppTypography.sectionTitleBold18(),
                ),
                const SizedBox(height: AppSizes.widgetSpacing),
                Text(
                  subtitle,
                  textAlign: TextAlign.center,
                  style: AppTypography.bodyMedium14(),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}