import 'package:flutter/material.dart';
import '../../../../app/router.dart';
import '../../../../app/theme/app_colors.dart';
import '../../../../core/di.dart';
import '../../../../core/network/api_exception.dart';
import '../../../../shared/widgets/municipality_widgets.dart';

class SettingsScreen extends StatefulWidget {
  const SettingsScreen({super.key, required this.onOpenProfile});
  final VoidCallback onOpenProfile;

  @override
  State<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen> {
  bool _isLoggingOut = false;

  Future<void> _logout() async {
    if (_isLoggingOut) return;
    setState(() => _isLoggingOut = true);

    String? warningMessage;

    try {
      await DI.auth.logout();
    } catch (error) {
      warningMessage = error is ApiException
          ? '${error.message} تم إنهاء الجلسة محليًا.'
          : 'تعذر إبلاغ الخادم، لكن تم إنهاء الجلسة محليًا.';
    } finally {
      if (mounted) setState(() => _isLoggingOut = false);
    }

    if (!mounted) return;

    Navigator.of(context).pushNamedAndRemoveUntil(
      AppRoutes.login,
      (route) => false,
    );

    if (warningMessage != null) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(warningMessage)),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return ListView(
        padding: const EdgeInsets.fromLTRB(24, 18, 24, 28),
        children: [
          const PageHeader(
              title: 'الإعدادات', subtitle: 'إدارة الحساب والتفضيلات'),
          const SizedBox(height: 24),
          _SettingsTile(
              icon: Icons.person_outline,
              title: 'الملف الشخصي',
              subtitle: 'البيانات الشخصية ومستندات التوثيق',
              onTap: widget.onOpenProfile),
          const SizedBox(height: 12),
          const _SettingsTile(
              icon: Icons.notifications_none,
              title: 'الإشعارات',
              subtitle: 'تنبيهات المعاملات والمنطقة'),
          const SizedBox(height: 12),
          const _SettingsTile(
              icon: Icons.language, title: 'اللغة', subtitle: 'العربية'),
          const SizedBox(height: 12),
          const _SettingsTile(
              icon: Icons.info_outline,
              title: 'حول التطبيق',
              subtitle: 'بوابة المواطن الرقمية - الإصدار 1.0'),
          const SizedBox(height: 12),
          _SettingsTile(
            icon: Icons.logout_rounded,
            title: _isLoggingOut ? 'جارٍ تسجيل الخروج...' : 'تسجيل الخروج',
            subtitle: 'إنهاء الجلسة الحالية بأمان',
            onTap: _isLoggingOut ? null : _logout,
          ),
        ]);
  }
}

class _SettingsTile extends StatelessWidget {
  const _SettingsTile(
      {required this.icon,
      required this.title,
      required this.subtitle,
      this.onTap});
  final IconData icon;
  final String title;
  final String subtitle;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    return InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(8),
        child: AppPanel(
            padding: const EdgeInsets.symmetric(
              horizontal: 18,
              vertical: 16,
            ),
            child: Row(children: [
              CircleIcon(icon: icon, iconColor: AppColors.primary),
              const SizedBox(width: 14),
              Expanded(
                  child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                    Text(title,
                        style: const TextStyle(
                            fontSize: 17, fontWeight: FontWeight.w800)),
                    const SizedBox(height: 4),
                    Text(subtitle,
                        style: const TextStyle(
                            color: AppColors.muted, fontSize: 13))
                  ])),
              const Icon(Icons.chevron_left, color: AppColors.muted)
            ])));
  }
}
