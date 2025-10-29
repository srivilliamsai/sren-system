class EmotionEntryDto {
  EmotionEntryDto({
    required this.emotion,
    required this.confidence,
    required this.capturedAt,
  });

  final String emotion;
  final double confidence;
  final DateTime capturedAt;

  factory EmotionEntryDto.fromJson(Map<String, dynamic> json) {
    return EmotionEntryDto(
      emotion: json['emotion']?.toString() ?? 'NEUTRAL',
      confidence: (json['confidence'] as num?)?.toDouble() ?? 0,
      capturedAt: DateTime.tryParse(
            json['capturedAt']?.toString() ?? '',
          ) ??
          DateTime.now(),
    );
  }

  Map<String, dynamic> toJson() => {
        'emotion': emotion,
        'confidence': confidence,
        'capturedAt': capturedAt.toIso8601String(),
      };
}
