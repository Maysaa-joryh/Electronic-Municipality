import 'dart:async';

import 'package:electronic_municipality/core/repositories/auth_repository.dart';

class AuthRepositoryFake implements AuthRepository {
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
    // Generate a deterministic fake 4-digit code for testing
    final code = (contact.hashCode.abs() % 9000 + 1000).toString();
    _otpStore[contact] = code;
  }

  @override
  Future<void> resetPassword(
      {required String contact, required String newPassword}) async {
    await Future.delayed(const Duration(milliseconds: 600));
    if (newPassword.length < 8) throw Exception('Weak password');
  }
}
