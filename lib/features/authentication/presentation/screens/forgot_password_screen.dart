import 'package:flutter/material.dart';

import '../../../../app/design_system.dart';
import '../../../../app/router.dart';
import '../../../../app/theme/app_colors.dart';
import '../../../../core/di.dart';
import '../../../../shared/widgets/form_components.dart';
import '../../../../shared/widgets/municipality_widgets.dart';

class AuthForgotPasswordScreen extends StatefulWidget {
  const AuthForgotPasswordScreen({super.key});

  @override
  State<AuthForgotPasswordScreen> createState() =>
      _AuthForgotPasswordScreenState();
}

class _AuthForgotPasswordScreenState extends State<AuthForgotPasswordScreen> {
  final _contactController = TextEditingController();
  final _formKey = GlobalKey<FormState>();
  bool _isLoading = false;

  @override
  void dispose() {
    _contactController.dispose();
    super.dispose();
  }

  void _sendCode() async {
    if (!_formKey.currentState!.validate()) {
      return;
    }

    setState(() => _isLoading = true);

    try {
      await DI.auth.requestOtp(contact: _contactController.text);
      if (mounted) {
        Navigator.of(context).pushNamed(AppRoutes.otp);
      }
    } catch (e) {
      if (mounted) {
        setState(() => _isLoading = false);
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('فشل إرسال الرمز')),
        );
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
                icon: Icons.lock_outline,
                size: 80,
                iconColor: AppColors.gold,
              ),
            ),
            const SizedBox(height: AppSpacing.xl),

            // Title
            Text(
              'نسيت كلمة المرور',
              textAlign: TextAlign.center,
              style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
            ),
            const SizedBox(height: AppSpacing.md),

            // Description
            Text(
              'أدخل رقم هاتفك أو بريدك الإلكتروني لاسترجاع كلمة المرور',
              textAlign: TextAlign.center,
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                    color: AppColors.muted,
                  ),
            ),
            const SizedBox(height: AppSpacing.xxl),

            // Form
            Form(
              key: _formKey,
              child: AppTextField(
                label: 'رقم الهاتف أو البريد الإلكتروني',
                hint: 'أدخل رقم الهاتف أو البريد',
                controller: _contactController,
                prefixIcon: Icons.person_outline,
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'هذا الحقل مطلوب';
                  }
                  return null;
                },
              ),
            ),
            const SizedBox(height: AppSpacing.xxl),

            // Send button
            SizedBox(
              width: double.infinity,
              height: AppStates.buttonHeight,
              child: FilledButton(
                onPressed: _isLoading ? null : _sendCode,
                child: _isLoading
                    ? const SizedBox(
                        width: 20,
                        height: 20,
                        child: CircularProgressIndicator(
                          strokeWidth: 2,
                          valueColor:
                              AlwaysStoppedAnimation<Color>(Colors.white),
                        ),
                      )
                    : Text('إرسال الرمز',
                        style: Theme.of(context).textTheme.labelLarge?.copyWith(
                              color: Colors.white,
                            )),
              ),
            ),
            const SizedBox(height: AppSpacing.lg),

            // Back button
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: Text(
                'العودة إلى تسجيل الدخول',
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
