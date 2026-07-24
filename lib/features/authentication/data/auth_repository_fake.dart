import 'dart:async';

import 'package:electronic_municipality/core/repositories/auth_repository.dart';

class AuthRepositoryFake implements AuthRepository {
  static const developmentOtpCode = '1234';

  final Map<String, String> _otpStore = {};

  @override
  Future<void> login(
      {required String identifier, required String password}) async {
    await Future.delayed(const Duration(milliseconds: 600));
    // Fake: accept any non-empty credentials
    if (identifier.isEmpty || password.isEmpty) {
      throw Exception('Credentials required');
    }
  }

  @override
  Future<bool> verifyOtp(
      {required String contact, required String code}) async {
    await Future.delayed(const Duration(milliseconds: 400));
    final expected = _otpStore[contact];
    return expected != null && expected == code;
  }

  @override
  Future<void> requestOtp({required String contact}) async {
    await Future.delayed(const Duration(milliseconds: 500));
    // Development-only fake. A production repository must issue OTPs server-side.
    _otpStore[contact] = developmentOtpCode;
  }

  @override
  Future<void> resetPassword(
      {required String contact, required String newPassword}) async {
    await Future.delayed(const Duration(milliseconds: 600));
    if (newPassword.length < 8) throw Exception('Weak password');
  }
}
