import 'package:flutter/material.dart';
import '../../../../app/theme/app_colors.dart';
import '../../../../core/constants/app_typography.dart';

class SubmitButton extends StatelessWidget {
  const SubmitButton({
    required this.onTap,
    super.key,
    this.isLoading = false,
    this.title = 'إرسال البلاغ',
  });

  final VoidCallback? onTap;
  final bool isLoading;
  final String title;

  @override
  Widget build(BuildContext context) {
    final bool isEnabled = onTap != null && !isLoading;

    return AnimatedContainer(
      duration: const Duration(milliseconds: 200),
      height: 52,
      decoration: BoxDecoration(
        color: isEnabled ? AppColors.deepPrimary : AppColors.deepPrimary.withOpacity(0.5),
        borderRadius: BorderRadius.circular(12),
        boxShadow: isEnabled
            ? [
                BoxShadow(
                  color: AppColors.deepPrimary.withOpacity(0.25),
                  blurRadius: 12,
                  offset: const Offset(0, 4),
                ),
              ]
            : null,
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: isEnabled ? onTap : null,
          borderRadius: BorderRadius.circular(12),
          splashColor: Colors.white.withOpacity(0.15),
          child: Center(
            child: isLoading
                ? const SizedBox(
                    width: 24,
                    height: 24,
                    child: CircularProgressIndicator(
                      strokeWidth: 2.5,
                      color: AppColors.surface,
                    ),
                  )
                : Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: <Widget>[
                      Text(
                        title,
                        style: AppTypography.buttonBold15().copyWith(
                          fontSize: 15,
                          color: AppColors.surface,
                        ),
                      ),
                      const SizedBox(width: 8),
                      // استخدام Transform.scale للغات مثل العربية أو أيقونة معكوسة تلقائياً
                      Transform.flip(
                        flipX: Directionality.of(context) == TextDirection.rtl,
                        child: const Icon(
                          Icons.send_rounded,
                          color: AppColors.surface,
                          size: 20,
                        ),
                      ),
                    ],
                  ),
          ),
        ),
      ),
    );
  }
}