import 'dart:async';

import 'package:hooks_riverpod/hooks_riverpod.dart';

import '../../../core/errors/app_exception.dart';
import '../../../core/di/locator.dart';
import '../../../core/utils/analytics.dart';
import '../../../domain/entities/user.dart';
import '../../../domain/repositories/auth_repository.dart';
import '../../../domain/usecases/login_usecase.dart';
import '../../../domain/usecases/logout_usecase.dart';
import 'auth_state.dart';

final authControllerProvider =
    AsyncNotifierProvider<AuthController, AuthState>(AuthController.new);

class AuthController extends AsyncNotifier<AuthState> {
  StreamSubscription<User?>? _userSubscription;

  AuthRepository get _authRepository => ref.read(authRepositoryProvider);

  LoginUseCase get _loginUseCase => ref.read(loginUseCaseProvider);

  LogoutUseCase get _logoutUseCase => ref.read(logoutUseCaseProvider);

  AnalyticsService get _analytics => ref.read(analyticsServiceProvider);

  @override
  Future<AuthState> build() async {
    await _authRepository.init();
    _userSubscription?.cancel();
    _userSubscription = _authRepository.userStream.listen((user) {
      state = AsyncValue.data(
        user != null
            ? AuthState.authenticated(user)
            : const AuthState.unauthenticated(),
      );
    });

    ref.onDispose(() => _userSubscription?.cancel());

    final user = _authRepository.currentUser;
    if (user != null) {
      return AuthState.authenticated(user);
    }
    return const AuthState.unauthenticated();
  }

  Future<void> login({
    required String email,
    required String password,
  }) async {
    final previous = state.valueOrNull ?? const AuthState.unauthenticated();
    state = AsyncValue.data(
      previous.copyWith(isLoading: true, errorMessage: null),
    );

    try {
      final user = await _loginUseCase.execute(
        email: email,
        password: password,
      );
      _analytics.logEvent('login_success', {'userId': user.id});
      state = AsyncValue.data(AuthState.authenticated(user));
    } catch (error, stackTrace) {
      state = AsyncValue.data(
        AuthState(
          status: AuthStatus.unauthenticated,
          user: null,
          errorMessage: _errorMessage(error),
          isLoading: false,
        ),
      );
      _reportError(error, stackTrace);
    }
  }

  Future<void> logout() async {
    await _logoutUseCase.execute();
    state = const AsyncValue.data(AuthState.unauthenticated());
  }

  String _errorMessage(Object error) {
    if (error is AppException) {
      return error.message;
    }
    return 'We could not sign you in. Please try again.';
  }

  void _reportError(Object error, StackTrace stackTrace) {
    // In the future, hook into analytics/Sentry here.
  }

}
