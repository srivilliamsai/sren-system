import 'dart:typed_data';

import 'package:camera/camera.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:go_router/go_router.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:image_picker/image_picker.dart';

import '../../../core/config/app_config.dart';
import '../../../core/di/locator.dart';
import '../../../core/utils/analytics.dart';
import '../../../core/utils/base64.dart';
import '../../../routing/app_router.dart';
import '../../../widgets/error_view.dart';
import '../../../widgets/primary_button.dart';
import '../../analyze/presentation/analyze_result_sheet.dart';
import '../../analyze/state/analyze_controller.dart';
import '../../auth/state/auth_controller.dart';
import '../../recommendations/state/recommendations_controller.dart';
import '../state/capture_controller.dart';
import '../../../domain/entities/emotion_analysis.dart';

const _sampleImageBase64 =
    'iVBORw0KGgoAAAANSUhEUgAAAAEAAAABCAYAAAAfFcSJAAAADUlEQVR4nGNgYPj/HwAE/wL+z6Ar2wAAAABJRU5ErkJggg==';

class CaptureScreen extends HookConsumerWidget {
  const CaptureScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final captureState = ref.watch(captureControllerProvider);
    final captureController = ref.read(captureControllerProvider.notifier);
    final analyzeState = ref.watch(analyzeControllerProvider);
    final analyzeController = ref.read(analyzeControllerProvider.notifier);
    final authState = ref.watch(authControllerProvider).valueOrNull;
    var user = authState?.user;

    final cameraController = useState<CameraController?>(null);
    final cameraError = useState<Object?>(null);
    final isCameraReady = useState(false);

    final camerasFuture = useMemoized(() => availableCameras(), const []);
    final camerasSnapshot = useFuture(camerasFuture);

