import 'package:flutter/material.dart';

import '../../../core/theme/app_theme.dart';
import '../../../core/utils/date_fmt.dart';
import '../../../domain/entities/emotion_analysis.dart';
import '../../../widgets/primary_button.dart';

class AnalyzeResultSheet extends StatelessWidget {
  const AnalyzeResultSheet({
    super.key,
    required this.analysis,
    required this.onGetRecommendations,
  });

  final EmotionAnalysis analysis;
  final VoidCallback onGetRecommendations;

  @override
  Widget build(BuildContext context) {
    final color = AppTheme.emotionColors[analysis.dominantEmotion.toUpperCase()] ??
        Theme.of(context).colorScheme.secondary;
    final confidence = (analysis.confidence * 100).clamp(0, 100).round();

    return Container(
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surface,
        borderRadius: const BorderRadius.vertical(top: Radius.circular(32)),
      ),
      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 24),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: 48,
            height: 4,
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(0.2),
              borderRadius: BorderRadius.circular(4),
            ),
          ),
          const SizedBox(height: 24),
          Text(
            'Analysis complete',
            style: Theme.of(context).textTheme.titleMedium,
          ),
          const SizedBox(height: 12),
          _EmotionBadge(
            emotion: analysis.dominantEmotion,
            color: color,
            confidence: confidence,
          ),
          const SizedBox(height: 16),
          Text(
            'Captured ${DateFmt.relative(analysis.capturedAt)} • ${DateFmt.time(analysis.capturedAt)}',
            style: Theme.of(context).textTheme.bodySmall,
          ),
          const SizedBox(height: 24),
          PrimaryButton(
            text: 'View tailored recommendations',
            onPressed: onGetRecommendations,
          ),
          const SizedBox(height: 12),
          Text(
            'We paired your dominant emotion with fresh wellness content, podcasts, and playlists.',
            style: Theme.of(context).textTheme.bodyMedium,
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 16),
        ],
      ),
    );
  }
}

class _EmotionBadge extends StatelessWidget {
  const _EmotionBadge({
    required this.emotion,
    required this.color,
    required this.confidence,
  });

  final String emotion;
  final Color color;
  final int confidence;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        gradient: RadialGradient(
          colors: [
            color.withOpacity(0.8),
            color.withOpacity(0.3),
          ],
        ),
        boxShadow: [
          BoxShadow(
            color: color.withOpacity(0.25),
            blurRadius: 24,
            spreadRadius: 4,
          ),
        ],
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            '${confidence.toString()}%',
            style: Theme.of(context)
                .textTheme
                .headlineMedium
                ?.copyWith(color: Colors.black, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 6),
          Text(
            emotion[0].toUpperCase() + emotion.substring(1).toLowerCase(),
            style: Theme.of(context)
                .textTheme
                .titleMedium
                ?.copyWith(color: Colors.black87),
          ),
        ],
      ),
    );
  }
}
