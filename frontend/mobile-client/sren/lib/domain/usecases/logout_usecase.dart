import '../repositories/auth_repository.dart';

class LogoutUseCase {
  LogoutUseCase(this._authRepository);

  final AuthRepository _authRepository;

  Future<void> execute() => _authRepository.logout();
}
