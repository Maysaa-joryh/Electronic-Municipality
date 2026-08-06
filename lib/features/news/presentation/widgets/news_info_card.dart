// PATH: lib/features/news/presentation/widgets/news_info_card.dart
import 'package:flutter/material.dart';

import '../../../../app/theme/app_colors.dart';
import '../../../../core/constants/app_sizes.dart';
import '../../../../core/constants/app_typography.dart';
import '../models/news_screen_models.dart';

class NewsInfoCard extends StatelessWidget {
  const NewsInfoCard({
    super.key,
    required this.data,
    required this.onTap,
    required this.onActionTap,
  });

  final NewsInfoCardData data;
  final VoidCallback onTap;
  final VoidCallback onActionTap;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        clipBehavior: Clip.antiAlias,
        decoration: BoxDecoration(
          color: AppColors.surface,
          borderRadius: BorderRadiusDirectional.circular(AppSizes.newsCardRadius),
          border: Border.all(color: AppColors.muted.withAlpha((0.2 * 255).round()), width: AppSizes.newsCardBorderWidth),
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
              height: 46,
              decoration: BoxDecoration(
                color: AppColors.sky,
                borderRadius: const BorderRadiusDirectional.only(
                  topStart: Radius.circular(AppSizes.newsCardRadius),
                  topEnd: Radius.circular(AppSizes.newsCardRadius),
                ),
              ),
            ),
            Padding(
              padding: const EdgeInsetsDirectional.all(AppSizes.widgetSpacing),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: <Widget>[
                  Row(
                    textDirection: TextDirection.rtl,
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: <Widget>[
                      Expanded(
                        child: Text(
                          data.title,
                          textAlign: TextAlign.right,
                          style: AppTypography.newsInfoTitleBold15(),
                        ),
                      ),
                      Container(
                        height: AppSizes.newsMiniBadgeHeight,
                        alignment: AlignmentDirectional.center,
                        padding: const EdgeInsetsDirectional.symmetric(horizontal: AppSizes.widgetSpacing),
                        decoration: BoxDecoration(
                          color: AppColors.surfaceMuted,
                          borderRadius: BorderRadiusDirectional.circular(AppSizes.newsMiniBadgeHeight / 2),
                        ),
                        child: Text(
                          data.status,
                          style: AppTypography.newsInfoStatusRegular10(),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: AppSizes.tinySpacing),
                  Text(
                    data.body,
                    textAlign: TextAlign.right,
                    style: AppTypography.newsCardBodyRegular13().copyWith(
                      fontSize: 12,
                      fontWeight: FontWeight.w600,
                      color: AppColors.text,
                    ),
                  ),
                  const SizedBox(height: AppSizes.widgetSpacing),
                  Align(
                    alignment: AlignmentDirectional.centerStart,
                    child: GestureDetector(
                      onTap: onActionTap,
                      child: Container(
                        height: AppSizes.newsEventActionButtonHeight,
                        padding: const EdgeInsetsDirectional.symmetric(horizontal: AppSizes.widgetSpacing),
                        decoration: BoxDecoration(
                          color: AppColors.deepPrimary,
                          borderRadius: BorderRadiusDirectional.circular(AppSizes.newsEventActionButtonRadius),
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          textDirection: TextDirection.ltr,
                          children: <Widget>[
                            const Icon(
                              Icons.place_outlined,
                              size: AppSizes.newsActionIconSize,
                              color: AppColors.surface,
                            ),
                            const SizedBox(width: AppSizes.tinySpacing),
                            Text(
                              data.buttonLabel,
                              style: AppTypography.newsCardButtonBold13().copyWith(
                                fontSize: 15,
                                fontWeight: FontWeight.w800,
                              ),
                            ),
                          ],
                        ),
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