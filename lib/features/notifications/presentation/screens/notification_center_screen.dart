import 'package:flutter/material.dart' hide Text;

import '../../../../app/theme/app_colors.dart';
import '../../../../core/notifications/push_notification_service.dart';
import '../../../../l10n/app_localizations.dart';
import '../../../../l10n/localized_text.dart';
import '../../../../shared/widgets/municipality_widgets.dart';

class NotificationCenterDialog extends StatelessWidget {
  const NotificationCenterDialog({
    super.key,
    required this.pushNotifications,
    required this.onOpenIntent,
  });

  final PushNotificationService pushNotifications;
  final Future<void> Function(PushNotificationIntent intent) onOpenIntent;

  @override
  Widget build(BuildContext context) {
    final maxHeight = MediaQuery.sizeOf(context).height * 0.78;

    return Dialog(
      insetPadding: const EdgeInsets.symmetric(horizontal: 18, vertical: 28),
      backgroundColor: AppColors.background,
      surfaceTintColor: Colors.transparent,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
      clipBehavior: Clip.antiAlias,
      child: ConstrainedBox(
        constraints: BoxConstraints(
          minWidth: 300,
          maxWidth: 520,
          maxHeight: maxHeight,
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            _NotificationDialogHeader(pushNotifications: pushNotifications),
            const Divider(height: 1, color: AppColors.border),
            Flexible(
              child: ValueListenableBuilder<List<PushInboxItem>>(
                valueListenable: pushNotifications.inbox,
                builder: (context, items, _) {
                  if (items.isEmpty) return const _EmptyNotificationState();

                  return ListView.separated(
                    shrinkWrap: true,
                    padding: const EdgeInsets.fromLTRB(16, 16, 16, 20),
                    itemCount: items.length,
                    separatorBuilder: (_, __) => const SizedBox(height: 10),
                    itemBuilder: (context, index) {
                      final item = items[index];
                      return _NotificationTile(
                        item: item,
                        onTap: () async {
                          await pushNotifications.markRead(item.id);
                          final intent = item.intent;
                          if (intent != null) await onOpenIntent(intent);
                        },
                      );
                    },
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _NotificationDialogHeader extends StatelessWidget {
  const _NotificationDialogHeader({required this.pushNotifications});

  final PushNotificationService pushNotifications;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(18, 18, 12, 16),
      child: Row(
        children: [
          const CircleIcon(
            icon: Icons.notifications_active_outlined,
            size: 48,
            color: Color(0xFFDCEBE1),
            iconColor: AppColors.primary,
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  context.tr('مركز الإشعارات'),
                  style: const TextStyle(
                    color: AppColors.text,
                    fontSize: 19,
                    fontWeight: FontWeight.w900,
                  ),
                ),
                const SizedBox(height: 3),
                ValueListenableBuilder<List<PushInboxItem>>(
                  valueListenable: pushNotifications.inbox,
                  builder: (context, items, _) => Text(
                    items.isEmpty
                        ? context.tr('لا توجد إشعارات بعد')
                        : '${items.length} ${context.tr('إشعارات محفوظة على هذا الجهاز')}',
                    style: const TextStyle(
                      color: AppColors.muted,
                      fontSize: 12,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
              ],
            ),
          ),
          ValueListenableBuilder<List<PushInboxItem>>(
            valueListenable: pushNotifications.inbox,
            builder: (context, items, _) {
              final hasUnread = items.any((item) => !item.isRead);
              if (!hasUnread) return const SizedBox.shrink();
              return TextButton(
                onPressed: pushNotifications.markAllRead,
                child: Text(
                  context.tr('تحديد الكل كمقروء'),
                  style: const TextStyle(
                    color: AppColors.primary,
                    fontSize: 11,
                    fontWeight: FontWeight.w800,
                  ),
                ),
              );
            },
          ),
          IconButton(
            tooltip: context.tr('إغلاق'),
            onPressed: () => Navigator.of(context).pop(),
            icon: const Icon(Icons.close_rounded, color: AppColors.muted),
          ),
        ],
      ),
    );
  }
}

class _EmptyNotificationState extends StatelessWidget {
  const _EmptyNotificationState();

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(28, 42, 28, 48),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          const CircleIcon(
            icon: Icons.notifications_none_rounded,
            size: 68,
            color: Color(0xFFE4EEE8),
            iconColor: AppColors.primary,
          ),
          const SizedBox(height: 18),
          Text(
            context.tr('لا توجد إشعارات بعد'),
            style: const TextStyle(fontSize: 19, fontWeight: FontWeight.w900),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 8),
          Text(
            context.tr('ستظهر هنا تحديثات معاملاتك وشكاواك عند وصولها.'),
            style: const TextStyle(color: AppColors.muted, height: 1.55),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }
}

class _NotificationTile extends StatelessWidget {
  const _NotificationTile({required this.item, required this.onTap});

  final PushInboxItem item;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final isUnread = !item.isRead;
    final intent = item.intent;
    final hasDetails = intent != null &&
        (intent.entityId != null || (intent.status?.trim().isNotEmpty ?? false));

    return Material(
      color: isUnread ? const Color(0xFFEAF4EF) : AppColors.surface,
      borderRadius: BorderRadius.circular(16),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(16),
        child: Container(
          padding: const EdgeInsets.fromLTRB(14, 14, 12, 13),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(16),
            border: Border.all(
              color: isUnread ? const Color(0xFF9FC9B2) : AppColors.border,
              width: isUnread ? 1.4 : 1,
            ),
          ),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              CircleIcon(
                icon: intent?.opensServiceRequest == true
                    ? Icons.receipt_long_outlined
                    : Icons.notifications_none_rounded,
                size: 46,
                color: isUnread
                    ? const Color(0xFFD8EADD)
                    : AppColors.surfaceMuted,
                iconColor: AppColors.primary,
              ),
              const SizedBox(width: 11),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Expanded(
                          child: Text(
                            item.title,
                            style: TextStyle(
                              color: AppColors.text,
                              fontSize: 15.5,
                              height: 1.25,
                              fontWeight:
                                  isUnread ? FontWeight.w900 : FontWeight.w700,
                            ),
                          ),
                        ),
                        if (isUnread) ...[
                          const SizedBox(width: 6),
                          Container(
                            width: 8,
                            height: 8,
                            margin: const EdgeInsets.only(top: 4),
                            decoration: const BoxDecoration(
                              color: AppColors.primary,
                              shape: BoxShape.circle,
                            ),
                          ),
                        ],
                      ],
                    ),
                    if (item.body.isNotEmpty) ...[
                      const SizedBox(height: 5),
                      Text(
                        item.body,
                        style: const TextStyle(
                          color: AppColors.muted,
                          fontSize: 13,
                          height: 1.45,
                        ),
                      ),
                    ],
                    if (hasDetails) ...[
                      const SizedBox(height: 9),
                      Wrap(
                        spacing: 6,
                        runSpacing: 5,
                        children: [
                          if (intent.entityId != null)
                            _DetailChip(
                              icon: Icons.tag_rounded,
                              label:
                                  '${context.tr('رقم المعاملة')} #${intent.entityId}',
                            ),
                          if (intent.status?.trim().isNotEmpty ?? false)
                            _DetailChip(
                              icon: Icons.info_outline_rounded,
                              label: intent.status!,
                            ),
                        ],
                      ),
                    ],
                    const SizedBox(height: 9),
                    Row(
                      children: [
                        const Icon(
                          Icons.schedule_outlined,
                          size: 14,
                          color: AppColors.subtle,
                        ),
                        const SizedBox(width: 4),
                        Text(
                          _formatDate(item.receivedAt),
                          style: const TextStyle(
                            color: AppColors.subtle,
                            fontSize: 11.5,
                            fontWeight: FontWeight.w600,
                          ),
                          textDirection: TextDirection.ltr,
                        ),
                      ],
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 2),
              const Icon(Icons.chevron_left_rounded, color: AppColors.muted),
            ],
          ),
        ),
      ),
    );
  }

  String _formatDate(DateTime value) {
    final date = value.toLocal();
    String pad(int number) => number.toString().padLeft(2, '0');
    return '${date.year}/${pad(date.month)}/${pad(date.day)} · '
        '${pad(date.hour)}:${pad(date.minute)}';
  }
}

class _DetailChip extends StatelessWidget {
  const _DetailChip({required this.icon, required this.label});

  final IconData icon;
  final String label;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 5),
      decoration: BoxDecoration(
        color: const Color(0xFFF1F6F3),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: const Color(0xFFD8E7DE)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 13, color: AppColors.primary),
          const SizedBox(width: 4),
          Text(
            label,
            style: const TextStyle(
              color: AppColors.primary,
              fontSize: 11,
              fontWeight: FontWeight.w800,
            ),
          ),
        ],
      ),
    );
  }
}
