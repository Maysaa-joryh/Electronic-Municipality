import 'package:flutter/material.dart';
import '../../../../app/theme/app_colors.dart';
import '../../../../core/constants/app_typography.dart';
import '../models/complaint_models.dart';

class ComplaintsFilterRow extends StatelessWidget {
  const ComplaintsFilterRow({required this.selectedIndex, required this.onSelected, super.key});

  final int selectedIndex;
  final ValueChanged<int> onSelected;

  @override
  Widget build(BuildContext context) {
    final List<String> filters = <String>['الكل', 'مسودة', 'قيد المعالجة', 'تم الحل'];
    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      child: Row(
        children: List<Widget>.generate(filters.length, (int idx) {
          final bool selected = idx == selectedIndex;
          return Padding(
            padding: const EdgeInsets.only(right: 8.0),
            child: GestureDetector(
              onTap: () => onSelected(idx),
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
                decoration: BoxDecoration(
                  color: selected ? AppColors.primary : AppColors.surface,
                  borderRadius: BorderRadius.circular(999),
                  border: Border.all(color: selected ? AppColors.primary : AppColors.border),
                ),
                child: Text(
                  filters[idx],
                  style: AppTypography.bodyMedium14().copyWith(color: selected ? AppColors.surface : AppColors.text, fontSize: 12),
                ),
              ),
            ),
          );
        }),
      ),
    );
  }
}

class ComplaintsListView extends StatelessWidget {
  const ComplaintsListView({required this.filterIndex, required this.items, super.key});

  final int filterIndex;
  final List<Complaint> items;

