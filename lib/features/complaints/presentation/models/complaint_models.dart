import 'package:flutter/material.dart';

class CategoryItem {
  const CategoryItem({required this.label, required this.icon});

  final String label;
  final IconData icon;
}

class ComplaintTimelineEntry {
  const ComplaintTimelineEntry({
    required this.status,
    required this.description,
    required this.timestamp,
    required this.completed,
  });

  final String status;
  final String description;
  final String timestamp;
  final bool completed;
}

class Complaint {
  const Complaint({
    required this.title,
    required this.date,
    required this.id,
    required this.status,
    required this.description,
    required this.location,
    required this.timeline,
    required this.secondaryStatus,
    required this.secondaryStatusColor,
  });

  final String title;
  final String date;
  final String id;
  final String status;
  final String description;
  final String location;
  final List<ComplaintTimelineEntry> timeline;
  final String secondaryStatus;
  final int secondaryStatusColor;
}
