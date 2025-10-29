import 'package:hive/hive.dart';

import '../../domain/entities/recommendation.dart';
import '../dto/reco_response.dart';

part 'recommendation_model.g.dart';

@HiveType(typeId: 1)
class RecommendationModel {
  RecommendationModel({
    required this.userId,
    required this.emotion,
    required this.contentTitle,
    required this.contentType,
    this.url,
    required this.rationale,
    required this.recommendedAt,
  });

  factory RecommendationModel.fromDto(RecommendationResponseDto dto) {
    return RecommendationModel(
      userId: dto.userId,
      emotion: dto.emotion,
      contentTitle: dto.contentTitle,
      contentType: dto.contentType,
      url: dto.url,
      rationale: dto.rationale,
      recommendedAt: dto.recommendedAt,
    );
  }

  factory RecommendationModel.fromEntity(Recommendation recommendation) {
    return RecommendationModel(
      userId: recommendation.userId,
      emotion: recommendation.emotion,
      contentTitle: recommendation.contentTitle,
      contentType: recommendation.contentType.name.toUpperCase(),
      url: recommendation.url,
      rationale: recommendation.rationale,
      recommendedAt: recommendation.recommendedAt,
    );
  }

  @HiveField(0)
  String userId;

  @HiveField(1)
  String emotion;

  @HiveField(2)
  String contentTitle;

  @HiveField(3)
  String contentType;

  @HiveField(4)
  String? url;

  @HiveField(5)
  String rationale;

  @HiveField(6)
  DateTime recommendedAt;

  Recommendation toEntity() => Recommendation(
        userId: userId,
        emotion: emotion,
        contentTitle: contentTitle,
        contentType: contentTypeFromString(contentType),
        url: url,
        rationale: rationale,
        recommendedAt: recommendedAt,
      );
}
