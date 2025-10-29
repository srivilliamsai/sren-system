import 'package:dio/dio.dart';

import '../../../core/errors/app_exception.dart';
import '../../dto/reco_request.dart';
import '../../dto/reco_response.dart';

class RecommendationApi {
  RecommendationApi(this._dio);

  final Dio _dio;

  static const _recommendationsPath = '/api/v1/recommendations';

  Future<List<RecommendationResponseDto>> getRecommendations(
    RecommendationRequestDto request,
  ) async {
    try {
      final response = await _dio.post<dynamic>(
        _recommendationsPath,
        data: request.toJson(),
      );

      return RecommendationResponseDto.fromDynamic(response.data);
    } on DioException catch (error) {
      throw NetworkException.fromDioError(error);
    }
  }
}
