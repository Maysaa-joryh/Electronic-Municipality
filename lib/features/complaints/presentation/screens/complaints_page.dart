// import 'package:flutter/material.dart';
// import 'package:image_picker/image_picker.dart';

// import '../../../../app/theme/app_colors.dart';
// import '../../../../core/constants/app_sizes.dart';
// import '../../../../core/constants/app_typography.dart';
// import '../../data/complaints_repository.dart';
// import '../models/complaint_models.dart';
// import '../widgets/attachments_row.dart';
// import '../widgets/category_card.dart';
// import '../widgets/complaints_list.dart';
// import '../widgets/description_box.dart';
// import '../widgets/map_preview_card.dart';
// import '../widgets/mode_switch.dart';
// import '../widgets/priority_selector.dart';
// import '../widgets/search_address_field.dart';
// import '../widgets/submit_button.dart';
// import '../widgets/top_bar.dart';

// class ComplaintsPage extends StatefulWidget {
//   const ComplaintsPage({
//     super.key,
//     required this.onOpenProfile,
//     required this.onOpenNews,
//   });

//   final VoidCallback onOpenProfile;
//   final VoidCallback onOpenNews;

//   @override
//   State<ComplaintsPage> createState() => _ComplaintsPageState();
// }

// class _ComplaintsPageState extends State<ComplaintsPage> {
//   int _selectedModeIndex = 1; // 0 => بلاغ جديد, 1 => قائمة الشكاوى
//   int _selectedCategoryIndex = 0;
//   int _selectedFilterIndex = 0;
//   int _selectedPriorityIndex = 1;
//   double _mapScale = 1.0;

//   late final TextEditingController _addressController;
//   late final TextEditingController _descriptionController;
//   late final ImagePicker _picker;
//   final List<XFile> _attachments = <XFile>[];
//   late final List<CategoryItem> _categories;

//   @override
//   void initState() {
//     super.initState();
//     _addressController = TextEditingController(text: 'أدخل العنوان بالتفصيل يدوياً...');
//     _descriptionController = TextEditingController();
//     _picker = ImagePicker();
//     _categories = const <CategoryItem>[
//       CategoryItem(label: 'كهرباء', icon: Icons.bolt_rounded),
//       CategoryItem(label: 'مياه', icon: Icons.water_drop_outlined),
//       CategoryItem(label: 'طرق', icon: Icons.add_road),
//       CategoryItem(label: 'صرف صحي ', icon: Icons.cleaning_services),
//       CategoryItem(label: 'نظافة', icon: Icons.restore_from_trash),
//       CategoryItem(label: 'حدائق', icon: Icons.park_outlined),
//     ];
//   }

//   @override
//   void dispose() {
//     _addressController.dispose();
//     _descriptionController.dispose();
//     super.dispose();
//   }

//   void _zoomIn() => setState(() => _mapScale = (_mapScale + 0.12).clamp(0.88, 1.34));
//   void _zoomOut() => setState(() => _mapScale = (_mapScale - 0.12).clamp(0.88, 1.34));

//   Future<void> _pickImage() async {
//     try {
//       final XFile? picked = await _picker.pickImage(source: ImageSource.gallery, imageQuality: 80);
//       if (!mounted) return;
//       if (picked != null) setState(() => _attachments.add(picked));
//     } catch (e) {
//       if (!mounted) return;
//       ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('فشل في اختيار المرفق')));
//     }
//   }

//   void _removeAttachmentAt(int index) => setState(() => _attachments.removeAt(index));

//   void _submitComplaint() {
//     ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('تم إرسال البلاغ بنجاح')));
//     setState(() {
//       _descriptionController.clear();
//       _addressController.text = 'أدخل العنوان بالتفصيل يدوياً...';
//       _attachments.clear();
//     });
//   }

