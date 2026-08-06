import 'package:electronic_municipality/core/constants/app_assets.dart';
import 'package:flutter/material.dart';


class AnnouncementCardsSection extends StatelessWidget {
  const AnnouncementCardsSection({super.key, required this.onOpenNews});

  final dynamic onOpenNews;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        const Text(
          'أحدث الأخبار والإعلانات',
          textAlign: TextAlign.right,
          style: TextStyle(
            color: Color(0xFF1B1C19),
            fontSize: 20,
            height: 1.4,
            fontWeight: FontWeight.w500,
          ),
        ),
        const SizedBox(height: 16),
        SizedBox(
          height: 200,
          child: LayoutBuilder(
            builder: (context, constraints) {
              final cardWidth = (constraints.maxWidth * 0.8).clamp(240.0, 280.0).toDouble();

              return ListView.separated(
                scrollDirection: Axis.horizontal,
                physics: const BouncingScrollPhysics(),
                itemCount: 2,
                separatorBuilder: (_, __) => const SizedBox(width: 16),
                itemBuilder: (context, index) {
                  return SizedBox(
                    width: cardWidth,
                    child: AnnouncementCard(
                      onTap: onOpenNews,
                      muted: index == 1,
                    ),
                  );
                },
              );
            },
          ),
        ),
      ],
    );
  }
}

class AnnouncementCard extends StatelessWidget {
  const AnnouncementCard({
    super.key,
    required this.onTap,
    this.muted = false,
  });

  final VoidCallback onTap;
  final bool muted;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.white,
      borderRadius: BorderRadius.circular(12),
      clipBehavior: Clip.antiAlias,
      elevation: 1,
      shadowColor: Colors.black.withOpacity(0.12),
      child: InkWell(
        key: muted ? null : const ValueKey('home_latest_news_card'),
        onTap: onTap,
        child: ColorFiltered(
          colorFilter: muted
              ? const ColorFilter.mode(
                  Color(0x4D002A1C),
                  BlendMode.darken,
                )
              : const ColorFilter.mode(
                  Colors.transparent,
                  BlendMode.srcOver,
                ),
          child: Image.asset(
            AppAssets.cityNews,
            width: double.infinity,
            height: 200,
            fit: BoxFit.cover,
            alignment: muted ? Alignment.centerLeft : Alignment.center,
            filterQuality: FilterQuality.high,
          ),
        ),
      ),
    );
  }
}
