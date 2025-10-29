import 'package:hive/hive.dart';

import '../../domain/entities/emotion_entry.dart';
import '../dto/emotion_entry_dto.dart';

part 'emotion_entry_model.g.dart';

@HiveType(typeId: 0)
class EmotionEntryModel {
  EmotionEntryModel({
    required this.emotion,
    required this.confidence,
    required this.capturedAt,
  });

  factory EmotionEntryModel.fromDto(EmotionEntryDto dto) {
    return EmotionEntryModel(
      emotion: dto.emotion,
      confidence: dto.confidence,
      capturedAt: dto.capturedAt,
    );
  }

  factory EmotionEntryModel.fromEntity(EmotionEntry entry) {
    return EmotionEntryModel(
      emotion: entry.emotion,
      confidence: entry.confidence,
      capturedAt: entry.capturedAt,
    );
  }

  @HiveField(0)
  String emotion;

  @HiveField(1)
  double confidence;

  @HiveField(2)
  DateTime capturedAt;

  EmotionEntry toEntity() => EmotionEntry(
        emotion: emotion,
        confidence: confidence,
        capturedAt: capturedAt,
      );

  EmotionEntryDto toDto() => EmotionEntryDto(
        emotion: emotion,
        confidence: confidence,
        capturedAt: capturedAt,
      );
}
