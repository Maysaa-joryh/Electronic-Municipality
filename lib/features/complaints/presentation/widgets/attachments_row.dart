import 'dart:io';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import '../../../../app/theme/app_colors.dart';
import '../../../../core/constants/app_typography.dart';

class AttachmentsRow extends StatelessWidget {
  const AttachmentsRow({
    required this.onAdd,
    required this.onRemove,
    required this.attachments,
    super.key,
    this.maxAttachments = 5,
    this.onImageTap,
  });

  final Future<void> Function() onAdd;
  final void Function(int) onRemove;
  final List<XFile> attachments;
  final int maxAttachments;
  final void Function(int index, XFile file)? onImageTap;

  @override
  Widget build(BuildContext context) {
    final bool canAddMore = attachments.length < maxAttachments;
    final int itemCount = canAddMore ? attachments.length + 1 : attachments.length;

    return SizedBox(
      height: 104,
      child: ListView.separated(
        scrollDirection: Axis.horizontal,
        physics: const BouncingScrollPhysics(),
        itemCount: itemCount,
        separatorBuilder: (_, __) => const SizedBox(width: 12),
        itemBuilder: (context, index) {
          // إذا كان يمكن إضافة المزيد، فالعنصر الأول (index 0) يكون هو زر الإضافة
          if (canAddMore && index == 0) {
            return _AddAttachmentCard(onTap: onAdd);
          }

          // معادلة تحديد الـ index الصحيح للصورة بناءً على وجود زر الإضافة أو عدمه
          final int fileIndex = canAddMore ? index - 1 : index;
          final XFile file = attachments[fileIndex];

          return _AttachmentTile(
            file: file,
            onRemove: () => onRemove(fileIndex),
            onTap: onImageTap != null ? () => onImageTap!(fileIndex, file) : null,
          );
        },
      ),
    );
  }
}

/// ويدجت زر الإضافة
class _AddAttachmentCard extends StatelessWidget {
  const _AddAttachmentCard({required this.onTap});

  final Future<void> Function() onTap;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: AppColors.surface,
      borderRadius: BorderRadius.circular(20),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(20),
        splashColor: AppColors.primary.withOpacity(0.08),
        highlightColor: Colors.transparent,
        child: Container(
          width: 104,
          height: 104,
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(20),
            border: Border.all(
              color: AppColors.border,
              width: 1.5,
            ),
          ),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: <Widget>[
              const Icon(
                Icons.add_a_photo_outlined,
                size: 26,
                color: AppColors.muted,
              ),
              const SizedBox(height: 6),
              Text(
                'إضافة مرفق',
                textAlign: TextAlign.center,
                style: AppTypography.bodyRegular13().copyWith(
                  color: AppColors.muted,
                  fontSize: 12,
                  height: 1.2,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

/// ويدجت عرض الصورة المرفقة
class _AttachmentTile extends StatelessWidget {
  const _AttachmentTile({
    required this.file,
    required this.onRemove,
    this.onTap,
  });

  final XFile file;
  final VoidCallback onRemove;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: <Widget>[
        // الصورة نفسها مع إمكانية الضغط عليها للمعاينة
        GestureDetector(
          onTap: onTap,
          child: Container(
            width: 104,
            height: 104,
            clipBehavior: Clip.antiAlias,
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(20),
              border: Border.all(color: AppColors.border.withOpacity(0.5)),
            ),
            child: Image.file(
              File(file.path),
              fit: BoxFit.cover,
              errorBuilder: (context, error, stackTrace) {
                return Container(
                  color: AppColors.surface,
                  child: const Icon(Icons.broken_image_rounded, color: AppColors.muted),
                );
              },
            ),
          ),
        ),

        // تدرج ظلي خفيف في الزاوية لتسهيل رؤية زر الإغلاق حتى لو كانت الصورة بيضاء
        PositionedDirectional(
          top: 0,
          end: 0,
          child: Container(
            width: 44,
            height: 44,
            decoration: const BoxDecoration(
              borderRadius: BorderRadius.only(
                topRight: Radius.circular(20),
              ),
              gradient: RadialGradient(
                center: Alignment.topRight,
                radius: 1.2,
                colors: [
                  Color(0x44000000),
                  Colors.transparent,
                ],
              ),
            ),
          ),
        ),

        // زر الحذف (X)
        PositionedDirectional(
          top: 6,
          end: 6,
          child: Material(
            color: Colors.transparent,
            child: InkWell(
              onTap: onRemove,
              customBorder: const CircleBorder(),
              child: Container(
                width: 26,
                height: 26,
                decoration: const BoxDecoration(
                  color: AppColors.danger,
                  shape: BoxShape.circle,
                  boxShadow: [
                    BoxShadow(
                      color: Color(0x29000000),
                      blurRadius: 4,
                      offset: Offset(0, 2),
                    ),
                  ],
                ),
                child: const Icon(
                  Icons.close_rounded,
                  size: 16,
                  color: AppColors.surface,
                ),
              ),
            ),
          ),
        ),
      ],
    );
  }
}