import 'package:flutter/material.dart';
import '../../../../app/theme/app_colors.dart';
import '../../../../core/constants/app_typography.dart';

class PrioritySelector extends StatelessWidget {
  const PrioritySelector({
    required this.selectedIndex,
    required this.onChanged,
    super.key,
  });

  final int selectedIndex;
  final ValueChanged<int> onChanged;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(4),
      decoration: BoxDecoration(
        color: AppColors.surfaceMuted,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppColors.border),
      ),
      child: Row(
        children: <Widget>[
          Expanded(
            child: PriorityOption(
              label: 'منخفضة',
              selected: selectedIndex == 0,
              onTap: () => onChanged(0),
              color: AppColors.muted,
            ),
          ),
          Expanded(
            child: PriorityOption(
              label: 'عادية',
              selected: selectedIndex == 1,
              onTap: () => onChanged(1),
              color: AppColors.text,
            ),
          ),
          Expanded(
            child: PriorityOption(
              label: 'عالية',
              selected: selectedIndex == 2,
              onTap: () => onChanged(2),
              color: AppColors.danger,
            ),
          ),
        ],
      ),
    );
  }
}

class PriorityOption extends StatelessWidget {
  const PriorityOption({
    required this.label,
    required this.selected,
    required this.onTap,
    required this.color,
    super.key,
  });

  final String label;
  final bool selected;
  final VoidCallback onTap;
  final Color color;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(8),
        splashColor: color.withOpacity(0.1),
        highlightColor: Colors.transparent,
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 200),
          curve: Curves.easeInOut,
          padding: const EdgeInsets.symmetric(vertical: 8),
          decoration: BoxDecoration(
            color: selected ? AppColors.surface : Colors.transparent,
            borderRadius: BorderRadius.circular(8),
            // ظل خفيف جداً يظهر فقط عند التحديد ليمنح شعور العمق (Depth)
            boxShadow: selected
                ? const [
                    BoxShadow(
                      color: Color(0x0F000000),
                      blurRadius: 4,
                      offset: Offset(0, 2),
                    ),
                  ]
                : null,
          ),
          child: AnimatedDefaultTextStyle(
            duration: const Duration(milliseconds: 300),
            curve: Curves.easeInOut,
            style: AppTypography.bodyBold14().copyWith(
              fontSize: 12,
              color: selected ? AppColors.text : color,
            ),
            child: Text(
              label,
              textAlign: TextAlign.center,
            ),
          ),
        ),
      ),
    );
  }
}