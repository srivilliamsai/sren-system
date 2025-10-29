import '../entities/user.dart';
import '../repositories/auth_repository.dart';

class LoginUseCase {
  LoginUseCase(this._authRepository);

  final AuthRepository _authRepository;

  Future<User> execute({
    required String email,
    required String password,
  }) {
    return _authRepository.login(email: email, password: password);
  }
}
