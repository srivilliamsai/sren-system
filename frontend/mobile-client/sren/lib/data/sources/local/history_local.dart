import 'package:hive/hive.dart';

import '../../models/emotion_entry_model.dart';
import '../../models/recommendation_model.dart';

class HistoryLocalDataSource {
  HistoryLocalDataSource(this._hive);

  static const _historyBoxName = 'history';
  static const _recoBoxName = 'recommendations';

  final HiveInterface _hive;

  Box? _historyBox;
  Box? _recommendationBox;

  Future<void> init() async {
    _historyBox ??= await _hive.openBox(_historyBoxName);
    _recommendationBox ??= await _hive.openBox(_recoBoxName);
  }

  Future<void> cacheHistory(String userId, List<EmotionEntryModel> entries) async {
    await init();
    final box = _historyBox!;
    await box.put(userId, entries);
  }

  Future<List<EmotionEntryModel>> readHistory(String userId) async {
    await init();
    final box = _historyBox!;
    final entries = box.get(userId) as List<dynamic>? ?? <dynamic>[];
    return entries
        .whereType<EmotionEntryModel>()
        .toList(growable: false);
  }

  Future<void> cacheRecommendations(
    String userId,
    List<RecommendationModel> recommendations,
  ) async {
    await init();
    final box = _recommendationBox!;
    await box.put(userId, recommendations);
  }

  Future<List<RecommendationModel>> readRecommendations(String userId) async {
    await init();
    final box = _recommendationBox!;
    final entries = box.get(userId) as List<dynamic>? ?? <dynamic>[];
    return entries
        .whereType<RecommendationModel>()
        .toList(growable: false);
  }
}
