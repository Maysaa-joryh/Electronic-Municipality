import 'package:electronic_municipality/features/complaints/data/complaints_remote_data_source.dart';
import 'package:electronic_municipality/features/complaints/data/complaints_repository.dart';
import 'package:electronic_municipality/features/complaints/data/complaints_repository_api.dart';
import 'package:flutter/foundation.dart';

import 'package:electronic_municipality/core/network/api_client.dart';
import 'package:electronic_municipality/core/repositories/auth_repository.dart';
import 'package:electronic_municipality/core/storage/token_storage.dart';
import 'package:electronic_municipality/features/authentication/data/auth_remote_data_source.dart';
import 'package:electronic_municipality/features/authentication/data/auth_repository_api.dart';
import 'package:electronic_municipality/features/profile/data/citizen_verification_remote_data_source.dart';
import 'package:electronic_municipality/features/profile/data/citizen_verification_repository_api.dart';

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

  static ComplaintsRepository _buildComplaintsRepository() {
    return ComplaintsRepositoryApi(
      remoteDataSource: complaintsRemoteDataSource,
    );
  }

  static AuthRepository get auth => _auth;
 static ComplaintsRepository _complaints = _buildComplaintsRepository();

static ComplaintsRepository get complaints => _complaints;
  static CitizenVerificationRepository get citizenVerification =>
      _citizenVerification;

  static final ComplaintsRemoteDataSource complaintsRemoteDataSource =
      ComplaintsRemoteDataSource(apiClient);
  @visibleForTesting
  static void overrideAuth(AuthRepository repository) {
    _auth = repository;
  }

 
 @visibleForTesting
static void resetAuth() {
  _auth = _buildAuthRepository();
  _citizenVerification = _buildCitizenVerificationRepository();
  _complaints = _buildComplaintsRepository();
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
