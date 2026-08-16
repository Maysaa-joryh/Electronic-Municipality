import 'package:flutter_secure_storage/flutter_secure_storage.dart';

/// Stores only the Laravel Sanctum token in platform-protected storage.
class TokenStorage {
  TokenStorage({FlutterSecureStorage? secureStorage})
      : _secureStorage = secureStorage ?? const FlutterSecureStorage();

  static const String _tokenKey = 'auth.sanctum_token';
  static const String _requiresPasswordChangeKey =
      'auth.requires_password_change';
  static const String _pendingAccountConfirmationContactKey =
      'auth.pending_account_confirmation_contact';

  final FlutterSecureStorage _secureStorage;

  Future<String?> readToken() async {
    final token = (await _secureStorage.read(key: _tokenKey))?.trim();
    return token == null || token.isEmpty ? null : token;
  }

  Future<bool> hasToken() async => await readToken() != null;

  Future<void> writeToken(String token) async {
    final normalized = token.trim();
    if (normalized.isEmpty) {
      throw ArgumentError.value(token, 'token', 'Token must not be empty.');
    }

    await _secureStorage.write(
      key: _tokenKey,
      value: normalized,
    );
  }

  Future<bool> requiresPasswordChange() async {
    return await _secureStorage.read(key: _requiresPasswordChangeKey) == 'true';
  }

  Future<String?> readPendingAccountConfirmationContact() async {
    final contact = await _secureStorage.read(
      key: _pendingAccountConfirmationContactKey,
    );
    final normalized = contact?.trim();
    return normalized == null || normalized.isEmpty ? null : normalized;
  }

  Future<void> writePendingAccountConfirmationContact(String contact) async {
    final normalized = contact.trim();
    if (normalized.isEmpty) {
      throw ArgumentError.value(
        contact,
        'contact',
        'Pending account-confirmation contact must not be empty.',
      );
    }
    await _secureStorage.write(
      key: _pendingAccountConfirmationContactKey,
      value: normalized,
    );
  }

  Future<void> clearPendingAccountConfirmationContact() async {
    await _secureStorage.delete(key: _pendingAccountConfirmationContactKey);
  }

  Future<void> writeSession({
    required String token,
    required bool requiresPasswordChange,
  }) async {
    await writeToken(token);
    await _secureStorage.write(
      key: _requiresPasswordChangeKey,
      value: requiresPasswordChange.toString(),
    );
  }

  Future<void> deleteToken() async {
    await Future.wait<void>([
      _secureStorage.delete(key: _tokenKey),
      _secureStorage.delete(key: _requiresPasswordChangeKey),
    ]);
  }
}
