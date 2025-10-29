import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';

import '../core/theme/app_theme.dart';
import '../core/utils/date_fmt.dart';
import '../domain/entities/recommendation.dart';
import 'emotion_chip.dart';
import 'primary_button.dart';

class RecommendationCard extends StatelessWidget {
  const RecommendationCard({
    super.key,
    required this.recommendation,
    this.onTap,
  });

  final Recommendation recommendation;
  final VoidCallback? onTap;

  IconData _iconForType(RecommendationContentType type) {
    return switch (type) {
      RecommendationContentType.audio => Icons.music_note,
      RecommendationContentType.video => Icons.play_circle_outline,
      RecommendationContentType.article => Icons.menu_book_outlined,
    };
  }

  Future<void> _launchUrl(BuildContext context, String url) async {
    final uri = Uri.parse(url);
    if (!await launchUrl(uri, mode: LaunchMode.externalApplication)) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Unable to open link.')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final color = AppTheme.emotionColors[recommendation.emotion.toUpperCase()] ??
        Theme.of(context).colorScheme.secondary;
    final icon = _iconForType(recommendation.contentType);

    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      decoration: BoxDecoration(
        color: Theme.of(context).cardColor,
        borderRadius: BorderRadius.circular(28),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.25),
            blurRadius: 24,
            offset: const Offset(0, 16),
          ),
        ],
      ),
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                EmotionChip(emotion: recommendation.emotion),
                const Spacer(),
                Text(
                  DateFmt.relative(recommendation.recommendedAt),
                  style: Theme.of(context).textTheme.bodySmall,
                ),
              ],
            ),
            const SizedBox(height: 16),
            Icon(
              icon,
              color: color,
              size: 32,
            ),
            const SizedBox(height: 12),
            Text(
              recommendation.contentTitle,
              style: Theme.of(context)
                  .textTheme
                  .titleLarge
                  ?.copyWith(fontWeight: FontWeight.w600),
            ),
            const SizedBox(height: 12),
            Text(
              recommendation.rationale,
              style: Theme.of(context).textTheme.bodyMedium,
            ),
            const SizedBox(height: 20),
            if (recommendation.url != null)
              PrimaryButton(
                text: 'Open',
                icon: icon,
                onPressed: () async {
                  if (onTap != null) {
                    onTap!();
                  }
                  await _launchUrl(context, recommendation.url!);
                },
              ),
          ],
        ),
      ),
    );
  }
}