//   @override
//   Widget build(BuildContext context) {
//     final ComplaintsRepository repo = const ComplaintsRepository();
//     final List<Complaint> complaints = repo.getComplaints();
//     return Directionality(
//       textDirection: TextDirection.rtl,
//       child: Scaffold(
//         backgroundColor: AppColors.background,
//         body: SafeArea(
//           child: SingleChildScrollView(
//             padding: const EdgeInsets.fromLTRB(AppSizes.screenPadding, AppSizes.screenPadding, AppSizes.screenPadding, 18),
//             child: Column(crossAxisAlignment: CrossAxisAlignment.stretch, children: <Widget>[
//               ComplaintsTopBar(onNotificationTap: widget.onOpenNews, onProfileTap: widget.onOpenProfile),
//               const SizedBox(height: AppSizes.sectionSpacing),
//               ModeSwitch(firstLabel: 'بلاغ جديد', secondLabel: 'شكاوي', selectedIndex: _selectedModeIndex, onChanged: (int index) => setState(() => _selectedModeIndex = index)),
//               if (_selectedModeIndex == 0) ...<Widget>[
//                 const SizedBox(height: 14),
//                 MapPreviewCard(badgeText: 'موقعك المبين', scale: _mapScale, onZoomIn: _zoomIn, onZoomOut: _zoomOut),
//                 const SizedBox(height: 14),
//                 SearchAddressField(controller: _addressController),
//                 const SizedBox(height: 16),
//                 Text('الفئة', textAlign: TextAlign.right, style: AppTypography.sectionTitleBold18()),
//                 const SizedBox(height: 10),
//                 GridView.builder(
//                   itemCount: _categories.length,
//                   shrinkWrap: true,
//                   physics: const NeverScrollableScrollPhysics(),
//                   gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(crossAxisCount: 3, mainAxisSpacing: 10, crossAxisSpacing: 10, mainAxisExtent: 84),
//                   itemBuilder: (BuildContext context, int index) {
//                     final CategoryItem category = _categories[index];
//                     final bool selected = index == _selectedCategoryIndex;
//                     return CategoryCard(item: category, selected: selected, onTap: () => setState(() => _selectedCategoryIndex = index));
//                   },
//                 ),
//                 const SizedBox(height: 16),
//                 Text('الوصف', textAlign: TextAlign.right, style: AppTypography.sectionTitleBold18()),
//                 const SizedBox(height: 10),
//                 DescriptionBox(controller: _descriptionController),
//                 const SizedBox(height: 12),
//                 Text('المرفقات', textAlign: TextAlign.right, style: AppTypography.sectionTitleBold18()),
//                 const SizedBox(height: 10),
//                 AttachmentsRow(onAdd: _pickImage, onRemove: _removeAttachmentAt, attachments: _attachments),
//                 const SizedBox(height: 16),
//                 Text('أولوية الشكوى', textAlign: TextAlign.right, style: AppTypography.sectionTitleBold18()),
//                 const SizedBox(height: 10),
//                 PrioritySelector(selectedIndex: _selectedPriorityIndex, onChanged: (int index) => setState(() => _selectedPriorityIndex = index)),
//                 const SizedBox(height: 20),
//                 SubmitButton(onTap: _submitComplaint),
//               ] else ...<Widget>[
//                 const SizedBox(height: 8),
//                 ComplaintsFilterRow(selectedIndex: _selectedFilterIndex, onSelected: (int idx) => setState(() => _selectedFilterIndex = idx)),
//                 const SizedBox(height: 8),
//                 ComplaintsListView(filterIndex: _selectedFilterIndex, items: complaints),
//               ],
//             ]),
//           ),
//         ),
//       ),
//     );
//   }
// }
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';

import '../../../../app/theme/app_colors.dart';
import '../../../../core/constants/app_sizes.dart';
import '../../../../core/constants/app_typography.dart';
import '../../../../core/di.dart';
import '../../../../core/network/api_exception.dart';
import '../../data/complaints_repository.dart';
import '../models/complaint_models.dart';
import '../widgets/attachments_row.dart';
import '../widgets/category_card.dart';
import '../widgets/complaints_list.dart';
import '../widgets/description_box.dart';
import '../widgets/map_preview_card.dart';
import '../widgets/mode_switch.dart';
import '../widgets/priority_selector.dart';
import '../widgets/search_address_field.dart';
import '../widgets/submit_button.dart';
import '../widgets/top_bar.dart';

