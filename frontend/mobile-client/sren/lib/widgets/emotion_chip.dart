import 'package:flutter/material.dart';

import '../core/theme/app_theme.dart';

class EmotionChip extends StatelessWidget {
  const EmotionChip({
    super.key,
    required this.emotion,
  });

  final String emotion;

  @override
  Widget build(BuildContext context) {
    final normalized = emotion.toUpperCase();
    final color = AppTheme.emotionColors[normalized] ??
        Theme.of(context).colorScheme.secondary;
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      decoration: BoxDecoration(
        color: color.withOpacity(0.15),
        borderRadius: BorderRadius.circular(18),
      ),
      child: Text(
        normalized[0] + normalized.substring(1).toLowerCase(),
        style: Theme.of(context).textTheme.labelLarge?.copyWith(
              color: color,
            ),
      ),
    );
  }
}
