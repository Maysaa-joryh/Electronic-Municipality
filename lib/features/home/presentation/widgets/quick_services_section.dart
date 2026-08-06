// PATH: lib/features/home/presentation/widgets/quick_services_section.dart
import 'package:flutter/material.dart';

import '../../../../core/constants/app_sizes.dart';
import '../models/home_dashboard_models.dart';
import 'quick_service_card.dart';
import 'section_title.dart';

class QuickServicesSection extends StatelessWidget {
  const QuickServicesSection({
    super.key,
    required this.title,
    required this.items,
    required this.onItemTap,
  });

  final String title;
  final List<HomeServiceCardData> items;
  final ValueChanged<HomeServiceCardData> onItemTap;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: <Widget>[
        SectionTitle(title: title),
        const SizedBox(height: AppSizes.widgetSpacing),
        GridView.builder(
          itemCount: items.length,
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: 2,
            crossAxisSpacing: AppSizes.cardSpacing,
            mainAxisSpacing: AppSizes.cardSpacing,
            mainAxisExtent: 124,
          ),
          itemBuilder: (BuildContext context, int index) {
            final HomeServiceCardData item = items[index];
            return QuickServiceCard(
              data: item,
              onTap: () => onItemTap(item),
            );
          },
        ),
      ],
    );
  }
}