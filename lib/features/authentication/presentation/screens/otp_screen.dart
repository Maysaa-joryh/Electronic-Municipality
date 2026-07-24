import 'package:flutter/material.dart';

import '../../../../app/design_system.dart';
import '../../../../app/router.dart';
import '../../../../app/theme/app_colors.dart';
import '../../../../core/di.dart';
import '../../../../shared/widgets/form_components.dart';
import '../../../../shared/widgets/municipality_widgets.dart';

class AuthOtpScreen extends StatefulWidget {
  const AuthOtpScreen({super.key});

  @override
  State<AuthOtpScreen> createState() => _AuthOtpScreenState();
}

class _AuthOtpScreenState extends State<AuthOtpScreen> {
  late OTPInputField _otpField;
  bool _isLoading = false;
  String? _errorMessage;

  @override
  void initState() {
    super.initState();
    _otpField = OTPInputField(
      onComplete: (otp) => _verifyOtp(otp),
    );
  }

  void _verifyOtp(String otp) async {
    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    try {
      // Assume contact is stored from previous screen - for now using test
      final contact = 'test@example.com';
      final result = await DI.auth.verifyOtp(
        contact: contact,
        code: otp,
      );
      if (result && mounted) {
        Navigator.of(context).pushNamed(AppRoutes.reset);
      } else if (mounted) {
        setState(() {
          _errorMessage = 'الرمز غير صحيح. حاول مرة أخرى.';
          _isLoading = false;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _errorMessage = 'الرمز غير صحيح. حاول مرة أخرى.';
          _isLoading = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return AuthCenterScaffold(
      verticalPadding: const EdgeInsets.symmetric(vertical: AppSpacing.xl),
      child: SingleChildScrollView(
        child: Column(
          children: [
            const MunicipalityLogo(size: 56),
            const SizedBox(height: AppSpacing.xxl),

            // Icon
            const Center(
              child: CircleIcon(
                icon: Icons.phonelink_lock_outlined,
                size: 80,
                color: AppColors.mint,
                iconColor: AppColors.primary,
              ),
            ),
            const SizedBox(height: AppSpacing.xl),

            // Title
            Text(
              'رمز التحقق',
              textAlign: TextAlign.center,
              style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
            ),
            const SizedBox(height: AppSpacing.md),

            // Description
            Text(
              'أدخل الرمز المكون من 4 أرقام المرسل إلى هاتفك',
              textAlign: TextAlign.center,
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                    color: AppColors.muted,
                  ),
            ),
            const SizedBox(height: AppSpacing.xxl),

            // Error message
            if (_errorMessage != null) ...[
              Container(
                padding: const EdgeInsets.all(AppSpacing.md),
                decoration: BoxDecoration(
                  color: AppColors.danger.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(AppRadius.md),
                  border: Border.all(color: AppColors.danger),
                ),
                child: Text(
                  _errorMessage!,
                  style: Theme.of(context).textTheme.bodySmall?.copyWith(
                        color: AppColors.danger,
                      ),
                ),
              ),
              const SizedBox(height: AppSpacing.lg),
            ],

            // OTP Input
            _otpField,
            const SizedBox(height: AppSpacing.xxl),

            // Resend timer
            ResendCodeTimer(
              onResend: () async {
                // Resend OTP logic
                try {
                  await DI.auth.requestOtp(contact: 'test@example.com');
                } catch (e) {
                  if (mounted) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(content: Text('فشل إعادة إرسال الرمز')),
                    );
                  }
                }
              },
            ),
            const SizedBox(height: AppSpacing.xxl),

            // Loading indicator
            if (_isLoading)
              const SizedBox(
                width: 30,
                height: 30,
                child: CircularProgressIndicator(
                  strokeWidth: 2,
                ),
              ),
            const SizedBox(height: AppSpacing.lg),

            // Back button
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: Text(
                'رجوع',
                style: Theme.of(context).textTheme.bodySmall?.copyWith(
                      color: AppColors.gold,
                    ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
