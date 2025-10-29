import 'package:dio/dio.dart';

import '../../../core/errors/app_exception.dart';

class UserApi {
  UserApi(this._dio);

  final Dio _dio;

  static const _usersPath = '/api/v1/users';

  Future<Map<String, dynamic>> fetchProfile(String userId) async {
    final path = '$_usersPath/$userId';
    try {
      final response = await _dio.get<dynamic>(path);
      return Map<String, dynamic>.from(response.data as Map);
    } on DioException catch (error) {
      throw NetworkException.fromDioError(error);
    }
  }
}
