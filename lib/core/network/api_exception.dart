import 'package:dio/dio.dart';

enum ApiExceptionKind {
  network,
  timeout,
  unauthorized,
  forbidden,
  notFound,
  validation,
  rateLimited,
  server,
  cancelled,
  invalidResponse,
  configuration,
  unknown,
}

/// A stable application-facing error independent of Dio and Laravel internals.
class ApiException implements Exception {
  const ApiException({
    required this.kind,
    required this.message,
    this.statusCode,
    this.errors = const {},
    this.cause,
  });

  factory ApiException.fromDioException(DioException exception) {
    switch (exception.type) {
      case DioExceptionType.connectionTimeout:
      case DioExceptionType.sendTimeout:
      case DioExceptionType.receiveTimeout:
      case DioExceptionType.transformTimeout:
        return ApiException(
          kind: ApiExceptionKind.timeout,
          message: 'انتهت مهلة الاتصال بالخادم. حاول مرة أخرى.',
          cause: exception,
        );
      case DioExceptionType.connectionError:
        return ApiException(
          kind: ApiExceptionKind.network,
          message: 'تعذر الاتصال بالخادم. تحقق من الشبكة وعنوان الخادم.',
          cause: exception,
        );
      case DioExceptionType.cancel:
        return ApiException(
          kind: ApiExceptionKind.cancelled,
          message: 'تم إلغاء الطلب.',
          cause: exception,
        );
      case DioExceptionType.badCertificate:
        return ApiException(
          kind: ApiExceptionKind.network,
          message: 'تعذر التحقق من شهادة أمان الخادم.',
          cause: exception,
        );
      case DioExceptionType.badResponse:
        return _fromResponse(exception);
      case DioExceptionType.unknown:
        return ApiException(
          kind: ApiExceptionKind.unknown,
          message: 'حدث خطأ غير متوقع أثناء الاتصال بالخادم.',
          cause: exception,
        );
    }
  }

  factory ApiException.invalidResponse({
    String message = 'أعاد الخادم استجابة غير صالحة.',
    Object? cause,
  }) {
    return ApiException(
      kind: ApiExceptionKind.invalidResponse,
      message: message,
      cause: cause,
    );
  }

  factory ApiException.configuration(String message) {
    return ApiException(
      kind: ApiExceptionKind.configuration,
      message: message,
    );
  }

  factory ApiException.unauthorized({
    String message = 'يجب تسجيل الدخول للمتابعة.',
  }) {
    return ApiException(
      kind: ApiExceptionKind.unauthorized,
      message: message,
      statusCode: 401,
    );
  }

  factory ApiException.validation({
    required String message,
    Map<String, List<String>> errors = const {},
  }) {
    return ApiException(
      kind: ApiExceptionKind.validation,
      message: message,
      statusCode: 422,
      errors: errors,
    );
  }

  final ApiExceptionKind kind;
  final String message;
  final int? statusCode;
  final Map<String, List<String>> errors;
  final Object? cause;

  bool get isUnauthorized => kind == ApiExceptionKind.unauthorized;
  bool get isValidation => kind == ApiExceptionKind.validation;

  String? errorFor(String field) {
    final fieldErrors = errors[field];
    return fieldErrors == null || fieldErrors.isEmpty
        ? null
        : fieldErrors.first;
  }

  static ApiException _fromResponse(DioException exception) {
    final response = exception.response;
    final statusCode = response?.statusCode;
    final body = _asStringKeyedMap(response?.data);
    final errors = _normalizeErrors(body?['errors']);
    final serverMessage = _nonEmptyString(body?['message']);
    String? validationMessage;

    for (final messages in errors.values) {
      if (messages.isNotEmpty) {
        validationMessage = messages.first;
        break;
      }
    }

    final kind = _kindForStatus(statusCode);
    final fallbackMessage = _fallbackMessageFor(kind);

    return ApiException(
      kind: kind,
      message: serverMessage ?? validationMessage ?? fallbackMessage,
      statusCode: statusCode,
      errors: errors,
      cause: exception,
    );
  }

  static Map<String, dynamic>? _asStringKeyedMap(Object? value) {
    if (value is Map<String, dynamic>) return value;
    if (value is Map) {
      return value.map(
        (key, dynamic item) => MapEntry(key.toString(), item),
      );
    }
    return null;
  }

  static Map<String, List<String>> _normalizeErrors(Object? value) {
    final map = _asStringKeyedMap(value);
    if (map == null) return const {};

    final result = <String, List<String>>{};
    for (final entry in map.entries) {
      final rawValue = entry.value;
      final messages = rawValue is Iterable
          ? rawValue
              .map((item) => item.toString().trim())
              .where((item) => item.isNotEmpty)
              .toList(growable: false)
          : <String>[
              if (rawValue != null && rawValue.toString().trim().isNotEmpty)
                rawValue.toString().trim(),
            ];

      if (messages.isNotEmpty) {
        result[entry.key] = List<String>.unmodifiable(messages);
      }
    }

    return Map<String, List<String>>.unmodifiable(result);
  }

  static String? _nonEmptyString(Object? value) {
    if (value is! String) return null;
    final normalized = value.trim();
    return normalized.isEmpty ? null : normalized;
  }

  static ApiExceptionKind _kindForStatus(int? statusCode) {
    if (statusCode == 401) return ApiExceptionKind.unauthorized;
    if (statusCode == 403) return ApiExceptionKind.forbidden;
    if (statusCode == 404) return ApiExceptionKind.notFound;
    if (statusCode == 422) return ApiExceptionKind.validation;
    if (statusCode == 429) return ApiExceptionKind.rateLimited;
    if (statusCode != null && statusCode >= 500 && statusCode <= 599) {
      return ApiExceptionKind.server;
    }
    return ApiExceptionKind.unknown;
  }

  static String _fallbackMessageFor(ApiExceptionKind kind) {
    switch (kind) {
      case ApiExceptionKind.unauthorized:
        return 'بيانات الدخول غير صحيحة أو انتهت صلاحية الجلسة.';
      case ApiExceptionKind.forbidden:
        return 'لا تملك صلاحية تنفيذ هذه العملية.';
      case ApiExceptionKind.notFound:
        return 'المورد المطلوب غير موجود.';
      case ApiExceptionKind.validation:
        return 'تحقق من البيانات المدخلة.';
      case ApiExceptionKind.rateLimited:
        return 'تم تجاوز عدد المحاولات المسموح. حاول لاحقًا.';
      case ApiExceptionKind.server:
        return 'حدث خطأ في الخادم. حاول لاحقًا.';
      default:
        return 'تعذر إكمال الطلب.';
    }
  }

  @override
  String toString() {
    final code = statusCode == null ? '' : ', statusCode: $statusCode';
    return 'ApiException(kind: $kind$code, message: $message)';
  }
}
