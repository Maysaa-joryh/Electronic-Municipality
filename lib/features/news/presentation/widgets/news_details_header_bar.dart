// PATH: lib/features/news/presentation/widgets/news_details_header_bar.dart
import 'package:flutter/material.dart';

import '../../../../app/theme/app_colors.dart';
import '../../../../core/constants/app_sizes.dart';
import '../../../../core/constants/app_typography.dart';
import '../models/news_details_models.dart';

class NewsDetailsHeaderBar extends StatelessWidget {
  const NewsDetailsHeaderBar({
    super.key,
    required this.data,
    required this.onBackTap,
  });

  final NewsDetailsHeaderData data;
  final VoidCallback onBackTap;

  @override
  Widget build(BuildContext context) {
    return Container(
      height: AppSizes.newsDetailsHeaderHeight,
      padding: const EdgeInsetsDirectional.symmetric(
        horizontal: AppSizes.widgetSpacing,
      ),
      decoration: BoxDecoration(
        color: AppColors.deepPrimary,
        borderRadius: BorderRadiusDirectional.circular(
          AppSizes.newsCardRadius,
        ),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: <Widget>[
          // زر العودة الاحترافي مع تأثير اللمس وتوسيع مساحة الضغط
          Material(
            color: Colors.transparent,
            borderRadius: BorderRadius.circular(20),
            child: InkWell(
              onTap: onBackTap,
              borderRadius: BorderRadius.circular(20),
              splashColor: AppColors.surface.withValues(alpha: 0.15),
              highlightColor: Colors.transparent,
              child: Container(
                width: 38,
                height: 38,
                alignment: Alignment.center,
                child: const Icon(
                  Icons.arrow_back_rounded,
                  size: AppSizes.iconSizeMedium,
                  color: AppColors.surface,
                ),
              ),
            ),
          ),

          // عنوان الشريط العلوي
          Expanded(
            child: Text(
              data.title,
              textAlign: TextAlign.center,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: AppTypography.newsDetailsHeaderTitle18(),
            ),
          ),

          // دائرة الشعار / حرف الماركة
          Container(
            width: AppSizes.newsDetailsHeaderIconWrap,
            height: AppSizes.newsDetailsHeaderIconWrap,
            decoration: BoxDecoration(
              color: AppColors.surface.withValues(alpha: 0.2),
              shape: BoxShape.circle,
            ),
            alignment: Alignment.center,
            child: Text(
              data.leadingBadgeText,
              style: AppTypography.newsCardDateRegular11().copyWith(
                color: AppColors.surface,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
        ],
      ),
    );
  }
}