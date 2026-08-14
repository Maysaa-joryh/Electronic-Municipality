import 'dart:typed_data';

import '../../../../core/network/api_exception.dart';

class ComplaintCategory {
  const ComplaintCategory({
    required this.id,
    required this.name,
    this.parentId,
    this.key,
    this.children = const <ComplaintCategory>[],
  });

  factory ComplaintCategory.fromJson(Map<String, dynamic> json) {
    return ComplaintCategory(
      id: _requiredInt(json, 'id'),
      name: _requiredString(json, 'name'),
      parentId: _nullableInt(json['parent_id']),
      key: _nullableString(json['key']),
      children: _mapList(json['children'])
          .map(ComplaintCategory.fromJson)
          .toList(growable: false),
    );
  }

  final int id;
  final int? parentId;
  final String? key;
  final String name;
  final List<ComplaintCategory> children;

  bool get isGroup => parentId == null && children.isNotEmpty;
}

class ComplaintStatus {
  const ComplaintStatus({
    required this.key,
    required this.label,
  });

  factory ComplaintStatus.fromJson(Object? value) {
    if (value is String && value.trim().isNotEmpty) {
      final key = value.trim();
      return ComplaintStatus(key: key, label: key);
    }

    final json = _nullableMap(value);
    if (json == null) {
      throw const FormatException('Missing or invalid complaint status.');
    }

    final key = _requiredString(json, 'key');
    return ComplaintStatus(
      key: key,
      label: _nullableString(json['label']) ??
          _nullableString(json['name']) ??
          key,
    );
  }

  final String key;
  final String label;

  bool get isDraft => key.toLowerCase() == 'draft';
}

class ComplaintImage {
  const ComplaintImage({
    required this.id,
    required this.url,
    this.name,
  });

  factory ComplaintImage.fromJson(Map<String, dynamic> json) {
    return ComplaintImage(
      id: _requiredInt(json, 'id'),
      url: _requiredStringFromKeys(
        json,
        const <String>[
          'url',
          'view_url',
          'image_url',
          'path',
        ],
      ),
      name: _nullableString(json['name']) ??
          _nullableString(json['file_name']) ??
          _nullableString(json['original_name']),
    );
  }

  final int id;
  final String url;
  final String? name;
}

class ComplaintReport {
  const ComplaintReport({
    required this.id,
    required this.status,
    required this.images,
    this.municipalityId,
    this.categoryId,
    this.category,
    this.title,
    this.description,
    this.textLocation,
    this.latitude,
    this.longitude,
    this.serverCanEdit,
    this.createdAt,
    this.updatedAt,
  });

  factory ComplaintReport.fromJson(Map<String, dynamic> json) {
    final statusValue = json['status'] ?? json['status_key'];
    final categoryJson = _nullableMap(json['category']);
    final municipalityJson = _nullableMap(json['municipality']);

    return ComplaintReport(
      id: _requiredInt(json, 'id'),
      status: ComplaintStatus.fromJson(statusValue),
      images: _mapList(json['images'])
          .map(ComplaintImage.fromJson)
          .toList(growable: false),
      municipalityId: _nullableInt(json['municipality_id']) ??
          _nullableInt(municipalityJson?['id']),
      categoryId: _nullableInt(json['category_id']) ??
          _nullableInt(categoryJson?['id']),
      category: categoryJson == null
          ? null
          : ComplaintCategory(
              id: _requiredInt(categoryJson, 'id'),
              name: _requiredString(categoryJson, 'name'),
              key: _nullableString(categoryJson['key']),
            ),
      title: _nullableString(json['title']),
      description: _nullableString(json['description']),
      textLocation: _nullableString(json['text_location']),
      latitude: _nullableDouble(json['latitude']),
      longitude: _nullableDouble(json['longitude']),
      serverCanEdit: _nullableBool(json['can_edit']),
      createdAt: _nullableDateTime(json['created_at']),
      updatedAt: _nullableDateTime(json['updated_at']),
    );
  }

  final int id;
  final ComplaintStatus status;
  final List<ComplaintImage> images;
  final int? municipalityId;
  final int? categoryId;
  final ComplaintCategory? category;
  final String? title;
  final String? description;
  final String? textLocation;
  final double? latitude;
  final double? longitude;

  /// If the backend sends `can_edit`, it is the authority. The draft status is
  /// used only as a compatibility fallback when that field is absent.
  final bool? serverCanEdit;
  final DateTime? createdAt;
  final DateTime? updatedAt;

  bool get canEdit => serverCanEdit ?? status.isDraft;
}

class ComplaintDraftInput {
  const ComplaintDraftInput({
    this.municipalityId,
    this.categoryId,
    this.title,
    this.description,
    this.textLocation,
    this.latitude,
    this.longitude,
  });

  final int? municipalityId;
  final int? categoryId;
  final String? title;
  final String? description;
  final String? textLocation;
  final double? latitude;
  final double? longitude;

