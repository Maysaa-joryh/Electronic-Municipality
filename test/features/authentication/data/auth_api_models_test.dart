import 'package:dio/dio.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:electronic_municipality/core/network/api_exception.dart';
import 'package:electronic_municipality/features/authentication/data/auth_remote_data_source.dart';
import 'package:electronic_municipality/features/authentication/data/models/auth_session_model.dart';

void main() {
  group('AuthSessionModel', () {
    test('parses the Laravel login payload', () {
      final session = AuthSessionModel.fromJson(
        <String, dynamic>{
          'token': '1|sanctum-token',
          'requires_password_change': false,
          'user': <String, dynamic>{
            'id': 7,
            'name': 'malik',
            'phone_number': '0991234567',
            'email': 'malik@example.sy',
            'roles': <String>['citizen'],
            'account_type': 'citizen',
            'citizen_profile': <String, dynamic>{
              'full_name': 'مالك الشحرور',
              'is_verified': false,
            },
            'employee_profile': null,
          },
        },
      );

      expect(session.token, '1|sanctum-token');
      expect(session.requiresPasswordChange, isFalse);
      expect(session.user.id, 7);
      expect(session.user.displayName, 'مالك الشحرور');
      expect(session.user.isCitizen, isTrue);
      expect(session.user.isCitizenVerified, isFalse);
    });

    test('rejects a payload without a token', () {
      expect(
        () => AuthSessionModel.fromJson(
          <String, dynamic>{
            'user': <String, dynamic>{},
          },
        ),
        throwsFormatException,
      );
    });
  });

  test('citizen registration matches the Laravel field names', () {
    final request = CitizenRegistrationApiRequest(
      name: 'malik',
      fullName: 'مالك الشحرور',
      phoneNumber: '0991234567',
      email: 'malik@example.sy',
      password: 'Password123',
      gender: CitizenGender.male,
      birthDate: DateTime(2001, 2, 3),
      nationalId: '01234567890',
      address: 'دمشق - بلدية دمشق',
    );

    expect(
      request.toJson(),
      <String, dynamic>{
        'name': 'malik',
        'full_name': 'مالك الشحرور',
        'phone_number': '0991234567',
        'email': 'malik@example.sy',
        'password': 'Password123',
        'password_confirmation': 'Password123',
        'gender': 'Male',
        'birth_date': '2001-02-03',
        'national_id': '01234567890',
        'address': 'دمشق - بلدية دمشق',
      },
    );
  });

  test('maps Laravel validation errors to field errors', () {
    final requestOptions = RequestOptions(path: 'auth/login');
    final dioError = DioException(
      requestOptions: requestOptions,
      response: Response<Map<String, dynamic>>(
        requestOptions: requestOptions,
        statusCode: 422,
        data: <String, dynamic>{
          'message': 'The given data was invalid.',
          'errors': <String, dynamic>{
            'email': <String>['The email field is required.'],
          },
        },
      ),
      type: DioExceptionType.badResponse,
    );

    final error = ApiException.fromDioException(dioError);

    expect(error.kind, ApiExceptionKind.validation);
    expect(error.statusCode, 422);
    expect(error.errorFor('email'), 'The email field is required.');
  });
}
