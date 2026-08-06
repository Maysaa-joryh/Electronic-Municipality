// PATH: lib/features/home/presentation/widgets/section_title.dart
import 'package:flutter/material.dart';

import '../../../../app/theme/app_colors.dart';
import '../../../../core/constants/app_typography.dart';

class SectionTitle extends StatelessWidget {
  const SectionTitle({
    super.key,
    required this.title,
    this.trailing,
  });

  final String title;
  final String? trailing;

  @override
  Widget build(BuildContext context) {
    return Row(
      textDirection: TextDirection.ltr,
      children: <Widget>[
        if (trailing != null) ...<Widget>[
          Text(
            trailing!,
            style: AppTypography.bodyRegular13().copyWith(color: AppColors.muted),
          ),
          const Spacer(),
        ] else
          const Spacer(),
        Text(title, textAlign: TextAlign.right, style: AppTypography.sectionTitleBold18()),
      ],
    );
  }
}