  @override
  Widget build(BuildContext context) {
    final List<Complaint> filteredItems = filterIndex == 0
      ? items
      : items.where((Complaint item) {
        if (filterIndex == 1) return item.status == 'مسودة';
        if (filterIndex == 2) return item.status == 'قيد المعالجة';
        if (filterIndex == 3) return item.status == 'تم الحل';
        return true;
        }).toList();

    return filteredItems.isEmpty
        ? Center(child: Text('لا توجد شكاوى لعرضها.', style: AppTypography.bodyRegular13()))
        : ListView.separated(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            itemBuilder: (context, index) {
              final Complaint item = filteredItems[index];
              final bool inProgress = item.status == 'قيد المعالجة';
              final bool isRejected = item.status == 'مرفوضة';
              return Container(
                decoration: BoxDecoration(
                  color: AppColors.surface,
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(color: AppColors.border),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: <Widget>[
                    Container(
                      padding: const EdgeInsets.all(16),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.stretch,
                        children: <Widget>[
                          Row(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: <Widget>[
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.stretch,
                                  children: <Widget>[
                                    Container(
                                      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                                      decoration: BoxDecoration(
                                        color: Color(item.secondaryStatusColor),
                                        borderRadius: BorderRadius.circular(8),
                                        border: Border.all(color: item.secondaryStatusColor == 0xFFE4E2DD ? const Color(0x7FC1C8C2) : Colors.transparent),
                                      ),
                                      child: Text(
                                        item.secondaryStatus,
                                        textAlign: TextAlign.right,
                                        style: AppTypography.bodyMedium14().copyWith(
                                          color: item.secondaryStatusColor == 0xFFE4E2DD ? AppColors.text : AppColors.text,
                                          fontSize: 12,
                                        ),
                                      ),
                                    ),
                                    const SizedBox(height: 16),
                                    Text(item.title, style: AppTypography.bodyBold14().copyWith(fontSize: 20, height: 1.4)),
                                    const SizedBox(height: 10),
                                    Text(item.description, style: AppTypography.bodyRegular13().copyWith(color: AppColors.subtle, height: 1.5)),
                                  ],
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 16),
                          Row(
                            children: <Widget>[
                              Expanded(child: Text(item.date, textAlign: TextAlign.right, style: AppTypography.bodyRegular13().copyWith(color: AppColors.muted))),
                              Expanded(child: Text('رقم البلاغ: #${item.id}', textAlign: TextAlign.right, style: AppTypography.bodyRegular13().copyWith(color: AppColors.muted))),
                            ],
                          ),
                        ],
                      ),
                    ),
                    if (inProgress || item.timeline.isNotEmpty || isRejected) ...<Widget>[
                      Container(
                        width: double.infinity,
                        padding: const EdgeInsets.all(16),
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: const BorderRadius.only(bottomLeft: Radius.circular(20), bottomRight: Radius.circular(20)),
                          border: Border.all(color: const Color(0x7FC1C8C2)),
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.stretch,
                          children: <Widget>[
                            Container(
                              width: double.infinity,
                              padding: const EdgeInsets.all(12),
                              decoration: BoxDecoration(
                                color: const Color(0xFFF5F3EE),
                                borderRadius: BorderRadius.circular(10),
                                border: Border.all(color: const Color(0x4CC1C8C2)),
                              ),
                              child: Text(item.location, textAlign: TextAlign.right, style: AppTypography.bodyRegular13().copyWith(color: AppColors.text, height: 1.5)),
                            ),
                            if (item.timeline.isNotEmpty) ...<Widget>[
                              const SizedBox(height: 16),
                              Row(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: <Widget>[
                                  SizedBox(
                                    width: 28,
                                    child: Column(
                                      children: List<Widget>.generate(item.timeline.length, (int stepIndex) {
                                        final bool isFirst = stepIndex == 0;
                                        final bool isLast = stepIndex == item.timeline.length - 1;
                                        return _buildTimelineConnector(
                                          isFirst: isFirst,
                                          isLast: isLast,
                                          completed: item.timeline[stepIndex].completed,
                                        );
                                      }),
                                    ),
                                  ),
                                  const SizedBox(width: 12),
                                  Expanded(
                                    child: Column(
                                      crossAxisAlignment: CrossAxisAlignment.stretch,
                                      children: List<Widget>.generate(item.timeline.length, (int stepIndex) {
                                        final ComplaintTimelineEntry entry = item.timeline[stepIndex];
                                        final bool isLast = stepIndex == item.timeline.length - 1;
                                        return _buildTimelineRow(entry, entry.completed, isLast);
                                      }),
                                    ),
                                  ),
                                ],
                              ),
                            ],
                            const SizedBox(height: 16),
                            Row(
                              children: <Widget>[
                                Expanded(
                                  child: OutlinedButton(
                                    onPressed: () => _showActionSheet(context, 'إضافة ملاحظة', 'يمكنك إضافة ملاحظة جديدة للبلاغ من هنا.'),
                                    style: OutlinedButton.styleFrom(
                                      side: const BorderSide(color: AppColors.border),
                                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                                      padding: const EdgeInsets.symmetric(vertical: 14),
                                    ),
                                    child: const Text('إضافة ملاحظة'),
                                  ),
                                ),
                                const SizedBox(width: 10),
                                Expanded(
                                  child: OutlinedButton(
                                    onPressed: () => _showActionSheet(context, 'تحدث مع الموظف', 'سيتم فتح نافذة للتواصل مع الموظف المختص.'),
                                    style: OutlinedButton.styleFrom(
                                      side: const BorderSide(color: AppColors.border),
                                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                                      padding: const EdgeInsets.symmetric(vertical: 14),
                                    ),
                                    child: const Text('تحدث مع الموظف'),
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),
                    ],
                  ],
                ),
              );
            },
            separatorBuilder: (_, __) => const SizedBox(height: 16),
            itemCount: filteredItems.length,
          );
  }

  Widget _buildTimelineConnector({required bool isFirst, required bool isLast, required bool completed}) {
    return Column(
      children: <Widget>[
        if (!isFirst)
          Container(width: 2, height: 16, color: const Color(0xFFEAE8E3)),
        Container(
          width: 16,
          height: 16,
          decoration: BoxDecoration(
            color: completed ? AppColors.primary : AppColors.surface,
            border: Border.all(color: completed ? AppColors.primary : AppColors.border),
            borderRadius: BorderRadius.circular(999),
          ),
          child: completed
              ? const Icon(Icons.check, size: 12, color: AppColors.surface)
              : null,
        ),
        if (!isLast)
          Container(width: 2, height: 48, color: const Color(0xFFEAE8E3)),
      ],
    );
  }

  Widget _buildTimelineRow(ComplaintTimelineEntry entry, bool completed, bool isLast) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: <Widget>[
          Text(entry.status, textAlign: TextAlign.right, style: AppTypography.bodyBold14().copyWith(fontSize: 14)),
          const SizedBox(height: 4),
          Text(entry.description, textAlign: TextAlign.right, style: AppTypography.bodyRegular13().copyWith(color: AppColors.subtle, height: 1.4)),
          const SizedBox(height: 4),
          Text(entry.timestamp, textAlign: TextAlign.right, style: AppTypography.captionRegular12()),
        ],
      ),
    );
  }

  void _showActionSheet(BuildContext context, String title, String message) {
    showModalBottomSheet<void>(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (BuildContext context) {
        return Padding(
          padding: const EdgeInsets.all(20),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: <Widget>[
              Text(title, style: AppTypography.sectionTitleBold18()),
              const SizedBox(height: 10),
              Text(message, style: AppTypography.bodyRegular13().copyWith(color: AppColors.subtle, height: 1.5)),
              const SizedBox(height: 20),
              ElevatedButton(
                onPressed: () => Navigator.of(context).pop(),
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.primary,
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                  padding: const EdgeInsets.symmetric(vertical: 16),
                ),
                child: const Text('حسنًا'),
              ),
            ],
          ),
        );
      },
    );
  }
}
