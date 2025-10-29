class EmotionAnalysis {
  const EmotionAnalysis({
    required this.userId,
    required this.dominantEmotion,
    required this.confidence,
    required this.capturedAt,
  });

  final String userId;
  final String dominantEmotion;
  final double confidence;
  final DateTime capturedAt;
}
