import '../../core/errors/app_exception.dart';
import '../../domain/entities/recommendation.dart';
import '../../domain/repositories/recommendation_repository.dart';
import '../dto/reco_request.dart';
import '../models/recommendation_model.dart';
import '../sources/local/history_local.dart';
import '../sources/remote/reco_api.dart';

class RecommendationRepositoryImpl implements RecommendationRepository {
  RecommendationRepositoryImpl({
    required RecommendationApi recommendationApi,
    required HistoryLocalDataSource localDataSource,
  })  : _recommendationApi = recommendationApi,
        _localDataSource = localDataSource;

  final RecommendationApi _recommendationApi;
  final HistoryLocalDataSource _localDataSource;

  static const _fallbackContent = <String, Map<String, dynamic>>{
    'HAPPY': {
      'title': 'Upbeat Flow Playlist',
      'type': 'AUDIO',
      'url':
          'https://music.youtube.com/playlist?list=RDCLAK5uy_l2g7zDs2',
      'rationale': 'Keep the positive vibes high with curated tracks.',
    },
    'SAD': {
      'title': 'Calming Breath Meditation',
      'type': 'ARTICLE',
      'url': 'https://www.mindful.org/breathing-meditation-joy/',
      'rationale':
          'A guided breathing exercise to help balance heavy feelings.',
    },
    'ANGRY': {
      'title': 'Box Breathing in 4 Minutes',
      'type': 'VIDEO',
      'url': 'https://www.youtube.com/watch?v=tEmt1Znux58',
      'rationale':
          'Lower your heart rate with a simple guided box breathing video.',
    },
    'FEAR': {
      'title': 'Grounding Calm Podcast',
      'type': 'AUDIO',
      'url': 'https://open.spotify.com/episode/4K2gGcalmAnchor',
      'rationale':
          'A short reassurance session to ease anxiety and reconnect.',
    },
    'NEUTRAL': {
      'title': 'Discovery Mix',
      'type': 'AUDIO',
      'url': 'https://music.youtube.com/playlist?list=RDCLAK5uy_discover',
      'rationale':
          'Lean into curiosity with a mix tailored for an even mood.',
    },
    'SURPRISE': {
      'title': 'Curated Curiosity Playlist',
      'type': 'VIDEO',
      'url': 'https://www.youtube.com/watch?v=-Curiosity',
      'rationale': 'Explore something new and inspiring when surprised.',
    },
  };

  @override
  Future<List<Recommendation>> fetchRecommendations({
    required String userId,
    required String emotion,
  }) async {
    final normalizedEmotion = emotion.toUpperCase();
    try {
      final response = await _recommendationApi.getRecommendations(
        RecommendationRequestDto(
          userId: userId,
          emotion: normalizedEmotion,
        ),
      );

      var models = response
          .map(RecommendationModel.fromDto)
          .map((model) {
            if (model.url == null || model.url!.isEmpty) {
              final fallback =
                  _fallbackContent[normalizedEmotion] ?? _fallbackContent['NEUTRAL']!;
              return RecommendationModel(
                userId: userId,
                emotion: normalizedEmotion,
                contentTitle: fallback['title']!.toString(),
                contentType: fallback['type']!.toString(),
                url: fallback['url']!.toString(),
                rationale: fallback['rationale']!.toString(),
                recommendedAt: DateTime.now(),
              );
            }
            return model;
          })
          .toList(growable: false);

      if (models.isEmpty) {
        models = [
          RecommendationModel(
            userId: userId,
            emotion: normalizedEmotion,
            contentTitle:
                _fallbackContent[normalizedEmotion]?['title']?.toString() ??
                    'Mindful Reset',
            contentType:
                _fallbackContent[normalizedEmotion]?['type']?.toString() ??
                    'ARTICLE',
            url: _fallbackContent[normalizedEmotion]?['url']?.toString(),
            rationale: _fallbackContent[normalizedEmotion]?['rationale']
                    ?.toString() ??
                'Take a moment to reset with a curated suggestion.',
            recommendedAt: DateTime.now(),
          ),
        ];
      }

      await cacheRecommendations(
        userId: userId,
        recommendations: models.map((e) => e.toEntity()).toList(),
      );

      return models.map((e) => e.toEntity()).toList(growable: false);
    } on AppException {
      final cached = await readCachedRecommendations(userId: userId);
      if (cached.isNotEmpty) {
        return cached;
      }
      rethrow;
    }
  }

  @override
  Future<void> cacheRecommendations({
    required String userId,
    required List<Recommendation> recommendations,
  }) async {
    final models = recommendations
        .map(RecommendationModel.fromEntity)
        .toList(growable: false);
    await _localDataSource.cacheRecommendations(userId, models);
  }

  @override
  Future<List<Recommendation>> readCachedRecommendations({
    required String userId,
  }) async {
    final cached = await _localDataSource.readRecommendations(userId);
    return cached.map((e) => e.toEntity()).toList(growable: false);
  }
}
