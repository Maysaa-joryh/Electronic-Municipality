
import 'package:electronic_municipality/features/complaints/data/model/complaint_api_model.dart';

import '../presentation/models/complaint_models.dart';


class ComplaintsMapper {
  const ComplaintsMapper._();

  static Complaint toUiComplaint(ComplaintApiModel api) {
    final presentation = _statusPresentation(api.status);

    return Complaint(
      id: api.id.toString(),
      title: api.title,
      description: api.description,
      date: _formatDate(api.createdAt),
      status: presentation.filterStatus,
      location: api.textLocation ?? '',
      secondaryStatus: presentation.label,
      secondaryStatusColor: presentation.color,
      timeline: const <ComplaintTimelineEntry>[],
    );
  }

  static List<Complaint> toUiComplaintList(List<ComplaintApiModel> items) {
    return items.map(toUiComplaint).toList(growable: false);
  }

  static _StatusPresentation _statusPresentation(String rawStatus) {
    switch (rawStatus.toLowerCase()) {
      case 'draft':
        return const _StatusPresentation(
          filterStatus: 'مسودة',
          label: 'مسودة',
          color: 0xFF34C759,
        );
      case 'submitted':
      case 'pending':
      case 'in_review':
      case 'under_review':
        return const _StatusPresentation(
          filterStatus: 'قيد المعالجة',
          label: 'قيد المراجعة',
          color: 0xFFFFD79B,
        );
      case 'assigned':
      case 'in_progress':
        return const _StatusPresentation(
          filterStatus: 'قيد المعالجة',
          label: 'قيد التنفيذ',
          color: 0xFFFFD79B,
        );
      case 'resolved':
      case 'completed':
      case 'closed':
        return const _StatusPresentation(
          filterStatus: 'تم الحل',
          label: 'تم الحل',
          color: 0xFF34C759,
        );
      case 'rejected':
        return const _StatusPresentation(
          filterStatus: 'مرفوضة',
          label: 'مرفوضة',
          color: 0xFFE4E2DD,
        );
      default:
        return const _StatusPresentation(
          filterStatus: 'قيد المعالجة',
          label: 'غير معروف',
          color: 0xFFE4E2DD,
        );
    }
  }

  static String _formatDate(DateTime? date) {
    if (date == null) return '';
    const months = <String>[
      'يناير', 'فبراير', 'مارس', 'أبريل', 'مايو', 'يونيو',
      'يوليو', 'أغسطس', 'سبتمبر', 'أكتوبر', 'نوفمبر', 'ديسمبر',
    ];
    final day = date.day.toString().padLeft(2, '0');
    return '$day ${months[date.month - 1]} ${date.year}';
  }
}

class _StatusPresentation {
  const _StatusPresentation({
    required this.filterStatus,
    required this.label,
    required this.color,
  });


  final String filterStatus;
  final String label;
  final int color;
}
