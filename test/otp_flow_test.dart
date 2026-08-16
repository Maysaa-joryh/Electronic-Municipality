import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:electronic_municipality/app/app.dart';
import 'package:electronic_municipality/app/router.dart';
import 'package:electronic_municipality/core/di.dart';
import 'package:electronic_municipality/core/repositories/auth_repository.dart';
import 'package:electronic_municipality/features/authentication/data/auth_repository_fake.dart';
import 'package:electronic_municipality/features/authentication/presentation/screens/otp_screen.dart';

import 'helpers/widget_test_actions.dart';

void main() {
  setUp(() {
    DI.overrideAuth(AuthRepositoryFake());
  });

  tearDown(DI.resetAuth);

  test(
    'citizen registration does not create a fake authenticated session',
    () async {
      final repository = AuthRepositoryFake();

      await repository.registerCitizen(
        registration: CitizenRegistration(
          fullName: 'مواطن جديد',
          nationalId: '12345678901',
          dateOfBirth: DateTime(1998, 1, 1),
          placeOfBirth: 'دمشق',
          municipalityId: 10,
          gender: CitizenGender.male,
          phone: '0990000000',
          email: 'new-citizen@example.sy',
          password: 'SafePassword123!',
          needsSpecialCare: false,
          acceptedTerms: true,
        ),
      );

      expect(
        await repository.restoreSession(),
        AuthStartupDestination.login,
      );
    },
  );

  test(
    'account confirmation marker blocks login until OTP completes',
    () async {
      final repository = AuthRepositoryFake();
      const contact = 'pending-citizen@example.sy';

      await repository.markAccountConfirmationPending(contact: contact);
      expect(
        await repository.hasPendingAccountConfirmation(contact: contact),
        isTrue,
      );

      await repository.completeAccountConfirmation(contact: contact);
      expect(
        await repository.hasPendingAccountConfirmation(contact: contact),
        isFalse,
      );
    },
  );

  testWidgets(
    'password recovery accepts a complete OTP entered at once',
    (tester) async {
      const contact = 'otp-test@example.sy';
      const expectedCode = '1234';

      await tester.pumpWidget(const AppRoot());
      await tester.pump(const Duration(seconds: 3));
      await tester.pumpAndSettle();

      await tapWhenVisible(tester, find.text('نسيت كلمة المرور؟'));
      await tester.pumpAndSettle();
      await tester.enterText(
        find.byKey(const ValueKey('forgot_contact_field')),
        contact,
      );
      await tapWhenVisible(
        tester,
        find.byKey(const ValueKey('forgot_send_code_button')),
      );
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 500));
      await tester.pumpAndSettle();

      final codeField = find.byKey(const ValueKey('otp_code_field'));
      expect(codeField, findsOneWidget);

      await tester.enterText(codeField, expectedCode);
      await tester.pump();

      for (var index = 0; index < expectedCode.length; index++) {
        expect(
          find.descendant(
            of: find.byKey(ValueKey('otp_digit_$index')),
            matching: find.text(expectedCode[index]),
          ),
          findsOneWidget,
        );
      }

      await tapWhenVisible(
        tester,
        find.byKey(const ValueKey('otp_verify_button')),
      );
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 400));
      await tester.pumpAndSettle();

      expect(find.text('تعيين كلمة مرور جديدة'), findsOneWidget);

      // Dispose the OTP route so its resend timer cannot leak past the test.
      await tester.pumpWidget(const SizedBox.shrink());
      await tester.pump();
    },
  );

  testWidgets(
    'account confirmation returns to login without opening password reset',
    (tester) async {
      const contact = 'new-citizen@example.sy';

      await tester.pumpWidget(
        MaterialApp(
          home: const AuthOtpScreen(
            contact: contact,
            purpose: AuthOtpPurpose.accountConfirmation,
          ),
          routes: <String, WidgetBuilder>{
            AppRoutes.login: (_) => const Scaffold(
                  body: Center(child: Text('تسجيل الدخول بعد التأكيد')),
                ),
          },
        ),
      );

      final otpRequest = DI.auth.requestOtp(contact: contact);
      await tester.pump(const Duration(milliseconds: 500));
      await otpRequest;
      await tester.pumpAndSettle();

      expect(
        find.byKey(const ValueKey('otp_verify_button')),
        findsOneWidget,
      );
      await tester.enterText(
        find.byKey(const ValueKey('otp_code_field')),
        AuthRepositoryFake.developmentOtpCode,
      );
      await tapWhenVisible(
        tester,
        find.byKey(const ValueKey('otp_verify_button')),
      );
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 400));
      await tester.pumpAndSettle();

      expect(find.text('تسجيل الدخول بعد التأكيد'), findsOneWidget);
      expect(find.text('تعيين كلمة مرور جديدة'), findsNothing);
    },
  );

  testWidgets(
    'returning from OTP restores forgot-password actions',
    (tester) async {
      await tester.pumpWidget(const AppRoot());
      await tester.pump(const Duration(seconds: 3));
      await tester.pumpAndSettle();

      await tapWhenVisible(tester, find.text('نسيت كلمة المرور؟'));
      await tester.pumpAndSettle();
      await tester.enterText(
        find.byKey(const ValueKey('forgot_contact_field')),
        'back-test@example.sy',
      );
      await tapWhenVisible(
        tester,
        find.byKey(const ValueKey('forgot_send_code_button')),
      );
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 500));
      await tester.pumpAndSettle();

      expect(find.text('رمز التحقق'), findsOneWidget);

      await tapWhenVisible(
        tester,
        find.byKey(const ValueKey('otp_back_button')),
      );
      await tester.pumpAndSettle();

      expect(find.text('نسيت كلمة المرور'), findsOneWidget);

      final sendCodeButton = tester.widget<FilledButton>(
        find.byKey(const ValueKey('forgot_send_code_button')),
      );
      final backButton = tester.widget<TextButton>(
        find.byKey(const ValueKey('forgot_back_button')),
      );

      expect(sendCodeButton.onPressed, isNotNull);
      expect(backButton.onPressed, isNotNull);
    },
  );
}