class ComplaintsPage extends StatefulWidget {
  const ComplaintsPage({
    super.key,
    required this.onOpenProfile,
    required this.onOpenNews,
  });

  final VoidCallback onOpenProfile;
  final VoidCallback onOpenNews;

  @override
  State<ComplaintsPage> createState() => _ComplaintsPageState();
}

class _ComplaintsPageState extends State<ComplaintsPage> {
  int _selectedModeIndex =
      0; // 0 => بلاغ جديد (الوضع الافتراضي الأنسب عند فتح الصفحة)
  int _selectedCategoryIndex = 0;
  int _selectedFilterIndex = 0;
  int _selectedPriorityIndex =
      1; // 1 => عادية (لا يُرسل للـ API حالياً، راجع الملاحظة أسفل _submitComplaint)
  double _mapScale = 1.0;
  bool _isLoading = false;

  late final TextEditingController _addressController;
  late final TextEditingController _descriptionController;
  late final ImagePicker _picker;
  final List<XFile> _attachments = <XFile>[];
  late final List<CategoryItem> _categories;

  static const List<int> _categoryIds = <int>[1, 2, 3, 4, 5, 6];

  List<Complaint> _complaints = <Complaint>[];
  bool _isLoadingComplaints = false;
  String? _complaintsError;

  @override
  void initState() {
    super.initState();
    _addressController = TextEditingController();
    _descriptionController = TextEditingController();
    _picker = ImagePicker();
    _categories = const <CategoryItem>[
      CategoryItem(label: 'كهرباء', icon: Icons.bolt_rounded),
      CategoryItem(label: 'مياه', icon: Icons.water_drop_outlined),
      CategoryItem(label: 'طرق', icon: Icons.add_road_rounded),
      CategoryItem(label: 'صرف صحي', icon: Icons.cleaning_services_rounded),
      CategoryItem(label: 'نظافة', icon: Icons.restore_from_trash_rounded),
      CategoryItem(label: 'حدائق', icon: Icons.park_outlined),
    ];
    _loadComplaints();
  }

  @override
  void dispose() {
    _addressController.dispose();
    _descriptionController.dispose();
    super.dispose();
  }

  Future<void> _loadComplaints() async {
    setState(() {
      _isLoadingComplaints = true;
      _complaintsError = null;
    });
    try {
      final items = await DI.complaints.getComplaints();
      if (!mounted) return;
      setState(() {
        _complaints = items;
        _isLoadingComplaints = false;
      });
    } on ApiException catch (error) {
      if (!mounted) return;
      setState(() {
        _isLoadingComplaints = false;
        _complaintsError = error.message;
      });
    } catch (_) {
      if (!mounted) return;
      setState(() {
        _isLoadingComplaints = false;
        _complaintsError = 'تعذر تحميل الشكاوى. حاول مرة أخرى.';
      });
    }
  }

  void _zoomIn() =>
      setState(() => _mapScale = (_mapScale + 0.12).clamp(0.88, 1.34));
  void _zoomOut() =>
      setState(() => _mapScale = (_mapScale - 0.12).clamp(0.88, 1.34));

  Future<void> _pickImage() async {
    try {
      final XFile? picked = await _picker.pickImage(
        source: ImageSource.gallery,
        imageQuality: 80,
      );
      if (!mounted) return;
      if (picked != null) {
        setState(() => _attachments.add(picked));
      }
    } catch (e) {
      if (!mounted) return;
      _showSnackBar('فشل في اختيار المرفق، يرجى المحاولة لاحقاً',
          isError: true);
    }
  }

  void _removeAttachmentAt(int index) =>
      setState(() => _attachments.removeAt(index));

