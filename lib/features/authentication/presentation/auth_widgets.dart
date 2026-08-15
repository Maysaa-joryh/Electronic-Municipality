import 'package:flutter/material.dart' hide Text;
import 'package:electronic_municipality/l10n/localized_text.dart';
import 'package:electronic_municipality/app/router.dart';
import 'package:electronic_municipality/app/theme/app_colors.dart';
import 'package:electronic_municipality/core/di.dart';
import 'package:electronic_municipality/core/network/api_exception.dart';

class AuthLoginButton extends StatefulWidget {
  const AuthLoginButton({super.key});

  @override
  State<AuthLoginButton> createState() => _AuthLoginButtonState();
}

class _AuthLoginButtonState extends State<AuthLoginButton> {
  bool _loading = false;

  Future<void> _login() async {
    setState(() => _loading = true);
    try {
      await DI.auth.login(identifier: 'demo@example.sy', password: 'password');
      if (!mounted) return;
      Navigator.of(context).pushReplacementNamed(AppRoutes.shell);
    } catch (error, stackTrace) {
      debugPrint('AUTH LOGIN BUTTON ERROR: $error');
      debugPrintStack(stackTrace: stackTrace);
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            error is ApiException
                ? error.message
                : 'فشل تسجيل الدخول. حاول مرة أخرى.',
          ),
        ),
      );
    } finally {
      if (mounted) setState(() => _loading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return _loading
        ? const SizedBox(
            height: 60, child: Center(child: CircularProgressIndicator()))
        : FilledButton.icon(
            onPressed: _login,
            icon: const Icon(Icons.login),
            label: const Text('تسجيل الدخول'),
            style: FilledButton.styleFrom(backgroundColor: AppColors.primary),
          );
  }
}
