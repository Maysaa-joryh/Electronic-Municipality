import 'package:flutter/material.dart';
import '../features/authentication/presentation/screens/auth_screens.dart';
import '../features/home/presentation/screens/app_shell.dart';
import '../features/profile/presentation/screens/profile_screen.dart';
import 'router.dart';
import 'theme/app_theme.dart';

class AppRoot extends StatelessWidget {
  const AppRoot({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'E-Municipality',
      theme: buildAppTheme(),
      builder: (context, child) {
        return Directionality(
          textDirection: TextDirection.rtl,
          child: child ?? const SizedBox.shrink(),
        );
      },
      initialRoute: AppRoutes.splash,
      onGenerateRoute: (settings) {
        final routeName = settings.name;

        if (routeName == AppRoutes.shell) {
          final initialIndex =
              settings.arguments is int ? settings.arguments as int : 0;
          return MaterialPageRoute<void>(
            builder: (_) => AppShell(initialIndex: initialIndex),
          );
        }

        final Widget page = switch (routeName) {
          AppRoutes.login => const AuthLoginScreen(),
          AppRoutes.signup => const AuthSignupScreen(),
          AppRoutes.forgot => const AuthForgotPasswordScreen(),
          AppRoutes.otp => AuthOtpScreen.fromRouteArguments(settings.arguments),
          AppRoutes.reset => AuthResetPasswordScreen(
              contact: settings.arguments is String
                  ? settings.arguments as String
                  : '',
            ),
          AppRoutes.profile => const ProfileScreen(),
          _ => const AppSplashScreen(),
        };

        return MaterialPageRoute<void>(builder: (_) => page);
      },
    );
  }
}
