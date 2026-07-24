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
      // محاكاة مرور مدة شاشة البداية البالغة ثانيتين.
      await tester.pump(const Duration(seconds: 2));

      // إكمال حركة الانتقال إلى شاشة تسجيل الدخول.
      await tester.pumpAndSettle();

      expect(find.text('تسجيل الدخول'), findsWidgets);
      expect(
        find.text('رقم الهاتف أو البريد الإلكتروني'),
        findsOneWidget,
      );
      expect(find.text('هل نسيت كلمة المرور؟'), findsOneWidget);
      expect(
        find.textContaining(
          'إنشاء حساب جديد',
          findRichText: true,
        ),
        findsOneWidget,
      );
    },
  );
}
