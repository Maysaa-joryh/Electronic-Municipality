
class ComplaintImage {
  const ComplaintImage({required this.id, required this.url});

  final int id;
  final String url;

  factory ComplaintImage.fromJson(Map<String, dynamic> json) {
    return ComplaintImage(
      id: _toInt(json['id']),
      url: (json['url'] ?? json['image_url'] ?? json['path'] ?? '')
          .toString(),
    );
  }

  static int _toInt(Object? value) {
    if (value is int) return value;
    if (value is num) return value.toInt();
    return int.tryParse(value?.toString() ?? '') ?? 0;
  }
}

class ComplaintApiModel {
  const ComplaintApiModel({
    required this.id,
    required this.title,
    required this.description,
    required this.status,
    required this.municipalityId,
    required this.categoryId,
    this.categoryName,
    this.textLocation,
    this.latitude,
    this.longitude,
    this.createdAt,
    this.updatedAt,
    this.images = const <ComplaintImage>[],
  });

  final int id;
  final String title;
  final String description;

  final String status;

  final int municipalityId;
  final int categoryId;
  final String? categoryName;
  final String? textLocation;
  final double? latitude;
  final double? longitude;
  final DateTime? createdAt;
  final DateTime? updatedAt;
  final List<ComplaintImage> images;

  factory ComplaintApiModel.fromJson(Map<String, dynamic> json) {
    final category = _nullableMap(json['category']);

    return ComplaintApiModel(
      id: _requiredInt(json, 'id'),
      title: (json['title'] ?? '').toString(),
      description: (json['description'] ?? '').toString(),
      status: (json['status'] ?? 'draft').toString(),
      municipalityId: _requiredInt(json, 'municipality_id'),
      categoryId: json['category_id'] != null
          ? _toInt(json['category_id'])
          : _toInt(category?['id']),
      categoryName: (category?['name'] ?? json['category_name'])?.toString(),
      textLocation:
          (json['text_location'] ?? json['location'])?.toString(),
      latitude: _toDoubleOrNull(json['latitude']),
      longitude: _toDoubleOrNull(json['longitude']),
      createdAt: _toDateOrNull(json['created_at']),
      updatedAt: _toDateOrNull(json['updated_at']),
      images: _toImageList(json['images']),
    );
  }

  static Map<String, dynamic>? _nullableMap(Object? value) {
    if (value == null) return null;
    if (value is Map<String, dynamic>) return value;
    if (value is Map) {
      return value.map((key, dynamic item) => MapEntry(key.toString(), item));
    }
    return null;
  }

  static List<ComplaintImage> _toImageList(Object? value) {
    if (value is! Iterable) return const <ComplaintImage>[];
    return value
        .map((dynamic item) {
          final map = _nullableMap(item);
          return map == null ? null : ComplaintImage.fromJson(map);
        })
        .whereType<ComplaintImage>()
        .toList(growable: false);
  }

  static int _requiredInt(Map<String, dynamic> json, String key) {
    final value = json[key];
    if (value is int) return value;
    if (value is num) return value.toInt();
    final parsed = int.tryParse(value?.toString() ?? '');
    if (parsed != null) return parsed;
    throw FormatException('Missing or invalid "$key" in complaint payload.');
  }

  static int _toInt(Object? value) {
    if (value is int) return value;
    if (value is num) return value.toInt();
    return int.tryParse(value?.toString() ?? '') ?? 0;
  }

  static double? _toDoubleOrNull(Object? value) {
    if (value == null) return null;
    if (value is double) return value;
    if (value is num) return value.toDouble();
    return double.tryParse(value.toString());
  }

  static DateTime? _toDateOrNull(Object? value) {
    if (value == null) return null;
    return DateTime.tryParse(value.toString());
  }
}
