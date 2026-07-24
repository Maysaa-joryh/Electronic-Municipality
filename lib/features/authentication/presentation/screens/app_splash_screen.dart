import 'package:flutter/material.dart';

import '../../../../app/design_system.dart';
import '../../../../app/router.dart';
import '../../../../app/theme/app_colors.dart';
import '../../../../shared/widgets/municipality_widgets.dart';

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
