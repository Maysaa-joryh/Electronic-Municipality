import 'package:electronic_municipality/core/network/api_client.dart';
import 'package:electronic_municipality/core/repositories/auth_repository.dart';
import 'package:electronic_municipality/core/storage/token_storage.dart';
import 'package:electronic_municipality/features/authentication/data/auth_remote_data_source.dart';
import 'package:electronic_municipality/features/authentication/data/auth_repository_api.dart';

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

  static final AuthRepository auth = AuthRepositoryApi(
    remoteDataSource: authRemoteDataSource,
    tokenStorage: tokenStorage,
  );
}
