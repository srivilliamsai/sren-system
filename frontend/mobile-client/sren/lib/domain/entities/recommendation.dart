enum RecommendationContentType { audio, video, article }

RecommendationContentType contentTypeFromString(String? value) {
  switch (value?.toUpperCase()) {
    case 'AUDIO':
      return RecommendationContentType.audio;
    case 'VIDEO':
      return RecommendationContentType.video;
    case 'ARTICLE':
    default:
      return RecommendationContentType.article;
  }
}

class Recommendation {
  const Recommendation({
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
  final RecommendationContentType contentType;
  final String? url;
  final String rationale;
  final DateTime recommendedAt;
}
