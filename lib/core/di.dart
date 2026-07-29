import 'package:flutter/foundation.dart';

import 'package:electronic_municipality/core/network/api_client.dart';
import 'package:electronic_municipality/core/repositories/auth_repository.dart';
import 'package:electronic_municipality/core/storage/token_storage.dart';
import 'package:electronic_municipality/features/authentication/data/auth_remote_data_source.dart';
import 'package:electronic_municipality/features/authentication/data/auth_repository_api.dart';
import 'package:electronic_municipality/features/profile/data/citizen_verification_remote_data_source.dart';
import 'package:electronic_municipality/features/profile/data/citizen_verification_repository_api.dart';

/// Dependencies used by the running application.
///
/// Tests can continue using AuthRepositoryFake directly.
class DI {
  DI._();

  static final TokenStorage tokenStorage = TokenStorage();

  static final ApiClient apiClient = ApiClient(
    tokenStorage: tokenStorage,
  );

  static final AuthRemoteDataSource authRemoteDataSource =
      AuthRemoteDataSource(apiClient);

  static AuthRepository _auth = _buildAuthRepository();
  static CitizenVerificationRepository _citizenVerification =
      _buildCitizenVerificationRepository();

  static AuthRepository get auth => _auth;
  static CitizenVerificationRepository get citizenVerification =>
      _citizenVerification;

  @visibleForTesting
  static void overrideAuth(AuthRepository repository) {
    _auth = repository;
  }

  @visibleForTesting
  static void resetAuth() {
    _auth = _buildAuthRepository();
    _citizenVerification = _buildCitizenVerificationRepository();
  }

  @visibleForTesting
  static void overrideCitizenVerification(
    CitizenVerificationRepository repository,
  ) {
    _citizenVerification = repository;
  }

  static AuthRepository _buildAuthRepository() {
    return AuthRepositoryApi(
      remoteDataSource: authRemoteDataSource,
      tokenStorage: tokenStorage,
    );
  }

  static CitizenVerificationRepository _buildCitizenVerificationRepository() {
    return CitizenVerificationRepositoryApi(
      remoteDataSource: CitizenVerificationRemoteDataSource(apiClient),
    );
  }
}
