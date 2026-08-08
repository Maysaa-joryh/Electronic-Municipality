import 'package:flutter/material.dart';
import '../../../../app/theme/app_colors.dart';
import '../../../../core/constants/app_typography.dart';

class DescriptionBox extends StatefulWidget {
  const DescriptionBox({
    required this.controller,
    super.key,
    this.hintText = 'يرجى وصف المشكلة بالتفصيل...',
    this.maxLength = 500,
    this.minLines = 4,
    this.maxLines = 6,
    this.onChanged,
  });

  final TextEditingController controller;
  final String hintText;
  final int maxLength;
  final int minLines;
  final int maxLines;
  final ValueChanged<String>? onChanged;

  @override
  State<DescriptionBox> createState() => _DescriptionBoxState();
}

class _DescriptionBoxState extends State<DescriptionBox> {
  final FocusNode _focusNode = FocusNode();
  int _currentLength = 0;

  @override
  void initState() {
    super.initState();
    _currentLength = widget.controller.text.length;
    widget.controller.addListener(_updateCharacterCount);
    _focusNode.addListener(_onFocusChange);
  }

  @override
  void dispose() {
    widget.controller.removeListener(_updateCharacterCount);
    _focusNode.removeListener(_onFocusChange);
    _focusNode.dispose();
    super.dispose();
  }

  void _updateCharacterCount() {
    if (_currentLength != widget.controller.text.length) {
      setState(() {
        _currentLength = widget.controller.text.length;
      });
    }
  }

  void _onFocusChange() {
    setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    final bool isFocused = _focusNode.hasFocus;

    return AnimatedContainer(
      duration: const Duration(milliseconds: 200),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(10),
        border: Border.all(
          color: isFocused ? AppColors.primary : AppColors.border,
          width: isFocused ? 1.5 : 1.0,
        ),
        boxShadow: isFocused
            ? [
                BoxShadow(
                  color: AppColors.primary.withOpacity(0.08),
                  blurRadius: 8,
                  offset: const Offset(0, 2),
                ),
              ]
            : null,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: <Widget>[
          TextField(
            controller: widget.controller,
            focusNode: _focusNode,
            minLines: widget.minLines,
            maxLines: widget.maxLines,
            maxLength: widget.maxLength,
            textAlign: TextAlign.right,
            onChanged: widget.onChanged,
            style: AppTypography.bodyMedium14().copyWith(
              fontSize: 13,
              color: AppColors.text,
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
              contentPadding: EdgeInsets.zero,
              isDense: true,
              counterText: '',
            ),
          ),
          const SizedBox(height: 8),
          Align(
            alignment: Alignment.bottomLeft,
            child: Text(
              '$_currentLength / ${widget.maxLength}',
              style: AppTypography.bodyRegular13().copyWith(
                fontSize: 11,
                color: _currentLength >= widget.maxLength
                    ? AppColors.danger
                    : AppColors.subtle,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
