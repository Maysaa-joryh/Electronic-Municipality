import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:electronic_municipality/app/app.dart';

void main() {
  testWidgets(
    'app shows splash then navigates to login',
    (WidgetTester tester) async {
      await tester.pumpWidget(const AppRoot());

      // شاشة البداية تظهر أولًا.
      expect(find.text('بلديتنا الإلكترونية'), findsOneWidget);
      expect(find.text('بوابة المواطن الرقمية'), findsOneWidget);

      // محاكاة مرور مدة شاشة البداية البالغة ثلاث ثوانٍ.
      await tester.pump(const Duration(seconds: 3));

      // إكمال حركة الانتقال إلى شاشة تسجيل الدخول.
      await tester.pumpAndSettle();

      expect(find.text('تسجيل الدخول'), findsWidgets);
      expect(
        find.text('رقم الهاتف أو البريد الإلكتروني'),
        findsOneWidget,
      );
      expect(find.text('نسيت كلمة المرور؟'), findsOneWidget);
      expect(
        find.textContaining(
          'إنشاء حساب جديد',
          findRichText: true,
        ),
        findsOneWidget,
      );
    },
  );

  testWidgets(
    'visitor can enter without credentials',
    (WidgetTester tester) async {
      await tester.pumpWidget(const AppRoot());
      await tester.pump(const Duration(seconds: 3));
      await tester.pumpAndSettle();

      await tester.tap(find.byKey(const ValueKey('visitor_tab')));
      await tester.pump();

      expect(
        find.byKey(const ValueKey('login_identifier_field')),
        findsNothing,
      );
      expect(
        find.byKey(const ValueKey('login_password_field')),
        findsNothing,
      );
      expect(find.text('نسيت كلمة المرور؟'), findsNothing);
      expect(
        find.byKey(const ValueKey('visitor_message')),
        findsOneWidget,
      );

      await tester.tap(find.byKey(const ValueKey('login_submit_button')));
      await tester.pumpAndSettle();

      expect(find.byType(NavigationBar), findsOneWidget);
    },
  );

  testWidgets(
    'password recovery forwards contact and verifies its OTP',
    (WidgetTester tester) async {
      const contact = 'citizen@example.sy';
      final expectedCode =
          (contact.hashCode.abs() % 9000 + 1000).toString();

      await tester.pumpWidget(const AppRoot());
      await tester.pump(const Duration(seconds: 3));
      await tester.pumpAndSettle();

      await tester.tap(find.text('نسيت كلمة المرور؟'));
      await tester.pumpAndSettle();

      expect(find.text('نسيت كلمة المرور'), findsOneWidget);
      expect(
        find.byKey(const ValueKey('forgot_contact_field')),
        findsOneWidget,
      );

      await tester.tap(
        find.byKey(const ValueKey('forgot_send_code_button')),
      );
      await tester.pump();
      expect(
        find.text('رقم الهاتف أو البريد الإلكتروني مطلوب'),
        findsOneWidget,
      );

      await tester.enterText(
        find.byKey(const ValueKey('forgot_contact_field')),
        contact,
      );
      await tester.tap(
        find.byKey(const ValueKey('forgot_send_code_button')),
      );
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 500));
      await tester.pumpAndSettle();

      expect(find.text('رمز التحقق'), findsOneWidget);
      expect(
        find.textContaining('بريدك الإلكتروني'),
        findsOneWidget,
      );

      await tester.tap(find.byKey(const ValueKey('otp_resend_button')));
      await tester.pump();
      expect(
        find.textContaining(
          'لا يمكنك إعادة إرسال الرمز قبل انتهاء المدة',
        ),
        findsOneWidget,
      );

      await tester.tap(find.byKey(const ValueKey('otp_verify_button')));
      await tester.pump();
      expect(
        find.text('أدخل رمز التحقق المكون من 4 أرقام.'),
        findsOneWidget,
      );

      await tester.enterText(
        find.byKey(const ValueKey('otp_code_field')),
        expectedCode,
      );

      for (var index = 0; index < expectedCode.length; index++) {
        expect(
          find.descendant(
            of: find.byKey(ValueKey('otp_digit_$index')),
            matching: find.text(expectedCode[index]),
          ),
          findsOneWidget,
        );
      }

      await tester.tap(find.byKey(const ValueKey('otp_verify_button')));
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 400));
      await tester.pumpAndSettle();

      expect(find.text('تعيين كلمة مرور جديدة'), findsOneWidget);
    },
  );

  testWidgets(
    'OTP accepts consecutive Arabic digits and resend waits for user action',
    (WidgetTester tester) async {
      const contact = 'citizen@example.sy';

      await tester.pumpWidget(const AppRoot());
      await tester.pump(const Duration(seconds: 3));
      await tester.pumpAndSettle();
      await tester.tap(find.text('نسيت كلمة المرور؟'));
      await tester.pumpAndSettle();
      await tester.enterText(
        find.byKey(const ValueKey('forgot_contact_field')),
        contact,
      );
      await tester.tap(
        find.byKey(const ValueKey('forgot_send_code_button')),
      );
      await tester.pump(const Duration(milliseconds: 500));
      await tester.pumpAndSettle();

      final codeField = find.byKey(const ValueKey('otp_code_field'));
      await tester.tap(codeField);
      for (final value in ['١', '١٢', '١٢٣', '١٢٣٤']) {
        await tester.enterText(codeField, value);
        await tester.pump();
      }

      for (var index = 0; index < 4; index++) {
        expect(
          find.descendant(
            of: find.byKey(ValueKey('otp_digit_$index')),
            matching: find.text('${index + 1}'),
          ),
          findsOneWidget,
        );
      }

      await tester.pump(const Duration(seconds: 60));
      expect(
        find.text('تمت إعادة إرسال رمز التحقق بنجاح.'),
        findsNothing,
      );

      await tester.tap(find.byKey(const ValueKey('otp_resend_button')));
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 500));
      await tester.pump();

      expect(
        find.text('تمت إعادة إرسال رمز التحقق بنجاح.'),
        findsOneWidget,
      );
    },
  );
}
