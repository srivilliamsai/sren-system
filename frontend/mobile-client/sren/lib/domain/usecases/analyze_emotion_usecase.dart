import '../entities/emotion_analysis.dart';
import '../repositories/emotion_repository.dart';

class AnalyzeEmotionUseCase {
  AnalyzeEmotionUseCase(this._emotionRepository);

  final EmotionRepository _emotionRepository;

  Future<EmotionAnalysis> execute({
    required String userId,
    required String imageBase64,
  }) {
    return _emotionRepository.analyzeEmotion(
      userId: userId,
      imageBase64: imageBase64,
    );
  }
}
