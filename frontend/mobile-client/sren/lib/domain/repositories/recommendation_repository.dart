import '../entities/recommendation.dart';

abstract class RecommendationRepository {
  Future<List<Recommendation>> fetchRecommendations({
    required String userId,
    required String emotion,
  });

  Future<void> cacheRecommendations({
    required String userId,
    required List<Recommendation> recommendations,
  });

  Future<List<Recommendation>> readCachedRecommendations({
    required String userId,
  });
}
