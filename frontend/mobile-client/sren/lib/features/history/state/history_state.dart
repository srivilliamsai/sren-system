import '../../../domain/entities/emotion_entry.dart';

enum HistoryRange { week, month, all }

class HistoryState {
  const HistoryState({
    required this.entries,
    this.range = HistoryRange.week,
    this.filteredEmotions = const <String>{},
    this.isLoading = false,
    this.errorMessage,
  });

  final List<EmotionEntry> entries;
  final HistoryRange range;
  final Set<String> filteredEmotions;
  final bool isLoading;
  final String? errorMessage;

  HistoryState copyWith({
    List<EmotionEntry>? entries,
    HistoryRange? range,
    Set<String>? filteredEmotions,
    bool? isLoading,
    String? errorMessage,
  }) {
    return HistoryState(
      entries: entries ?? this.entries,
      range: range ?? this.range,
      filteredEmotions: filteredEmotions ?? this.filteredEmotions,
      isLoading: isLoading ?? this.isLoading,
      errorMessage: errorMessage,
    );
  }

  List<EmotionEntry> get filteredEntries {
    final cutoff = switch (range) {
      HistoryRange.week => DateTime.now().subtract(const Duration(days: 7)),
      HistoryRange.month => DateTime.now().subtract(const Duration(days: 30)),
      HistoryRange.all => DateTime.fromMillisecondsSinceEpoch(0),
    };

    return entries.where((entry) {
      final matchesRange = entry.capturedAt.isAfter(cutoff);
      final matchesEmotion = filteredEmotions.isEmpty ||
          filteredEmotions.contains(entry.emotion.toUpperCase());
      return matchesRange && matchesEmotion;
    }).toList(growable: false);
  }

  static const initial = HistoryState(entries: []);
}
