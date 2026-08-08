// PATH: lib/features/news/presentation/widgets/news_filter_chips_row.dart
import 'package:flutter/material.dart';

import '../../../../app/theme/app_colors.dart';
import '../../../../core/constants/app_sizes.dart';
import '../../../../core/constants/app_typography.dart';
import '../models/news_screen_models.dart';

class NewsFilterChipsRow extends StatelessWidget {
  const NewsFilterChipsRow({
    super.key,
    required this.items,
    required this.onChipTap,
  });

  final List<NewsCategoryChipData> items;
  final ValueChanged<String> onChipTap;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: AppSizes.newsChipHeight,
      child: ListView.separated(
        scrollDirection: Axis.horizontal,
        itemCount: items.length,
        separatorBuilder: (_, __) => const SizedBox(width: AppSizes.tinySpacing),
        itemBuilder: (BuildContext context, int index) {
          final NewsCategoryChipData item = items[index];
          final bool selected = item.isSelected;
          return GestureDetector(
            onTap: () => onChipTap(item.id),
            child: Container(
              alignment: AlignmentDirectional.center,
              
              padding: const EdgeInsetsDirectional.symmetric(
                horizontal: AppSizes.widgetSpacing,
              ),
              decoration: BoxDecoration(
                color: selected ? AppColors.primary : AppColors.surfaceMuted,
                borderRadius: BorderRadiusDirectional.circular(AppSizes.newsChipRadius),
                border: Border.all(
                  color: selected ? AppColors.primary : AppColors.border,
                ),
              ),
              child: Text(
                item.label,
                style: AppTypography.newsChipLabel11().copyWith(
                  color: selected ? AppColors.surface : AppColors.text,
                ),
              ),
            ),
          );
        },
      ),
    );
  }
}