// PATH: lib/features/news/presentation/widgets/news_details_hero.dart
import 'package:flutter/material.dart';

import '../../../../app/theme/app_colors.dart';
import '../../../../core/constants/app_sizes.dart';
import '../../../../core/constants/app_typography.dart';
import '../models/news_details_models.dart';

class NewsDetailsHero extends StatelessWidget {
  const NewsDetailsHero({
    super.key,
    required this.data,
    this.heroTag,
  });

  final NewsDetailsHeroData data;
  final String? heroTag;

  @override
  Widget build(BuildContext context) {
    final Widget imageWidget = ClipRRect(
      borderRadius: BorderRadiusDirectional.circular(AppSizes.newsCardRadius),
      child: Stack(
        fit: StackFit.expand,
        children: <Widget>[
          // صورة الخبر من الشبكة مع معالجة حَالَتي التحميل والخطأ
          Image.network(
            data.imageUrl,
            fit: BoxFit.cover,
            loadingBuilder: (context, child, loadingProgress) {
              if (loadingProgress == null) return child;
              return Container(
                color: AppColors.surfaceMuted,
                child: const Center(
                  child: SizedBox(
                    width: 24,
                    height: 24,
                    child: CircularProgressIndicator(
                      strokeWidth: 2,
                      color: AppColors.deepPrimary,
                    ),
                  ),
                ),
              );
            },
            errorBuilder: (context, error, stackTrace) {
              return Container(
                color: AppColors.surfaceMuted,
                child: const Center(
                  child: Icon(
                    Icons.broken_image_rounded,
                    color: AppColors.muted,
                    size: 32,
                  ),
                ),
              );
            },
          ),

          // تدرج ظلي في أسفل الصورة لضمان وضوح شارة التاريخ دائماً
          const DecoratedBox(
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
                colors: <Color>[
                  Colors.transparent,
                  Color(0x55000000),
                ],
                stops: <double>[0.6, 1.0],
              ),
            ),
          ),

          // شارة التاريخ
          Padding(
            padding: const EdgeInsetsDirectional.all(AppSizes.widgetSpacing),
            child: Align(
              alignment: AlignmentDirectional.bottomEnd,
              child: Container(
                height: AppSizes.newsDetailsDatePillHeight,
                padding: const EdgeInsetsDirectional.symmetric(
                  horizontal: AppSizes.widgetSpacing,
                ),
                decoration: BoxDecoration(
                  color: AppColors.deepPrimary,
                  borderRadius: BorderRadiusDirectional.circular(
                    AppSizes.newsDetailsDatePillRadius,
                  ),
                  boxShadow: const <BoxShadow>[
                    BoxShadow(
                      color: Color(0x29000000),
                      blurRadius: 6,
                      offset: Offset(0, 2),
                    ),
                  ],
                ),
                alignment: AlignmentDirectional.center,
                child: Text(
                  data.dateText,
                  style: AppTypography.newsCardDateRegular11().copyWith(
                    color: AppColors.surface,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );

    // إذا تم تمرير heroTag يتم تفعيل تأثير الانتقال الحركي الانسيابي
    if (heroTag != null && heroTag!.isNotEmpty) {
      return SizedBox(
        height: AppSizes.newsDetailsHeroHeight,
        child: Hero(
          tag: heroTag!,
          child: imageWidget,
        ),
      );
    }

    return SizedBox(
      height: AppSizes.newsDetailsHeroHeight,
      child: imageWidget,
    );
  }
}