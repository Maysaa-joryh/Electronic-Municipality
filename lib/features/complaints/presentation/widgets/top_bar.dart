import 'package:flutter/material.dart';
import '../../../../app/theme/app_colors.dart';
import '../../../../core/constants/app_typography.dart';

class ComplaintsTopBar extends StatelessWidget {
  const ComplaintsTopBar({required this.onNotificationTap, required this.onProfileTap, super.key});

  final VoidCallback onNotificationTap;
  final VoidCallback onProfileTap;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: AppColors.border),
        boxShadow: const <BoxShadow>[
          BoxShadow(
            color: Color(0x0F000000),
            blurRadius: 8,
            offset: Offset(0, 2),
          ),
        ],
      ),
      child: Row(
        textDirection: TextDirection.ltr,
        children: <Widget>[
          TopIconButton(icon: Icons.notifications_none_rounded, onTap: onNotificationTap, badge: true),
          const SizedBox(width: 10),
          Expanded(
            child: Center(
              child: Text(
                'E-Municipality',
                style: AppTypography.bodyBold14().copyWith(
                  color: AppColors.text,
                  fontSize: 16,
                ),
              ),
            ),
          ),
          const SizedBox(width: 10),
          TopIconButton(icon: Icons.person_rounded, onTap: onProfileTap),
        ],
      ),
    );
  }
}

class TopIconButton extends StatelessWidget {
  const TopIconButton({required this.icon, required this.onTap, this.badge = false, super.key});

  final IconData icon;
  final VoidCallback onTap;
  final bool badge;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: 32,
        height: 32,
        decoration: BoxDecoration(
          color: AppColors.surfaceMuted,
          shape: BoxShape.circle,
          border: Border.all(color: AppColors.border),
        ),
        child: Stack(
          children: <Widget>[
            Center(
              child: Icon(icon, size: 17, color: AppColors.text),
            ),
            if (badge)
              PositionedDirectional(
                top: 7,
                end: 7,
                child: Container(
                  width: 7,
                  height: 7,
                  decoration: const BoxDecoration(
                    color: AppColors.danger,
                    shape: BoxShape.circle,
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }
}
