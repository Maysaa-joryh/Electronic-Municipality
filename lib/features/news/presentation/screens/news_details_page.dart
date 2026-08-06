import 'package:flutter/material.dart';

import '../../../../app/theme/app_colors.dart';
import '../../../../core/constants/app_sizes.dart';
import '../../../../core/constants/app_strings.dart';
import '../../../../core/constants/app_typography.dart';
import '../models/news_details_models.dart';
import '../models/news_screen_models.dart';
import '../widgets/news_details_header_bar.dart';
import '../widgets/news_details_hero.dart';
import '../widgets/news_details_info_panel.dart';

class NewsDetailsPage extends StatefulWidget {
  const NewsDetailsPage({super.key, this.item});

  final NewsItemData? item;

  @override
  State<NewsDetailsPage> createState() => _NewsDetailsPageState();
}

class _NewsDetailsPageState extends State<NewsDetailsPage> {
  late final NewsDetailsHeaderData _headerData;
  late final NewsDetailsHeroData _heroData;
  late final NewsDetailsInfoData _infoData;

  @override
  void initState() {
    super.initState();
    final NewsItemData? item = widget.item;

    _headerData = const NewsDetailsHeaderData(
      title: AppStrings.newsDetailsTitle,
      leadingBadgeText: 'K',
    );

    _heroData = NewsDetailsHeroData(
      imageUrl: item?.imageUrl ??
          'https://images.unsplash.com/photo-1469474968028-56623f02e42e?auto=format&fit=crop&w=1200&q=80',
      dateText: item?.date ?? '24 مايو 2026',
    );

    _infoData = NewsDetailsInfoData(
      title: item?.title ?? 'خبر غير محدد',
      description: item?.detailsDescription ??
          'لا تتوفر تفاصيل إضافية لهذا الخبر حالياً.',
      metaItems: item?.detailsMetaItems ??
          <NewsDetailsMetaItem>[
            const NewsDetailsMetaItem(
              icon: Icons.access_time_rounded,
              text: 'التاريخ غير متوفر',
            ),
            const NewsDetailsMetaItem(
              icon: Icons.place_outlined,
              text: 'الموقع غير متوفر',
            ),
          ],
      actionText: item?.actionText ?? AppStrings.newsDetailsEnableAlert,
    );
  }

  void _showNotificationSnackBar(BuildContext context) {
    ScaffoldMessenger.of(context).clearSnackBars();
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        elevation: 0,
        behavior: SnackBarBehavior.floating,
        backgroundColor: Colors.transparent,
        margin: const EdgeInsets.all(16),
        duration: const Duration(seconds: 3),
        content: Container(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
          decoration: BoxDecoration(
            color: AppColors.surface,
            borderRadius: BorderRadius.circular(14),
            boxShadow: const <BoxShadow>[
              BoxShadow(
                color: Color(0x33000000),
                blurRadius: 14,
                offset: Offset(0, 4),
              ),
            ],
          ),
          child: Row(
            children: <Widget>[
              const Icon(
                Icons.notifications_active_rounded,
                color: AppColors.deepPrimary,
                size: 22,
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Text(
                  'تم تفعيل تنبيهات هذا الخبر بنجاح',
                  style: AppTypography.bodyMedium14().copyWith(
                    color: AppColors.text,
                    fontSize: 13,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    const double overlapOffset = -35.0;

    return Directionality(
      textDirection: TextDirection.rtl,
      child: Scaffold(
        backgroundColor: AppColors.deepPrimary,
        body: SafeArea(
          child: Padding(
            padding: const EdgeInsetsDirectional.fromSTEB(
              AppSizes.cardSpacing,
              AppSizes.widgetSpacing,
              AppSizes.cardSpacing,
              0,
            ),
            child: Column(
              children: <Widget>[
                // شريط العنونة والتنقل العلوي
                NewsDetailsHeaderBar(
                  data: _headerData,
                  onBackTap: () => Navigator.of(context).pop(),
                ),
                const SizedBox(height: AppSizes.widgetSpacing),

                // محتوى الخبر القابل للتمرير
                Expanded(
                  child: Center(
                    child: SingleChildScrollView(
                      physics: const BouncingScrollPhysics(),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.stretch,
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: <Widget>[
                          // 1. صورة الخبر الرئيسية
                          NewsDetailsHero(data: _heroData),

                          // 2. بطاقة التفاصيل المتداخلة بالمنتصف وعلى كامل العرض
                          Transform.translate(
                            offset: const Offset(0, overlapOffset),
                            child: SizedBox(
                              width: double.infinity,
                              child: NewsDetailsInfoPanel(
                                data: _infoData,
                                onActionTap: () =>
                                    _showNotificationSnackBar(context),
                              ),
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
        ),
      ),
    );
  }
}