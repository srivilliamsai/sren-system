import 'package:hooks_riverpod/hooks_riverpod.dart';

import '../../../core/di/locator.dart';
import '../../../domain/entities/emotion_analysis.dart';
import '../../../domain/usecases/analyze_emotion_usecase.dart';

final analyzeControllerProvider =
    AutoDisposeAsyncNotifierProvider<AnalyzeController, EmotionAnalysis?>(
  AnalyzeController.new,
);

class AnalyzeController extends AutoDisposeAsyncNotifier<EmotionAnalysis?> {
  AnalyzeEmotionUseCase get _analyzeEmotionUseCase =>
      ref.read(analyzeEmotionUseCaseProvider);

  @override
  Future<EmotionAnalysis?> build() async => null;

  Future<EmotionAnalysis?> analyze({
    required String userId,
    required String imageBase64,
  }) async {
    state = const AsyncValue.loading();
    try {
      final result = await _analyzeEmotionUseCase.execute(
        userId: userId,
        imageBase64: imageBase64,
      );
      state = AsyncValue.data(result);
      return result;
    } catch (error, stackTrace) {
      state = AsyncValue.error(error, stackTrace);
      return null;
    }
  }
}
