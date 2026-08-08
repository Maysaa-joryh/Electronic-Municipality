// PATH: lib/features/news/presentation/models/news_details_models.dart
import 'package:flutter/material.dart';

class NewsDetailsHeaderData {
  const NewsDetailsHeaderData({
    required this.title,
    required this.leadingBadgeText,
  });

  final String title;
  final String leadingBadgeText;
}

class NewsDetailsHeroData {
  const NewsDetailsHeroData({
    required this.imageUrl,
    required this.dateText,
  });

  final String imageUrl;
  final String dateText;
}

class NewsDetailsMetaItem {
  const NewsDetailsMetaItem({
    required this.icon,
    required this.text,
  });

  final IconData icon;
  final String text;
}

class NewsDetailsInfoData {
  const NewsDetailsInfoData({
    required this.title,
    required this.description,
    required this.metaItems,
    required this.actionText,
  });

  final String title;
  final String description;
  final List<NewsDetailsMetaItem> metaItems;
  final String actionText;
}