    ref.listen<AsyncValue<EmotionAnalysis?>>(
      analyzeControllerProvider,
      (_, state) {
        state.whenOrNull(
          error: (error, __) {
            if (context.mounted) {
              final message = error is Exception
                  ? error.toString()
                  : 'Analysis failed. Try again.';
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(content: Text(message)),
              );
            }
          },
        );
      },
    );

    useEffect(() {
      Future<void> setupCamera() async {
        try {
          final cameras = camerasSnapshot.data;
          if (cameras == null || cameras.isEmpty) {
            cameraError.value =
                'No camera detected. Use gallery picker instead.';
            return;
          }
          final controller = CameraController(
            cameras.first,
            ResolutionPreset.medium,
            enableAudio: false,
          );
          await controller.initialize();
          cameraController.value = controller;
          isCameraReady.value = true;
        } catch (error) {
          cameraError.value = error;
        }
      }

      if (cameraController.value == null &&
          camerasSnapshot.connectionState == ConnectionState.done &&
          !AppConfig.mockMode) {
        setupCamera();
      }

      return () {
        cameraController.value?.dispose();
      };
    }, [camerasSnapshot.connectionState]);

    Future<void> handleImageBytes(Uint8List bytes) async {
      final base64 = encodeToBase64(bytes);
      captureController.setProcessing(true);
      captureController.setImage(base64);

      if (user == null) {
        captureController.setError('Please sign in again.');
        return;
      }

      if (user.id.isEmpty) {
        final authRepo = ref.read(authRepositoryProvider);
        final tokens = authRepo.currentTokens;
        if (tokens != null) {
          try {
            await authRepo.refreshTokens(tokens.refreshToken);
            final refreshedUser = authRepo.currentUser;
            if (refreshedUser != null && refreshedUser.id.isNotEmpty) {
              user = refreshedUser;
            }
          } catch (_) {
            // ignore, fallback handled below
          }
        }

        if (user == null || user!.id.isEmpty) {
          captureController.setError('We could not resolve your profile. Please sign out and sign in again.');
          return;
        }
      }

      assert(() {
        // ignore: avoid_print
        print('Analyzing emotion for user id: ${user!.id}');
        return true;
      }());

      final result = await analyzeController.analyze(
        userId: user!.id,
        imageBase64: base64,
      );
      captureController.setProcessing(false);

      if (result == null) {
        captureController.setError(
          'We could not analyze your emotion right now. Please try again.',
        );
        return;
      }

      if (context.mounted) {
        ref.read(analyticsServiceProvider).logEvent(
          'emotion_analyzed',
          {
            'userId': user.id,
            'emotion': result.dominantEmotion,
            'confidence': result.confidence,
          },
        );
        final shouldNavigate = await showModalBottomSheet<bool>(
          context: context,
          isScrollControlled: true,
          backgroundColor: Colors.transparent,
          builder: (_) => AnalyzeResultSheet(
            analysis: result,
            onGetRecommendations: () => Navigator.of(context).pop(true),
          ),
        );
        if (shouldNavigate == true && context.mounted) {
          final recommendationsController =
              ref.read(recommendationsControllerProvider.notifier);
          await recommendationsController.loadForEmotion(
            result.dominantEmotion,
          );
          if (context.mounted) {
            context.goNamed(AppRoute.feed.name);
          }
        }
      }
    }

    Future<void> capturePhoto() async {
      try {
        captureController.setProcessing(true);
        final controller = cameraController.value;
        if (controller == null || !controller.value.isInitialized) {
          throw CameraException('SREN', 'Camera not ready');
        }
        final file = await controller.takePicture();
        final bytes = await file.readAsBytes();
        await handleImageBytes(bytes);
      } catch (error, stackTrace) {
        if (kDebugMode) {
          debugPrint('Capture failed: $error\n$stackTrace');
        }
        captureController.setError(
          'We could not capture the photo. Please try again.',
        );
      }
    }

    Future<void> pickFromGallery() async {
      try {
        captureController.setProcessing(true);
        final picker = ImagePicker();
        final image = await picker.pickImage(source: ImageSource.gallery);
        if (image == null) {
          captureController.setProcessing(false);
          return;
        }
        final bytes = await image.readAsBytes();
        await handleImageBytes(bytes);
      } on PlatformException catch (error) {
        captureController.setError(
          error.message ?? 'Failed to access gallery.',
        );
      }
    }

    final isAnalyzing = analyzeState.isLoading;

    Widget buildPreview() {
      if (AppConfig.mockMode) {
        return _buildPlaceholder(context);
      }

      if (cameraError.value != null) {
        return Center(
          child: ErrorView(
            title: 'Camera unavailable',
            message: cameraError.value.toString(),
            onRetry: pickFromGallery,
          ),
        );
      }

      final controller = cameraController.value;
      if (!isCameraReady.value || controller == null) {
        return const Center(
          child: CircularProgressIndicator(),
        );
      }

      return ClipRRect(
        borderRadius: BorderRadius.circular(32),
        child: AspectRatio(
          aspectRatio: controller.value.aspectRatio,
          child: CameraPreview(controller),
        ),
      );
    }

    return Scaffold(
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Capture your mood',
                style: Theme.of(context).textTheme.headlineMedium,
              ),
              const SizedBox(height: 8),
              Text(
                'Take a quick snapshot to analyze your current emotion.',
                style: Theme.of(context).textTheme.bodyLarge,
              ),
              const SizedBox(height: 24),
              Expanded(child: buildPreview()),
              const SizedBox(height: 24),
              if (captureState.errorMessage != null)
                ErrorView(
                  message: captureState.errorMessage!,
                ),
              Row(
                children: [
                  Expanded(
                    child: PrimaryButton(
                      text: isAnalyzing || captureState.isProcessing
                          ? 'Analyzing…'
                          : 'Capture emotion',
                      onPressed: (isAnalyzing || captureState.isProcessing)
                          ? null
                          : (AppConfig.mockMode ? pickFromGallery : capturePhoto),
                    ),
                  ),
                  const SizedBox(width: 12),
                  IconButton(
                    icon: const Icon(Icons.photo_library_outlined),
                    onPressed:
                        (isAnalyzing || captureState.isProcessing) ? null : pickFromGallery,
                  ),
                ],
              ),
              if (!kReleaseMode)
                TextButton(
                  onPressed: (isAnalyzing || captureState.isProcessing)
                      ? null
                      : () async {
                          final bytes = decodeBase64Image(_sampleImageBase64);
                          await handleImageBytes(bytes);
                        },
                  child: const Text('Use sample image'),
                ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildPlaceholder(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(32),
        gradient: const LinearGradient(
          colors: [
            Color(0xFF1E1E1E),
            Color(0xFF2A2D32),
          ],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
      ),
      child: Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              Icons.camera_alt_outlined,
              color: Theme.of(context).colorScheme.secondary,
              size: 64,
            ),
            const SizedBox(height: 12),
            Text(
              'Camera mock mode enabled',
              style: Theme.of(context).textTheme.titleMedium,
            ),
            const SizedBox(height: 4),
            Text(
              'Select an image from your gallery or use a sample.',
              style: Theme.of(context).textTheme.bodyMedium,
            ),
          ],
        ),
      ),
    );
  }
}
