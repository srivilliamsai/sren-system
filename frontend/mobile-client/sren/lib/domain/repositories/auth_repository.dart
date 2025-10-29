import '../entities/auth_tokens.dart';
import '../entities/user.dart';

abstract class AuthRepository {
  Stream<User?> get userStream;
  User? get currentUser;
  AuthTokens? get currentTokens;

  Future<void> init();
  Future<User> login({
    required String email,
    required String password,
  });
  Future<String> register({
    required String name,
    required String email,
    required String password,
  });
  Future<void> logout();
  Future<AuthTokens> refreshTokens(String refreshToken);
}
