// PATH: lib/features/home/presentation/widgets/home_app_header.dart
import 'package:flutter/material.dart';

import '../../../../app/theme/app_colors.dart';
import '../../../../core/constants/app_sizes.dart';
import '../../../../core/constants/app_typography.dart';
import 'home_search_bar.dart';

class HomeAppHeader extends StatelessWidget {
  const HomeAppHeader({
    super.key,
    required this.pageLabel,
    required this.searchController,
    required this.searchValidator,
    required this.searchHintText,
    required this.notificationCount,
    required this.onNotificationTap,
    required this.onProfileTap,
    required this.profileImageUrl,
    required this.profileInitials,
    required this.onSearchSubmitted,
  });

  final String pageLabel;
  final TextEditingController searchController;
  final FormFieldValidator<String> searchValidator;
  final String searchHintText;
  final int notificationCount;
  final VoidCallback onNotificationTap;
  final VoidCallback onProfileTap;
  final String profileImageUrl;
  final String profileInitials;
  final ValueChanged<String> onSearchSubmitted;

  @override
  Widget build(BuildContext context) {
    final bool hasPageLabel = pageLabel.trim().isNotEmpty;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: <Widget>[
        if (hasPageLabel) ...<Widget>[
          Text(
            pageLabel,
            textAlign: TextAlign.start,
            style: AppTypography.captionRegular12(),
          ),
          const SizedBox(height: AppSizes.widgetSpacing),
        ],
        Row(
          textDirection: TextDirection.ltr,
          children: <Widget>[
            _NotificationBadgeButton(
              count: notificationCount,
              onTap: onNotificationTap,
            ),
            const SizedBox(width: AppSizes.widgetSpacing),
            Expanded(
              child: HomeSearchBar(
                controller: searchController,
                validator: searchValidator,
                hintText: searchHintText,
                onSubmitted: onSearchSubmitted,
              ),
            ),
            const SizedBox(width: AppSizes.widgetSpacing),
            _ProfileAvatarButton(
              imageUrl: profileImageUrl,
              initials: profileInitials,
              onTap: onProfileTap,
            ),
          ],
        ),
      ],
    );
  }
}

class _NotificationBadgeButton extends StatelessWidget {
  const _NotificationBadgeButton({
    required this.count,
    required this.onTap,
  });

  final int count;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: AppSizes.avatarSize,
        height: AppSizes.avatarSize,
        decoration: BoxDecoration(
          color: AppColors.surface,
          borderRadius: BorderRadius.circular(18),
          border: Border.all(color: AppColors.border),
        ),
        child: Stack(
          clipBehavior: Clip.none,
          alignment: Alignment.center,
          children: <Widget>[
            const Icon(
              Icons.notifications_none_rounded,
              size: AppSizes.iconSizeMedium,
              color: AppColors.primary,
            ),
            if (count > 0)
              PositionedDirectional(
                top: 9,
                end: 11,
                child: Container(
                  width: AppSizes.badgeSize,
                  height: AppSizes.badgeSize,
                  decoration: const BoxDecoration(
                    color: AppColors.danger,
                    shape: BoxShape.circle,
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }
}

class _ProfileAvatarButton extends StatelessWidget {
  const _ProfileAvatarButton({
    required this.imageUrl,
    required this.initials,
    required this.onTap,
  });

  final String imageUrl;
  final String initials;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: AppSizes.avatarSize,
        height: AppSizes.avatarSize,
        decoration: BoxDecoration(
          color: AppColors.surface,
          shape: BoxShape.circle,
          border: Border.all(color: AppColors.border, width: 1),
        ),
        clipBehavior: Clip.antiAlias,
        child: imageUrl.isEmpty
            ? Center(
                child: Text(
                  initials,
                  style: AppTypography.bodyBold14(),
                ),
              )
            : Image.network(
                imageUrl,
                fit: BoxFit.cover,
                errorBuilder: (_, __, ___) => Center(
                  child: Text(
                    initials,
                    style: AppTypography.bodyBold14(),
                  ),
                ),
              ),
      ),
    );
  }
}