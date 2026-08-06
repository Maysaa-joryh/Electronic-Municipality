
import 'package:electronic_municipality/features/home/presentation/widgets/announcement_cards_section.dart';
import 'package:electronic_municipality/features/home/presentation/widgets/municipality_map_card.dart';
import 'package:flutter/material.dart';

import '../../../../app/theme/app_colors.dart';
import '../../../../core/constants/app_sizes.dart';
import '../models/home_dashboard_models.dart';
import '../widgets/emergency_banner.dart';
import '../widgets/home_app_header.dart';
import '../widgets/quick_services_section.dart';

import 'map_view_page.dart';
import 'placeholder_page.dart';

class HomePage extends StatefulWidget {
  const HomePage({
    super.key,
    required this.onOpenProfile,
    required this.onOpenComplaints,
    required this.onOpenTransactions,
    required this.onOpenNews,
  });

  final VoidCallback onOpenProfile;
  final VoidCallback onOpenComplaints;
  final VoidCallback onOpenTransactions;
  final VoidCallback onOpenNews;

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  late final TextEditingController _searchController;
  late final List<HomeServiceCardData> _serviceCards;

  @override
  void initState() {
    super.initState();
    _searchController = TextEditingController();
    _serviceCards = <HomeServiceCardData>[
      const HomeServiceCardData(
        title: 'تقديم معاملة',
        subtitle: 'إنجاز الطلبات الرسمية',
        icon: Icons.description_rounded,
      ),
      const HomeServiceCardData(
        title: 'تقديم شكوى',
        subtitle: 'التبليغ عن المشكلات',
        icon: Icons.report_gmailerrorred_rounded,
      ),
    ];
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  String? _validateSearch(String? value) {
    return null;
  }

  void _openPlaceholder(String title, String subtitle) {
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (_) => PlaceholderPage(title: title, subtitle: subtitle),
      ),
    );
  }

  void _openServiceCard(HomeServiceCardData item) {
    if (item.title == 'تقديم شكوى') {
      widget.onOpenComplaints();
      return;
    }
    _openPlaceholder(item.title, item.subtitle);
  }

  @override
  Widget build(BuildContext context) {
    return Directionality(
      textDirection: TextDirection.rtl,
      child: Scaffold(
        backgroundColor: AppColors.background,
        body: SafeArea(
          child: GestureDetector(
            onTap: () => FocusScope.of(context).unfocus(),
            child: CustomScrollView(
              keyboardDismissBehavior: ScrollViewKeyboardDismissBehavior.onDrag,
              slivers: <Widget>[
                SliverToBoxAdapter(
                  child: Padding(
                    padding: const EdgeInsets.fromLTRB(
                      AppSizes.screenPadding,
                      AppSizes.screenPadding,
                      AppSizes.screenPadding,
                      0,
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: <Widget>[
                        const SizedBox(height: AppSizes.widgetSpacing),
                        HomeAppHeader(
                          pageLabel: '',
                          searchController: _searchController,
                          searchValidator: _validateSearch,
                          searchHintText: 'ابحث في الخدمات...',
                          notificationCount: 1,
                          onNotificationTap: widget.onOpenTransactions,
                          onProfileTap: widget.onOpenProfile,
                          profileImageUrl: 'https://images.unsplash.com/photo-1494790108377-be9c29b29330?auto=format&fit=crop&w=200&q=80',
                          profileInitials: 'م',
                          onSearchSubmitted: (_) {},
                        ),
                        const SizedBox(height: AppSizes.sectionSpacing),
                        AnnouncementCardsSection(onOpenNews: widget.onOpenNews),
                        const SizedBox(height: AppSizes.sectionSpacing),
                        QuickServicesSection(
                          title: 'الخدمات السريعة',
                          items: _serviceCards,
                          onItemTap: _openServiceCard,
                        ),
                        const SizedBox(height: AppSizes.sectionSpacing),
                        EmergencyBanner(
                          title: 'تبرع للمدينة',
                          subtitle: 'ساهم في تطوير مجتمعنا',
                          actionLabel: 'تواصل الآن',
                          onTap: () => _openPlaceholder('تبرع للمدينة', 'ساهم في تطوير مجتمعنا'),
                        ),
                        const SizedBox(height: AppSizes.sectionSpacing),
                        GestureDetector(
                          onTap: () => Navigator.of(context).push(
                            MaterialPageRoute(
                              builder: (_) => const MapViewPage(
                                focusData: MapFocusData(
                                  title: 'تنبيه مرتبط بالموقع',
                                  subtitle: 'يتم الآن عرض التنبيه على الخريطة مع إمكانية التكبير والتصغير.',
                                  pinLabel: 'موقع التنبيه',
                                  badgeText: 'تنبيهات السكان',
                                  locationLabel: 'حي الميدان - وسط المدينة',
                                ),
                              ),
                            ),
                          ),
                          child: const MunicipalityMapCard(),
                        ),
                        const SizedBox(height: 24),
                      ],
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
