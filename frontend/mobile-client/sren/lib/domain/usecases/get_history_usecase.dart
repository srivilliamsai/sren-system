import '../entities/emotion_entry.dart';
import '../repositories/emotion_repository.dart';

class GetHistoryUseCase {
  GetHistoryUseCase(this._emotionRepository);

  final EmotionRepository _emotionRepository;

  Future<List<EmotionEntry>> execute({
    required String userId,
    bool forceRefresh = false,
  }) {
    return _emotionRepository.fetchHistory(
      userId: userId,
      forceRefresh: forceRefresh,
    );
  }
}
