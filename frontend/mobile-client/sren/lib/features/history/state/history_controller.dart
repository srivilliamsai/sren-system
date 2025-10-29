import 'package:hooks_riverpod/hooks_riverpod.dart';

import '../../../core/errors/app_exception.dart';
import '../../../core/di/locator.dart';
import '../../../domain/repositories/emotion_repository.dart';
import '../../../domain/usecases/get_history_usecase.dart';
import '../../auth/state/auth_controller.dart';
import 'history_state.dart';

final historyControllerProvider =
    StateNotifierProvider<HistoryController, HistoryState>(
  (ref) => HistoryController(
    getHistoryUseCase: ref.watch(getHistoryUseCaseProvider),
    emotionRepository: ref.watch(emotionRepositoryProvider),
    authController: ref.watch(authControllerProvider.notifier),
  ),
);

class HistoryController extends StateNotifier<HistoryState> {
  HistoryController({
    required GetHistoryUseCase getHistoryUseCase,
    required EmotionRepository emotionRepository,
    required AuthController authController,
  })  : _getHistoryUseCase = getHistoryUseCase,
        _emotionRepository = emotionRepository,
        _authController = authController,
        super(HistoryState.initial);

  final GetHistoryUseCase _getHistoryUseCase;
  final EmotionRepository _emotionRepository;
  final AuthController _authController;

  Future<void> load({bool forceRefresh = false}) async {
    final user = _authController.state.valueOrNull?.user;
    if (user == null) {
      state = state.copyWith(
        errorMessage: 'You need to sign in to access your history.',
      );
      return;
    }

    state = state.copyWith(isLoading: true, errorMessage: null);
    try {
      final entries = await _getHistoryUseCase.execute(
        userId: user.id,
        forceRefresh: forceRefresh,
      );
      state = state.copyWith(
        entries: entries,
        isLoading: false,
      );
    } catch (error) {
      final message = error is AppException
          ? error.message
          : 'We were unable to load your history.';
      state = state.copyWith(isLoading: false, errorMessage: message);
    }
  }

  Future<void> cacheEntry({
    required String userId,
    required List<dynamic> entries,
  }) async {
    // Placeholder for manual cache updates if needed.
  }

  void changeRange(HistoryRange range) {
    state = state.copyWith(range: range);
  }

  void toggleEmotion(String emotion) {
    final filters = Set<String>.from(state.filteredEmotions);
    final normalized = emotion.toUpperCase();
    if (!filters.add(normalized)) {
      filters.remove(normalized);
    }
    state = state.copyWith(filteredEmotions: filters);
  }
}
