// PATH: lib/features/home/presentation/widgets/emergency_banner.dart
import 'package:flutter/material.dart';

import '../../../../app/theme/app_colors.dart';
import '../../../../core/constants/app_sizes.dart';
import '../../../../core/constants/app_typography.dart';

class EmergencyBanner extends StatelessWidget {
  const EmergencyBanner({
    super.key,
    required this.title,
    required this.subtitle,
    required this.actionLabel,
    required this.onTap,
  });

  final String title;
  final String subtitle;
  final String actionLabel;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: AppColors.primary,
      borderRadius: BorderRadius.circular(AppSizes.cardRadius),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(AppSizes.cardRadius),
        child: Container(
          constraints: const BoxConstraints(minHeight: AppSizes.bannerHeight),
          padding: const EdgeInsets.symmetric(
            horizontal: AppSizes.screenPadding,
            vertical: AppSizes.widgetSpacing,
          ),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(AppSizes.cardRadius),
            gradient: const LinearGradient(
              colors: <Color>[AppColors.deepPrimary, AppColors.primary],
              begin: Alignment.centerRight,
              end: Alignment.centerLeft,
            ),
          ),
          child: Row(
            textDirection: TextDirection.ltr,
            children: <Widget>[
              const Icon(
                Icons.west,
                color: AppColors.surface,
                size: 24,
              ),
              const SizedBox(width: AppSizes.widgetSpacing),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: <Widget>[
                    Text(
                      title,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: AppTypography.buttonBold15(),
                    ),
                    const SizedBox(height: AppSizes.tinySpacing),
                    Text(
                      subtitle,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: AppTypography.bodyRegular13().copyWith(
                        color: AppColors.surface.withValues(alpha: 0.9),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(width: AppSizes.widgetSpacing),
              Container(
                width: 44,
                height: 44,
                decoration: BoxDecoration(
                  color: AppColors.surface.withValues(alpha: 0.12),
                  shape: BoxShape.circle,
                  border: Border.all(color: AppColors.surface.withValues(alpha: 0.16)),
                ),
                child: const Icon(
                  Icons.volunteer_activism_outlined,
                  color: AppColors.surface,
                  size: 24,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}