import '../entities/recommendation.dart';
import '../repositories/recommendation_repository.dart';

class GetRecommendationsUseCase {
  GetRecommendationsUseCase(this._recommendationRepository);

  final RecommendationRepository _recommendationRepository;

  Future<List<Recommendation>> execute({
    required String userId,
    required String emotion,
  }) {
    return _recommendationRepository.fetchRecommendations(
      userId: userId,
      emotion: emotion,
    );
  }
}