  Map<String, dynamic> toJson() {
    final normalizedTitle = _trimmed(title);
    final normalizedDescription = _trimmed(description);
    final normalizedTextLocation = _trimmed(textLocation);

    return <String, dynamic>{
      if (municipalityId != null) 'municipality_id': municipalityId,
      if (categoryId != null) 'category_id': categoryId,
      if (normalizedTitle != null) 'title': normalizedTitle,
      if (normalizedDescription != null) 'description': normalizedDescription,
      if (normalizedTextLocation != null)
        'text_location': normalizedTextLocation,
      if (latitude != null) 'latitude': latitude,
      if (longitude != null) 'longitude': longitude,
    };
  }

  /// Use before submit when the UI needs immediate field-level feedback.
  Map<String, List<String>> submissionErrors() {
    final errors = <String, List<String>>{};
    void required(String field, bool missing) {
      if (missing) errors[field] = <String>['هذا الحقل مطلوب.'];
    }

    required('municipality_id', municipalityId == null);
    required('category_id', categoryId == null);
    required('title', _trimmed(title) == null);
    required('description', _trimmed(description) == null);
    required('latitude', latitude == null);
    required('longitude', longitude == null);
    return Map<String, List<String>>.unmodifiable(errors);
  }
}

class ComplaintAttachment {
  const ComplaintAttachment({
    required this.name,
    required this.bytes,
  });

  static const int maxCount = 5;
  static const int maxBytes = 5 * 1024 * 1024;

  final String name;
  final Uint8List bytes;

  int get sizeInBytes => bytes.lengthInBytes;

  static void validateSelection(
    List<ComplaintAttachment> attachments, {
    int existingCount = 0,
  }) {
    if (attachments.isEmpty) {
      throw ApiException.validation(
        message: 'اختر صورة واحدة على الأقل.',
        errors: const <String, List<String>>{
          'images': <String>['اختر صورة واحدة على الأقل.'],
        },
      );
    }
    if (existingCount + attachments.length > maxCount) {
      throw ApiException.validation(
        message: 'يمكن إرفاق 5 صور كحد أقصى.',
        errors: const <String, List<String>>{
          'images': <String>['يمكن إرفاق 5 صور كحد أقصى.'],
        },
      );
    }

    for (final attachment in attachments) {
      final extension = attachment.name.split('.').last.toLowerCase();
      if (!const <String>{'jpg', 'jpeg', 'png'}.contains(extension)) {
        throw ApiException.validation(
          message: 'يجب أن تكون صور الشكوى بصيغة JPG أو PNG.',
          errors: const <String, List<String>>{
            'images': <String>['يجب أن تكون صور الشكوى بصيغة JPG أو PNG.'],
          },
        );
      }
      if (attachment.sizeInBytes > maxBytes) {
        throw ApiException.validation(
          message: 'يجب ألا يتجاوز حجم كل صورة شكوى 5 ميغابايت.',
          errors: const <String, List<String>>{
            'images': <String>[
              'يجب ألا يتجاوز حجم كل صورة شكوى 5 ميغابايت.',
            ],
          },
        );
      }
    }
  }
}

String? _trimmed(String? value) {
  final normalized = value?.trim();
  return normalized == null || normalized.isEmpty ? null : normalized;
}

String? _nullableString(Object? value) {
  if (value == null) return null;
  final normalized = value.toString().trim();
  return normalized.isEmpty ? null : normalized;
}

String _requiredString(Map<String, dynamic> json, String key) {
  final value = _nullableString(json[key]);
  if (value != null) return value;
  throw FormatException('Missing or invalid "$key" in complaint payload.');
}

String _requiredStringFromKeys(
  Map<String, dynamic> json,
  List<String> keys,
) {
  for (final key in keys) {
    final value = _nullableString(json[key]);
    if (value != null) return value;
  }
  throw FormatException('Missing complaint image URL.');
}

int _requiredInt(Map<String, dynamic> json, String key) {
  final value = _nullableInt(json[key]);
  if (value != null) return value;
  throw FormatException('Missing or invalid "$key" in complaint payload.');
}

int? _nullableInt(Object? value) {
  if (value is int) return value;
  if (value is num) return value.toInt();
  return int.tryParse(value?.toString() ?? '');
}

double? _nullableDouble(Object? value) {
  if (value is num) return value.toDouble();
  return double.tryParse(value?.toString() ?? '');
}

bool? _nullableBool(Object? value) {
  if (value is bool) return value;
  if (value is num) return value != 0;
  if (value is String) {
    final normalized = value.toLowerCase().trim();
    if (normalized == 'true' || normalized == '1') return true;
    if (normalized == 'false' || normalized == '0') return false;
  }
  return null;
}

DateTime? _nullableDateTime(Object? value) {
  final normalized = _nullableString(value);
  return normalized == null ? null : DateTime.tryParse(normalized);
}

Map<String, dynamic>? _nullableMap(Object? value) {
  if (value is Map<String, dynamic>) return value;
  if (value is Map) {
    return value.map(
      (key, dynamic item) => MapEntry(key.toString(), item),
    );
  }
  return null;
}

List<Map<String, dynamic>> _mapList(Object? value) {
  if (value == null) return const <Map<String, dynamic>>[];
  if (value is! Iterable) {
    throw const FormatException('Invalid complaint images payload.');
  }
  return value.map((item) {
    final map = _nullableMap(item);
    if (map == null) {
      throw const FormatException('Invalid complaint image item.');
    }
    return map;
  }).toList(growable: false);
}
