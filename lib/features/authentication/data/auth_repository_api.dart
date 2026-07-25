import '../../../core/network/api_exception.dart';
import '../../../core/repositories/auth_repository.dart';
import '../../../core/storage/token_storage.dart';
import 'auth_remote_data_source.dart';
import 'models/auth_session_model.dart';
import 'models/auth_user_model.dart';

typedef CitizenRegistrationMapper = CitizenRegistrationApiRequest Function(
  CitizenRegistration registration,
);

/// API-backed implementation of the existing authentication contract.
///
/// The legacy Flutter registration model is missing `gender` and `national_id`
/// required by Laravel. A mapper must therefore be supplied after those fields
/// are collected by the UI; silently inventing them would corrupt citizen data.
class AuthRepositoryApi implements AuthRepository {
  AuthRepositoryApi({
    required AuthRemoteDataSource remoteDataSource,
    required TokenStorage tokenStorage,
    CitizenRegistrationMapper? registrationMapper,
  })  : _remoteDataSource = remoteDataSource,
        _tokenStorage = tokenStorage,
        _registrationMapper = registrationMapper;

  final AuthRemoteDataSource _remoteDataSource;
  final TokenStorage _tokenStorage;
  final CitizenRegistrationMapper? _registrationMapper;
  final Map<String, String> _resetTokensByEmail = <String, String>{};

  AuthUserModel? _currentUser;
  bool _requiresPasswordChange = false;

  AuthUserModel? get currentUser => _currentUser;
  bool get requiresPasswordChange => _requiresPasswordChange;

  Future<bool> get isAuthenticated => _tokenStorage.hasToken();

  @override
  Future<void> login({
    required String identifier,
    required String password,
  }) async {
    await loginWithEmail(
      email: _requireEmail(identifier),
      password: password,
    );
  }

  Future<AuthSessionModel> loginWithEmail({
    required String email,
    required String password,
  }) async {
    final session = await _remoteDataSource.login(
      email: _requireEmail(email),
      password: password,
    );
    await _persistSession(session);
    return session;
  }

  @override
  Future<void> registerCitizen({
    required CitizenRegistration registration,
  }) async {
    final mapper = _registrationMapper;
    if (mapper == null) {
      throw ApiException.configuration(
        'لا يمكن ربط التسجيل بعد: نموذج Flutter الحالي لا يجمع الجنس '
        'والرقم الوطني المطلوبين من الخادم.',
      );
    }

    await registerCitizenWithRequest(mapper(registration));
  }

  Future<AuthSessionModel> registerCitizenWithRequest(
    CitizenRegistrationApiRequest request,
  ) async {
    final session = await _remoteDataSource.registerCitizen(request);
    await _persistSession(session);
    return session;
  }

  @override
  Future<void> requestOtp({required String contact}) {
    return requestPasswordReset(email: contact);
  }

  Future<void> requestPasswordReset({required String email}) {
    final normalizedEmail = _requireEmail(email);
    _resetTokensByEmail.remove(normalizedEmail);
    return _remoteDataSource.requestPasswordReset(
      email: normalizedEmail,
    );
  }

  @override
  Future<bool> verifyOtp({
    required String contact,
    required String code,
  }) async {
    final email = _requireEmail(contact);

    try {
      final verification = await _remoteDataSource.verifyResetOtp(
        email: email,
        otp: code,
      );

      final resetToken = verification.resetToken;
      if (resetToken != null) {
        _resetTokensByEmail[email] = resetToken;
      }
      return true;
    } on ApiException catch (error) {
      if (error.isValidation && error.errors.containsKey('otp')) {
        return false;
      }
      rethrow;
    }
  }

  @override
  Future<void> resetPassword({
    required String contact,
    required String newPassword,
  }) async {
    final email = _requireEmail(contact);
    final resetToken = _resetTokensByEmail[email];

    if (resetToken == null) {
      throw ApiException.configuration(
        'رفض التطبيق تغيير كلمة المرور لأن الخادم لم يُرجع reset_token '
        'بعد التحقق من OTP. يجب إصلاح عقد الباك قبل تفعيل هذه العملية.',
      );
    }

    await _remoteDataSource.resetPassword(
      email: email,
      resetToken: resetToken,
      password: newPassword,
    );
    _resetTokensByEmail.remove(email);
    await clearLocalSession();
  }

  Future<AuthUserModel?> restoreSession() async {
    if (!await _tokenStorage.hasToken()) return null;

    try {
      final user = await _remoteDataSource.fetchCurrentUser();
      _currentUser = user;
      return user;
    } on ApiException catch (error) {
      if (error.isUnauthorized) {
        await clearLocalSession();
        return null;
      }
      rethrow;
    }
  }

  Future<void> logout() async {
    try {
      if (await _tokenStorage.hasToken()) {
        await _remoteDataSource.logout();
      }
    } finally {
      await clearLocalSession();
    }
  }

  Future<void> changeTemporaryPassword({
    required String currentPassword,
    required String newPassword,
  }) async {
    await _remoteDataSource.changeTemporaryPassword(
      currentPassword: currentPassword,
      newPassword: newPassword,
    );
    await clearLocalSession();
  }

  Future<void> clearLocalSession() async {
    await _tokenStorage.deleteToken();
    _currentUser = null;
    _requiresPasswordChange = false;
  }

  Future<void> _persistSession(AuthSessionModel session) async {
    await _tokenStorage.writeToken(session.token);
    _currentUser = session.user;
    _requiresPasswordChange = session.requiresPasswordChange;
  }

  static String _requireEmail(String value) {
    final email = value.trim().toLowerCase();
    final isValid = RegExp(r'^[^@\s]+@[^@\s]+\.[^@\s]+$').hasMatch(email);
    if (!isValid) {
      throw ApiException.validation(
        message: 'البريد الإلكتروني مطلوب وبصيغة صحيحة.',
        errors: const {
          'email': ['البريد الإلكتروني مطلوب وبصيغة صحيحة.'],
        },
      );
    }
    return email;
  }
}
