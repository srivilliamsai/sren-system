import '../repositories/auth_repository.dart';

class RegisterUseCase {
  RegisterUseCase(this._authRepository);

  final AuthRepository _authRepository;

  Future<String> execute({
    required String name,
    required String email,
    required String password,
  }) {
    return _authRepository.register(
      name: name,
      email: email,
      password: password,
    );
  }
}
