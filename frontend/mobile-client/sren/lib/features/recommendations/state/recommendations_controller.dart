import 'package:hooks_riverpod/hooks_riverpod.dart';

import '../../../core/errors/app_exception.dart';
import '../../../core/di/locator.dart';
import '../../../domain/entities/recommendation.dart';
import '../../../domain/repositories/recommendation_repository.dart';
import '../../../domain/usecases/get_recommendations_usecase.dart';
import '../../auth/state/auth_controller.dart';
import 'recommendations_state.dart';

final recommendationsControllerProvider =
    StateNotifierProvider<RecommendationsController, RecommendationsState>(
  (ref) => RecommendationsController(
    repository: ref.watch(recommendationRepositoryProvider),
    getRecommendationsUseCase: ref.watch(getRecommendationsUseCaseProvider),
    authController: ref.watch(authControllerProvider.notifier),
  ),
);

class RecommendationsController extends StateNotifier<RecommendationsState> {
  RecommendationsController({
    required RecommendationRepository repository,
    required GetRecommendationsUseCase getRecommendationsUseCase,
    required AuthController authController,
  })  : _repository = repository,
        _getRecommendationsUseCase = getRecommendationsUseCase,
        _authController = authController,
        super(RecommendationsState.initial);

  final RecommendationRepository _repository;
  final GetRecommendationsUseCase _getRecommendationsUseCase;
  final AuthController _authController;

  Future<void> loadForEmotion(String emotion) async {
    final user = _authController.state.valueOrNull?.user;
    if (user == null) {
      state = state.copyWith(
        errorMessage: 'You need to be signed in to view recommendations.',
      );
      return;
    }

    state = state.copyWith(
      isLoading: true,
      errorMessage: null,
      emotion: emotion.toUpperCase(),
    );

    try {
      final items = await _getRecommendationsUseCase.execute(
        userId: user.id,
        emotion: emotion,
      );

      await _repository.cacheRecommendations(
        userId: user.id,
        recommendations: items,
      );

      state = state.copyWith(
        items: items,
        isLoading: false,
        hasCache: true,
      );
    } catch (error) {
      final message = error is AppException
          ? error.message
          : 'Unable to fetch recommendations right now.';
      final cached = await _repository.readCachedRecommendations(
        userId: user?.id ?? '',
      );
      state = state.copyWith(
        items: cached,
        isLoading: false,
        hasCache: cached.isNotEmpty,
        errorMessage: message,
      );
    }
  }

  Future<void> refresh() async {
    final emotion = state.emotion;
    if (emotion == null) {
      return;
    }
    await loadForEmotion(emotion);
  }

  Future<void> loadCached() async {
    final user = _authController.state.valueOrNull?.user;
    if (user == null) {
      return;
    }
    final cached = await _repository.readCachedRecommendations(
      userId: user.id,
    );
    if (cached.isNotEmpty) {
      state = state.copyWith(
        items: cached,
        hasCache: true,
        errorMessage: null,
      );
    }
  }
}
