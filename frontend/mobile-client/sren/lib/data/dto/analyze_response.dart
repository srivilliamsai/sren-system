class AnalyzeResponseDto {
  AnalyzeResponseDto({
    required this.userId,
    required this.dominantEmotion,
    required this.confidence,
    required this.capturedAt,
  });

  final String userId;
  final String dominantEmotion;
  final double confidence;
  final DateTime capturedAt;

  factory AnalyzeResponseDto.fromJson(Map<String, dynamic> json) {
    return AnalyzeResponseDto(
      userId: json['userId']?.toString() ?? '',
      dominantEmotion: json['dominantEmotion']?.toString() ?? 'NEUTRAL',
      confidence: (json['confidence'] as num?)?.toDouble() ?? 0,
      capturedAt: DateTime.tryParse(
            json['capturedAt']?.toString() ?? '',
          ) ??
          DateTime.now(),
    );
  }
}
