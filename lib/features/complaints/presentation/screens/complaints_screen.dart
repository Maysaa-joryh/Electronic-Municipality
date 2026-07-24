import 'package:flutter/material.dart';
import '../../../../app/theme/app_colors.dart';
import '../../../../shared/widgets/municipality_widgets.dart';

class ComplaintsScreen extends StatefulWidget {
  const ComplaintsScreen({super.key});

  @override
  State<ComplaintsScreen> createState() => _ComplaintsScreenState();
}

class _ComplaintsScreenState extends State<ComplaintsScreen> {
  int _mode = 0;

  @override
  Widget build(BuildContext context) {
    return ListView(
      padding: const EdgeInsets.fromLTRB(20, 0, 20, 28),
      children: [
        const SizedBox(height: 12),
        const PageHeader(
          title: 'الشكاوى',
          subtitle: 'إدارة البلاغات والمقترحات بكل سهولة',
          dense: true,
        ),
        const SizedBox(height: 16),
        Row(
          children: [
            Expanded(
              child: _ModeButton(
                label: 'بلاغ جديد',
                selected: _mode == 0,
                onTap: () => setState(() => _mode = 0),
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: _ModeButton(
                label: 'سجل الشكاوى',
                selected: _mode == 1,
                onTap: () => setState(() => _mode = 1),
              ),
            ),
          ],
        ),
        const SizedBox(height: 18),
        if (_mode == 0) ...[
          AppPanel(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                const Text('إضافة شكوى جديدة',
                    style:
                        TextStyle(fontSize: 18, fontWeight: FontWeight.w800)),
                const SizedBox(height: 12),
                const MunicipalityTextField(
                    label: 'العنوان', hint: 'أدخل عنوان الشكوى'),
                const SizedBox(height: 12),
                const MunicipalityTextField(
                    label: 'الوصف', hint: 'اكتب تفاصيل المشكلة', maxLines: 4),
                const SizedBox(height: 12),
                const MunicipalityTextField(
                    label: 'الموقع', hint: 'مثال: المزة / الشارع الرئيسي'),
                const SizedBox(height: 16),
                PrimaryButton(
                    label: 'إرسال البلاغ', icon: Icons.send, onPressed: () {}),
              ],
            ),
          ),
        ] else ...[
          const AppPanel(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Text('الشكاوى السابقة',
                    style:
                        TextStyle(fontSize: 18, fontWeight: FontWeight.w800)),
                SizedBox(height: 12),
                _ComplaintItem(
                  title: 'تسرب مياه في الشارع الرئيسي',
                  status: 'قيد التنفيذ',
                  color: AppColors.gold,
                ),
                SizedBox(height: 12),
                _ComplaintItem(
                  title: 'إنارة شارع معطلة',
                  status: 'تم الحل',
                  color: AppColors.primary,
                ),
              ],
            ),
          ),
        ],
      ],
    );
  }
}

class _ModeButton extends StatelessWidget {
  const _ModeButton(
      {required this.label, required this.selected, required this.onTap});

  final String label;
  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(8),
      child: Container(
        height: 46,
        alignment: Alignment.center,
        decoration: BoxDecoration(
          color: selected ? AppColors.primary : AppColors.surfaceMuted,
          borderRadius: BorderRadius.circular(8),
        ),
        child: Text(
          label,
          style: TextStyle(
            color: selected ? Colors.white : AppColors.text,
            fontWeight: FontWeight.w800,
          ),
        ),
      ),
    );
  }
}

class _ComplaintItem extends StatelessWidget {
  const _ComplaintItem(
      {required this.title, required this.status, required this.color});

  final String title;
  final String status;
  final Color color;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: AppColors.surfaceMuted,
        borderRadius: BorderRadius.circular(8),
      ),
      child: Row(
        children: [
          Expanded(
            child: Text(
              title,
              style: const TextStyle(fontSize: 15, fontWeight: FontWeight.w800),
            ),
          ),
          StatusPill(label: status, color: color, pale: true),
        ],
      ),
    );
  }
}
