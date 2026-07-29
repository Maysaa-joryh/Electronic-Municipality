import 'package:dio/dio.dart';

import '../../../core/config/api_config.dart';
import '../../../core/network/api_client.dart';
import '../../../core/network/api_exception.dart';
import 'models/auth_session_model.dart';
import 'models/auth_user_model.dart';
import '../../../core/network/api_endpoints.dart';

enum CitizenGender { male, female }

/// Exact request contract currently required by Laravel's
/// `RegisterCitizenRequest`.
class CitizenRegistrationApiRequest {
  const CitizenRegistrationApiRequest({
    required this.name,
    required this.fullName,
    required this.phoneNumber,
    required this.email,
    required this.password,
    required this.gender,
    required this.birthDate,
    required this.nationalId,
    required this.address,
  });

  final String name;
  final String fullName;
  final String phoneNumber;
  final String email;
  final String password;
  final CitizenGender gender;
  final DateTime birthDate;
  final String nationalId;
  final String address;

  Map<String, dynamic> toJson() {
    return <String, dynamic>{
      'name': name.trim(),
      'full_name': fullName.trim(),
      'phone_number': phoneNumber.trim(),
      'email': email.trim(),
      'password': password,
      'password_confirmation': password,
      'gender': gender == CitizenGender.male ? 'Male' : 'Female',
      'birth_date': _dateOnly(birthDate),
      'national_id': nationalId.trim(),
      'address': address.trim(),
    };
  }

  static String _dateOnly(DateTime value) {
    final month = value.month.toString().padLeft(2, '0');
    final day = value.day.toString().padLeft(2, '0');
    return '${value.year}-$month-$day';
  }
}

class ResetOtpVerification {
  const ResetOtpVerification({this.resetToken});

  /// The current backend does not return this value yet. Keeping it in the
  /// contract makes the client ready for the required secure backend fix.
  final String? resetToken;
}

class AuthRemoteDataSource {
  const AuthRemoteDataSource(this._client);

  final ApiClient _client;

  Future<AuthSessionModel> login({
    required String email,
    required String password,
  }) async {
    final envelope = await _client.post(
      ApiEndpoints.login,
      requiresAuth: false,
      data: <String, dynamic>{
        'email': email.trim(),
        'password': password,
        'device_name': ApiConfig.deviceName,
      },
    );

    return _sessionFromEnvelope(envelope);
  }

  Future<AuthSessionModel> registerCitizen(
    CitizenRegistrationApiRequest request,
  ) async {
    final envelope = await _client.post(
      ApiEndpoints.registerCitizen,
      requiresAuth: false,
      data: FormData.fromMap(request.toJson()),
    );

    return _sessionFromEnvelope(envelope);
  }

  Future<void> requestPasswordReset({required String email}) async {
    final envelope = await _client.post(
      ApiEndpoints.forgotPassword,
      requiresAuth: false,
      data: <String, dynamic>{'email': email.trim()},
    );
    _validateSuccess(envelope);
  }

  Future<ResetOtpVerification> verifyResetOtp({
    required String email,
    required String otp,
  }) async {
    final envelope = await _client.post(
      ApiEndpoints.verifyResetOtp,
      requiresAuth: false,
      data: <String, dynamic>{
        'email': email.trim(),
        'otp': otp.trim(),
      },
    );
    _validateSuccess(envelope);

    final data = _nullableMap(envelope['data']);
    final resetToken = data?['reset_token']?.toString().trim();
    return ResetOtpVerification(
      resetToken: resetToken == null || resetToken.isEmpty ? null : resetToken,
    );
  }

  Future<void> resetPassword({
    required String email,
    required String resetToken,
    required String password,
  }) async {
    final envelope = await _client.post(
      ApiEndpoints.resetPassword,
      requiresAuth: false,
      data: <String, dynamic>{
        'email': email.trim(),
        'reset_token': resetToken,
        'password': password,
        'password_confirmation': password,
      },
    );
    _validateSuccess(envelope);
  }

  Future<AuthUserModel> fetchCurrentUser() async {
    final envelope = await _client.get(ApiEndpoints.me);
    final data = _requiredData(envelope);
    final user = _nullableMap(data['user']);

    if (user == null) {
      throw ApiException.invalidResponse(
        message: 'لم تتضمن استجابة الخادم بيانات المستخدم.',
      );
    }

    try {
      return AuthUserModel.fromJson(user);
    } on FormatException catch (error) {
      throw ApiException.invalidResponse(cause: error);
    }
  }

  Future<void> logout() async {
    final envelope = await _client.post(ApiEndpoints.logout);
    _validateSuccess(envelope);
  }

  Future<void> changeTemporaryPassword({
    required String currentPassword,
    required String newPassword,
  }) async {
    final envelope = await _client.post(
      ApiEndpoints.changeTemporaryPassword,
      data: <String, dynamic>{
        'current_password': currentPassword,
        'password': newPassword,
        'password_confirmation': newPassword,
      },
    );
    _validateSuccess(envelope);
  }

  static AuthSessionModel _sessionFromEnvelope(
    Map<String, dynamic> envelope,
  ) {
    final data = _requiredData(envelope);
    try {
      return AuthSessionModel.fromJson(data);
    } on FormatException catch (error) {
      throw ApiException.invalidResponse(cause: error);
    }
  }

  static Map<String, dynamic> _requiredData(
    Map<String, dynamic> envelope,
  ) {
    _validateSuccess(envelope);
    final data = _nullableMap(envelope['data']);
    if (data == null) {
      throw ApiException.invalidResponse(
        message: 'لم تتضمن استجابة الخادم حقل data صالحًا.',
      );
    }
    return data;
  }

  static void _validateSuccess(Map<String, dynamic> envelope) {
    if (envelope['success'] == true) return;

    final message = envelope['message']?.toString().trim();
    throw ApiException.invalidResponse(
      message: message == null || message.isEmpty
          ? 'أعاد الخادم استجابة نجاح غير صالحة.'
          : message,
    );
  }

  static Map<String, dynamic>? _nullableMap(Object? value) {
    if (value == null) return null;
    if (value is Map<String, dynamic>) return value;
    if (value is Map) {
      return value.map(
        (key, dynamic item) => MapEntry(key.toString(), item),
      );
    }
    return null;
  }
}
