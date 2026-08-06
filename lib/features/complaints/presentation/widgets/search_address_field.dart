import 'package:flutter/material.dart';
import '../../../../app/theme/app_colors.dart';
import '../../../../core/constants/app_typography.dart';

class SearchAddressField extends StatefulWidget {
  const SearchAddressField({
    required this.controller,
    super.key,
    this.onChanged,
    this.onSubmitted,
    this.onCurrentLocationPressed,
    this.isLoadingLocation = false,
    this.hintText = 'أدخل العنوان بالتفصيل يدوياً...',
  });

  final TextEditingController controller;
  final ValueChanged<String>? onChanged;
  final ValueChanged<String>? onSubmitted;
  final VoidCallback? onCurrentLocationPressed;
  final bool isLoadingLocation;
  final String hintText;

  @override
  State<SearchAddressField> createState() => _SearchAddressFieldState();
}

class _SearchAddressFieldState extends State<SearchAddressField> {
  bool _showClearButton = false;

  @override
  void initState() {
    super.initState();
    _showClearButton = widget.controller.text.isNotEmpty;
    widget.controller.addListener(_handleTextChange);
  }

  @override
  void dispose() {
    widget.controller.removeListener(_handleTextChange);
    super.dispose();
  }

  void _handleTextChange() {
    final hasText = widget.controller.text.isNotEmpty;
    if (hasText != _showClearButton) {
      setState(() {
        _showClearButton = hasText;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedContainer(
      duration: const Duration(milliseconds: 200),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: AppColors.border,
          width: 1,
        ),
        boxShadow: const [
          BoxShadow(
            color: Color(0x08000000),
            blurRadius: 8,
            offset: Offset(0, 2),
          ),
        ],
      ),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
        child: Row(
          children: <Widget>[
            // أيقونة البحث / الموقع في البداية
            const Icon(
              Icons.search_rounded,
              size: 20,
              color: AppColors.muted,
            ),
            const SizedBox(width: 8),

            // حقل النص الرئيسي
            Expanded(
              child: TextField(
                controller: widget.controller,
                textAlign: TextAlign.right,
                onChanged: widget.onChanged,
                onSubmitted: widget.onSubmitted,
                textInputAction: TextInputAction.search,
                style: AppTypography.bodyMedium14().copyWith(
                  fontSize: 13,
                  color: AppColors.text, // استبدل بـ لون النص لديك إن وجد
                ),
                decoration: InputDecoration(
                  hintText: widget.hintText,
                  hintStyle: AppTypography.bodyRegular13().copyWith(
                    fontSize: 13,
                    color: AppColors.subtle,
                  ),
                  border: InputBorder.none,
                  enabledBorder: InputBorder.none,
                  focusedBorder: InputBorder.none,
                  isDense: true,
                  contentPadding: const EdgeInsets.symmetric(vertical: 10),
                ),
              ),
            ),

            // زر مسح النص (يظهر فقط عند وجود نص)
            if (_showClearButton) ...[
              IconButton(
                padding: EdgeInsets.zero,
                constraints: const BoxConstraints(minWidth: 32, minHeight: 32),
                icon: const Icon(
                  Icons.cancel_rounded,
                  size: 18,
                  color: AppColors.muted,
                ),
                onPressed: () {
                  widget.controller.clear();
                  widget.onChanged?.call('');
                },
                tooltip: 'مسح',
              ),
              const SizedBox(width: 4),
            ],

            // فاصل بسيط بين الزرين
            if (widget.onCurrentLocationPressed != null) ...[
              Container(
                height: 18,
                width: 1,
                color: AppColors.border,
              ),
              const SizedBox(width: 4),
            ],

            // زر تحديد الموقع الحقيقي (GPS)
            if (widget.onCurrentLocationPressed != null)
              widget.isLoadingLocation
                  ? const SizedBox(
                      width: 20,
                      height: 20,
                      child: CircularProgressIndicator(
                        strokeWidth: 2,
                        color: AppColors.primary,
                      ),
                    )
                  : IconButton(
                      padding: EdgeInsets.zero,
                      constraints: const BoxConstraints(minWidth: 36, minHeight: 36),
                      icon: const Icon(
                        Icons.my_location_rounded,
                        size: 20,
                        color: AppColors.primary,
                      ),
                      onPressed: widget.onCurrentLocationPressed,
                      tooltip: 'جلب موقعي الحالي',
                    ),
          ],
        ),
      ),
    );
  }
}