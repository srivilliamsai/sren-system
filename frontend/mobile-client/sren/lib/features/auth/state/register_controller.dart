import 'package:hooks_riverpod/hooks_riverpod.dart';

import '../../../core/errors/app_exception.dart';
import '../../../core/di/locator.dart';
import '../../../domain/usecases/register_usecase.dart';

final registerControllerProvider =
    AutoDisposeAsyncNotifierProvider<RegisterController, String?>(
  RegisterController.new,
);

class RegisterController extends AutoDisposeAsyncNotifier<String?> {
  RegisterUseCase get _registerUseCase => ref.read(registerUseCaseProvider);

  @override
  Future<String?> build() async => null;

  Future<String?> register({
    required String name,
    required String email,
    required String password,
  }) async {
    state = const AsyncValue.loading();
    try {
      final id = await _registerUseCase.execute(
        name: name,
        email: email,
        password: password,
      );
      state = AsyncValue.data(id);
      return id;
    } catch (error, stackTrace) {
      state = AsyncValue.error(
        error is AppException ? error.message : error,
        stackTrace,
      );
      return null;
    }
  }
}
