import '../presentation/models/complaint_models.dart';

const List<Complaint> complaintMocks = <Complaint>[
  Complaint(
    title: 'تسرب مياه في الشارع الرئيسي',
    date: '12 أكتوبر 2023',
    id: 'CMP-2023-089',
    status: 'قيد المعالجة',
    description: 'تسرب مياه إلى الشارع الرئيسي ويتطلب تدخل الصيانة.',
    location: 'ريف دمشق، داريا، شارع الكورنيش، دخلة مدرسة الإباء العربي.',
    secondaryStatus: 'قيد التنفيذ',
    secondaryStatusColor: 0xFFFFD79B,
    timeline: <ComplaintTimelineEntry>[
      ComplaintTimelineEntry(status: 'تم الإرسال', description: 'تم إرسال البلاغ وتسجيله في النظام.', timestamp: '12 أكتوبر - 10:00 ص', completed: true),
      ComplaintTimelineEntry(status: 'قيد المراجعة', description: 'جارٍ مراجعة البلاغ من قبل الجهات المختصة.', timestamp: '13 أكتوبر - 09:45 ص', completed: true),
      ComplaintTimelineEntry(status: 'تم تحويلها للقسم المختص', description: 'تم تحويل البلاغ إلى قسم شبكات المياه.', timestamp: '13 أكتوبر - 11:15 ص', completed: true),
      ComplaintTimelineEntry(status: 'قيد التنفيذ', description: 'فريق الصيانة متواجد في الموقع ويعمل على إصلاح العطل.', timestamp: '14 أكتوبر - 09:30 ص', completed: false),
      ComplaintTimelineEntry(status: 'تم الحل', description: 'تم حل المشكلة وإغلاق البلاغ.', timestamp: '15 أكتوبر - 02:20 م', completed: false),
    ],
  ),
  Complaint(
    title: 'تقليم أشجار متدلية على الشارع',
    date: '05 أكتوبر 2023',
    id: 'CMP-2023-072',
    status: 'مسودة',
    description: 'طلب تقليم الأشجار المتدلية على الشارع لتجنب الحوادث.',
    location: 'حي شارع رئيسي، قرب محطة الوقود.',
    secondaryStatus: 'مسودة',
    secondaryStatusColor: 0xFF34C759,
    timeline: <ComplaintTimelineEntry>[],
  ),
  Complaint(
    title: 'إنارة شارع معطلة',
    date: '28 سبتمبر 2023',
    id: 'CMP-2023-065',
    status: 'مرفوضة',
    description: 'إنارة الشارع متوقفة في نهاية البلدة ويجب مراجعة البلدية بشأنها.',
    location: 'منطقة غير تابعة',
    secondaryStatus: 'غير مكتمل',
    secondaryStatusColor: 0xFFE4E2DD,
    timeline: <ComplaintTimelineEntry>[],
  ),
];
