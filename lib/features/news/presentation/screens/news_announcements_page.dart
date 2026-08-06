// PATH: lib/features/news/presentation/screens/news_announcements_page.dart
// ADAPTED FROM: khadijheh/municipality -> lib/features/news/presentation/pages/news_announcements_page.dart
// التعديل الوحيد: استبدال تنقّل go_router بـ callback (onOpenProfile) بنفس نمط AppShell،
// والانتقال لصفحة التفاصيل عبر Navigator.push مباشرة، وإزالة شريط التنقّل السفلي المدمج
// لأن AppShell يوفر واحدًا مشتركًا. النسخة الأصلية news_screen.dart بقيت بدون أي تعديل.
import 'package:flutter/material.dart';

import '../../../../app/theme/app_colors.dart';
import '../../../../core/constants/app_sizes.dart';
import '../../../../core/constants/app_strings.dart';
import '../../data/news_repository.dart';
import '../models/news_screen_models.dart';
import '../widgets/news_card_factory.dart';
import '../widgets/news_filter_chips_row.dart';
import '../widgets/news_screen_header.dart';
import '../widgets/news_top_app_bar.dart';
import 'news_details_page.dart';

class NewsAnnouncementsPage extends StatefulWidget {
  const NewsAnnouncementsPage({super.key, required this.onOpenProfile});

  final VoidCallback onOpenProfile;

  @override
  State<NewsAnnouncementsPage> createState() => _NewsAnnouncementsPageState();
}

class _NewsAnnouncementsPageState extends State<NewsAnnouncementsPage> {
  String _selectedChipId = 'all';
  final NewsRepository _repo = const NewsRepository();

  List<NewsCategoryChipData> get _chips {
    return _repo.getCategories().map((NewsCategoryChipData item) => NewsCategoryChipData(
        id: item.id,
        label: item.label,
        isSelected: item.id == _selectedChipId,
      )).toList(growable: false);
  }

  List<NewsItemData> get _filteredItems {
    final List<NewsItemData> all = _repo.getNewsItems();
    if (_selectedChipId == 'all') return all;
    return all.where((NewsItemData item) => item.categories.contains(_selectedChipId)).toList(growable: false);
  }

  void _onChipTap(String id) {
    if (id == _selectedChipId) return;
    setState(() => _selectedChipId = id);
  }

  void _navigateToDetails(NewsItemData item) {
    Navigator.of(context).push(
      MaterialPageRoute(builder: (_) => NewsDetailsPage(item: item)),
    );
  }

  Widget _buildNewsCard(NewsItemData item) {
    return NewsCardFactory(
      item: item,
      onNavigateToDetails: () => _navigateToDetails(item),
      onMapViewTap: () => _navigateToDetails(item),
    );
  }

  @override
  Widget build(BuildContext context) {
    final List<NewsItemData> filteredItems = _filteredItems;

    return Directionality(
      textDirection: TextDirection.rtl,
      child: Scaffold(
        backgroundColor: AppColors.background,
        body: SafeArea(
          child: SingleChildScrollView(
            padding: const EdgeInsetsDirectional.fromSTEB(
              AppSizes.widgetSpacing,
              AppSizes.tinySpacing,
              AppSizes.widgetSpacing,
              AppSizes.sectionSpacing,
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisAlignment: MainAxisAlignment.start,
              children: <Widget>[
                NewsTopAppBar(
                  brandText: AppStrings.appBrandEn,
                  onProfileTap: widget.onOpenProfile,
                ),
                const SizedBox(height: AppSizes.tinySpacing),
                const NewsScreenHeader(
                  title: AppStrings.newsScreenTitle,
                  subtitle: AppStrings.newsScreenSubtitle,
                ),
                const SizedBox(height: AppSizes.tinySpacing),
                NewsFilterChipsRow(items: _chips, onChipTap: _onChipTap),
                const SizedBox(height: AppSizes.widgetSpacing),
                ...filteredItems.map(
                  (NewsItemData item) => Padding(
                    padding: const EdgeInsets.only(bottom: AppSizes.widgetSpacing),
                    child: _buildNewsCard(item),
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
