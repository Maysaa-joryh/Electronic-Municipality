import 'package:flutter/material.dart';

import '../../../../app/design_system.dart';
import '../../../../app/router.dart';
import '../../../../app/theme/app_colors.dart';
import '../../../../core/di.dart';
import '../../../../shared/widgets/form_components.dart';
import '../../../../shared/widgets/municipality_widgets.dart';

class AuthResetPasswordScreen extends StatefulWidget {
  const AuthResetPasswordScreen({
    super.key,
    required this.contact,
  });

  final String contact;

  @override
  State<AuthResetPasswordScreen> createState() =>
      _AuthResetPasswordScreenState();
}

class _AuthResetPasswordScreenState extends State<AuthResetPasswordScreen> {
  final _newPasswordController = TextEditingController();
  final _confirmPasswordController = TextEditingController();
  final _formKey = GlobalKey<FormState>();
  bool _isLoading = false;
  String? _errorMessage;

  @override
  void dispose() {
    _newPasswordController.dispose();
    _confirmPasswordController.dispose();
    super.dispose();
  }

  void _resetPassword() async {
    if (!_formKey.currentState!.validate()) {
      return;
    }

    if (_newPasswordController.text != _confirmPasswordController.text) {
      setState(() {
        _errorMessage = 'كلمات المرور غير متطابقة';
      });
      return;
    }

    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    try {
      await DI.auth.resetPassword(
        contact: widget.contact,
        newPassword: _newPasswordController.text,
      );
      if (mounted) {
        Navigator.of(context)
            .pushNamedAndRemoveUntil(AppRoutes.login, (route) => false);
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _errorMessage = 'فشل تعيين كلمة المرور الجديدة';
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
                icon: Icons.lock_outline,
                size: 80,
                color: AppColors.mint,
                iconColor: AppColors.primary,
              ),
            ),
            const SizedBox(height: AppSpacing.xl),

            // Title
            Text(
              'تعيين كلمة مرور جديدة',
              textAlign: TextAlign.center,
              style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
            ),
            const SizedBox(height: AppSpacing.md),

            // Description
            Text(
              'الرجاء إدخال كلمة المرور الجديدة وتأكيدها',
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

            // Form
            Form(
              key: _formKey,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'كلمة المرور الجديدة',
                    style: Theme.of(context).textTheme.titleMedium?.copyWith(
                          fontWeight: FontWeight.bold,
                        ),
                  ),
                  const SizedBox(height: AppSpacing.sm),
                  PasswordField(
                    controller: _newPasswordController,
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'كلمة المرور مطلوبة';
                      }
                      if (value.length < 8) {
                        return 'كلمة المرور يجب أن تكون 8 أحرف على الأقل';
                      }
                      return null;
                    },
                  ),
                  const SizedBox(height: AppSpacing.xl),
                  Text(
                    'تأكيد كلمة المرور',
                    style: Theme.of(context).textTheme.titleMedium?.copyWith(
                          fontWeight: FontWeight.bold,
                        ),
                  ),
                  const SizedBox(height: AppSpacing.sm),
                  PasswordField(
                    controller: _confirmPasswordController,
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'تأكيد كلمة المرور مطلوب';
                      }
                      return null;
                    },
                  ),
                  const SizedBox(height: AppSpacing.xl),
                  PasswordStrengthIndicator(
                    password: _newPasswordController.text,
                  ),
                ],
              ),
            ),
            const SizedBox(height: AppSpacing.xxl),

            // Reset button
            SizedBox(
              width: double.infinity,
              height: AppStates.buttonHeight,
              child: FilledButton(
                onPressed: _isLoading ? null : _resetPassword,
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
                    : Text('تغيير كلمة المرور',
                        style: Theme.of(context).textTheme.labelLarge?.copyWith(
                              color: Colors.white,
                            )),
              ),
            ),
            const SizedBox(height: AppSpacing.lg),

            // Back button
            TextButton(
              onPressed: () => Navigator.of(context)
                  .pushNamedAndRemoveUntil(AppRoutes.login, (route) => false),
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