  // تحسين عملية إرسال البلاغ مع التحقق وحالة التحميل
  Future<void> _submitComplaint() async {
    // 1. التحقق من إدخال وصف المشكلة
    final description = _descriptionController.text.trim();
    if (description.isEmpty) {
      _showSnackBar('يرجى كتابة وصف المشكلة قبل الإرسال', isError: true);
      return;
    }

    final address = _addressController.text.trim();
    if (address.isEmpty) {
      _showSnackBar('يرجى إدخال العنوان قبل الإرسال', isError: true);
      return;
    }

    final municipalityId =
        DI.auth.currentUser?.citizenProfile?['municipality_id'];
    if (municipalityId == null) {
      _showSnackBar(
        'تعذر تحديد بلديتك. حاول تسجيل الدخول من جديد.',
        isError: true,
      );
      return;
    }

    setState(() => _isLoading = true);

    try {
      final attachments = await Future.wait(
        _attachments.map(
          (file) async => NewComplaintAttachment(
            fileName: file.name,
            bytes: await file.readAsBytes(),
          ),
        ),
      );

      await DI.complaints.createAndSubmitComplaint(
        NewComplaintInput(
          municipalityId: municipalityId is int
              ? municipalityId
              : int.parse(municipalityId.toString()),
          categoryId: _categoryIds[_selectedCategoryIndex],
          title: 'بلاغ ${_categories[_selectedCategoryIndex].label}',
          description: description,
          textLocation: address,
          latitude: 0.0,
          longitude: 0.0,
          attachments: attachments,
        ),
      );

      if (!mounted) return;

      setState(() {
        _isLoading = false;
        _descriptionController.clear();
        _addressController.clear();
        _attachments.clear();
        _selectedCategoryIndex = 0;
        _selectedPriorityIndex = 1;
        _selectedModeIndex = 1; 
      });

      _showSnackBar(
        'تم إرسال البلاغ بنجاح، يمكنك متابعة حالته من قائمة الشكاوى',
      );
      await _loadComplaints();
    } on ApiException catch (error) {
      if (!mounted) return;
      setState(() => _isLoading = false);
      _showSnackBar(error.message, isError: true);
    } catch (_) {
      if (!mounted) return;
      setState(() => _isLoading = false);
      _showSnackBar('حدث خطأ غير متوقع أثناء إرسال البلاغ.', isError: true);
    }
  }

