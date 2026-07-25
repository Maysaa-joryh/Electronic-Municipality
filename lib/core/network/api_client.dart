import 'package:dio/dio.dart';

import '../config/api_config.dart';
import '../storage/token_storage.dart';
import 'api_exception.dart';

/// Dio wrapper responsible for transport, authorization, and error mapping.
class ApiClient {
  ApiClient({
    required TokenStorage tokenStorage,
    Dio? dio,
  })  : _tokenStorage = tokenStorage,
        _dio = dio ??
            Dio(
              BaseOptions(
                baseUrl: ApiConfig.normalizedBaseUrl,
                connectTimeout: ApiConfig.connectTimeout,
                sendTimeout: ApiConfig.sendTimeout,
                receiveTimeout: ApiConfig.receiveTimeout,
                responseType: ResponseType.json,
                headers: const {
                  'Accept': 'application/json',
                },
              ),
            ) {
    _dio.interceptors.add(
      InterceptorsWrapper(
        onRequest: _authorizeRequest,
        onError: _handleUnauthorizedResponse,
      ),
    );
  }

  static const String _requiresAuthExtra = 'requires_auth';

  final TokenStorage _tokenStorage;
  final Dio _dio;

  Future<Map<String, dynamic>> get(
    String path, {
    Map<String, dynamic>? queryParameters,
    bool requiresAuth = true,
  }) {
    return _request(
      path,
      method: 'GET',
      queryParameters: queryParameters,
      requiresAuth: requiresAuth,
    );
  }

  Future<Map<String, dynamic>> post(
    String path, {
    Object? data,
    Map<String, dynamic>? queryParameters,
    bool requiresAuth = true,
  }) {
    return _request(
      path,
      method: 'POST',
      data: data,
      queryParameters: queryParameters,
      requiresAuth: requiresAuth,
    );
  }

  Future<Map<String, dynamic>> put(
    String path, {
    Object? data,
    Map<String, dynamic>? queryParameters,
    bool requiresAuth = true,
  }) {
    return _request(
      path,
      method: 'PUT',
      data: data,
      queryParameters: queryParameters,
      requiresAuth: requiresAuth,
    );
  }

  Future<Map<String, dynamic>> patch(
    String path, {
    Object? data,
    Map<String, dynamic>? queryParameters,
    bool requiresAuth = true,
  }) {
    return _request(
      path,
      method: 'PATCH',
      data: data,
      queryParameters: queryParameters,
      requiresAuth: requiresAuth,
    );
  }

  Future<Map<String, dynamic>> delete(
    String path, {
    Object? data,
    Map<String, dynamic>? queryParameters,
    bool requiresAuth = true,
  }) {
    return _request(
      path,
      method: 'DELETE',
      data: data,
      queryParameters: queryParameters,
      requiresAuth: requiresAuth,
    );
  }

  Future<Map<String, dynamic>> _request(
    String path, {
    required String method,
    Object? data,
    Map<String, dynamic>? queryParameters,
    required bool requiresAuth,
  }) async {
    if (requiresAuth && !await _tokenStorage.hasToken()) {
      throw ApiException.unauthorized();
    }

    try {
      final response = await _dio.request<Object?>(
        path,
        data: data,
        queryParameters: queryParameters,
        options: Options(
          method: method,
          extra: <String, Object?>{
            _requiresAuthExtra: requiresAuth,
          },
        ),
      );

      final body = response.data;
      if (body is Map<String, dynamic>) return body;
      if (body is Map) {
        return body.map(
          (key, dynamic value) => MapEntry(key.toString(), value),
        );
      }

      throw ApiException.invalidResponse(
        message: 'أعاد الخادم استجابة ليست كائن JSON.',
      );
    } on ApiException {
      rethrow;
    } on DioException catch (error) {
      throw ApiException.fromDioException(error);
    } catch (error) {
      throw ApiException(
        kind: ApiExceptionKind.unknown,
        message: 'حدث خطأ غير متوقع أثناء تجهيز الطلب.',
        cause: error,
      );
    }
  }

  Future<void> _authorizeRequest(
    RequestOptions options,
    RequestInterceptorHandler handler,
  ) async {
    final requiresAuth = options.extra[_requiresAuthExtra] == true;

    if (!requiresAuth) {
      options.headers.remove('Authorization');
      options.headers.remove('authorization');
      handler.next(options);
      return;
    }

    final token = await _tokenStorage.readToken();
    if (token != null) {
      options.headers['Authorization'] = 'Bearer $token';
    }

    handler.next(options);
  }

  Future<void> _handleUnauthorizedResponse(
    DioException error,
    ErrorInterceptorHandler handler,
  ) async {
    final wasAuthenticated =
        error.requestOptions.extra[_requiresAuthExtra] == true;

    if (wasAuthenticated && error.response?.statusCode == 401) {
      await _tokenStorage.deleteToken();
    }

    handler.next(error);
  }

  void close({bool force = false}) {
    _dio.close(force: force);
  }
}
