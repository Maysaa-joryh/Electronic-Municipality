import 'package:flutter/material.dart';
import '../../../../app/theme/app_colors.dart';
import '../../../../shared/widgets/municipality_widgets.dart';

class ProfileScreen extends StatelessWidget {
  const ProfileScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        bottom: false,
        child: ListView(
          padding: const EdgeInsets.fromLTRB(20, 0, 20, 28),
          children: [
            SizedBox(
              height: 56,
              child: Row(
                children: [
                  const MunicipalityLogo(size: 42),
                  const Spacer(),
                  const Text(
                    'الملف الشخصي',
                    style: TextStyle(fontSize: 20, fontWeight: FontWeight.w800),
                  ),
                  const Spacer(),
                  IconButton(
                    tooltip: 'رجوع',
                    onPressed: () => Navigator.of(context).maybePop(),
                    icon: const Icon(Icons.arrow_back),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 24),
            AppPanel(
              child: Column(
                children: const [
                  CircleIcon(icon: Icons.person_outline, size: 84),
                  SizedBox(height: 16),
                  Text(
                    'أحمد محمود السالم',
                    style: TextStyle(fontSize: 24, fontWeight: FontWeight.w800),
                  ),
                  SizedBox(height: 8),
                  StatusPill(
                      label: 'غير موثق',
                      color: AppColors.danger,
                      pale: true,
                      icon: Icons.error_outline),
                  SizedBox(height: 12),
                  Text('0933 123 456',
                      style: TextStyle(color: AppColors.muted, fontSize: 14)),
                  SizedBox(height: 3),
                  Text('ahmad.salem@example.sy',
                      style: TextStyle(color: AppColors.muted, fontSize: 14)),
                ],
              ),
            ),
            const SizedBox(height: 18),
            AppPanel(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  const Row(
                    children: [
                      Icon(Icons.verified_user_outlined, color: AppColors.gold),
                      SizedBox(width: 8),
                      Expanded(
                          child: Text('توثيق الحساب مطلوب',
                              style: TextStyle(
                                  fontSize: 17, fontWeight: FontWeight.w800))),
                    ],
                  ),
                  const SizedBox(height: 10),
                  const Text(
                      'للوصول إلى كافة الخدمات والمعاملات الرسمية، يرجى توثيق حسابك عن طريق المستندات المطلوبة.',
                      style: TextStyle(color: AppColors.muted, fontSize: 14)),
                  const SizedBox(height: 14),
                  PrimaryButton(
                      label: 'توثيق الحساب الآن',
                      dense: true,
                      onPressed: () {}),
                ],
              ),
            ),
            const SizedBox(height: 18),
            AppPanel(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: const [
                  CardTitleRow(
                      icon: Icons.badge_outlined,
                      title: 'البيانات الشخصية',
                      action: 'تعديل'),
                  Divider(height: 28),
                  InfoNotice(
                      text:
                          'ملاحظة: تعديل البيانات الشخصية الأساسية قد يتطلب إعادة توثيق الحساب لاحقاً.'),
                  SizedBox(height: 16),
                  ReadonlyField(
                      label: 'الاسم الكامل (كما في الهوية)',
                      value: 'أحمد محمود السالم'),
                  SizedBox(height: 12),
                  ReadonlyField(label: 'تاريخ الميلاد', value: '05/15/1985'),
                  SizedBox(height: 12),
                  ReadonlyField(
                      label: 'المحافظة (السكن الحالي)', value: 'دمشق'),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
