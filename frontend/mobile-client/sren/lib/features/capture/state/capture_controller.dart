import 'package:hooks_riverpod/hooks_riverpod.dart';

import 'capture_state.dart';

final captureControllerProvider =
    StateNotifierProvider<CaptureController, CaptureState>(
  (ref) => CaptureController(),
);

class CaptureController extends StateNotifier<CaptureState> {
  CaptureController() : super(CaptureState.initial);

  void setImage(String imageBase64) {
    state = state.copyWith(
      imageBase64: imageBase64,
      isProcessing: state.isProcessing,
      errorMessage: null,
    );
  }

  void setProcessing(bool value) {
    state = state.copyWith(isProcessing: value, errorMessage: null);
  }

  void setError(String message) {
    state = state.copyWith(errorMessage: message, isProcessing: false);
  }

  void clear() {
    state = CaptureState.initial;
  }
}
