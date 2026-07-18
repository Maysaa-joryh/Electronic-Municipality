import 'package:electronic_municipality/features/authentication/data/auth_repository_fake.dart';

/// Simple development DI container. Replace with provider/get_it later.
class DI {
  static final auth = AuthRepositoryFake();
}
