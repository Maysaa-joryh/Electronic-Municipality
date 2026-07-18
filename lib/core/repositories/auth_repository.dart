abstract class AuthRepository {
  /// Perform login using phone/email and password.
  Future<void> login({required String identifier, required String password});

  /// Request an OTP to be sent to the given contact (phone or email).
  Future<void> requestOtp({required String contact});

  /// Verify the OTP code.
  Future<bool> verifyOtp({required String contact, required String code});

  /// Reset the password for the given contact.
  Future<void> resetPassword(
      {required String contact, required String newPassword});
}
