// PATH: lib/features/news/presentation/widgets/news_top_app_bar.dart
import 'package:flutter/material.dart';

import '../../../../app/theme/app_colors.dart';
import '../../../../core/constants/app_sizes.dart';
import '../../../../core/constants/app_typography.dart';

class NewsTopAppBar extends StatelessWidget {
  const NewsTopAppBar({
    super.key,
    required this.brandText,
    required this.onProfileTap,
  });

  final String brandText;
  final VoidCallback onProfileTap;

  @override
  Widget build(BuildContext context) {
    return Row(
      textDirection: TextDirection.rtl,
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: <Widget>[
        Text(
          brandText,
          style: AppTypography.newsTopBrandBold17(),
        ),
        GestureDetector(
          onTap: onProfileTap,
          child: Container(
            width: AppSizes.newsHeaderAvatarSize,
            height: AppSizes.newsHeaderAvatarSize,
            decoration: BoxDecoration(
              color: AppColors.surfaceMuted,
              borderRadius: BorderRadiusDirectional.circular(AppSizes.newsHeaderAvatarSize / 2),
              border: Border.all(color: AppColors.border),
            ),
            child: const Icon(
              Icons.person,
              size: AppSizes.newsHeaderIconSize,
              color: AppColors.muted,
            ),
          ),
        ),
      ],
    );
  }
}