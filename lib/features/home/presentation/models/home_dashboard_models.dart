// PATH: lib/features/home/presentation/models/home_dashboard_models.dart
import 'package:flutter/material.dart';

class HomeNewsCardData {
  const HomeNewsCardData({
    required this.title,
    required this.subtitle,
    required this.imageUrl,
    required this.badgeText,
    required this.width,
  });

  final String title;
  final String subtitle;
  final String imageUrl;
  final String badgeText;
  final double width;
}

class HomeServiceCardData {
  const HomeServiceCardData({
    required this.title,
    required this.subtitle,
    required this.icon,
  });

  final String title;
  final String subtitle;
  final IconData icon;
}

class HomeBottomNavItemData {
  const HomeBottomNavItemData({
    required this.label,
    required this.icon,
    required this.routeName,
  });

  final String label;
  final IconData icon;
  final String routeName;
}

class MapFocusData {
  const MapFocusData({
    required this.title,
    required this.subtitle,
    required this.pinLabel,
    required this.badgeText,
    required this.locationLabel,
    this.initialScale = 1.0,
    this.latitude = 33.5138, // إحداثيات افتراضية (يمكنك تغييرها)
    this.longitude = 36.2765,
    this.zoomLevel = 14.0,
  });

  final String title;
  final String subtitle;
  final String pinLabel;
  final String badgeText;
  final String locationLabel;
  final double initialScale;
  final double latitude;
  final double longitude;
  final double zoomLevel;
}