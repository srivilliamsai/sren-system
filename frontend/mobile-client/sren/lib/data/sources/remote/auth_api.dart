import 'package:dio/dio.dart';

import '../../../core/errors/app_exception.dart';
import '../../dto/login_request.dart';
import '../../dto/login_response.dart';

class AuthApi {
  AuthApi(this._dio);

  final Dio _dio;

  static const _loginPath = '/api/v1/auth/login';
  static const _registerPath = '/api/v1/auth/register';
  static const _refreshPath = '/api/v1/auth/refresh';

  Future<LoginResponseDto> login(LoginRequestDto request) async {
    try {
      final response = await _dio.post<dynamic>(
        _loginPath,
        data: request.toJson(),
      );
      assert(() {
        // ignore: avoid_print
        print('Login response data: ${response.data}');
        return true;
      }());
      return LoginResponseDto.fromJson(
        Map<String, dynamic>.from(response.data as Map),
      );
    } on DioException catch (error) {
      throw NetworkException.fromDioError(error);
    }
  }

  Future<String> register({
    required String name,
    required String email,
    required String password,
  }) async {
    final trimmedName = name.trim();
    final parts = trimmedName.split(RegExp(r'\s+'));
    final firstName = parts.isNotEmpty ? parts.first : trimmedName;
    final tail =
        parts.length > 1 ? parts.sublist(1).join(' ').trim() : '';
    final lastName = tail.isNotEmpty ? tail : firstName;

    try {
      final response = await _dio.post<dynamic>(
        _registerPath,
        data: {
          'name': trimmedName,
          'fullName': trimmedName,
          'email': email.trim(),
          'password': password,
          'firstName': firstName,
          'lastName': lastName,
        },
      );

      final body = Map<String, dynamic>.from(response.data as Map);
      return body['id']?.toString() ?? '';
    } on DioException catch (error) {
      throw NetworkException.fromDioError(error);
    }
  }

  Future<Map<String, dynamic>> refresh(String refreshToken) async {
    try {
      final response = await _dio.post<dynamic>(
        _refreshPath,
        data: {
          'refreshToken': refreshToken,
        },
      );
      return Map<String, dynamic>.from(response.data as Map);
    } on DioException catch (error) {
      throw NetworkException.fromDioError(error);
    }
  }
}
