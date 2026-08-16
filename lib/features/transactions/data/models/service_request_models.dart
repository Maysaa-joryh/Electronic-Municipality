import 'dart:typed_data';

enum ServiceFormFieldType {
  text,
  textarea,
  number,
  date,
  select,
  radio,
  checkbox,
  file;

  static ServiceFormFieldType fromApi(Object? value) {
    return switch (value?.toString()) {
      'textarea' => ServiceFormFieldType.textarea,
      'number' => ServiceFormFieldType.number,
      'date' => ServiceFormFieldType.date,
      'select' => ServiceFormFieldType.select,
      'radio' => ServiceFormFieldType.radio,
      'checkbox' => ServiceFormFieldType.checkbox,
      'file' => ServiceFormFieldType.file,
      _ => ServiceFormFieldType.text,
    };
  }
}

class ServiceFormField {
  const ServiceFormField({
    required this.id,
    required this.fieldKey,
    required this.label,
    required this.type,
    required this.isRequired,
    required this.options,
    required this.validationRules,
    required this.condition,
    required this.sortOrder,
  });

  final int id;
  final String fieldKey;
  final String label;
  final ServiceFormFieldType type;
  final bool isRequired;
  final List<String> options;
  final List<String> validationRules;
  final Map<String, dynamic>? condition;
  final int sortOrder;

  bool get isFile => type == ServiceFormFieldType.file;

  factory ServiceFormField.fromJson(Map<String, dynamic> json) {
    return ServiceFormField(
      id: _int(json['id']),
      fieldKey: _string(json['field_key']),
      label: _string(json['label']),
      type: ServiceFormFieldType.fromApi(json['field_type']),
      isRequired: _bool(json['is_required']),
      options: _stringList(json['options_json']),
      validationRules: _stringList(json['validation_json']),
      condition: _mapOrNull(json['condition_json']),
      sortOrder: _int(json['sort_order']),
    );
  }
}

class ServiceTypeVersion {
  const ServiceTypeVersion({
    required this.id,
    required this.versionNumber,
    required this.isActive,
    required this.fields,
  });

  final int id;
  final int versionNumber;
  final bool isActive;
  final List<ServiceFormField> fields;

  factory ServiceTypeVersion.fromJson(Map<String, dynamic> json) {
    final fields = _mapList(json['fields'])
        .map(ServiceFormField.fromJson)
        .toList(growable: false)
      ..sort((left, right) => left.sortOrder.compareTo(right.sortOrder));
    return ServiceTypeVersion(
      id: _int(json['id']),
      versionNumber: _int(json['version_number']),
      isActive: _bool(json['is_active']),
      fields: fields,
    );
  }
}

class MunicipalServiceType {
  const MunicipalServiceType({
    required this.id,
    required this.name,
    required this.description,
    required this.documentTemplateKey,
    required this.isActive,
    required this.municipalityName,
    required this.activeVersion,
  });

  final int id;
  final String name;
  final String description;
  final String? documentTemplateKey;
  final bool isActive;
  final String? municipalityName;
  final ServiceTypeVersion? activeVersion;

  factory MunicipalServiceType.fromJson(Map<String, dynamic> json) {
    final municipality = _mapOrNull(json['municipality']);
    final activeVersion = _mapOrNull(json['active_version']);
    return MunicipalServiceType(
      id: _int(json['id']),
      name: _string(json['name']),
      description: _string(json['description']),
      documentTemplateKey: _nullableString(json['document_template_key']),
      isActive: _bool(json['is_active']),
      municipalityName: _nullableString(municipality?['name']),
      activeVersion: activeVersion == null
          ? null
          : ServiceTypeVersion.fromJson(activeVersion),
    );
  }
}

class ServiceRequestStatus {
  const ServiceRequestStatus({
    required this.id,
    required this.code,
    required this.name,
    required this.nameAr,
    required this.isTerminal,
  });

  final int id;
  final String code;
  final String name;
  final String nameAr;
  final bool isTerminal;

  String get displayName => nameAr.trim().isEmpty ? name : nameAr;

  factory ServiceRequestStatus.fromJson(Map<String, dynamic> json) {
    return ServiceRequestStatus(
      id: _int(json['id']),
      code: _string(json['code']),
      name: _string(json['name']),
      nameAr: _string(json['name_ar']),
      isTerminal: _bool(json['is_terminal']),
    );
  }
}

class ServiceRequestAttachment {
  const ServiceRequestAttachment({
    required this.id,
    required this.fieldKey,
    required this.originalName,
    required this.mimeType,
    required this.fileSize,
    required this.createdAt,
  });

  final int id;
  final String fieldKey;
  final String originalName;
  final String mimeType;
  final int fileSize;
  final DateTime? createdAt;

  factory ServiceRequestAttachment.fromJson(Map<String, dynamic> json) {
    return ServiceRequestAttachment(
      id: _int(json['id']),
      fieldKey: _string(json['field_key']),
      originalName: _string(json['original_name']),
      mimeType: _string(json['mime_type']),
      fileSize: _int(json['file_size']),
      createdAt: _dateOrNull(json['created_at']),
    );
  }
}

