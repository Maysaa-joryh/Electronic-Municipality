import 'package:flutter/material.dart';
import '../../../../app/theme/app_colors.dart';
import '../../../../shared/widgets/municipality_widgets.dart';

class TransactionsScreen extends StatelessWidget {
  const TransactionsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return ListView(
        padding: const EdgeInsets.fromLTRB(24, 18, 24, 28),
        children: const [
          PageHeader(title: 'المعاملات', subtitle: 'متابعة الطلبات الرسمية'),
          SizedBox(height: 24),
          TransactionCard(
              status: 'قيد المراجعة',
              title: 'طلب رخصة بناء',
              id: 'TRX-2023-441',
              icon: Icons.apartment_outlined),
          SizedBox(height: 14),
          TransactionCard(
              status: 'مكتملة',
              title: 'إخراج قيد عقاري',
              id: 'TRX-2023-396',
              icon: Icons.description_outlined,
              done: true),
          SizedBox(height: 14),
          TransactionCard(
              status: 'بانتظار الدفع',
              title: 'تسديد رسوم النظافة',
              id: 'TRX-2023-358',
              icon: Icons.payments_outlined),
        ]);
  }
}

class TransactionCard extends StatelessWidget {
  const TransactionCard(
      {super.key,
      required this.status,
      required this.title,
      required this.id,
      required this.icon,
      this.done = false});

  final String status;
  final String title;
  final String id;
  final IconData icon;
  final bool done;

  @override
  Widget build(BuildContext context) {
    return AppPanel(
        padding: const EdgeInsets.all(18),
        child: Row(children: [
          CircleIcon(
              icon: icon,
              color: done ? const Color(0xFFDDE7E0) : AppColors.surfaceMuted,
              iconColor: done ? AppColors.primary : AppColors.gold),
          const SizedBox(width: 16),
          Expanded(
              child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                Text(title,
                    style: const TextStyle(
                        fontSize: 18, fontWeight: FontWeight.w800)),
                const SizedBox(height: 4),
                Text(id, style: const TextStyle(color: AppColors.muted))
              ])),
          StatusPill(
              label: status, color: done ? AppColors.primary : AppColors.gold)
        ]));
  }
}
