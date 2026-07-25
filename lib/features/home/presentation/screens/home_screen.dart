import 'package:flutter/material.dart';
import '../../../../app/theme/app_colors.dart';
import '../../../../core/constants/app_assets.dart';
import '../../../../shared/widgets/municipality_widgets.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({
    super.key,
    required this.onOpenProfile,
    required this.onOpenComplaints,
    required this.onOpenTransactions,
  });

  final VoidCallback onOpenProfile;
  final VoidCallback onOpenComplaints;
  final VoidCallback onOpenTransactions;

  @override
  Widget build(BuildContext context) {
    return ListView(
      padding: const EdgeInsets.fromLTRB(20, 0, 20, 28),
      children: [
        HomeTopBar(onOpenProfile: onOpenProfile),
        const SizedBox(height: 24),
        const PageHeader(
          title: 'الخدمات الإلكترونية',
          subtitle: 'كل ما تحتاجه من خدمات بلدية في مكان واحد',
          dense: true,
        ),
        const SizedBox(height: 16),
        AppPanel(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              const Row(
                children: [
                  CircleIcon(
                    icon: Icons.account_balance_outlined,
                    size: 50,
                    iconColor: AppColors.primary,
                  ),
                  SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'مرحبا بك في بوابة المواطن',
                          style: TextStyle(
                              fontSize: 17, fontWeight: FontWeight.w800),
                        ),
                        SizedBox(height: 4),
                        Text(
                          'تابع الطلبات والشكاوى والإعلانات بسهولة.',
                          style:
                              TextStyle(color: AppColors.muted, fontSize: 13),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 16),
              ClipRRect(
                borderRadius: BorderRadius.circular(8),
                child: Image.asset(
                  AppAssets.cityNews,
                  height: 140,
                  fit: BoxFit.cover,
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 18),
        Row(
          children: [
            Expanded(
              child: QuickServiceCard(
                icon: Icons.report_problem_outlined,
                title: 'تقديم شكوى',
                subtitle: 'التبليغ عن المشكلات',
                onTap: onOpenComplaints,
              ),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: QuickServiceCard(
                icon: Icons.description_outlined,
                title: 'تقديم معاملة',
                subtitle: 'إدارة الطلبات الرسمية',
                onTap: onOpenTransactions,
              ),
            ),
          ],
        ),
        const SizedBox(height: 18),
        const AppPanel(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text('أحدث الإعلانات',
                  style: TextStyle(fontSize: 17, fontWeight: FontWeight.w800)),
              SizedBox(height: 8),
              Text('تم تحديث خدمات التراخيص والرسوم الأسبوعية.',
                  style: TextStyle(color: AppColors.muted, fontSize: 13)),
            ],
          ),
        ),
      ],
    );
  }
}

class HomeTopBar extends StatelessWidget {
  const HomeTopBar({super.key, required this.onOpenProfile});

  final VoidCallback onOpenProfile;

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 68,
      padding: const EdgeInsets.symmetric(horizontal: 4),
      decoration: const BoxDecoration(
        color: AppColors.surface,
        border: Border(bottom: BorderSide(color: Color(0xFFE7E3DB))),
      ),
      child: Row(
        children: [
          IconButton(
            tooltip: 'الإشعارات',
            onPressed: () {},
            icon: const BadgeDot(child: Icon(Icons.notifications_none)),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Container(
              height: 44,
              decoration: BoxDecoration(
                color: AppColors.surface,
                border: Border.all(color: AppColors.border),
                borderRadius: BorderRadius.circular(22),
              ),
              child: const Row(
                children: [
                  SizedBox(width: 16),
                  Icon(Icons.search, color: AppColors.muted),
                  SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      'ابحث في الخدمات...',
                      overflow: TextOverflow.ellipsis,
                      style: TextStyle(color: AppColors.muted, fontSize: 16),
                    ),
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(width: 12),
          InkWell(
            customBorder: const CircleBorder(),
            onTap: onOpenProfile,
            child: Container(
              width: 48,
              height: 48,
              decoration: const BoxDecoration(
                color: AppColors.primary,
                shape: BoxShape.circle,
              ),
              child: const Icon(Icons.person, color: Colors.white),
            ),
          ),
        ],
      ),
    );
  }
}

class QuickServiceCard extends StatelessWidget {
  const QuickServiceCard({
    super.key,
    required this.icon,
    required this.title,
    required this.subtitle,
    required this.onTap,
  });

  final IconData icon;
  final String title;
  final String subtitle;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(8),
      child: Container(
        height: 148,
        padding: const EdgeInsets.symmetric(
          horizontal: 18,
          vertical: 16,
        ),
        decoration: BoxDecoration(
          color: AppColors.surfaceMuted,
          border: Border.all(color: const Color(0xFFD9DED8)),
          borderRadius: BorderRadius.circular(8),
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            CircleIcon(icon: icon, size: 54, iconColor: AppColors.primary),
            const SizedBox(height: 12),
            Text(
              title,
              textAlign: TextAlign.center,
              style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w800),
            ),
            const SizedBox(height: 4),
            Text(
              subtitle,
              textAlign: TextAlign.center,
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
              style: const TextStyle(color: AppColors.muted, fontSize: 13),
            ),
          ],
        ),
      ),
    );
  }
}
