import 'dart:async';
import 'dart:convert';

import '../../core/errors/app_exception.dart';
import '../../core/utils/token_storage.dart';
import '../../domain/entities/auth_tokens.dart';
import '../../domain/entities/user.dart';
import '../../domain/repositories/auth_repository.dart';
import '../dto/login_request.dart';
import '../dto/login_response.dart';
import '../models/user_model.dart';
import '../sources/remote/auth_api.dart';

class AuthRepositoryImpl implements AuthRepository {
  AuthRepositoryImpl({
    required AuthApi authApi,
    required TokenStorage tokenStorage,
  })  : _authApi = authApi,
        _tokenStorage = tokenStorage;

  final AuthApi _authApi;
  final TokenStorage _tokenStorage;

  final _userController = StreamController<User?>.broadcast();

  AuthTokens? _tokens;
  User? _currentUser;
  bool _initialized = false;

  @override
  Stream<User?> get userStream => _userController.stream;

  @override
  User? get currentUser => _currentUser;

  @override
  AuthTokens? get currentTokens => _tokens;

  @override
  Future<void> init() async {
    if (_initialized) {
      return;
    }
    _initialized = true;
    final access = await _tokenStorage.readAccessToken();
    final refresh = await _tokenStorage.readRefreshToken();
    final profileJson = await _tokenStorage.readProfile();

    if (access != null && refresh != null) {
      _tokens = AuthTokens(
        accessToken: access,
        refreshToken: refresh,
      );
    }

    if (profileJson != null) {
      var userModel = UserModel.fromJson(profileJson);
      if (userModel.id.isEmpty) {
        final fallbackId =
            _extractUserId(_tokens?.accessToken ?? '') ??
                _extractUserId(_tokens?.refreshToken ?? '') ??
                '';
        if (fallbackId.isNotEmpty) {
          userModel = UserModel(
            id: fallbackId,
            name: userModel.name,
            email: userModel.email,
            avatarUrl: userModel.avatarUrl,
          );
          await _tokenStorage.saveProfile(userModel.toJson());
        }
      }
      _currentUser = userModel.toEntity();
      _userController.add(_currentUser);
    }
  }

  @override
  Future<User> login({
    required String email,
    required String password,
  }) async {
    final response = await _authApi.login(
      LoginRequestDto(email: email, password: password),
    );

    var userModel = UserModel.fromProfile(response.profile);

    final resolvedId = await _resolveUserId(
      candidate: userModel.id,
      accessToken: response.accessToken,
      refreshToken: response.refreshToken,
    );
    assert(() {
      // Helps diagnose missing IDs during development.
      // ignore: avoid_print
      print('Resolved user id: $resolvedId');
      return true;
    }());

    if (resolvedId.isEmpty) {
      throw AuthException(
        'Unable to determine your profile identifier. Please try again later.',
      );
    }

    assert(resolvedId.isNotEmpty, 'Resolved user id must not be empty');

    userModel = UserModel(
      id: resolvedId,
      name: userModel.name,
      email: userModel.email,
      avatarUrl: userModel.avatarUrl,
    );

    final user = userModel.toEntity();

    _tokens = AuthTokens(
      accessToken: response.accessToken,
      refreshToken: response.refreshToken,
    );

    _currentUser = user;
    await _tokenStorage.saveTokens(
      accessToken: response.accessToken,
      refreshToken: response.refreshToken,
    );
    await _tokenStorage.saveProfile(userModel.toJson());

    _userController.add(user);
    return user;
  }

  @override
  Future<String> register({
    required String name,
    required String email,
    required String password,
  }) {
    return _authApi.register(
      name: name,
      email: email,
      password: password,
    );
  }

  @override
  Future<void> logout() async {
    _tokens = null;
    _currentUser = null;
    await _tokenStorage.clear();
    _userController.add(null);
  }

  @override
  Future<AuthTokens> refreshTokens(String refreshToken) async {
    try {
      final response = await _authApi.refresh(refreshToken);
      final accessToken = response['accessToken']?.toString() ?? '';
      final refresh = response['refreshToken']?.toString() ?? refreshToken;
      if (accessToken.isEmpty) {
        throw AuthException('Failed to refresh session.');
      }
      _tokens = AuthTokens(
        accessToken: accessToken,
        refreshToken: refresh,
      );
      await _tokenStorage.saveTokens(
        accessToken: accessToken,
        refreshToken: refresh,
      );
      if (_currentUser != null) {
        final resolvedId = await _resolveUserId(
          candidate: _currentUser!.id,
          accessToken: accessToken,
          refreshToken: refresh,
        );

        _currentUser = _currentUser!.copyWith(id: resolvedId.isEmpty ? _currentUser!.id : resolvedId);

        await _tokenStorage.saveProfile(
          UserModel(
            id: _currentUser!.id,
            name: _currentUser!.name,
            email: _currentUser!.email,
            avatarUrl: _currentUser!.avatarUrl,
          ).toJson(),
        );
      }
      return _tokens!;
    } on AppException {
      rethrow;
    } catch (error, stackTrace) {
      throw AuthException(
        'Unable to refresh your session, please login again.',
        cause: error,
        stackTrace: stackTrace,
      );
    }
  }

  void dispose() {
    _userController.close();
  }

  String? _extractUserId(String token) {
    try {
      final parts = token.split('.');
      if (parts.length < 2) {
        return null;
      }
      final normalized = base64Url.normalize(parts[1]);
      final payloadJson = utf8.decode(base64Url.decode(normalized));
      final payload = jsonDecode(payloadJson) as Map<String, dynamic>;
      return payload['sub']?.toString() ??
          payload['userId']?.toString() ??
          payload['user_id']?.toString();
    } catch (_) {
      return null;
    }
  }

  Future<String?> _readStoredUserId() async {
    final stored = await _tokenStorage.readProfile();
    final id = stored?['id']?.toString();
    if (id != null && id.isNotEmpty) {
      return id;
    }
    return stored?['userId']?.toString() ?? stored?['user_id']?.toString();
  }

  Future<String> _resolveUserId({
    required String candidate,
    required String accessToken,
    required String refreshToken,
  }) async {
    if (candidate.isNotEmpty) {
      return candidate;
    }

    final tokenId = _extractUserId(accessToken) ??
        _extractUserId(refreshToken);
    if (tokenId != null && tokenId.isNotEmpty) {
      return tokenId;
    }

    final stored = await _readStoredUserId();
    return stored ?? '';
  }
}
