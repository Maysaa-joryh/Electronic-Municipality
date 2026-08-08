// PATH: lib/features/news/presentation/widgets/news_details_info_panel.dart
import 'package:flutter/material.dart';

import '../../../../app/theme/app_colors.dart';
import '../../../../core/constants/app_sizes.dart';
import '../../../../core/constants/app_typography.dart';
import '../models/news_details_models.dart';

class NewsDetailsInfoPanel extends StatelessWidget {
  const NewsDetailsInfoPanel({
    super.key,
    required this.data,
    required this.onActionTap,
  });

  final NewsDetailsInfoData data;
  final VoidCallback onActionTap;

  @override
  Widget build(BuildContext context) {
    return Container(
      
      padding: const EdgeInsetsDirectional.fromSTEB(
        AppSizes.newsDetailsPanelPadding,
        AppSizes.newsDetailsPanelPadding + 16,
        AppSizes.newsDetailsPanelPadding,
        AppSizes.newsDetailsPanelPadding,
      ),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadiusDirectional.circular(AppSizes.cardRadius),
        boxShadow: const <BoxShadow>[
          BoxShadow(
            color: AppColors.shadow,
            blurRadius: AppSizes.newsCardShadowBlur,
            offset: Offset(0, AppSizes.newsCardShadowOffsetY),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          // عنوان الخبر
          Text(
            data.title,
            textAlign: TextAlign.center,
            style: AppTypography.newsDetailsCardTitle18(),
          ),
          const SizedBox(height: AppSizes.newsDetailsLineGap + 4),

          // تفاصيل المقال
          Text(
            data.description,
            textAlign: TextAlign.start,
            style: AppTypography.newsDetailsBody12().copyWith(
              height: 1.6,
            ),
          ),
          const SizedBox(height: AppSizes.widgetSpacing),

          // معلومات الخبر الإضافية (التاريخ، المكان، ...إلخ)
          ...data.metaItems.map(
            (NewsDetailsMetaItem item) => Padding(
              padding: const EdgeInsetsDirectional.only(
                bottom: AppSizes.newsDetailsLineGap,
              ),
              child: Row(
                children: <Widget>[
                  Icon(
                    item.icon,
                    size: AppSizes.iconSizeSmall,
                    color: AppColors.muted,
                  ),
                  const SizedBox(width: AppSizes.tinySpacing + 2),
                  Expanded(
                    child: Text(
                      item.text,
                      style: AppTypography.newsDetailsMeta12().copyWith(
                        color: AppColors.text,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: AppSizes.widgetSpacing),

          // زر إجراء التنبيه (Action Button)
          Align(
            alignment: AlignmentDirectional.centerEnd,
            child: Material(
              color: AppColors.deepPrimary,
              borderRadius: BorderRadiusDirectional.circular(
                AppSizes.newsDetailsActionButtonRadius,
              ),
              child: InkWell(
                onTap: onActionTap,
                // الإصلاح هنا: استخدام BorderRadius بدلاً من BorderRadiusDirectional
                borderRadius: BorderRadius.circular(
                  AppSizes.newsDetailsActionButtonRadius,
                ),
                splashColor: Colors.white.withOpacity(0.15),
                highlightColor: Colors.transparent,
                child: Container(
                  height: AppSizes.newsDetailsActionButtonHeight,
                  padding: const EdgeInsetsDirectional.symmetric(
                    horizontal: AppSizes.widgetSpacing,
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: <Widget>[
                      Text(
                        data.actionText,
                        style: AppTypography.newsCardButtonBold13().copyWith(
                          color: AppColors.surface,
                        ),
                      ),
                      const SizedBox(width: AppSizes.tinySpacing + 2),
                      const Icon(
                        Icons.notifications_none_rounded,
                        size: AppSizes.newsDetailsActionIcon,
                        color: AppColors.surface,
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}