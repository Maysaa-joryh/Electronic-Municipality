import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:electronic_municipality/app/app.dart';
import 'package:electronic_municipality/app/router.dart';
import 'package:electronic_municipality/core/di.dart';
import 'package:electronic_municipality/core/repositories/auth_repository.dart';
import 'package:electronic_municipality/features/authentication/presentation/screens/otp_screen.dart';

import 'helpers/widget_test_actions.dart';

void main() {
  testWidgets(
    'login opens the citizen signup form',
    (tester) async {
      await tester.pumpWidget(const AppRoot());
      await tester.pump(const Duration(seconds: 3));
      await tester.pumpAndSettle();

      await tapWhenVisible(
        tester,
        find.byKey(const ValueKey('login_signup_button')),
      );
      await tester.pumpAndSettle();

      expect(find.text('إنشاء حساب مواطن'), findsOneWidget);
      expect(find.text('البيانات الشخصية'), findsOneWidget);
      expect(find.text('بيانات السكن'), findsOneWidget);
      expect(find.text('معلومات الدخول'), findsOneWidget);
      expect(
        find.byKey(const ValueKey('signup_full_name_field')),
        findsOneWidget,
      );
      expect(
        find.byKey(const ValueKey('signup_submit_button')),
        findsOneWidget,
      );
    },
  );

  testWidgets(
    'signup OTP completes registration instead of opening password reset',
    (tester) async {
      const phone = '0991234567';
      final registration = CitizenRegistration(
        fullName: 'أحمد محمد علي',
        dateOfBirth: DateTime(2000),
        placeOfBirth: 'دمشق',
        governorate: 'دمشق',
        nationalId: '01234567890',
        municipality: 'بلدية دمشق',
        phone: phone,
        email: '',
        password: 'test',
        needsSpecialCare: false,
        acceptedTerms: true,
      );

      await DI.auth.requestOtp(contact: phone);

      await tester.pumpWidget(
        MaterialApp(
          home: AuthOtpScreen(
            contact: phone,
            registration: registration,
          ),
          routes: {
            AppRoutes.shell: (_) => const Scaffold(
                  key: ValueKey('registered_shell'),
                ),
          },
        ),
      );

      await tester.enterText(
        find.byKey(const ValueKey('otp_code_field')),
        '1234',
      );
      await tapWhenVisible(
        tester,
        find.byKey(const ValueKey('otp_verify_button')),
      );
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 400));
      await tester.pump(const Duration(milliseconds: 600));
      await tester.pumpAndSettle();

      expect(
        find.byKey(const ValueKey('registered_shell')),
        findsOneWidget,
      );
      expect(find.text('تعيين كلمة مرور جديدة'), findsNothing);
    },
  );
}
