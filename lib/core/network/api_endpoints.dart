abstract final class ApiEndpoints {
  // Authentication
  static const String login = 'auth/login';
  static const String registerCitizen = 'auth/register-citizen';
  static const String forgotPassword = 'auth/forgot-password';
  static const String verifyResetOtp = 'auth/verify-reset-otp';
  static const String resetPassword = 'auth/reset-password';
  static const String changeTemporaryPassword =
      'auth/change-temporary-password';
  static const String logout = 'auth/logout';
  static const String me = 'auth/me';

  // Public reference data
  static const String governorates = 'public/governorates';

  static String municipalitiesByGovernorate(int governorateId) {
    return 'public/governorates/$governorateId/municipalities';
  }

  // Citizen
  static const String uploadIdentityPhotos = 'citizen/identity-photos';
  
  // Citizen complaints
  static const String citizenComplaints = 'citizen/complaints';
  static const String citizenComplaintDrafts = 'citizen/complaints/drafts';

  static String citizenComplaintById(int complaintId) {
    return 'citizen/complaints/$complaintId';
  }

  static String citizenComplaintImages(int complaintId) {
    return 'citizen/complaints/$complaintId/images';
  }

  static String citizenComplaintSubmit(int complaintId) {
    return 'citizen/complaints/$complaintId/submit';
  }

  static String citizenComplaintImage(int complaintId, int imageId) {
    return 'citizen/complaints/$complaintId/images/$imageId';
  }
}
