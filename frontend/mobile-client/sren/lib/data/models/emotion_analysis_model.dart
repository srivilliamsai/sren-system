import '../../domain/entities/emotion_analysis.dart';
import '../dto/analyze_response.dart';

class EmotionAnalysisModel {
  EmotionAnalysisModel({
    required this.userId,
    required this.dominantEmotion,
    required this.confidence,
    required this.capturedAt,
  });

  final String userId;
  final String dominantEmotion;
  final double confidence;
  final DateTime capturedAt;

  factory EmotionAnalysisModel.fromDto(AnalyzeResponseDto dto) {
    return EmotionAnalysisModel(
      userId: dto.userId,
      dominantEmotion: dto.dominantEmotion,
      confidence: dto.confidence,
      capturedAt: dto.capturedAt,
    );
  }

  EmotionAnalysis toEntity() => EmotionAnalysis(
        userId: userId,
        dominantEmotion: dominantEmotion,
        confidence: confidence,
        capturedAt: capturedAt,
      );
}