class ServiceRequestDocument {
  const ServiceRequestDocument({
    required this.id,
    required this.documentNumber,
    required this.verificationCode,
    required this.issuedAt,
    required this.expiresAt,
    required this.isExpired,
    required this.isSigned,
  });

  final int id;
  final String documentNumber;
  final String verificationCode;
  final DateTime? issuedAt;
  final DateTime? expiresAt;
  final bool isExpired;
  final bool? isSigned;

  factory ServiceRequestDocument.fromJson(Map<String, dynamic> json) {
    return ServiceRequestDocument(
      id: _int(json['id']),
      documentNumber: _string(json['document_number']),
      verificationCode: _string(json['verification_code']),
      issuedAt: _dateOrNull(json['issued_at']),
      expiresAt: _dateOrNull(json['expires_at']),
      isExpired: _bool(json['is_expired']),
      isSigned: json['is_signed'] is bool ? json['is_signed'] as bool : null,
    );
  }
}

class ServiceRequestServiceType {
  const ServiceRequestServiceType({
    required this.id,
    required this.name,
    required this.municipalityName,
  });

  final int id;
  final String name;
  final String? municipalityName;

  factory ServiceRequestServiceType.fromJson(Map<String, dynamic> json) {
    final municipality = _mapOrNull(json['municipality']);
    return ServiceRequestServiceType(
      id: _int(json['id']),
      name: _string(json['name']),
      municipalityName: _nullableString(municipality?['name']),
    );
  }
}

class MunicipalServiceRequest {
  const MunicipalServiceRequest({
    required this.id,
    required this.serviceType,
    required this.data,
    required this.status,
    required this.attachments,
    required this.submittedAt,
    required this.document,
    required this.createdAt,
    required this.updatedAt,
  });

  final int id;
  final ServiceRequestServiceType? serviceType;
  final Map<String, dynamic> data;
  final ServiceRequestStatus? status;
  final List<ServiceRequestAttachment> attachments;
  final DateTime? submittedAt;
  final ServiceRequestDocument? document;
  final DateTime? createdAt;
  final DateTime? updatedAt;

  bool get isDraft => status?.code == 'draft';
  bool get hasIssuedDocument => document != null;

  factory MunicipalServiceRequest.fromJson(Map<String, dynamic> json) {
    final serviceType = _mapOrNull(json['service_type']);
    final status = _mapOrNull(json['current_status']);
    final document = _mapOrNull(json['document']);
    return MunicipalServiceRequest(
      id: _int(json['id']),
      serviceType: serviceType == null
          ? null
          : ServiceRequestServiceType.fromJson(serviceType),
      data: _mapOrNull(json['data']) ?? const <String, dynamic>{},
      status: status == null ? null : ServiceRequestStatus.fromJson(status),
      attachments: _mapList(json['attachments'])
          .map(ServiceRequestAttachment.fromJson)
          .toList(growable: false),
      submittedAt: _dateOrNull(json['submitted_at']),
      document:
          document == null ? null : ServiceRequestDocument.fromJson(document),
      createdAt: _dateOrNull(json['created_at']),
      updatedAt: _dateOrNull(json['updated_at']),
    );
  }
}

class ServiceRequestAttachmentInput {
  const ServiceRequestAttachmentInput({
    required this.name,
    required this.bytes,
  });

  final String name;
  final Uint8List bytes;
}

class ServiceRequestPage<T> {
  const ServiceRequestPage({
    required this.items,
    required this.currentPage,
    required this.lastPage,
    required this.perPage,
    required this.total,
  });

  final List<T> items;
  final int currentPage;
  final int lastPage;
  final int perPage;
  final int total;

  bool get hasNextPage => currentPage < lastPage;
}

int _int(Object? value) => switch (value) {
      int value => value,
      num value => value.toInt(),
      String value => int.tryParse(value) ?? 0,
      _ => 0,
    };

bool _bool(Object? value) => value == true || value == 1 || value == '1';

String _string(Object? value) => value?.toString() ?? '';

String? _nullableString(Object? value) {
  final result = _string(value).trim();
  return result.isEmpty ? null : result;
}

DateTime? _dateOrNull(Object? value) {
  if (value is! String || value.trim().isEmpty) return null;
  return DateTime.tryParse(value);
}

Map<String, dynamic>? _mapOrNull(Object? value) {
  if (value is Map<String, dynamic>) return value;
  if (value is Map) {
    return value.map((key, item) => MapEntry(key.toString(), item));
  }
  return null;
}

List<Map<String, dynamic>> _mapList(Object? value) {
  if (value is! Iterable) return const <Map<String, dynamic>>[];
  return value
      .map(_mapOrNull)
      .whereType<Map<String, dynamic>>()
      .toList(growable: false);
}

List<String> _stringList(Object? value) {
  if (value is! Iterable) return const <String>[];
  return value.map((item) => item.toString()).toList(growable: false);
}
