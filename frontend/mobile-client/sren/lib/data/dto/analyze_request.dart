class AnalyzeRequestDto {
  AnalyzeRequestDto({
    required this.userId,
    required this.imageData,
  });

  final String userId;
  final String imageData;

  Map<String, dynamic> toJson() => {
        'userId': userId,
        'imageData': imageData,
      };
}
