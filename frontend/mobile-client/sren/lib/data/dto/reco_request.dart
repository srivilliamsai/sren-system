class RecommendationRequestDto {
  RecommendationRequestDto({
    required this.userId,
    required this.emotion,
  });

  final String userId;
  final String emotion;

  Map<String, dynamic> toJson() => {
        'userId': userId,
        'emotion': emotion,
      };
}
