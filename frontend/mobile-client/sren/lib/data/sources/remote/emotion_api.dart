import 'package:dio/dio.dart';

import '../../../core/errors/app_exception.dart';
import '../../dto/analyze_request.dart';
import '../../dto/analyze_response.dart';
import '../../dto/emotion_entry_dto.dart';

class EmotionApi {
  EmotionApi(this._dio);

  final Dio _dio;

  static const _analyzePath = '/api/v1/emotions/analyze';
  static const _historyPath = '/api/v1/users';

  Future<AnalyzeResponseDto> analyze(AnalyzeRequestDto request) async {
    try {
      assert(
        request.userId.isNotEmpty,
        'Analyze request requires non-empty userId',
      );
      final response = await _dio.post<dynamic>(
        _analyzePath,
        data: request.toJson(),
      );

      return AnalyzeResponseDto.fromJson(
        Map<String, dynamic>.from(response.data as Map),
      );
    } on DioException catch (error) {
      throw NetworkException.fromDioError(error);
    }
  }

  Future<List<EmotionEntryDto>> fetchHistory(String userId) async {
    final path = '$_historyPath/$userId/emotions';
    try {
      final response = await _dio.get<dynamic>(path);
      final body = response.data;
      if (body is List) {
        return body
            .whereType<Map<String, dynamic>>()
            .map(EmotionEntryDto.fromJson)
            .toList();
      }
      return [];
    } on DioException catch (error) {
      throw NetworkException.fromDioError(error);
    }
  }

  Future<void> storeEmotion(String userId, EmotionEntryDto dto) async {
    final path = '$_historyPath/$userId/emotions';
    try {
      await _dio.post<dynamic>(
        path,
        data: dto.toJson(),
      );
    } on DioException catch (error) {
      throw NetworkException.fromDioError(error);
    }
  }
}
