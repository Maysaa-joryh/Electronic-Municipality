// PATH: lib/features/news/presentation/models/news_screen_models.dart
import 'package:flutter/material.dart';

import 'news_details_models.dart';

class NewsCategoryChipData {
  const NewsCategoryChipData({
    required this.id,
    required this.label,
    required this.isSelected,
  });

  final String id;
  final String label;
  final bool isSelected;
}

enum NewsItemType {
  urgent,
  info,
  event,
}

class NewsItemData {
  const NewsItemData({
    required this.id,
    required this.type,
    required this.categories,
    required this.title,
    required this.body,
    required this.date,
    required this.detailsDescription,
    required this.detailsMetaItems,
    required this.actionText,
    this.status,
    this.buttonLabel,
    this.imageUrl,
  });

  final String id;
  final NewsItemType type;
  final List<String> categories;
  final String title;
  final String body;
  final String date;
  final String detailsDescription;
  final List<NewsDetailsMetaItem> detailsMetaItems;
  final String actionText;
  final String? status;
  final String? buttonLabel;
  final String? imageUrl;
}

class NewsUrgentCardData {
  const NewsUrgentCardData({
    required this.badge,
    required this.title,
    required this.body,
    required this.date,
  });

  final String badge;
  final String title;
  final String body;
  final String date;
}

class NewsInfoCardData {
  const NewsInfoCardData({
    required this.title,
    required this.status,
    required this.body,
    required this.buttonLabel,
  });

  final String title;
  final String status;
  final String body;
  final String buttonLabel;
}

class NewsEventCardData {
  const NewsEventCardData({
    required this.title,
    required this.subtitle,
    required this.date,
    required this.actionLabel,
    required this.imageUrl,
  });

  final String title;
  final String subtitle;
  final String date;
  final String actionLabel;
  final String imageUrl;
}

class NewsBottomNavItemData {
  const NewsBottomNavItemData({
    required this.label,
    required this.routeName,
    this.icon,
  });

  final String label;
  final String routeName;
  final IconData? icon;
}