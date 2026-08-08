// PATH: lib/features/news/presentation/widgets/news_event_card.dart
import 'package:flutter/material.dart';

import '../../../../app/theme/app_colors.dart';
import '../../../../core/constants/app_sizes.dart';
import '../../../../core/constants/app_typography.dart';
import '../models/news_screen_models.dart';

class NewsEventCard extends StatelessWidget {
  const NewsEventCard({
    super.key,
    required this.data,
    required this.onTap,
    required this.onActionTap,
  });

  final NewsEventCardData data;
  final VoidCallback onTap;
  final VoidCallback onActionTap;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        height: AppSizes.newsEventHeight,
        clipBehavior: Clip.antiAlias,
        decoration: BoxDecoration(
          color: AppColors.surface.withAlpha((0.40 * 255).round()),
          borderRadius: BorderRadiusDirectional.circular(AppSizes.newsCardRadius),
          boxShadow: const <BoxShadow>[
            BoxShadow(
              color: AppColors.shadow,
              blurRadius: AppSizes.newsEventShadowBlur,
              offset: Offset(0, AppSizes.newsEventShadowOffsetY),
            ),
          ],
        ),
        child: Stack(
          children: <Widget>[
            Positioned.fill(
              child: Image.network(
                data.imageUrl,
                fit: BoxFit.cover,
                color: Colors.black.withAlpha((0.56 * 255).round()),
                colorBlendMode: BlendMode.darken,
              ),
            ),
            Positioned.fill(
              child: Container(
                  decoration: BoxDecoration(
                  color: Colors.black.withAlpha((0.24 * 255).round()),
                  borderRadius: BorderRadiusDirectional.circular(AppSizes.newsCardRadius),
                ),
              ),
            ),
            Padding(
              padding: const EdgeInsetsDirectional.fromSTEB(
                AppSizes.widgetSpacing,
                AppSizes.widgetSpacing,
                AppSizes.widgetSpacing,
                AppSizes.widgetSpacing,
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: <Widget>[
                  Text(
                    data.title,
                    textAlign: TextAlign.right,
                    style: AppTypography.newsEventTitleBold15().copyWith(
                      color: AppColors.surface,
                      shadows: <Shadow>[
                        const Shadow(
                          offset: Offset(0, 2),
                          blurRadius: 3,
                          color: Colors.black45,
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: AppSizes.widgetSpacing),
                  Text(
                    data.subtitle,
                    textAlign: TextAlign.right,
                    style: AppTypography.newsCardBodyRegular13().copyWith(
                      color: AppColors.surface,
                      fontWeight: FontWeight.w900,
                    ),
                  ),
                  const Spacer(),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    crossAxisAlignment: CrossAxisAlignment.end,
                    textDirection: TextDirection.rtl,
                    children: <Widget>[
                      GestureDetector(
                        onTap: onActionTap,
                        child: Container(
                          height: 43,
                          padding: const EdgeInsetsDirectional.symmetric(
                            horizontal: AppSizes.widgetSpacing,
                          ),
                          decoration: BoxDecoration(
                            color: AppColors.deepPrimary,
                            borderRadius: BorderRadius.circular(AppSizes.newsEventActionButtonRadius),
                          ),
                          alignment: AlignmentDirectional.center,
                          child: Text(
                            data.actionLabel,
                            textAlign: TextAlign.center,
                            style: AppTypography.newsCardButtonBold13().copyWith(
                              fontSize: 15,
                              fontWeight: FontWeight.w800,
                            ),
                          ),
                        ),
                      ),
                      Text(
                        data.date,
                        textAlign: TextAlign.right,
                        style: AppTypography.newsCardDateRegular11().copyWith(
                          fontSize: 13,
                          fontWeight: FontWeight.w800,
                          color: AppColors.surface,
                        ),
                      ),
                    ],
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