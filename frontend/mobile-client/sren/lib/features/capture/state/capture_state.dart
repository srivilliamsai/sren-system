class CaptureState {
  const CaptureState({
    this.imageBase64,
    this.isProcessing = false,
    this.errorMessage,
  });

  final String? imageBase64;
  final bool isProcessing;
  final String? errorMessage;

  CaptureState copyWith({
    String? imageBase64,
    bool? isProcessing,
    String? errorMessage,
  }) {
    return CaptureState(
      imageBase64: imageBase64 ?? this.imageBase64,
      isProcessing: isProcessing ?? this.isProcessing,
      errorMessage: errorMessage,
    );
  }

  static const initial = CaptureState();
}
