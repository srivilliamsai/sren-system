import 'dart:io';

import 'package:dio/dio.dart';

/// Base application-level exception that surfaces user-facing messaging.
abstract class AppException implements Exception {
  AppException(this.message, {this.cause, this.stackTrace});

  /// Localized-friendly summary that can be shown to end users.
  final String message;

  /// Underlying error when available.
  final Object? cause;

  /// Useful for error reporting.
  final StackTrace? stackTrace;

  @override
  String toString() => '$runtimeType: $message';
}

class NetworkException extends AppException {
  NetworkException(
    super.message, {
    this.statusCode,
    this.errorCode,
    super.cause,
    super.stackTrace,
  });

  final int? statusCode;
  final String? errorCode;

  factory NetworkException.fromDioError(DioException error) {
    final response = error.response;
    final statusCode = response?.statusCode;
    final errorBody = response?.data;
    final message = _extractMessage(error) ??
        _extractMessageFromResponse(errorBody) ??
        _mapStatusCodeToMessage(statusCode) ??
        'We are having trouble reaching the server. Try again shortly.';

    return NetworkException(
      message,
      statusCode: statusCode,
      errorCode: errorBody is Map<String, dynamic>
          ? errorBody['code']?.toString()
          : null,
      cause: error,
      stackTrace: error.stackTrace,
    );
  }

  static String? _extractMessage(DioException error) {
    if (error.type == DioExceptionType.connectionTimeout ||
        error.type == DioExceptionType.sendTimeout ||
        error.type == DioExceptionType.receiveTimeout) {
      return 'Connection timed out. Please check your connectivity and retry.';
    }
    if (error.type == DioExceptionType.connectionError) {
      if (error.error is SocketException) {
        return 'It looks like you are offline. We will retry automatically when the connection is back.';
      }
      return 'Network connection error occurred.';
    }
    return null;
  }

  static String? _extractMessageFromResponse(dynamic errorBody) {
    if (errorBody is Map<String, dynamic>) {
      return (errorBody['message'] ?? errorBody['error'])?.toString();
    }
    return null;
  }

  static String? _mapStatusCodeToMessage(int? statusCode) {
    switch (statusCode) {
      case 400:
        return 'Invalid request. Please double-check the information.';
      case 401:
        return 'Your session has expired. Please sign in again.';
      case 403:
        return 'You are not permitted to perform this action.';
      case 404:
        return 'We could not find the requested resource.';
      case 500:
      case 502:
      case 503:
      case 504:
        return 'The service is momentarily unavailable. Please try again soon.';
      default:
        return null;
    }
  }
}

class AuthException extends AppException {
  AuthException(super.message, {super.cause, super.stackTrace});
}

class CacheException extends AppException {
  CacheException(super.message, {super.cause, super.stackTrace});
}
