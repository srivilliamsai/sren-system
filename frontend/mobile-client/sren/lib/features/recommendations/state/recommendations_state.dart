import '../../../domain/entities/recommendation.dart';

class RecommendationsState {
  const RecommendationsState({
    required this.items,
    this.isLoading = false,
    this.errorMessage,
    this.emotion,
    this.hasCache = false,
  });

  final List<Recommendation> items;
  final bool isLoading;
  final String? errorMessage;
  final String? emotion;
  final bool hasCache;

  RecommendationsState copyWith({
    List<Recommendation>? items,
    bool? isLoading,
    String? errorMessage,
    String? emotion,
    bool? hasCache,
  }) {
    return RecommendationsState(
      items: items ?? this.items,
      isLoading: isLoading ?? this.isLoading,
      errorMessage: errorMessage,
      emotion: emotion ?? this.emotion,
      hasCache: hasCache ?? this.hasCache,
    );
  }

  static const initial = RecommendationsState(items: []);
}
