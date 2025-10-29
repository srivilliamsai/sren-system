import '../../../domain/entities/user.dart';

enum AuthStatus {
  unknown,
  authenticated,
  unauthenticated,
}

class AuthState {
  const AuthState({
    required this.status,
    this.user,
    this.errorMessage,
    this.isLoading = false,
  });

  const AuthState.unknown()
      : status = AuthStatus.unknown,
        user = null,
        errorMessage = null,
        isLoading = false;

  const AuthState.authenticated(User user)
      : status = AuthStatus.authenticated,
        user = user,
        errorMessage = null,
        isLoading = false;

  const AuthState.unauthenticated()
      : status = AuthStatus.unauthenticated,
        user = null,
        errorMessage = null,
        isLoading = false;

  final AuthStatus status;
  final User? user;
  final String? errorMessage;
  final bool isLoading;

  AuthState copyWith({
    AuthStatus? status,
    User? user,
    String? errorMessage,
    bool? isLoading,
  }) {
    return AuthState(
      status: status ?? this.status,
      user: user ?? this.user,
      errorMessage: errorMessage,
      isLoading: isLoading ?? this.isLoading,
    );
  }
}
