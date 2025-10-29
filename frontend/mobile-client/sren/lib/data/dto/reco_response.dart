class RecommendationResponseDto {
  RecommendationResponseDto({
    required this.userId,
    required this.emotion,
    required this.contentTitle,
    required this.contentType,
    this.url,
    required this.rationale,
    required this.recommendedAt,
  });

  final String userId;
  final String emotion;
  final String contentTitle;
  final String contentType;
  final String? url;
  final String rationale;
  final DateTime recommendedAt;

  factory RecommendationResponseDto.fromJson(Map<String, dynamic> json) {
    return RecommendationResponseDto(
      userId: json['userId']?.toString() ?? '',
      emotion: json['emotion']?.toString() ?? 'NEUTRAL',
      contentTitle: json['contentTitle']?.toString() ?? '',
      contentType: json['contentType']?.toString() ?? 'ARTICLE',
      url: json['url']?.toString(),
      rationale: json['rationale']?.toString() ?? '',
      recommendedAt: DateTime.tryParse(
            json['recommendedAt']?.toString() ?? '',
          ) ??
          DateTime.now(),
    );
  }

  static List<RecommendationResponseDto> fromDynamic(dynamic data) {
    if (data is List) {
      return data
          .whereType<Map<String, dynamic>>()
          .map(RecommendationResponseDto.fromJson)
          .toList();
    } else if (data is Map<String, dynamic>) {
      return [RecommendationResponseDto.fromJson(data)];
    }
    return [];
  }
}
