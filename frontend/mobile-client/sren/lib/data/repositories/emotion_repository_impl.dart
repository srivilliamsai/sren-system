import '../../core/errors/app_exception.dart';
import '../../domain/entities/emotion_analysis.dart';
import '../../domain/entities/emotion_entry.dart';
import '../../domain/repositories/emotion_repository.dart';
import '../dto/analyze_request.dart';
import '../dto/emotion_entry_dto.dart';
import '../models/emotion_analysis_model.dart';
import '../models/emotion_entry_model.dart';
import '../sources/local/history_local.dart';
import '../sources/remote/emotion_api.dart';

class EmotionRepositoryImpl implements EmotionRepository {
  EmotionRepositoryImpl({
    required EmotionApi emotionApi,
    required HistoryLocalDataSource localDataSource,
  })  : _emotionApi = emotionApi,
        _localDataSource = localDataSource;

  final EmotionApi _emotionApi;
  final HistoryLocalDataSource _localDataSource;

  @override
  Future<EmotionAnalysis> analyzeEmotion({
    required String userId,
    required String imageBase64,
  }) async {
    assert(userId.isNotEmpty, 'Emotion analysis requires a user id');
    final response = await _emotionApi.analyze(
      AnalyzeRequestDto(userId: userId, imageData: imageBase64),
    );

    final analysis = EmotionAnalysisModel.fromDto(response).toEntity();

    try {
      await persistHistory(
        userId: userId,
        entries: [
          EmotionEntry(
            emotion: analysis.dominantEmotion,
            confidence: analysis.confidence,
            capturedAt: analysis.capturedAt,
          ),
        ],
      );
    } catch (_) {
      // ignore cache failures
    }

    return analysis;
  }

  @override
  Future<List<EmotionEntry>> fetchHistory({
    required String userId,
    bool forceRefresh = false,
  }) async {
    if (!forceRefresh) {
      final cached = await _localDataSource.readHistory(userId);
      if (cached.isNotEmpty) {
        return cached.map((e) => e.toEntity()).toList(growable: false);
      }
    }

    try {
      final remoteEntries = await _emotionApi.fetchHistory(userId);
      final models = remoteEntries
          .map(EmotionEntryModel.fromDto)
          .toList(growable: false);

      await _localDataSource.cacheHistory(userId, models);

      return models.map((e) => e.toEntity()).toList(growable: false);
    } on AppException {
      final cached = await _localDataSource.readHistory(userId);
      if (cached.isNotEmpty) {
        return cached.map((e) => e.toEntity()).toList(growable: false);
      }
      rethrow;
    }
  }

  @override
  Future<void> persistHistory({
    required String userId,
    required List<EmotionEntry> entries,
  }) async {
    final models = entries
        .map(EmotionEntryModel.fromEntity)
        .toList(growable: false);
    final history = await _localDataSource.readHistory(userId);
    await _localDataSource.cacheHistory(
      userId,
      [
        ...models,
        ...history,
      ]..sort(
          (a, b) => b.capturedAt.compareTo(a.capturedAt),
        ),
    );

    try {
      for (final entry in entries) {
        await _emotionApi.storeEmotion(
          userId,
          EmotionEntryModel.fromEntity(entry).toDto(),
        );
      }
    } catch (_) {
      // Backend may not expose store endpoint; ignore silently.
    }
  }
}
