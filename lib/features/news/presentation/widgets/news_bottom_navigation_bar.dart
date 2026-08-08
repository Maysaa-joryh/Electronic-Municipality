// PATH: lib/features/news/presentation/widgets/news_bottom_navigation_bar.dart
import 'package:flutter/material.dart';

import '../../../../app/theme/app_colors.dart';
import '../../../../core/constants/app_sizes.dart';
import '../../../../core/constants/app_typography.dart';
import '../models/news_screen_models.dart';

class NewsBottomNavigationBar extends StatelessWidget {
  const NewsBottomNavigationBar({
    super.key,
    required this.items,
    required this.selectedIndex,
    required this.onItemTap,
  });

  final List<NewsBottomNavItemData> items;
  final int selectedIndex;
  final ValueChanged<int> onItemTap;

  @override
  Widget build(BuildContext context) {
    return Container(
      height: AppSizes.newsBottomNavHeight,
      margin: const EdgeInsetsDirectional.fromSTEB(
        AppSizes.newsBottomNavOuterMargin,
        0,
        AppSizes.newsBottomNavOuterMargin,
        AppSizes.newsBottomNavBottomMargin,
      ),
      padding: const EdgeInsetsDirectional.symmetric(horizontal: AppSizes.widgetSpacing),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadiusDirectional.circular(AppSizes.cardRadius),
        border: Border.all(color: AppColors.border),
        boxShadow: const <BoxShadow>[
          BoxShadow(
            color: AppColors.shadow,
            blurRadius: AppSizes.newsEventShadowBlur,
            offset: Offset(0, AppSizes.newsEventShadowOffsetY),
          ),
        ],
      ),
      child: Row(
        textDirection: TextDirection.ltr,
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: List<Widget>.generate(items.length, (int index) {
          final NewsBottomNavItemData item = items[index];
          final bool selected = index == selectedIndex;
          return Expanded(
            child: GestureDetector(
              onTap: () => onItemTap(index),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: <Widget>[
                  if (selected)
                    Container(
                      width: AppSizes.newsBottomSelectedPillWidth,
                      height: AppSizes.newsBottomSelectedPillHeight,
                      decoration: BoxDecoration(
                        color: AppColors.primary,
                        borderRadius: BorderRadiusDirectional.circular(AppSizes.newsBottomNavSelectedRadius),
                      ),
                      child: _NavIcon(
                        icon: item.icon,
                        selected: true,
                      ),
                    )
                  else
                    _NavIcon(
                      icon: item.icon,
                      selected: false,
                    ),
                  const SizedBox(height: AppSizes.newsBottomNavLabelGap),
                  Text(
                    item.label,
                    style: AppTypography.newsBottomNavLabel10(),
                  ),
                ],
              ),
            ),
          );
        }),
      ),
    );
  }
}

class _NavIcon extends StatelessWidget {
  const _NavIcon({
    required this.icon,
    required this.selected,
  });

  final IconData? icon;
  final bool selected;

  @override
  Widget build(BuildContext context) {
    return Icon(
      icon ?? Icons.circle,
      size: AppSizes.newsBottomNavIconSize,
      color: selected ? AppColors.surface : AppColors.muted,
    );
  }
}