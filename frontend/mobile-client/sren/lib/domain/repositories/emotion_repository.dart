import '../entities/emotion_analysis.dart';
import '../entities/emotion_entry.dart';

abstract class EmotionRepository {
  Future<EmotionAnalysis> analyzeEmotion({
    required String userId,
    required String imageBase64,
  });

  Future<List<EmotionEntry>> fetchHistory({
    required String userId,
    bool forceRefresh = false,
  });

  Future<void> persistHistory({
    required String userId,
    required List<EmotionEntry> entries,
  });
}
