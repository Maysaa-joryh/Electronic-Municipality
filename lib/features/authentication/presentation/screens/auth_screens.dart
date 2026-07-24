import 'package:flutter/material.dart';
import '../../../../app/design_system.dart';
import '../../../../app/router.dart';
import '../../../../app/theme/app_colors.dart';
import '../../../../core/di.dart';
import '../../../../shared/widgets/form_components.dart';
import '../../../../shared/widgets/municipality_widgets.dart';

// ==================== SPLASH SCREEN ====================
class AppSplashScreen extends StatefulWidget {
  const AppSplashScreen({super.key});

  @override
  State<AppSplashScreen> createState() => _AppSplashScreenState();
}

class _AppSplashScreenState extends State<AppSplashScreen> {
  @override
  void initState() {
    super.initState();
    _navigateToLogin();
  }

  void _navigateToLogin() {
    Future.delayed(
      const Duration(milliseconds: 2000),
      () {
        if (mounted) {
          Navigator.of(context).pushReplacementNamed(AppRoutes.login);
        }
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: BoxDecoration(
          gradient: RadialGradient(
            center: Alignment.center,
            radius: 1.5,
            colors: [
              AppColors.emerald,
              AppColors.emerald.withOpacity(0.7),
              AppColors.deepPrimary,
            ],
          ),
        ),
        child: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const MunicipalityLogo(size: 120),
              const SizedBox(height: AppSpacing.xl),
              Text(
                'الخدمات الإلكترونية',
                style: Theme.of(context).textTheme.headlineLarge?.copyWith(
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                    ),
              ),
              const SizedBox(height: AppSpacing.sm),
              Text(
                'الجمهورية العربية السورية',
                style: Theme.of(context).textTheme.titleMedium?.copyWith(
                      color: AppColors.gold,
                    ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

// ==================== LOGIN SCREEN ====================
class AuthLoginScreen extends StatefulWidget {
  const AuthLoginScreen({super.key});

  @override
  State<AuthLoginScreen> createState() => _AuthLoginScreenState();
}

class _AuthLoginScreenState extends State<AuthLoginScreen> {
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _formKey = GlobalKey<FormState>();
  bool _isLoading = false;
  String? _errorMessage;
  int _selectedTab = 0; // 0: citizen, 1: visitor

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  void _login() async {
    if (!_formKey.currentState!.validate()) {
      return;
    }

    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    try {
      await DI.auth.login(
        identifier: _emailController.text,
        password: _passwordController.text,
      );

      if (mounted) {
        Navigator.of(context).pushReplacementNamed(AppRoutes.shell);
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _errorMessage = 'فشل تسجيل الدخول. تحقق من بيانات الدخول.';
          _isLoading = false;
        });
      }
    }
  }

  Widget _buildTabButton(String label, int index) {
    final isSelected = _selectedTab == index;
    return Expanded(
      child: GestureDetector(
        onTap: () => setState(() => _selectedTab = index),
        child: Container(
          padding: const EdgeInsets.symmetric(
            horizontal: AppSpacing.lg,
            vertical: AppSpacing.md,
          ),
          decoration: BoxDecoration(
            color: isSelected ? AppColors.background : Colors.transparent,
            borderRadius: BorderRadius.circular(AppRadius.md),
          ),
          child: Text(
            label,
            textAlign: TextAlign.center,
            style: Theme.of(context).textTheme.titleMedium?.copyWith(
                  color: isSelected ? AppColors.primary : AppColors.muted,
                ),
          ),
        ),
      ),
    );
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

            // Tab selector
            Container(
              padding: const EdgeInsets.all(AppSpacing.sm),
              decoration: BoxDecoration(
                color: AppColors.surface,
                borderRadius: BorderRadius.circular(AppRadius.md),
                border: Border.all(color: AppColors.border),
              ),
              child: Row(
                children: [
                  _buildTabButton('مواطن', 0),
                  _buildTabButton('زائر', 1),
                ],
              ),
            ),
            const SizedBox(height: AppSpacing.xl),

            // Login title
            Text(
              'تسجيل الدخول',
              textAlign: TextAlign.center,
              style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
            ),
            const SizedBox(height: AppSpacing.md),
            Text(
              'أدخل بياناتك للوصول إلى الخدمات البلدية',
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
                children: [
                  AppTextField(
                    label: 'رقم الهاتف أو البريد الإلكتروني',
                    hint: 'أدخل رقم الهاتف أو البريد',
                    controller: _emailController,
                    prefixIcon: Icons.person_outline,
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'هذا الحقل مطلوب';
                      }
                      return null;
                    },
                  ),
                  const SizedBox(height: AppSpacing.lg),
                  PasswordField(
                    controller: _passwordController,
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'كلمة المرور مطلوبة';
                      }
                      return null;
                    },
                  ),
                ],
              ),
            ),
            const SizedBox(height: AppSpacing.lg),

            // Forgot password link
            Align(
              alignment: Alignment.centerRight,
              child: TextButton(
                onPressed: () =>
                    Navigator.of(context).pushNamed(AppRoutes.forgot),
                child: Text(
                  'هل نسيت كلمة المرور؟',
                  style: Theme.of(context).textTheme.bodySmall?.copyWith(
                        color: AppColors.gold,
                      ),
                ),
              ),
            ),
            const SizedBox(height: AppSpacing.lg),

            // Login button
            SizedBox(
              width: double.infinity,
              height: AppStates.buttonHeight,
              child: FilledButton(
                onPressed: _isLoading ? null : _login,
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
                    : Text('تسجيل الدخول',
                        style: Theme.of(context).textTheme.labelLarge?.copyWith(
                              color: Colors.white,
                            )),
              ),
            ),
            const SizedBox(height: AppSpacing.xl),

            // Sign up link
            Center(
              child: RichText(
                text: TextSpan(
                  text: 'ليس لديك حساب؟ ',
                  style: Theme.of(context).textTheme.bodySmall,
                  children: [
                    TextSpan(
                      text: 'إنشاء حساب جديد',
                      style: Theme.of(context).textTheme.bodySmall?.copyWith(
                            color: AppColors.gold,
                            fontWeight: FontWeight.bold,
                          ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// ==================== FORGOT PASSWORD SCREEN ====================
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

// ==================== OTP SCREEN ====================
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

// ==================== RESET PASSWORD SCREEN ====================
class AuthResetPasswordScreen extends StatefulWidget {
  const AuthResetPasswordScreen({super.key});

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
      // Use test contact - in real app this would come from context
      await DI.auth.resetPassword(
        contact: 'test@example.com',
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
