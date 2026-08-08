// PATH: lib/features/news/presentation/widgets/news_urgent_card.dart
import 'package:flutter/material.dart';

import '../../../../app/theme/app_colors.dart';
import '../../../../core/constants/app_sizes.dart';
import '../../../../core/constants/app_typography.dart';
import '../models/news_screen_models.dart';

class NewsUrgentCard extends StatelessWidget {
  const NewsUrgentCard({
    super.key,
    required this.data,
    required this.onTap,
  });

  final NewsUrgentCardData data;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        constraints: const BoxConstraints(minHeight: AppSizes.newsAlertMinHeight),
        decoration: BoxDecoration(
          color: AppColors.surface,
          borderRadius: BorderRadiusDirectional.circular(AppSizes.newsCardRadius),
          border: Border.all(color: AppColors.danger, width: AppSizes.newsCardBorderWidth),
          boxShadow: const <BoxShadow>[
            BoxShadow(
              color: AppColors.shadow,
              blurRadius: AppSizes.newsCardShadowBlur,
              offset: Offset(0, AppSizes.newsCardShadowOffsetY),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: <Widget>[
            Container(
              padding: const EdgeInsetsDirectional.symmetric(
                vertical: AppSizes.widgetSpacing,
                horizontal: AppSizes.widgetSpacing,
              ),
              decoration: BoxDecoration(
                color: AppColors.danger,
                borderRadius: const BorderRadiusDirectional.only(
                  topStart: Radius.circular(AppSizes.newsCardRadius),
                  topEnd: Radius.circular(AppSizes.newsCardRadius),
                ),
              ),
              child: Align(
              alignment: AlignmentDirectional.centerStart,
              child: Text(
                data.badge,
                textAlign: TextAlign.start,
                style: AppTypography.newsBadgeBold11().copyWith(color: AppColors.surface),
              ),
            ),
            ),
            Padding(
              padding: const EdgeInsetsDirectional.all(AppSizes.widgetSpacing),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: <Widget>[
                  Text(
                    data.title,
                    textAlign: TextAlign.right,
                    style: AppTypography.newsUrgentTitleBold20().copyWith(
                      fontSize: 15,
                      fontWeight: FontWeight.w900,
                      color: AppColors.text,
                    ),
                  ),
                  const SizedBox(height: AppSizes.tinySpacing),
                  Text(
                    data.body,
                    textAlign: TextAlign.right,
                    style: AppTypography.newsCardBodyRegular13().copyWith(
                      fontWeight: FontWeight.w900,
                    ),
                  ),
                  const SizedBox(height: AppSizes.widgetSpacing),
                  Align(
                    alignment: AlignmentDirectional.centerEnd,
                    child: Text(
                      data.date,
                      style: AppTypography.newsCardDateRegular11().copyWith(
                        fontSize: 12,
                        fontWeight: FontWeight.w500,
                        color: AppColors.muted,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}