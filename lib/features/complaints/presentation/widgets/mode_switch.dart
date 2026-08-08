import 'package:flutter/material.dart';
import '../../../../app/theme/app_colors.dart';
import '../../../../core/constants/app_typography.dart';

class ModeSwitch extends StatelessWidget {
  const ModeSwitch({required this.firstLabel, required this.secondLabel, required this.selectedIndex, required this.onChanged, super.key});

  final String firstLabel;
  final String secondLabel;
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
          Expanded(child: ModeButton(label: firstLabel, selected: selectedIndex == 0, onTap: () => onChanged(0))),
          Expanded(child: ModeButton(label: secondLabel, selected: selectedIndex == 1, onTap: () => onChanged(1))),
        ],
      ),
    );
  }
}

class ModeButton extends StatelessWidget {
  const ModeButton({required this.label, required this.selected, required this.onTap, super.key});

  final String label;
  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 180),
        padding: const EdgeInsets.symmetric(vertical: 10),
        decoration: BoxDecoration(
          color: selected ? AppColors.surface : Colors.transparent,
          borderRadius: BorderRadius.circular(8),
          boxShadow: selected
              ? const <BoxShadow>[
                  BoxShadow(
                    color: Color(0x0C000000),
                    blurRadius: 2,
                    offset: Offset(0, 1),
                  ),
                ]
              : null,
        ),
        child: Text(
          label,
          textAlign: TextAlign.center,
          style: AppTypography.bodyBold14().copyWith(
            color: selected ? AppColors.text : AppColors.muted,
            fontSize: 13,
          ),
        ),
      ),
    );
  }
}
