import 'package:flutter/material.dart';

import '../models/news_screen_models.dart';
import 'news_event_card.dart';
import 'news_info_card.dart';
import 'news_urgent_card.dart';

class NewsCardFactory extends StatelessWidget {
  const NewsCardFactory({
    super.key,
    required this.item,
    required this.onNavigateToDetails,
    required this.onMapViewTap,
  });

  final NewsItemData item;
  final VoidCallback onNavigateToDetails;
  final VoidCallback onMapViewTap;

  @override
  Widget build(BuildContext context) {
    switch (item.type) {
      case NewsItemType.urgent:
        return NewsUrgentCard(
          data: NewsUrgentCardData(
            badge: 'تنبيه',
            title: item.title,
            body: item.body,
            date: item.date,
          ),
          onTap: onNavigateToDetails,
        );
      case NewsItemType.info:
        return NewsInfoCard(
          data: NewsInfoCardData(
            title: item.title,
            status: item.status ?? '',
            body: item.body,
            buttonLabel: item.buttonLabel ?? 'افتح الخريطة',
          ),
          onTap: onNavigateToDetails,
          onActionTap: onMapViewTap,
        );
      case NewsItemType.event:
        return NewsEventCard(
          data: NewsEventCardData(
            title: item.title,
            subtitle: item.body,
            date: item.date,
            actionLabel: item.actionText,
            imageUrl: item.imageUrl ?? '',
          ),
          onTap: onNavigateToDetails,
          onActionTap: onNavigateToDetails,
        );
    }
  }
}
