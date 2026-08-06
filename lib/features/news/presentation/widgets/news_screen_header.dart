// PATH: lib/features/news/presentation/widgets/news_screen_header.dart
import 'package:flutter/material.dart';
import 'package:electronic_municipality/core/constants/app_sizes.dart';

import '../../../../core/constants/app_typography.dart';

class NewsScreenHeader extends StatelessWidget {
  const NewsScreenHeader({
    super.key,
    required this.title,
    required this.subtitle,
  });

  final String title;
  final String subtitle;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      mainAxisAlignment: MainAxisAlignment.start,
      children: <Widget>[
        Text(
          title,
          
          style: AppTypography.newsScreenHeaderBold33(),
        ),
         const SizedBox(height: AppSizes.newsActionButtonHeight),
        Text(
          subtitle,
        
          style: AppTypography.newsSubtitleRegular12(),
        ),
      ],
    );
  }
}