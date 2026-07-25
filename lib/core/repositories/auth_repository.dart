class CitizenRegistration {
  const CitizenRegistration({
    required this.fullName,
    required this.nationalId,
    required this.dateOfBirth,
    required this.placeOfBirth,
    required this.governorate,
    required this.municipality,
    required this.phone,
    required this.email,
    required this.password,
    required this.needsSpecialCare,
    required this.acceptedTerms,
  });

  final String fullName;
  final String nationalId;
  final DateTime dateOfBirth;
  final String placeOfBirth;
  final String governorate;
  final String municipality;
  final String phone;
  final String email;
  final String password;
  final bool needsSpecialCare;
  final bool acceptedTerms;
}

abstract class AuthRepository {
  /// Perform login using phone/email and password.
  Future<void> login({required String identifier, required String password});

  /// Create a citizen account after its phone number has been verified.
  Future<void> registerCitizen({required CitizenRegistration registration});

  /// Request an OTP to be sent to the given contact (phone or email).
  Future<void> requestOtp({required String contact});

  /// Verify the OTP code.
  Future<bool> verifyOtp({required String contact, required String code});

  /// Reset the password for the given contact.
  Future<void> resetPassword(
      {required String contact, required String newPassword});
}