  void _showSnackBar(String message, {bool isError = false}) {
    ScaffoldMessenger.of(context).clearSnackBars();
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        elevation: 0,
        behavior: SnackBarBehavior.floating,
        backgroundColor: Colors.transparent,
        margin: const EdgeInsets.all(16),
        content: Container(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
          decoration: BoxDecoration(
            color: isError ? AppColors.danger : AppColors.deepPrimary,
            borderRadius: BorderRadius.circular(14),
            boxShadow: const [
              BoxShadow(
                color: Color(0x29000000),
                blurRadius: 12,
                offset: Offset(0, 4),
              ),
            ],
          ),
          child: Row(
            children: [
              Icon(
                isError
                    ? Icons.error_outline_rounded
                    : Icons.check_circle_rounded,
                color: Colors.white,
                size: 22,
              ),
              const SizedBox(width: 10),
              Expanded(
                child: Text(
                  message,
                  style: AppTypography.bodyMedium14().copyWith(
                    color: Colors.white,
                    fontSize: 13,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Directionality(
      textDirection: TextDirection.rtl,
      child: Scaffold(
        backgroundColor: AppColors.background,
        body: SafeArea(
          child: SingleChildScrollView(
            physics: const BouncingScrollPhysics(),
            padding: const EdgeInsets.fromLTRB(
              AppSizes.screenPadding,
              AppSizes.screenPadding,
              AppSizes.screenPadding,
              24,
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: <Widget>[
                // الشريط العلوي
                ComplaintsTopBar(
                  onNotificationTap: widget.onOpenNews,
                  onProfileTap: widget.onOpenProfile,
                ),
                const SizedBox(height: AppSizes.sectionSpacing),

                // محول النمط (بلاغ جديد / قائمة الشكاوي)
                ModeSwitch(
                  firstLabel: 'بلاغ جديد',
                  secondLabel: 'شكاوي',
                  selectedIndex: _selectedModeIndex,
                  onChanged: (int index) {
                    setState(() => _selectedModeIndex = index);
                    if (index == 1) _loadComplaints();
                  },
                ),

                if (_selectedModeIndex == 0) ...<Widget>[
                  const SizedBox(height: 16),

                  // معاينة الخريطة
                  MapPreviewCard(
                    badgeText: 'موقعك المبين',
                    scale: _mapScale,
                    onZoomIn: _zoomIn,
                    onZoomOut: _zoomOut,
                  ),
                  const SizedBox(height: 14),

                  // حقل العنوان
                  SearchAddressField(
                    controller: _addressController,
                    onCurrentLocationPressed: () {
                      // إمكانية إضافة جلب الموقع بالـ GPS هنا
                    },
                  ),
                  const SizedBox(height: 20),

                  // الفئة
                  Text(
                    'الفئة',
                    textAlign: TextAlign.right,
                    style: AppTypography.sectionTitleBold18(),
                  ),
                  const SizedBox(height: 10),
                  GridView.builder(
                    itemCount: _categories.length,
                    shrinkWrap: true,
                    physics: const NeverScrollableScrollPhysics(),
                    gridDelegate:
                        const SliverGridDelegateWithFixedCrossAxisCount(
                      crossAxisCount: 3,
                      mainAxisSpacing: 10,
                      crossAxisSpacing: 10,
                      mainAxisExtent: 88,
                    ),
                    itemBuilder: (BuildContext context, int index) {
                      final CategoryItem category = _categories[index];
                      final bool selected = index == _selectedCategoryIndex;
                      return CategoryCard(
                        item: category,
                        selected: selected,
                        onTap: () =>
                            setState(() => _selectedCategoryIndex = index),
                      );
                    },
                  ),
                  const SizedBox(height: 20),

                  // الوصف
                  Text(
                    'الوصف',
                    textAlign: TextAlign.right,
                    style: AppTypography.sectionTitleBold18(),
                  ),
                  const SizedBox(height: 10),
                  DescriptionBox(controller: _descriptionController),
                  const SizedBox(height: 20),

                  // المرفقات
                  Text(
                    'المرفقات',
                    textAlign: TextAlign.right,
                    style: AppTypography.sectionTitleBold18(),
                  ),
                  const SizedBox(height: 10),
                  AttachmentsRow(
                    onAdd: _pickImage,
                    onRemove: _removeAttachmentAt,
                    attachments: _attachments,
                    maxAttachments: 5,
                  ),
                  const SizedBox(height: 20),

                  // الأولوية
                  Text(
                    'أولوية الشكوى',
                    textAlign: TextAlign.right,
                    style: AppTypography.sectionTitleBold18(),
                  ),
                  const SizedBox(height: 10),
                  PrioritySelector(
                    selectedIndex: _selectedPriorityIndex,
                    onChanged: (int index) =>
                        setState(() => _selectedPriorityIndex = index),
                  ),
                  const SizedBox(height: 28),

                  // زر الإرسال
                  SubmitButton(
                    onTap: _submitComplaint,
                    isLoading: _isLoading,
                  ),
                ] else ...<Widget>[
                  const SizedBox(height: 12),

                  // شاشة قائمة الشكاوى
                  ComplaintsFilterRow(
                    selectedIndex: _selectedFilterIndex,
                    onSelected: (int idx) =>
                        setState(() => _selectedFilterIndex = idx),
                  ),
                  const SizedBox(height: 12),
                  if (_isLoadingComplaints)
                    const Padding(
                      padding: EdgeInsets.symmetric(vertical: 40),
                      child: Center(child: CircularProgressIndicator()),
                    )
                  else if (_complaintsError != null)
                    Padding(
                      padding: const EdgeInsets.symmetric(vertical: 24),
                      child: Column(
                        children: <Widget>[
                          Text(
                            _complaintsError!,
                            textAlign: TextAlign.center,
                            style: AppTypography.bodyRegular13()
                                .copyWith(color: AppColors.danger),
                          ),
                          const SizedBox(height: 12),
                          OutlinedButton(
                            onPressed: _loadComplaints,
                            child: const Text('إعادة المحاولة'),
                          ),
                        ],
                      ),
                    )
                  else
                    ComplaintsListView(
                      filterIndex: _selectedFilterIndex,
                      items: _complaints,
                    ),
                ],
              ],
            ),
          ),
        ),
      ),
    );
  }
}
