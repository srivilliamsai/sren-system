import 'dart:async';

import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';
import 'package:pretty_dio_logger/pretty_dio_logger.dart';

import '../config/app_config.dart';
import '../utils/token_storage.dart';

class TokenPair {
  TokenPair({
    required this.accessToken,
    required this.refreshToken,
  });

  final String accessToken;
  final String refreshToken;
}

typedef RefreshTokenCallback = Future<TokenPair> Function(String refreshToken);
typedef LogoutCallback = Future<void> Function();

class DioClientFactory {
  const DioClientFactory._();

  static Dio create({
    required TokenStorage tokenStorage,
    required RefreshTokenCallback refreshToken,
    required LogoutCallback onUnauthorized,
  }) {
    final dio = Dio(
      BaseOptions(
        baseUrl: AppConfig.baseUrl,
        connectTimeout: const Duration(seconds: 15),
        receiveTimeout: const Duration(seconds: 20),
        contentType: Headers.jsonContentType,
        responseType: ResponseType.json,
      ),
    );

    final retryInterceptor = _RetryInterceptor(
      dio: dio,
      tokenStorage: tokenStorage,
      refreshToken: refreshToken,
      onUnauthorized: onUnauthorized,
    );

    dio.interceptors.addAll([
      _AuthInterceptor(tokenStorage),
      retryInterceptor,
      if (!kReleaseMode)
        PrettyDioLogger(
          requestHeader: true,
          requestBody: true,
          responseBody: true,
          responseHeader: false,
          compact: true,
        ),
    ]);

    return dio;
  }
}

class _AuthInterceptor extends QueuedInterceptor {
  _AuthInterceptor(this._tokenStorage);

  final TokenStorage _tokenStorage;

  @override
  Future<void> onRequest(
    RequestOptions options,
    RequestInterceptorHandler handler,
  ) async {
    if (_shouldSkip(options)) {
      handler.next(options);
      return;
    }

    final token = await _tokenStorage.readAccessToken();
    if (token != null && token.isNotEmpty) {
      options.headers['Authorization'] = 'Bearer $token';
    }
    handler.next(options);
  }

  bool _shouldSkip(RequestOptions options) {
    const excludedPaths = <String>{
      '/api/v1/auth/login',
      '/api/v1/auth/register',
      '/api/v1/auth/refresh',
    };

    return excludedPaths.contains(options.path);
  }
}

class _RetryInterceptor extends QueuedInterceptor {
  _RetryInterceptor({
    required Dio dio,
    required TokenStorage tokenStorage,
    required RefreshTokenCallback refreshToken,
    required LogoutCallback onUnauthorized,
  })  : _dio = dio,
        _tokenStorage = tokenStorage,
        _refreshTokenCallback = refreshToken,
        _onUnauthorized = onUnauthorized;

  final Dio _dio;
  final TokenStorage _tokenStorage;
  final RefreshTokenCallback _refreshTokenCallback;
  final LogoutCallback _onUnauthorized;

  Completer<TokenPair>? _refreshCompleter;

  @override
  Future<void> onError(
    DioException err,
    ErrorInterceptorHandler handler,
  ) async {
    if (_shouldAttemptRefresh(err)) {
      try {
        final tokenPair = await _refreshTokens();
        final response = await _retryRequest(err.requestOptions, tokenPair);
        handler.resolve(response);
        return;
      } on DioException catch (dioErr, stackTrace) {
        await _onUnauthorized();
        handler.reject(dioErr.copyWith(stackTrace: stackTrace));
        return;
      } catch (_) {
        await _onUnauthorized();
        handler.reject(err);
        return;
      }
    } else if (_isTransientError(err) && err.requestOptions.extra['retry'] != true) {
      try {
        final response = await _retryWithDelay(err.requestOptions);
        handler.resolve(response);
        return;
      } catch (retryErr, stackTrace) {
        if (retryErr is DioException) {
          handler.reject(retryErr.copyWith(stackTrace: stackTrace));
          return;
        }
      }
    }

    handler.next(err);
  }

  Future<Response<dynamic>> _retryRequest(
    RequestOptions requestOptions,
    TokenPair tokenPair,
  ) async {
    final options = Options(
      method: requestOptions.method,
      headers: {
        ...requestOptions.headers,
        'Authorization': 'Bearer ${tokenPair.accessToken}',
      },
      responseType: requestOptions.responseType,
      contentType: requestOptions.contentType,
      receiveTimeout: requestOptions.receiveTimeout,
      sendTimeout: requestOptions.sendTimeout,
      extra: {
        ...requestOptions.extra,
        'retry': true,
      },
    );

    return _dio.request<dynamic>(
      requestOptions.path,
      data: requestOptions.data,
      queryParameters: requestOptions.queryParameters,
      options: options,
    );
  }

  Future<Response<dynamic>> _retryWithDelay(
    RequestOptions requestOptions,
  ) async {
    await Future<void>.delayed(const Duration(milliseconds: 350));
    return _dio.request<dynamic>(
      requestOptions.path,
      data: requestOptions.data,
      queryParameters: requestOptions.queryParameters,
      options: Options(
        method: requestOptions.method,
        headers: requestOptions.headers,
        responseType: requestOptions.responseType,
        contentType: requestOptions.contentType,
        receiveTimeout: requestOptions.receiveTimeout,
        sendTimeout: requestOptions.sendTimeout,
        extra: {
          ...requestOptions.extra,
          'retry': true,
        },
      ),
    );
  }

  Future<TokenPair> _refreshTokens() async {
    if (_refreshCompleter != null) {
      return _refreshCompleter!.future;
    }

    _refreshCompleter = Completer<TokenPair>();
    try {
      final refreshToken = await _tokenStorage.readRefreshToken();
      if (refreshToken == null || refreshToken.isEmpty) {
        throw DioException(
          requestOptions: RequestOptions(path: '/api/v1/auth/refresh'),
          error: 'Missing refresh token',
        );
      }

      final tokenPair = await _refreshTokenCallback(refreshToken);
      await _tokenStorage.saveTokens(
        accessToken: tokenPair.accessToken,
        refreshToken: tokenPair.refreshToken,
      );
      _refreshCompleter!.complete(tokenPair);
      return tokenPair;
    } catch (error, stackTrace) {
      _refreshCompleter!.completeError(error, stackTrace);
      rethrow;
    } finally {
      _refreshCompleter = null;
    }
  }

  bool _shouldAttemptRefresh(DioException error) {
    final statusCode = error.response?.statusCode;
    return statusCode == 401 && !_isAuthEndpoint(error.requestOptions.path);
  }

  bool _isAuthEndpoint(String path) {
    return path.contains('/auth/login') ||
        path.contains('/auth/register') ||
        path.contains('/auth/refresh');
  }

  bool _isTransientError(DioException error) {
    return error.type == DioExceptionType.connectionTimeout ||
        error.type == DioExceptionType.receiveTimeout ||
        error.type == DioExceptionType.sendTimeout ||
        error.type == DioExceptionType.connectionError;
  }
}
