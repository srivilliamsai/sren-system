import 'package:dio/dio.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:hive/hive.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../../data/repositories/auth_repository_impl.dart';
import '../../data/repositories/emotion_repository_impl.dart';
import '../../data/repositories/recommendation_repository_impl.dart';
import '../../data/sources/local/history_local.dart';
import '../../data/sources/remote/auth_api.dart';
import '../../data/sources/remote/emotion_api.dart';
import '../../data/sources/remote/reco_api.dart';
import '../../domain/repositories/auth_repository.dart';
import '../../domain/repositories/emotion_repository.dart';
import '../../domain/repositories/recommendation_repository.dart';
import '../../domain/usecases/analyze_emotion_usecase.dart';
import '../../domain/usecases/get_history_usecase.dart';
import '../../domain/usecases/get_recommendations_usecase.dart';
import '../../domain/usecases/login_usecase.dart';
import '../../domain/usecases/logout_usecase.dart';
import '../../domain/usecases/register_usecase.dart';
import '../network/dio_client.dart';
import '../utils/analytics.dart';
import '../utils/token_storage.dart';
import '../config/app_config.dart';

final hiveProvider = Provider<HiveInterface>((_) => Hive);

final secureStorageProvider = Provider<FlutterSecureStorage>(
  (_) => const FlutterSecureStorage(),
);

final tokenStorageProvider = Provider<TokenStorage>(
  (ref) => TokenStorage(ref.watch(secureStorageProvider)),
);

final sharedPreferencesProvider = Provider<SharedPreferences>(
  (ref) => throw UnimplementedError('SharedPreferences not provided'),
);

final analyticsServiceProvider = Provider<AnalyticsService>(
  (ref) => AnalyticsService(ref.watch(sharedPreferencesProvider)),
);

final historyLocalDataSourceProvider = Provider<HistoryLocalDataSource>(
  (ref) => HistoryLocalDataSource(ref.watch(hiveProvider)),
);

final authDioProvider = Provider<Dio>(
  (_) => Dio(
    BaseOptions(
      baseUrl: AppConfig.baseUrl,
      connectTimeout: const Duration(seconds: 15),
      receiveTimeout: const Duration(seconds: 20),
      contentType: Headers.jsonContentType,
    ),
  ),
);

final authApiProvider = Provider<AuthApi>(
  (ref) => AuthApi(ref.watch(authDioProvider)),
);

final dioProvider = Provider<Dio>((ref) {
  final tokenStorage = ref.watch(tokenStorageProvider);
  final authRepository = ref.watch(authRepositoryProvider);

  return DioClientFactory.create(
    tokenStorage: tokenStorage,
    refreshToken: (refreshToken) async {
      final tokens =
          await authRepository.refreshTokens(refreshToken);
      return TokenPair(
        accessToken: tokens.accessToken,
        refreshToken: tokens.refreshToken,
      );
    },
    onUnauthorized: () async {
      await authRepository.logout();
    },
  );
});

final emotionApiProvider = Provider<EmotionApi>(
  (ref) => EmotionApi(ref.watch(dioProvider)),
);

final recommendationApiProvider = Provider<RecommendationApi>(
  (ref) => RecommendationApi(ref.watch(dioProvider)),
);

final authRepositoryProvider = Provider<AuthRepository>((ref) {
  final repository = AuthRepositoryImpl(
    authApi: ref.watch(authApiProvider),
    tokenStorage: ref.watch(tokenStorageProvider),
  );
  ref.onDispose(repository.dispose);
  return repository;
});

final emotionRepositoryProvider = Provider<EmotionRepository>(
  (ref) => EmotionRepositoryImpl(
    emotionApi: ref.watch(emotionApiProvider),
    localDataSource: ref.watch(historyLocalDataSourceProvider),
  ),
);

final recommendationRepositoryProvider = Provider<RecommendationRepository>(
  (ref) => RecommendationRepositoryImpl(
    recommendationApi: ref.watch(recommendationApiProvider),
    localDataSource: ref.watch(historyLocalDataSourceProvider),
  ),
);

final loginUseCaseProvider = Provider(
  (ref) => LoginUseCase(ref.watch(authRepositoryProvider)),
);

final registerUseCaseProvider = Provider(
  (ref) => RegisterUseCase(ref.watch(authRepositoryProvider)),
);

final logoutUseCaseProvider = Provider(
  (ref) => LogoutUseCase(ref.watch(authRepositoryProvider)),
);

final analyzeEmotionUseCaseProvider = Provider(
  (ref) => AnalyzeEmotionUseCase(ref.watch(emotionRepositoryProvider)),
);

final getRecommendationsUseCaseProvider = Provider(
  (ref) => GetRecommendationsUseCase(
    ref.watch(recommendationRepositoryProvider),
  ),
);

final getHistoryUseCaseProvider = Provider(
  (ref) => GetHistoryUseCase(ref.watch(emotionRepositoryProvider)),
);
