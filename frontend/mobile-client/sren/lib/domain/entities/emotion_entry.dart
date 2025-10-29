class EmotionEntry {
  const EmotionEntry({
    required this.emotion,
    required this.confidence,
    required this.capturedAt,
  });

  final String emotion;
  final double confidence;
  final DateTime capturedAt;
}
